From: YOSHIFUJI Hideaki / =?iso-2022-jp?B?GyRCNUhGIzFRTEAbKEI=?=
	<yoshfuji@linux-ipv6.org>
Subject: Re: 2.6.25-rc8: FTP transfer errors
Date: Fri, 11 Apr 2008 11:59:07 +0900 (JST)
Message-ID: <20080411.115907.116626245.yoshfuji@linux-ipv6.org>
References: <47FEADCB.7070104@rtr.ca>
	<20080410.172648.187059862.davem@davemloft.net>
	<47FEB0E3.8080507@rtr.ca>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: jesper.juhl@gmail.com, tilman@imap.cc, jeff@garzik.org,
	rjw@sisk.pl, linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	xemul@openvz.org, yoshfuji@linux-ipv6.org
To: lkml@rtr.ca, davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from yue.linux-ipv6.org ([203.178.140.15]:32937 "EHLO
	yue.st-paulia.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754812AbYDKC5Y (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 10 Apr 2008 22:57:24 -0400
In-Reply-To: <47FEB0E3.8080507@rtr.ca>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

In article <47FEB0E3.8080507@rtr.ca> (at Thu, 10 Apr 2008 20:29:23 -0400), Mark Lord <lkml@rtr.ca> says:

> David Miller wrote:
> > From: Mark Lord <lkml@rtr.ca>
> > Date: Thu, 10 Apr 2008 20:16:11 -0400
> > 
> >> [c67499c0e772064b37ad75eb69b28fc218752636 is first bad commit
> >> commit c67499c0e772064b37ad75eb69b28fc218752636
> >> Author: Pavel Emelyanov <xemul@openvz.org>
> >> Date:   Thu Jan 31 05:06:40 2008 -0800
> >>
> >>     [NETNS]: Tcp-v4 sockets per-net lookup.
> >>
> >>     Add a net argument to inet_lookup and propagate it further
> >>     into lookup calls. Plus tune the __inet_check_established.
> >>
> >>     The dccp and inet_diag, which use that lookup functions
> >>     pass the init_net into them.
> >>
> >>     Signed-off-by: Pavel Emelyanov <xemul@openvz.org>
> >>     Signed-off-by: David S. Miller <davem@davemloft.net>
> > 
> > Thanks Mark.
> > 
> > Pavel can you take a look?  I suspect that the namespace
> > changes or gets NULL'd out somehow and this leads to the
> > resets because the socket can no longer be found.  Perhaps
> > it's even a problem with time-wait socket namespace
> > propagation.
> ..
> 
> My system here is now set up for quick/easy retest, if you have any
> suggestions or patches to try out.

Please try this, from net-2.6.26 tree.

Signed-off-by: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>

----
>From 8d9f1744cab50acb0c6c9553be533621e01f178b Mon Sep 17 00:00:00 2001
From: Daniel Lezcano <dlezcano@fr.ibm.com>
Date: Fri, 21 Mar 2008 04:12:54 -0700
Subject: [PATCH] [NETNS][IPV6] tcp - assign the netns for timewait sockets

Copy the network namespace from the socket to the timewait socket.

Signed-off-by: Daniel Lezcano <dlezcano@fr.ibm.com>
Signed-off-by: David S. Miller <davem@davemloft.net>
---
 net/ipv4/inet_timewait_sock.c |    1 +
 1 files changed, 1 insertions(+), 0 deletions(-)

diff --git a/net/ipv4/inet_timewait_sock.c b/net/ipv4/inet_timewait_sock.c
index 876169f..717c411 100644
--- a/net/ipv4/inet_timewait_sock.c
+++ b/net/ipv4/inet_timewait_sock.c
@@ -124,6 +124,7 @@ struct inet_timewait_sock *inet_twsk_alloc(const struct sock *sk, const int stat
 		tw->tw_hash	    = sk->sk_hash;
 		tw->tw_ipv6only	    = 0;
 		tw->tw_prot	    = sk->sk_prot_creator;
+		tw->tw_net          = sk->sk_net;
 		atomic_set(&tw->tw_refcnt, 1);
 		inet_twsk_dead_node_init(tw);
 		__module_get(tw->tw_prot->owner);
-- 
1.4.4.4

-- 
YOSHIFUJI Hideaki @ USAGI Project  <yoshfuji@linux-ipv6.org>
GPG-FP  : 9022 65EB 1ECF 3AD1 0BDF  80D8 4807 F894 E062 0EEA
