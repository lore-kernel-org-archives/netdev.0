From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: [PATCH 4/6] ipvs: fix bind to link-local mcast IPv6 address in backup
Date: Tue, 12 Jul 2016 18:11:00 +0200
Message-ID: <1468339862-4028-5-git-send-email-pablo@netfilter.org>
References: <1468339862-4028-1-git-send-email-pablo@netfilter.org>
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: netfilter-devel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.us.es ([193.147.175.20]:49165 "EHLO mail.us.es"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753743AbcGLQLV (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 12 Jul 2016 12:11:21 -0400
Received: from antivirus1-rhel7.int (unknown [192.168.2.11])
	by mail.us.es (Postfix) with ESMTP id 8825AE7DA0
	for <netdev@vger.kernel.org>; Tue, 12 Jul 2016 18:11:20 +0200 (CEST)
Received: from antivirus1-rhel7.int (localhost [127.0.0.1])
	by antivirus1-rhel7.int (Postfix) with ESMTP id 78568FAB52
	for <netdev@vger.kernel.org>; Tue, 12 Jul 2016 18:11:20 +0200 (CEST)
Received: from antivirus1-rhel7.int (localhost [127.0.0.1])
	by antivirus1-rhel7.int (Postfix) with ESMTP id DBE08100A4E
	for <netdev@vger.kernel.org>; Tue, 12 Jul 2016 18:11:13 +0200 (CEST)
In-Reply-To: <1468339862-4028-1-git-send-email-pablo@netfilter.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Quentin Armitage <quentin@armitage.org.uk>

When using HEAD from
https://git.kernel.org/cgit/utils/kernel/ipvsadm/ipvsadm.git/,
the command:
ipvsadm --start-daemon backup --mcast-interface eth0.60 \
    --mcast-group ff02::1:81
fails with the error message:
Argument list too long

whereas both:
ipvsadm --start-daemon master --mcast-interface eth0.60 \
    --mcast-group ff02::1:81
and:
ipvsadm --start-daemon backup --mcast-interface eth0.60 \
    --mcast-group 224.0.0.81
are successful.

The error message "Argument list too long" isn't helpful. The error occurs
because an IPv6 address is given in backup mode.

The error is in make_receive_sock() in net/netfilter/ipvs/ip_vs_sync.c,
since it fails to set the interface on the address or the socket before
calling inet6_bind() (via sock->ops->bind), where the test
'if (!sk->sk_bound_dev_if)' failed.

Setting sock->sk->sk_bound_dev_if on the socket before calling
inet6_bind() resolves the issue.

Fixes: d33288172e72 ("ipvs: add more mcast parameters for the sync daemon")
Signed-off-by: Quentin Armitage <quentin@armitage.org.uk>
Acked-by: Julian Anastasov <ja@ssi.bg>
Signed-off-by: Simon Horman <horms@verge.net.au>
---
 net/netfilter/ipvs/ip_vs_sync.c | 6 ++++--
 1 file changed, 4 insertions(+), 2 deletions(-)

diff --git a/net/netfilter/ipvs/ip_vs_sync.c b/net/netfilter/ipvs/ip_vs_sync.c
index 803001a..1b07578 100644
--- a/net/netfilter/ipvs/ip_vs_sync.c
+++ b/net/netfilter/ipvs/ip_vs_sync.c
@@ -1545,7 +1545,8 @@ error:
 /*
  *      Set up receiving multicast socket over UDP
  */
-static struct socket *make_receive_sock(struct netns_ipvs *ipvs, int id)
+static struct socket *make_receive_sock(struct netns_ipvs *ipvs, int id,
+					int ifindex)
 {
 	/* multicast addr */
 	union ipvs_sockaddr mcast_addr;
@@ -1566,6 +1567,7 @@ static struct socket *make_receive_sock(struct netns_ipvs *ipvs, int id)
 		set_sock_size(sock->sk, 0, result);
 
 	get_mcast_sockaddr(&mcast_addr, &salen, &ipvs->bcfg, id);
+	sock->sk->sk_bound_dev_if = ifindex;
 	result = sock->ops->bind(sock, (struct sockaddr *)&mcast_addr, salen);
 	if (result < 0) {
 		pr_err("Error binding to the multicast addr\n");
@@ -1868,7 +1870,7 @@ int start_sync_thread(struct netns_ipvs *ipvs, struct ipvs_sync_daemon_cfg *c,
 		if (state == IP_VS_STATE_MASTER)
 			sock = make_send_sock(ipvs, id);
 		else
-			sock = make_receive_sock(ipvs, id);
+			sock = make_receive_sock(ipvs, id, dev->ifindex);
 		if (IS_ERR(sock)) {
 			result = PTR_ERR(sock);
 			goto outtinfo;
-- 
2.1.4
