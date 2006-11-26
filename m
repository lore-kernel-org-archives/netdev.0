From: Patrick McHardy <kaber@trash.net>
Subject: [NET_SCHED]: policer: restore compatibility with old iproute binaries
Date: Sun, 26 Nov 2006 14:59:51 +0100
Message-ID: <45699DD7.8080408@trash.net>
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="------------020802090709040800020208"
Cc: Kernel Netdev Mailing List <netdev@vger.kernel.org>,
	jamal <hadi@cyberus.ca>
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:21424 "EHLO
	stinky.trash.net") by vger.kernel.org with ESMTP id S935396AbWKZOAI
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 26 Nov 2006 09:00:08 -0500
To: "David S. Miller" <davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This is a multi-part message in MIME format.
--------------020802090709040800020208
Content-Type: text/plain; charset=ISO-8859-15
Content-Transfer-Encoding: 7bit


--------------020802090709040800020208
Content-Type: text/plain;
 name="x"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="x"

[NET_SCHED]: policer: restore compatibility with old iproute binaries

The tc actions increased the size of struct tc_police, which broke
compatibility with old iproute binaries since both the act_police
and the old NET_CLS_POLICE code check for an exact size match.

Since the new members are not even used, the simple fix is to also
accept the size of the old structure. Dumping is not affected since
old userspace will receive a bigger structure, which is handled fine.

Signed-off-by: Patrick McHardy <kaber@trash.net>

---
commit 8c69566fc6b34f819d1002fdc76cdb2611e37dcb
tree dd502f69be944acd744f19392f3e3145552ca6b2
parent c498fe066d393b0f677fd0a857c0b25f24dd2049
author Patrick McHardy <kaber@gw.localnet> Sun, 26 Nov 2006 14:56:09 +0100
committer Patrick McHardy <kaber@gw.localnet> Sun, 26 Nov 2006 14:56:09 +0100

 net/sched/act_police.c |   26 ++++++++++++++++++++++----
 1 files changed, 22 insertions(+), 4 deletions(-)

diff --git a/net/sched/act_police.c b/net/sched/act_police.c
index fed47b6..af68e1e 100644
--- a/net/sched/act_police.c
+++ b/net/sched/act_police.c
@@ -46,6 +46,18 @@ static struct tcf_hashinfo police_hash_i
 	.lock	=	&police_lock,
 };
 
+/* old policer structure from before tc actions */
+struct tc_police_compat
+{
+	u32			index;
+	int			action;
+	u32			limit;
+	u32			burst;
+	u32			mtu;
+	struct tc_ratespec	rate;
+	struct tc_ratespec	peakrate;
+};
+
 /* Each policer is serialized by its individual spinlock */
 
 #ifdef CONFIG_NET_CLS_ACT
@@ -131,12 +143,15 @@ static int tcf_act_police_locate(struct 
 	struct tc_police *parm;
 	struct tcf_police *police;
 	struct qdisc_rate_table *R_tab = NULL, *P_tab = NULL;
+	int size;
 
 	if (rta == NULL || rtattr_parse_nested(tb, TCA_POLICE_MAX, rta) < 0)
 		return -EINVAL;
 
-	if (tb[TCA_POLICE_TBF-1] == NULL ||
-	    RTA_PAYLOAD(tb[TCA_POLICE_TBF-1]) != sizeof(*parm))
+	if (tb[TCA_POLICE_TBF-1] == NULL)
+		return -EINVAL;
+	size = RTA_PAYLOAD(tb[TCA_POLICE_TBF-1]);
+	if (size != sizeof(*parm) && size != sizeof(struct tc_police_compat))
 		return -EINVAL;
 	parm = RTA_DATA(tb[TCA_POLICE_TBF-1]);
 
@@ -415,12 +430,15 @@ struct tcf_police *tcf_police_locate(str
 	struct tcf_police *police;
 	struct rtattr *tb[TCA_POLICE_MAX];
 	struct tc_police *parm;
+	int size;
 
 	if (rtattr_parse_nested(tb, TCA_POLICE_MAX, rta) < 0)
 		return NULL;
 
-	if (tb[TCA_POLICE_TBF-1] == NULL ||
-	    RTA_PAYLOAD(tb[TCA_POLICE_TBF-1]) != sizeof(*parm))
+	if (tb[TCA_POLICE_TBF-1] == NULL)
+		return NULL;
+	size = RTA_PAYLOAD(tb[TCA_POLICE_TBF-1]);
+	if (size != sizeof(*parm) && size != sizeof(struct tc_police_compat))
 		return NULL;
 
 	parm = RTA_DATA(tb[TCA_POLICE_TBF-1]);

--------------020802090709040800020208--
