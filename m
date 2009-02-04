From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: [PATCH 1/3] net: Partially allow skb destructors to be used on receive path
Date: Wed, 04 Feb 2009 21:49:22 +1100
Message-ID: <E1LUfJq-0005Z8-SW@gondolin.me.apana.org.au>
References: <20090204104825.GA21257@gondor.apana.org.au>
To: "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhun.apana.org.au ([64.62.148.172]:59760 "EHLO
	arnor.apana.org.au" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1751771AbZBDKtZ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 4 Feb 2009 05:49:25 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

net: Partially allow skb destructors to be used on receive path

As it currently stands, skb destructors are forbidden on the
receive path because the protocol end-points will overwrite
any existing destructor with their own.

This is the reason why we have to call skb_orphan in the loopback
driver before we reinject the packet back into the stack, thus
creating a period during which loopback traffic isn't charged
to any socket.

With virtualisation, we have a similar problem in that traffic
is reinjected into the stack without being associated with any
socket entity, thus providing no natural congestion push-back
for those poor folks still stuck with UDP.

Now had we been consistent in telling them that UDP simply has
no congestion feedback, I could just fob them off.  Unfortunately,
we appear to have gone to some length in catering for this on
the standard UDP path, with skb/socket accounting so that has
created a very unhealthy dependency.

Alas habits are difficult to break out of, so we may just have
to allow skb destructors on the receive path.

It turns out that making skb destructors useable on the receive path
isn't as easy as it seems.  For instance, simply adding skb_orphan
to skb_set_owner_r isn't enough.  This is because we assume all
over the IP stack that skb->sk is an IP socket if present.

The new transparent proxy code goes one step further and assumes
that skb->sk is the receiving socket if present.

Now all of this can be dealt with by adding simple checks such
as only treating skb->sk as an IP socket if skb->sk->sk_family
matches.  However, it turns out that for bridging at least we
don't need to do all of this work.

This is of interest because most virtualisation setups use bridging
so we don't actually go through the IP stack on the host (with
the exception of our old nemesis the bridge netfilter, but that's
easily taken care of).

So this patch simply adds skb_orphan to the point just before we
enter the IP stack, but after we've gone through the bridge on the
receive path.  It also adds an skb_orphan to the one place in
netfilter that touches skb->sk/skb->destructor, that is, tproxy.

One word of caution, because of the internal code structure, anyone
wishing to deploy this must use skb_set_owner_w as opposed to
skb_set_owner_r since many functions that create a new skb from
an existing one will invoke skb_set_owner_w on the new skb.

Signed-off-by: Herbert Xu <herbert@gondor.apana.org.au>
---

 net/core/dev.c                 |    2 ++
 net/netfilter/nf_tproxy_core.c |    1 +
 2 files changed, 3 insertions(+)

diff --git a/net/core/dev.c b/net/core/dev.c
index dab3aed..45f9292 100644
--- a/net/core/dev.c
+++ b/net/core/dev.c
@@ -2318,6 +2318,8 @@ ncls:
 	if (!skb)
 		goto out;
 
+	skb_orphan(skb);
+
 	type = skb->protocol;
 	list_for_each_entry_rcu(ptype,
 			&ptype_base[ntohs(type) & PTYPE_HASH_MASK], list) {
diff --git a/net/netfilter/nf_tproxy_core.c b/net/netfilter/nf_tproxy_core.c
index cdc97f3..5490fc3 100644
--- a/net/netfilter/nf_tproxy_core.c
+++ b/net/netfilter/nf_tproxy_core.c
@@ -71,6 +71,7 @@ int
 nf_tproxy_assign_sock(struct sk_buff *skb, struct sock *sk)
 {
 	if (inet_sk(sk)->transparent) {
+		skb_orphan(skb);
 		skb->sk = sk;
 		skb->destructor = nf_tproxy_destructor;
 		return 1;
