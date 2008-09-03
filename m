From: Paul Moore <paul.moore@hp.com>
Subject: [RFC PATCH v4 02/14] selinux: Better local/forward check in
	selinux_ip_postroute()
Date: Tue, 02 Sep 2008 20:48:54 -0400
Message-ID: <20080903004854.15669.95990.stgit@flek.lan>
References: <20080903003647.15669.45349.stgit@flek.lan>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
To: selinux@tycho.nsa.gov, netdev@vger.kernel.org,
	linux-security-module@vger.kernel.org
Return-path: <linux-security-module-owner@vger.kernel.org>
In-Reply-To: <20080903003647.15669.45349.stgit@flek.lan>
Sender: linux-security-module-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

It turns out that checking to see if skb->sk is NULL is not a very good
indicator of a forwarded packet as some locally generated packets also have
skb->sk set to NULL.  Fix this by not only checking the skb->sk field but also
the IP[6]CB(skb)->flags field for the IP[6]SKB_FORWARDED flag.

Signed-off-by: Paul Moore <paul.moore@hp.com>
---

 security/selinux/hooks.c |   36 +++++++++++++++++++++++++++---------
 1 files changed, 27 insertions(+), 9 deletions(-)

diff --git a/security/selinux/hooks.c b/security/selinux/hooks.c
index 03fc6a8..995488d 100644
--- a/security/selinux/hooks.c
+++ b/security/selinux/hooks.c
@@ -4562,19 +4562,37 @@ static unsigned int selinux_ip_postroute(struct sk_buff *skb, int ifindex,
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
 
 	if (secmark_active)

