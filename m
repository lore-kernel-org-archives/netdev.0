From: Harvey Harrison <harvey.harrison@gmail.com>
Subject: [PATCH 3/7] net: replace NIPQUAD() in net/netfilter/
Date: Thu, 30 Oct 2008 17:13:45 -0700
Message-ID: <1225412025.5574.34.camel@brick>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: linux-netdev <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from wf-out-1314.google.com ([209.85.200.175]:44522 "EHLO
	wf-out-1314.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753808AbYJaANu (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 30 Oct 2008 20:13:50 -0400
Received: by wf-out-1314.google.com with SMTP id 27so879406wfd.4
        for <netdev@vger.kernel.org>; Thu, 30 Oct 2008 17:13:49 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Using NIPQUAD() with NIPQUAD_FMT, %d.%d.%d.%d or %u.%u.%u.%u
can be replaced with %pI4

Signed-off-by: Harvey Harrison <harvey.harrison@gmail.com>
---
 net/netfilter/ipvs/ip_vs_core.c         |   12 +++++-----
 net/netfilter/ipvs/ip_vs_ctl.c          |    4 +-
 net/netfilter/ipvs/ip_vs_dh.c           |    7 +----
 net/netfilter/ipvs/ip_vs_ftp.c          |   13 ++++-------
 net/netfilter/ipvs/ip_vs_lblc.c         |   11 +++------
 net/netfilter/ipvs/ip_vs_lblcr.c        |   19 +++++++---------
 net/netfilter/ipvs/ip_vs_proto.c        |   19 ++++++----------
 net/netfilter/ipvs/ip_vs_proto_ah_esp.c |    5 +--
 net/netfilter/ipvs/ip_vs_sh.c           |    7 +----
 net/netfilter/ipvs/ip_vs_sync.c         |    4 +-
 net/netfilter/ipvs/ip_vs_xmit.c         |   17 +++++++-------
 net/netfilter/nf_conntrack_ftp.c        |    7 ++---
 net/netfilter/nf_conntrack_irc.c        |   13 +++++------
 net/netfilter/xt_hashlimit.c            |    7 ++---
 net/netfilter/xt_iprange.c              |   36 +++++++++++++-----------------
 net/netfilter/xt_recent.c               |    5 +--
 16 files changed, 78 insertions(+), 108 deletions(-)

diff --git a/net/netfilter/ipvs/ip_vs_core.c b/net/netfilter/ipvs/ip_vs_core.c
index c3c6844..cb3e031 100644
--- a/net/netfilter/ipvs/ip_vs_core.c
+++ b/net/netfilter/ipvs/ip_vs_core.c
@@ -730,9 +730,9 @@ static int ip_vs_out_icmp(struct sk_buff *skb, int *related)
 	if (ic == NULL)
 		return NF_DROP;
 
-	IP_VS_DBG(12, "Outgoing ICMP (%d,%d) %u.%u.%u.%u->%u.%u.%u.%u\n",
+	IP_VS_DBG(12, "Outgoing ICMP (%d,%d) %pI4->%pI4\n",
 		  ic->type, ntohs(icmp_id(ic)),
-		  NIPQUAD(iph->saddr), NIPQUAD(iph->daddr));
+		  &iph->saddr, &iph->daddr);
 
 	/*
 	 * Work through seeing if this is for us.
@@ -1070,9 +1070,9 @@ ip_vs_in_icmp(struct sk_buff *skb, int *related, unsigned int hooknum)
 	if (ic == NULL)
 		return NF_DROP;
 
-	IP_VS_DBG(12, "Incoming ICMP (%d,%d) %u.%u.%u.%u->%u.%u.%u.%u\n",
+	IP_VS_DBG(12, "Incoming ICMP (%d,%d) %pI4->%pI4\n",
 		  ic->type, ntohs(icmp_id(ic)),
-		  NIPQUAD(iph->saddr), NIPQUAD(iph->daddr));
+		  &iph->saddr, &iph->daddr);
 
 	/*
 	 * Work through seeing if this is for us.
@@ -1127,8 +1127,8 @@ ip_vs_in_icmp(struct sk_buff *skb, int *related, unsigned int hooknum)
 	/* Ensure the checksum is correct */
 	if (!skb_csum_unnecessary(skb) && ip_vs_checksum_complete(skb, ihl)) {
 		/* Failed checksum! */
-		IP_VS_DBG(1, "Incoming ICMP: failed checksum from %d.%d.%d.%d!\n",
-			  NIPQUAD(iph->saddr));
+		IP_VS_DBG(1, "Incoming ICMP: failed checksum from %pI4!\n",
+			  &iph->saddr);
 		goto out;
 	}
 
diff --git a/net/netfilter/ipvs/ip_vs_ctl.c b/net/netfilter/ipvs/ip_vs_ctl.c
index 76db27e..98e0a65 100644
--- a/net/netfilter/ipvs/ip_vs_ctl.c
+++ b/net/netfilter/ipvs/ip_vs_ctl.c
@@ -2141,8 +2141,8 @@ do_ip_vs_set_ctl(struct sock *sk, int cmd, void __user *user, unsigned int len)
 
 	/* Check for valid protocol: TCP or UDP, even for fwmark!=0 */
 	if (usvc.protocol != IPPROTO_TCP && usvc.protocol != IPPROTO_UDP) {
-		IP_VS_ERR("set_ctl: invalid protocol: %d %d.%d.%d.%d:%d %s\n",
-			  usvc.protocol, NIPQUAD(usvc.addr.ip),
+		IP_VS_ERR("set_ctl: invalid protocol: %d %pI4:%d %s\n",
+			  usvc.protocol, &usvc.addr.ip,
 			  ntohs(usvc.port), usvc.sched_name);
 		ret = -EFAULT;
 		goto out_unlock;
diff --git a/net/netfilter/ipvs/ip_vs_dh.c b/net/netfilter/ipvs/ip_vs_dh.c
index a16943f..77179b9 100644
--- a/net/netfilter/ipvs/ip_vs_dh.c
+++ b/net/netfilter/ipvs/ip_vs_dh.c
@@ -215,11 +215,8 @@ ip_vs_dh_schedule(struct ip_vs_service *svc, const struct sk_buff *skb)
 		return NULL;
 	}
 
-	IP_VS_DBG(6, "DH: destination IP address %u.%u.%u.%u "
-		  "--> server %u.%u.%u.%u:%d\n",
-		  NIPQUAD(iph->daddr),
-		  NIPQUAD(dest->addr.ip),
-		  ntohs(dest->port));
+	IP_VS_DBG(6, "DH: destination IP address %pI4 --> server %pI4:%d\n",
+		  &iph->daddr, &dest->addr.ip, ntohs(dest->port));
 
 	return dest;
 }
diff --git a/net/netfilter/ipvs/ip_vs_ftp.c b/net/netfilter/ipvs/ip_vs_ftp.c
index 2e7dbd8..428edbf 100644
--- a/net/netfilter/ipvs/ip_vs_ftp.c
+++ b/net/netfilter/ipvs/ip_vs_ftp.c
@@ -178,10 +178,8 @@ static int ip_vs_ftp_out(struct ip_vs_app *app, struct ip_vs_conn *cp,
 					   &start, &end) != 1)
 			return 1;
 
-		IP_VS_DBG(7, "PASV response (%u.%u.%u.%u:%d) -> "
-			  "%u.%u.%u.%u:%d detected\n",
-			  NIPQUAD(from.ip), ntohs(port),
-			  NIPQUAD(cp->caddr.ip), 0);
+		IP_VS_DBG(7, "PASV response (%pI4:%d) -> %pI4:%d detected\n",
+			  &from.ip, ntohs(port), &cp->caddr.ip, 0);
 
 		/*
 		 * Now update or create an connection entry for it
@@ -312,8 +310,7 @@ static int ip_vs_ftp_in(struct ip_vs_app *app, struct ip_vs_conn *cp,
 				   &start, &end) != 1)
 		return 1;
 
-	IP_VS_DBG(7, "PORT %u.%u.%u.%u:%d detected\n",
-		  NIPQUAD(to.ip), ntohs(port));
+	IP_VS_DBG(7, "PORT %pI4:%d detected\n", &to.ip, ntohs(port));
 
 	/* Passive mode off */
 	cp->app_data = NULL;
@@ -321,9 +318,9 @@ static int ip_vs_ftp_in(struct ip_vs_app *app, struct ip_vs_conn *cp,
 	/*
 	 * Now update or create a connection entry for it
 	 */
-	IP_VS_DBG(7, "protocol %s %u.%u.%u.%u:%d %u.%u.%u.%u:%d\n",
+	IP_VS_DBG(7, "protocol %s %pI4:%d %pI4:%d\n",
 		  ip_vs_proto_name(iph->protocol),
-		  NIPQUAD(to.ip), ntohs(port), NIPQUAD(cp->vaddr.ip), 0);
+		  &to.ip, ntohs(port), &cp->vaddr.ip, 0);
 
 	n_cp = ip_vs_conn_in_get(AF_INET, iph->protocol,
 				 &to, port,
diff --git a/net/netfilter/ipvs/ip_vs_lblc.c b/net/netfilter/ipvs/ip_vs_lblc.c
index 6ecef35..035d4c3 100644
--- a/net/netfilter/ipvs/ip_vs_lblc.c
+++ b/net/netfilter/ipvs/ip_vs_lblc.c
@@ -420,9 +420,9 @@ __ip_vs_lblc_schedule(struct ip_vs_service *svc, struct iphdr *iph)
 		}
 	}
 
-	IP_VS_DBG(6, "LBLC: server %d.%d.%d.%d:%d "
+	IP_VS_DBG(6, "LBLC: server %pI4:%d "
 		  "activeconns %d refcnt %d weight %d overhead %d\n",
-		  NIPQUAD(least->addr.ip), ntohs(least->port),
+		  &least->addr.ip, ntohs(least->port),
 		  atomic_read(&least->activeconns),
 		  atomic_read(&least->refcnt),
 		  atomic_read(&least->weight), loh);
@@ -503,11 +503,8 @@ ip_vs_lblc_schedule(struct ip_vs_service *svc, const struct sk_buff *skb)
 	write_unlock(&svc->sched_lock);
 
 out:
-	IP_VS_DBG(6, "LBLC: destination IP address %u.%u.%u.%u "
-		  "--> server %u.%u.%u.%u:%d\n",
-		  NIPQUAD(iph->daddr),
-		  NIPQUAD(dest->addr.ip),
-		  ntohs(dest->port));
+	IP_VS_DBG(6, "LBLC: destination IP address %pI4 --> server %pI4:%d\n",
+		  &iph->daddr, &dest->addr.ip, ntohs(dest->port));
 
 	return dest;
 }
diff --git a/net/netfilter/ipvs/ip_vs_lblcr.c b/net/netfilter/ipvs/ip_vs_lblcr.c
index 1f75ea8..cceeff6 100644
--- a/net/netfilter/ipvs/ip_vs_lblcr.c
+++ b/net/netfilter/ipvs/ip_vs_lblcr.c
@@ -202,9 +202,9 @@ static inline struct ip_vs_dest *ip_vs_dest_set_min(struct ip_vs_dest_set *set)
 		}
 	}
 
