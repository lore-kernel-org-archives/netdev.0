From: Julia Lawall <julia@diku.dk>
Subject: [PATCH 1/2] net/wireless/nl80211.c: Avoid call to genlmsg_cancel
Date: Fri, 28 Jan 2011 15:17:11 +0100
Message-ID: <1296224232-8115-1-git-send-email-julia@diku.dk>
Cc: kernel-janitors@vger.kernel.org,
	"John W. Linville" <linville@tuxdriver.com>,
	"David S. Miller" <davem@davemloft.net>,
	linux-wireless@vger.kernel.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: Johannes Berg <johannes@sipsolutions.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

genlmsg_cancel subtracts some constants from its second argument before
calling nlmsg_cancel.  nlmsg_cancel then calls nlmsg_trim on the same
arguments.  nlmsg_trim tests for NULL before doing any computation, but a
NULL second argument to genlmsg_cancel is no longer NULL due to the initial
subtraction.  Nothing else happens in this execution, so the call to
genlmsg_cancel is simply unnecessary in this case.

The semantic match that finds this problem is as follows:
(http://coccinelle.lip6.fr/)

// <smpl>
@@
expression data;
@@

if (data == NULL) { ...
* genlmsg_cancel(..., data);
  ...
  return ...;
}
// </smpl>

Signed-off-by: Julia Lawall <julia@diku.dk>

---
 net/wireless/nl80211.c |    6 ++++--
 1 file changed, 4 insertions(+), 2 deletions(-)

diff --git a/net/wireless/nl80211.c b/net/wireless/nl80211.c
index 9b62710..864ddfb 100644
--- a/net/wireless/nl80211.c
+++ b/net/wireless/nl80211.c
@@ -2718,7 +2718,7 @@ static int nl80211_get_mesh_config(struct sk_buff *skb,
 	hdr = nl80211hdr_put(msg, info->snd_pid, info->snd_seq, 0,
 			     NL80211_CMD_GET_MESH_CONFIG);
 	if (!hdr)
-		goto nla_put_failure;
+		goto out;
 	pinfoattr = nla_nest_start(msg, NL80211_ATTR_MESH_CONFIG);
 	if (!pinfoattr)
 		goto nla_put_failure;
@@ -2759,6 +2759,7 @@ static int nl80211_get_mesh_config(struct sk_buff *skb,
 
  nla_put_failure:
 	genlmsg_cancel(msg, hdr);
+ out:
 	nlmsg_free(msg);
 	return -ENOBUFS;
 }
@@ -2954,7 +2955,7 @@ static int nl80211_get_reg(struct sk_buff *skb, struct genl_info *info)
 	hdr = nl80211hdr_put(msg, info->snd_pid, info->snd_seq, 0,
 			     NL80211_CMD_GET_REG);
 	if (!hdr)
-		goto nla_put_failure;
+		goto put_failure;
 
 	NLA_PUT_STRING(msg, NL80211_ATTR_REG_ALPHA2,
 		cfg80211_regdomain->alpha2);
@@ -3001,6 +3002,7 @@ static int nl80211_get_reg(struct sk_buff *skb, struct genl_info *info)
 
 nla_put_failure:
 	genlmsg_cancel(msg, hdr);
+put_failure:
 	nlmsg_free(msg);
 	err = -EMSGSIZE;
 out:
