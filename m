From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [PATCH net] selinux: fix random read in
 selinux_ip_postroute_compat()
Date: Thu, 05 Nov 2015 13:39:24 -0800
Message-ID: <1446759564.4184.65.camel@edumazet-glaptop2.roam.corp.google.com>
References: <CACT4Y+ZVnfoqeJZ5cOKu70d3N9LuPMeotarKGBx-EHwYrOe-Eg@mail.gmail.com>
	 <1446752806.4184.50.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>, Paul Moore <paul@paul-moore.com>
To: Dmitry Vyukov <dvyukov@google.com>,
	David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f50.google.com ([209.85.220.50]:33714 "EHLO
	mail-pa0-f50.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751512AbbKEVj0 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 5 Nov 2015 16:39:26 -0500
Received: by pabfh17 with SMTP id fh17so98778278pab.0
        for <netdev@vger.kernel.org>; Thu, 05 Nov 2015 13:39:26 -0800 (PST)
In-Reply-To: <1446752806.4184.50.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <edumazet@google.com>

In commit e446f9dfe17b ("net: synack packets can be attached to request
sockets"), I missed one remaining case of invalid skb->sk->sk_security
access.

Dmitry Vyukov got a KASan report pointing to it.

Add selinux_skb_sk() helper that is responsible to get back to the
listener if skb is attached to a request socket, instead of
duplicating the logic.

Fixes: ca6fb0651883 ("tcp: attach SYNACK messages to request sockets instead of listener")
Signed-off-by: Eric Dumazet <edumazet@google.com>
Reported-by: Dmitry Vyukov <dvyukov@google.com>
Cc: Paul Moore <paul@paul-moore.com>
---
 security/selinux/hooks.c |   18 ++++++++++++++----
 1 file changed, 14 insertions(+), 4 deletions(-)

diff --git a/security/selinux/hooks.c b/security/selinux/hooks.c
index 26f4039d54b8..c9b2d5467477 100644
--- a/security/selinux/hooks.c
+++ b/security/selinux/hooks.c
@@ -4931,11 +4931,23 @@ static unsigned int selinux_ipv4_output(void *priv,
 	return selinux_ip_output(skb, PF_INET);
 }
 
+/* SYNACK messages might be attached to request sockets.
+ * To get back to sk_security, we need to look at the listener.
+ */
+static struct sock *selinux_skb_sk(const struct sk_buff *skb)
+{
+	struct sock *sk = skb->sk;
+
+	if (sk && sk->sk_state == TCP_NEW_SYN_RECV)
+		sk = inet_reqsk(sk)->rsk_listener;
+	return sk;
+}
+
 static unsigned int selinux_ip_postroute_compat(struct sk_buff *skb,
 						int ifindex,
 						u16 family)
 {
-	struct sock *sk = skb->sk;
+	struct sock *sk = selinux_skb_sk(skb);
 	struct sk_security_struct *sksec;
 	struct common_audit_data ad;
 	struct lsm_network_audit net = {0,};
@@ -4990,7 +5002,7 @@ static unsigned int selinux_ip_postroute(struct sk_buff *skb,
 	if (!secmark_active && !peerlbl_active)
 		return NF_ACCEPT;
 
-	sk = skb->sk;
+	sk = selinux_skb_sk(skb);
 
 #ifdef CONFIG_XFRM
 	/* If skb->dst->xfrm is non-NULL then the packet is undergoing an IPsec
@@ -5035,8 +5047,6 @@ static unsigned int selinux_ip_postroute(struct sk_buff *skb,
 		u32 skb_sid;
 		struct sk_security_struct *sksec;
 
-		if (sk->sk_state == TCP_NEW_SYN_RECV)
-			sk = inet_reqsk(sk)->rsk_listener;
 		sksec = sk->sk_security;
 		if (selinux_skb_peerlbl_sid(skb, family, &skb_sid))
 			return NF_DROP;
