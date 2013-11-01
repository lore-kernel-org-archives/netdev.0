From: Joe Perches <joe@perches.com>
Subject: Re: [PATCH NEXT V2] rtlwifi: Fix endian error in extracting packet
 type
Date: Thu, 31 Oct 2013 18:48:35 -0700
Message-ID: <1383270515.2769.15.camel@joe-AO722>
References: <1383266638-4813-1-git-send-email-Larry.Finger@lwfinger.net>
	 <1383267769.1583.8.camel@bwh-desktop.uk.level5networks.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Cc: Larry Finger <Larry.Finger@lwfinger.net>, linville@tuxdriver.com,
	linux-wireless@vger.kernel.org,
	Mark Cave-Ayland <mark.cave-ayland@ilande.co.uk>,
	netdev@vger.kernel.org, Stable <stable@vger.kernel.org>
To: Ben Hutchings <bhutchings@solarflare.com>
Return-path: <stable-owner@vger.kernel.org>
In-Reply-To: <1383267769.1583.8.camel@bwh-desktop.uk.level5networks.com>
Sender: stable-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, 2013-11-01 at 01:02 +0000, Ben Hutchings wrote:
> On Thu, 2013-10-31 at 19:43 -0500, Larry Finger wrote:
> > From: Mark Cave-Ayland <mark.cave-ayland@ilande.co.uk>
> > 
> > All of the rtlwifi drivers have an error in the routine that tests if
> > the data is "special". If it is, the subsequant transmission will be
> > at the lowest rate to enhance reliability. The 16-bit quantity is
> > big-endian, but was being extracted in native CPU mode. One of the
> > effects of this bug is to inhibit association under some conditions
> > as the TX rate is too high.
> > 
> > A statement that would have made the code correct had been changed to
> > a comment. Rather than just reinstating that code, the fix here passes
> > sparse tests. A side effect of fixing this problem would have been to force
> > all IPv6 frames to run at the lowest rate. The test for that frame type
> > is removed.
> > 
> > The original code only checked the lower-order byte of UDP ports for BOOTP
> > protocol. That is extended to the full 16-bit source and destination ports.
> > 
> > One of the local headers contained duplicates of some of the ETH_P_XXX
> > definitions. These are deleted.
> > 
> > Signed-off-by: Larry Finger <Larry.Finger@lwfinger.net>
> > Cc: Mark Cave-Ayland <mark.cave-ayland@ilande.co.uk>
> > Cc: Stable <stable@vger.kernel.org> [2.6.38+]
> > ---
> > 
> > V2 - Addresses comments by Ben Hutchings and Bjorn Mork.
> > 
> >  drivers/net/wireless/rtlwifi/base.c |   15 ++++++---------
> >  drivers/net/wireless/rtlwifi/wifi.h |    6 +-----
> >  2 files changed, 7 insertions(+), 14 deletions(-)
> > Index: wireless-testing-save/drivers/net/wireless/rtlwifi/base.c
> > ===================================================================
> > --- wireless-testing-save.orig/drivers/net/wireless/rtlwifi/base.c
> > +++ wireless-testing-save/drivers/net/wireless/rtlwifi/base.c
> > @@ -1077,17 +1077,17 @@ u8 rtl_is_special_data(struct ieee80211_
> >  
> >  	ip = (struct iphdr *)((u8 *) skb->data + mac_hdr_len +
> >  			      SNAP_SIZE + PROTOC_TYPE_SIZE);
> > -	ether_type = *(u16 *) ((u8 *) skb->data + mac_hdr_len + SNAP_SIZE);
> > -	/*	ether_type = ntohs(ether_type); */
> > +	ether_type = be16_to_cpu(*(__be16 *)((u8 *)skb->data + mac_hdr_len +
> > +					     SNAP_SIZE));
> >  
> >  	if (ETH_P_IP == ether_type) {
> >  		if (IPPROTO_UDP == ip->protocol) {
> >  			struct udphdr *udp = (struct udphdr *)((u8 *) ip +
> >  							       (ip->ihl << 2));
> > -			if (((((u8 *) udp)[1] == 68) &&
> > -			     (((u8 *) udp)[3] == 67)) ||
> > -			    ((((u8 *) udp)[1] == 67) &&
> > -			     (((u8 *) udp)[3] == 68))) {
> > +			if (((((u16 *) udp)[0] == 68) &&
> > +			     (((u16 *) udp)[2] == 67)) ||
> > +			    ((((u16 *) udp)[0] == 67) &&
> > +			     (((u16 *) udp)[2] == 68))) {
> [...]
> 
> Now you're missing byte-swapping here, and using the wrong offset for
> the dest port (4 bytes rather than 2).
> 
> If you really think this is necessary then use something like:
> 			if ((udp->source == htons(68) &&
> 			     udp->dest == htons(67)) ||
> 			     ...

Or maybe something like this?
---
 drivers/net/wireless/rtlwifi/base.c | 91 +++++++++++++++++--------------------
 1 file changed, 41 insertions(+), 50 deletions(-)

diff --git a/drivers/net/wireless/rtlwifi/base.c b/drivers/net/wireless/rtlwifi/base.c
index 9a78e3d..7e9df65 100644
--- a/drivers/net/wireless/rtlwifi/base.c
+++ b/drivers/net/wireless/rtlwifi/base.c
@@ -37,6 +37,7 @@
 
 #include <linux/ip.h>
 #include <linux/module.h>
+#include <linux/udp.h>
 
 /*
  *NOTICE!!!: This file will be very big, we should
@@ -1074,64 +1075,54 @@ u8 rtl_is_special_data(struct ieee80211_hw *hw, struct sk_buff *skb, u8 is_tx)
 	if (!ieee80211_is_data(fc))
 		return false;
 
+	ip = (const struct iphdr *)(skb->data + mac_hdr_len +
+				    SNAP_SIZE + PROTOC_TYPE_SIZE);
+	ether_type = be16_to_cpup((__be16 *)
+				  (skb->data + mac_hdr_len + SNAP_SIZE));
 
-	ip = (struct iphdr *)((u8 *) skb->data + mac_hdr_len +
-			      SNAP_SIZE + PROTOC_TYPE_SIZE);
-	ether_type = *(u16 *) ((u8 *) skb->data + mac_hdr_len + SNAP_SIZE);
-	/*	ether_type = ntohs(ether_type); */
-
-	if (ETH_P_IP == ether_type) {
-		if (IPPROTO_UDP == ip->protocol) {
-			struct udphdr *udp = (struct udphdr *)((u8 *) ip +
-							       (ip->ihl << 2));
-			if (((((u8 *) udp)[1] == 68) &&
-			     (((u8 *) udp)[3] == 67)) ||
-			    ((((u8 *) udp)[1] == 67) &&
-			     (((u8 *) udp)[3] == 68))) {
-				/*
-				 * 68 : UDP BOOTP client
-				 * 67 : UDP BOOTP server
-				 */
-				RT_TRACE(rtlpriv, (COMP_SEND | COMP_RECV),
-					 DBG_DMESG, "dhcp %s !!\n",
-					 is_tx ? "Tx" : "Rx");
-
-				if (is_tx) {
-					rtlpriv->enter_ps = false;
-					schedule_work(&rtlpriv->
-						      works.lps_change_work);
-					ppsc->last_delaylps_stamp_jiffies =
-					    jiffies;
-				}
+	switch (ether_type) {
+	case ETH_P_IP: {
+		struct udphdr *udp;
+		u16 src;
+		u16 dst;
 
-				return true;
-			}
-		}
-	} else if (ETH_P_ARP == ether_type) {
-		if (is_tx) {
-			rtlpriv->enter_ps = false;
-			schedule_work(&rtlpriv->works.lps_change_work);
-			ppsc->last_delaylps_stamp_jiffies = jiffies;
-		}
+		if (ip->protocol != IPPROTO_UDP)
+			return false;
 
-		return true;
-	} else if (ETH_P_PAE == ether_type) {
-		RT_TRACE(rtlpriv, (COMP_SEND | COMP_RECV), DBG_DMESG,
-			 "802.1X %s EAPOL pkt!!\n", is_tx ? "Tx" : "Rx");
+		udp = (struct udphdr *)((u8 *)ip + (ip->ihl << 2));
+		src = be16_to_cpu(udp->source) >> 8;
+		dst = be16_to_cpu(udp->dest) >> 8;
 
-		if (is_tx) {
-			rtlpriv->enter_ps = false;
-			schedule_work(&rtlpriv->works.lps_change_work);
-			ppsc->last_delaylps_stamp_jiffies = jiffies;
-		}
+		/*
+		 * 68 : UDP BOOTP client
+		 * 67 : UDP BOOTP server
+		 */
+		if (!((src == 68 && dst == 67) || (src == 67 && dst == 68)))
+			return false;
 
+		RT_TRACE(rtlpriv, (COMP_SEND | COMP_RECV), DBG_DMESG,
+			 "dhcp %s !!\n", is_tx ? "Tx" : "Rx");
+		break;
+	}
+	case ETH_P_ARP:
+		break;
+	case ETH_P_PAE:
+		RT_TRACE(rtlpriv, (COMP_SEND | COMP_RECV), DBG_DMESG,
+			 "802.1X %s EAPOL pkt!!\n", is_tx ? "Tx" : "Rx");
+		break;
+	case ETH_P_IPV6:
 		return true;
-	} else if (ETH_P_IPV6 == ether_type) {
-		/* IPv6 */
-		return true;
+	default:
+		return false;
 	}
 
-	return false;
+	if (is_tx) {
+		rtlpriv->enter_ps = false;
+		schedule_work(&rtlpriv->works.lps_change_work);
+		ppsc->last_delaylps_stamp_jiffies = jiffies;
+	}
+
+	return true;
 }
 EXPORT_SYMBOL_GPL(rtl_is_special_data);
 
