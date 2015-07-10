From: ebiederm@xmission.com (Eric W. Biederman)
Subject: [PATCH -next 4/6] netfilter: Factor out the hook list selection from nf_register_hook
Date: Fri, 10 Jul 2015 18:14:30 -0500
Message-ID: <87lhenr4fd.fsf_-_@x220.int.ebiederm.org>
References: <87616ppt3h.fsf@x220.int.ebiederm.org>
	<87r3pae5hn.fsf@x220.int.ebiederm.org>
	<878uansj4d.fsf_-_@x220.int.ebiederm.org>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <netdev@vger.kernel.org>, <netfilter-devel@vger.kernel.org>,
	Stephen Hemminger <stephen@networkplumber.org>,
	Juanjo Ciarlante <jjciarla@raiz.uncu.edu.ar>,
	Wensong Zhang <wensong@linux-vs.org>,
	Simon Horman <horms@verge.net.au>,
	Julian Anastasov <ja@ssi.bg>,
	Patrick McHardy <kaber@trash.net>,
	Jozsef Kadlecsik <kadlec@blackhole.kfki.hu>,
	Jamal Hadi Salim <jhs@mojatatu.com>,
	Steffen Klassert <steffen.klassert@secunet.com>,
	Herbert Xu <herbert@gondor.apana.org.au>,
	David Miller <davem@davemloft.net>
To: Pablo Neira Ayuso <pablo@netfilter.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from out01.mta.xmission.com ([166.70.13.231]:55467 "EHLO
	out01.mta.xmission.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753115AbbGJXUK (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 10 Jul 2015 19:20:10 -0400
In-Reply-To: <878uansj4d.fsf_-_@x220.int.ebiederm.org> (Eric W. Biederman's
	message of "Fri, 10 Jul 2015 18:11:46 -0500")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


- Add a new function find_nf_hook_list to select the nf_hook_list

- Fail nf_register_hook when asked for a per netdevice hook list when
  support for per netdevice hook lists is not built into the kernel.

- Move the hook list head selection outside of nf_hook_mutex as
  nothing in the selection requires the hook list, and error handling
  is simpler if a mutex is not held.

Signed-off-by: "Eric W. Biederman" <ebiederm@xmission.com>
---
 net/netfilter/core.c | 32 ++++++++++++++++++--------------
 1 file changed, 18 insertions(+), 14 deletions(-)

diff --git a/net/netfilter/core.c b/net/netfilter/core.c
index 7e3bc12f1c62..8bbcdfcdbfbd 100644
--- a/net/netfilter/core.c
+++ b/net/netfilter/core.c
@@ -62,27 +62,31 @@ EXPORT_SYMBOL(nf_hooks_needed);
 
 static DEFINE_MUTEX(nf_hook_mutex);
 
-int nf_register_hook(struct nf_hook_ops *reg)
+static struct list_head *find_nf_hook_list(const struct nf_hook_ops *reg)
 {
-	struct list_head *nf_hook_list;
-	struct nf_hook_ops *elem;
+	struct list_head *nf_hook_list = NULL;
 
-	mutex_lock(&nf_hook_mutex);
-	switch (reg->pf) {
-	case NFPROTO_NETDEV:
+	if (reg->pf != NFPROTO_NETDEV)
+		nf_hook_list = &nf_hooks[reg->pf][reg->hooknum];
+	else if (reg->hooknum == NF_NETDEV_INGRESS) {
 #ifdef CONFIG_NETFILTER_INGRESS
-		if (reg->hooknum == NF_NETDEV_INGRESS) {
-			BUG_ON(reg->dev == NULL);
+		if (reg->dev)
 			nf_hook_list = &reg->dev->nf_hooks_ingress;
-			break;
-		}
 #endif
-		/* Fall through. */
-	default:
-		nf_hook_list = &nf_hooks[reg->pf][reg->hooknum];
-		break;
 	}
+	return nf_hook_list;
+}
+
+int nf_register_hook(struct nf_hook_ops *reg)
+{
+	struct list_head *nf_hook_list;
+	struct nf_hook_ops *elem;
 
+	nf_hook_list = find_nf_hook_list(reg);
+	if (!nf_hook_list)
+		return -ENOENT;
+
+	mutex_lock(&nf_hook_mutex);
 	list_for_each_entry(elem, nf_hook_list, list) {
 		if (reg->priority < elem->priority)
 			break;
-- 
2.2.1
