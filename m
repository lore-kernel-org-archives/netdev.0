From: Ignacy =?iso-8859-2?Q?Gaw=EAdzki?=
	<ignacy.gawedzki@green-communications.fr>
Subject: [PATCH net v2] cls_api.c: Fix dumping of non-existing actions' stats.
Date: Tue, 3 Feb 2015 19:05:18 +0100
Message-ID: <20150203180518.GA3806@zenon.in.qult.net>
References: <CAHA+R7Pq6aUyCzc2HE+b4RU0RfYnM_cLPfRcV3jLmAZ+dFCsxw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-2
Content-Transfer-Encoding: QUOTED-PRINTABLE
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from [78.193.33.39] ([78.193.33.39]:54071 "EHLO mail.qult.net"
	rhost-flags-FAIL-FAIL-OK-OK) by vger.kernel.org with ESMTP
	id S965959AbbBCSFr (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 3 Feb 2015 13:05:47 -0500
Received: from zenon.in.qult.net ([192.168.64.1] helo=zenon)
	by mail.qult.net with esmtps (TLS1.2:RSA_AES_128_CBC_SHA1:128)
	(Exim 4.82)
	(envelope-from <ignacy.gawedzki@green-communications.fr>)
	id 1YIhqh-0003Va-AA
	for netdev@vger.kernel.org; Tue, 03 Feb 2015 19:05:19 +0100
Received: from ig by zenon with local (Exim 4.84_RC1)
	(envelope-from <ignacy.gawedzki@green-communications.fr>)
	id 1YIhqg-0006sm-FE
	for netdev@vger.kernel.org; Tue, 03 Feb 2015 19:05:18 +0100
Content-Disposition: inline
In-Reply-To: <CAHA+R7Pq6aUyCzc2HE+b4RU0RfYnM_cLPfRcV3jLmAZ+dFCsxw@mail.gmail.com>
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

=46ixes: 33be62715991 ("net_sched: act: use standard struct list_head")
Signed-off-by: Ignacy Gaw=EAdzki <ignacy.gawedzki@green-communications.=
fr>
---
 net/sched/cls_api.c | 7 ++++---
 1 file changed, 4 insertions(+), 3 deletions(-)

diff --git a/net/sched/cls_api.c b/net/sched/cls_api.c
index aad6a67..baef987 100644
--- a/net/sched/cls_api.c
+++ b/net/sched/cls_api.c
@@ -556,8 +556,9 @@ void tcf_exts_change(struct tcf_proto *tp, struct t=
cf_exts *dst,
 }
 EXPORT_SYMBOL(tcf_exts_change);
=20
-#define tcf_exts_first_act(ext) \
-		list_first_entry(&(exts)->actions, struct tc_action, list)
+#define tcf_exts_first_act(ext)					\
+	list_first_entry_or_null(&(exts)->actions,		\
+				 struct tc_action, list)
=20
 int tcf_exts_dump(struct sk_buff *skb, struct tcf_exts *exts)
 {
@@ -603,7 +604,7 @@ int tcf_exts_dump_stats(struct sk_buff *skb, struct=
 tcf_exts *exts)
 {
 #ifdef CONFIG_NET_CLS_ACT
 	struct tc_action *a =3D tcf_exts_first_act(exts);
-	if (tcf_action_copy_stats(skb, a, 1) < 0)
+	if (a !=3D NULL && tcf_action_copy_stats(skb, a, 1) < 0)
 		return -1;
 #endif
 	return 0;
--=20
2.1.0
