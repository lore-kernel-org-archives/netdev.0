From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [PATCH iproute2] ip: speedup ip link
Date: Sat, 09 Jun 2012 13:55:55 +0200
Message-ID: <1339242955.7575.5.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>
To: Stephen Hemminger <shemminger@vyatta.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f170.google.com ([209.85.212.170]:48255 "EHLO
	mail-wi0-f170.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751192Ab2FILz7 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 9 Jun 2012 07:55:59 -0400
Received: by wibhm6 with SMTP id hm6so2011778wib.1
        for <netdev@vger.kernel.org>; Sat, 09 Jun 2012 04:55:58 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <edumazet@google.com>

ip link has quadratic behavior because store_nlmsg()
has a head list pointer and search the end of list.

Provides a head/tail to cut time.

Time with 128000 net devices, to do "ip link show dev xxx"

Before: 2m3.594s
After: 0m2.830s

Signed-off-by: Eric Dumazet <edumazet@google.com>
---
 ip/ipaddress.c |   28 ++++++++++++++++++----------
 1 file changed, 18 insertions(+), 10 deletions(-)

diff --git a/ip/ipaddress.c b/ip/ipaddress.c
index 9ab65ec..51292b0 100644
--- a/ip/ipaddress.c
+++ b/ip/ipaddress.c
@@ -717,6 +717,12 @@ struct nlmsg_list
 	struct nlmsghdr	  h;
 };
 
+struct nlmsg_chain
+{
+	struct nlmsg_list *head;
+	struct nlmsg_list *tail;
+};
+
 static int print_selected_addrinfo(int ifindex, struct nlmsg_list *ainfo, FILE *fp)
 {
 	for ( ;ainfo ;  ainfo = ainfo->next) {
@@ -742,9 +748,8 @@ static int print_selected_addrinfo(int ifindex, struct nlmsg_list *ainfo, FILE *
 static int store_nlmsg(const struct sockaddr_nl *who, struct nlmsghdr *n,
 		       void *arg)
 {
-	struct nlmsg_list **linfo = (struct nlmsg_list**)arg;
+	struct nlmsg_chain *lchain = (struct nlmsg_chain *)arg;
 	struct nlmsg_list *h;
-	struct nlmsg_list **lp;
 
 	h = malloc(n->nlmsg_len+sizeof(void*));
 	if (h == NULL)
@@ -753,8 +758,11 @@ static int store_nlmsg(const struct sockaddr_nl *who, struct nlmsghdr *n,
 	memcpy(&h->h, n, n->nlmsg_len);
 	h->next = NULL;
 
-	for (lp = linfo; *lp; lp = &(*lp)->next) /* NOTHING */;
-	*lp = h;
+	if (lchain->tail)
+		lchain->tail->next = h;
+	else
+		lchain->head = h;
+	lchain->tail = h;
 
 	ll_remember_index(who, n, NULL);
 	return 0;
@@ -762,8 +770,8 @@ static int store_nlmsg(const struct sockaddr_nl *who, struct nlmsghdr *n,
 
 static int ipaddr_list_or_flush(int argc, char **argv, int flush)
 {
-	struct nlmsg_list *linfo = NULL;
-	struct nlmsg_list *ainfo = NULL;
+	struct nlmsg_chain linfo = { NULL, NULL};
+	struct nlmsg_chain ainfo = { NULL, NULL};
 	struct nlmsg_list *l, *n;
 	char *filter_dev = NULL;
 	int no_link = 0;
@@ -953,7 +961,7 @@ flush_done:
 
 	if (filter.family && filter.family != AF_PACKET) {
 		struct nlmsg_list **lp;
-		lp=&linfo;
+		lp = &linfo.head;
 
 		if (filter.oneline)
 			no_link = 1;
@@ -963,7 +971,7 @@ flush_done:
 			struct ifinfomsg *ifi = NLMSG_DATA(&l->h);
 			struct nlmsg_list *a;
 
-			for (a=ainfo; a; a=a->next) {
+			for (a = ainfo.head; a; a = a->next) {
 				struct nlmsghdr *n = &a->h;
 				struct ifaddrmsg *ifa = NLMSG_DATA(n);
 
@@ -1010,12 +1018,12 @@ flush_done:
 		}
 	}
 
-	for (l=linfo; l; l = n) {
+	for (l = linfo.head; l; l = n) {
 		n = l->next;
 		if (no_link || print_linkinfo(NULL, &l->h, stdout) == 0) {
 			struct ifinfomsg *ifi = NLMSG_DATA(&l->h);
 			if (filter.family != AF_PACKET)
-				print_selected_addrinfo(ifi->ifi_index, ainfo, stdout);
+				print_selected_addrinfo(ifi->ifi_index, ainfo.head, stdout);
 		}
 		fflush(stdout);
 		free(l);
