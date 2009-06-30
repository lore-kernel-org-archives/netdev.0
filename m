From: Denys Fedoryschenko <denys@visp.net.lb>
Subject: Re: [RFC] arp announce, arp_proxy and windows ip conflict verification
Date: Wed, 1 Jul 2009 01:54:27 +0300
Message-ID: <200907010154.27457.denys@visp.net.lb>
References: <200903011344.45814.denys@visp.net.lb> <m1r5x1z5z4.fsf@fess.ebiederm.org>
Mime-Version: 1.0
Content-Type: Multipart/Mixed;
  boundary="Boundary-00=_jepSK1bIbWTB1Hi"
Cc: netdev@vger.kernel.org, David Miller <davem@davemloft.net>
To: "Eric W. Biederman" <ebiederm@xmission.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from hosting.visp.net.lb ([194.146.153.11]:35955 "EHLO
	hosting.visp.net.lb" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753980AbZGAD3i (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 30 Jun 2009 23:29:38 -0400
In-Reply-To: <m1r5x1z5z4.fsf@fess.ebiederm.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

--Boundary-00=_jepSK1bIbWTB1Hi
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

On Wednesday 01 July 2009 01:55:59 Eric W. Biederman wrote:
>
> I have a problem with this patch.  It stops gratuitous arps updating
> my arp cache.  I'm still trying to figure out what the correct behaviour
> should be.
>
> Perhaps making the goto out; become if (sip == 0) goto out;
Yes, you are right. 

Proposing 3 simple patches against git next-next-2.6 . As attaches (sorry, 
kmail). All of them equal, but since i am amateur in programming, i dont know 
how it is should be done "nice way".

If you want to test it - do it carefully. I didn't did runtime tests yet, but 
they are compile tested. (But they are trivial).

If someone can review and tell if any of them ok, i will submit it with proper 
tags and etc.


--Boundary-00=_jepSK1bIbWTB1Hi
Content-Type: text/x-diff;
  charset="iso-8859-1";
  name="patch1.diff"
Content-Transfer-Encoding: 7bit
Content-Disposition: attachment;
	filename="patch1.diff"

diff -uprN net-next-2.6/net/ipv4/arp.c net-next-2.6.my/net/ipv4/arp.c
--- net-next-2.6/net/ipv4/arp.c	2009-07-01 01:00:58.000000000 +0300
+++ net-next-2.6.my/net/ipv4/arp.c	2009-07-01 01:24:19.000000000 +0300
@@ -811,11 +811,9 @@ static int arp_process(struct sk_buff *s
 		    !arp_ignore(in_dev, sip, tip))
 			arp_send(ARPOP_REPLY, ETH_P_ARP, sip, dev, tip, sha,
 				 dev->dev_addr, sha);
-		goto out;
-	}
-
-	if (arp->ar_op == htons(ARPOP_REQUEST) &&
-	    ip_route_input(skb, tip, sip, 0, dev) == 0) {
+		if (sip == 0) goto out;
+	} else if (arp->ar_op == htons(ARPOP_REQUEST) &&
+		    ip_route_input(skb, tip, sip, 0, dev) == 0) {
 
 		rt = skb_rtable(skb);
 		addr_type = rt->rt_type;

--Boundary-00=_jepSK1bIbWTB1Hi
Content-Type: text/x-diff;
  charset="iso-8859-1";
  name="patch2.diff"
Content-Transfer-Encoding: 7bit
Content-Disposition: attachment;
	filename="patch2.diff"

diff -uprN net-next-2.6/net/ipv4/arp.c net-next-2.6.my2/net/ipv4/arp.c
--- net-next-2.6/net/ipv4/arp.c	2009-07-01 01:00:58.000000000 +0300
+++ net-next-2.6.my2/net/ipv4/arp.c	2009-07-01 01:25:38.000000000 +0300
@@ -811,7 +811,10 @@ static int arp_process(struct sk_buff *s
 		    !arp_ignore(in_dev, sip, tip))
 			arp_send(ARPOP_REPLY, ETH_P_ARP, sip, dev, tip, sha,
 				 dev->dev_addr, sha);
-		goto out;
+		if (tip == sip)
+		    goto update;
+		else
+		    goto out;
 	}
 
 	if (arp->ar_op == htons(ARPOP_REQUEST) &&
@@ -858,6 +861,7 @@ static int arp_process(struct sk_buff *s
 
 	/* Update our ARP tables */
 
+update:
 	n = __neigh_lookup(&arp_tbl, &sip, dev, 0);
 
 	if (IPV4_DEVCONF_ALL(dev_net(dev), ARP_ACCEPT)) {

--Boundary-00=_jepSK1bIbWTB1Hi
Content-Type: text/x-diff;
  charset="iso-8859-1";
  name="patch3.diff"
Content-Transfer-Encoding: 7bit
Content-Disposition: attachment;
	filename="patch3.diff"

diff -uprN net-next-2.6/net/ipv4/arp.c net-next-2.6.my3/net/ipv4/arp.c
--- net-next-2.6/net/ipv4/arp.c	2009-07-01 01:00:58.000000000 +0300
+++ net-next-2.6.my3/net/ipv4/arp.c	2009-07-01 01:26:09.000000000 +0300
@@ -815,6 +815,7 @@ static int arp_process(struct sk_buff *s
 	}
 
 	if (arp->ar_op == htons(ARPOP_REQUEST) &&
+	    tip != sip &&
 	    ip_route_input(skb, tip, sip, 0, dev) == 0) {
 
 		rt = skb_rtable(skb);

--Boundary-00=_jepSK1bIbWTB1Hi--
