From: Yoshihiro Shimoda <yoshihiro.shimoda.uh@renesas.com>
Subject: [PATCH v3] packet: fix second argument of sock_tx_timestamp()
Date: Tue, 19 Jul 2016 14:40:51 +0900
Message-ID: <1468906851-8424-1-git-send-email-yoshihiro.shimoda.uh@renesas.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <daniel@iogearbox.net>, <willemb@google.com>, <ast@plumgrid.com>,
	<tklauser@distanz.ch>, <fruggeri@aristanetworks.com>,
	<netdev@vger.kernel.org>, <linux-renesas-soc@vger.kernel.org>,
	Yoshihiro Shimoda <yoshihiro.shimoda.uh@renesas.com>,
	<stable@vger.kernel.org>
To: <davem@davemloft.net>
Return-path: <linux-renesas-soc-owner@vger.kernel.org>
Sender: linux-renesas-soc-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This patch fixes an issue that a syscall (e.g. sendto syscall) cannot
work correctly. Since the sendto syscall doesn't have msg_control buffer,
the sock_tx_timestamp() in packet_snd() cannot work correctly because
the socks.tsflags is set to 0.
So, this patch sets the socks.tsflags to sk->sk_tsflags as default.

Fixes: c14ac9451c34 ("sock: enable timestamping using control messages")
Cc: <stable@vger.kernel.org>
Reported-by: Kazuya Mizuguchi <kazuya.mizuguchi.ks@renesas.com>
Reported-by: Keita Kobayashi <keita.kobayashi.ym@renesas.com>
Signed-off-by: Yoshihiro Shimoda <yoshihiro.shimoda.uh@renesas.com>
---
 Changes from v2:
  - Fix build error...

 Changes from v1:
  - Set socks.tsflags to sk->sk_tsflags as default instead of a condition.
  - Fix other socks.tsflags values in the af_packet.c.
  - Revise the commit log.

 About v1 (as RFC):
  - http://thread.gmane.org/gmane.linux.kernel.renesas-soc/5646

 net/packet/af_packet.c | 6 +++---
 1 file changed, 3 insertions(+), 3 deletions(-)

diff --git a/net/packet/af_packet.c b/net/packet/af_packet.c
index 9f0983f..53e87ce 100644
--- a/net/packet/af_packet.c
+++ b/net/packet/af_packet.c
@@ -1927,7 +1927,7 @@ retry:
 		goto out_unlock;
 	}
 
-	sockc.tsflags = 0;
+	sockc.tsflags = sk->sk_tsflags;
 	if (msg->msg_controllen) {
 		err = sock_cmsg_send(sk, msg, &sockc);
 		if (unlikely(err)) {
@@ -2678,7 +2678,7 @@ static int tpacket_snd(struct packet_sock *po, struct msghdr *msg)
 		dev = dev_get_by_index(sock_net(&po->sk), saddr->sll_ifindex);
 	}
 
-	sockc.tsflags = 0;
+	sockc.tsflags = po->sk.sk_tsflags;
 	if (msg->msg_controllen) {
 		err = sock_cmsg_send(&po->sk, msg, &sockc);
 		if (unlikely(err))
@@ -2881,7 +2881,7 @@ static int packet_snd(struct socket *sock, struct msghdr *msg, size_t len)
 	if (unlikely(!(dev->flags & IFF_UP)))
 		goto out_unlock;
 
-	sockc.tsflags = 0;
+	sockc.tsflags = sk->sk_tsflags;
 	sockc.mark = sk->sk_mark;
 	if (msg->msg_controllen) {
 		err = sock_cmsg_send(sk, msg, &sockc);
-- 
1.9.1
