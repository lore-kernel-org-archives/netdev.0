From: Florian Westphal <fw@strlen.de>
Subject: Re: KASAN: stack-out-of-bounds Read in xfrm_state_find (2)
Date: Wed, 1 Nov 2017 23:06:08 +0100
Message-ID: <20171101220608.GA9424@breakpoint.cc>
References: <001a1141c71c4ce4b3055cef6ea2@google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: davem@davemloft.net, herbert@gondor.apana.org.au,
        linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
        steffen.klassert@secunet.com, syzkaller-bugs@googlegroups.com,
        thomas.egerer@secunet.com
To: syzbot
        <bot+19b21aa652248382e2b8cbb81fa1cdc03b4bda01@syzkaller.appspotmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <001a1141c71c4ce4b3055cef6ea2@google.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

syzbot <bot+19b21aa652248382e2b8cbb81fa1cdc03b4bda01@syzkaller.appspotmail.com> wrote:

[ cc Thomas Egerer ]

> syzkaller hit the following crash on
> 36ef71cae353f88fd6e095e2aaa3e5953af1685d
> git://git.kernel.org/pub/scm/linux/kernel/git/next/linux-next.git/master
> compiler: gcc (GCC) 7.1.1 20170620
> .config is attached
> Raw console output is attached.
> C reproducer is attached
> syzkaller reproducer is attached. See https://goo.gl/kgGztJ
> for information about syzkaller reproducers
> 
> BUG: KASAN: stack-out-of-bounds in xfrm_state_find+0x303d/0x3170
> net/xfrm/xfrm_state.c:1051
> Read of size 4 at addr ffff88003adb7760 by task syzkaller429801/2969

Seems this was added in
commit 8444cf712c5f71845cba9dc30d8f530ff0d5ff83
("xfrm: Allow different selector family in temporary state").

No idea how to fix this:

struct xfrm_state *
xfrm_state_find(const xfrm_address_t *daddr, const xfrm_address_t *saddr,
                const struct flowi *fl, struct xfrm_tmpl *tmpl,
                struct xfrm_policy *pol, int *err,
                unsigned short family)	// AF_INET
{
[..]
        unsigned short encap_family = tmpl->encap_family; // AF_INET6
[..]
        h = xfrm_dst_hash(net, daddr, saddr, tmpl->reqid, encap_family);

saddr, daddr point to ipv4 addresses inside an on-stack flowi4 struct,
i.e. they get hashed as ipv6 addresses which then results in invalid stack access.

What is this supposed to do if family != encap_family?

I also don't understand how address comparision is supposed to work in this case,
it seems that if saddr/daddr are v4 and template v6 we compare full ipv6 addresses
(how would that succeed...?) and, if saddr/daddr is v6 add template is v4 we just
compare the first 32bit of the ipv6 addresses...?

This fix silences the reproducer, but I am not sure about it, it looks like it
papers over the real problem...

diff --git a/net/xfrm/xfrm_policy.c b/net/xfrm/xfrm_policy.c
--- a/net/xfrm/xfrm_policy.c
+++ b/net/xfrm/xfrm_policy.c
@@ -1359,16 +1359,19 @@ xfrm_tmpl_resolve_one(struct xfrm_policy *policy, const struct flowi *fl,
 		      struct xfrm_state **xfrm, unsigned short family)
 {
 	struct net *net = xp_net(policy);
+	xfrm_address_t tmp, daddr, saddr;
 	int nx;
 	int i, error;
-	xfrm_address_t *daddr = xfrm_flowi_daddr(fl, family);
-	xfrm_address_t *saddr = xfrm_flowi_saddr(fl, family);
-	xfrm_address_t tmp;
+
+	memset(&saddr, 0, sizeof(saddr));
+	memset(&daddr, 0, sizeof(daddr));
+
+	xfrm_flowi_addr_get(fl, &saddr, &daddr, family);
 
 	for (nx = 0, i = 0; i < policy->xfrm_nr; i++) {
 		struct xfrm_state *x;
-		xfrm_address_t *remote = daddr;
-		xfrm_address_t *local  = saddr;
+		xfrm_address_t *remote = &daddr;
+		xfrm_address_t *local  = &saddr;
 		struct xfrm_tmpl *tmpl = &policy->xfrm_vec[i];
 
 		if (tmpl->mode == XFRM_MODE_TUNNEL ||
@@ -1389,8 +1392,8 @@ xfrm_tmpl_resolve_one(struct xfrm_policy *policy, const struct flowi *fl,
 
 		if (x && x->km.state == XFRM_STATE_VALID) {
 			xfrm[nx++] = x;
-			daddr = remote;
-			saddr = local;
+			daddr = *remote;
+			saddr = *local;
 			continue;
 		}
 		if (x) {
