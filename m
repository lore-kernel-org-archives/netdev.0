From: "Denis V. Lunev" <den@openvz.org>
Subject: [PATCH net-2.6] [RAW]: Raw socket leak.
Date: Fri, 30 May 2008 17:43:05 +0400
Message-ID: <1212154985-28103-1-git-send-email-den@openvz.org>
Cc: netdev@vger.kernel.org, "Denis V. Lunev" <den@openvz.org>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailhub.sw.ru ([195.214.232.25]:19864 "EHLO relay.sw.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751689AbYE3Nmj (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 30 May 2008 09:42:39 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The program below just leaks the raw kernel socket

int main() {
        int fd = socket(PF_INET, SOCK_RAW, IPPROTO_UDP);
        struct sockaddr_in addr;

        memset(&addr, 0, sizeof(addr));
        inet_aton("127.0.0.1", &addr.sin_addr);
        addr.sin_family = AF_INET;
        addr.sin_port = htons(2048);
        sendto(fd,  "a", 1, MSG_MORE, &addr, sizeof(addr));
        return 0;
}

Corked packet is allocated via sock_wmalloc which holds the owner socket,
so one should uncork it and flush all pending data on close. Do this in the
same way as in UDP.

Signed-off-by: Denis V. Lunev <den@openvz.org>
Acked-by: Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>
---
 net/ipv4/raw.c |    9 +++++++++
 net/ipv6/raw.c |    9 +++++++++
 2 files changed, 18 insertions(+), 0 deletions(-)

diff --git a/net/ipv4/raw.c b/net/ipv4/raw.c
index fead049..e7e091d 100644
--- a/net/ipv4/raw.c
+++ b/net/ipv4/raw.c
@@ -608,6 +608,14 @@ static void raw_close(struct sock *sk, long timeout)
 	sk_common_release(sk);
 }
 
+static int raw_destroy(struct sock *sk)
+{
+	lock_sock(sk);
+	ip_flush_pending_frames(sk);
+	release_sock(sk);
+	return 0;
+}
+
 /* This gets rid of all the nasties in af_inet. -DaveM */
 static int raw_bind(struct sock *sk, struct sockaddr *uaddr, int addr_len)
 {
@@ -820,6 +828,7 @@ struct proto raw_prot = {
 	.name		   = "RAW",
 	.owner		   = THIS_MODULE,
 	.close		   = raw_close,
+	.destroy	   = raw_destroy,
 	.connect	   = ip4_datagram_connect,
 	.disconnect	   = udp_disconnect,
 	.ioctl		   = raw_ioctl,
diff --git a/net/ipv6/raw.c b/net/ipv6/raw.c
index 232e0dc..a9deade 100644
--- a/net/ipv6/raw.c
+++ b/net/ipv6/raw.c
@@ -1164,6 +1164,14 @@ static void rawv6_close(struct sock *sk, long timeout)
 	sk_common_release(sk);
 }
 
+static int raw6_destroy(struct sock *sk)
+{
+	lock_sock(sk);
+	ip6_flush_pending_frames(sk);
+	release_sock(sk);
+	return 0;
+}
+
 static int rawv6_init_sk(struct sock *sk)
 {
 	struct raw6_sock *rp = raw6_sk(sk);
@@ -1187,6 +1195,7 @@ struct proto rawv6_prot = {
 	.name		   = "RAWv6",
 	.owner		   = THIS_MODULE,
 	.close		   = rawv6_close,
+	.destroy	   = raw6_destroy,
 	.connect	   = ip6_datagram_connect,
 	.disconnect	   = udp_disconnect,
 	.ioctl		   = rawv6_ioctl,
-- 
1.5.3.rc5

