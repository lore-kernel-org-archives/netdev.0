From: Neil Horman <nhorman@tuxdriver.com>
Subject: Re: [RFC][PATCH] add tracepoint to __sk_mem_schedule
Date: Wed, 15 Jun 2011 16:04:05 -0400
Message-ID: <20110615200405.GB23380@hmsreliant.think-freely.org>
References: <65795E11DBF1E645A09CEC7EAEE94B9C3FBC0707@USINDEVS02.corp.hds.com>
 <20110615110723.GA23380@hmsreliant.think-freely.org>
 <65795E11DBF1E645A09CEC7EAEE94B9C3FBC0709@USINDEVS02.corp.hds.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"davem@davemloft.net" <davem@davemloft.net>,
	"dle-develop@lists.sourceforge.net"
	<dle-develop@lists.sourceforge.net>,
	Seiji Aguchi <seiji.aguchi@hds.com>
To: Satoru Moriya <satoru.moriya@hds.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from charlotte.tuxdriver.com ([70.61.120.58]:43528 "EHLO
	smtp.tuxdriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751461Ab1FOUER (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 15 Jun 2011 16:04:17 -0400
Content-Disposition: inline
In-Reply-To: <65795E11DBF1E645A09CEC7EAEE94B9C3FBC0709@USINDEVS02.corp.hds.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Jun 15, 2011 at 03:18:09PM -0400, Satoru Moriya wrote:
> Hi Neil,
> 
> Thank you for looking at it.
> I'm afraid that my explanation was not enough.
> 
> On 06/15/2011 07:07 AM, Neil Horman wrote:
> > On Tue, Jun 14, 2011 at 03:24:14PM -0400, Satoru Moriya wrote:
> >
> > There are several ways to do this already.  Every drop that occurs in the stack
> > should have a corresponding statistical counter exposed for it, and we also have
> > a tracepoint in kfree_skb that the dropwatch system monitors to inform us of
> > dropped packets in a certralized fashion.  Not saying this tracepoint isn't
> > worthwhile, only that it covers already covered ground.
> 
> Right. We can catch packet drop events via dropwatch/kfree_skb tracepoint.
> OTOH, what I'd like to know is why kernel dropped packets. Basically,
> we're able to know the reason because kfree_skb tracepoint records its
> return address. But in this case it is difficult to know a detailed reason
> because there are some possibilities. I'll try to explain UDP case.
Ok, but you're patch only gets us incrmentally closer to that goal.  You can
tell if theres too much memory pressue to accept another packet on a socket, but
it doesn't tell you if for instance if sk_filter indicated an error, or
something else failed.  In short it sounds to me like you're trying to debug a
specific problem, rather than add something generally useful.

> 
> > Again, this is why dropwatch exists.  UDP gets into this path from:
> > __udp_queue_rcv_skb
> >  ip_queue_rcv_skb
> >   sock_queue_rcv_skb
> >    sk_rmem_schedule
> >     __sk_mem_schedule
> > 
> > If ip_queue_rcv_skb fails we increment the UDP_MIB_RCVBUFERRORS counter as well
> > as the UDP_MIB_INERRORS counter, and on the kfree_skb call after those
> > increments, dropwatch will report the frame loss and the fact that it occured in
> > __udp_queue_rcv_skb
> 
> As you said, we're able to catch the packet drop in __udp_queue_rcv_skb
> and it means ip_queue_rcv_skb/sock_queue_rcv_skb returned negative value.
> In sock_queue_rcv_skb there are 3 possibilities where it returns nagative
> val but we can't separate them from the kfree_skb tracepoint. Moreover
This is true, but you're patch doesn't do that either (not that either feature
holds that as a specific goal).

> sock_queue_rcv_skb calls __sk_mem_schedule and there are several
> if-statement to decide whether kernel should drop a packet in it. I'd like
> to know the condition when it returned error because some of them are
> related to sysctl knob e.g. /proc/sys/net/ipv4/udp_mem, udp_rmem_min,
> udp_wmem_min for UDP case and we can tune kernel behavior easily.
> Also they are needed to show root cause of packet drop to our customers.
> 
> Does it make sense?
> 
Yes, it makes sense, but I think the patch could be made generally more useful.

> > I still think its an interesting tracepoint, just because it might be nice to
> > know which sockets are expanding their snd/rcv buffer space, but why not modify
> > the tracepoint so that it accepts the return code of __sk_mem_schedule and call
> > it from both sk_rmem_schedule and sk_wmem_schedule.   That way you can use the
> > tracepoint to record both successfull expansion and failed expansions.
> 
> It may be good but not enough for me as I mentioned above.
> 
> 
> Regards,
> Satoru--
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
> 
