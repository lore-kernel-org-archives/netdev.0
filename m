From: Shaddy Baddah <shaddy_baddah-PkbjNfxxIARBDgjK7y7TUQ@public.gmane.org>
Subject: Re: ZD1211RW unaligned accesses...
Date: Fri, 30 Nov 2007 18:34:56 +1100
Message-ID: <474FBD20.10202@hotmail.com>
References: <20071120.040546.222294375.davem@davemloft.net> <47442BFC.8090008@hotmail.com> <20071124150216.GA28153@gondor.apana.org.au> <20071129214533.GD32730@tuxdriver.com> <20071129234327.GA23769@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: "John W. Linville" <linville-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org>,
	netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>, dsd-aBrp7R+bbdUdnm+yROfE0A@public.gmane.org,
	kune-hUSrv6EASfkEnNRfnnE9gw@public.gmane.org
To: Herbert Xu <herbert-lOAM2aK0SrRLBo1qDEOMRrpzq4S04n8Q@public.gmane.org>
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <20071129234327.GA23769-lOAM2aK0SrRLBo1qDEOMRrpzq4S04n8Q@public.gmane.org>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

Hi again,

Herbert Xu wrote:
> On Thu, Nov 29, 2007 at 04:45:33PM -0500, John W. Linville wrote:
>> So, did the patch below fix the problem?  Should I apply it?
> 
> I'm keen to find out the result too :)
> 
> Chances are it does make progress however we may still have the
> general wireless/IP stack alignment issue that we are still discussing.


OK... so I've applied patches left right and centre. As there have been 
a few, I'll in-line them all at the bottom of this email.

The result is that there are no more unaligned access messages at all. 
However, I still can only scan one (occasionally two) AP, using iwlist 
eth2 scanning command before a bus error. Jean, I missed your emails 
regarding compiling the wireless-tools, I will try these and see if they 
help.

Perhaps related to the scanning problems, I cannot setup any wireless 
links, with Open access points, WEP access points, anything at all. I am 
losing direction on what information to supply here-in, but am willing 
to take suggestions.

Thanks for all your help,
Shaddy

Patches applied follow:

diff --git a/drivers/net/wireless/zd1211rw/zd_mac.c 
b/drivers/net/wireless/zd1211rw/zd_mac.c
index a903645..d06b05b 100644
--- a/drivers/net/wireless/zd1211rw/zd_mac.c
+++ b/drivers/net/wireless/zd1211rw/zd_mac.c
@@ -1166,15 +1166,16 @@ static void do_rx(unsigned long mac_ptr)
  int zd_mac_rx_irq(struct zd_mac *mac, const u8 *buffer, unsigned int 
length)
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

diff --git a/net/ieee80211/ieee80211_tx.c b/net/ieee80211/ieee80211_tx.c
index a4c3c51..6d06f13 100644
--- a/net/ieee80211/ieee80211_tx.c
+++ b/net/ieee80211/ieee80211_tx.c
@@ -144,7 +144,8 @@ static int ieee80211_copy_snap(u8 * data, u16 h_proto)
  	snap->oui[1] = oui[1];
  	snap->oui[2] = oui[2];

-	*(u16 *) (data + SNAP_SIZE) = htons(h_proto);
+	h_proto = htons(h_proto);
+	memcpy(data + SNAP_SIZE, &h_proto, sizeof(u16));

  	return SNAP_SIZE + sizeof(u16);
  }

Index: linux-2.6.24-rc3-git1/drivers/net/wireless/zd1211rw/zd_mac.c
===================================================================
--- linux-2.6.24-rc3-git1.orig/drivers/net/wireless/zd1211rw/zd_mac.c
+++ linux-2.6.24-rc3-git1/drivers/net/wireless/zd1211rw/zd_mac.c
@@ -974,14 +974,14 @@ static int is_data_packet_for_us(struct
  	switch (ieee->iw_mode) {
  	case IW_MODE_ADHOC:
  		if ((fc & (IEEE80211_FCTL_TODS|IEEE80211_FCTL_FROMDS)) != 0 ||
-		    compare_ether_addr(hdr->addr3, ieee->bssid) != 0)
+		    memcmp(hdr->addr3, ieee->bssid, ETH_ALEN) != 0)
  			return 0;
  		break;
  	case IW_MODE_AUTO:
  	case IW_MODE_INFRA:
  		if ((fc & (IEEE80211_FCTL_TODS|IEEE80211_FCTL_FROMDS)) !=
  		    IEEE80211_FCTL_FROMDS ||
-		    compare_ether_addr(hdr->addr2, ieee->bssid) != 0)
+		    memcmp(hdr->addr2, ieee->bssid, ETH_ALEN) != 0)
  			return 0;
  		break;
  	default:
@@ -989,9 +989,9 @@ static int is_data_packet_for_us(struct
  		return 0;
  	}

-	return compare_ether_addr(hdr->addr1, netdev->dev_addr) == 0 ||
+	return memcmp(hdr->addr1, netdev->dev_addr, ETH_ALEN) == 0 ||
  	       (is_multicast_ether_addr(hdr->addr1) &&
-		compare_ether_addr(hdr->addr3, netdev->dev_addr) != 0) ||
+		memcmp(hdr->addr3, netdev->dev_addr, ETH_ALEN) != 0) ||
  	       (netdev->flags & IFF_PROMISC);
  }

@@ -1047,7 +1047,7 @@ static void update_qual_rssi(struct zd_m
  	hdr = (struct ieee80211_hdr_3addr *)buffer;
  	if (length < offsetof(struct ieee80211_hdr_3addr, addr3))
  		return;
-	if (compare_ether_addr(hdr->addr2, zd_mac_to_ieee80211(mac)->bssid) != 0)
+	if (memcmp(hdr->addr2, zd_mac_to_ieee80211(mac)->bssid, ETH_ALEN) != 0)
  		return;

  	spin_lock_irqsave(&mac->lock, flags);


--- everything.orig/drivers/net/wireless/zd1211rw/Makefile	2007-11-23 
11:36:30.652094075 +0100
+++ everything/drivers/net/wireless/zd1211rw/Makefile	2007-11-23 
11:36:57.112090711 +0100
@@ -1,5 +1,7 @@
  obj-$(CONFIG_ZD1211RW) += zd1211rw.o

+EXTRA_CFLAGS += -fno-inline-functions-called-once
+
  zd1211rw-objs := zd_chip.o zd_ieee80211.o \
  		zd_mac.o zd_netdev.o \
  		zd_rf_al2230.o zd_rf_rf2959.o \


I believe that's it.