-	IP_VS_DBG(6, "ip_vs_dest_set_min: server %d.%d.%d.%d:%d "
+	IP_VS_DBG(6, "ip_vs_dest_set_min: server %pI4:%d "
 		  "activeconns %d refcnt %d weight %d overhead %d\n",
-		  NIPQUAD(least->addr.ip), ntohs(least->port),
+		  &least->addr.ip, ntohs(least->port),
 		  atomic_read(&least->activeconns),
 		  atomic_read(&least->refcnt),
 		  atomic_read(&least->weight), loh);
@@ -248,9 +248,9 @@ static inline struct ip_vs_dest *ip_vs_dest_set_max(struct ip_vs_dest_set *set)
 		}
 	}
 
-	IP_VS_DBG(6, "ip_vs_dest_set_max: server %d.%d.%d.%d:%d "
+	IP_VS_DBG(6, "ip_vs_dest_set_max: server %pI4:%d "
 		  "activeconns %d refcnt %d weight %d overhead %d\n",
-		  NIPQUAD(most->addr.ip), ntohs(most->port),
+		  &most->addr.ip, ntohs(most->port),
 		  atomic_read(&most->activeconns),
 		  atomic_read(&most->refcnt),
 		  atomic_read(&most->weight), moh);
@@ -596,9 +596,9 @@ __ip_vs_lblcr_schedule(struct ip_vs_service *svc, struct iphdr *iph)
 		}
 	}
 
