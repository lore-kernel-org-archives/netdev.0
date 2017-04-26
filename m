From: Wei Yongjun <weiyj.lk@gmail.com>
Subject: [PATCH net-next] fib_rules: fix error return code
Date: Wed, 26 Apr 2017 14:03:50 +0000
Message-ID: <20170426140350.25451-1-weiyj.lk@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: Wei Yongjun <weiyongjun1@huawei.com>, netdev@vger.kernel.org
To: Lorenzo Colitti <lorenzo@google.com>,
        Ido Schimmel <idosch@mellanox.com>,
        David Ahern <dsa@cumulusnetworks.com>,
        Mateusz Bajorski <mateusz.bajorski@nokia.com>,
        Johannes Berg <johannes.berg@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f195.google.com ([209.85.192.195]:34953 "EHLO
        mail-pf0-f195.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S3000944AbdDZOEA (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 26 Apr 2017 10:04:00 -0400
Received: by mail-pf0-f195.google.com with SMTP id a188so267128pfa.2
        for <netdev@vger.kernel.org>; Wed, 26 Apr 2017 07:04:00 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Wei Yongjun <weiyongjun1@huawei.com>

Fix to return error code -EINVAL from the error handling
case instead of 0, as done elsewhere in this function.

Fixes: 622ec2c9d524 ("net: core: add UID to flows, rules, and routes")
Signed-off-by: Wei Yongjun <weiyongjun1@huawei.com>
---
 net/core/fib_rules.c | 6 ++++--
 1 file changed, 4 insertions(+), 2 deletions(-)

diff --git a/net/core/fib_rules.c b/net/core/fib_rules.c
index c58c1df..f21c4d3 100644
--- a/net/core/fib_rules.c
+++ b/net/core/fib_rules.c
@@ -440,6 +440,7 @@ int fib_nl_newrule(struct sk_buff *skb, struct nlmsghdr *nlh,
 	if (tb[FRA_TUN_ID])
 		rule->tun_id = nla_get_be64(tb[FRA_TUN_ID]);
 
+	err = -EINVAL;
 	if (tb[FRA_L3MDEV]) {
 #ifdef CONFIG_NET_L3_MASTER_DEV
 		rule->l3mdev = nla_get_u8(tb[FRA_L3MDEV]);
@@ -461,7 +462,6 @@ int fib_nl_newrule(struct sk_buff *skb, struct nlmsghdr *nlh,
 	else
 		rule->suppress_ifgroup = -1;
 
-	err = -EINVAL;
 	if (tb[FRA_GOTO]) {
 		if (rule->action != FR_ACT_GOTO)
 			goto errout_free;
@@ -592,8 +592,10 @@ int fib_nl_delrule(struct sk_buff *skb, struct nlmsghdr *nlh,
 
 	if (tb[FRA_UID_RANGE]) {
 		range = nla_get_kuid_range(tb);
-		if (!uid_range_set(&range))
+		if (!uid_range_set(&range)) {
+			err = -EINVAL;
 			goto errout;
+		}
 	} else {
 		range = fib_kuid_range_unset;
 	}
