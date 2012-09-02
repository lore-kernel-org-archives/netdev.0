From: Wei Yongjun <weiyj.lk@gmail.com>
Subject: [PATCH] nl80211: [PATCH] nl80211: fix possible memory leak nl80211_connect()
Date: Sun, 2 Sep 2012 21:41:04 +0800
Message-ID: <CAPgLHd_ykxWnV82swesivdEkyqP+a+hBgTTT8SXwn9RYWR1HFA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: yongjun_wei@trendmicro.com.cn, linux-wireless@vger.kernel.org,
	netdev@vger.kernel.org
To: johannes@sipsolutions.net, linville@tuxdriver.com,
	davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qa0-f46.google.com ([209.85.216.46]:44994 "EHLO
	mail-qa0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751098Ab2IBNlF (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 2 Sep 2012 09:41:05 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Wei Yongjun <yongjun_wei@trendmicro.com.cn>

connkeys is malloced in nl80211_parse_connkeys() and should
be freed in the error handling case, otherwise it will cause
memory leak.

spatch with a semantic match is used to found this problem.
(http://coccinelle.lip6.fr/)

Signed-off-by: Wei Yongjun <yongjun_wei@trendmicro.com.cn>
---
 net/wireless/nl80211.c | 4 +++-
 1 file changed, 3 insertions(+), 1 deletion(-)

diff --git a/net/wireless/nl80211.c b/net/wireless/nl80211.c
index 97026f3..1e37dbf 100644
--- a/net/wireless/nl80211.c
+++ b/net/wireless/nl80211.c
@@ -5633,8 +5633,10 @@ static int nl80211_connect(struct sk_buff *skb, struct genl_info *info)
 		       sizeof(connect.ht_capa_mask));
 
 	if (info->attrs[NL80211_ATTR_HT_CAPABILITY]) {
-		if (!info->attrs[NL80211_ATTR_HT_CAPABILITY_MASK])
+		if (!info->attrs[NL80211_ATTR_HT_CAPABILITY_MASK]) {
+			kfree(connkeys);
 			return -EINVAL;
+		}
 		memcpy(&connect.ht_capa,
 		       nla_data(info->attrs[NL80211_ATTR_HT_CAPABILITY]),
 		       sizeof(connect.ht_capa));
