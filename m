From: "John W. Linville" <linville@tuxdriver.com>
Subject: pull request: wireless-2.6 2010-02-12
Date: Fri, 12 Feb 2010 16:45:50 -0500
Message-ID: <20100212214550.GB16783@tuxdriver.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-wireless@vger.kernel.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: davem@davemloft.net
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Dave,

Here are a couple of stragglers for 2.6.33.  One purports to fix a
crash, the other avoids processing of uninitialized data when using
devices with rate control in hardware.

The latter patch will cause a merge issue in linux-next.  I'll be happy
to resolve that in wireless-next-2.6 once this merge request is
resolved.

Please let me know if there are problems!

Thanks,

John

---

The following changes since commit 044c18c9f51a2b92b310e28bb121e55451b088dd:
  David S. Miller (1):
        Merge branch 'master' of git://git.kernel.org/.../linville/wireless-2.6

are available in the git repository at:

  ssh://master.kernel.org/pub/scm/linux/kernel/git/linville/wireless-2.6.git master

Juuso Oikarinen (1):
      mac80211: fix handling of null-rate control in rate_control_get_rate

Shanyu Zhao (1):
      iwlwifi: fix AMSDU Rx after paged Rx patch

 drivers/net/wireless/iwlwifi/iwl-rx.c |    5 ++++-
 net/mac80211/rate.c                   |    3 +++
 2 files changed, 7 insertions(+), 1 deletions(-)

diff --git a/drivers/net/wireless/iwlwifi/iwl-rx.c b/drivers/net/wireless/iwlwifi/iwl-rx.c
index 6f36b6e..2dbce85 100644
--- a/drivers/net/wireless/iwlwifi/iwl-rx.c
+++ b/drivers/net/wireless/iwlwifi/iwl-rx.c
@@ -928,7 +928,10 @@ static void iwl_pass_packet_to_mac80211(struct iwl_priv *priv,
 	if (ieee80211_is_mgmt(fc) ||
 	    ieee80211_has_protected(fc) ||
 	    ieee80211_has_morefrags(fc) ||
-	    le16_to_cpu(hdr->seq_ctrl) & IEEE80211_SCTL_FRAG)
+	    le16_to_cpu(hdr->seq_ctrl) & IEEE80211_SCTL_FRAG ||
+	    (ieee80211_is_data_qos(fc) &&
+	     *ieee80211_get_qos_ctl(hdr) &
+	     IEEE80211_QOS_CONTROL_A_MSDU_PRESENT))
 		ret = skb_linearize(skb);
 	else
 		ret = __pskb_pull_tail(skb, min_t(u16, IWL_LINK_HDR_MAX, len)) ?
diff --git a/net/mac80211/rate.c b/net/mac80211/rate.c
index b9007f8..12a2bff 100644
--- a/net/mac80211/rate.c
+++ b/net/mac80211/rate.c
@@ -245,6 +245,9 @@ void rate_control_get_rate(struct ieee80211_sub_if_data *sdata,
 		info->control.rates[i].count = 1;
 	}
 
+	if (sdata->local->hw.flags & IEEE80211_HW_HAS_RATE_CONTROL)
+		return;
+
 	if (sta && sdata->force_unicast_rateidx > -1) {
 		info->control.rates[0].idx = sdata->force_unicast_rateidx;
 	} else {
-- 
John W. Linville		Someday the world will need a hero, and you
linville@tuxdriver.com			might be all we have.  Be ready.
