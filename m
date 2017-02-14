From: Steffen Klassert <steffen.klassert@secunet.com>
Subject: Re: net/xfrm: stack out-of-bounds in xfrm_flowi_sport
Date: Tue, 14 Feb 2017 08:08:54 +0100
Message-ID: <20170214070854.GH30338@gauss.secunet.com>
References: <CACT4Y+ZBY+gYUJ9NuxPByEbbrR7M09vBd5Lx4=xGSGXSxai==Q@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: Herbert Xu <herbert@gondor.apana.org.au>,
        David Miller <davem@davemloft.net>,
        Eric Dumazet <edumazet@google.com>,
        netdev <netdev@vger.kernel.org>,
        LKML <linux-kernel@vger.kernel.org>,
        syzkaller <syzkaller@googlegroups.com>
To: Dmitry Vyukov <dvyukov@google.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <CACT4Y+ZBY+gYUJ9NuxPByEbbrR7M09vBd5Lx4=xGSGXSxai==Q@mail.gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, Feb 13, 2017 at 03:46:56PM +0100, Dmitry Vyukov wrote:
> 
> On commit 7089db84e356562f8ba737c29e472cc42d530dbc.
> 
> 
> struct flowi4 fl4_stack allocated on stack in udp_sendmsg is being
> casted to larger struct flowi and then accessed.

Looks like the problem is when using IPv4-mapped IPv6 addresses.

Does the patch below help?


Subject: [PATCH RFC ipsec] xfrm: Don't use sk_family for socket policy lookups

On IPv4-mapped IPv6 addresses sk_family is AF_INET6,
but the flow informations are created based on AF_INET.
So the routing set up 'struct flowi4' but we try to
access 'struct flowi6' what leads to an out of bounds
access. Fix this by using the family we get with the
dst_entry, like we do it for the standard policy lookup.

Reported-by: Dmitry Vyukov <dvyukov@google.com>
Signed-off-by: Steffen Klassert <steffen.klassert@secunet.com>
---
 net/xfrm/xfrm_policy.c | 9 ++++-----
 1 file changed, 4 insertions(+), 5 deletions(-)

diff --git a/net/xfrm/xfrm_policy.c b/net/xfrm/xfrm_policy.c
index b5e665b..4891b7b 100644
--- a/net/xfrm/xfrm_policy.c
+++ b/net/xfrm/xfrm_policy.c
@@ -1216,7 +1216,7 @@ static inline int policy_to_flow_dir(int dir)
 }
 
 static struct xfrm_policy *xfrm_sk_policy_lookup(const struct sock *sk, int dir,
-						 const struct flowi *fl)
+						 const struct flowi *fl, u16 family)
 {
 	struct xfrm_policy *pol;
 	struct net *net = sock_net(sk);
@@ -1225,8 +1225,7 @@ static struct xfrm_policy *xfrm_sk_policy_lookup(const struct sock *sk, int dir,
 	read_lock_bh(&net->xfrm.xfrm_policy_lock);
 	pol = rcu_dereference(sk->sk_policy[dir]);
 	if (pol != NULL) {
-		bool match = xfrm_selector_match(&pol->selector, fl,
-						 sk->sk_family);
+		bool match = xfrm_selector_match(&pol->selector, fl, family);
 		int err = 0;
 
 		if (match) {
@@ -2221,7 +2220,7 @@ struct dst_entry *xfrm_lookup(struct net *net, struct dst_entry *dst_orig,
 	sk = sk_const_to_full_sk(sk);
 	if (sk && sk->sk_policy[XFRM_POLICY_OUT]) {
 		num_pols = 1;
-		pols[0] = xfrm_sk_policy_lookup(sk, XFRM_POLICY_OUT, fl);
+		pols[0] = xfrm_sk_policy_lookup(sk, XFRM_POLICY_OUT, fl, family);
 		err = xfrm_expand_policies(fl, family, pols,
 					   &num_pols, &num_xfrms);
 		if (err < 0)
@@ -2500,7 +2499,7 @@ int __xfrm_policy_check(struct sock *sk, int dir, struct sk_buff *skb,
 	pol = NULL;
 	sk = sk_to_full_sk(sk);
 	if (sk && sk->sk_policy[dir]) {
-		pol = xfrm_sk_policy_lookup(sk, dir, &fl);
+		pol = xfrm_sk_policy_lookup(sk, dir, &fl, family);
 		if (IS_ERR(pol)) {
 			XFRM_INC_STATS(net, LINUX_MIB_XFRMINPOLERROR);
 			return 0;
-- 
1.9.1
