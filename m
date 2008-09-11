From: "John W. Linville" <linville@tuxdriver.com>
Subject: pull request: wireless-2.6 2008-09-11
Date: Thu, 11 Sep 2008 16:13:09 -0400
Message-ID: <20080911201308.GJ3423@tuxdriver.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-wireless@vger.kernel.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from charlotte.tuxdriver.com ([70.61.120.58]:43783 "EHLO
	smtp.tuxdriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753122AbYIKUlf (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 11 Sep 2008 16:41:35 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Dave,

Here is one fix for 2.6.27.  It is a backport of a patch that is already
in net-next-2.6.  Since it is for a new driver (ath9k) and since it
fixes a reported bug (http://bugzilla.kernel.org/show_bug.cgi?id=11394)
I think it should be OK to pass it to Linus for the current cycle.

John

---

Individual patch is available here:

	http://www.kernel.org/pub/linux/kernel/people/linville/wireless-2.6/

---

The following changes since commit e550dfb0c2c31b6363aa463a035fc9f8dcaa3c9b:
  Neil Horman (1):
        ipv6: Fix OOPS in ip6_dst_lookup_tail().

are available in the git repository at:

  git://git.kernel.org/pub/scm/linux/kernel/git/linville/wireless-2.6.git master

Jouni Malinen (1):
      ath9k: Assign seq# when mac80211 requests this

 drivers/net/wireless/ath9k/beacon.c |   13 +++++++++++++
 drivers/net/wireless/ath9k/core.h   |    1 +
 drivers/net/wireless/ath9k/main.c   |   14 ++++++++++++++
 3 files changed, 28 insertions(+), 0 deletions(-)

diff --git a/drivers/net/wireless/ath9k/beacon.c b/drivers/net/wireless/ath9k/beacon.c
index caf5694..00a0eaa 100644
--- a/drivers/net/wireless/ath9k/beacon.c
+++ b/drivers/net/wireless/ath9k/beacon.c
@@ -209,6 +209,7 @@ static struct ath_buf *ath_beacon_generate(struct ath_softc *sc, int if_id)
 	unsigned int curlen;
 	struct ath_txq *cabq;
 	struct ath_txq *mcastq;
+	struct ieee80211_tx_info *info;
 	avp = sc->sc_vaps[if_id];
 
 	mcastq = &avp->av_mcastq;
@@ -232,6 +233,18 @@ static struct ath_buf *ath_beacon_generate(struct ath_softc *sc, int if_id)
 	 */
 	curlen = skb->len;
 
+	info = IEEE80211_SKB_CB(skb);
+	if (info->flags & IEEE80211_TX_CTL_ASSIGN_SEQ) {
+		/*
+		 * TODO: make sure the seq# gets assigned properly (vs. other
+		 * TX frames)
+		 */
+		struct ieee80211_hdr *hdr = (struct ieee80211_hdr *) skb->data;
+		sc->seq_no += 0x10;
+		hdr->seq_ctrl &= cpu_to_le16(IEEE80211_SCTL_FRAG);
+		hdr->seq_ctrl |= cpu_to_le16(sc->seq_no);
+	}
+
 	/* XXX: spin_lock_bh should not be used here, but sparse bitches
 	 * otherwise. We should fix sparse :) */
 	spin_lock_bh(&mcastq->axq_lock);
diff --git a/drivers/net/wireless/ath9k/core.h b/drivers/net/wireless/ath9k/core.h
index 673b3d8..4ee695b 100644
--- a/drivers/net/wireless/ath9k/core.h
+++ b/drivers/net/wireless/ath9k/core.h
@@ -992,6 +992,7 @@ struct ath_softc {
 	u32 sc_txintrperiod;	/* tx interrupt batching */
 	int sc_haltype2q[ATH9K_WME_AC_VO+1]; /* HAL WME	AC -> h/w qnum */
 	u32 sc_ant_tx[8];	/* recent tx frames/antenna */
+	u16 seq_no; /* TX sequence number */
 
 	/* Beacon */
 	struct ath9k_tx_queue_info sc_beacon_qi;
diff --git a/drivers/net/wireless/ath9k/main.c b/drivers/net/wireless/ath9k/main.c
index c5107f2..99badf1 100644
--- a/drivers/net/wireless/ath9k/main.c
+++ b/drivers/net/wireless/ath9k/main.c
@@ -369,6 +369,20 @@ static int ath9k_tx(struct ieee80211_hw *hw,
 {
 	struct ath_softc *sc = hw->priv;
 	int hdrlen, padsize;
+	struct ieee80211_tx_info *info = IEEE80211_SKB_CB(skb);
+
+	/*
+	 * As a temporary workaround, assign seq# here; this will likely need
+	 * to be cleaned up to work better with Beacon transmission and virtual
+	 * BSSes.
+	 */
+	if (info->flags & IEEE80211_TX_CTL_ASSIGN_SEQ) {
+		struct ieee80211_hdr *hdr = (struct ieee80211_hdr *) skb->data;
+		if (info->flags & IEEE80211_TX_CTL_FIRST_FRAGMENT)
+			sc->seq_no += 0x10;
+		hdr->seq_ctrl &= cpu_to_le16(IEEE80211_SCTL_FRAG);
+		hdr->seq_ctrl |= cpu_to_le16(sc->seq_no);
+	}
 
 	/* Add the padding after the header if this is not already done */
 	hdrlen = ieee80211_get_hdrlen_from_skb(skb);
-- 
John W. Linville
linville@tuxdriver.com
