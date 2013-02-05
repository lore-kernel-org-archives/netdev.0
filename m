From: Eric Dumazet <eric.dumazet-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Subject: Re: [PATCH] wpan: use GFP_ATOMIC instead of
	GFP_KERNEL
Date: Tue, 05 Feb 2013 10:20:03 -0800
Message-ID: <1360088403.28557.6.camel@edumazet-glaptop>
References: <1360078474-24362-1-git-send-email-alex.aring@gmail.com>
	<1360080597.28557.5.camel@edumazet-glaptop>
	<20130205180057.GA1124@x61s.8.8.8.8>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org,
	linux-zigbee-devel-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org
To: Alexander Aring <alex.aring-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Return-path: <linux-zigbee-devel-bounces-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org>
In-Reply-To: <20130205180057.GA1124-P4zwP3w+81Pu/k754drY8A@public.gmane.org>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/linux-zigbee-devel>,
	<mailto:linux-zigbee-devel-request-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum_name=linux-zigbee-devel>
List-Post: <mailto:linux-zigbee-devel-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org>
List-Help: <mailto:linux-zigbee-devel-request-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/linux-zigbee-devel>,
	<mailto:linux-zigbee-devel-request-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org?subject=subscribe>
Errors-To: linux-zigbee-devel-bounces-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org
List-Id: netdev.vger.kernel.org

On Tue, 2013-02-05 at 19:00 +0100, Alexander Aring wrote:

> I don't know how I can do that. head is a temp buffer.
> At the end of this function stands:
> 
> memcpy(skb_push(skb, pos), head, pos)
> 
> and 'pos' is determined at runtime. skb_push will add data to the
> start of buffer, so head buffer will be at the start of skb. I don't
> know where I should manipulate the skb buffer at beginning of this function.

Please try :

diff --git a/net/mac802154/wpan.c b/net/mac802154/wpan.c
index 199b922..d18f2ac 100644
--- a/net/mac802154/wpan.c
+++ b/net/mac802154/wpan.c
@@ -137,16 +137,12 @@ static int mac802154_header_create(struct sk_buff *skb,
 	struct ieee802154_addr dev_addr;
 	struct mac802154_sub_if_data *priv = netdev_priv(dev);
 	int pos = 2;
-	u8 *head;
+	u8 head[MAC802154_FRAME_HARD_HEADER_LEN];
 	u16 fc;
 
 	if (!daddr)
 		return -EINVAL;
 
-	head = kzalloc(MAC802154_FRAME_HARD_HEADER_LEN, GFP_KERNEL);
-	if (head == NULL)
-		return -ENOMEM;
-
 	head[pos++] = mac_cb(skb)->seq; /* DSN/BSN */
 	fc = mac_cb_type(skb);
 
@@ -210,7 +206,6 @@ static int mac802154_header_create(struct sk_buff *skb,
 	head[1] = fc >> 8;
 
 	memcpy(skb_push(skb, pos), head, pos);
-	kfree(head);
 
 	return pos;
 }



------------------------------------------------------------------------------
Free Next-Gen Firewall Hardware Offer
Buy your Sophos next-gen firewall before the end March 2013 
and get the hardware for free! Learn more.
http://p.sf.net/sfu/sophos-d2d-feb
