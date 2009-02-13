From: Jarek Poplawski <jarkao2@gmail.com>
Subject: Re: WARNING: at net/core/skbuff.c:154 with tcpdump and ipsec
Date: Fri, 13 Feb 2009 12:14:24 +0000
Message-ID: <20090213121424.GA8717@ff.dom.local>
References: <alpine.LNX.1.10.0902111641280.13501@bizon.gios.gov.pl>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Marco Berizzi <pupilla@hotmail.com>, netdev@vger.kernel.org
To: Krzysztof Oledzki <ole@ans.pl>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bw0-f161.google.com ([209.85.218.161]:51918 "EHLO
	mail-bw0-f161.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750797AbZBMMOc (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 13 Feb 2009 07:14:32 -0500
Received: by bwz5 with SMTP id 5so1679532bwz.13
        for <netdev@vger.kernel.org>; Fri, 13 Feb 2009 04:14:29 -0800 (PST)
Content-Disposition: inline
In-Reply-To: <alpine.LNX.1.10.0902111641280.13501@bizon.gios.gov.pl>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 11-02-2009 16:55, Krzysztof Oledzki wrote:
> 
> On Wed, 11 Feb 2009, Marco Berizzi wrote:
> 
>> Hi Folks,
>>
>> I'm getting this error on 2.6.28.4 when I run tcpdump on
>> the interface where ipsec packets are enc/decrypted.
>>
>> TIA
>>
>>> Feb 11 10:53:55 Pleiadi kernel: ------------[ cut here ]------------
>>> Feb 11 10:53:55 Pleiadi kernel: WARNING: at net/core/skbuff.c:154 skb_truesize_bug+0x2e/0x33()
>>> Feb 11 10:53:55 Pleiadi kernel: SKB BUG: Invalid truesize (268) len=134, sizeof(sk_buff)=172
> <CUT>
> 
> This annoying problem is quite old (appeared in 2.6.25) and already known:
>   http://bugzilla.kernel.org/show_bug.cgi?id=10996
> 
> Sadly, no one is interested in fixing it. :(

Here is a debugging patch doing these checks a bit earlier, so maybe
we get something new and interesting. ;)

Thanks,
Jarek P.
---

 include/linux/skbuff.h |    8 ++++++--
 net/packet/af_packet.c |    9 +++++++++
 2 files changed, 15 insertions(+), 2 deletions(-)

diff --git a/include/linux/skbuff.h b/include/linux/skbuff.h
index cf2cb50..20c3182 100644
--- a/include/linux/skbuff.h
+++ b/include/linux/skbuff.h
@@ -418,12 +418,16 @@ extern void	      skb_under_panic(struct sk_buff *skb, int len,
 				      void *here);
 extern void	      skb_truesize_bug(struct sk_buff *skb);
 
-static inline void skb_truesize_check(struct sk_buff *skb)
+static inline int skb_truesize_check(struct sk_buff *skb)
 {
 	int len = sizeof(struct sk_buff) + skb->len;
 
-	if (unlikely((int)skb->truesize < len))
+	if (unlikely((int)skb->truesize < len)) {
 		skb_truesize_bug(skb);
+		return 1;
+	}
+
+	return 0;
 }
 
 extern int skb_append_datato_frags(struct sock *sk, struct sk_buff *skb,
diff --git a/net/packet/af_packet.c b/net/packet/af_packet.c
index 1fc4a78..08200be 100644
--- a/net/packet/af_packet.c
+++ b/net/packet/af_packet.c
@@ -307,6 +307,9 @@ static int packet_rcv_spkt(struct sk_buff *skb, struct net_device *dev,  struct
 	if (dev_net(dev) != sock_net(sk))
 		goto out;
 
+	if (skb_truesize_check(skb))
+		goto out;
+
 	if ((skb = skb_share_check(skb, GFP_ATOMIC)) == NULL)
 		goto oom;
 
@@ -495,6 +498,9 @@ static int packet_rcv(struct sk_buff *skb, struct net_device *dev, struct packet
 	if (dev_net(dev) != sock_net(sk))
 		goto drop;
 
+	if (skb_truesize_check(skb))
+		goto drop;
+
 	skb->dev = dev;
 
 	if (dev->header_ops) {
@@ -617,6 +623,9 @@ static int tpacket_rcv(struct sk_buff *skb, struct net_device *dev, struct packe
 	if (dev_net(dev) != sock_net(sk))
 		goto drop;
 
+	if (skb_truesize_check(skb))
+		goto drop;
+
 	if (dev->header_ops) {
 		if (sk->sk_type != SOCK_DGRAM)
 			skb_push(skb, skb->data - skb_mac_header(skb));
