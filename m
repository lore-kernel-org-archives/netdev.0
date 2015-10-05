From: David Ahern <dsa@cumulusnetworks.com>
Subject: [PATCH net-next 5/5] net: Add l3mdev saddr lookup to raw_sendmsg
Date: Mon,  5 Oct 2015 08:51:27 -0700
Message-ID: <1444060287-11024-6-git-send-email-dsa@cumulusnetworks.com>
References: <1444060287-11024-1-git-send-email-dsa@cumulusnetworks.com>
Cc: dsahern@gmail.com, David Ahern <dsa@cumulusnetworks.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f50.google.com ([209.85.220.50]:34661 "EHLO
	mail-pa0-f50.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752172AbbJEPvm (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 5 Oct 2015 11:51:42 -0400
Received: by padhy16 with SMTP id hy16so40311176pad.1
        for <netdev@vger.kernel.org>; Mon, 05 Oct 2015 08:51:42 -0700 (PDT)
In-Reply-To: <1444060287-11024-1-git-send-email-dsa@cumulusnetworks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

ping originated on box through a VRF device is showing up in tcpdump
without a source address:
    $ tcpdump -n -i vrf-blue
    08:58:33.311303 IP 0.0.0.0 > 10.2.2.254: ICMP echo request, id 2834, seq 1, length 64
    08:58:33.311562 IP 10.2.2.254 > 10.2.2.2: ICMP echo reply, id 2834, seq 1, length 64

Add the call to l3mdev_get_saddr to raw_sendmsg.

Signed-off-by: David Ahern <dsa@cumulusnetworks.com>
---
 net/ipv4/raw.c | 8 ++++++--
 1 file changed, 6 insertions(+), 2 deletions(-)

diff --git a/net/ipv4/raw.c b/net/ipv4/raw.c
index 28ef8a913130..09a07e8b2f35 100644
--- a/net/ipv4/raw.c
+++ b/net/ipv4/raw.c
@@ -484,6 +484,7 @@ static int raw_getfrag(void *from, char *to, int offset, int len, int odd,
 static int raw_sendmsg(struct sock *sk, struct msghdr *msg, size_t len)
 {
 	struct inet_sock *inet = inet_sk(sk);
+	struct net *net = sock_net(sk);
 	struct ipcm_cookie ipc;
 	struct rtable *rt = NULL;
 	struct flowi4 fl4;
@@ -543,7 +544,7 @@ static int raw_sendmsg(struct sock *sk, struct msghdr *msg, size_t len)
 	ipc.oif = sk->sk_bound_dev_if;
 
 	if (msg->msg_controllen) {
-		err = ip_cmsg_send(sock_net(sk), msg, &ipc, false);
+		err = ip_cmsg_send(net, msg, &ipc, false);
 		if (err)
 			goto out;
 		if (ipc.opt)
@@ -598,6 +599,9 @@ static int raw_sendmsg(struct sock *sk, struct msghdr *msg, size_t len)
 			    (inet->hdrincl ? FLOWI_FLAG_KNOWN_NH : 0),
 			   daddr, saddr, 0, 0);
 
+	if (!saddr && ipc.oif)
+		l3mdev_get_saddr(net, ipc.oif, &fl4);
+
 	if (!inet->hdrincl) {
 		rfv.msg = msg;
 		rfv.hlen = 0;
@@ -608,7 +612,7 @@ static int raw_sendmsg(struct sock *sk, struct msghdr *msg, size_t len)
 	}
 
 	security_sk_classify_flow(sk, flowi4_to_flowi(&fl4));
-	rt = ip_route_output_flow(sock_net(sk), &fl4, sk);
+	rt = ip_route_output_flow(net, &fl4, sk);
 	if (IS_ERR(rt)) {
 		err = PTR_ERR(rt);
 		rt = NULL;
-- 
1.9.1
