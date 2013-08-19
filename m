From: Cong Wang <amwang@redhat.com>
Subject: [Patch net-next v3 2/9] net: rename '%pIS' to '%pIA' for union inet_addr
Date: Mon, 19 Aug 2013 18:14:31 +0800
Message-ID: <1376907278-26377-3-git-send-email-amwang@redhat.com>
References: <1376907278-26377-1-git-send-email-amwang@redhat.com>
Cc: "David S. Miller" <davem@davemloft.net>,
	Daniel Borkmann <dborkman@redhat.com>,
	Joe Perches <joe@perches.com>, linux-kernel@vger.kernel.org,
	Cong Wang <amwang@redhat.com>
To: netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1376907278-26377-1-git-send-email-amwang@redhat.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Cong Wang <amwang@redhat.com>

The "%pIS" specifier is for struct Sockaddr, since now we have union
inet_addr, rename it to '%pIA' so that it can accept union inet_addr*.
But struct sockaddr * can still safely passed to
'%pIA', since it is a union of it.

Cc: Daniel Borkmann <dborkman@redhat.com>
Cc: Joe Perches <joe@perches.com>
Cc: linux-kernel@vger.kernel.org
Signed-off-by: Cong Wang <amwang@redhat.com>
---
 Documentation/printk-formats.txt |   20 ++++++++++----------
 drivers/net/netconsole.c         |   10 ++--------
 lib/vsprintf.c                   |   29 +++++++++++++----------------
 net/core/netpoll.c               |   10 ++--------
 net/sctp/associola.c             |    6 +++---
 net/sctp/protocol.c              |    6 +++---
 net/sctp/sm_sideeffect.c         |    2 +-
 net/sctp/socket.c                |    4 ++--
 8 files changed, 36 insertions(+), 51 deletions(-)

diff --git a/Documentation/printk-formats.txt b/Documentation/printk-formats.txt
index 3e8cb73..3521cc9 100644
--- a/Documentation/printk-formats.txt
+++ b/Documentation/printk-formats.txt
@@ -123,15 +123,15 @@ IPv6 addresses:
 
 IPv4/IPv6 addresses (generic, with port, flowinfo, scope):
 
-	%pIS	1.2.3.4		or 0001:0002:0003:0004:0005:0006:0007:0008
-	%piS	001.002.003.004	or 00010002000300040005000600070008
-	%pISc	1.2.3.4		or 1:2:3:4:5:6:7:8
-	%pISpc	1.2.3.4:12345	or [1:2:3:4:5:6:7:8]:12345
-	%p[Ii]S[pfschnbl]
+	%pIA	1.2.3.4		or 0001:0002:0003:0004:0005:0006:0007:0008
+	%piA	001.002.003.004	or 00010002000300040005000600070008
+	%pIAc	1.2.3.4		or 1:2:3:4:5:6:7:8
+	%pIApc	1.2.3.4:12345	or [1:2:3:4:5:6:7:8]:12345
+	%p[Ii]A[pfschnbl]
 
 	For printing an IP address without the need to distinguish whether it's
-	of type AF_INET or AF_INET6, a pointer to a valid 'struct sockaddr',
-	specified through 'IS' or 'iS', can be passed to this format specifier.
+	of type AF_INET or AF_INET6, a pointer to a valid 'union inet_addr',
+	specified through 'IA' or 'iA', can be passed to this format specifier.
 
 	The additional 'p', 'f', and 's' specifiers are used to specify port
 	(IPv4, IPv6), flowinfo (IPv6) and scope (IPv6). Ports have a ':' prefix,
@@ -149,9 +149,9 @@ IPv4/IPv6 addresses (generic, with port, flowinfo, scope):
 
 	Further examples:
 
-	%pISfc		1.2.3.4		or [1:2:3:4:5:6:7:8]/123456789
-	%pISsc		1.2.3.4		or [1:2:3:4:5:6:7:8]%1234567890
-	%pISpfc		1.2.3.4:12345	or [1:2:3:4:5:6:7:8]:12345/123456789
+	%pIAfc		1.2.3.4		or [1:2:3:4:5:6:7:8]/123456789
+	%pIAsc		1.2.3.4		or [1:2:3:4:5:6:7:8]%1234567890
+	%pIApfc		1.2.3.4:12345	or [1:2:3:4:5:6:7:8]:12345/123456789
 
 UUID/GUID addresses:
 
