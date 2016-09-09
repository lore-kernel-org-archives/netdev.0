From: Tom Herbert <tom@herbertland.com>
Subject: [PATCH RFC 3/6] ila: Call library function alloc_bucket_locks
Date: Fri, 9 Sep 2016 16:19:54 -0700
Message-ID: <1473463197-3076903-4-git-send-email-tom@herbertland.com>
References: <1473463197-3076903-1-git-send-email-tom@herbertland.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <kernel-team@fb.com>, <tgraf@suug.ch>
To: <davem@davemloft.net>, <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0b-00082601.pphosted.com ([67.231.153.30]:57217 "EHLO
        mx0a-00082601.pphosted.com" rhost-flags-OK-OK-OK-FAIL)
        by vger.kernel.org with ESMTP id S1755668AbcIIXUy (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 9 Sep 2016 19:20:54 -0400
Received: from pps.filterd (m0089730.ppops.net [127.0.0.1])
        by m0089730.ppops.net (8.16.0.17/8.16.0.17) with SMTP id u89NIQG5027039
        for <netdev@vger.kernel.org>; Fri, 9 Sep 2016 16:20:53 -0700
Received: from mail.thefacebook.com ([199.201.64.23])
        by m0089730.ppops.net with ESMTP id 25c201sv6c-4
        (version=TLSv1 cipher=ECDHE-RSA-AES256-SHA bits=256 verify=NOT)
        for <netdev@vger.kernel.org>; Fri, 09 Sep 2016 16:20:53 -0700
Received: from facebook.com (2401:db00:21:6030:face:0:92:0)     by
 mx-out.facebook.com (10.212.236.87) with ESMTP id
 faf57d8676e311e681670002c9521c9e-3bfe0a50 for <netdev@vger.kernel.org>;        Fri,
 09 Sep 2016 16:20:22 -0700
In-Reply-To: <1473463197-3076903-1-git-send-email-tom@herbertland.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

To allocate the array of bucket locks for the hash table we now
call library function alloc_bucket_spinlocks.

Signed-off-by: Tom Herbert <tom@herbertland.com>
---
 net/ipv6/ila/ila_xlat.c | 36 +++++-------------------------------
 1 file changed, 5 insertions(+), 31 deletions(-)

diff --git a/net/ipv6/ila/ila_xlat.c b/net/ipv6/ila/ila_xlat.c
index e604013..7d1c34b 100644
--- a/net/ipv6/ila/ila_xlat.c
+++ b/net/ipv6/ila/ila_xlat.c
@@ -30,34 +30,6 @@ struct ila_net {
 	bool hooks_registered;
 };
 
-#define	LOCKS_PER_CPU 10
-
-static int alloc_ila_locks(struct ila_net *ilan)
-{
-	unsigned int i, size;
-	unsigned int nr_pcpus = num_possible_cpus();
-
-	nr_pcpus = min_t(unsigned int, nr_pcpus, 32UL);
-	size = roundup_pow_of_two(nr_pcpus * LOCKS_PER_CPU);
-
-	if (sizeof(spinlock_t) != 0) {
-#ifdef CONFIG_NUMA
-		if (size * sizeof(spinlock_t) > PAGE_SIZE)
-			ilan->locks = vmalloc(size * sizeof(spinlock_t));
-		else
-#endif
-		ilan->locks = kmalloc_array(size, sizeof(spinlock_t),
-					    GFP_KERNEL);
-		if (!ilan->locks)
-			return -ENOMEM;
-		for (i = 0; i < size; i++)
-			spin_lock_init(&ilan->locks[i]);
-	}
-	ilan->locks_mask = size - 1;
-
-	return 0;
-}
-
 static u32 hashrnd __read_mostly;
 static __always_inline void __ila_hash_secret_init(void)
 {
@@ -561,14 +533,16 @@ static const struct genl_ops ila_nl_ops[] = {
 	},
 };
 
-#define ILA_HASH_TABLE_SIZE 1024
+#define LOCKS_PER_CPU 10
+#define MAX_LOCKS 1024
 
 static __net_init int ila_init_net(struct net *net)
 {
 	int err;
 	struct ila_net *ilan = net_generic(net, ila_net_id);
 
-	err = alloc_ila_locks(ilan);
+	err = alloc_bucket_spinlocks(&ilan->locks, &ilan->locks_mask,
+				     MAX_LOCKS, LOCKS_PER_CPU, GFP_KERNEL);
 	if (err)
 		return err;
 
@@ -583,7 +557,7 @@ static __net_exit void ila_exit_net(struct net *net)
 
 	rhashtable_free_and_destroy(&ilan->rhash_table, ila_free_cb, NULL);
 
-	kvfree(ilan->locks);
+	free_bucket_spinlocks(ilan->locks);
 
 	if (ilan->hooks_registered)
 		nf_unregister_net_hooks(net, ila_nf_hook_ops,
-- 
2.8.0.rc2
