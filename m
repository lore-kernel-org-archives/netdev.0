From: "John W. Linville" <linville-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org>
Subject: pull request: wireless-2.6 2010-04-09
Date: Fri, 9 Apr 2010 11:38:07 -0400
Message-ID: <20100409153807.GA3014@tuxdriver.com>
References: <Pine.LNX.4.64.1004090251210.11582@boston.corp.fedex.com> <Pine.LNX.4.64.1004090336410.22139@boston.corp.fedex.com> <1270759800.19330.19.camel@wwguy-ubuntu> <20100408200218.GC2999@tuxdriver.com> <1270762107.20845.3.camel@wwguy-ubuntu>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Jeff Chua <jeff.chua.linux-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>,
	"Zhao, Shanyu" <shanyu.zhao-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>,
	"Chatre, Reinette" <reinette.chatre-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>,
	"stable-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org" <stable-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>,
	Linux Kernel <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	Linus Torvalds <torvalds-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>,
	Al Viro <viro-RmSDqhL/yNMiFSDQTTA3OLVCufUGDwFn@public.gmane.org>,
	"Guy, Wey-Yi" <wey-yi.w.guy-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>,
	linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <1270762107.20845.3.camel@wwguy-ubuntu>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

Dave,

This fix is intended for 2.6.34.  It resolves an issue involving an
Oops on boxes w/ iwl4965 hardware, apparently introduced by another
recent patch.  The thread describing the issue and the resolution
is here:

	http://marc.info/?l=linux-kernel&m=127074721531649&w=2

In order to avoid reverting that patch, please accept this fix instead.
As usual, please let me know if there are problems!

Thanks,

John

---

The following changes since commit 2626419ad5be1a054d350786b684b41d23de1538:
  David S. Miller (1):
        tcp: Set CHECKSUM_UNNECESSARY in tcp_init_nondata_skb

are available in the git repository at:

  git://git.kernel.org/pub/scm/linux/kernel/git/linville/wireless-2.6.git master

Wey-Yi Guy (1):
      iwlwifi: need check for valid qos packet before free

 drivers/net/wireless/iwlwifi/iwl-4965.c |   13 +++++++++----
 1 files changed, 9 insertions(+), 4 deletions(-)

diff --git a/drivers/net/wireless/iwlwifi/iwl-4965.c b/drivers/net/wireless/iwlwifi/iwl-4965.c
index 83c52a6..8972166 100644
--- a/drivers/net/wireless/iwlwifi/iwl-4965.c
+++ b/drivers/net/wireless/iwlwifi/iwl-4965.c
@@ -2015,7 +2015,9 @@ static void iwl4965_rx_reply_tx(struct iwl_priv *priv,
 			IWL_DEBUG_TX_REPLY(priv, "Retry scheduler reclaim scd_ssn "
 					   "%d index %d\n", scd_ssn , index);
 			freed = iwl_tx_queue_reclaim(priv, txq_id, index);
-			iwl_free_tfds_in_queue(priv, sta_id, tid, freed);
+			if (qc)
+				iwl_free_tfds_in_queue(priv, sta_id,
+						       tid, freed);
 
 			if (priv->mac80211_registered &&
 			    (iwl_queue_space(&txq->q) > txq->q.low_mark) &&
@@ -2041,14 +2043,17 @@ static void iwl4965_rx_reply_tx(struct iwl_priv *priv,
 				   tx_resp->failure_frame);
 
 		freed = iwl_tx_queue_reclaim(priv, txq_id, index);
-		iwl_free_tfds_in_queue(priv, sta_id, tid, freed);
+		if (qc && likely(sta_id != IWL_INVALID_STATION))
+			iwl_free_tfds_in_queue(priv, sta_id, tid, freed);
+		else if (sta_id == IWL_INVALID_STATION)
+			IWL_DEBUG_TX_REPLY(priv, "Station not known\n");
 
 		if (priv->mac80211_registered &&
 		    (iwl_queue_space(&txq->q) > txq->q.low_mark))
 			iwl_wake_queue(priv, txq_id);
 	}