-	IP_VS_DBG(6, "LBLCR: server %d.%d.%d.%d:%d "
+	IP_VS_DBG(6, "LBLCR: server %pI4:%d "
 		  "activeconns %d refcnt %d weight %d overhead %d\n",
-		  NIPQUAD(least->addr.ip), ntohs(least->port),
+		  &least->addr.ip, ntohs(least->port),
 		  atomic_read(&least->activeconns),
 		  atomic_read(&least->refcnt),
 		  atomic_read(&least->weight), loh);
@@ -703,11 +703,8 @@ ip_vs_lblcr_schedule(struct ip_vs_service *svc, const struct sk_buff *skb)
 	write_unlock(&svc->sched_lock);
 
 out:
-	IP_VS_DBG(6, "LBLCR: destination IP address %u.%u.%u.%u "
-		  "--> server %u.%u.%u.%u:%d\n",
-		  NIPQUAD(iph->daddr),
-		  NIPQUAD(dest->addr.ip),
-		  ntohs(dest->port));
+	IP_VS_DBG(6, "LBLCR: destination IP address %pI4 --> server %pI4:%d\n",
+		  &iph->daddr, &dest->addr.ip, ntohs(dest->port));
 
 	return dest;
 }
diff --git a/net/netfilter/ipvs/ip_vs_proto.c b/net/netfilter/ipvs/ip_vs_proto.c
index 54cd67f..a01520e 100644
--- a/net/netfilter/ipvs/ip_vs_proto.c
+++ b/net/netfilter/ipvs/ip_vs_proto.c
@@ -164,26 +164,21 @@ ip_vs_tcpudp_debug_packet_v4(struct ip_vs_protocol *pp,
 	if (ih == NULL)
 		sprintf(buf, "%s TRUNCATED", pp->name);
 	else if (ih->frag_off & htons(IP_OFFSET))
-		sprintf(buf, "%s %u.%u.%u.%u->%u.%u.%u.%u frag",
-			pp->name, NIPQUAD(ih->saddr),
-			NIPQUAD(ih->daddr));
+		sprintf(buf, "%s %pI4->%pI4 frag",
+			pp->name, &ih->saddr, &ih->daddr);
 	else {
 		__be16 _ports[2], *pptr
 ;
 		pptr = skb_header_pointer(skb, offset + ih->ihl*4,
 					  sizeof(_ports), _ports);
 		if (pptr == NULL)
-			sprintf(buf, "%s TRUNCATED %u.%u.%u.%u->%u.%u.%u.%u",
-				pp->name,
-				NIPQUAD(ih->saddr),
-				NIPQUAD(ih->daddr));
+			sprintf(buf, "%s TRUNCATED %pI4->%pI4",
+				pp->name, &ih->saddr, &ih->daddr);
 		else
-			sprintf(buf, "%s %u.%u.%u.%u:%u->%u.%u.%u.%u:%u",
+			sprintf(buf, "%s %pI4:%u->%pI4:%u",
 				pp->name,
-				NIPQUAD(ih->saddr),
-				ntohs(pptr[0]),
-				NIPQUAD(ih->daddr),
-				ntohs(pptr[1]));
+				&ih->saddr, ntohs(pptr[0]),
+				&ih->daddr, ntohs(pptr[1]));
 	}
 
 	printk(KERN_DEBUG "IPVS: %s: %s\n", msg, buf);
diff --git a/net/netfilter/ipvs/ip_vs_proto_ah_esp.c b/net/netfilter/ipvs/ip_vs_proto_ah_esp.c
index 6ede888..79f56c1 100644
--- a/net/netfilter/ipvs/ip_vs_proto_ah_esp.c
+++ b/net/netfilter/ipvs/ip_vs_proto_ah_esp.c
@@ -135,9 +135,8 @@ ah_esp_debug_packet_v4(struct ip_vs_protocol *pp, const struct sk_buff *skb,
 	if (ih == NULL)
 		sprintf(buf, "%s TRUNCATED", pp->name);
 	else
-		sprintf(buf, "%s %u.%u.%u.%u->%u.%u.%u.%u",
-			pp->name, NIPQUAD(ih->saddr),
-			NIPQUAD(ih->daddr));
+		sprintf(buf, "%s %pI4->%pI4",
+			pp->name, &ih->saddr, &ih->daddr);
 
 	printk(KERN_DEBUG "IPVS: %s: %s\n", msg, buf);
 }
diff --git a/net/netfilter/ipvs/ip_vs_sh.c b/net/netfilter/ipvs/ip_vs_sh.c
index 1d96de2..be5863c 100644
--- a/net/netfilter/ipvs/ip_vs_sh.c
+++ b/net/netfilter/ipvs/ip_vs_sh.c
@@ -212,11 +212,8 @@ ip_vs_sh_schedule(struct ip_vs_service *svc, const struct sk_buff *skb)
 		return NULL;
 	}
 
