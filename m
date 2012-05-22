From: Pravin B Shelar <pshelar@nicira.com>
Subject: [PATCH 1/2] iproute2: Improve list add.
Date: Tue, 22 May 2012 15:37:19 -0700
Message-ID: <1337726239-9925-1-git-send-email-pshelar@nicira.com>
Cc: jpettit@nicira.com, jesse@nicira.com,
	Pravin B Shelar <pshelar@nicira.com>
To: shemminger@vyatta.com, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from na3sys009aog122.obsmtp.com ([74.125.149.147]:37242 "HELO
	na3sys009aog122.obsmtp.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with SMTP id S1757076Ab2EVWh0 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 22 May 2012 18:37:26 -0400
Received: by dadg9 with SMTP id g9so10457097dad.26
        for <netdev@vger.kernel.org>; Tue, 22 May 2012 15:37:24 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

ip command reads entire list of devices on every flush command.
While adding device record to list is does list traversal O(n).
This is time consuming for large batch commands.
Following patch improves list add operation to O(1).

Reported-by: Justin Pettit <jpettit@nicira.com>
Signed-off-by: Pravin B Shelar <pshelar@nicira.com>
---
 ip/ipaddress.c |   16 ++++++++++++----
 1 file changed, 12 insertions(+), 4 deletions(-)

diff --git a/ip/ipaddress.c b/ip/ipaddress.c
index 9ab65ec..7080c41 100644
--- a/ip/ipaddress.c
+++ b/ip/ipaddress.c
@@ -714,6 +714,7 @@ int print_addrinfo_secondary(const struct sockaddr_nl *who, struct nlmsghdr *n,
 struct nlmsg_list
 {
 	struct nlmsg_list *next;
+	struct nlmsg_list *last;
 	struct nlmsghdr	  h;
 };
 
@@ -744,17 +745,24 @@ static int store_nlmsg(const struct sockaddr_nl *who, struct nlmsghdr *n,
 {
 	struct nlmsg_list **linfo = (struct nlmsg_list**)arg;
 	struct nlmsg_list *h;
-	struct nlmsg_list **lp;
 
-	h = malloc(n->nlmsg_len+sizeof(void*));
+	h = malloc(n->nlmsg_len+sizeof(void*)+sizeof(void*));
 	if (h == NULL)
 		return -1;
 
 	memcpy(&h->h, n, n->nlmsg_len);
 	h->next = NULL;
 
-	for (lp = linfo; *lp; lp = &(*lp)->next) /* NOTHING */;
-	*lp = h;
+	if (!*linfo) {
+		/* First element. */
+		h->last = h;
+		*linfo = h;
+	} else {
+		struct nlmsg_list *last = (*linfo)->last;
+
+		last->next = h;
+		(*linfo)->last = h;
+	}
 
 	ll_remember_index(who, n, NULL);
 	return 0;
-- 
1.7.10
