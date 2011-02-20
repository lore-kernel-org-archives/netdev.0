From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] route_bench: Filter out all responses.
Date: Sun, 20 Feb 2011 14:32:48 -0800 (PST)
Message-ID: <20110220.143248.260098148.davem@davemloft.net>
References: <20110220.140450.48516784.davem@davemloft.net>
	<4D61957F.5060905@netfilter.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: pablo@netfilter.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:41965
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1755246Ab1BTWcL (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 20 Feb 2011 17:32:11 -0500
In-Reply-To: <4D61957F.5060905@netfilter.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Pablo Neira Ayuso <pablo@netfilter.org>
Date: Sun, 20 Feb 2011 23:28:15 +0100

> You can use:
> 
> extern int mnl_socket_get_fd(const struct mnl_socket *nl);
> 
> Thus, you can invoke setsockopt directly ;-).

Thank you, I didn't notice that interface.

I'll check in the following.

--------------------
route_bench: Remove knowledge of libmnl internals, not needed.

Since mnl_socket_get_fd() exists, we can use that.

Thanks to Pablo.

Signed-off-by: David S. Miller <davem@davemloft.net>
---
 route_bench.c |   13 ++-----------
 1 files changed, 2 insertions(+), 11 deletions(-)

diff --git a/route_bench.c b/route_bench.c
index 6c6b525..063b15e 100644
--- a/route_bench.c
+++ b/route_bench.c
@@ -24,16 +24,6 @@
 #include <linux/rtnetlink.h>
 #include <linux/filter.h>
 
-/* XXX Ugly knowledge of internals, but there is currently no way
- * XXX provided by the libmnl library to set socket options that are
- * XXX of level other than SOL_NETLINK.   And we need to set one of
- * XXX level SOL_SOCKET to install the socket filter.
- */
-struct mnl_socket {
-	int 			fd;
-	struct sockaddr_nl	addr;
-};
-
 static int usage(void)
 {
 	printf("usage: route_bench [ -o ] [ -l count ]\n");
@@ -178,7 +168,8 @@ static int do_bench(int count, in_addr_t src_addr, in_addr_t dst_addr,
 
 	portid = mnl_socket_get_portid(nl);
 
-	err = setsockopt(nl->fd, SOL_SOCKET, SO_ATTACH_FILTER, &filter, sizeof(filter));
+	err = setsockopt(mnl_socket_get_fd(nl), SOL_SOCKET,
+			 SO_ATTACH_FILTER, &filter, sizeof(filter));
 	if (err) {
 		perror("setsockopt");
 		return -1;
-- 
1.7.4.1

