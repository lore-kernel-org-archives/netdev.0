From: Vlad Yasevich <vladislav.yasevich@hp.com>
Subject: [PATCH] [SCTP]: Fix local_addr deletions during list traversals.
Date: Mon, 10 Mar 2008 16:45:09 -0400
Message-ID: <47D59DD5.5060403@hp.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>,
	Chidambar 'ilLogict' Zinnoury <illogict@online.fr>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from g1t0028.austin.hp.com ([15.216.28.35]:13835 "EHLO
	g1t0028.austin.hp.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751158AbYCJUo3 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 10 Mar 2008 16:44:29 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi David

Can please send this to stable as well...

Thanks
-vlad

--
From: Chidambar 'ilLogict' Zinnoury <illogict@online.fr>

Since the lists are circular, we need to explicitely tag
the address to be deleted since we might end up freeing
the list head instead.  This fixes some interesting SCTP
crashes.

Signed-off-by: Chidambar 'ilLogict' Zinnoury <illogict@online.fr>
Signed-off-by: Vlad Yasevich <vladislav.yasevich@hp.com>
---
 net/sctp/bind_addr.c |    4 +++-
 net/sctp/ipv6.c      |    4 +++-
 net/sctp/protocol.c  |    4 +++-
 3 files changed, 9 insertions(+), 3 deletions(-)

diff --git a/net/sctp/bind_addr.c b/net/sctp/bind_addr.c
index a27511e..ceefda0 100644
--- a/net/sctp/bind_addr.c
+++ b/net/sctp/bind_addr.c
@@ -209,6 +209,7 @@ int sctp_add_bind_addr(struct sctp_bind_addr *bp, union sctp_addr *new,
 int sctp_del_bind_addr(struct sctp_bind_addr *bp, union sctp_addr *del_addr)
 {
 	struct sctp_sockaddr_entry *addr, *temp;
+	int found = 0;
 
 	/* We hold the socket lock when calling this function,
 	 * and that acts as a writer synchronizing lock.
@@ -216,13 +217,14 @@ int sctp_del_bind_addr(struct sctp_bind_addr *bp, union sctp_addr *del_addr)
 	list_for_each_entry_safe(addr, temp, &bp->address_list, list) {
 		if (sctp_cmp_addr_exact(&addr->a, del_addr)) {
 			/* Found the exact match. */
+			found = 1;
 			addr->valid = 0;
 			list_del_rcu(&addr->list);
 			break;
 		}
 	}
 
-	if (addr && !addr->valid) {
+	if (found) {
 		call_rcu(&addr->rcu, sctp_local_addr_free);
 		SCTP_DBG_OBJCNT_DEC(addr);
 		return 0;
diff --git a/net/sctp/ipv6.c b/net/sctp/ipv6.c
index 87f9405..9aa0733 100644
--- a/net/sctp/ipv6.c
+++ b/net/sctp/ipv6.c
@@ -89,6 +89,7 @@ static int sctp_inet6addr_event(struct notifier_block *this, unsigned long ev,
 	struct inet6_ifaddr *ifa = (struct inet6_ifaddr *)ptr;
 	struct sctp_sockaddr_entry *addr = NULL;
 	struct sctp_sockaddr_entry *temp;
+	int found = 0;
 
 	switch (ev) {
 	case NETDEV_UP:
@@ -111,13 +112,14 @@ static int sctp_inet6addr_event(struct notifier_block *this, unsigned long ev,
 					&sctp_local_addr_list, list) {
 			if (ipv6_addr_equal(&addr->a.v6.sin6_addr,
 					     &ifa->addr)) {
+				found = 1;
 				addr->valid = 0;
 				list_del_rcu(&addr->list);
 				break;
 			}
 		}
 		spin_unlock_bh(&sctp_local_addr_lock);
-		if (addr && !addr->valid)
+		if (found)
 			call_rcu(&addr->rcu, sctp_local_addr_free);
 		break;
 	}
diff --git a/net/sctp/protocol.c b/net/sctp/protocol.c
index 688546d..ad0a406 100644
--- a/net/sctp/protocol.c
+++ b/net/sctp/protocol.c
@@ -628,6 +628,7 @@ static int sctp_inetaddr_event(struct notifier_block *this, unsigned long ev,
 	struct in_ifaddr *ifa = (struct in_ifaddr *)ptr;
 	struct sctp_sockaddr_entry *addr = NULL;
 	struct sctp_sockaddr_entry *temp;
+	int found = 0;
 
 	switch (ev) {
 	case NETDEV_UP:
@@ -647,13 +648,14 @@ static int sctp_inetaddr_event(struct notifier_block *this, unsigned long ev,
 		list_for_each_entry_safe(addr, temp,
 					&sctp_local_addr_list, list) {
 			if (addr->a.v4.sin_addr.s_addr == ifa->ifa_local) {
+				found = 1;
 				addr->valid = 0;
 				list_del_rcu(&addr->list);
 				break;
 			}
 		}
 		spin_unlock_bh(&sctp_local_addr_lock);
-		if (addr && !addr->valid)
+		if (found)
 			call_rcu(&addr->rcu, sctp_local_addr_free);
 		break;
 	}
-- 
1.5.3.5

