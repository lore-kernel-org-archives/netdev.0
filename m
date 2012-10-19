From: Neil Horman <nhorman@tuxdriver.com>
Subject: [PATCH] Make hmac algorithm selection for cookie generation dynamic
Date: Fri, 19 Oct 2012 11:52:06 -0400
Message-ID: <1350661926-8312-1-git-send-email-nhorman@tuxdriver.com>
Cc: Neil Horman <nhorman@tuxdriver.com>,
	Vlad Yasevich <vyasevich@gmail.com>,
	"David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org
To: linux-sctp@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from charlotte.tuxdriver.com ([70.61.120.58]:46422 "EHLO
	smtp.tuxdriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751917Ab2JSPws (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 19 Oct 2012 11:52:48 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Currently sctp allows for the optional use of md5 of sha1 hmac algorithms to
generate cookie values when establishing new connections via two build time
config options.  Theres no real reason to make this a static selection.  We can
add a sysctl that allows for the dynamic selection of these algorithms at run
time, with the default value determined by the corresponding crypto library
config options.  It saves us two needless configuration settings and enables the
freedom for administrators to select which algorithm a particular system uses.
This comes in handy when, for example running a system in FIPS mode, where use
of md5 is disallowed, but SHA1 is permitted.

Note: This new sysctl has no corresponding socket option to select the cookie
hmac algorithm.  I chose not to implement that intentionally, as RFC 6458
contains no option for this value, and I opted not to pollute the socket option
namespace.

Signed-off-by: Neil Horman <nhorman@tuxdriver.com>
CC: Vlad Yasevich <vyasevich@gmail.com>
CC: "David S. Miller" <davem@davemloft.net>
CC: netdev@vger.kernel.org
---
 Documentation/networking/ip-sysctl.txt | 14 ++++++++
 include/net/netns/sctp.h               |  3 ++
 include/net/sctp/constants.h           |  8 -----
 include/net/sctp/structs.h             |  1 +
 net/sctp/Kconfig                       | 30 -----------------
 net/sctp/protocol.c                    |  9 ++++++
 net/sctp/socket.c                      | 11 ++++---
 net/sctp/sysctl.c                      | 59 ++++++++++++++++++++++++++++++++++
 8 files changed, 93 insertions(+), 42 deletions(-)

diff --git a/Documentation/networking/ip-sysctl.txt b/Documentation/networking/ip-sysctl.txt
index c7fc107..98ac0d7 100644
--- a/Documentation/networking/ip-sysctl.txt
+++ b/Documentation/networking/ip-sysctl.txt
@@ -1514,6 +1514,20 @@ cookie_preserve_enable - BOOLEAN
 
 	Default: 1
 
+cookie_hmac_alg - STRING
+	Select the hmac algorithm used when generating the cookie value sent by
+	a listening sctp socket to a connecting client in the INIT-ACK chunk.
+	Valid values are:
+	* md5
+	* sha1
+	* none
+	Ability to assign md5 or sha1 as the selected alg is predicated on the
+	configuarion of those algorithms at build time (CONFIG_CRYPTO_MD5 and
+	CONFIG_CRYPTO_SHA1).
+
+	Default: Dependent on configuration.  MD5 if available, else SHA1 if
+	available, else none.
+
 rcvbuf_policy - INTEGER
 	Determines if the receive buffer is attributed to the socket or to
 	association.   SCTP supports the capability to create multiple
diff --git a/include/net/netns/sctp.h b/include/net/netns/sctp.h
index 5e5eb1f..3573a81 100644
--- a/include/net/netns/sctp.h
+++ b/include/net/netns/sctp.h
@@ -62,6 +62,9 @@ struct netns_sctp {
 	/* Whether Cookie Preservative is enabled(1) or not(0) */
 	int cookie_preserve_enable;
 
+	/* The namespace default hmac alg */
+	char *sctp_hmac_alg;
+
 	/* Valid.Cookie.Life	    - 60  seconds  */
 	unsigned int valid_cookie_life;
 
diff --git a/include/net/sctp/constants.h b/include/net/sctp/constants.h
index d053d2e..c29707d 100644
--- a/include/net/sctp/constants.h
+++ b/include/net/sctp/constants.h
@@ -312,14 +312,6 @@ enum { SCTP_MAX_GABS = 16 };
 				 * functions simpler to write.
 				 */
 
-#if defined (CONFIG_SCTP_HMAC_MD5)
-#define SCTP_COOKIE_HMAC_ALG "hmac(md5)"
-#elif defined (CONFIG_SCTP_HMAC_SHA1)
-#define SCTP_COOKIE_HMAC_ALG "hmac(sha1)"
-#else
-#define SCTP_COOKIE_HMAC_ALG NULL
-#endif
-
 /* These return values describe the success or failure of a number of
  * routines which form the lower interface to SCTP_outqueue.
  */
diff --git a/include/net/sctp/structs.h b/include/net/sctp/structs.h
index 0fef00f..ce5f957 100644
--- a/include/net/sctp/structs.h
+++ b/include/net/sctp/structs.h
@@ -177,6 +177,7 @@ struct sctp_sock {
 
 	/* Access to HMAC transform. */
 	struct crypto_hash *hmac;
+	char *sctp_hmac_alg;
 
 	/* What is our base endpointer? */
 	struct sctp_endpoint *ep;
diff --git a/net/sctp/Kconfig b/net/sctp/Kconfig
index 126b014..44ffd3e 100644
--- a/net/sctp/Kconfig
+++ b/net/sctp/Kconfig
@@ -9,7 +9,6 @@ menuconfig IP_SCTP
 	select CRYPTO
 	select CRYPTO_HMAC
 	select CRYPTO_SHA1
-	select CRYPTO_MD5 if SCTP_HMAC_MD5
 	select LIBCRC32C
 	---help---
 	  Stream Control Transmission Protocol
@@ -68,33 +67,4 @@ config SCTP_DBG_OBJCNT
 
 	  If unsure, say N
 
-choice
-	prompt "SCTP: Cookie HMAC Algorithm"
-	default SCTP_HMAC_MD5
-	help
-	  HMAC algorithm to be used during association initialization.  It
-	  is strongly recommended to use HMAC-SHA1 or HMAC-MD5.  See 
-	  configuration for Cryptographic API and enable those algorithms
-          to make usable by SCTP. 
-
-config SCTP_HMAC_NONE
-	bool "None"
-	help 
-	  Choosing this disables the use of an HMAC during association 
-	  establishment.  It is advised to use either HMAC-MD5 or HMAC-SHA1.
-
-config SCTP_HMAC_SHA1
-	bool "HMAC-SHA1"
-	help 
-	  Enable the use of HMAC-SHA1 during association establishment.  It 
-	  is advised to use either HMAC-MD5 or HMAC-SHA1.
-
-config SCTP_HMAC_MD5
-	bool "HMAC-MD5"
-	help
-	  Enable the use of HMAC-MD5 during association establishment.  It is 
-	  advised to use either HMAC-MD5 or HMAC-SHA1.
-
-endchoice
-
 endif # IP_SCTP
diff --git a/net/sctp/protocol.c b/net/sctp/protocol.c
index 2d51842..456bc3d 100644
--- a/net/sctp/protocol.c
+++ b/net/sctp/protocol.c
@@ -1190,6 +1190,15 @@ static int sctp_net_init(struct net *net)
 	/* Whether Cookie Preservative is enabled(1) or not(0) */
 	net->sctp.cookie_preserve_enable 	= 1;
 
+	/* Default sctp sockets to use md5 as their hmac alg */
+#if defined (CONFIG_CRYPTO_MD5)
+	net->sctp.sctp_hmac_alg			= "md5";
+#elif defined (CONFIG_CRYPTO_SHA1)
+	net->sctp.sctp_hmac_alg			= "sha1";
+#else
+	net->sctp.sctp_hmac_alg			= NULL;
+#endif
+
 	/* Max.Burst		    - 4 */
 	net->sctp.max_burst			= SCTP_DEFAULT_MAX_BURST;
 
diff --git a/net/sctp/socket.c b/net/sctp/socket.c
index d37d24f..c388262 100644
--- a/net/sctp/socket.c
+++ b/net/sctp/socket.c
@@ -109,7 +109,6 @@ static int sctp_do_bind(struct sock *, union sctp_addr *, int);
 static int sctp_autobind(struct sock *sk);
 static void sctp_sock_migrate(struct sock *, struct sock *,
 			      struct sctp_association *, sctp_socket_type_t);
-static char *sctp_hmac_alg = SCTP_COOKIE_HMAC_ALG;
 
 extern struct kmem_cache *sctp_bucket_cachep;
 extern long sysctl_sctp_mem[3];
@@ -3889,6 +3888,8 @@ SCTP_STATIC int sctp_init_sock(struct sock *sk)
 	sp->default_rcv_context = 0;
 	sp->max_burst = net->sctp.max_burst;
 
+	sp->sctp_hmac_alg = net->sctp.sctp_hmac_alg;
+
 	/* Initialize default setup parameters. These parameters
 	 * can be modified with the SCTP_INITMSG socket option or
 	 * overridden by the SCTP_INIT CMSG.
@@ -5966,13 +5967,15 @@ SCTP_STATIC int sctp_listen_start(struct sock *sk, int backlog)
 	struct sctp_sock *sp = sctp_sk(sk);
 	struct sctp_endpoint *ep = sp->ep;
 	struct crypto_hash *tfm = NULL;
+	char alg[32];
 
 	/* Allocate HMAC for generating cookie. */
-	if (!sctp_sk(sk)->hmac && sctp_hmac_alg) {
-		tfm = crypto_alloc_hash(sctp_hmac_alg, 0, CRYPTO_ALG_ASYNC);
+	if (!sp->hmac && sp->sctp_hmac_alg) {
+		sprintf(alg, "hmac(%s)", sp->sctp_hmac_alg);
+		tfm = crypto_alloc_hash(alg, 0, CRYPTO_ALG_ASYNC);
 		if (IS_ERR(tfm)) {
 			net_info_ratelimited("failed to load transform for %s: %ld\n",
-					     sctp_hmac_alg, PTR_ERR(tfm));
+					     sp->sctp_hmac_alg, PTR_ERR(tfm));
 			return -ENOSYS;
 		}
 		sctp_sk(sk)->hmac = tfm;
diff --git a/net/sctp/sysctl.c b/net/sctp/sysctl.c
index 70e3ba5..043889a 100644
--- a/net/sctp/sysctl.c
+++ b/net/sctp/sysctl.c
@@ -62,6 +62,11 @@ extern long sysctl_sctp_mem[3];
 extern int sysctl_sctp_rmem[3];
 extern int sysctl_sctp_wmem[3];
 
+static int proc_sctp_do_hmac_alg(ctl_table *ctl,
+				int write,
+				void __user *buffer, size_t *lenp,
+
+				loff_t *ppos);
 static ctl_table sctp_table[] = {
 	{
 		.procname	= "sctp_mem",
@@ -147,6 +152,12 @@ static ctl_table sctp_net_table[] = {
 		.proc_handler	= proc_dointvec,
 	},
 	{
+		.procname	= "cookie_hmac_alg",
+		.maxlen		= 8,
+		.mode		= 0644,
+		.proc_handler	= proc_sctp_do_hmac_alg,
+	},
+	{
 		.procname	= "valid_cookie_life",
 		.data		= &init_net.sctp.valid_cookie_life,
 		.maxlen		= sizeof(unsigned int),
@@ -289,6 +300,54 @@ static ctl_table sctp_net_table[] = {
 	{ /* sentinel */ }
 };
 
+static int proc_sctp_do_hmac_alg(ctl_table *ctl,
+				int write,
+				void __user *buffer, size_t *lenp,
+				loff_t *ppos)
+{
+	struct net *net = current->nsproxy->net_ns;
+	char tmp[8];
+	ctl_table tbl;
+	int ret;
+	int changed = 0;
+	char *none = "none";
+
+	memset(&tbl, 0, sizeof(struct ctl_table));
+
+	if (write) {
+		tbl.data = tmp;
+		tbl.maxlen = 8;
+	} else {
+		tbl.data = net->sctp.sctp_hmac_alg ? : none;
+		tbl.maxlen = strlen(tbl.data);
+	}
+		ret = proc_dostring(&tbl, write, buffer, lenp, ppos);
+
+	if (write) {
+#ifdef CONFIG_CRYPTO_MD5
+		if (!strncmp(tmp, "md5", 3)) {
+			net->sctp.sctp_hmac_alg = "md5";
+			changed = 1;
+		}
+#endif
+#ifdef CONFIG_CRYPTO_SHA1
+		if (!strncmp(tmp, "sha1", 4)) {
+			net->sctp.sctp_hmac_alg = "sha1";
+			changed = 1;
+		}
+#endif
+		if (!strncmp(tmp, "none", 4)) {
+			net->sctp.sctp_hmac_alg = NULL;
+			changed = 1;
+		}
+
+		if (!changed)
+			ret = -EINVAL;
+	}
+
+	return ret;
+}
+
 int sctp_sysctl_net_register(struct net *net)
 {
 	struct ctl_table *table;
-- 
1.7.11.7
