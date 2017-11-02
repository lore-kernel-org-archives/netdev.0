From: Steffen Klassert <steffen.klassert@secunet.com>
Subject: Re: KASAN: stack-out-of-bounds Read in xfrm_state_find (2)
Date: Thu, 2 Nov 2017 11:32:37 +0100
Message-ID: <20171102103237.GL11292@secunet.com>
References: <20171101220608.GA9424@breakpoint.cc>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: syzbot
        <bot+19b21aa652248382e2b8cbb81fa1cdc03b4bda01@syzkaller.appspotmail.com>,
        <davem@davemloft.net>, <herbert@gondor.apana.org.au>,
        <linux-kernel@vger.kernel.org>, <netdev@vger.kernel.org>,
        <syzkaller-bugs@googlegroups.com>, <thomas.egerer@secunet.com>
To: Florian Westphal <fw@strlen.de>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20171101220608.GA9424@breakpoint.cc>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, Nov 01, 2017 at 11:06:08PM +0100, Florian Westphal wrote:
> syzbot <bot+19b21aa652248382e2b8cbb81fa1cdc03b4bda01@syzkaller.appspotmail.com> wrote:
> 
> [ cc Thomas Egerer ]
> 
> > syzkaller hit the following crash on
> > 36ef71cae353f88fd6e095e2aaa3e5953af1685d
> > git://git.kernel.org/pub/scm/linux/kernel/git/next/linux-next.git/master
> > compiler: gcc (GCC) 7.1.1 20170620
> > .config is attached
> > Raw console output is attached.
> > C reproducer is attached
> > syzkaller reproducer is attached. See https://goo.gl/kgGztJ
> > for information about syzkaller reproducers
> > 
> > BUG: KASAN: stack-out-of-bounds in xfrm_state_find+0x303d/0x3170
> > net/xfrm/xfrm_state.c:1051
> > Read of size 4 at addr ffff88003adb7760 by task syzkaller429801/2969
> 
> Seems this was added in
> commit 8444cf712c5f71845cba9dc30d8f530ff0d5ff83
> ("xfrm: Allow different selector family in temporary state").
> 
> No idea how to fix this:
> 
> struct xfrm_state *
> xfrm_state_find(const xfrm_address_t *daddr, const xfrm_address_t *saddr,
>                 const struct flowi *fl, struct xfrm_tmpl *tmpl,
>                 struct xfrm_policy *pol, int *err,
>                 unsigned short family)	// AF_INET
> {
> [..]
>         unsigned short encap_family = tmpl->encap_family; // AF_INET6
> [..]
>         h = xfrm_dst_hash(net, daddr, saddr, tmpl->reqid, encap_family);
> 
> saddr, daddr point to ipv4 addresses inside an on-stack flowi4 struct,
> i.e. they get hashed as ipv6 addresses which then results in invalid stack access.

This looks like yet another IPv4 mapped IPv6 address + socket policy bug.

> 
> What is this supposed to do if family != encap_family?

This is the case for interfamily tunnels. Here family is the
address family of the inner packet and encap_family is the
address family for the outer one.

> 
> I also don't understand how address comparision is supposed to work in this case,
> it seems that if saddr/daddr are v4 and template v6 we compare full ipv6 addresses
> (how would that succeed...?) and, if saddr/daddr is v6 add template is v4 we just
> compare the first 32bit of the ipv6 addresses...?

When we do tunnel or beet mode, we pass saddr and daddr from the
template to xfrm_state_find(), this should be ok. On transport
mode, we pass the addresses from the flowi, assuming that the
IP addresses (and address family) don't change during transformation.
This assumption is wrong in the IPv4 mapped IPv6 case, packet
is IPv4 and template is IPv6.

I'd propose to use the addresses from the template unconditionally,
like the (untested) patch below does.

Unfortunalely the reproducer does not work with my config,
sendto returns EAGAIN. Could anybody try this patch?


---
 net/xfrm/xfrm_policy.c | 29 +++++++++++------------------
 1 file changed, 11 insertions(+), 18 deletions(-)

diff --git a/net/xfrm/xfrm_policy.c b/net/xfrm/xfrm_policy.c
index 4838329..450bdff 100644
--- a/net/xfrm/xfrm_policy.c
+++ b/net/xfrm/xfrm_policy.c
@@ -1360,36 +1360,29 @@ xfrm_tmpl_resolve_one(struct xfrm_policy *policy, const struct flowi *fl,
 	struct net *net = xp_net(policy);
 	int nx;
 	int i, error;
-	xfrm_address_t *daddr = xfrm_flowi_daddr(fl, family);
-	xfrm_address_t *saddr = xfrm_flowi_saddr(fl, family);
 	xfrm_address_t tmp;
 
 	for (nx = 0, i = 0; i < policy->xfrm_nr; i++) {
 		struct xfrm_state *x;
-		xfrm_address_t *remote = daddr;
-		xfrm_address_t *local  = saddr;
+		xfrm_address_t *local;
+		xfrm_address_t *remote;
 		struct xfrm_tmpl *tmpl = &policy->xfrm_vec[i];
 
-		if (tmpl->mode == XFRM_MODE_TUNNEL ||
-		    tmpl->mode == XFRM_MODE_BEET) {
-			remote = &tmpl->id.daddr;
-			local = &tmpl->saddr;
-			if (xfrm_addr_any(local, tmpl->encap_family)) {
-				error = xfrm_get_saddr(net, fl->flowi_oif,
-						       &tmp, remote,
-						       tmpl->encap_family, 0);
-				if (error)
-					goto fail;
-				local = &tmp;
-			}
+		remote = &tmpl->id.daddr;
+		local = &tmpl->saddr;
+		if (xfrm_addr_any(local, tmpl->encap_family)) {
+			error = xfrm_get_saddr(net, fl->flowi_oif,
+					       &tmp, remote,
+					       tmpl->encap_family, 0);
+			if (error)
+				goto fail;
+			local = &tmp;
 		}
 
 		x = xfrm_state_find(remote, local, fl, tmpl, policy, &error, family);
 
 		if (x && x->km.state == XFRM_STATE_VALID) {
 			xfrm[nx++] = x;
-			daddr = remote;
-			saddr = local;
 			continue;
 		}
 		if (x) {
-- 
2.7.4
