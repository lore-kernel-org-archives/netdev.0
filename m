From: Steffen Klassert <steffen.klassert@secunet.com>
Subject: Re: [RFC PATCH] xfrm: fix handling of XFRM policies mark and mask.
Date: Thu, 7 Feb 2013 11:49:08 +0100
Message-ID: <20130207104908.GA17794@secunet.com>
References: <9E57ADA1-5770-47A8-8EBF-7FC262EEF1C7@ipflavors.com>
 <20130205081232.GF23291@secunet.com>
 <51125744.3030905@gmail.com>
 <D4563759-CEC5-4F33-BF0A-9FA10716F8DF@telecom-bretagne.eu>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: jamal <j.hadi123@gmail.com>, Romain KUNTZ <r.kuntz@ipflavors.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"davem@davemloft.net" <davem@davemloft.net>,
	herbert@gondor.apana.org.au,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	Jamal Hadi Salim <hadi@cyberus.ca>
To: Emmanuel Thierry <emmanuel.thierry@telecom-bretagne.eu>
Return-path: <netdev-owner@vger.kernel.org>
Received: from a.mx.secunet.com ([195.81.216.161]:35327 "EHLO a.mx.secunet.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757265Ab3BGKtQ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 7 Feb 2013 05:49:16 -0500
Content-Disposition: inline
In-Reply-To: <D4563759-CEC5-4F33-BF0A-9FA10716F8DF@telecom-bretagne.eu>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Feb 06, 2013 at 02:53:48PM +0100, Emmanuel Thierry wrote:
>=20
> Hello,
>=20
> Le 6 f=E9vr. 2013 =E0 14:14, jamal a =E9crit :
>=20
> >=20
> > On 13-02-05 03:12 AM, Steffen Klassert wrote:
> >>> For example, executing the below commands in that order succeed:
> >>>  ip -6 xfrm policy flush
> >>>  ip -6 xfrm policy add src fd00::1/128 dst fd00::2/128 dir out ma=
rk 1 mask 0xffffffff
> >>>  ip -6 xfrm policy add src fd00::1/128 dst fd00::2/128 dir out
> >> The policy with mark 1 is the first we find. The policy passes the
> >> mark check and if the flow matches the selectors, we use this poli=
cy.
> >>=20
> >>> But it fails in the reverse order:
> >>>  ip -6 xfrm policy flush
> >>>  ip -6 xfrm policy add src fd00::1/128 dst fd00::2/128 dir out
> >>>  ip -6 xfrm policy add src fd00::1/128 dst fd00::2/128 dir out ma=
rk 1 mask 0xffffffff
> >>>  RTNETLINK answers: File exists
> >> With this scenario, we would find the policy with mark and mask 0 =
first.
> >> This policy passes the mark check too. So we would use this policy=
 if the
> >> flow matches the selectors, but the flow asked for a policy with m=
ark 1.
> >=20
> > I think the intent Romain is expressing is reasonable and should re=
solved at
> > insertion time(xfrm_policy_insert()).
> > i.e even though the policy (such as mark=3D1) is inserted afterward=
s, at
> > insertion time if it proves it is more specific and not duplicate, =
it should be
> > inserted ahead of the mark=3D0.
> > The runtime check will work then.
>=20
> Actually, we didn't think about this problem since we work with prior=
ities, putting the default policy (without a mark) at a minor priority =
than the marked one.
> Your remark makes clearer the ideas behind the design of XFRM, but th=
is leads to an interesting concern. If on policy insertion, the policy =
were inserted depending on the accuracy of the mark (the more the mask =
is specific, the more the mark must be put at the beginning of the list=
), how would we decide which is the more specific between these ones ?
>=20
> ip -6 xfrm policy add src fd00::1/128 dst fd00::2/128 dir out mark 0x=
00000001 mask 0x00000005
>=20
> ip -6 xfrm policy add src fd00::1/128 dst fd00::2/128 dir out mark 0x=
00000001 mask 0x00000003
>=20

We can't decide on the order of these two policies, so we should not
allow to insert both. At least not if the have the same priority,
but we could insert both if they have different priorities.

Would the patch below meet your requirements?

---
 net/xfrm/xfrm_policy.c |   18 ++++++++++++++++--
 1 files changed, 16 insertions(+), 2 deletions(-)

diff --git a/net/xfrm/xfrm_policy.c b/net/xfrm/xfrm_policy.c
index 6c9aa64..b169a69 100644
--- a/net/xfrm/xfrm_policy.c
+++ b/net/xfrm/xfrm_policy.c
@@ -562,6 +562,21 @@ static inline int selector_cmp(struct xfrm_selecto=
r *s1, struct xfrm_selector *s
 	return 0;
 }
=20
+static bool xfrm_mark_match(struct xfrm_policy *policy,
+			    struct xfrm_policy *pol)
+{
+	u32 mark =3D policy->mark.v & policy->mark.m;
+
+	if (policy->mark.v =3D=3D pol->mark.v && policy->mark.m =3D=3D pol->m=
ark.m)
+		return true;
+
+	if ((mark & pol->mark.m) =3D=3D pol->mark.v &&
+	    policy->priority =3D=3D pol->priority)
+		return true;
+
+	return false;
+}
+
 int xfrm_policy_insert(int dir, struct xfrm_policy *policy, int excl)
 {
 	struct net *net =3D xp_net(policy);
@@ -569,7 +584,6 @@ int xfrm_policy_insert(int dir, struct xfrm_policy =
*policy, int excl)
 	struct xfrm_policy *delpol;
 	struct hlist_head *chain;
 	struct hlist_node *entry, *newpos;
-	u32 mark =3D policy->mark.v & policy->mark.m;
=20
 	write_lock_bh(&xfrm_policy_lock);
 	chain =3D policy_hash_bysel(net, &policy->selector, policy->family, d=
ir);
@@ -578,7 +592,7 @@ int xfrm_policy_insert(int dir, struct xfrm_policy =
*policy, int excl)
 	hlist_for_each_entry(pol, entry, chain, bydst) {
 		if (pol->type =3D=3D policy->type &&
 		    !selector_cmp(&pol->selector, &policy->selector) &&
-		    (mark & pol->mark.m) =3D=3D pol->mark.v &&
+		    xfrm_mark_match(policy, pol) &&
 		    xfrm_sec_ctx_match(pol->security, policy->security) &&
 		    !WARN_ON(delpol)) {
 			if (excl) {
--=20
1.7.2.5
