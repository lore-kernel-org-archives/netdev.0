From: Cong Wang <amwang@redhat.com>
Subject: [PATCH net-next] net: make snmp_mib_free static inline
Date: Mon,  2 Sep 2013 10:06:53 +0800
Message-ID: <1378087613-15279-3-git-send-email-amwang@redhat.com>
References: <1378087613-15279-1-git-send-email-amwang@redhat.com>
Cc: "David S. Miller" <davem@davemloft.net>,
	Cong Wang <amwang@redhat.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:55256 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757964Ab3IBCHE (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 1 Sep 2013 22:07:04 -0400
In-Reply-To: <1378087613-15279-1-git-send-email-amwang@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Cong Wang <amwang@redhat.com>

Fengguang reported:

   net/built-in.o: In function `in6_dev_finish_destroy':
   (.text+0x4ca7d): undefined reference to `snmp_mib_free'

this is due to snmp_mib_free() is defined when CONFIG_INET is enabled,
but in6_dev_finish_destroy() is now moved to core kernel.

I think snmp_mib_free() is small enough to be inlined, so just make it
static inline.

Reported-by: kbuild test robot <fengguang.wu@intel.com>
Signed-off-by: Cong Wang <amwang@redhat.com>
---
 include/net/ip.h   |   12 +++++++++++-
 net/ipv4/af_inet.c |   12 ------------
 2 files changed, 11 insertions(+), 13 deletions(-)

diff --git a/include/net/ip.h b/include/net/ip.h
index a68f838..48f5597 100644
--- a/include/net/ip.h
+++ b/include/net/ip.h
@@ -194,7 +194,17 @@ static inline u64 snmp_fold_field64(void __percpu *mib[], int offt, size_t syncp
 }
 #endif
 extern int snmp_mib_init(void __percpu *ptr[2], size_t mibsize, size_t align);
-extern void snmp_mib_free(void __percpu *ptr[2]);
+
+static inline void snmp_mib_free(void __percpu *ptr[SNMP_ARRAY_SZ])
+{
+	int i;
+
+	BUG_ON(ptr == NULL);
+	for (i = 0; i < SNMP_ARRAY_SZ; i++) {
+		free_percpu(ptr[i]);
+		ptr[i] = NULL;
+	}
+}
 
 extern struct local_ports {
 	seqlock_t	lock;
diff --git a/net/ipv4/af_inet.c b/net/ipv4/af_inet.c
index b4d0be2..7a1874b 100644
--- a/net/ipv4/af_inet.c
+++ b/net/ipv4/af_inet.c
@@ -1532,18 +1532,6 @@ int snmp_mib_init(void __percpu *ptr[2], size_t mibsize, size_t align)
 }
 EXPORT_SYMBOL_GPL(snmp_mib_init);
 
-void snmp_mib_free(void __percpu *ptr[SNMP_ARRAY_SZ])
-{
-	int i;
-
-	BUG_ON(ptr == NULL);
-	for (i = 0; i < SNMP_ARRAY_SZ; i++) {
-		free_percpu(ptr[i]);
-		ptr[i] = NULL;
-	}
-}
-EXPORT_SYMBOL_GPL(snmp_mib_free);
-
 #ifdef CONFIG_IP_MULTICAST
 static const struct net_protocol igmp_protocol = {
 	.handler =	igmp_rcv,
-- 
1.7.7.6
