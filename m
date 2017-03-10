From: Etienne Noss <etienne.noss@wifirst.fr>
Subject: [PATCH net] act_connmark: avoid crashing on malformed nlattrs with null parms
Date: Fri, 10 Mar 2017 16:55:32 +0100
Message-ID: <1489161332-5012-1-git-send-email-etienne.noss@wifirst.fr>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 8bit
Cc: =?UTF-8?q?=C3=89tienne=20Noss?= <etienne.noss@wifirst.fr>,
        Victorien Molle <victorien.molle@wifirst.fr>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from fourcot.fr ([217.70.191.14]:36559 "EHLO olfflo.fourcot.fr"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S933097AbdCJQDc (ORCPT <rfc822;netdev@vger.kernel.org>);
        Fri, 10 Mar 2017 11:03:32 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

tcf_connmark_init does not check in its configuration if TCA_CONNMARK_PARMS
is set, resulting in a null pointer dereference when trying to access it.

[501099.043007] BUG: unable to handle kernel NULL pointer dereference at 0000000000000004
[501099.043039] IP: [<ffffffffc10c60fb>] tcf_connmark_init+0x8b/0x180 [act_connmark]
...
[501099.044334] Call Trace:
[501099.044345]  [<ffffffffa47270e8>] ? tcf_action_init_1+0x198/0x1b0
[501099.044363]  [<ffffffffa47271b0>] ? tcf_action_init+0xb0/0x120
[501099.044380]  [<ffffffffa47250a4>] ? tcf_exts_validate+0xc4/0x110
[501099.044398]  [<ffffffffc0f5fa97>] ? u32_set_parms+0xa7/0x270 [cls_u32]
[501099.044417]  [<ffffffffc0f60bf0>] ? u32_change+0x680/0x87b [cls_u32]
[501099.044436]  [<ffffffffa4725d1d>] ? tc_ctl_tfilter+0x4dd/0x8a0
[501099.044454]  [<ffffffffa44a23a1>] ? security_capable+0x41/0x60
[501099.044471]  [<ffffffffa470ca01>] ? rtnetlink_rcv_msg+0xe1/0x220
[501099.044490]  [<ffffffffa470c920>] ? rtnl_newlink+0x870/0x870
[501099.044507]  [<ffffffffa472cc61>] ? netlink_rcv_skb+0xa1/0xc0
[501099.044524]  [<ffffffffa47073f4>] ? rtnetlink_rcv+0x24/0x30
[501099.044541]  [<ffffffffa472c634>] ? netlink_unicast+0x184/0x230
[501099.044558]  [<ffffffffa472c9d8>] ? netlink_sendmsg+0x2f8/0x3b0
[501099.044576]  [<ffffffffa46d8880>] ? sock_sendmsg+0x30/0x40
[501099.044592]  [<ffffffffa46d8e03>] ? SYSC_sendto+0xd3/0x150
[501099.044608]  [<ffffffffa425fda1>] ? __do_page_fault+0x2d1/0x510
[501099.044626]  [<ffffffffa47fbd7b>] ? system_call_fast_compare_end+0xc/0x9b

Signed-off-by: Étienne Noss <etienne.noss@wifirst.fr>
Signed-off-by: Victorien Molle <victorien.molle@wifirst.fr>
---
 net/sched/act_connmark.c | 3 +++
 1 file changed, 3 insertions(+)

diff --git a/net/sched/act_connmark.c b/net/sched/act_connmark.c
index ab8062909962..f9bb43c25697 100644
--- a/net/sched/act_connmark.c
+++ b/net/sched/act_connmark.c
@@ -113,6 +113,9 @@ static int tcf_connmark_init(struct net *net, struct nlattr *nla,
 	if (ret < 0)
 		return ret;
 
+	if (!tb[TCA_CONNMARK_PARMS])
+		return -EINVAL;
+
 	parm = nla_data(tb[TCA_CONNMARK_PARMS]);
 
 	if (!tcf_hash_check(tn, parm->index, a, bind)) {
-- 
2.11.0
