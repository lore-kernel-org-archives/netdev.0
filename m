From: Alexander Aring <alex.aring-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Subject: [PATCH 2/6] 6lowpan: Fix fragmentation with
	link-local compressed addresses
Date: Tue, 13 Aug 2013 23:53:29 +0200
Message-ID: <1376430813-30982-4-git-send-email-alex.aring@gmail.com>
References: <1376430813-30982-1-git-send-email-alex.aring@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-zigbee-devel-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org,
	David Hauweele <david-1EggE+PRa6vk1uMJSBkQmQ@public.gmane.org>, davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org
To: alex.bluesman.smirnov-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org
Return-path: <linux-zigbee-devel-bounces-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org>
In-Reply-To: <1376430813-30982-1-git-send-email-alex.aring-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/linux-zigbee-devel>,
	<mailto:linux-zigbee-devel-request-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum_name=linux-zigbee-devel>
List-Post: <mailto:linux-zigbee-devel-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org>
List-Help: <mailto:linux-zigbee-devel-request-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/linux-zigbee-devel>,
	<mailto:linux-zigbee-devel-request-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org?subject=subscribe>
Errors-To: linux-zigbee-devel-bounces-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org
List-Id: netdev.vger.kernel.org

From: David Hauweele <david-1EggE+PRa6vk1uMJSBkQmQ@public.gmane.org>

When a new 6lowpan fragment is received, a skbuff is allocated for
the reassembled packet. However when a 6lowpan packet compresses
link-local addresses based on link-layer addresses, the processing
function relies on the skb mac control block to find the related
link-layer address.

This patch copies the control block from the first fragment into
the newly allocated skb to keep a trace of the link-layer addresses
in case of a link-local compressed address.

Edit: small changes on comment issue

Signed-off-by: David Hauweele <david-1EggE+PRa6vk1uMJSBkQmQ@public.gmane.org>
Signed-off-by: Alexander Aring <alex.aring-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
---
 net/ieee802154/6lowpan.c | 6 ++++++
 1 file changed, 6 insertions(+)

diff --git a/net/ieee802154/6lowpan.c b/net/ieee802154/6lowpan.c
index 92429db..632b3fd 100644
--- a/net/ieee802154/6lowpan.c
+++ b/net/ieee802154/6lowpan.c
@@ -698,6 +698,12 @@ lowpan_alloc_new_frame(struct sk_buff *skb, u16 len, u16 tag)
 	skb_reserve(frame->skb, sizeof(struct ipv6hdr));
 	skb_put(frame->skb, frame->length);
 
+	/* copy the first control block to keep a
+	 * trace of the link-layer addresses in case
+	 * of a link-local compressed address
+	 */
+	memcpy(frame->skb->cb, skb->cb, sizeof(skb->cb));
+
 	init_timer(&frame->timer);
 	/* time out is the same as for ipv6 - 60 sec */
 	frame->timer.expires = jiffies + LOWPAN_FRAG_TIMEOUT;
-- 
1.8.3.3


------------------------------------------------------------------------------
Get 100% visibility into Java/.NET code with AppDynamics Lite!
It's a free troubleshooting tool designed for production.
Get down to code-level detail for bottlenecks, with <2% overhead. 
Download for free and get started troubleshooting in minutes. 
http://pubads.g.doubleclick.net/gampad/clk?id=48897031&iu=/4140/ostg.clktrk
