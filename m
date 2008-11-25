From: Eric Dumazet <dada1@cosmosbay.com>
Subject: [PATCH]  net: udp_unhash() can test if sk is hashed
Date: Tue, 25 Nov 2008 21:25:55 +0100
Message-ID: <492C5F53.2090901@cosmosbay.com>
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="------------010909000500010601020709"
Cc: Linux Netdev List <netdev@vger.kernel.org>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from gw1.cosmosbay.com ([86.65.150.130]:36556 "EHLO
	gw1.cosmosbay.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751119AbYKYU0A (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 25 Nov 2008 15:26:00 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This is a multi-part message in MIME format.
--------------010909000500010601020709
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit

Impact: Optimization

Like done in inet_unhash(), we can avoid taking a chain lock if
socket is not hashed in udp_unhash()

Triggered by close(socket(AF_INET, SOCK_DGRAM, 0));

Signed-off-by: Eric Dumazet <dada1@cosmosbay.com>
---
 net/ipv4/udp.c |   18 ++++++++++--------
 1 files changed, 10 insertions(+), 8 deletions(-)

--------------010909000500010601020709
Content-Type: text/plain;
 name="udp_unhash.patch"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="udp_unhash.patch"

diff --git a/net/ipv4/udp.c b/net/ipv4/udp.c
index da869ce..e2ab258 100644
--- a/net/ipv4/udp.c
+++ b/net/ipv4/udp.c
@@ -970,16 +970,18 @@ int udp_disconnect(struct sock *sk, int flags)
 
 void udp_lib_unhash(struct sock *sk)
 {
-	struct udp_table *udptable = sk->sk_prot->h.udp_table;
-	unsigned int hash = udp_hashfn(sock_net(sk), sk->sk_hash);
-	struct udp_hslot *hslot = &udptable->hash[hash];
+	if (sk_hashed(sk)) {
+		struct udp_table *udptable = sk->sk_prot->h.udp_table;
+		unsigned int hash = udp_hashfn(sock_net(sk), sk->sk_hash);
+		struct udp_hslot *hslot = &udptable->hash[hash];
 
-	spin_lock_bh(&hslot->lock);
-	if (sk_nulls_del_node_init_rcu(sk)) {
-		inet_sk(sk)->num = 0;
-		sock_prot_inuse_add(sock_net(sk), sk->sk_prot, -1);
+		spin_lock_bh(&hslot->lock);
+		if (sk_nulls_del_node_init_rcu(sk)) {
+			inet_sk(sk)->num = 0;
+			sock_prot_inuse_add(sock_net(sk), sk->sk_prot, -1);
+		}
+		spin_unlock_bh(&hslot->lock);
 	}
-	spin_unlock_bh(&hslot->lock);
 }
 EXPORT_SYMBOL(udp_lib_unhash);
 

--------------010909000500010601020709--
