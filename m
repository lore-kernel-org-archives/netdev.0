From: Marcus Meissner <meissner@novell.com>
Subject: [PATCH] net: bind() fix error return on wrong address family
Date: Mon,  4 Jul 2011 13:30:29 +0200
Message-ID: <1309779029-15403-1-git-send-email-meissner@novell.com>
Cc: Marcus Meissner <meissner@novell.com>,
	Marcus Meissner <meissner@suse.de>, Reinhard Max <max@suse.de>
To: davem@davemloft.net, kuznet@ms2.inr.ac.ru, pekkas@netcore.fi,
	jmorris@namei.org, yoshfuji@linux-ipv6.org, kaber@trash.net,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi,

Reinhard Max also pointed out that the error should EAFNOSUPPORT according
to POSIX.

The Linux manpages have it as EINVAL, some other OSes (Minix, HPUX, perhaps BSD) use
EAFNOSUPPORT. Windows uses WSAEFAULT according to MSDN.

Other protocols error values in their af bind() methods in current mainline git as far
as a brief look shows:
	EAFNOSUPPORT: atm, appletalk, l2tp, llc, phonet, rxrpc
	EINVAL: ax25, bluetooth, decnet, econet, ieee802154, iucv, netlink, netrom, packet, rds, rose, unix, x25, 
	No check?: can/raw, ipv6/raw, irda, l2tp/l2tp_ip

Ciao, Marcus

Signed-off-by: Marcus Meissner <meissner@suse.de>
Cc: Reinhard Max <max@suse.de>
---
 net/ipv4/af_inet.c  |    4 +++-
 net/ipv6/af_inet6.c |    2 +-
 2 files changed, 4 insertions(+), 2 deletions(-)

diff --git a/net/ipv4/af_inet.c b/net/ipv4/af_inet.c
index eae1f67..ef1528a 100644
--- a/net/ipv4/af_inet.c
+++ b/net/ipv4/af_inet.c
@@ -465,8 +465,10 @@ int inet_bind(struct socket *sock, struct sockaddr *uaddr, int addr_len)
 	if (addr_len < sizeof(struct sockaddr_in))
 		goto out;
 
-	if (addr->sin_family != AF_INET)
+	if (addr->sin_family != AF_INET) {
+		err = -EAFNOSUPPORT;
 		goto out;
+	}
 
 	chk_addr_ret = inet_addr_type(sock_net(sk), addr->sin_addr.s_addr);
 
diff --git a/net/ipv6/af_inet6.c b/net/ipv6/af_inet6.c
index d450a2f..3b5669a 100644
--- a/net/ipv6/af_inet6.c
+++ b/net/ipv6/af_inet6.c
@@ -274,7 +274,7 @@ int inet6_bind(struct socket *sock, struct sockaddr *uaddr, int addr_len)
 		return -EINVAL;
 
 	if (addr->sin6_family != AF_INET6)
-		return -EINVAL;
+		return -EAFNOSUPPORT;
 
 	addr_type = ipv6_addr_type(&addr->sin6_addr);
 	if ((addr_type & IPV6_ADDR_MULTICAST) && sock->type == SOCK_STREAM)
-- 
1.7.5.4
