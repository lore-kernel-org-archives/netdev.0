From: Li Wang <li.wang@windriver.com>
Subject: [PATCH] iputils: multiply sndbuf size by sending icmp times
Date: Wed, 3 Dec 2014 10:58:51 +0800
Message-ID: <1417575531-12856-1-git-send-email-li.wang@windriver.com>
Mime-Version: 1.0
Content-Type: text/plain
To: <hideaki.yoshifuji@miraclelinux.com>, <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail1.windriver.com ([147.11.146.13]:34804 "EHLO
	mail1.windriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750927AbaLCC7H (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 2 Dec 2014 21:59:07 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

$ ping -i 0.1 198.168.5.200 -W 1
PING 128.224.124.76 (128.224.124.76) 56(84) bytes of data.
ping: sendmsg: No buffer space available
>From 128.224.124.205 icmp_seq=1 Destination Host Unreachable

when ping a non-exist IP with same subnet,
ping will send arp packet, at first.
there is a limitation for arp packet of same ping.

for linux-2.6, the arp packet of number is 3.
so, the size of limitation is (3*sizeof(arp packet)).

for linux-3.x, the arp packet of size is 64k.
so, it maybe exceed the sock of sndbuf.
the linux kernel impoves the limitation.

when customer use "-i 0.1 -W 1" option, it will send 20 icmp packets.
at the same time, it send 20 arp packets.
it does not exceed the limitation of linux-3.x,
but, it exceeds the sock sndbuf of ping(324):
setsockopt(3, SOL_SOCKET, SO_SNDBUF, [324], 4) = 0

so, auto-resize sndbuf according to the arp packet number.

Signed-off-by: Li Wang <li.wang@windriver.com>
---
 ping.c  |    1 +
 ping6.c |    1 +
 2 files changed, 2 insertions(+)

diff --git a/ping.c b/ping.c
index c0366cd..46ca6df 100644
--- a/ping.c
+++ b/ping.c
@@ -531,6 +531,7 @@ main(int argc, char **argv)
 	 * Actually, for small datalen's it depends on kernel side a lot. */
 	hold = datalen + 8;
 	hold += ((hold+511)/512)*(optlen + 20 + 16 + 64 + 160);
+	hold *= lingertime/SCHINT(interval/2);
 	sock_setbufs(icmp_sock, hold);
 
 	if (broadcast_pings) {
diff --git a/ping6.c b/ping6.c
index 6d83462..58843a9 100644
--- a/ping6.c
+++ b/ping6.c
@@ -1086,6 +1086,7 @@ int main(int argc, char *argv[])
 	 * Actually, for small datalen's it depends on kernel side a lot. */
 	hold = datalen+8;
 	hold += ((hold+511)/512)*(40+16+64+160);
+	hold *= lingertime/SCHINT(interval/2);
 	sock_setbufs(icmp_sock, hold);
 
 #ifdef __linux__
-- 
1.7.9.5
