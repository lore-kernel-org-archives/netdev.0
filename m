From: Paul Moore <paul.moore@hp.com>
Subject: [RFC PATCH v5 02/14] selinux: Better local/forward check in
	selinux_ip_postroute()
Date: Fri, 05 Sep 2008 19:23:25 -0400
Message-ID: <20080905232325.31840.731.stgit@flek.lan>
References: <20080905231853.31840.57880.stgit@flek.lan>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
To: selinux@tycho.nsa.gov, netdev@vger.kernel.org,
	linux-security-module@vger.kernel.org
Return-path: <linux-security-module-owner@vger.kernel.org>
In-Reply-To: <20080905231853.31840.57880.stgit@flek.lan>
Sender: linux-security-module-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

It turns out that checking to see if skb->sk is NULL is not a very good
indicator of a forwarded packet as some locally generated packets also have
skb->sk set to NULL.  Fix this by not only checking the skb->sk field but also
the IP[6]CB(skb)->flags field for the IP[6]SKB_FORWARDED flag.  While we are
at it, we are calling selinux_parse_skb() much earlier than we really should
resulting in potentially wasted cycles parsing packets for information we
might no use; so shuffle the code around a bit to fix this.

Signed-off-by: Paul Moore <paul.moore@hp.com>
---

 security/selinux/hooks.c |  126 ++++++++++++++++++++++++++++++----------------
 1 files changed, 81 insertions(+), 45 deletions(-)

diff --git a/security/selinux/hooks.c b/security/selinux/hooks.c
index 03fc6a8..065de8c 100644
--- a/security/selinux/hooks.c
+++ b/security/selinux/hooks.c
@@ -4070,20 +4070,28 @@ static int selinux_sock_rcv_skb_iptables_compat(struct sock *sk,
 }
 
 static int selinux_sock_rcv_skb_compat(struct sock *sk, struct sk_buff *skb,
-				       struct avc_audit_data *ad,
-				       u16 family, char *addrp)
+				       u16 family)
 {
 	int err;
 	struct sk_security_struct *sksec = sk->sk_security;
 	u32 peer_sid;
 	u32 sk_sid = sksec->sid;
+	struct avc_audit_data ad;
+	char *addrp;
+
+	AVC_AUDIT_DATA_INIT(&ad, NET);
+	ad.u.net.netif = skb->iif;
+	ad.u.net.family = family;
+	err = selinux_parse_skb(skb, &ad, &addrp, 1, NULL);
+	if (err)
+		return err;
 
 	if (selinux_compat_net)
-		err = selinux_sock_rcv_skb_iptables_compat(sk, skb, ad,
+		err = selinux_sock_rcv_skb_iptables_compat(sk, skb, &ad,
 							   family, addrp);
 	else
 		err = avc_has_perm(sk_sid, skb->secmark, SECCLASS_PACKET,
-				   PACKET__RECV, ad);
+				   PACKET__RECV, &ad);
 	if (err)
 		return err;
 
@@ -4092,12 +4100,12 @@ static int selinux_sock_rcv_skb_compat(struct sock *sk, struct sk_buff *skb,
 		if (err)
 			return err;
 		err = avc_has_perm(sk_sid, peer_sid,
-				   SECCLASS_PEER, PEER__RECV, ad);
+				   SECCLASS_PEER, PEER__RECV, &ad);
 	} else {
-		err = selinux_netlbl_sock_rcv_skb(sksec, skb, family, ad);
+		err = selinux_netlbl_sock_rcv_skb(sksec, skb, family, &ad);
 		if (err)
 			return err;
-		err = selinux_xfrm_sock_rcv_skb(sksec->sid, skb, ad);
+		err = selinux_xfrm_sock_rcv_skb(sksec->sid, skb, &ad);
 	}
 
 	return err;
@@ -4111,6 +4119,8 @@ static int selinux_socket_sock_rcv_skb(struct sock *sk, struct sk_buff *skb)
 	u32 sk_sid = sksec->sid;
 	struct avc_audit_data ad;
 	char *addrp;
+	u8 secmark_active;
+	u8 peerlbl_active;
 
 	if (family != PF_INET && family != PF_INET6)
 		return 0;
