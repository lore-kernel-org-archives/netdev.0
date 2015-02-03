From: Ignacy =?iso-8859-2?Q?Gaw=EAdzki?=
	<ignacy.gawedzki@green-communications.fr>
Subject: [PATCH net 1/1] cls_api.c: Fix dumping of non-existing actions'
 stats.
Date: Tue, 3 Feb 2015 18:32:51 +0100
Message-ID: <20150203173251.GB6246@zenon.in.qult.net>
References: <20150203141059.GA25454@zenon.in.qult.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-2
Content-Transfer-Encoding: QUOTED-PRINTABLE
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from [78.193.33.39] ([78.193.33.39]:53984 "EHLO mail.qult.net"
	rhost-flags-FAIL-FAIL-OK-OK) by vger.kernel.org with ESMTP
	id S965720AbbBCRdP (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 3 Feb 2015 12:33:15 -0500
Received: from zenon.in.qult.net ([192.168.64.1] helo=zenon)
	by mail.qult.net with esmtps (TLS1.2:RSA_AES_128_CBC_SHA1:128)
	(Exim 4.82)
	(envelope-from <ignacy.gawedzki@green-communications.fr>)
	id 1YIhLI-00039k-AD
	for netdev@vger.kernel.org; Tue, 03 Feb 2015 18:32:52 +0100
Received: from ig by zenon with local (Exim 4.84_RC1)
	(envelope-from <ignacy.gawedzki@green-communications.fr>)
	id 1YIhLH-0002CW-KA
	for netdev@vger.kernel.org; Tue, 03 Feb 2015 18:32:51 +0100
Content-Disposition: inline
In-Reply-To: <20150203141059.GA25454@zenon.in.qult.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

In tcf_exts_dump_stats(), ensure that exts->actions is not empty before
accessing the first element of that list and calling tcf_action_copy_st=
ats()
on it.  This fixes some random segvs when adding filters of type "basic=
" with
no particular action.

This also fixes the dumping of those "no-action" filters, which more of=
ten
than not made calls to tcf_action_copy_stats() fail and consequently ne=
tlink
attributes added by the caller to be removed by a call to nla_nest_canc=
el().

Signed-off-by: Ignacy Gaw=EAdzki <ignacy.gawedzki@green-communications.=
fr>
---
 net/sched/cls_api.c | 9 ++++++---
 1 file changed, 6 insertions(+), 3 deletions(-)

diff --git a/net/sched/cls_api.c b/net/sched/cls_api.c
index aad6a67..30e6967 100644
--- a/net/sched/cls_api.c
+++ b/net/sched/cls_api.c
@@ -602,9 +602,12 @@ EXPORT_SYMBOL(tcf_exts_dump);
 int tcf_exts_dump_stats(struct sk_buff *skb, struct tcf_exts *exts)
 {
 #ifdef CONFIG_NET_CLS_ACT
-	struct tc_action *a =3D tcf_exts_first_act(exts);
-	if (tcf_action_copy_stats(skb, a, 1) < 0)
-		return -1;
+	struct tc_action *a;
+	if (!list_empty(&exts->actions)) {
+		a =3D tcf_exts_first_act(exts);
+		if (tcf_action_copy_stats(skb, a, 1) < 0)
+			return -1;
+	}
 #endif
 	return 0;
 }
--=20
2.1.0
