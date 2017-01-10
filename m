From: Stephen Rothwell <sfr@canb.auug.org.au>
Subject: linux-next: build failure after merge of the selinux tree
Date: Tue, 10 Jan 2017 12:27:03 +1100
Message-ID: <20170110122703.2dbdfd18@canb.auug.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: linux-next@vger.kernel.org, linux-kernel@vger.kernel.org,
        Ursula Braun <ubraun@linux.vnet.ibm.com>,
        Stephen Smalley <sds@tycho.nsa.gov>
To: Paul Moore <paul@paul-moore.com>,
        David Miller <davem@davemloft.net>,
        Networking <netdev@vger.kernel.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi Paul,

After merging the selinux tree, today's linux-next build (x86_64
allmodconfig) failed like this:

In file included from /home/sfr/next/next/security/selinux/avc.c:35:0:
/home/sfr/next/next/security/selinux/include/classmap.h:242:2: error: #error New address family defined, please update secclass_map.
 #error New address family defined, please update secclass_map.
  ^
/home/sfr/next/next/security/selinux/hooks.c: In function 'socket_type_to_security_class':
/home/sfr/next/next/security/selinux/hooks.c:1409:2: error: #error New address family defined, please update this function.

Caused by commit

  da69a5306ab9 ("selinux: support distinctions among all network address families")

interacting with commit

  ac7138746e14 ("smc: establish new socket family")

from the net-next tree.

I added the following merge fix patch:

From: Stephen Rothwell <sfr@canb.auug.org.au>
Date: Tue, 10 Jan 2017 12:22:21 +1100
Subject: [PATCH] selinux: merge fix for "smc: establish new socket family"

Signed-off-by: Stephen Rothwell <sfr@canb.auug.org.au>
---
 security/selinux/hooks.c            | 4 +++-
 security/selinux/include/classmap.h | 4 +++-
 2 files changed, 6 insertions(+), 2 deletions(-)

diff --git a/security/selinux/hooks.c b/security/selinux/hooks.c
index bada3cd42b9c..712fd0e7c91d 100644
--- a/security/selinux/hooks.c
+++ b/security/selinux/hooks.c
@@ -1405,7 +1405,9 @@ static inline u16 socket_type_to_security_class(int family, int type, int protoc
 			return SECCLASS_KCM_SOCKET;
 		case PF_QIPCRTR:
 			return SECCLASS_QIPCRTR_SOCKET;
-#if PF_MAX > 43
+		case PF_SMC:
+			return SECCLASS_SMC_SOCKET;
+#if PF_MAX > 44
 #error New address family defined, please update this function.
 #endif
 		}
diff --git a/security/selinux/include/classmap.h b/security/selinux/include/classmap.h
index 0dfd26d0b8d8..40f1d4f8bc2a 100644
--- a/security/selinux/include/classmap.h
+++ b/security/selinux/include/classmap.h
@@ -235,9 +235,11 @@ struct security_class_mapping secclass_map[] = {
 	  { COMMON_SOCK_PERMS, NULL } },
 	{ "qipcrtr_socket",
 	  { COMMON_SOCK_PERMS, NULL } },
+	{ "smc_socket",
+	  { COMMON_SOCK_PERMS, NULL } },
 	{ NULL }
   };
 
-#if PF_MAX > 43
+#if PF_MAX > 44
 #error New address family defined, please update secclass_map.
 #endif
-- 
2.10.2

-- 
Cheers,
Stephen Rothwell