@@ -4119,6 +4129,18 @@ static int selinux_socket_sock_rcv_skb(struct sock *sk, struct sk_buff *skb)
 	if (family == PF_INET6 && skb->protocol == htons(ETH_P_IP))
 		family = PF_INET;
 
+	/* If any sort of compatibility mode is enabled then handoff processing
+	 * to the selinux_sock_rcv_skb_compat() function to deal with the
+	 * special handling.  We do this in an attempt to keep this function
+	 * as fast and as clean as possible. */
+	if (selinux_compat_net || !selinux_policycap_netpeer)
+		return selinux_sock_rcv_skb_compat(sk, skb, family);
+
+	secmark_active = selinux_secmark_enabled();
+	peerlbl_active = netlbl_enabled() || selinux_xfrm_enabled();
+	if (!secmark_active && !peerlbl_active)
+		return 0;
+
 	AVC_AUDIT_DATA_INIT(&ad, NET);
 	ad.u.net.netif = skb->iif;
 	ad.u.net.family = family;
@@ -4126,15 +4148,7 @@ static int selinux_socket_sock_rcv_skb(struct sock *sk, struct sk_buff *skb)
 	if (err)
 		return err;
 
-	/* If any sort of compatibility mode is enabled then handoff processing
-	 * to the selinux_sock_rcv_skb_compat() function to deal with the
-	 * special handling.  We do this in an attempt to keep this function
-	 * as fast and as clean as possible. */
-	if (selinux_compat_net || !selinux_policycap_netpeer)
-		return selinux_sock_rcv_skb_compat(sk, skb, &ad,
-						   family, addrp);
-
-	if (netlbl_enabled() || selinux_xfrm_enabled()) {
+	if (peerlbl_active) {
 		u32 peer_sid;
 
 		err = selinux_skb_peerlbl_sid(skb, family, &peer_sid);
@@ -4148,7 +4162,7 @@ static int selinux_socket_sock_rcv_skb(struct sock *sk, struct sk_buff *skb)
 				   PEER__RECV, &ad);
 	}
 
-	if (selinux_secmark_enabled()) {
+	if (secmark_active) {
 		err = avc_has_perm(sk_sid, skb->secmark, SECCLASS_PACKET,
 				   PACKET__RECV, &ad);
 		if (err)
@@ -4384,15 +4398,15 @@ static unsigned int selinux_ip_forward(struct sk_buff *skb, int ifindex,
 	if (!secmark_active && !peerlbl_active)
 		return NF_ACCEPT;
 
+	if (selinux_skb_peerlbl_sid(skb, family, &peer_sid) != 0)
+		return NF_DROP;
+
 	AVC_AUDIT_DATA_INIT(&ad, NET);
 	ad.u.net.netif = ifindex;
 	ad.u.net.family = family;
 	if (selinux_parse_skb(skb, &ad, &addrp, 1, NULL) != 0)
 		return NF_DROP;
 
-	if (selinux_skb_peerlbl_sid(skb, family, &peer_sid) != 0)
-		return NF_DROP;
-
 	if (peerlbl_active)
 		if (selinux_inet_sys_rcv_skb(ifindex, addrp, family,
 					     peer_sid, &ad) != 0)
@@ -4493,30 +4507,36 @@ static int selinux_ip_postroute_iptables_compat(struct sock *sk,
 
 static unsigned int selinux_ip_postroute_compat(struct sk_buff *skb,
 						int ifindex,
-						struct avc_audit_data *ad,
-						u16 family,
-						char *addrp,
-						u8 proto)
+						u16 family)
 {
 	struct sock *sk = skb->sk;
 	struct sk_security_struct *sksec;
+	struct avc_audit_data ad;
+	char *addrp;
+	u8 proto;
 
 	if (sk == NULL)
 		return NF_ACCEPT;
 	sksec = sk->sk_security;
 
+	AVC_AUDIT_DATA_INIT(&ad, NET);
+	ad.u.net.netif = ifindex;
+	ad.u.net.family = family;
+	if (selinux_parse_skb(skb, &ad, &addrp, 0, &proto))
+		return NF_DROP;
+
 	if (selinux_compat_net) {
 		if (selinux_ip_postroute_iptables_compat(skb->sk, ifindex,
-							 ad, family, addrp))
+							 &ad, family, addrp))
 			return NF_DROP;
 	} else {
 		if (avc_has_perm(sksec->sid, skb->secmark,
-				 SECCLASS_PACKET, PACKET__SEND, ad))
+				 SECCLASS_PACKET, PACKET__SEND, &ad))
 			return NF_DROP;
 	}
 
 	if (selinux_policycap_netpeer)
