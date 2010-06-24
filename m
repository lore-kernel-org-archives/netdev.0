From: =?UTF-8?q?Timo=20Ter=C3=A4s?= <timo.teras@iki.fi>
Subject: [PATCH] xfrm: check bundle policy existance before dereferencing it
Date: Thu, 24 Jun 2010 08:45:19 +0300
Message-ID: <1277358319-9868-1-git-send-email-timo.teras@iki.fi>
References: <4C22805A.3080307@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: =?UTF-8?q?Timo=20Ter=C3=A4s?= <timo.teras@iki.fi>
To: netdev@vger.kernel.org,
	"Justin P. Mattock" <justinmattock@gmail.com>,
	Eric Dumazet <eric.dumazet@gmail.com>,
	"John W.Linville" <linville@tuxdriver.com>,
	Linux Kernel Mailing List <l
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <4C22805A.3080307@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

=46ix the bundle validation code to not assume having a valid policy.
When we have multiple transformations for a xfrm policy, the bundle
instance will be a chain of bundles with only the first one having
the policy reference. When policy_genid is bumped it will expire the
first bundle in the chain which is equivalent of expiring the whole
chain.

Reported-bisected-and-tested-by: Justin P. Mattock <justinmattock@gmail=
=2Ecom>
Signed-off-by: Timo Ter=C3=A4s <timo.teras@iki.fi>
---
 net/xfrm/xfrm_policy.c |    3 ++-
 1 files changed, 2 insertions(+), 1 deletions(-)

diff --git a/net/xfrm/xfrm_policy.c b/net/xfrm/xfrm_policy.c
index 4bf27d9..af1c173 100644
--- a/net/xfrm/xfrm_policy.c
+++ b/net/xfrm/xfrm_policy.c
@@ -2300,7 +2300,8 @@ int xfrm_bundle_ok(struct xfrm_policy *pol, struc=
t xfrm_dst *first,
 			return 0;
 		if (xdst->xfrm_genid !=3D dst->xfrm->genid)
 			return 0;
-		if (xdst->policy_genid !=3D atomic_read(&xdst->pols[0]->genid))
+		if (xdst->num_pols > 0 &&
+		    xdst->policy_genid !=3D atomic_read(&xdst->pols[0]->genid))
 			return 0;
=20
 		if (strict && fl &&
--=20
1.7.0.4