diff --git a/drivers/net/netconsole.c b/drivers/net/netconsole.c
index e4eac0c..28234f8 100644
--- a/drivers/net/netconsole.c
+++ b/drivers/net/netconsole.c
@@ -270,18 +270,12 @@ static ssize_t show_remote_port(struct netconsole_target *nt, char *buf)
 
 static ssize_t show_local_ip(struct netconsole_target *nt, char *buf)
 {
-	if (nt->np.ipv6)
-		return snprintf(buf, PAGE_SIZE, "%pI6c\n", &nt->np.local_ip.sin6.sin6_addr);
-	else
-		return snprintf(buf, PAGE_SIZE, "%pI4\n", &nt->np.local_ip.sin.sin_addr.s_addr);
+	return snprintf(buf, PAGE_SIZE, "%pIA\n", &nt->np.local_ip);
 }
 
 static ssize_t show_remote_ip(struct netconsole_target *nt, char *buf)
 {
-	if (nt->np.ipv6)
-		return snprintf(buf, PAGE_SIZE, "%pI6c\n", &nt->np.remote_ip.sin6.sin6_addr);
-	else
-		return snprintf(buf, PAGE_SIZE, "%pI4\n", &nt->np.remote_ip.sin.sin_addr.s_addr);
+	return snprintf(buf, PAGE_SIZE, "%pIA\n", &nt->np.remote_ip);
 }
 
 static ssize_t show_local_mac(struct netconsole_target *nt, char *buf)
diff --git a/lib/vsprintf.c b/lib/vsprintf.c
index 739a363..49618d0 100644
--- a/lib/vsprintf.c
+++ b/lib/vsprintf.c
@@ -27,6 +27,7 @@
 #include <linux/uaccess.h>
 #include <linux/ioport.h>
 #include <net/addrconf.h>
+#include <net/inet_addr.h>
 
 #include <asm/page.h>		/* for PAGE_SIZE */
 #include <asm/sections.h>	/* for dereference_function_descriptor() */
@@ -1104,14 +1105,14 @@ int kptr_restrict __read_mostly;
  * - 'I' [46] for IPv4/IPv6 addresses printed in the usual way
  *       IPv4 uses dot-separated decimal without leading 0's (1.2.3.4)
  *       IPv6 uses colon separated network-order 16 bit hex with leading 0's
- *       [S][pfs]
- *       Generic IPv4/IPv6 address (struct sockaddr *) that falls back to
+ *       [A][pfs]
+ *       Generic IPv4/IPv6 address (union inet_addr *) that falls back to
  *       [4] or [6] and is able to print port [p], flowinfo [f], scope [s]
  * - 'i' [46] for 'raw' IPv4/IPv6 addresses
  *       IPv6 omits the colons (01020304...0f)
  *       IPv4 uses dot-separated decimal with leading 0's (010.123.045.006)
- *       [S][pfs]
- *       Generic IPv4/IPv6 address (struct sockaddr *) that falls back to
+ *       [A][pfs]
+ *       Generic IPv4/IPv6 address (union inet_addr *) that falls back to
  *       [4] or [6] and is able to print port [p], flowinfo [f], scope [s]
  * - '[Ii][4S][hnbl]' IPv4 addresses in host, network, big or little endian order
  * - 'I[6S]c' for IPv6 addresses printed as specified by
