From: Ignacy =?iso-8859-2?Q?Gaw=EAdzki?=
	<ignacy.gawedzki@green-communications.fr>
Subject: [PATCH net] ematch: Fix auto-loading of ematch modules.
Date: Mon, 16 Feb 2015 19:13:15 +0100
Message-ID: <20150216181315.GA15280@zenon.in.qult.net>
References: <20150216150329.GB16798@zenon.in.qult.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-2
Content-Transfer-Encoding: QUOTED-PRINTABLE
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from [78.193.33.39] ([78.193.33.39]:58468 "EHLO mail.qult.net"
	rhost-flags-FAIL-FAIL-OK-OK) by vger.kernel.org with ESMTP
	id S1753436AbbBPSNm (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 16 Feb 2015 13:13:42 -0500
Received: from zenon.in.qult.net ([192.168.64.1] helo=zenon)
	by mail.qult.net with esmtps (TLS1.2:RSA_AES_128_CBC_SHA1:128)
	(Exim 4.82)
	(envelope-from <ignacy.gawedzki@green-communications.fr>)
	id 1YNQAW-0007Is-H9
	for netdev@vger.kernel.org; Mon, 16 Feb 2015 19:13:16 +0100
Received: from ig by zenon with local (Exim 4.84_RC1)
	(envelope-from <ignacy.gawedzki@green-communications.fr>)
	id 1YNQAV-00073W-Ef
	for netdev@vger.kernel.org; Mon, 16 Feb 2015 19:13:15 +0100
Content-Disposition: inline
In-Reply-To: <20150216150329.GB16798@zenon.in.qult.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

In tcf_em_validate(), when calling tcf_em_lookup(), don't put the resul=
ting
pointer directly into em->ops, if the function is to possibly return -E=
AGAIN
after module auto-loading.  Otherwise, module_put() will be called by
tcf_em_tree_destroy() on em->ops->owner, while it has already been call=
ed by
tcf_em_validate() before return.

Signed-off-by: Ignacy Gaw=EAdzki <ignacy.gawedzki@green-communications.=
fr>
---
 net/sched/ematch.c | 13 ++++++++-----
 1 file changed, 8 insertions(+), 5 deletions(-)

diff --git a/net/sched/ematch.c b/net/sched/ematch.c
index 6742200..39fbe2f 100644
--- a/net/sched/ematch.c
+++ b/net/sched/ematch.c
@@ -176,6 +176,7 @@ static int tcf_em_validate(struct tcf_proto *tp,
 {
 	int err =3D -EINVAL;
 	struct tcf_ematch_hdr *em_hdr =3D nla_data(nla);
+	struct tcf_ematch_ops *em_ops;
 	int data_len =3D nla_len(nla) - sizeof(*em_hdr);
 	void *data =3D (void *) em_hdr + sizeof(*em_hdr);
 	struct net *net =3D dev_net(qdisc_dev(tp->q));
@@ -213,27 +214,29 @@ static int tcf_em_validate(struct tcf_proto *tp,
 		 * here. Be aware, the destroy function assumes that the
 		 * module is held if the ops field is non zero.
 		 */
-		em->ops =3D tcf_em_lookup(em_hdr->kind);
+		em_ops =3D tcf_em_lookup(em_hdr->kind);
=20
-		if (em->ops =3D=3D NULL) {
+		if (em_ops =3D=3D NULL) {
 			err =3D -ENOENT;
 #ifdef CONFIG_MODULES
 			__rtnl_unlock();
 			request_module("ematch-kind-%u", em_hdr->kind);
 			rtnl_lock();
-			em->ops =3D tcf_em_lookup(em_hdr->kind);
-			if (em->ops) {
+			em_ops =3D tcf_em_lookup(em_hdr->kind);
+			if (em_ops) {
 				/* We dropped the RTNL mutex in order to
 				 * perform the module load. Tell the caller
 				 * to replay the request.
 				 */
-				module_put(em->ops->owner);
+				module_put(em_ops->owner);
 				err =3D -EAGAIN;
 			}
 #endif
 			goto errout;
 		}
=20
+		em->ops =3D em_ops;
+
 		/* ematch module provides expected length of data, so we
 		 * can do a basic sanity check.
 		 */
--=20
2.1.0
