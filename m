From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: Fwd: Netlink XFRM socket subsystem NULL pointer dereference
Date: Thu, 19 Oct 2017 17:57:04 +0800
Message-ID: <20171019095704.GA13459@gondor.apana.org.au>
References: <CAHqykcSO0vQvh0uXwDNgXr0ZpP8m4AGZ=ks9FNshJZw0=GWHpw@mail.gmail.com>
 <CANn89iLBO2RzqMzb61Qn=HFncsfYLnXLcUfSqFsDTPakQ2o4FQ@mail.gmail.com>
 <20171017061832.GA3323@secunet.com>
 <CANn89iJmtPQ=HV6xLjTaLS6WnVmiN+PgaObmWWnevcEzLitRTQ@mail.gmail.com>
 <20171018151159.GA5188@gondor.apana.org.au>
 <CANn89iL_QRZUTDXdci+Nsn=oM471N4r6im0zLgHkJANx_X6wbQ@mail.gmail.com>
 <20171019092625.GA12863@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Steffen Klassert <steffen.klassert@secunet.com>,
        Timo Teras <timo.teras@iki.fi>, netdev@vger.kernel.org
To: Eric Dumazet <edumazet@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from orcrist.hmeau.com ([104.223.48.154]:46126 "EHLO
        deadmen.hmeau.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751348AbdJSJ5f (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 19 Oct 2017 05:57:35 -0400
Content-Disposition: inline
In-Reply-To: <20171019092625.GA12863@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Oct 19, 2017 at 05:26:25PM +0800, Herbert Xu wrote:
>
> So it's an netlink API issue.  It is possible for cb->done to be
> called without cb->dump ever being called.  And xfrm_user doesn't
> deal with that.  Let me survey the others to see whether we should
> fix this in netlink, xfrm, or both.

OK it looks like an XFRM bug pure and simple.  Funnily enough
the xfrm sa dump code which got changed by the same commit that
added this bug isn't buggy.

---8<---
Subject: ipsec: Fix aborted xfrm policy dump crash

An independent security researcher, Mohamed Ghannam, has reported
this vulnerability to Beyond Security's SecuriTeam Secure Disclosure
program.

The xfrm_dump_policy_done function expects xfrm_dump_policy to
have been called at least once or it will crash.  This can be
triggered if a dump fails because the target socket's receive
buffer is full.

This patch fixes it by using the cb->start mechanism to ensure that
the initialisation is always done regardless of the buffer situation.

Fixes: 4c563f7669c1 ("[XFRM]: Speed up xfrm_policy and xfrm_state...")
Signed-off-by: Herbert Xu <herbert@gondor.apana.org.au>

diff --git a/net/xfrm/xfrm_user.c b/net/xfrm/xfrm_user.c
index 2bfbd91..98a6d65 100644
--- a/net/xfrm/xfrm_user.c
+++ b/net/xfrm/xfrm_user.c
@@ -1692,32 +1692,34 @@ static int dump_one_policy(struct xfrm_policy *xp, int dir, int count, void *ptr
 
 static int xfrm_dump_policy_done(struct netlink_callback *cb)
 {
-	struct xfrm_policy_walk *walk = (struct xfrm_policy_walk *) &cb->args[1];
+	struct xfrm_policy_walk *walk = (struct xfrm_policy_walk *)cb->args;
 	struct net *net = sock_net(cb->skb->sk);
 
 	xfrm_policy_walk_done(walk, net);
 	return 0;
 }
 
+static int xfrm_dump_policy_start(struct netlink_callback *cb)
+{
+	struct xfrm_policy_walk *walk = (struct xfrm_policy_walk *)cb->args;
+
+	BUILD_BUG_ON(sizeof(*walk) > sizeof(cb->args));
+
+	xfrm_policy_walk_init(walk, XFRM_POLICY_TYPE_ANY);
+	return 0;
+}
+
 static int xfrm_dump_policy(struct sk_buff *skb, struct netlink_callback *cb)
 {
 	struct net *net = sock_net(skb->sk);
-	struct xfrm_policy_walk *walk = (struct xfrm_policy_walk *) &cb->args[1];
+	struct xfrm_policy_walk *walk = (struct xfrm_policy_walk *)cb->args;
 	struct xfrm_dump_info info;
 
-	BUILD_BUG_ON(sizeof(struct xfrm_policy_walk) >
-		     sizeof(cb->args) - sizeof(cb->args[0]));
-
 	info.in_skb = cb->skb;
 	info.out_skb = skb;
 	info.nlmsg_seq = cb->nlh->nlmsg_seq;
 	info.nlmsg_flags = NLM_F_MULTI;
 
-	if (!cb->args[0]) {
-		cb->args[0] = 1;
-		xfrm_policy_walk_init(walk, XFRM_POLICY_TYPE_ANY);
-	}
-
 	(void) xfrm_policy_walk(net, walk, dump_one_policy, &info);
 
 	return skb->len;
@@ -2473,6 +2475,7 @@ static int xfrm_send_migrate(const struct xfrm_selector *sel, u8 dir, u8 type,
 
 static const struct xfrm_link {
 	int (*doit)(struct sk_buff *, struct nlmsghdr *, struct nlattr **);
+	int (*start)(struct netlink_callback *);
 	int (*dump)(struct sk_buff *, struct netlink_callback *);
 	int (*done)(struct netlink_callback *);
 	const struct nla_policy *nla_pol;
@@ -2486,6 +2489,7 @@ static int xfrm_send_migrate(const struct xfrm_selector *sel, u8 dir, u8 type,
 	[XFRM_MSG_NEWPOLICY   - XFRM_MSG_BASE] = { .doit = xfrm_add_policy    },
 	[XFRM_MSG_DELPOLICY   - XFRM_MSG_BASE] = { .doit = xfrm_get_policy    },
 	[XFRM_MSG_GETPOLICY   - XFRM_MSG_BASE] = { .doit = xfrm_get_policy,
+						   .start = xfrm_dump_policy_start,
 						   .dump = xfrm_dump_policy,
 						   .done = xfrm_dump_policy_done },
 	[XFRM_MSG_ALLOCSPI    - XFRM_MSG_BASE] = { .doit = xfrm_alloc_userspi },
@@ -2538,6 +2542,7 @@ static int xfrm_user_rcv_msg(struct sk_buff *skb, struct nlmsghdr *nlh,
 
 		{
 			struct netlink_dump_control c = {
+				.start = link->start,
 				.dump = link->dump,
 				.done = link->done,
 			};
-- 
Email: Herbert Xu <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
