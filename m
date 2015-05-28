From: Thadeu Lima de Souza Cascardo <cascardo@redhat.com>
Subject: [PATCH iproute2] Fix changing tunnel remote and local address to any
Date: Thu, 28 May 2015 08:32:55 -0300
Message-ID: <1432812775-21452-1-git-send-email-cascardo@redhat.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:33311 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753490AbbE1LdF (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 28 May 2015 07:33:05 -0400
Received: from int-mx09.intmail.prod.int.phx2.redhat.com (int-mx09.intmail.prod.int.phx2.redhat.com [10.5.11.22])
	by mx1.redhat.com (Postfix) with ESMTPS id 4339F3674C3
	for <netdev@vger.kernel.org>; Thu, 28 May 2015 11:33:05 +0000 (UTC)
Received: from indiana.gru.redhat.com (ovpn-113-61.phx2.redhat.com [10.3.113.61])
	by int-mx09.intmail.prod.int.phx2.redhat.com (8.14.4/8.14.4) with ESMTP id t4SBX3cv017115
	for <netdev@vger.kernel.org>; Thu, 28 May 2015 07:33:04 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

If a tunnel is created with a local address, you can't change it to any.

 # ip tunnel add tunl1 mode ipip remote 10.16.42.37 local 10.16.42.214 ttl 64
 # ip tunnel show tunl1
 tunl1: ip/ip  remote 10.16.42.37  local 10.16.42.214  ttl 64
 # ip tunnel change tunl1 local any
 # echo $?
 0
 # ip tunnel show tunl1
 tunl1: ip/ip  remote 10.16.42.37  local 10.16.42.214  ttl 64

It happens that parse_args zeroes ip_tunnel_parm, and when creating the
tunnel, it is OK to leave it as is if the address is any. However, when
changing the tunnel, the current parameters will be read from
ip_tunnel_parm, and local and remote address won't be zeroes anymore, so
it needs to be explicitly set to any.

Signed-off-by: Thadeu Lima de Souza Cascardo <cascardo@redhat.com>
---
 ip/iptunnel.c | 4 ++++
 1 file changed, 4 insertions(+)

diff --git a/ip/iptunnel.c b/ip/iptunnel.c
index be84b83..78fa988 100644
--- a/ip/iptunnel.c
+++ b/ip/iptunnel.c
@@ -167,10 +167,14 @@ static int parse_args(int argc, char **argv, int cmd, struct ip_tunnel_parm *p)
 			NEXT_ARG();
 			if (strcmp(*argv, "any"))
 				p->iph.daddr = get_addr32(*argv);
+			else
+				p->iph.daddr = htonl(INADDR_ANY);
 		} else if (strcmp(*argv, "local") == 0) {
 			NEXT_ARG();
 			if (strcmp(*argv, "any"))
 				p->iph.saddr = get_addr32(*argv);
+			else
+				p->iph.saddr = htonl(INADDR_ANY);
 		} else if (strcmp(*argv, "dev") == 0) {
 			NEXT_ARG();
 			strncpy(medium, *argv, IFNAMSIZ-1);
-- 
2.4.1
