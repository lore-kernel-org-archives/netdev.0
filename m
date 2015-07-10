From: ebiederm@xmission.com (Eric W. Biederman)
Subject: [PATCH -next 2/6] netfilter: kill nf_hooks_active
Date: Fri, 10 Jul 2015 18:13:20 -0500
Message-ID: <87wpy7r4hb.fsf_-_@x220.int.ebiederm.org>
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
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <878uansj4d.fsf_-_@x220.int.ebiederm.org> (Eric W. Biederman's
	message of "Fri, 10 Jul 2015 18:11:46 -0500")
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


The function obscures what is going on in nf_hook_thresh and it's existence
requires computing the hook list twice.

Signed-off-by: "Eric W. Biederman" <ebiederm@xmission.com>
---
 include/linux/netfilter.h | 10 +++-------
 1 file changed, 3 insertions(+), 7 deletions(-)

diff --git a/include/linux/netfilter.h b/include/linux/netfilter.h
index 00050dfd9f23..d7826e59779e 100644
--- a/include/linux/netfilter.h
+++ b/include/linux/netfilter.h
@@ -150,11 +150,6 @@ static inline bool nf_hook_list_active(struct list_head *nf_hook_list,
 }
 #endif
 
-static inline bool nf_hooks_active(u_int8_t pf, unsigned int hook)
-{
-	return nf_hook_list_active(&nf_hooks[pf][hook], pf, hook);
-}
-
 int nf_hook_slow(struct sk_buff *skb, struct nf_hook_state *state);
 
 /**
@@ -172,10 +167,11 @@ static inline int nf_hook_thresh(u_int8_t pf, unsigned int hook,
 				 int (*okfn)(struct sock *, struct sk_buff *),
 				 int thresh)
 {
-	if (nf_hooks_active(pf, hook)) {
+	struct list_head *nf_hook_list = &nf_hooks[pf][hook];
+	if (nf_hook_list_active(nf_hook_list, pf, hook)) {
 		struct nf_hook_state state;
 
-		nf_hook_state_init(&state, &nf_hooks[pf][hook], hook, thresh,
+		nf_hook_state_init(&state, nf_hook_list, hook, thresh,
 				   pf, indev, outdev, sk, okfn);
 		return nf_hook_slow(skb, &state);
 	}
-- 
2.2.1

