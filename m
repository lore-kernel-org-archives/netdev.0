From: Marcus Meissner <meissner@suse.de>
Subject: Bad behaviour when unintentionally mixing ipv4 and ipv6 addresses
Date: Wed, 25 May 2011 17:59:18 +0200
Message-ID: <20110525155918.GA27869@suse.de>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="dDRMvlgZJXvWKvBx"
Cc: max@suse.de
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from cantor.suse.de ([195.135.220.2]:59221 "EHLO mx1.suse.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757475Ab1EYP7T (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 25 May 2011 11:59:19 -0400
Received: from relay2.suse.de (charybdis-ext.suse.de [195.135.221.2])
	(using TLSv1 with cipher DHE-RSA-AES256-SHA (256/256 bits))
	(No client certificate requested)
	by mx1.suse.de (Postfix) with ESMTP id 4BBFD8E8CC
	for <netdev@vger.kernel.org>; Wed, 25 May 2011 17:59:18 +0200 (CEST)
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--dDRMvlgZJXvWKvBx
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline

Hi,

By chance Reinhard Max spotted an interesting flaw in Linux bind(2)...

If you create a IPv4 socket and then incorrectly bind(2) to a IPv6 address
(which you got from getaddrinfo(3) or similar), the socket will be bound
to INADDR_ANY.

The reason is that the kernel just takes the sockaddr_in6 struct and
evaluates it as a sockaddr_in struct, with the port being OK, but the IPv4
sin_addr overlaying the IPv6 sin6_flowinfo field.

As the sin6_flowinfo field is usually 0, your service can end up listening
to the world.

A testprogram that you can strace is attached, run netstat -apn |grep 12345
afterwards to see it binds 0.0.0.0:12345.

Perhaps add a check like the one below? (untested)
Or use if (addr->sin_family == AF_INET6) to just catch the IPv6 case?

Ciao, Marcus


Subject: [PATCH] net/ipv4: Check for mistakenly passed in non-IPv4 address

Hi,

Check against mistakenly passing in IPv6 addresses (which would result
in an INADDR_ANY bind) or similar incompatible sockaddrs.

Ciao, Marcus

Signed-off-by: Marcus Meissner <meissner@suse.de>
Cc: Reinhard Max <max@suse.de>
---
 net/ipv4/af_inet.c |    3 +++
 1 files changed, 3 insertions(+), 0 deletions(-)

diff --git a/net/ipv4/af_inet.c b/net/ipv4/af_inet.c
index cc14631..9c19260 100644
--- a/net/ipv4/af_inet.c
+++ b/net/ipv4/af_inet.c
@@ -465,6 +465,9 @@ int inet_bind(struct socket *sock, struct sockaddr *uaddr, int addr_len)
 	if (addr_len < sizeof(struct sockaddr_in))
 		goto out;
 
+	if (addr->sin_family != AF_INET)
+		goto out;
+
 	chk_addr_ret = inet_addr_type(sock_net(sk), addr->sin_addr.s_addr);
 
 	/* Not specified by any standard per-se, however it breaks too
-- 
1.7.4.1


--dDRMvlgZJXvWKvBx
Content-Type: text/x-c++src; charset=us-ascii
Content-Disposition: attachment; filename="xx.c"

#include <stdio.h>
#include <stdlib.h>
#include <netinet/in.h>
#include <unistd.h>
#include <string.h>
int main(int argc, char **argv) {
	int			fd,fd2;
	struct sockaddr_in6	saddrin,saddrin2;
	size_t			len;

	fd = socket(AF_INET,SOCK_STREAM,0);
	if (fd == -1) {
		perror("socket");
		exit(1);
	}
	memset(&saddrin,0,sizeof(saddrin));

	/*memcpy(&saddrin.sin6_addr, &in6addr_loopback, sizeof(saddrin.sin6_addr));*/
	memset(&saddrin.sin6_addr, 0x42, sizeof(saddrin.sin6_addr));

	saddrin.sin6_family = AF_INET6;
	saddrin.sin6_port = htons(12345);
	if (-1 == bind(fd, (struct sockaddr*)&saddrin, sizeof(saddrin))) {
		perror("bind");
		exit(1);
	}
	if (-1 == listen(fd, 5)) {
		perror("listen");
		exit(1);
	}
	len  = sizeof(saddrin2);
	fd2 = accept (fd, (struct sockaddr*)&saddrin2, &len);
	if (fd2 == -1) perror("accept");
	close(fd);
	return 0;
}

--dDRMvlgZJXvWKvBx--