-	IP_VS_DBG(6, "SH: source IP address %u.%u.%u.%u "
-		  "--> server %u.%u.%u.%u:%d\n",
-		  NIPQUAD(iph->saddr),
-		  NIPQUAD(dest->addr.ip),
-		  ntohs(dest->port));
+	IP_VS_DBG(6, "SH: source IP address %pI4 --> server %pI4:%d\n",
+		  &iph->saddr, &dest->addr.ip, ntohs(dest->port));
 
 	return dest;
 }
diff --git a/net/netfilter/ipvs/ip_vs_sync.c b/net/netfilter/ipvs/ip_vs_sync.c
index de5e7e1..6be5d4e 100644
--- a/net/netfilter/ipvs/ip_vs_sync.c
+++ b/net/netfilter/ipvs/ip_vs_sync.c
@@ -580,8 +580,8 @@ static int bind_mcastif_addr(struct socket *sock, char *ifname)
 		IP_VS_ERR("You probably need to specify IP address on "
 			  "multicast interface.\n");
 
-	IP_VS_DBG(7, "binding socket with (%s) %u.%u.%u.%u\n",
-		  ifname, NIPQUAD(addr));
+	IP_VS_DBG(7, "binding socket with (%s) %pI4\n",
+		  ifname, &addr);
 
 	/* Now bind the socket with the address of multicast interface */
 	sin.sin_family	     = AF_INET;
