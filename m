From: Jason Wang <jasowang@redhat.com>
Subject: Re: [PATCH] pktgen: nowait parameter.
Date: Fri, 05 Sep 2014 10:52:22 +0800
Message-ID: <54092566.8080307@redhat.com>
References: <87oauxibda.fsf@rustcorp.com.au> <20140903110956.0872841f@redhat.com> <87sik6kfa8.fsf@rustcorp.com.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>,
	Mathias Krause <minipli@googlemail.com>,
	Robert Olsson <robert@herjulf.net>
To: Rusty Russell <rusty@rustcorp.com.au>,
	Jesper Dangaard Brouer <brouer@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:2890 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751536AbaIECwh (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 4 Sep 2014 22:52:37 -0400
In-Reply-To: <87sik6kfa8.fsf@rustcorp.com.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 09/05/2014 09:49 AM, Rusty Russell wrote:
> Jesper Dangaard Brouer <brouer@redhat.com> writes:
>> > On Wed, 03 Sep 2014 13:50:01 +0930
>> > Rusty Russell <rusty@rustcorp.com.au> wrote:
>> >
>>> >> While trying to measure speed of virtio_net, I was getting hangs.
>>> >> This is because we skb_orphan() but delay the tx interrupt
>>> >> indefinitely (by number of slots).
>>> >> 
>>> >> With nowait, pktgen won't wait for the skb to be released.  This
>>> >> introduces an error, but it's ok if count >> ringsize.
>> >
>> > This pktgen_wait_for_skb() only happens it the exit case, when count
>> > packets have been send.  I guess its okay to proceed to
>> > pktgen_stop_device() which will call kfree_skb(pkt_dev->skb) with
>> > refcnt=2, decrementing to refcnt=1, and then we depend on driver to
>> > eventually call kfree_skb().
> Yes, exactly.
>
>>> >> I updated the documentation, but it needs far more work (it
>>> >> refers to pgset and an examples directory, none of which exist
>>> >> in the kernel tree).
>> >
>> > Yes, the doc is not in such a good shape.
>> >
>> > I'm not 100% happy with the name "nowait" parameter, as users could
>> > easily misunderstand the purpose of this parameter.  But I've not come
>> > up with a better name, e.g. "exit_nowait" is also not the best.
> Agreed.  It could also be a flag, though that doesn't help with the name.
>
>> > diff --git a/net/core/pktgen.c b/net/core/pktgen.c
>>> >> index 8b849ddfef2e..adc41f2b3bc7 100644
>>> >> --- a/net/core/pktgen.c
>>> >> +++ b/net/core/pktgen.c
>>> >> @@ -290,6 +290,11 @@ struct pktgen_dev {
>>> >>  				 * set clone_skb to 1024.
>>> >>  				 */
>>> >>  
>>> >> +	bool no_wait;		/*
>>> >> +				 * Don't wait for packet to be freed
>>> >> +				 * by driver
>>> >> +				 */
>>> >> +
>> >
>> > DaveM prefers multi line comments like:
>> >
>> >  /* Don't wait for packet to be freed
>> >   * by driver
>> >   */
> He does, but the rest of the kernel and the comment immediately above
> doesn't:
>
> 	int clone_skb;		/*
> 				 * Use multiple SKBs during packet gen.
> 				 * If this number is greater than 1, then
> 				 * that many copies of the same packet will be
> 				 * sent before a new packet is allocated.
> 				 * If you want to send 1024 identical packets
> 				 * before creating a new packet,
> 				 * set clone_skb to 1024.
> 				 */
>
>>> >>  	char dst_min[IP_NAME_SZ];	/* IP, ie 1.2.3.4 */
>>> >>  	char dst_max[IP_NAME_SZ];	/* IP, ie 1.2.3.4 */
>>> >>  	char src_min[IP_NAME_SZ];	/* IP, ie 1.2.3.4 */
>>> >> @@ -679,6 +684,9 @@ static int pktgen_if_show(struct seq_file *seq, void *v)
>>> >>  
>>> >>  	seq_puts(seq, "\n");
>>> >>  
>>> >> +	if (pkt_dev->no_wait)
>>> >> +		seq_puts(seq, "     nowait\n");
>>> >> +
>> >
>> > Shouldn't you put this print statement above the "Flags:" section?
> Sure.
>
>>> >>  	/* not really stopped, more like last-running-at */
>>> >>  	stopped = pkt_dev->running ? ktime_get() : pkt_dev->stopped_at;
>>> >>  	idle = pkt_dev->idle_acc;
>>> >> @@ -1711,6 +1719,17 @@ static ssize_t pktgen_if_write(struct file *file,
> Subject: pktgen: nowait parameter.
>
> While trying to measure speed of virtio_net, I was getting hangs.
> This is because we skb_orphan() but delay the tx interrupt
> indefinitely (by number of slots).
>
> With nowait, pktgen won't wait for the skb to be released.  This
> introduces an error, but it's ok if count >> ringsize.
>
> I updated the documentation, but it needs far more work (it
> refers to pgset and an examples directory, none of which exist
> in the kernel tree).
>
> Signed-off-by: Rusty Russell <rusty@rustcorp.com.au>

This depends on user to know the internals of driver (e.g whether the tx
completion is delayed by something e.g using skb_orphan()) which may not
be a good idea. We may change the virtio-net to use tx interrupt in the
future (I'm testing a draft patch to do this). How about something
transparent to the user? I post a patch that marking such device with a
special flag (https://patchwork.kernel.org/patch/1800711/), but not all
like it. Maybe we need a new ndo_tx_polling() for pktgen or someone else
to poll the tx completion?

Thanks
