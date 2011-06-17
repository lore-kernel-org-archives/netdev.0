From: Julian Anastasov <ja@ssi.bg>
Subject: Re: what's causing "ip_rt_bug"?
Date: Sat, 18 Jun 2011 02:56:42 +0300 (EEST)
Message-ID: <alpine.LFD.2.00.1106180227400.1583@ja.ssi.bg>
References: <4DFBB270.8000003@wpkg.org> <1308342993.3539.30.camel@edumazet-laptop> <4DFBC92A.2030901@wpkg.org>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: Eric Dumazet <eric.dumazet@gmail.com>, netdev@vger.kernel.org
To: Tomasz Chmielewski <mangoo@wpkg.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ja.ssi.bg ([178.16.129.10]:34345 "EHLO ja.ssi.bg"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754455Ab1FQXyM (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 17 Jun 2011 19:54:12 -0400
In-Reply-To: <4DFBC92A.2030901@wpkg.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


	Hello,

On Fri, 17 Jun 2011, Tomasz Chmielewski wrote:

> > What your routing table looks like ? (ip ro)
> 
> It's just a proxy, no special routing set:

	Is transparent proxy used?

> # ip ro
> 58.185.117.18 via 119.46.110.193 dev eth0 
> 119.46.240.13 via 119.46.110.193 dev eth0 
> 58.185.117.29 via 119.46.110.193 dev eth0 
> 119.46.241.13 via 119.46.110.193 dev eth0 

	Same route for 58.185.117.28 2nd time? Is that possible?:

> 58.185.117.28 via 119.46.110.193 dev eth0 
> 119.46.110.192/26 dev eth0  proto kernel  scope link  src 119.46.110.197 
> 169.254.0.0/16 dev eth0  scope link 
> default via 119.46.110.195 dev eth0 
> 
> 
> The box is also crashing every few days; and I really had no clue why (just connected a serial console to catch any new oops/panic).
> 
> 
> The last time it crashed, I have this entry in syslog:
> 
> Jun 17 16:16:17 TRUE-SC02 kernel: [172488.602629] ip_rt_bug: 124.121.155.197 -> 119.46.110.197, ?

	The ip_rt_bug messages show that skb->dev is
NULL (OUTPUT hook), daddr in IP header is local address,
may be some original received packet. If such packet is
provided to ip_route_me_harder(skb, RTN_UNSPEC) an
ip_route_input call can happen. Calling later dst_output
should lead to this warning. The question is what can
cause received packet to appear in OUTPUT hook where
a change in mark or TOS can can trigger such ip_route_input
call. What kind of netfilter modules are used? nf_queue,
-j REJECT, NAT? Is 124.121.155.197 a local address?

> Jun 17 16:17:00 TRUE-SC02 kernel: [172531.239041] BUG: unable to handle kernel NULL pointer dereference at (null)
> Jun 17 16:17:00 TRUE-SC02 kernel: [172531.239409] IP: [<ffffffff81361cae>] dev_queue_xmit+0x1e3/0x441
> Jun 17 16:17:00 TRUE-SC02 kernel: [172531.239760] PGD 43c30b067 PUD 439e63067 PMD 0
> Jun 17 16:17:00 TRUE-SC02 kernel: [172531.240103] Oops: 0000 [#1] SMP
> Jun 17 16:19:58 TRUE-SC02 syslogd 1.4.1: restart.

Regards

--
Julian Anastasov <ja@ssi.bg>
