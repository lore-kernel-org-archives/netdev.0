From: Daniel Drake <dsd@gentoo.org>
Subject: Re: ieee80211 and devices which decrypt in hardware
Date: Wed, 13 Sep 2006 18:35:37 -0400
Message-ID: <450887B9.7080308@gentoo.org>
References: <45077241.1070102@gentoo.org> <200609131627.58153.mb@bu3sch.de>
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="------------040105090104050601080501"
Cc: netdev@vger.kernel.org, yi.zhu@intel.com,
	ipw2100-admin@linux.intel.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp131.iad.emailsrvr.com ([207.97.245.131]:29388 "EHLO
	smtp131.iad.emailsrvr.com") by vger.kernel.org with ESMTP
	id S1751236AbWIMWgk (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 13 Sep 2006 18:36:40 -0400
To: Michael Buesch <mb@bu3sch.de>
In-Reply-To: <200609131627.58153.mb@bu3sch.de>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This is a multi-part message in MIME format.
--------------040105090104050601080501
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit

Michael Buesch wrote:
> Does it strip ICV and FCS?

The driver always strips FCS (unconditionally).

The device does not strip ICV even when hardware decryption is in use, 
it gets included at the end of the frame, and I guess we should also 
handle that.

> in bcm43xx-softmac we use memmove to move the wireless header 4 bytes
> up and after that strip the first 4 bytes of the skb.
> I don't think there is another easy way to handle this. You'd have
> to modify the stack and softmac. And this would probably result in more
> overhead than the simple memove of 24 bytes.

softmac doesn't need modifying, and the ieee80211 modification is very 
simple. See the attached patch. ieee80211 could also be modified very 
easily to drop the ICV.

Surely this is nicer than adding IEEE802.11 header parsing code to 
zd1211rw rx path (currently there is none, which is nice) and a memmove?

Daniel


--------------040105090104050601080501
Content-Type: text/x-patch;
 name="ieee80211-rx-strip-iv.patch"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="ieee80211-rx-strip-iv.patch"

Index: linux/net/ieee80211/ieee80211_rx.c
===================================================================
--- linux.orig/net/ieee80211/ieee80211_rx.c
+++ linux/net/ieee80211/ieee80211_rx.c
@@ -655,6 +655,11 @@ int ieee80211_rx(struct ieee80211_device
 		goto rx_dropped;
 	}
 
+	/* If the device does decryption but leaves the IV in place then we
+	 * need to kill it. */
+	if (!can_be_decrypted && (fc & IEEE80211_FCTL_PROTECTED))
+		hdrlen += 4;
+
 	/* skb: hdr + (possible reassembled) full plaintext payload */
 
 	payload = skb->data + hdrlen;

--------------040105090104050601080501--
