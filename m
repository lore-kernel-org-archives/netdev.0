From: Benoit PAPILLAULT <benoit.papillault@free.fr>
Subject: UDP broadcast packets not looped back
Date: Sat, 01 Sep 2007 16:30:39 +0200
Message-ID: <46D9778F.9070403@free.fr>
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="------------020604090103010605000801"
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp1-g19.free.fr ([212.27.42.27]:60219 "EHLO smtp1-g19.free.fr"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753084AbXIAOar (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 1 Sep 2007 10:30:47 -0400
Received: from smtp1-g19.free.fr (localhost.localdomain [127.0.0.1])
	by smtp1-g19.free.fr (Postfix) with ESMTP id 9EA841AB2D4
	for <netdev@vger.kernel.org>; Sat,  1 Sep 2007 16:30:46 +0200 (CEST)
Received: from [192.168.1.62] (ns.popipo.fr [88.163.232.53])
	by smtp1-g19.free.fr (Postfix) with ESMTP id 6B55E1AB2B9
	for <netdev@vger.kernel.org>; Sat,  1 Sep 2007 16:30:46 +0200 (CEST)
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This is a multi-part message in MIME format.
--------------020604090103010605000801
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit

Hi there,

I've already sent this email to lkml (see 
http://lkml.org/lkml/2007/8/13/1144) and got no feedback so far. I was 
told that netdev might be a more appropriate list, so here I am!

I wrote a small C program using the BSD socket API to send a UDP
broadcast packet to all interfaces on my machine. To do so, i sendto()
it to 255.255.255.255 after using setsockopt(SO_BINDTODEVICE) on the
correct interface. It works perfectly.

However, in the same program, either using the same socket or another on
the same UDP port, I found out that I just received packets i'm sending 
as well. And do not want it. I perfectly understand that some program 
might be interested in broadcast packets they sent, but i don't.

I have seen that in the multicast world, every program can choose this
behaviour throught the setsockopt IP_MULTICAST_LOOP. I do not want to
use multicast since I don't want my packets to be routed (if there was
ever a multicast router on the link). But I admit I could use a TTL=1
packet in this case.

Anyway, I dig five minutes into the kernel source code I have at hand
and wrote a small patch to add IP_MULTICAST_LOOP to broadcast packets.
Since it might be interesting to other people, I just submit it here. It
has been testing on Ubuntu and kernel 2.6.23-rc1 from the wireless.git
repository. It should be very easy to adapt to other kernel version.

I have not seen this feature as being standard throught the OpenGroup
specification
(http://www.opengroup.org/onlinepubs/009695399/functions/setsockopt.html),
but it might be usefull anyway.

Comments welcome,
Benoit

--------------020604090103010605000801
Content-Type: text/x-patch;
 name="wireless-dev-udp-broadcast.diff"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="wireless-dev-udp-broadcast.diff"

diff --git a/net/ipv4/ip_output.c b/net/ipv4/ip_output.c
index c9e2b5e..1052a6e 100644
--- a/net/ipv4/ip_output.c
+++ b/net/ipv4/ip_output.c
@@ -232,6 +232,9 @@ int ip_mc_output(struct sk_buff *skb)
 	skb->dev = dev;
 	skb->protocol = htons(ETH_P_IP);
 
+	printk("rt->rt_flags = %x mc_loop=%d\n",
+		rt->rt_flags, sk ? inet_sk(sk)->mc_loop : 0);
+
 	/*
 	 *	Multicasts are looped back for other local users
 	 */
@@ -266,10 +269,12 @@ int ip_mc_output(struct sk_buff *skb)
 	}
 
 	if (rt->rt_flags&RTCF_BROADCAST) {
+		if (!sk || inet_sk(sk)->mc_loop) {
 		struct sk_buff *newskb = skb_clone(skb, GFP_ATOMIC);
 		if (newskb)
 			NF_HOOK(PF_INET, NF_IP_POST_ROUTING, newskb, NULL,
 				newskb->dev, ip_dev_loopback_xmit);
+		}
 	}
 
 	return NF_HOOK_COND(PF_INET, NF_IP_POST_ROUTING, skb, NULL, skb->dev,


--------------020604090103010605000801--
