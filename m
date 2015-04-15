From: George Dunlap <george.dunlap@eu.citrix.com>
Subject: Re: [Xen-devel] "tcp: refine TSO autosizing" causes performance regression
 on Xen
Date: Wed, 15 Apr 2015 18:23:25 +0100
Message-ID: <552E9E8D.1080000@eu.citrix.com>
References: <alpine.DEB.2.02.1504091344260.7690@kaball.uk.xensource.com>
	 <1428596218.25985.263.camel@edumazet-glaptop2.roam.corp.google.com>
	 <alpine.DEB.2.02.1504091729160.7690@kaball.uk.xensource.com>
	 <CAFLBxZaVjFHh4UBnksGZS4waBr4jLdO8aJegyKvsU1-TvVt2Dg@mail.gmail.com>
	 <1428932970.3834.4.camel@edumazet-glaptop2.roam.corp.google.com>
	 <CAFLBxZYt7-v29ysm=f+5QMOw64_QhESjzj98udba+1cS-PfObA@mail.gmail.com>
 <1429115934.7346.107.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 8bit
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
Received: from smtp02.citrix.com ([66.165.176.63]:13975 "EHLO
	SMTP02.CITRIX.COM" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756217AbbDORX4 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 15 Apr 2015 13:23:56 -0400
In-Reply-To: <1429115934.7346.107.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 04/15/2015 05:38 PM, Eric Dumazet wrote:
> My thoughts that instead of these long talks you should guys read the
> code :
> 
>                 /* TCP Small Queues :
>                  * Control number of packets in qdisc/devices to two packets / or ~1 ms.
>                  * This allows for :
>                  *  - better RTT estimation and ACK scheduling
>                  *  - faster recovery
>                  *  - high rates
>                  * Alas, some drivers / subsystems require a fair amount
>                  * of queued bytes to ensure line rate.
>                  * One example is wifi aggregation (802.11 AMPDU)
>                  */
>                 limit = max(2 * skb->truesize, sk->sk_pacing_rate >> 10);
>                 limit = min_t(u32, limit, sysctl_tcp_limit_output_bytes);
> 
> 
> Then you'll see that most of your questions are already answered.
> 
> Feel free to try to improve the behavior, if it does not hurt critical workloads
> like TCP_RR, where we we send very small messages, millions times per second.

First of all, with regard to critical workloads, once this patch gets
into distros, *normal TCP streams* on every VM running on Amazon,
Rackspace, Linode, &c will get a 30% hit in performance *by default*.
Normal TCP streams on xennet *are* a critical workload, and deserve the
same kind of accommodation as TCP_RR (if not more).  The same goes for
virtio_net.

Secondly, according to Stefano's and Jonathan's tests,
tcp_limit_output_bytes completely fixes the problem for Xen.

Which means that max(2*skb->truesize, sk->sk_pacing_rate >>10) is
*already* larger for Xen; that calculation mentioned in the comment is
*already* doing the right thing.

As Jonathan pointed out, sysctl_tcp_limit_output_bytes is overriding an
automatic TSQ calculation which is actually choosing an effective value
for xennet.

It certainly makes sense for sysctl_tcp_limit_output_bytes to be an
actual maximum limit.  I went back and looked at the original patch
which introduced it (46d3ceabd), and it looks to me like it was designed
to be a rough, quick estimate of "two packets outstanding" (by choosing
the maximum size of the packet, 64k, and multiplying it by two).

Now that you have a better algorithm -- the size of 2 actual packets or
the amount transmitted in 1ms -- it seems like the default
sysctl_tcp_limit_output_bytes should be higher, and let the automatic
TSQ you have on the first line throttle things down when necessary.

 -George