diff --git a/net/netfilter/ipvs/ip_vs_xmit.c b/net/netfilter/ipvs/ip_vs_xmit.c
index fc342dd..2f36721 100644
--- a/net/netfilter/ipvs/ip_vs_xmit.c
+++ b/net/netfilter/ipvs/ip_vs_xmit.c
@@ -82,14 +82,13 @@ __ip_vs_get_out_rt(struct ip_vs_conn *cp, u32 rtos)
 
 			if (ip_route_output_key(&init_net, &rt, &fl)) {
 				spin_unlock(&dest->dst_lock);
-				IP_VS_DBG_RL("ip_route_output error, "
-					     "dest: %u.%u.%u.%u\n",
-					     NIPQUAD(dest->addr.ip));
+				IP_VS_DBG_RL("ip_route_output error, dest: %pI4\n",
+					     &dest->addr.ip);
 				return NULL;
 			}
 			__ip_vs_dst_set(dest, rtos, dst_clone(&rt->u.dst));
-			IP_VS_DBG(10, "new dst %u.%u.%u.%u, refcnt=%d, rtos=%X\n",
-				  NIPQUAD(dest->addr.ip),
+			IP_VS_DBG(10, "new dst %pI4, refcnt=%d, rtos=%X\n",
+				  &dest->addr.ip,
 				  atomic_read(&rt->u.dst.__refcnt), rtos);
 		}
 		spin_unlock(&dest->dst_lock);
