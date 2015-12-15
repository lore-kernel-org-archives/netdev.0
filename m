From: Paolo Abeni <pabeni@redhat.com>
Subject: [PATCH iproute2] lwtunnel: fix argument parsing
Date: Tue, 15 Dec 2015 12:18:04 +0100
Message-ID: <f105b591ec43f65607f9d08d46af4612bb75e8cd.1450178247.git.pabeni@redhat.com>
Cc: netdev@vger.kernel.org, Roopa Prabhu <roopa@cumulusnetworks.com>
To: shemming@brocade.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:50142 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S964994AbbLOLSW (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 15 Dec 2015 06:18:22 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Currently parse_encap_ip() does not update correctly argv/argc;
if multiple lwtunnel arguments are provided, the parsing fails after
the first one, i.e.

 ip route add 172.16.101.0/24 dev vxlan1 encap ip id 42 dst 192.168.255.1

fails with:

 Error: either "to" is duplicate, or "dst" is a garbage.

This commit addresses the issue, stepping to next argument at each iteration
of the parsing loop.

Fixes: 1e5293056a02 ("lwtunnel: Add encapsulation support to ip route")
Signed-off-by: Paolo Abeni <pabeni@redhat.com>
---
 ip/iproute_lwtunnel.c | 8 ++++++--
 1 file changed, 6 insertions(+), 2 deletions(-)

diff --git a/ip/iproute_lwtunnel.c b/ip/iproute_lwtunnel.c
index 63322a1..c825b82 100644
--- a/ip/iproute_lwtunnel.c
+++ b/ip/iproute_lwtunnel.c
@@ -178,10 +178,14 @@ static int parse_encap_ip(struct rtattr *rta, size_t len, int *argcp, char ***ar
 		} else {
 			break;
 		}
+		argc--; argv++;
 	}
 
-	*argcp = argc;
-	*argvp = argv;
+	/* argv is currently the first unparsed argument,
+	 * but the lwt_parse_encap() caller will move to the next,
+	 * so step back */
+	*argcp = argc + 1;
+	*argvp = argv - 1;
 
 	return 0;
 }
-- 
1.8.3.1
