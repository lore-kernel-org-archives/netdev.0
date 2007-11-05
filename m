From: horms@vergenet.net
Subject: [patch 1/2] ipvs: Bind connections on stanby if the destination exists
Date: Mon, 05 Nov 2007 12:08:52 +0900
Message-ID: <20071105030958.596331811@vergenet.net>
References: <20071105030851.615630269@vergenet.net>
Cc: "Rumen G. Bogdanovski" <rumen@voicecho.com>,
	Graeme Fowler <graeme@graemef.net>,
	Joseph Mack NA3T <jmack@wm7d.net>,
	Julian Anastasov <ja@ssi.bg>,
	Wensong Zhang <wensong@linux-vs.org>,
	"David S. Miller" <davem@davemloft.net>
To: lvs-devel@linuxvirtualserver.org, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from koto.vergenet.net ([210.128.90.7]:47132 "EHLO koto.vergenet.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752858AbXKEDNk (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 4 Nov 2007 22:13:40 -0500
From: Simon Horman <horms@verge.net.au>
Content-Disposition: inline; filename=linux-2.6.23.1-ipvs-rb.patch
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Rumen G. Bogdanovski <rumen@voicecho.com>

This patch fixes the problem with node overload on director fail-over.
Given the scenario: 2 nodes each accepting 3 connections at a time and 2
directors, director failover occurs when the nodes are fully loaded (6
connections to the cluster) in this case the new director will assign
another 6 connections to the cluster, If the same real servers exist
there.

The problem turned to be in not binding the inherited connections to
the real servers (destinations) on the backup director. Therefore:
"ipvsadm -l" reports 0 connections:
root@test2:~# ipvsadm -l
IP Virtual Server version 1.2.1 (size=4096)
Prot LocalAddress:Port Scheduler Flags
  -> RemoteAddress:Port           Forward Weight ActiveConn InActConn
TCP  test2.local:5999 wlc
  -> node473.local:5999           Route   1000   0          0
  -> node484.local:5999           Route   1000   0          0

while "ipvs -lnc" is right
root@test2:~# ipvsadm -lnc
IPVS connection entries
pro expire state       source             virtual            destination
TCP 14:56  ESTABLISHED 192.168.0.10:39164 192.168.0.222:5999
192.168.0.51:5999
TCP 14:59  ESTABLISHED 192.168.0.10:39165 192.168.0.222:5999
192.168.0.52:5999

So the patch I am sending fixes the problem by binding the received
connections to the appropriate service on the backup director, if it
exists, else the connection will be handled the old way. So if the
master and the backup directors are synchronized in terms of real
services there will be no problem with server over-committing since
new connections will not be created on the nonexistent real services
on the backup. However if the service is created later on the backup,
the binding will be performed when the next connection update is
received. With this patch the inherited connections will show as
inactive on the backup:

root@test2:~# ipvsadm -l
IP Virtual Server version 1.2.1 (size=4096)
Prot LocalAddress:Port Scheduler Flags
  -> RemoteAddress:Port           Forward Weight ActiveConn InActConn
TCP  test2.local:5999 wlc
  -> node473.local:5999           Route   1000   0          1
  -> node484.local:5999           Route   1000   0          1

rumen@test2:~$ cat /proc/net/ip_vs
IP Virtual Server version 1.2.1 (size=4096)
Prot LocalAddress:Port Scheduler Flags
  -> RemoteAddress:Port Forward Weight ActiveConn InActConn
TCP  C0A800DE:176F wlc
  -> C0A80033:176F      Route   1000   0          1
  -> C0A80032:176F      Route   1000   0          1


Regards,
Rumen Bogdanovski

Acked-by: Julian Anastasov <ja@ssi.bg>
Signed-off-by: Rumen G. Bogdanovski <rumen@voicecho.com>
Signed-off-by: Simon Horman <horms@verge.net.au>

--- 
Mon, 05 Nov 2007 11:33:33 +0900
* Various whitespace and indentation changes
* Rediffed against net-2.6
* Ran against ./scripts/checkpatch.pl and fixed everything that
  it complained about

Index: net-2.6/include/net/ip_vs.h
===================================================================
--- net-2.6.orig/include/net/ip_vs.h	2007-11-05 11:23:58.000000000 +0900
+++ net-2.6/include/net/ip_vs.h	2007-11-05 11:25:51.000000000 +0900
@@ -901,6 +901,10 @@ extern int ip_vs_use_count_inc(void);
 extern void ip_vs_use_count_dec(void);
 extern int ip_vs_control_init(void);
 extern void ip_vs_control_cleanup(void);
+extern struct ip_vs_dest *
+ip_vs_find_dest(__be32 daddr, __be16 dport,
+		 __be32 vaddr, __be16 vport, __u16 protocol);
+extern struct ip_vs_dest *ip_vs_try_bind_dest(struct ip_vs_conn *cp);
 
 
 /*
Index: net-2.6/net/ipv4/ipvs/ip_vs_conn.c
===================================================================
--- net-2.6.orig/net/ipv4/ipvs/ip_vs_conn.c	2007-11-05 11:23:58.000000000 +0900
+++ net-2.6/net/ipv4/ipvs/ip_vs_conn.c	2007-11-05 11:25:51.000000000 +0900
@@ -426,6 +426,25 @@ ip_vs_bind_dest(struct ip_vs_conn *cp, s
 
 
 /*
+ * Check if there is a destination for the connection, if so
+ * bind the connection to the destination.
+ */
+struct ip_vs_dest *ip_vs_try_bind_dest(struct ip_vs_conn *cp)
+{
+	struct ip_vs_dest *dest;
+
+	if ((cp) && (!cp->dest)) {
+		dest = ip_vs_find_dest(cp->daddr, cp->dport,
+				       cp->vaddr, cp->vport, cp->protocol);
+		ip_vs_bind_dest(cp, dest);
+		return dest;
+	} else
+		return NULL;
+}
+EXPORT_SYMBOL(ip_vs_try_bind_dest);
+
+
+/*
  *	Unbind a connection entry with its VS destination
  *	Called by the ip_vs_conn_expire function.
  */
Index: net-2.6/net/ipv4/ipvs/ip_vs_ctl.c
===================================================================
--- net-2.6.orig/net/ipv4/ipvs/ip_vs_ctl.c	2007-11-05 11:23:58.000000000 +0900
+++ net-2.6/net/ipv4/ipvs/ip_vs_ctl.c	2007-11-05 11:25:51.000000000 +0900
@@ -579,6 +579,32 @@ ip_vs_lookup_dest(struct ip_vs_service *
 	return NULL;
 }
 
+/*
+ * Find destination by {daddr,dport,vaddr,protocol}
+ * Cretaed to be used in ip_vs_process_message() in
+ * the backup synchronization daemon. It finds the
+ * destination to be bound to the received connection
+ * on the backup.
+ *
+ * ip_vs_lookup_real_service() looked promissing, but
+ * seems not working as expected.
+ */
+struct ip_vs_dest *ip_vs_find_dest(__be32 daddr, __be16 dport,
+				    __be32 vaddr, __be16 vport, __u16 protocol)
+{
+	struct ip_vs_dest *dest;
+	struct ip_vs_service *svc;
+
+	svc = ip_vs_service_get(0, protocol, vaddr, vport);
+	if (!svc)
+		return NULL;
+	dest = ip_vs_lookup_dest(svc, daddr, dport);
+	if (dest)
+		atomic_inc(&dest->refcnt);
+	ip_vs_service_put(svc);
+	return dest;
+}
+EXPORT_SYMBOL(ip_vs_find_dest);
 
 /*
  *  Lookup dest by {svc,addr,port} in the destination trash.
Index: net-2.6/net/ipv4/ipvs/ip_vs_sync.c
===================================================================
--- net-2.6.orig/net/ipv4/ipvs/ip_vs_sync.c	2007-11-05 11:23:58.000000000 +0900
+++ net-2.6/net/ipv4/ipvs/ip_vs_sync.c	2007-11-05 11:26:16.000000000 +0900
@@ -284,6 +284,7 @@ static void ip_vs_process_message(const 
 	struct ip_vs_sync_conn_options *opt;
 	struct ip_vs_conn *cp;
 	struct ip_vs_protocol *pp;
+	struct ip_vs_dest *dest;
 	char *p;
 	int i;
 
@@ -317,20 +318,35 @@ static void ip_vs_process_message(const 
 					       s->caddr, s->cport,
 					       s->vaddr, s->vport);
 		if (!cp) {
+			/*
+			 * Find the appropriate destination for the connection.
+			 * If it is not found the connection will remain unbound
+			 * but still handled.
+			 */
+			dest = ip_vs_find_dest(s->daddr, s->dport,
+					       s->vaddr, s->vport,
+					       s->protocol);
 			cp = ip_vs_conn_new(s->protocol,
 					    s->caddr, s->cport,
 					    s->vaddr, s->vport,
 					    s->daddr, s->dport,
-					    flags, NULL);
+					    flags, dest);
+			if (dest)
+				atomic_dec(&dest->refcnt);
 			if (!cp) {
 				IP_VS_ERR("ip_vs_conn_new failed\n");
 				return;
 			}
 			cp->state = ntohs(s->state);
 		} else if (!cp->dest) {
-			/* it is an entry created by the synchronization */
-			cp->state = ntohs(s->state);
-			cp->flags = flags | IP_VS_CONN_F_HASHED;
+			dest = ip_vs_try_bind_dest(cp);
+			if (!dest) {
+				/* it is an unbound entry created by
+				 * synchronization */
+				cp->state = ntohs(s->state);
+				cp->flags = flags | IP_VS_CONN_F_HASHED;
+			} else
+				atomic_dec(&dest->refcnt);
 		}	/* Note that we don't touch its state and flags
 			   if it is a normal entry. */
 

-- 

-- 
Horms
  H: http://www.vergenet.net/~horms/
  W: http://www.valinux.co.jp/en/