-		if (selinux_xfrm_postroute_last(sksec->sid, skb, ad, proto))
+		if (selinux_xfrm_postroute_last(sksec->sid, skb, &ad, proto))
 			return NF_DROP;
 
 	return NF_ACCEPT;
@@ -4530,23 +4550,15 @@ static unsigned int selinux_ip_postroute(struct sk_buff *skb, int ifindex,
 	struct sock *sk;
 	struct avc_audit_data ad;
 	char *addrp;
-	u8 proto;
 	u8 secmark_active;
 	u8 peerlbl_active;
 
-	AVC_AUDIT_DATA_INIT(&ad, NET);
-	ad.u.net.netif = ifindex;
-	ad.u.net.family = family;
-	if (selinux_parse_skb(skb, &ad, &addrp, 0, &proto))
-		return NF_DROP;
-
 	/* If any sort of compatibility mode is enabled then handoff processing
 	 * to the selinux_ip_postroute_compat() function to deal with the
 	 * special handling.  We do this in an attempt to keep this function
 	 * as fast and as clean as possible. */
 	if (selinux_compat_net || !selinux_policycap_netpeer)
-		return selinux_ip_postroute_compat(skb, ifindex, &ad,
-						   family, addrp, proto);
+		return selinux_ip_postroute_compat(skb, ifindex, family);
 
 	/* If skb->dst->xfrm is non-NULL then the packet is undergoing an IPsec
 	 * packet transformation so allow the packet to pass without any checks
@@ -4562,21 +4574,45 @@ static unsigned int selinux_ip_postroute(struct sk_buff *skb, int ifindex,
 	if (!secmark_active && !peerlbl_active)
 		return NF_ACCEPT;
 
-	/* if the packet is locally generated (skb->sk != NULL) then use the
-	 * socket's label as the peer label, otherwise the packet is being
-	 * forwarded through this system and we need to fetch the peer label
-	 * directly from the packet */
+	/* if the packet is being forwarded then get the peer label from the
+	 * packet itself; otherwise check to see if it is from a local
+	 * application or the kernel, if from an application get the peer label
+	 * from the sending socket, otherwise use the kernel's sid */
 	sk = skb->sk;
-	if (sk) {
+	if (sk == NULL) {
+		switch (family) {
+		case PF_INET:
+			if (IPCB(skb)->flags & IPSKB_FORWARDED)
+				secmark_perm = PACKET__FORWARD_OUT;
+			else
+				secmark_perm = PACKET__SEND;
+			break;
+		case PF_INET6:
+			if (IP6CB(skb)->flags & IP6SKB_FORWARDED)
+				secmark_perm = PACKET__FORWARD_OUT;
+			else
+				secmark_perm = PACKET__SEND;
+			break;
+		default:
+			return NF_DROP;
+		}
+		if (secmark_perm == PACKET__FORWARD_OUT) {
+			if (selinux_skb_peerlbl_sid(skb, family, &peer_sid))
+				return NF_DROP;
+		} else
+			peer_sid = SECINITSID_KERNEL;
+	} else {
 		struct sk_security_struct *sksec = sk->sk_security;
 		peer_sid = sksec->sid;
 		secmark_perm = PACKET__SEND;
-	} else {
-		if (selinux_skb_peerlbl_sid(skb, family, &peer_sid))
-				return NF_DROP;
-		secmark_perm = PACKET__FORWARD_OUT;
 	}
 
+	AVC_AUDIT_DATA_INIT(&ad, NET);
+	ad.u.net.netif = ifindex;
+	ad.u.net.family = family;
+	if (selinux_parse_skb(skb, &ad, &addrp, 0, NULL))
+		return NF_DROP;
+
 	if (secmark_active)
 		if (avc_has_perm(peer_sid, skb->secmark,
 				 SECCLASS_PACKET, secmark_perm, &ad))

