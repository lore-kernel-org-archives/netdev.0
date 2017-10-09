From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: [PATCH 03/12] netfilter: ipset: Fix adding an IPv4 range containing more than 2^31 addresses
Date: Mon,  9 Oct 2017 18:25:37 +0200
Message-ID: <1507566346-32553-4-git-send-email-pablo@netfilter.org>
References: <1507566346-32553-1-git-send-email-pablo@netfilter.org>
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: netfilter-devel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.us.es ([193.147.175.20]:57772 "EHLO mail.us.es"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1754944AbdJIQZ7 (ORCPT <rfc822;netdev@vger.kernel.org>);
        Mon, 9 Oct 2017 12:25:59 -0400
Received: from antivirus1-rhel7.int (unknown [192.168.2.11])
        by mail.us.es (Postfix) with ESMTP id 7E89EC0B2C
        for <netdev@vger.kernel.org>; Mon,  9 Oct 2017 18:25:57 +0200 (CEST)
Received: from antivirus1-rhel7.int (localhost [127.0.0.1])
        by antivirus1-rhel7.int (Postfix) with ESMTP id 6D43ADA873
        for <netdev@vger.kernel.org>; Mon,  9 Oct 2017 18:25:57 +0200 (CEST)
In-Reply-To: <1507566346-32553-1-git-send-email-pablo@netfilter.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jozsef Kadlecsik <kadlec@blackhole.kfki.hu>

Wrong comparison prevented the hash types to add a range with more than
2^31 addresses but reported as a success.

Fixes Netfilter's bugzilla id #1005, reported by Oleg Serditov and
Oliver Ford.

Signed-off-by: Jozsef Kadlecsik <kadlec@blackhole.kfki.hu>
Signed-off-by: Pablo Neira Ayuso <pablo@netfilter.org>
---
 net/netfilter/ipset/ip_set_hash_ip.c         | 22 ++++++++++++----------
 net/netfilter/ipset/ip_set_hash_ipmark.c     |  2 +-
 net/netfilter/ipset/ip_set_hash_ipport.c     |  2 +-
 net/netfilter/ipset/ip_set_hash_ipportip.c   |  2 +-
 net/netfilter/ipset/ip_set_hash_ipportnet.c  |  4 ++--
 net/netfilter/ipset/ip_set_hash_net.c        |  2 +-
 net/netfilter/ipset/ip_set_hash_netiface.c   |  2 +-
 net/netfilter/ipset/ip_set_hash_netnet.c     |  4 ++--
 net/netfilter/ipset/ip_set_hash_netport.c    |  2 +-
 net/netfilter/ipset/ip_set_hash_netportnet.c |  4 ++--
 10 files changed, 24 insertions(+), 22 deletions(-)

diff --git a/net/netfilter/ipset/ip_set_hash_ip.c b/net/netfilter/ipset/ip_set_hash_ip.c
index 20bfbd315f61..613eb212cb48 100644
--- a/net/netfilter/ipset/ip_set_hash_ip.c
+++ b/net/netfilter/ipset/ip_set_hash_ip.c
@@ -123,13 +123,12 @@ hash_ip4_uadt(struct ip_set *set, struct nlattr *tb[],
 		return ret;
 
 	ip &= ip_set_hostmask(h->netmask);
+	e.ip = htonl(ip);
+	if (e.ip == 0)
+		return -IPSET_ERR_HASH_ELEM;
 
-	if (adt == IPSET_TEST) {
-		e.ip = htonl(ip);
-		if (e.ip == 0)
-			return -IPSET_ERR_HASH_ELEM;
+	if (adt == IPSET_TEST)
 		return adtfn(set, &e, &ext, &ext, flags);
-	}
 
 	ip_to = ip;
 	if (tb[IPSET_ATTR_IP_TO]) {
@@ -148,17 +147,20 @@ hash_ip4_uadt(struct ip_set *set, struct nlattr *tb[],
 
 	hosts = h->netmask == 32 ? 1 : 2 << (32 - h->netmask - 1);
 
-	if (retried)
+	if (retried) {
 		ip = ntohl(h->next.ip);
-	for (; !before(ip_to, ip); ip += hosts) {
 		e.ip = htonl(ip);
-		if (e.ip == 0)
-			return -IPSET_ERR_HASH_ELEM;
+	}
+	for (; ip <= ip_to;) {
 		ret = adtfn(set, &e, &ext, &ext, flags);
-
 		if (ret && !ip_set_eexist(ret, flags))
 			return ret;
 
+		ip += hosts;
+		e.ip = htonl(ip);
+		if (e.ip == 0)
+			return 0;
+
 		ret = 0;
 	}
 	return ret;
diff --git a/net/netfilter/ipset/ip_set_hash_ipmark.c b/net/netfilter/ipset/ip_set_hash_ipmark.c
index b64cf14e8352..f3ba8348cf9d 100644
--- a/net/netfilter/ipset/ip_set_hash_ipmark.c
+++ b/net/netfilter/ipset/ip_set_hash_ipmark.c
@@ -149,7 +149,7 @@ hash_ipmark4_uadt(struct ip_set *set, struct nlattr *tb[],
 
 	if (retried)
 		ip = ntohl(h->next.ip);
-	for (; !before(ip_to, ip); ip++) {
+	for (; ip <= ip_to; ip++) {
 		e.ip = htonl(ip);
 		ret = adtfn(set, &e, &ext, &ext, flags);
 
diff --git a/net/netfilter/ipset/ip_set_hash_ipport.c b/net/netfilter/ipset/ip_set_hash_ipport.c
index f438740e6c6a..ddb8039ec1d2 100644
--- a/net/netfilter/ipset/ip_set_hash_ipport.c
+++ b/net/netfilter/ipset/ip_set_hash_ipport.c
@@ -178,7 +178,7 @@ hash_ipport4_uadt(struct ip_set *set, struct nlattr *tb[],
 
 	if (retried)
 		ip = ntohl(h->next.ip);
-	for (; !before(ip_to, ip); ip++) {
+	for (; ip <= ip_to; ip++) {
 		p = retried && ip == ntohl(h->next.ip) ? ntohs(h->next.port)
 						       : port;
 		for (; p <= port_to; p++) {
diff --git a/net/netfilter/ipset/ip_set_hash_ipportip.c b/net/netfilter/ipset/ip_set_hash_ipportip.c
index 6215fb898c50..a7f4d7a85420 100644
--- a/net/netfilter/ipset/ip_set_hash_ipportip.c
+++ b/net/netfilter/ipset/ip_set_hash_ipportip.c
@@ -185,7 +185,7 @@ hash_ipportip4_uadt(struct ip_set *set, struct nlattr *tb[],
 
 	if (retried)
 		ip = ntohl(h->next.ip);
-	for (; !before(ip_to, ip); ip++) {
+	for (; ip <= ip_to; ip++) {
 		p = retried && ip == ntohl(h->next.ip) ? ntohs(h->next.port)
 						       : port;
 		for (; p <= port_to; p++) {
diff --git a/net/netfilter/ipset/ip_set_hash_ipportnet.c b/net/netfilter/ipset/ip_set_hash_ipportnet.c
index 5ab1b99a53c2..a2f19b9906e9 100644
--- a/net/netfilter/ipset/ip_set_hash_ipportnet.c
+++ b/net/netfilter/ipset/ip_set_hash_ipportnet.c
@@ -271,7 +271,7 @@ hash_ipportnet4_uadt(struct ip_set *set, struct nlattr *tb[],
 
 	if (retried)
 		ip = ntohl(h->next.ip);
-	for (; !before(ip_to, ip); ip++) {
+	for (; ip <= ip_to; ip++) {
 		e.ip = htonl(ip);
 		p = retried && ip == ntohl(h->next.ip) ? ntohs(h->next.port)
 						       : port;
@@ -281,7 +281,7 @@ hash_ipportnet4_uadt(struct ip_set *set, struct nlattr *tb[],
 			      ip == ntohl(h->next.ip) &&
 			      p == ntohs(h->next.port)
 				? ntohl(h->next.ip2) : ip2_from;
-			while (!after(ip2, ip2_to)) {
+			while (ip2 <= ip2_to) {
 				e.ip2 = htonl(ip2);
 				ip2_last = ip_set_range_to_cidr(ip2, ip2_to,
 								&cidr);
diff --git a/net/netfilter/ipset/ip_set_hash_net.c b/net/netfilter/ipset/ip_set_hash_net.c
index 5d9e895452e7..1c67a1761e45 100644
--- a/net/netfilter/ipset/ip_set_hash_net.c
+++ b/net/netfilter/ipset/ip_set_hash_net.c
@@ -193,7 +193,7 @@ hash_net4_uadt(struct ip_set *set, struct nlattr *tb[],
 	}
 	if (retried)
 		ip = ntohl(h->next.ip);
-	while (!after(ip, ip_to)) {
+	while (ip <= ip_to) {
 		e.ip = htonl(ip);
 		last = ip_set_range_to_cidr(ip, ip_to, &e.cidr);
 		ret = adtfn(set, &e, &ext, &ext, flags);
diff --git a/net/netfilter/ipset/ip_set_hash_netiface.c b/net/netfilter/ipset/ip_set_hash_netiface.c
index 44cf11939c91..d417074f1c1a 100644
--- a/net/netfilter/ipset/ip_set_hash_netiface.c
+++ b/net/netfilter/ipset/ip_set_hash_netiface.c
@@ -255,7 +255,7 @@ hash_netiface4_uadt(struct ip_set *set, struct nlattr *tb[],
 
 	if (retried)
 		ip = ntohl(h->next.ip);
-	while (!after(ip, ip_to)) {
+	while (ip <= ip_to) {
 		e.ip = htonl(ip);
 		last = ip_set_range_to_cidr(ip, ip_to, &e.cidr);
 		ret = adtfn(set, &e, &ext, &ext, flags);
diff --git a/net/netfilter/ipset/ip_set_hash_netnet.c b/net/netfilter/ipset/ip_set_hash_netnet.c
index db614e13b193..7f9ae2e9645b 100644
--- a/net/netfilter/ipset/ip_set_hash_netnet.c
+++ b/net/netfilter/ipset/ip_set_hash_netnet.c
@@ -250,13 +250,13 @@ hash_netnet4_uadt(struct ip_set *set, struct nlattr *tb[],
 	if (retried)
 		ip = ntohl(h->next.ip[0]);
 
-	while (!after(ip, ip_to)) {
+	while (ip <= ip_to) {
 		e.ip[0] = htonl(ip);
 		last = ip_set_range_to_cidr(ip, ip_to, &e.cidr[0]);
 		ip2 = (retried &&
 		       ip == ntohl(h->next.ip[0])) ? ntohl(h->next.ip[1])
 						   : ip2_from;
-		while (!after(ip2, ip2_to)) {
+		while (ip2 <= ip2_to) {
 			e.ip[1] = htonl(ip2);
 			last2 = ip_set_range_to_cidr(ip2, ip2_to, &e.cidr[1]);
 			ret = adtfn(set, &e, &ext, &ext, flags);
diff --git a/net/netfilter/ipset/ip_set_hash_netport.c b/net/netfilter/ipset/ip_set_hash_netport.c
index 54b64b6cd0cd..e6ef382febe4 100644
--- a/net/netfilter/ipset/ip_set_hash_netport.c
+++ b/net/netfilter/ipset/ip_set_hash_netport.c
@@ -241,7 +241,7 @@ hash_netport4_uadt(struct ip_set *set, struct nlattr *tb[],
 
 	if (retried)
 		ip = ntohl(h->next.ip);
-	while (!after(ip, ip_to)) {
+	while (ip <= ip_to) {
 		e.ip = htonl(ip);
 		last = ip_set_range_to_cidr(ip, ip_to, &cidr);
 		e.cidr = cidr - 1;
diff --git a/net/netfilter/ipset/ip_set_hash_netportnet.c b/net/netfilter/ipset/ip_set_hash_netportnet.c
index aff846960ac4..8602f2595a1a 100644
--- a/net/netfilter/ipset/ip_set_hash_netportnet.c
+++ b/net/netfilter/ipset/ip_set_hash_netportnet.c
@@ -291,7 +291,7 @@ hash_netportnet4_uadt(struct ip_set *set, struct nlattr *tb[],
 	if (retried)
 		ip = ntohl(h->next.ip[0]);
 
-	while (!after(ip, ip_to)) {
+	while (ip <= ip_to) {
 		e.ip[0] = htonl(ip);
 		ip_last = ip_set_range_to_cidr(ip, ip_to, &e.cidr[0]);
 		p = retried && ip == ntohl(h->next.ip[0]) ? ntohs(h->next.port)
@@ -301,7 +301,7 @@ hash_netportnet4_uadt(struct ip_set *set, struct nlattr *tb[],
 			ip2 = (retried && ip == ntohl(h->next.ip[0]) &&
 			       p == ntohs(h->next.port)) ? ntohl(h->next.ip[1])
 							 : ip2_from;
-			while (!after(ip2, ip2_to)) {
+			while (ip2 <= ip2_to) {
 				e.ip[1] = htonl(ip2);
 				ip2_last = ip_set_range_to_cidr(ip2, ip2_to,
 								&e.cidr[1]);
-- 
2.1.4
