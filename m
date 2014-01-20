From: Wang Weidong <wangweidong1@huawei.com>
Subject: [PATCH net-next 1/2] sctp: use sctp_local_bh_{disable|enable} instead local_bh_{disable|enable}
Date: Mon, 20 Jan 2014 19:27:26 +0800
Message-ID: <1390217247-9408-2-git-send-email-wangweidong1@huawei.com>
References: <1390217247-9408-1-git-send-email-wangweidong1@huawei.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <dborkman@redhat.com>, <netdev@vger.kernel.org>,
	<linux-sctp@vger.kernel.org>
To: <nhorman@tuxdriver.com>, <davem@davemloft.net>,
	<vyasevich@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from szxga03-in.huawei.com ([119.145.14.66]:29311 "EHLO
	szxga03-in.huawei.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750917AbaATL1z (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 20 Jan 2014 06:27:55 -0500
In-Reply-To: <1390217247-9408-1-git-send-email-wangweidong1@huawei.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

While we have the macros sctp_local_bh_{disable|enable}, so use them.

Signed-off-by: Wang Weidong <wangweidong1@huawei.com>
---
 net/sctp/sm_make_chunk.c | 8 ++++----
 net/sctp/socket.c        | 8 ++++----
 2 files changed, 8 insertions(+), 8 deletions(-)

diff --git a/net/sctp/sm_make_chunk.c b/net/sctp/sm_make_chunk.c
index 632090b..1bbac08 100644
--- a/net/sctp/sm_make_chunk.c
+++ b/net/sctp/sm_make_chunk.c
@@ -3266,12 +3266,12 @@ static void sctp_asconf_param_success(struct sctp_association *asoc,
 		/* This is always done in BH context with a socket lock
 		 * held, so the list can not change.
 		 */
-		local_bh_disable();
+		sctp_local_bh_disable();
 		list_for_each_entry(saddr, &bp->address_list, list) {
 			if (sctp_cmp_addr_exact(&saddr->a, &addr))
 				saddr->state = SCTP_ADDR_SRC;
 		}
-		local_bh_enable();
+		sctp_local_bh_enable();
 		list_for_each_entry(transport, &asoc->peer.transport_addr_list,
 				transports) {
 			dst_release(transport->dst);
@@ -3279,14 +3279,14 @@ static void sctp_asconf_param_success(struct sctp_association *asoc,
 		}
 		break;
 	case SCTP_PARAM_DEL_IP:
-		local_bh_disable();
+		sctp_local_bh_disable();
 		sctp_del_bind_addr(bp, &addr);
 		if (asoc->asconf_addr_del_pending != NULL &&
 		    sctp_cmp_addr_exact(asoc->asconf_addr_del_pending, &addr)) {
 			kfree(asoc->asconf_addr_del_pending);
 			asoc->asconf_addr_del_pending = NULL;
 		}
-		local_bh_enable();
+		sctp_local_bh_enable();
 		list_for_each_entry(transport, &asoc->peer.transport_addr_list,
 				transports) {
 			dst_release(transport->dst);
diff --git a/net/sctp/socket.c b/net/sctp/socket.c
index fd7337a..f73918c 100644
--- a/net/sctp/socket.c
+++ b/net/sctp/socket.c
@@ -3985,7 +3985,7 @@ static int sctp_init_sock(struct sock *sk)
 
 	SCTP_DBG_OBJCNT_INC(sock);
 
-	local_bh_disable();
+	sctp_local_bh_disable();
 	percpu_counter_inc(&sctp_sockets_allocated);
 	sock_prot_inuse_add(net, sk->sk_prot, 1);
 	if (net->sctp.default_auto_asconf) {
@@ -3994,7 +3994,7 @@ static int sctp_init_sock(struct sock *sk)
 		sp->do_auto_asconf = 1;
 	} else
 		sp->do_auto_asconf = 0;
-	local_bh_enable();
+	sctp_local_bh_enable();
 
 	return 0;
 }
@@ -4019,10 +4019,10 @@ static void sctp_destroy_sock(struct sock *sk)
 		list_del(&sp->auto_asconf_list);
 	}
 	sctp_endpoint_free(sp->ep);
-	local_bh_disable();
+	sctp_local_bh_disable();
 	percpu_counter_dec(&sctp_sockets_allocated);
 	sock_prot_inuse_add(sock_net(sk), sk->sk_prot, -1);
-	local_bh_enable();
+	sctp_local_bh_enable();
 }
 
 /* Triggered when there are no references on the socket anymore */
-- 
1.7.12
