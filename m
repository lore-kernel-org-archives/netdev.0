From: frank.blaschka@de.ibm.com
Subject: [patch 1/4] af_iucv: Add automatic (source) iucv_name to bind
Date: Tue, 27 May 2014 11:13:42 +0200
Message-ID: <20140527091400.088583527@de.ibm.com>
References: <20140527091341.417448231@de.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: netdev@vger.kernel.org, linux-s390@vger.kernel.org,
	Philipp Hachtmann <phacht@linux.vnet.ibm.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from e06smtp16.uk.ibm.com ([195.75.94.112]:34226 "EHLO
	e06smtp16.uk.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752430AbaE0JOI (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 27 May 2014 05:14:08 -0400
Received: from /spool/local
	by e06smtp16.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <netdev@vger.kernel.org> from <frank.blaschka@de.ibm.com>;
	Tue, 27 May 2014 10:14:05 +0100
Content-Disposition: inline; filename=605-iucv-source-name.diff
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Philipp Hachtmann <phacht@linux.vnet.ibm.com>

If a socket is bound to an address using before calling connect
it is usual to leave it to the network system to choose an appropriate
outgoing application name respective port address.
af_iucv on VM uses a counter and uses simple numbers as unique identifiers.
This behaviour was missing when af_iucv is used with HiperSockets.

This patch contains a simple approach to harmonize af_iucv's behaviour.

Signed-off-by: Philipp Hachtmann <phacht@linux.vnet.ibm.com>
Signed-off-by: Frank Blaschka <blaschka@linux.vnet.ibm.com>
---
 net/iucv/af_iucv.c | 29 ++++++++++++++++++-----------
 1 file changed, 18 insertions(+), 11 deletions(-)

diff --git a/net/iucv/af_iucv.c b/net/iucv/af_iucv.c
index 8c9d730..60f5c20 100644
--- a/net/iucv/af_iucv.c
+++ b/net/iucv/af_iucv.c
@@ -682,6 +682,18 @@ struct sock *iucv_accept_dequeue(struct sock *parent, struct socket *newsock)
 	return NULL;
 }
 
+static void __iucv_auto_name(struct iucv_sock *iucv)
+{
+	char name[12];
+
+	sprintf(name, "%08x", atomic_inc_return(&iucv_sk_list.autobind_name));
+	while (__iucv_get_sock_by_name(name)) {
+		sprintf(name, "%08x",
+			atomic_inc_return(&iucv_sk_list.autobind_name));
+	}
+	memcpy(iucv->src_name, name, 8);
+}
+
 /* Bind an unbound socket */
 static int iucv_sock_bind(struct socket *sock, struct sockaddr *addr,
 			  int addr_len)
@@ -724,8 +736,12 @@ static int iucv_sock_bind(struct socket *sock, struct sockaddr *addr,
 	rcu_read_lock();
 	for_each_netdev_rcu(&init_net, dev) {
 		if (!memcmp(dev->perm_addr, uid, 8)) {
-			memcpy(iucv->src_name, sa->siucv_name, 8);
 			memcpy(iucv->src_user_id, sa->siucv_user_id, 8);
+			/* Check for unitialized siucv_name */
+			if (strncmp(sa->siucv_name, "        ", 8) == 0)
+				__iucv_auto_name(iucv);
+			else
+				memcpy(iucv->src_name, sa->siucv_name, 8);
 			sk->sk_bound_dev_if = dev->ifindex;
 			iucv->hs_dev = dev;
 			dev_hold(dev);
@@ -763,7 +779,6 @@ done:
 static int iucv_sock_autobind(struct sock *sk)
 {
 	struct iucv_sock *iucv = iucv_sk(sk);
-	char name[12];
 	int err = 0;
 
 	if (unlikely(!pr_iucv))
@@ -772,17 +787,9 @@ static int iucv_sock_autobind(struct sock *sk)
 	memcpy(iucv->src_user_id, iucv_userid, 8);
 
 	write_lock_bh(&iucv_sk_list.lock);
-
-	sprintf(name, "%08x", atomic_inc_return(&iucv_sk_list.autobind_name));
-	while (__iucv_get_sock_by_name(name)) {
-		sprintf(name, "%08x",
-			atomic_inc_return(&iucv_sk_list.autobind_name));
-	}
-
+	__iucv_auto_name(iucv);
 	write_unlock_bh(&iucv_sk_list.lock);
 
-	memcpy(&iucv->src_name, name, 8);
-
 	if (!iucv->msglimit)
 		iucv->msglimit = IUCV_QUEUELEN_DEFAULT;
 