@@ -1196,18 +1197,14 @@ char *pointer(const char *fmt, char *buf, char *end, void *ptr,
 			return ip6_addr_string(buf, end, ptr, spec, fmt);
 		case '4':
 			return ip4_addr_string(buf, end, ptr, spec, fmt);
-		case 'S': {
-			const union {
-				struct sockaddr		raw;
-				struct sockaddr_in	v4;
-				struct sockaddr_in6	v6;
-			} *sa = ptr;
-
-			switch (sa->raw.sa_family) {
+		case 'A': {
+			const union inet_addr *sa = ptr;
+
+			switch (sa->sa.sa_family) {
 			case AF_INET:
-				return ip4_addr_string_sa(buf, end, &sa->v4, spec, fmt);
+				return ip4_addr_string_sa(buf, end, &sa->sin, spec, fmt);
 			case AF_INET6:
-				return ip6_addr_string_sa(buf, end, &sa->v6, spec, fmt);
+				return ip6_addr_string_sa(buf, end, &sa->sin6, spec, fmt);
 			default:
 				return string(buf, end, "(invalid address)", spec);
 			}}
@@ -1488,8 +1485,8 @@ qualifier:
  * %pI6 print an IPv6 address with colons
  * %pi6 print an IPv6 address without colons
  * %pI6c print an IPv6 address as specified by RFC 5952
- * %pIS depending on sa_family of 'struct sockaddr *' print IPv4/IPv6 address
- * %piS depending on sa_family of 'struct sockaddr *' print IPv4/IPv6 address
+ * %pIA depending on sa_family of 'union inet_addr *' print IPv4/IPv6 address
+ * %piA depending on sa_family of 'union inet_addr *' print IPv4/IPv6 address
  * %pU[bBlL] print a UUID/GUID in big or little endian using lower or upper
  *   case.
  * %*ph[CDN] a variable-length hex string with a separator (supports up to 64
diff --git a/net/core/netpoll.c b/net/core/netpoll.c
index dd38553..9a45c54 100644
--- a/net/core/netpoll.c
+++ b/net/core/netpoll.c
@@ -900,16 +900,10 @@ out:
 void netpoll_print_options(struct netpoll *np)
 {
 	np_info(np, "local port %d\n", np->local_port);
-	if (np->ipv6)
-		np_info(np, "local IPv6 address %pI6c\n", &np->local_ip.sin6.sin6_addr);
-	else
-		np_info(np, "local IPv4 address %pI4\n", &np->local_ip.sin.sin_addr.s_addr);
+	np_info(np, "local IP address %pIA\n", &np->local_ip);
 	np_info(np, "interface '%s'\n", np->dev_name);
 	np_info(np, "remote port %d\n", np->remote_port);
-	if (np->ipv6)
-		np_info(np, "remote IPv6 address %pI6c\n", &np->remote_ip.sin6.sin6_addr);
-	else
-		np_info(np, "remote IPv4 address %pI4\n", &np->remote_ip.sin.sin_addr.s_addr);
+	np_info(np, "remote IP address %pIA\n", &np->remote_ip);
 	np_info(np, "remote ethernet address %pM\n", np->remote_mac);
 }
 EXPORT_SYMBOL(netpoll_print_options);
diff --git a/net/sctp/associola.c b/net/sctp/associola.c
index cef5099..a514612 100644
--- a/net/sctp/associola.c
+++ b/net/sctp/associola.c
@@ -534,7 +534,7 @@ void sctp_assoc_rm_peer(struct sctp_association *asoc,
 	struct list_head	*pos;
 	struct sctp_transport	*transport;
 
-	pr_debug("%s: association:%p addr:%pISpc\n",
+	pr_debug("%s: association:%p addr:%pIApc\n",
 		 __func__, asoc, &peer->ipaddr.sa);
 
 	/* If we are to remove the current retran_path, update it
@@ -631,7 +631,7 @@ struct sctp_transport *sctp_assoc_add_peer(struct sctp_association *asoc,
 	/* AF_INET and AF_INET6 share common port field. */
 	port = ntohs(addr->v4.sin_port);
 
-	pr_debug("%s: association:%p addr:%pISpc state:%d\n", __func__,
+	pr_debug("%s: association:%p addr:%pIApc state:%d\n", __func__,
 		 asoc, &addr->sa, peer_state);
 
 	/* Set the port if it has not been set yet.  */
@@ -1341,7 +1341,7 @@ void sctp_assoc_update_retran_path(struct sctp_association *asoc)
 	else
 		t = asoc->peer.retran_path;
 
-	pr_debug("%s: association:%p addr:%pISpc\n", __func__, asoc,
+	pr_debug("%s: association:%p addr:%pIApc\n", __func__, asoc,
 		 &t->ipaddr.sa);
 }
 
diff --git a/net/sctp/protocol.c b/net/sctp/protocol.c
index 5e17092..0680be7 100644
--- a/net/sctp/protocol.c
+++ b/net/sctp/protocol.c
@@ -598,7 +598,7 @@ static void sctp_addr_wq_timeout_handler(unsigned long arg)
 	spin_lock_bh(&net->sctp.addr_wq_lock);
 
 	list_for_each_entry_safe(addrw, temp, &net->sctp.addr_waitq, list) {
-		pr_debug("%s: the first ent in wq:%p is addr:%pISc for cmd:%d at "
+		pr_debug("%s: the first ent in wq:%p is addr:%pIAc for cmd:%d at "
 			 "entry:%p\n", __func__, &net->sctp.addr_waitq, &addrw->a.sa,
 			 addrw->state, addrw);
 
@@ -703,7 +703,7 @@ void sctp_addr_wq_mgmt(struct net *net, struct sctp_sockaddr_entry *addr, int cm
 	addrw = sctp_addr_wq_lookup(net, addr);
 	if (addrw) {
 		if (addrw->state != cmd) {
-			pr_debug("%s: offsets existing entry for %d, addr:%pISc "
+			pr_debug("%s: offsets existing entry for %d, addr:%pIAc "
 				 "in wq:%p\n", __func__, addrw->state, &addrw->a.sa,
 				 &net->sctp.addr_waitq);
 
@@ -723,7 +723,7 @@ void sctp_addr_wq_mgmt(struct net *net, struct sctp_sockaddr_entry *addr, int cm
 	addrw->state = cmd;
 	list_add_tail(&addrw->list, &net->sctp.addr_waitq);
 
-	pr_debug("%s: add new entry for cmd:%d, addr:%pISc in wq:%p\n",
+	pr_debug("%s: add new entry for cmd:%d, addr:%pIAc in wq:%p\n",
 		 __func__, addrw->state, &addrw->a.sa, &net->sctp.addr_waitq);
 
 	if (!timer_pending(&net->sctp.addr_wq_timer)) {
diff --git a/net/sctp/sm_sideeffect.c b/net/sctp/sm_sideeffect.c
index 666c668..638c63c 100644
--- a/net/sctp/sm_sideeffect.c
+++ b/net/sctp/sm_sideeffect.c
@@ -514,7 +514,7 @@ static void sctp_do_8_2_transport_strike(sctp_cmd_seq_t *commands,
 
 	if (transport->state != SCTP_INACTIVE &&
 	    (transport->error_count > transport->pathmaxrxt)) {
-		pr_debug("%s: association:%p transport addr:%pISpc failed\n",
+		pr_debug("%s: association:%p transport addr:%pIApc failed\n",
 			 __func__, asoc, &transport->ipaddr.sa);
 
 		sctp_assoc_control_transport(asoc, transport,
diff --git a/net/sctp/socket.c b/net/sctp/socket.c
index d5d5882..dba117a 100644
--- a/net/sctp/socket.c
+++ b/net/sctp/socket.c
@@ -343,7 +343,7 @@ static int sctp_do_bind(struct sock *sk, union sctp_addr *addr, int len)
 
 	snum = ntohs(addr->v4.sin_port);
 
-	pr_debug("%s: sk:%p, new addr:%pISc, port:%d, new port:%d, len:%d\n",
+	pr_debug("%s: sk:%p, new addr:%pIAc, port:%d, new port:%d, len:%d\n",
 		 __func__, sk, &addr->sa, bp->port, snum, len);
 
 	/* PF specific bind() address verification. */
@@ -797,7 +797,7 @@ static int sctp_send_asconf_del_ip(struct sock		*sk,
 				asoc->asconf_addr_del_pending->v6.sin6_addr = sin6->sin6_addr;
 			}
 
-			pr_debug("%s: keep the last address asoc:%p %pISc at %p\n",
+			pr_debug("%s: keep the last address asoc:%p %pIAc at %p\n",
 				 __func__, asoc, &asoc->asconf_addr_del_pending->sa,
 				 asoc->asconf_addr_del_pending);
 
-- 
1.7.7.6
