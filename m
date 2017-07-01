From: Florian Westphal <fw@strlen.de>
Subject: Re: nf_conntrack: Infoleak via CTA_ID and CTA_EXPECT_ID
Date: Sat, 1 Jul 2017 12:35:04 +0200
Message-ID: <20170701103504.GO9307@breakpoint.cc>
References: <c84e0301-2bb6-8932-2ed5-939340762159@nod.at>
 <20170630193544.GM9307@breakpoint.cc>
 <f3d78dc5-7694-8e01-ac4d-54fc248a96f1@nod.at>
 <20170630195547.GN9307@breakpoint.cc>
 <ad87cf0f-2ff4-48d7-b53c-bc4b5e98cfca@nod.at>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Florian Westphal <fw@strlen.de>,
        "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
        Pablo Neira Ayuso <pablo@netfilter.org>,
        David Miller <davem@davemloft.net>,
        netfilter-devel@vger.kernel.org, coreteam@netfilter.org,
        "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
        David Gstir <david@sigma-star.at>, kaber@trash.net,
        "keescook@chromium.org" <keescook@chromium.org>
To: Richard Weinberger <richard@nod.at>
Return-path: <netfilter-devel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <ad87cf0f-2ff4-48d7-b53c-bc4b5e98cfca@nod.at>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Richard Weinberger <richard@nod.at> wrote:
> Florian,
> 
> Am 30.06.2017 um 21:55 schrieb Florian Westphal:
> >>> Why not use a hash of the address?
> >>
> >> Would also work. Or xor it with a random number.
> >>
> >> On the other hand, for user space it would be more useful when the conntrack id
> >> does not repeat that often. That's why I favor the good old counter method.
> >> Currently the conntrack id is reused very fast.
> >> e.g. in one of our applications we use the conntack id via NFQUEUE and watch the
> >> destroy events via conntrack. It happens regularly that a new connection has the
> >> same id than a different connection we saw some moments before, before we receive
> >> the destroy event from the conntrack socket.
> > 
> > Perhaps we can place that in a new extension (its not needed in any
> > fastpath ops)?
> 
> To get rid of the infoleak we have to re-introduce the id field in struct nf_conn
> and struct nf_conntrack_expect.

Why will this not work?

> Otherwise have nothing to compare against in the conntrack/expect remove case.

Not following, sorry.  The id is not used anywhere except when we send
info to userspace.

The compare on removal is not needed afaics, and its also not used when
doing lookup to begin with, so we can just recompute it?

diff --git a/net/netfilter/nf_conntrack_netlink.c b/net/netfilter/nf_conntrack_netlink.c
--- a/net/netfilter/nf_conntrack_netlink.c
+++ b/net/netfilter/nf_conntrack_netlink.c
@@ -25,6 +25,7 @@
 #include <linux/security.h>
 #include <linux/skbuff.h>
 #include <linux/errno.h>
+#include <linux/hash.h>
 #include <linux/netlink.h>
 #include <linux/spinlock.h>
 #include <linux/interrupt.h>
@@ -443,9 +444,44 @@ static int ctnetlink_dump_ct_seq_adj(struct sk_buff *skb, struct nf_conn *ct)
 	return -1;
 }
 
+static __be32 ct_to_id(const struct nf_conn *ct)
+{
+	static u32 seed __read_mostly;
+	u32 a, b, c;
+
+	if (!ct)
+		return 0;
+
+	if (!seed)
+		seed = get_random_u32();
+
+	a = jhash2((u32 *)ct->tuplehash, sizeof(ct->tuplehash) / sizeof(u32),
+		   hash32_ptr(ct));
+	b = ct_to_id(ct->master) ^ net_hash_mix(nf_ct_net(ct));
+	c = hash32_ptr(ct->ext);
+
+	return (__force __be32)jhash_3words(a, b, c, seed);
+}
+
+static __be32 ctexp_to_id(const struct nf_conntrack_expect *exp)
+{
+	static u32 seed __read_mostly;
+	u32 a, b, c;
+
+	if (!seed)
+		seed = get_random_u32();
+
+	a = ct_to_id(exp->master);
+	b = hash32_ptr(exp->helper);
+	c = jhash2((u32 *)&exp->tuple, sizeof(exp->tuple) / sizeof(u32),
+		   hash32_ptr(exp));
+
+	return (__force __be32)jhash_3words(a, b, c, seed);
+}
+
 static int ctnetlink_dump_id(struct sk_buff *skb, const struct nf_conn *ct)
 {
-	if (nla_put_be32(skb, CTA_ID, htonl((unsigned long)ct)))
+	if (nla_put_be32(skb, CTA_ID, ct_to_id(ct)))
 		goto nla_put_failure;
 	return 0;
 
@@ -1164,8 +1200,8 @@ static int ctnetlink_del_conntrack(struct net *net, struct sock *ctnl,
 	ct = nf_ct_tuplehash_to_ctrack(h);
 
 	if (cda[CTA_ID]) {
-		u_int32_t id = ntohl(nla_get_be32(cda[CTA_ID]));
-		if (id != (u32)(unsigned long)ct) {
+		__be32 id = nla_get_be32(cda[CTA_ID]);
+		if (id != ct_to_id(ct)) {
 			nf_ct_put(ct);
 			return -ENOENT;
 		}
@@ -2563,7 +2599,7 @@ ctnetlink_exp_dump_expect(struct sk_buff *skb,
 	}
 #endif
 	if (nla_put_be32(skb, CTA_EXPECT_TIMEOUT, htonl(timeout)) ||
-	    nla_put_be32(skb, CTA_EXPECT_ID, htonl((unsigned long)exp)) ||
+	    nla_put_be32(skb, CTA_EXPECT_ID, ctexp_to_id(exp)) ||
 	    nla_put_be32(skb, CTA_EXPECT_FLAGS, htonl(exp->flags)) ||
 	    nla_put_be32(skb, CTA_EXPECT_CLASS, htonl(exp->class)))
 		goto nla_put_failure;
@@ -2871,7 +2907,7 @@ static int ctnetlink_get_expect(struct net *net, struct sock *ctnl,
 
 	if (cda[CTA_EXPECT_ID]) {
 		__be32 id = nla_get_be32(cda[CTA_EXPECT_ID]);
-		if (ntohl(id) != (u32)(unsigned long)exp) {
+		if (id != ctexp_to_id(exp)) {
 			nf_ct_expect_put(exp);
 			return -ENOENT;
 		}
