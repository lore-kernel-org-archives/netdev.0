From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: regression: tethering fails in 3.5 with iwlwifi
Date: Thu, 20 Sep 2012 16:25:49 +0200
Message-ID: <1348151149.31352.109.camel@edumazet-glaptop>
References: <1347361823.26457.3.camel@sauron.fi.intel.com>
	 <1DC40B07CD6EC041A66726C271A73AE6195AE9C8@IRSMSX102.ger.corp.intel.com>
	 <1347631355.5263.19.camel@sauron.fi.intel.com>
	 <1347640763.5263.24.camel@sauron.fi.intel.com>
	 <1347892887.7112.9.camel@sauron.fi.intel.com>
	 <1348142775.2388.10.camel@sauron.fi.intel.com>
	 <1348144524.4161.26.camel@jlt4.sipsolutions.net>
	 <CANn89iJkXrZPB14KU8xA-Dn8_n=H3J4-R60BTZFV+STF9_ASdA@mail.gmail.com>
	 <CANn89iKStHAwVZtpgQMzEpByGYG2FKpjSQsJFT-9qQmjw+KJ8g@mail.gmail.com>
	 <1348145936.2388.18.camel@sauron.fi.intel.com>
	 <CANn89i+9Th=xVgDgoy7tHwKtLNpOC8rgJkA09nQ1Yf0zvqBw6w@mail.gmail.com>
	 <1348147353.2388.19.camel@sauron.fi.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Eric Dumazet <edumazet@google.com>,
	Johannes Berg <johannes@sipsolutions.net>,
	linux-wireless@vger.kernel.org, netdev <netdev@vger.kernel.org>
To: artem.bityutskiy@linux.intel.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bk0-f46.google.com ([209.85.214.46]:34315 "EHLO
	mail-bk0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755741Ab2ITOZy (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 20 Sep 2012 10:25:54 -0400
In-Reply-To: <1348147353.2388.19.camel@sauron.fi.intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2012-09-20 at 16:22 +0300, Artem Bityutskiy wrote:
> On Thu, 2012-09-20 at 15:04 +0200, Eric Dumazet wrote:
> > Try to pull 40 bytes : Thats OK for tcp performance, because 40 bytes
> > is the minimum size of IP+TCP headers
> > 
> > pskb_may_pull(skb, 40);
> 
> OK, I've tried almost this (see below) and it solves my issue:
> 
> diff --git a/net/mac80211/rx.c b/net/mac80211/rx.c
> index 965e6ec..7f079d0 100644
> --- a/net/mac80211/rx.c
> +++ b/net/mac80211/rx.c
> @@ -1798,9 +1798,13 @@ ieee80211_deliver_skb(struct ieee80211_rx_data *rx)
>  
>                 if (skb) {
>                         /* deliver to local stack */
> -                       skb->protocol = eth_type_trans(skb, dev);
> -                       memset(skb->cb, 0, sizeof(skb->cb));
> -                       netif_receive_skb(skb);
> +                       if (pskb_may_pull(skb, 40)) {
> +                               skb->protocol = eth_type_trans(skb, dev);
> +                               memset(skb->cb, 0, sizeof(skb->cb));
> +                               netif_receive_skb(skb);
> +                       } else {
> +                               kfree_skb(skb);
> +                       }
>                 }
>         }
> 

Please remove this hack and try the following bugfix in raw handler

icmp_filter() should not modify skb, or else its caller should not
assume ip_hdr() is unchanged.

 net/ipv4/raw.c |   29 +++++++++++++++++------------
 1 file changed, 17 insertions(+), 12 deletions(-)

diff --git a/net/ipv4/raw.c b/net/ipv4/raw.c
index f242578..3fa8c96 100644
--- a/net/ipv4/raw.c
+++ b/net/ipv4/raw.c
@@ -128,25 +128,30 @@ found:
 }
 
 /*
- *	0 - deliver
- *	1 - block
+ *	false - deliver
+ *	true - block
  */
-static __inline__ int icmp_filter(struct sock *sk, struct sk_buff *skb)
+static bool icmp_filter(struct sock *sk, const struct sk_buff *skb)
 {
-	int type;
-
-	if (!pskb_may_pull(skb, sizeof(struct icmphdr)))
-		return 1;
-
-	type = icmp_hdr(skb)->type;
-	if (type < 32) {
+	__u8 _type;
+	const __u8 *type;
+
+	type = skb_header_pointer(skb,
+				  skb_transport_offset(skb) +
+				  offsetof(struct icmphdr, type),
+				  sizeof(_type),
+				  &_type);
+	if (!type)
+		return true;
+
+	if (*type < 32) {
 		__u32 data = raw_sk(sk)->filter.data;
 
-		return ((1 << type) & data) != 0;
+		return ((1U << *type) & data) != 0;
 	}
 
 	/* Do not block unknown ICMP types */
-	return 0;
+	return false;
 }
 
 /* IP input processing comes here for RAW socket delivery.
