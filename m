From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [PATCH iproute2] ip: speedup  store_nlmsg()
Date: Fri, 23 Oct 2009 06:37:49 +0200
Message-ID: <4AE1331D.6000604@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: Linux Netdev List <netdev@vger.kernel.org>
To: Stephen Hemminger <shemminger@vyatta.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from gw1.cosmosbay.com ([212.99.114.194]:55348 "EHLO
	gw1.cosmosbay.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750864AbZJWEhr (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 23 Oct 2009 00:37:47 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

ip link show command has O(N^2) complexity, because it loops until list end.
Adding pointer to last elements avoids this loop.

Before patch :

# time ip -o link | wc
  15013  240212 2136365

real    0m0.738s
user    0m0.770s
sys     0m0.035s
# time ip link show dev eth0
2: eth0: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc mq state UP qlen 1000
    link/ether 00:1e:0b:ec:d3:dc brd ff:ff:ff:ff:ff:ff

real    0m0.565s
user    0m0.540s
sys     0m0.025s

After patch :

# time ip/ip -o link | wc
  15013  210192 2031310

real    0m0.189s
user    0m0.221s
sys     0m0.032s

# time ip/ip link show dev eth0
2: eth0: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc mq state UP qlen 1000
    link/ether 00:1e:0b:ec:d3:dc brd ff:ff:ff:ff:ff:ff

real    0m0.032s
user    0m0.006s
sys     0m0.026s

Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>
---

diff --git a/ip/ipaddress.c b/ip/ipaddress.c
index cadc1a3..7674256 100644
--- a/ip/ipaddress.c
+++ b/ip/ipaddress.c
@@ -570,13 +570,16 @@ static int print_selected_addrinfo(int ifindex, struct nlmsg_list *ainfo, FILE *
 	return 0;
 }
 
+struct nlmsg_list_info {
+	struct nlmsg_list *first;
+	struct nlmsg_list *last;
+}; 
 
 static int store_nlmsg(const struct sockaddr_nl *who, struct nlmsghdr *n,
 		       void *arg)
 {
-	struct nlmsg_list **linfo = (struct nlmsg_list**)arg;
+	struct nlmsg_list_info *linfo = (struct nlmsg_list_info *)arg;
 	struct nlmsg_list *h;
-	struct nlmsg_list **lp;
 
 	h = malloc(n->nlmsg_len+sizeof(void*));
 	if (h == NULL)
@@ -585,8 +588,11 @@ static int store_nlmsg(const struct sockaddr_nl *who, struct nlmsghdr *n,
 	memcpy(&h->h, n, n->nlmsg_len);
 	h->next = NULL;
 
-	for (lp = linfo; *lp; lp = &(*lp)->next) /* NOTHING */;
-	*lp = h;
+	if (linfo->first)
+		linfo->last->next = h;
+	else
+		linfo->first = h;
+	linfo->last = h;
 
 	ll_remember_index(who, n, NULL);
 	return 0;
@@ -594,8 +600,8 @@ static int store_nlmsg(const struct sockaddr_nl *who, struct nlmsghdr *n,
 
 static int ipaddr_list_or_flush(int argc, char **argv, int flush)
 {
-	struct nlmsg_list *linfo = NULL;
-	struct nlmsg_list *ainfo = NULL;
+	struct nlmsg_list_info linfo = {0};
+	struct nlmsg_list_info ainfo = {0};
 	struct nlmsg_list *l, *n;
 	char *filter_dev = NULL;
 	int no_link = 0;
@@ -750,7 +756,7 @@ static int ipaddr_list_or_flush(int argc, char **argv, int flush)
 
 	if (filter.family && filter.family != AF_PACKET) {
 		struct nlmsg_list **lp;
-		lp=&linfo;
+		lp = &linfo.first;
 
 		if (filter.oneline)
 			no_link = 1;
@@ -760,7 +766,7 @@ static int ipaddr_list_or_flush(int argc, char **argv, int flush)
 			struct ifinfomsg *ifi = NLMSG_DATA(&l->h);
 			struct nlmsg_list *a;
 
-			for (a=ainfo; a; a=a->next) {
+			for (a = ainfo.first; a; a = a->next) {
 				struct nlmsghdr *n = &a->h;
 				struct ifaddrmsg *ifa = NLMSG_DATA(n);
 
@@ -807,12 +813,12 @@ static int ipaddr_list_or_flush(int argc, char **argv, int flush)
 		}
 	}
 
-	for (l=linfo; l; l = n) {
+	for (l = linfo.first; l; l = n) {
 		n = l->next;
 		if (no_link || print_linkinfo(NULL, &l->h, stdout) == 0) {
 			struct ifinfomsg *ifi = NLMSG_DATA(&l->h);
 			if (filter.family != AF_PACKET)
-				print_selected_addrinfo(ifi->ifi_index, ainfo, stdout);
+				print_selected_addrinfo(ifi->ifi_index, ainfo.first, stdout);
 		}
 		fflush(stdout);
 		free(l);
