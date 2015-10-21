From: Sowmini Varadhan <sowmini.varadhan@oracle.com>
Subject: [PATCH v2 net-next] xfrm: Fix unaligned access to stats in
 copy_to_user_state()
Date: Wed, 21 Oct 2015 11:48:25 -0400
Message-ID: <20151021154722.GA14667@oracle.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: steffen.klassert@secunet.com, herbert@gondor.apana.org.au,
	davem@davemloft.net
To: sowmini.varadhan@oracle.com, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


On sparc, deleting established SAs (e.g., by restarting ipsec)
results in unaligned access messages via xfrm_del_sa -> 
km_state_notify -> xfrm_send_state_notify().

Even though struct xfrm_usersa_info is aligned on 8-byte boundaries,
netlink attributes are fundamentally only 4 byte aligned, and this
cannot be changed for nla_data() that is passed up to userspace.
As a result, the put_unaligned() macro needs to be used to
set up potentially unaligned fields such as the xfrm_stats in
copy_to_user_state()

Signed-off-by: Sowmini Varadhan <sowmini.varadhan@oracle.com>
---
v2: review comment from thread: cannot use PTR_ALIGN as this would break
    userspace assumptions about 4 byte alignment. Use *_unaligned() macros
    as needed, instead.

 net/xfrm/xfrm_user.c |    5 ++++-
 1 files changed, 4 insertions(+), 1 deletions(-)

diff --git a/net/xfrm/xfrm_user.c b/net/xfrm/xfrm_user.c
index a8de9e3..639e0d5 100644
--- a/net/xfrm/xfrm_user.c
+++ b/net/xfrm/xfrm_user.c
@@ -31,6 +31,7 @@
 #if IS_ENABLED(CONFIG_IPV6)
 #include <linux/in6.h>
 #endif
+#include <asm/unaligned.h>
 
 static int verify_one_alg(struct nlattr **attrs, enum xfrm_attr_type_t type)
 {
@@ -728,7 +729,9 @@ static void copy_to_user_state(struct xfrm_state *x, struct xfrm_usersa_info *p)
 	memcpy(&p->sel, &x->sel, sizeof(p->sel));
 	memcpy(&p->lft, &x->lft, sizeof(p->lft));
 	memcpy(&p->curlft, &x->curlft, sizeof(p->curlft));
-	memcpy(&p->stats, &x->stats, sizeof(p->stats));
+	put_unaligned(x->stats.replay_window, &p->stats.replay_window);
+	put_unaligned(x->stats.replay, &p->stats.replay);
+	put_unaligned(x->stats.integrity_failed, &p->stats.integrity_failed);
 	memcpy(&p->saddr, &x->props.saddr, sizeof(p->saddr));
 	p->mode = x->props.mode;
 	p->replay_window = x->props.replay_window;
-- 
1.7.1
