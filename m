From: Rusty Russell <rusty@rustcorp.com.au>
Subject: Re: [PATCH] pktgen: nowait parameter.
Date: Fri, 05 Sep 2014 11:19:19 +0930
Message-ID: <87sik6kfa8.fsf@rustcorp.com.au>
References: <87oauxibda.fsf@rustcorp.com.au> <20140903110956.0872841f@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: netdev <netdev@vger.kernel.org>,
	Mathias Krause <minipli@googlemail.com>, brouer@redhat.com,
	Robert Olsson <robert@herjulf.net>
To: Jesper Dangaard Brouer <brouer@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ozlabs.org ([103.22.144.67]:40807 "EHLO ozlabs.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755862AbaIECev (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 4 Sep 2014 22:34:51 -0400
In-Reply-To: <20140903110956.0872841f@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Jesper Dangaard Brouer <brouer@redhat.com> writes:
> On Wed, 03 Sep 2014 13:50:01 +0930
> Rusty Russell <rusty@rustcorp.com.au> wrote:
>
>> While trying to measure speed of virtio_net, I was getting hangs.
>> This is because we skb_orphan() but delay the tx interrupt
>> indefinitely (by number of slots).
>> 
>> With nowait, pktgen won't wait for the skb to be released.  This
>> introduces an error, but it's ok if count >> ringsize.
>
> This pktgen_wait_for_skb() only happens it the exit case, when count
> packets have been send.  I guess its okay to proceed to
> pktgen_stop_device() which will call kfree_skb(pkt_dev->skb) with
> refcnt=2, decrementing to refcnt=1, and then we depend on driver to
> eventually call kfree_skb().

Yes, exactly.

>> I updated the documentation, but it needs far more work (it
>> refers to pgset and an examples directory, none of which exist
>> in the kernel tree).
>
> Yes, the doc is not in such a good shape.
>
> I'm not 100% happy with the name "nowait" parameter, as users could
> easily misunderstand the purpose of this parameter.  But I've not come
> up with a better name, e.g. "exit_nowait" is also not the best.

Agreed.  It could also be a flag, though that doesn't help with the name.

> diff --git a/net/core/pktgen.c b/net/core/pktgen.c
>> index 8b849ddfef2e..adc41f2b3bc7 100644
>> --- a/net/core/pktgen.c
>> +++ b/net/core/pktgen.c
>> @@ -290,6 +290,11 @@ struct pktgen_dev {
>>  				 * set clone_skb to 1024.
>>  				 */
>>  
>> +	bool no_wait;		/*
>> +				 * Don't wait for packet to be freed
>> +				 * by driver
>> +				 */
>> +
>
> DaveM prefers multi line comments like:
>
>  /* Don't wait for packet to be freed
>   * by driver
>   */

He does, but the rest of the kernel and the comment immediately above
doesn't:

	int clone_skb;		/*
				 * Use multiple SKBs during packet gen.
				 * If this number is greater than 1, then
				 * that many copies of the same packet will be
				 * sent before a new packet is allocated.
				 * If you want to send 1024 identical packets
				 * before creating a new packet,
				 * set clone_skb to 1024.
				 */

>>  	char dst_min[IP_NAME_SZ];	/* IP, ie 1.2.3.4 */
>>  	char dst_max[IP_NAME_SZ];	/* IP, ie 1.2.3.4 */
>>  	char src_min[IP_NAME_SZ];	/* IP, ie 1.2.3.4 */
>> @@ -679,6 +684,9 @@ static int pktgen_if_show(struct seq_file *seq, void *v)
>>  
>>  	seq_puts(seq, "\n");
>>  
>> +	if (pkt_dev->no_wait)
>> +		seq_puts(seq, "     nowait\n");
>> +
>
> Shouldn't you put this print statement above the "Flags:" section?

Sure.

>>  	/* not really stopped, more like last-running-at */
>>  	stopped = pkt_dev->running ? ktime_get() : pkt_dev->stopped_at;
>>  	idle = pkt_dev->idle_acc;
>> @@ -1711,6 +1719,17 @@ static ssize_t pktgen_if_write(struct file *file,

Subject: pktgen: nowait parameter.

While trying to measure speed of virtio_net, I was getting hangs.
This is because we skb_orphan() but delay the tx interrupt
indefinitely (by number of slots).

With nowait, pktgen won't wait for the skb to be released.  This
introduces an error, but it's ok if count >> ringsize.

I updated the documentation, but it needs far more work (it
refers to pgset and an examples directory, none of which exist
in the kernel tree).

Signed-off-by: Rusty Russell <rusty@rustcorp.com.au>

diff --git a/Documentation/networking/pktgen.txt b/Documentation/networking/pktgen.txt
index 0dffc6e37902..dbd993d1e7f8 100644
--- a/Documentation/networking/pktgen.txt
+++ b/Documentation/networking/pktgen.txt
@@ -41,10 +41,13 @@ NIC HW layer (which is bad for bufferbloat).
 One should be careful to conclude, that packets/descriptors in the HW
 TX ring cause delay.  Drivers usually delay cleaning up the
 ring-buffers (for various performance reasons), thus packets stalling
-the TX ring, might just be waiting for cleanup.
+the TX ring, might just be waiting for cleanup.  Writing the "nowait"
+parameter into /proc/net/pktgen/ethX will avoid waiting for cleanup of
+the final packets, introducing a slight error (tiny if the count of
+packets being sent is much greater than the ring size of the device).
 
-This cleanup issues is specifically the case, for the driver ixgbe
-(Intel 82599 chip).  This driver (ixgbe) combine TX+RX ring cleanups,
+Alternately, some drivers (eg ixgbe for the Intel 82599 chip) can
+have their cleanup interval changed.  ixgbe combines TX+RX ring cleanups,
 and the cleanup interval is affected by the ethtool --coalesce setting
 of parameter "rx-usecs".
 
@@ -303,6 +306,8 @@ flowlen
 rate
 ratep
 
+nowait
+
 References:
 ftp://robur.slu.se/pub/Linux/net-development/pktgen-testing/
 ftp://robur.slu.se/pub/Linux/net-development/pktgen-testing/examples/
diff --git a/net/core/pktgen.c b/net/core/pktgen.c
index 8b849ddfef2e..1589f5ac0509 100644
--- a/net/core/pktgen.c
+++ b/net/core/pktgen.c
@@ -290,6 +290,8 @@ struct pktgen_dev {
 				 * set clone_skb to 1024.
 				 */
 
+	bool no_wait;		/* Don't wait for packet to be freed by driver */
+
 	char dst_min[IP_NAME_SZ];	/* IP, ie 1.2.3.4 */
 	char dst_max[IP_NAME_SZ];	/* IP, ie 1.2.3.4 */
 	char src_min[IP_NAME_SZ];	/* IP, ie 1.2.3.4 */
@@ -615,6 +617,9 @@ static int pktgen_if_show(struct seq_file *seq, void *v)
 	if (pkt_dev->node >= 0)
 		seq_printf(seq, "     node: %d\n", pkt_dev->node);
 
+	if (pkt_dev->no_wait)
+		seq_puts(seq, "     nowait\n");
+
 	seq_puts(seq, "     Flags: ");
 
 	if (pkt_dev->flags & F_IPV6)
@@ -1711,6 +1716,17 @@ static ssize_t pktgen_if_write(struct file *file,
 		return count;
 	}
 
+	if (!strcmp(name, "nowait")) {
+		len = num_arg(&user_buffer[i], 10, &value);
+		if (len < 0)
+			return len;
+
+		i += len;
+		pkt_dev->no_wait = value;
+		sprintf(pg_result, "OK: nowait=%u", pkt_dev->no_wait);
+		return count;
+	}
+
 	sprintf(pkt_dev->result, "No such parameter \"%s\"", name);
 	return -EINVAL;
 }
@@ -3373,7 +3389,8 @@ unlock:
 
 	/* If pkt_dev->count is zero, then run forever */
 	if ((pkt_dev->count != 0) && (pkt_dev->sofar >= pkt_dev->count)) {
-		pktgen_wait_for_skb(pkt_dev);
+		if (!pkt_dev->no_wait)
+			pktgen_wait_for_skb(pkt_dev);
 
 		/* Done with this */
 		pktgen_stop_device(pkt_dev);
@@ -3565,6 +3582,7 @@ static int pktgen_add_device(struct pktgen_thread *t, const char *ifname)
 	pkt_dev->svlan_cfi = 0;
 	pkt_dev->svlan_id = 0xffff;
 	pkt_dev->node = -1;
+	pkt_dev->no_wait = false;
 
 	err = pktgen_setup_dev(t->net, pkt_dev, ifname);
 	if (err)
