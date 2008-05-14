From: James Chapman <jchapman@katalix.com>
Subject: L2TP: skb truesize bug in recent kernels
Date: Wed, 14 May 2008 11:07:16 +0100
Message-ID: <482AB9D4.7050800@katalix.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
To: netdev <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from s36.avahost.net ([74.53.95.194]:37217 "EHLO s36.avahost.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1760992AbYENKHT (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 14 May 2008 06:07:19 -0400
Received: from jchapman.plus.com ([84.92.108.75] helo=[192.168.1.10])
	by s36.avahost.net with esmtpa (Exim 4.68)
	(envelope-from <jchapman@katalix.com>)
	id 1JwE3G-00026N-9v
	for netdev@vger.kernel.org; Wed, 14 May 2008 05:17:39 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

A user of L2TP reports skb truesize bugs being logged. His config is GRE 
over PPP over L2TP. All we know so far is that 2.6.24.4 works and 
2.6.25.2 doesn't. There are no other reports of this problem, though 
this might be the only user using GRE over L2TP tunnels at this time.

The truesize bugs don't occur for every packet:

SKB BUG: Invalid truesize (272) len=72, sizeof(sk_buff)=208
SKB BUG: Invalid truesize (272) len=81, sizeof(sk_buff)=208

The pppol2tp driver uses skb_cow_head() to make headroom for IP, UDP, 
L2TP and PPP headers. As GRE is being used, it is more likely that there 
will be insufficient headroom. Does the pppol2tp driver need to adjust 
truesize if pskb_expand_head() is called?

I tried the following hack which stopped the skb truesize bug but caused 
a kernel assert when the socket was closed:

KERN: assertion (!atomic_read(&sk->sk_wmem_alloc)) failed at 
net/ipv4/af_inet.c (155)

Index: linux-2.6.25-new/drivers/net/pppol2tp.c
===================================================================
--- linux-2.6.25.orig/drivers/net/pppol2tp.c
+++ linux-2.6.25/drivers/net/pppol2tp.c
@@ -980,6 +980,8 @@ static int pppol2tp_xmit(struct ppp_chan
  	__wsum csum = 0;
  	struct udphdr *uh;
  	unsigned int len;
+	int old_headroom;
+	int new_headroom;

  	if (sock_flag(sk, SOCK_DEAD) || !(sk->sk_state & PPPOX_CONNECTED))
  		goto abort;
@@ -1008,9 +1010,13 @@ static int pppol2tp_xmit(struct ppp_chan
  	 */
  	headroom = NET_SKB_PAD + sizeof(struct iphdr) +
  		sizeof(struct udphdr) + hdr_len + sizeof(ppph);
+	old_headroom = skb_headroom(skb);
  	if (skb_cow_head(skb, headroom))
  		goto abort;

+	new_headroom = skb_headroom(skb);
+	skb->truesize += new_headroom - old_headroom;
+
  	/* Setup PPP header */
  	__skb_push(skb, sizeof(ppph));
  	skb->data[0] = ppph[0];

Does the driver need to mess with truesize?


-- 
James Chapman
Katalix Systems Ltd
http://www.katalix.com
Catalysts for your Embedded Linux software development

