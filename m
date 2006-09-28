From: Larry Finger <Larry.Finger@lwfinger.net>
Subject: Re: kernel: TKIP: replay detected:
Date: Thu, 28 Sep 2006 16:42:10 -0500
Message-ID: <451C41B2.4090209@lwfinger.net>
References: <20060924104053.GA6645@frodo.home.lxtec.de> <20060925144954.GC16949@tuxdriver.com> <20060928160834.GC9615@instant802.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: "John W. Linville" <linville@tuxdriver.com>,
	netdev <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mtiwmhc11.worldnet.att.net ([204.127.131.115]:20706 "EHLO
	mtiwmhc11.worldnet.att.net") by vger.kernel.org with ESMTP
	id S1161187AbWI1VmN (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 28 Sep 2006 17:42:13 -0400
To: Jouni Malinen <jkm@devicescape.com>
In-Reply-To: <20060928160834.GC9615@instant802.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Jouni Malinen wrote:
> 
> TKIP/CCMP are required to use incrementing TSC/PN for each frame. When a
> directed IEEE 802.11 frame is not acknowledged, it will be retransmitted
> (up to a certain limit). This retransmitted frame will use the same
> TSC/PN. However, the duplicate detection routine in the receiver
> (something that happens before TKIP/CCMP processing) should catch these
> cases since the frames from the same source address that use the same
> seq# and fragm# should be dropped at that layer.
> 
> If it can be shown, that these errors are indeed caused by a broken
> transmitter (and that transmitter is not a Linux device for which we
> control the driver code ;-), I would be much more willing to accept
> patches that silence these messages (as long as the replay statistics
> are easily available in other ways) by default, but I would still not
> remove them completely.
> 

I added the following patch to bcm43xx:

Index: wireless-2.6/drivers/net/wireless/bcm43xx/bcm43xx_xmit.c
===================================================================
--- wireless-2.6.orig/drivers/net/wireless/bcm43xx/bcm43xx_xmit.c
+++ wireless-2.6/drivers/net/wireless/bcm43xx/bcm43xx_xmit.c
@@ -460,6 +460,9 @@ static s8 bcm43xx_rssinoise_postprocess(
  }
  #endif

+static u16 prev_frame = 0;
+static u16 prev_seq = 0;
+
  int bcm43xx_rx(struct bcm43xx_private *bcm,
  	       struct sk_buff *skb,
  	       struct bcm43xx_rxhdr *rxhdr)
@@ -470,6 +473,7 @@ int bcm43xx_rx(struct bcm43xx_private *b
  	struct ieee80211_rx_stats stats;
  	struct ieee80211_hdr_4addr *wlhdr;
  	u16 frame_ctl;
+	u16 seq_ctl;
  	int is_packet_for_us = 0;
  	int err = -EINVAL;
  	const u16 rxflags1 = le16_to_cpu(rxhdr->flags1);
@@ -544,6 +548,14 @@ int bcm43xx_rx(struct bcm43xx_private *b
  	}

  	frame_ctl = le16_to_cpu(wlhdr->frame_ctl);
+	seq_ctl = le16_to_cpu(wlhdr->seq_ctl);
+
+	if ((frame_ctl == prev_frame) && (seq_ctl == prev_seq))
+		return -EINVAL;
+
+	prev_frame = frame_ctl;
+	prev_seq = seq_ctl;
+
  	if ((frame_ctl & IEEE80211_FCTL_PROTECTED) && !bcm->ieee->host_decrypt) {
  		frame_ctl &= ~IEEE80211_FCTL_PROTECTED;
  		wlhdr->frame_ctl = cpu_to_le16(frame_ctl);		



By dropping those packets with frame_ctl and seq_ctl the same as the values in the previous packet, 
I was able to cut the number of TKIP replay messages, but some still come through. Is this what you 
had in mind, or is there somewhere else that I should be looking?

Larry
