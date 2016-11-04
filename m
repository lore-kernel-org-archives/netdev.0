From: Sowmini Varadhan <sowmini.varadhan@oracle.com>
Subject: [PATCH net-next 1/2] RDS: TCP: report addr/port info based on TCP socket in rds-info
Date: Fri,  4 Nov 2016 10:04:11 -0700
Message-ID: <2527eeac34575ba47af508dfbd8e6f7fec3f94be.1478276221.git.sowmini.varadhan@oracle.com>
References: <cover.1478276221.git.sowmini.varadhan@oracle.com>
Cc: davem@davemloft.net, rds-devel@oss.oracle.com,
        sowmini.varadhan@oracle.com, santosh.shilimkar@oracle.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from aserp1040.oracle.com ([141.146.126.69]:31923 "EHLO
        aserp1040.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S936216AbcKDREW (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 4 Nov 2016 13:04:22 -0400
In-Reply-To: <cover.1478276221.git.sowmini.varadhan@oracle.com>
In-Reply-To: <cover.1478276221.git.sowmini.varadhan@oracle.com>
References: <cover.1478276221.git.sowmini.varadhan@oracle.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The socket argument passed to rds_tcp_tc_info() is a PF_RDS socket,
so it is incorrect to report the address port info based on
rds_getname() as part of TCP state report.

Invoke inet_getname() for the t_sock associated with the
rds_tcp_connection instead.

Signed-off-by: Sowmini Varadhan <sowmini.varadhan@oracle.com>
Acked-by: Santosh Shilimkar <santosh.shilimkar@oracle.com>
---
 net/rds/tcp.c |   20 +++++++++++++-------
 1 files changed, 13 insertions(+), 7 deletions(-)

diff --git a/net/rds/tcp.c b/net/rds/tcp.c
index fcddacc..3296a6a 100644
--- a/net/rds/tcp.c
+++ b/net/rds/tcp.c
@@ -220,7 +220,7 @@ void rds_tcp_set_callbacks(struct socket *sock, struct rds_conn_path *cp)
 	write_unlock_bh(&sock->sk->sk_callback_lock);
 }
 
-static void rds_tcp_tc_info(struct socket *sock, unsigned int len,
+static void rds_tcp_tc_info(struct socket *rds_sock, unsigned int len,
 			    struct rds_info_iterator *iter,
 			    struct rds_info_lengths *lens)
 {
@@ -229,6 +229,7 @@ static void rds_tcp_tc_info(struct socket *sock, unsigned int len,
 	unsigned long flags;
 	struct sockaddr_in sin;
 	int sinlen;
+	struct socket *sock;
 
 	spin_lock_irqsave(&rds_tcp_tc_list_lock, flags);
 
@@ -237,12 +238,17 @@ static void rds_tcp_tc_info(struct socket *sock, unsigned int len,
 
 	list_for_each_entry(tc, &rds_tcp_tc_list, t_list_item) {
 
-		sock->ops->getname(sock, (struct sockaddr *)&sin, &sinlen, 0);
-		tsinfo.local_addr = sin.sin_addr.s_addr;
-		tsinfo.local_port = sin.sin_port;
-		sock->ops->getname(sock, (struct sockaddr *)&sin, &sinlen, 1);
-		tsinfo.peer_addr = sin.sin_addr.s_addr;
-		tsinfo.peer_port = sin.sin_port;
+		sock = tc->t_sock;
+		if (sock) {
+			sock->ops->getname(sock, (struct sockaddr *)&sin,
+					   &sinlen, 0);
+			tsinfo.local_addr = sin.sin_addr.s_addr;
+			tsinfo.local_port = sin.sin_port;
+			sock->ops->getname(sock, (struct sockaddr *)&sin,
+					   &sinlen, 1);
+			tsinfo.peer_addr = sin.sin_addr.s_addr;
+			tsinfo.peer_port = sin.sin_port;
+		}
 
 		tsinfo.hdr_rem = tc->t_tinc_hdr_rem;
 		tsinfo.data_rem = tc->t_tinc_data_rem;
-- 
1.7.1
