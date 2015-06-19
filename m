From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: [PATCH 10/12] netfilter: don't pull include/linux/netfilter.h from netns headers
Date: Fri, 19 Jun 2015 19:17:47 +0200
Message-ID: <1434734269-4545-11-git-send-email-pablo@netfilter.org>
References: <1434734269-4545-1-git-send-email-pablo@netfilter.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: netfilter-devel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.us.es ([193.147.175.20]:55553 "EHLO mail.us.es"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754436AbbFSRMj (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 19 Jun 2015 13:12:39 -0400
In-Reply-To: <1434734269-4545-1-git-send-email-pablo@netfilter.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This pulls the full hook netfilter definitions from all those that incl=
ude
net_namespace.h.

Instead let's just include the bare minimum required in the new
linux/netfilter_defs.h file, and use it from the netfilter netns header=
 files.

I also needed to include in.h and in6.h from linux/netfilter.h otherwis=
e we hit
this compilation error:

In file included from include/linux/netfilter_defs.h:4:0,
                 from include/net/netns/netfilter.h:4,
                 from include/net/net_namespace.h:22,
                 from include/linux/netdevice.h:43,
                 from net/netfilter/nfnetlink_queue_core.c:23:
include/uapi/linux/netfilter.h:76:17: error: field =E2=80=98in=E2=80=99=
 has incomplete type struct in_addr in;

And also explicit include linux/netfilter.h in several spots.

Signed-off-by: Pablo Neira Ayuso <pablo@netfilter.org>
Signed-off-by: Eric W. Biederman <ebiederm@xmission.com>
---
 include/linux/netfilter.h      |    6 ++----
 include/linux/netfilter_defs.h |    9 +++++++++
 include/net/netns/netfilter.h  |    2 +-
 include/net/netns/x_tables.h   |    2 +-
 include/uapi/linux/netfilter.h |    3 ++-
 net/ipv6/output_core.c         |    1 +
 6 files changed, 16 insertions(+), 7 deletions(-)
 create mode 100644 include/linux/netfilter_defs.h

diff --git a/include/linux/netfilter.h b/include/linux/netfilter.h
index f5ff5d1..00050df 100644
--- a/include/linux/netfilter.h
+++ b/include/linux/netfilter.h
@@ -10,7 +10,8 @@
 #include <linux/wait.h>
 #include <linux/list.h>
 #include <linux/static_key.h>
-#include <uapi/linux/netfilter.h>
+#include <linux/netfilter_defs.h>
+
 #ifdef CONFIG_NETFILTER
 static inline int NF_DROP_GETERR(int verdict)
 {
@@ -38,9 +39,6 @@ static inline void nf_inet_addr_mask(const union nf_i=
net_addr *a1,
=20
 int netfilter_init(void);
=20
-/* Largest hook number + 1 */
-#define NF_MAX_HOOKS 8
-
 struct sk_buff;
=20
 struct nf_hook_ops;
diff --git a/include/linux/netfilter_defs.h b/include/linux/netfilter_d=
efs.h
new file mode 100644
index 0000000..d3a7f85
--- /dev/null
+++ b/include/linux/netfilter_defs.h
@@ -0,0 +1,9 @@
+#ifndef __LINUX_NETFILTER_CORE_H_
+#define __LINUX_NETFILTER_CORE_H_
+
+#include <uapi/linux/netfilter.h>
+
+/* Largest hook number + 1, see uapi/linux/netfilter_decnet.h */
+#define NF_MAX_HOOKS 8
+
+#endif
diff --git a/include/net/netns/netfilter.h b/include/net/netns/netfilte=
r.h
index cf25b5e..532e4ba 100644
--- a/include/net/netns/netfilter.h
+++ b/include/net/netns/netfilter.h
@@ -1,7 +1,7 @@
 #ifndef __NETNS_NETFILTER_H
 #define __NETNS_NETFILTER_H
=20
-#include <linux/netfilter.h>
+#include <linux/netfilter_defs.h>
=20
 struct proc_dir_entry;
 struct nf_logger;
diff --git a/include/net/netns/x_tables.h b/include/net/netns/x_tables.=
h
index 4d6597a..c8a7681 100644
--- a/include/net/netns/x_tables.h
+++ b/include/net/netns/x_tables.h
@@ -2,7 +2,7 @@
 #define __NETNS_X_TABLES_H
=20
 #include <linux/list.h>
-#include <linux/netfilter.h>
+#include <linux/netfilter_defs.h>
=20
 struct ebt_table;
=20
diff --git a/include/uapi/linux/netfilter.h b/include/uapi/linux/netfil=
ter.h
index 177027c..d93f949 100644
--- a/include/uapi/linux/netfilter.h
+++ b/include/uapi/linux/netfilter.h
@@ -4,7 +4,8 @@
 #include <linux/types.h>
 #include <linux/compiler.h>
 #include <linux/sysctl.h>
-
+#include <linux/in.h>
+#include <linux/in6.h>
=20
 /* Responses from hook functions. */
 #define NF_DROP 0
diff --git a/net/ipv6/output_core.c b/net/ipv6/output_core.c
index 21678ac..928a0fb 100644
--- a/net/ipv6/output_core.c
+++ b/net/ipv6/output_core.c
@@ -8,6 +8,7 @@
 #include <net/ip6_fib.h>
 #include <net/addrconf.h>
 #include <net/secure_seq.h>
+#include <linux/netfilter.h>
=20
 static u32 __ipv6_select_ident(struct net *net, u32 hashrnd,
 			       const struct in6_addr *dst,
--=20
1.7.10.4
