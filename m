From: Ben Greear <greearb@candelatech.com>
Subject: Re: PF_RING: Include in main line kernel?
Date: Wed, 14 Oct 2009 14:27:45 -0700
Message-ID: <4AD64251.50903@candelatech.com>
References: <a07586b0910140733s1976cd05u39286de42d9fac23@mail.gmail.com> <20091014090125.535ee0dc@nehalam> <a07586b0910141002m2a9f4466j412245fdae4e5372@mail.gmail.com> <20091014123328.1ebe35ea@s6510> <8B385E10-4BE2-48A6-BDE0-0AA1A603275E@ntop.org> <20091014203640.GB32317@ioremap.net>
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="------------070400070207010204090907"
Cc: Luca Deri <deri@ntop.org>,
	Stephen Hemminger <shemminger@vyatta.com>,
	Brad Doctor <brad.doctor@gmail.com>, netdev@vger.kernel.org
To: Evgeniy Polyakov <zbr@ioremap.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.candelatech.com ([208.74.158.172]:33183 "EHLO
	ns3.lanforge.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754917AbZJNV25 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 14 Oct 2009 17:28:57 -0400
In-Reply-To: <20091014203640.GB32317@ioremap.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This is a multi-part message in MIME format.
--------------070400070207010204090907
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit

On 10/14/2009 01:36 PM, Evgeniy Polyakov wrote:
> On Wed, Oct 14, 2009 at 10:17:30PM +0200, Luca Deri (deri@ntop.org) wrote:
>> The reason why I decided to patch dev.c is because I wanted PF_RING to
>> decide whether the packet journey shall continue or not. In other
>> words with my solution PF_RING applications can decide whether the
>> received packets will also be delivered to upper layers (and to other
>> kernel network components). This configurable 'early packet drop'
>> allows the overall performance to be significantly increased as
>> received packets are not supposed to be delivered to upper layers;
>> this is a typical situations for many monitoring devices.
>
> This is a feature many projects implement themself indeed. What about
> creating special return value from the packet handler which will
> indicate that packet was already consumed and no further work should be
> done on it?

Maybe something similar to the attached patch?

Thanks,
Ben

-- 
Ben Greear <greearb@candelatech.com>
Candela Technologies Inc  http://www.candelatech.com


--------------070400070207010204090907
Content-Type: text/plain;
 name="patch0.patch"
Content-Transfer-Encoding: 7bit
Content-Disposition: attachment;
 filename="patch0.patch"

diff --git a/include/linux/netdevice.h b/include/linux/netdevice.h
index 907d118..da78f0a 100644
--- a/include/linux/netdevice.h
+++ b/include/linux/netdevice.h
@@ -78,6 +78,7 @@ struct wireless_dev;
 #define NET_RX_CN_MOD		3   /* Storm on its way! */
 #define NET_RX_CN_HIGH		4   /* The storm is here */
 #define NET_RX_BAD		5  /* packet dropped due to kernel error */
+#define NET_RX_CONSUMED       6 /* pkt is consumed, stop rx logic here. */
 
 /* NET_XMIT_CN is special. It does not guarantee that this packet is lost. It
  * indicates that the device will soon be dropping packets, or already drops
diff --git a/net/core/dev.c b/net/core/dev.c
index 0101178..d5024b9 100644
--- a/net/core/dev.c
+++ b/net/core/dev.c
@@ -2105,6 +2105,10 @@ static inline struct sk_buff *handle_bridge(struct sk_buff *skb,
 	if (*pt_prev) {
 		*ret = deliver_skb(skb, *pt_prev, orig_dev);
 		*pt_prev = NULL;
+		if (*ret == NET_RX_CONSUMED) {
+			kfree_skb(skb); /* we made a copy in deliver_skb */
+			return NULL;
+		}
 	}
 
 	return br_handle_frame_hook(port, skb);
@@ -2128,6 +2132,10 @@ static inline struct sk_buff *handle_macvlan(struct sk_buff *skb,
 	if (*pt_prev) {
 		*ret = deliver_skb(skb, *pt_prev, orig_dev);
 		*pt_prev = NULL;
+		if (*ret == NET_RX_CONSUMED) {
+			kfree_skb(skb); /* we made a copy in deliver_skb */
+			return NULL;
+		}
 	}
 	return macvlan_handle_frame_hook(skb);
 }
@@ -2185,6 +2193,10 @@ static inline struct sk_buff *handle_ing(struct sk_buff *skb,
 	if (*pt_prev) {
 		*ret = deliver_skb(skb, *pt_prev, orig_dev);
 		*pt_prev = NULL;
+		if (*ret == NET_RX_CONSUMED) {
+			kfree_skb(skb); /* we made a copy in deliver_skb */
+			return NULL;
+		}
 	} else {
 		/* Huh? Why does turning on AF_PACKET affect this? */
 		skb->tc_verd = SET_TC_OK2MUNGE(skb->tc_verd);
@@ -2300,8 +2312,13 @@ int netif_receive_skb(struct sk_buff *skb)
 	list_for_each_entry_rcu(ptype, &ptype_all, list) {
 		if (ptype->dev == null_or_orig || ptype->dev == skb->dev ||
 		    ptype->dev == orig_dev) {
-			if (pt_prev)
+			if (pt_prev) {
 				ret = deliver_skb(skb, pt_prev, orig_dev);
+				if (ret == NET_RX_CONSUMED) {
+					kfree_skb(skb); /* we made a copy in deliver_skb */
+					goto out;
+				}
+			}
 			pt_prev = ptype;
 		}
 	}
@@ -2336,8 +2353,13 @@ ncls:
 		if (ptype->type == type &&
 		    (ptype->dev == null_or_orig || ptype->dev == skb->dev ||
 		     ptype->dev == orig_dev)) {
-			if (pt_prev)
+			if (pt_prev) {
 				ret = deliver_skb(skb, pt_prev, orig_dev);
+				if (ret == NET_RX_CONSUMED) {
+					kfree_skb(skb); /* we made a copy in deliver_skb */
+					goto out;
+				}
+			}
 			pt_prev = ptype;
 		}
 	}

--------------070400070207010204090907--
