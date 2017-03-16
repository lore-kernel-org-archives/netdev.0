From: Elena Reshetova <elena.reshetova@intel.com>
Subject: [PATCH 5/9] net, ipv6: convert ifacaddr6.aca_refcnt from atomic_t to refcount_t
Date: Thu, 16 Mar 2017 20:23:27 +0200
Message-ID: <1489688611-4542-6-git-send-email-elena.reshetova@intel.com>
References: <1489688611-4542-1-git-send-email-elena.reshetova@intel.com>
Cc: linux-kernel@vger.kernel.org, davem@davemloft.net,
        jmorris@namei.org, kaber@trash.net, yoshfuji@linux-ipv6.org,
        steffen.klassert@secunet.com, kuznet@ms2.inr.ac.ru,
        peterz@infradead.org, keescook@chromium.org,
        Elena Reshetova <elena.reshetova@intel.com>,
        Hans Liljestrand <ishkamiel@gmail.com>,
        David Windsor <dwindsor@gmail.com>
To: netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1489688611-4542-1-git-send-email-elena.reshetova@intel.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

refcount_t type and corresponding API should be
used instead of atomic_t when the variable is used as
a reference counter. This allows to avoid accidental
refcounter overflows that might lead to use-after-free
situations.

Signed-off-by: Elena Reshetova <elena.reshetova@intel.com>
Signed-off-by: Hans Liljestrand <ishkamiel@gmail.com>
Signed-off-by: Kees Cook <keescook@chromium.org>
Signed-off-by: David Windsor <dwindsor@gmail.com>
---
 include/net/if_inet6.h | 2 +-
 net/ipv6/anycast.c     | 6 +++---
 2 files changed, 4 insertions(+), 4 deletions(-)

diff --git a/include/net/if_inet6.h b/include/net/if_inet6.h
index 4bb52ce..d4088d1 100644
--- a/include/net/if_inet6.h
+++ b/include/net/if_inet6.h
@@ -147,7 +147,7 @@ struct ifacaddr6 {
 	struct rt6_info		*aca_rt;
 	struct ifacaddr6	*aca_next;
 	int			aca_users;
-	atomic_t		aca_refcnt;
+	refcount_t		aca_refcnt;
 	unsigned long		aca_cstamp;
 	unsigned long		aca_tstamp;
 };
diff --git a/net/ipv6/anycast.c b/net/ipv6/anycast.c
index 514ac25..0bbab8a 100644
--- a/net/ipv6/anycast.c
+++ b/net/ipv6/anycast.c
@@ -203,12 +203,12 @@ void ipv6_sock_ac_close(struct sock *sk)
 
 static void aca_get(struct ifacaddr6 *aca)
 {
-	atomic_inc(&aca->aca_refcnt);
+	refcount_inc(&aca->aca_refcnt);
 }
 
 static void aca_put(struct ifacaddr6 *ac)
 {
-	if (atomic_dec_and_test(&ac->aca_refcnt)) {
+	if (refcount_dec_and_test(&ac->aca_refcnt)) {
 		in6_dev_put(ac->aca_idev);
 		dst_release(&ac->aca_rt->dst);
 		kfree(ac);
@@ -232,7 +232,7 @@ static struct ifacaddr6 *aca_alloc(struct rt6_info *rt,
 	aca->aca_users = 1;
 	/* aca_tstamp should be updated upon changes */
 	aca->aca_cstamp = aca->aca_tstamp = jiffies;
-	atomic_set(&aca->aca_refcnt, 1);
+	refcount_set(&aca->aca_refcnt, 1);
 
 	return aca;
 }
-- 
2.7.4
