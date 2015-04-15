From: George Dunlap <george.dunlap@eu.citrix.com>
Subject: Re: [Xen-devel] "tcp: refine TSO autosizing" causes performance regression
 on Xen
Date: Wed, 15 Apr 2015 18:41:16 +0100
Message-ID: <552EA2BC.5000707@eu.citrix.com>
References: <alpine.DEB.2.02.1504091344260.7690@kaball.uk.xensource.com>
	 <1428596218.25985.263.camel@edumazet-glaptop2.roam.corp.google.com>
	 <alpine.DEB.2.02.1504091729160.7690@kaball.uk.xensource.com>
	 <CAFLBxZaVjFHh4UBnksGZS4waBr4jLdO8aJegyKvsU1-TvVt2Dg@mail.gmail.com>
	 <1428932970.3834.4.camel@edumazet-glaptop2.roam.corp.google.com>
	 <CAFLBxZYt7-v29ysm=f+5QMOw64_QhESjzj98udba+1cS-PfObA@mail.gmail.com>
	 <1429115934.7346.107.camel@edumazet-glaptop2.roam.corp.google.com>
	 <552E9E8D.1080000@eu.citrix.com>
 <1429118948.7346.114.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: multipart/mixed;
	boundary="------------050503070601030601010806"
Cc: Jonathan Davies <Jonathan.Davies@citrix.com>,
	"xen-devel@lists.xensource.com" <xen-devel@lists.xensource.com>,
	Wei Liu <wei.liu2@citrix.com>,
	Ian Campbell <Ian.Campbell@citrix.com>,
	"Stefano Stabellini" <stefano.stabellini@eu.citrix.com>,
	netdev <netdev@vger.kernel.org>,
	Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
	Eric Dumazet <edumazet@google.com>,
	"Paul Durrant" <paul.durrant@citrix.com>,
	Christoffer Dall <christoffer.dall@linaro.org>,
	Felipe Franciosi <felipe.franciosi@citrix.com>,
	<linux-arm-kernel@lists.infradead.org>,
	"David Vrabel" <david.vrabel@citrix.com>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp02.citrix.com ([66.165.176.63]:23222 "EHLO
	SMTP02.CITRIX.COM" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932746AbbDORmR (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 15 Apr 2015 13:42:17 -0400
In-Reply-To: <1429118948.7346.114.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

--------------050503070601030601010806
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit

On 04/15/2015 06:29 PM, Eric Dumazet wrote:
> On Wed, 2015-04-15 at 18:23 +0100, George Dunlap wrote:
>> On 04/15/2015 05:38 PM, Eric Dumazet wrote:
>>> My thoughts that instead of these long talks you should guys read the
>>> code :
>>>
>>>                 /* TCP Small Queues :
>>>                  * Control number of packets in qdisc/devices to two packets / or ~1 ms.
>>>                  * This allows for :
>>>                  *  - better RTT estimation and ACK scheduling
>>>                  *  - faster recovery
>>>                  *  - high rates
>>>                  * Alas, some drivers / subsystems require a fair amount
>>>                  * of queued bytes to ensure line rate.
>>>                  * One example is wifi aggregation (802.11 AMPDU)
>>>                  */
>>>                 limit = max(2 * skb->truesize, sk->sk_pacing_rate >> 10);
>>>                 limit = min_t(u32, limit, sysctl_tcp_limit_output_bytes);
>>>
>>>
>>> Then you'll see that most of your questions are already answered.
>>>
>>> Feel free to try to improve the behavior, if it does not hurt critical workloads
>>> like TCP_RR, where we we send very small messages, millions times per second.
>>
>> First of all, with regard to critical workloads, once this patch gets
>> into distros, *normal TCP streams* on every VM running on Amazon,
>> Rackspace, Linode, &c will get a 30% hit in performance *by default*.
>> Normal TCP streams on xennet *are* a critical workload, and deserve the
>> same kind of accommodation as TCP_RR (if not more).  The same goes for
>> virtio_net.
>>
>> Secondly, according to Stefano's and Jonathan's tests,
>> tcp_limit_output_bytes completely fixes the problem for Xen.
>>
>> Which means that max(2*skb->truesize, sk->sk_pacing_rate >>10) is
>> *already* larger for Xen; that calculation mentioned in the comment is
>> *already* doing the right thing.
>>
>> As Jonathan pointed out, sysctl_tcp_limit_output_bytes is overriding an
>> automatic TSQ calculation which is actually choosing an effective value
>> for xennet.
>>
>> It certainly makes sense for sysctl_tcp_limit_output_bytes to be an
>> actual maximum limit.  I went back and looked at the original patch
>> which introduced it (46d3ceabd), and it looks to me like it was designed
>> to be a rough, quick estimate of "two packets outstanding" (by choosing
>> the maximum size of the packet, 64k, and multiplying it by two).
>>
>> Now that you have a better algorithm -- the size of 2 actual packets or
>> the amount transmitted in 1ms -- it seems like the default
>> sysctl_tcp_limit_output_bytes should be higher, and let the automatic
>> TSQ you have on the first line throttle things down when necessary.
> 
> 
> I asked you guys to make a test by increasing
> sysctl_tcp_limit_output_bytes

So you'd be OK with a patch like this?  (With perhaps a better changelog?)

 -George

---
TSQ: Raise default static TSQ limit

A new dynamic TSQ limit was introduced in c/s 605ad7f18 based on the
size of actual packets and the amount of data being transmitted.
Raise the default static limit to allow that new limit to actually
come into effect.

This fixes a regression where NICs with large transmit completion
times (such as xennet) had a 30% hit unless the user manually tweaked
the value in /proc.

Signed-off-by: George Dunlap <george.dunlap@eu.citrix.com>

diff --git a/net/ipv4/tcp_output.c b/net/ipv4/tcp_output.c
index 1db253e..8ad7cdf 100644
--- a/net/ipv4/tcp_output.c
+++ b/net/ipv4/tcp_output.c
@@ -50,8 +50,8 @@ int sysctl_tcp_retrans_collapse __read_mostly = 1;
  */
 int sysctl_tcp_workaround_signed_windows __read_mostly = 0;

-/* Default TSQ limit of two TSO segments */
-int sysctl_tcp_limit_output_bytes __read_mostly = 131072;
+/* Static TSQ limit.  A more dynamic limit is calculated in
tcp_write_xmit. */
+int sysctl_tcp_limit_output_bytes __read_mostly = 1048576;

 /* This limits the percentage of the congestion window which we
  * will allow a single TSO frame to consume.  Building TSO frames


--------------050503070601030601010806
Content-Type: text/x-patch; name="tsq-raise-default-static.diff"
Content-Transfer-Encoding: 7bit
Content-Disposition: attachment; filename="tsq-raise-default-static.diff"

TSQ: Raise default static TSQ limit
    
A new dynamic TSQ limit was introduced in c/s 605ad7f18 based on the
size of actual packets and the amount of data being transmitted.
Raise the default static limit to allow that new limit to actually
come into effect.
 
This fixes a regression where NICs with large transmit completion
times (such as xennet) had a 30% hit unless the user manually tweaked
the value in /proc.
    
Signed-off-by: George Dunlap <george.dunlap@eu.citrix.com>

diff --git a/net/ipv4/tcp_output.c b/net/ipv4/tcp_output.c
index 1db253e..8ad7cdf 100644
--- a/net/ipv4/tcp_output.c
+++ b/net/ipv4/tcp_output.c
@@ -50,8 +50,8 @@ int sysctl_tcp_retrans_collapse __read_mostly = 1;
  */
 int sysctl_tcp_workaround_signed_windows __read_mostly = 0;
 
-/* Default TSQ limit of two TSO segments */
-int sysctl_tcp_limit_output_bytes __read_mostly = 131072;
+/* Static TSQ limit.  A more dynamic limit is calculated in tcp_write_xmit. */
+int sysctl_tcp_limit_output_bytes __read_mostly = 1048576;
 
 /* This limits the percentage of the congestion window which we
  * will allow a single TSO frame to consume.  Building TSO frames

--------------050503070601030601010806--
