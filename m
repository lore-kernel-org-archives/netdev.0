From: Chen Gang <gang.chen.5i5j@gmail.com>
Subject: [PATCH] net: mac80211: tx.c: be sure of 'sdata->vif.type' must be
 NL80211_IFTYPE_AP when be in NL80211_IFTYPE_AP case
Date: Wed, 27 Nov 2013 12:53:46 +0800
Message-ID: <52957ADA.2080704@gmail.com>
References: <528AEFB7.4060301@gmail.com> <20131125011938.GB18921@codeaurora.org> <5292B845.3010404@gmail.com> <5292B8A0.7020409@gmail.com> <5294255E.7040105@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: rkuo <rkuo@codeaurora.org>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	David Miller <davem@davemloft.net>,
	linux-wireless@vger.kernel.org, netdev <netdev@vger.kernel.org>
To: "John W. Linville" <linville@tuxdriver.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <5294255E.7040105@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

In next-20131122 tree, if "sdata->vif.type != NL80211_IFTYPE_AP",
'chanctx_conf' will be not initialized, so need check it. Related
warning (with allmodconfig under hexagon):

    CC [M]  net/mac80211/tx.o
  net/mac80211/tx.c: In function 'ieee80211_subif_start_xmit':
  net/mac80211/tx.c:1827:27: warning: 'chanctx_conf' may be used uninitialized in this function [-Wuninitialized]


Signed-off-by: Chen Gang <gang.chen.5i5j@gmail.com>
---
 net/mac80211/tx.c |    5 +++--
 1 files changed, 3 insertions(+), 2 deletions(-)

diff --git a/net/mac80211/tx.c b/net/mac80211/tx.c
index c558b24..f3245d6 100644
--- a/net/mac80211/tx.c
+++ b/net/mac80211/tx.c
@@ -1814,8 +1814,9 @@ netdev_tx_t ieee80211_subif_start_xmit(struct sk_buff *skb,
 			break;
 		/* fall through */
 	case NL80211_IFTYPE_AP:
-		if (sdata->vif.type == NL80211_IFTYPE_AP)
-			chanctx_conf = rcu_dereference(sdata->vif.chanctx_conf);
+		if (sdata->vif.type != NL80211_IFTYPE_AP)
+			goto fail_rcu;
+		chanctx_conf = rcu_dereference(sdata->vif.chanctx_conf);
 		if (!chanctx_conf)
 			goto fail_rcu;
 		fc |= cpu_to_le16(IEEE80211_FCTL_FROMDS);
-- 
1.7.7.6
