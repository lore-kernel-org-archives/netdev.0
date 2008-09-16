From: Paul Moore <paul.moore@hp.com>
Subject: [RFC PATCH v6 02/16] selinux: Correctly handle IPv4 packets on IPv6
	sockets in all cases
Date: Tue, 16 Sep 2008 08:56:01 -0400
Message-ID: <20080916125601.17132.61002.stgit@flek.lan>
References: <20080916124722.17132.38741.stgit@flek.lan>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
To: selinux@tycho.nsa.gov, linux-security-module@vger.kernel.org,
	netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from g5t0009.atlanta.hp.com ([15.192.0.46]:44497 "EHLO
	g5t0009.atlanta.hp.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752821AbYIPM4T (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 16 Sep 2008 08:56:19 -0400
In-Reply-To: <20080916124722.17132.38741.stgit@flek.lan>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

We did the right thing in a few cases but there were several areas where we
determined a packet's address family based on the socket's address family which
is not the right thing to do since we can get IPv4 packets on IPv6 sockets.
This patch fixes these problems by either taking the address family directly
from the packet.

Signed-off-by: Paul Moore <paul.moore@hp.com>
---

 security/selinux/hooks.c |   22 +++++++++++++++++-----
 1 files changed, 17 insertions(+), 5 deletions(-)

diff --git a/security/selinux/hooks.c b/security/selinux/hooks.c
index 03fc6a8..223f474 100644
--- a/security/selinux/hooks.c
+++ b/security/selinux/hooks.c
@@ -4207,10 +4207,12 @@ static int selinux_socket_getpeersec_dgram(struct socket *sock, struct sk_buff *
 	u32 peer_secid = SECSID_NULL;
 	u16 family;
 
-	if (sock)
+	if (skb && skb->protocol == htons(ETH_P_IP))
+		family = PF_INET;
+	else if (skb && skb->protocol == htons(ETH_P_IPV6))
+		family = PF_INET6;
+	else if (sock)
 		family = sock->sk->sk_family;
-	else if (skb && skb->sk)
-		family = skb->sk->sk_family;
 	else
 		goto out;
 
@@ -4277,10 +4279,15 @@ static int selinux_inet_conn_request(struct sock *sk, struct sk_buff *skb,
 {
 	struct sk_security_struct *sksec = sk->sk_security;
 	int err;
+	u16 family = sk->sk_family;
 	u32 newsid;
 	u32 peersid;
 
-	err = selinux_skb_peerlbl_sid(skb, sk->sk_family, &peersid);
+	/* handle mapped IPv4 packets arriving via IPv6 sockets */
+	if (family == PF_INET6 && skb->protocol == htons(ETH_P_IP))
+		family = PF_INET;
+
+	err = selinux_skb_peerlbl_sid(skb, family, &peersid);
 	if (err)
 		return err;
 	if (peersid == SECSID_NULL) {
@@ -4318,9 +4325,14 @@ static void selinux_inet_csk_clone(struct sock *newsk,
 static void selinux_inet_conn_established(struct sock *sk,
 				struct sk_buff *skb)
 {
+	u16 family = sk->sk_family;
 	struct sk_security_struct *sksec = sk->sk_security;
 
-	selinux_skb_peerlbl_sid(skb, sk->sk_family, &sksec->peer_sid);
+	/* handle mapped IPv4 packets arriving via IPv6 sockets */
+	if (family == PF_INET6 && skb->protocol == htons(ETH_P_IP))
+		family = PF_INET;
+
+	selinux_skb_peerlbl_sid(skb, family, &sksec->peer_sid);
 }
 
 static void selinux_req_classify_flow(const struct request_sock *req,

