From: Herbert Xu <herbert-lOAM2aK0SrRLBo1qDEOMRrpzq4S04n8Q@public.gmane.org>
Subject: Re: ZD1211RW unaligned accesses...
Date: Sat, 24 Nov 2007 23:02:16 +0800
Message-ID: <20071124150216.GA28153@gondor.apana.org.au>
References: <20071120.040546.222294375.davem@davemloft.net> <47442BFC.8090008@hotmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
To: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	Shaddy Baddah <shaddy_baddah-PkbjNfxxIARBDgjK7y7TUQ@public.gmane.org>,
	David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <47442BFC.8090008-PkbjNfxxIARBDgjK7y7TUQ@public.gmane.org>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Wed, Nov 21, 2007 at 01:00:44PM +0000, Shaddy Baddah wrote:
>
> It hasn't seemed to. I patched the source (confirming the patched lines 
> are in), compiled, installed and rebooted to effect the changes. My 
> zd1211rw modules timestamp indicates that I have an updated module:

Thanks for your quick response and sorry for my late answer :)

I think Dave's patch is definietly on the right track but there
are subsequent unaligned accesses of a similar kind which is
why it still appears to be broken if you look at the kernel
messages.

But there is definitely progress because those addresses are now
bigger (0x394/0x39c/0x3a8 vs. 0x2** earlier).

So please try the following patch (instead of the original one)
which should fix all the unailgned accesses in do_rx.

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert-lOAM2aK0SrRLBo1qDEOMRrpzq4S04n8Q@public.gmane.org>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
--
diff --git a/drivers/net/wireless/zd1211rw/zd_mac.c b/drivers/net/wireless/zd1211rw/zd_mac.c
index a903645..d06b05b 100644
--- a/drivers/net/wireless/zd1211rw/zd_mac.c
+++ b/drivers/net/wireless/zd1211rw/zd_mac.c
@@ -1166,15 +1166,16 @@ static void do_rx(unsigned long mac_ptr)
 int zd_mac_rx_irq(struct zd_mac *mac, const u8 *buffer, unsigned int length)
 {
 	struct sk_buff *skb;
+	unsigned int hlen = ALIGN(sizeof(struct zd_rt_hdr), 16);
 
-	skb = dev_alloc_skb(sizeof(struct zd_rt_hdr) + length);
+	skb = dev_alloc_skb(hlen + length);
 	if (!skb) {
 		struct ieee80211_device *ieee = zd_mac_to_ieee80211(mac);
 		dev_warn(zd_mac_dev(mac), "Could not allocate skb.\n");
 		ieee->stats.rx_dropped++;
 		return -ENOMEM;
 	}
-	skb_reserve(skb, sizeof(struct zd_rt_hdr));
+	skb_reserve(skb, hlen - ZD_PLCP_HEADER_SIZE);
 	memcpy(__skb_put(skb, length), buffer, length);
 	skb_queue_tail(&mac->rx_queue, skb);
 	tasklet_schedule(&mac->rx_tasklet);