@@ -104,8 +103,8 @@ __ip_vs_get_out_rt(struct ip_vs_conn *cp, u32 rtos)
 		};
 
 		if (ip_route_output_key(&init_net, &rt, &fl)) {
-			IP_VS_DBG_RL("ip_route_output error, dest: "
-				     "%u.%u.%u.%u\n", NIPQUAD(cp->daddr.ip));
+			IP_VS_DBG_RL("ip_route_output error, dest: %pI4\n",
+				     &cp->daddr.ip);
 			return NULL;
 		}
 	}
@@ -236,8 +235,8 @@ ip_vs_bypass_xmit(struct sk_buff *skb, struct ip_vs_conn *cp,
 	EnterFunction(10);
 
 	if (ip_route_output_key(&init_net, &rt, &fl)) {
-		IP_VS_DBG_RL("ip_vs_bypass_xmit(): ip_route_output error, "
-			     "dest: %u.%u.%u.%u\n", NIPQUAD(iph->daddr));
+		IP_VS_DBG_RL("ip_vs_bypass_xmit(): ip_route_output error, dest: %pI4\n",
+			     &iph->daddr);
 		goto tx_error_icmp;
 	}
 
diff --git a/net/netfilter/nf_conntrack_ftp.c b/net/netfilter/nf_conntrack_ftp.c
index 8cab6d5..6295009 100644
--- a/net/netfilter/nf_conntrack_ftp.c
+++ b/net/netfilter/nf_conntrack_ftp.c
@@ -462,10 +462,9 @@ static int help(struct sk_buff *skb,
 		   different IP address.  Simply don't record it for
 		   NAT. */
 		if (cmd.l3num == PF_INET) {
-			pr_debug("conntrack_ftp: NOT RECORDING: " NIPQUAD_FMT
-				 " != " NIPQUAD_FMT "\n",
-				 NIPQUAD(cmd.u3.ip),
-				 NIPQUAD(ct->tuplehash[dir].tuple.src.u3.ip));
+			pr_debug("conntrack_ftp: NOT RECORDING: %pI4 != %pI4\n",
+				 &cmd.u3.ip,
+				 &ct->tuplehash[dir].tuple.src.u3.ip);
 		} else {
 			pr_debug("conntrack_ftp: NOT RECORDING: %pI6 != %pI6\n",
 				 cmd.u3.ip6,
diff --git a/net/netfilter/nf_conntrack_irc.c b/net/netfilter/nf_conntrack_irc.c
index 20633fd..4d681a0 100644
--- a/net/netfilter/nf_conntrack_irc.c
+++ b/net/netfilter/nf_conntrack_irc.c
@@ -156,9 +156,9 @@ static int help(struct sk_buff *skb, unsigned int protoff,
 		/* we have at least (19+MINMATCHLEN)-5 bytes valid data left */
 
 		iph = ip_hdr(skb);
-		pr_debug("DCC found in master %u.%u.%u.%u:%u %u.%u.%u.%u:%u\n",
-			 NIPQUAD(iph->saddr), ntohs(th->source),
-			 NIPQUAD(iph->daddr), ntohs(th->dest));
+		pr_debug("DCC found in master %pI4:%u %pI4:%u\n",
+			 &iph->saddr, ntohs(th->source),
+			 &iph->daddr, ntohs(th->dest));
 
 		for (i = 0; i < ARRAY_SIZE(dccprotos); i++) {
 			if (memcmp(data, dccprotos[i], strlen(dccprotos[i]))) {
@@ -185,10 +185,9 @@ static int help(struct sk_buff *skb, unsigned int protoff,
 			    tuple->dst.u3.ip != htonl(dcc_ip)) {
 				if (net_ratelimit())
 					printk(KERN_WARNING
-						"Forged DCC command from "
-						"%u.%u.%u.%u: %u.%u.%u.%u:%u\n",
-						NIPQUAD(tuple->src.u3.ip),
-						HIPQUAD(dcc_ip), dcc_port);
+						"Forged DCC command from %pI4: %pI4:%u\n",
+						&tuple->src.u3.ip,
+						&dcc_ip, dcc_port);
 				continue;
 			}
 
diff --git a/net/netfilter/xt_hashlimit.c b/net/netfilter/xt_hashlimit.c
index 6379717..f97fded 100644
--- a/net/netfilter/xt_hashlimit.c
+++ b/net/netfilter/xt_hashlimit.c
@@ -893,12 +893,11 @@ static int dl_seq_real_show(struct dsthash_ent *ent, u_int8_t family,
 
 	switch (family) {
 	case NFPROTO_IPV4:
-		return seq_printf(s, "%ld %u.%u.%u.%u:%u->"
-				     "%u.%u.%u.%u:%u %u %u %u\n",
+		return seq_printf(s, "%ld %pI4:%u->%pI4:%u %u %u %u\n",
 				 (long)(ent->expires - jiffies)/HZ,
-				 NIPQUAD(ent->dst.ip.src),
+				 &ent->dst.ip.src,
 				 ntohs(ent->dst.src_port),
-				 NIPQUAD(ent->dst.ip.dst),
+				 &ent->dst.ip.dst,
 				 ntohs(ent->dst.dst_port),
 				 ent->rateinfo.credit, ent->rateinfo.credit_cap,
 				 ent->rateinfo.cost);
diff --git a/net/netfilter/xt_iprange.c b/net/netfilter/xt_iprange.c
index 7ac54ea..501f9b6 100644
--- a/net/netfilter/xt_iprange.c
+++ b/net/netfilter/xt_iprange.c
@@ -26,12 +26,11 @@ iprange_mt_v0(const struct sk_buff *skb, const struct xt_match_param *par)
 		if ((ntohl(iph->saddr) < ntohl(info->src.min_ip)
 			  || ntohl(iph->saddr) > ntohl(info->src.max_ip))
 			 ^ !!(info->flags & IPRANGE_SRC_INV)) {
-			pr_debug("src IP %u.%u.%u.%u NOT in range %s"
-				 "%u.%u.%u.%u-%u.%u.%u.%u\n",
-				 NIPQUAD(iph->saddr),
+			pr_debug("src IP %pI4 NOT in range %s%pI4-%pI4\n",
+				 &iph->saddr,
 				 info->flags & IPRANGE_SRC_INV ? "(INV) " : "",
-				 NIPQUAD(info->src.min_ip),
-				 NIPQUAD(info->src.max_ip));
+				 &info->src.min_ip,
+				 &info->src.max_ip);
 			return false;
 		}
 	}
@@ -39,12 +38,11 @@ iprange_mt_v0(const struct sk_buff *skb, const struct xt_match_param *par)
 		if ((ntohl(iph->daddr) < ntohl(info->dst.min_ip)
 			  || ntohl(iph->daddr) > ntohl(info->dst.max_ip))
 			 ^ !!(info->flags & IPRANGE_DST_INV)) {
-			pr_debug("dst IP %u.%u.%u.%u NOT in range %s"
-				 "%u.%u.%u.%u-%u.%u.%u.%u\n",
-				 NIPQUAD(iph->daddr),
+			pr_debug("dst IP %pI4 NOT in range %s%pI4-%pI4\n",
+				 &iph->daddr,
 				 info->flags & IPRANGE_DST_INV ? "(INV) " : "",
-				 NIPQUAD(info->dst.min_ip),
-				 NIPQUAD(info->dst.max_ip));
+				 &info->dst.min_ip,
+				 &info->dst.max_ip);
 			return false;
 		}
 	}
@@ -63,12 +61,11 @@ iprange_mt4(const struct sk_buff *skb, const struct xt_match_param *par)
 		m |= ntohl(iph->saddr) > ntohl(info->src_max.ip);
 		m ^= !!(info->flags & IPRANGE_SRC_INV);
 		if (m) {
-			pr_debug("src IP " NIPQUAD_FMT " NOT in range %s"
-			         NIPQUAD_FMT "-" NIPQUAD_FMT "\n",
-			         NIPQUAD(iph->saddr),
+			pr_debug("src IP %pI4 NOT in range %s%pI4-%pI4\n",
+			         &iph->saddr,
 			         (info->flags & IPRANGE_SRC_INV) ? "(INV) " : "",
-			         NIPQUAD(info->src_max.ip),
-			         NIPQUAD(info->src_max.ip));
+			         &info->src_max.ip,
+			         &info->src_max.ip);
 			return false;
 		}
 	}
@@ -77,12 +74,11 @@ iprange_mt4(const struct sk_buff *skb, const struct xt_match_param *par)
 		m |= ntohl(iph->daddr) > ntohl(info->dst_max.ip);
 		m ^= !!(info->flags & IPRANGE_DST_INV);
 		if (m) {
-			pr_debug("dst IP " NIPQUAD_FMT " NOT in range %s"
-			         NIPQUAD_FMT "-" NIPQUAD_FMT "\n",
-			         NIPQUAD(iph->daddr),
+			pr_debug("dst IP %pI4 NOT in range %s%pI4-%pI4\n",
+			         &iph->daddr,
 			         (info->flags & IPRANGE_DST_INV) ? "(INV) " : "",
-			         NIPQUAD(info->dst_min.ip),
-			         NIPQUAD(info->dst_max.ip));
+			         &info->dst_min.ip,
+			         &info->dst_max.ip);
 			return false;
 		}
 	}
diff --git a/net/netfilter/xt_recent.c b/net/netfilter/xt_recent.c
index b785727..3c3dd22 100644
--- a/net/netfilter/xt_recent.c
+++ b/net/netfilter/xt_recent.c
@@ -422,9 +422,8 @@ static int recent_seq_show(struct seq_file *seq, void *v)
 
 	i = (e->index - 1) % ip_pkt_list_tot;
 	if (e->family == NFPROTO_IPV4)
-		seq_printf(seq, "src=" NIPQUAD_FMT " ttl: %u last_seen: %lu "
-			   "oldest_pkt: %u", NIPQUAD(e->addr.ip), e->ttl,
-			   e->stamps[i], e->index);
+		seq_printf(seq, "src=%pI4 ttl: %u last_seen: %lu oldest_pkt: %u",
+			   &e->addr.ip, e->ttl, e->stamps[i], e->index);
 	else
 		seq_printf(seq, "src=%pI6 ttl: %u last_seen: %lu oldest_pkt: %u",
 			   &e->addr.in6, e->ttl, e->stamps[i], e->index);
-- 
1.6.0.3.756.gb776d


