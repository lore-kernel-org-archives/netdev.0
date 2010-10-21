From: kaber@trash.net
Subject: [PATCH 17/72] IPVS: compact ip_vs_sched_persist()
Date: Thu, 21 Oct 2010 17:19:04 +0200
Message-ID: <1287674399-31455-18-git-send-email-kaber@trash.net>
References: <1287674399-31455-1-git-send-email-kaber@trash.net>
Cc: netfilter-devel@vger.kernel.org, netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <1287674399-31455-1-git-send-email-kaber@trash.net>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Simon Horman <horms@verge.net.au>

Compact ip_vs_sched_persist() by setting up parameters
and calling functions once.

Signed-off-by: Simon Horman <horms@verge.net.au>
Acked-by: Julian Anastasov <ja@ssi.bg>
---
 net/netfilter/ipvs/ip_vs_core.c |  160 +++++++++++++--------------------------
 1 files changed, 53 insertions(+), 107 deletions(-)

diff --git a/net/netfilter/ipvs/ip_vs_core.c b/net/netfilter/ipvs/ip_vs_core.c
index 06c388b..70a5cac 100644
--- a/net/netfilter/ipvs/ip_vs_core.c
+++ b/net/netfilter/ipvs/ip_vs_core.c
@@ -193,10 +193,14 @@ ip_vs_sched_persist(struct ip_vs_service *svc,
 	struct ip_vs_iphdr iph;
 	struct ip_vs_dest *dest;
 	struct ip_vs_conn *ct;
-	__be16  dport;			/* destination port to forward */
+	int protocol = iph.protocol;
+	__be16 dport = 0;		/* destination port to forward */
+	__be16 vport = 0;		/* virtual service port */
 	unsigned int flags;
 	union nf_inet_addr snet;	/* source network of the client,
 					   after masking */
+	const union nf_inet_addr fwmark = { .ip = htonl(svc->fwmark) };
+	const union nf_inet_addr *vaddr = &iph.daddr;
 
 	ip_vs_fill_iphdr(svc->af, skb_network_header(skb), &iph);
 
@@ -227,119 +231,61 @@ ip_vs_sched_persist(struct ip_vs_service *svc,
 	 * service, and a template like <caddr, 0, vaddr, vport, daddr, dport>
 	 * is created for other persistent services.
 	 */
-	if (ports[1] == svc->port) {
-		/* Check if a template already exists */
-		if (svc->port != FTPPORT)
-			ct = ip_vs_ct_in_get(svc->af, iph.protocol, &snet, 0,
-					     &iph.daddr, ports[1]);
-		else
-			ct = ip_vs_ct_in_get(svc->af, iph.protocol, &snet, 0,
-					     &iph.daddr, 0);
-
-		if (!ct || !ip_vs_check_template(ct)) {
-			/*
-			 * No template found or the dest of the connection
-			 * template is not available.
-			 */
-			dest = svc->scheduler->schedule(svc, skb);
-			if (dest == NULL) {
-				IP_VS_DBG(1, "p-schedule: no dest found.\n");
-				return NULL;
-			}
-
-			/*
-			 * Create a template like <protocol,caddr,0,
-			 * vaddr,vport,daddr,dport> for non-ftp service,
-			 * and <protocol,caddr,0,vaddr,0,daddr,0>
-			 * for ftp service.
+	{
+		if (ports[1] == svc->port) {
+			/* non-FTP template:
+			 * <protocol, caddr, 0, vaddr, vport, daddr, dport>
+			 * FTP template:
+			 * <protocol, caddr, 0, vaddr, 0, daddr, 0>
 			 */
 			if (svc->port != FTPPORT)
-				ct = ip_vs_conn_new(svc->af, iph.protocol,
-						    &snet, 0,
-						    &iph.daddr,
-						    ports[1],
-						    &dest->addr, dest->port,
-						    IP_VS_CONN_F_TEMPLATE,
-						    dest);
-			else
-				ct = ip_vs_conn_new(svc->af, iph.protocol,
-						    &snet, 0,
-						    &iph.daddr, 0,
-						    &dest->addr, 0,
-						    IP_VS_CONN_F_TEMPLATE,
-						    dest);
-			if (ct == NULL)
-				return NULL;
-
-			ct->timeout = svc->timeout;
+				vport = ports[1];
 		} else {
-			/* set destination with the found template */
-			dest = ct->dest;
+			/* Note: persistent fwmark-based services and
+			 * persistent port zero service are handled here.
+			 * fwmark template:
+			 * <IPPROTO_IP,caddr,0,fwmark,0,daddr,0>
+			 * port zero template:
+			 * <protocol,caddr,0,vaddr,0,daddr,0>
+			 */
+			if (svc->fwmark) {
+				protocol = IPPROTO_IP;
+				vaddr = &fwmark;
+			}
 		}
-		dport = dest->port;
-	} else {
-		/*
-		 * Note: persistent fwmark-based services and persistent
-		 * port zero service are handled here.
-		 * fwmark template: <IPPROTO_IP,caddr,0,fwmark,0,daddr,0>
-		 * port zero template: <protocol,caddr,0,vaddr,0,daddr,0>
+	}
+
+	/* Check if a template already exists */
+	ct = ip_vs_ct_in_get(svc->af, protocol, &snet, 0, vaddr, vport);
+
+	if (!ct || !ip_vs_check_template(ct)) {
+		/* No template found or the dest of the connection
+		 * template is not available.
 		 */
-		if (svc->fwmark) {
-			union nf_inet_addr fwmark = {
-				.ip = htonl(svc->fwmark)
-			};
+		dest = svc->scheduler->schedule(svc, skb);
+		if (!dest) {
+			IP_VS_DBG(1, "p-schedule: no dest found.\n");
+			return NULL;
+		}
 
-			ct = ip_vs_ct_in_get(svc->af, IPPROTO_IP, &snet, 0,
-					     &fwmark, 0);
-		} else
-			ct = ip_vs_ct_in_get(svc->af, iph.protocol, &snet, 0,
-					     &iph.daddr, 0);
+		if (ports[1] == svc->port && svc->port != FTPPORT)
+			dport = dest->port;
 
-		if (!ct || !ip_vs_check_template(ct)) {
-			/*
-			 * If it is not persistent port zero, return NULL,
-			 * otherwise create a connection template.
-			 */
-			if (svc->port)
-				return NULL;
+		/* Create a template */
+		ct = ip_vs_conn_new(svc->af, protocol, &snet, 0,vaddr, vport,
+				    &dest->addr, dport,
+				    IP_VS_CONN_F_TEMPLATE, dest);
+		if (ct == NULL)
+			return NULL;
 
-			dest = svc->scheduler->schedule(svc, skb);
-			if (dest == NULL) {
-				IP_VS_DBG(1, "p-schedule: no dest found.\n");
-				return NULL;
-			}
+		ct->timeout = svc->timeout;
+	} else
+		/* set destination with the found template */
+		dest = ct->dest;
 
-			/*
-			 * Create a template according to the service
-			 */
-			if (svc->fwmark) {
-				union nf_inet_addr fwmark = {
-					.ip = htonl(svc->fwmark)
-				};
-
-				ct = ip_vs_conn_new(svc->af, IPPROTO_IP,
-						    &snet, 0,
-						    &fwmark, 0,
-						    &dest->addr, 0,
-						    IP_VS_CONN_F_TEMPLATE,
-						    dest);
-			} else
-				ct = ip_vs_conn_new(svc->af, iph.protocol,
-						    &snet, 0,
-						    &iph.daddr, 0,
-						    &dest->addr, 0,
-						    IP_VS_CONN_F_TEMPLATE,
-						    dest);
-			if (ct == NULL)
-				return NULL;
-
-			ct->timeout = svc->timeout;
-		} else {
-			/* set destination with the found template */
-			dest = ct->dest;
-		}
-		dport = ports[1];
-	}
+	dport = ports[1];
+	if (dport == svc->port && dest->port)
+		dport = dest->port;
 
 	flags = (svc->flags & IP_VS_SVC_F_ONEPACKET
 		 && iph.protocol == IPPROTO_UDP)?
-- 
1.7.1

