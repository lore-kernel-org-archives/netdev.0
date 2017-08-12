From: Phil Sutter <phil@nwl.cc>
Subject: [iproute PATCH 12/51] iproute_lwtunnel: csum_mode value checking was ineffective
Date: Sat, 12 Aug 2017 14:04:31 +0200
Message-ID: <20170812120510.28750-13-phil@nwl.cc>
References: <20170812120510.28750-1-phil@nwl.cc>
Cc: netdev@vger.kernel.org
To: Stephen Hemminger <stephen@networkplumber.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from orbyte.nwl.cc ([151.80.46.58]:44375 "EHLO mail.nwl.cc"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1752249AbdHLMKF (ORCPT <rfc822;netdev@vger.kernel.org>);
        Sat, 12 Aug 2017 08:10:05 -0400
In-Reply-To: <20170812120510.28750-1-phil@nwl.cc>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

ila_csum_name2mode() returning -1 on error but being declared as
returning __u8 doesn't make much sense. Change the code to correctly
detect this issue. Checking for __u8 overruns shouldn't be necessary
though since ila_csum_name2mode() return values are well-defined.

Signed-off-by: Phil Sutter <phil@nwl.cc>
---
 ip/iproute_lwtunnel.c | 7 ++++---
 1 file changed, 4 insertions(+), 3 deletions(-)

diff --git a/ip/iproute_lwtunnel.c b/ip/iproute_lwtunnel.c
index 5c0c7d110d23e..398ab5e077ed8 100644
--- a/ip/iproute_lwtunnel.c
+++ b/ip/iproute_lwtunnel.c
@@ -171,7 +171,7 @@ static char *ila_csum_mode2name(__u8 csum_mode)
 	}
 }
 
-static __u8 ila_csum_name2mode(char *name)
+static int ila_csum_name2mode(char *name)
 {
 	if (strcmp(name, "adj-transport") == 0)
 		return ILA_CSUM_ADJUST_TRANSPORT;
@@ -517,7 +517,7 @@ static int parse_encap_ila(struct rtattr *rta, size_t len,
 
 	while (argc > 0) {
 		if (strcmp(*argv, "csum-mode") == 0) {
-			__u8 csum_mode;
+			int csum_mode;
 
 			NEXT_ARG();
 
@@ -526,7 +526,8 @@ static int parse_encap_ila(struct rtattr *rta, size_t len,
 				invarg("\"csum-mode\" value is invalid\n",
 				       *argv);
 
-			rta_addattr8(rta, 1024, ILA_ATTR_CSUM_MODE, csum_mode);
+			rta_addattr8(rta, 1024, ILA_ATTR_CSUM_MODE,
+				     (__u8)csum_mode);
 
 			argc--; argv++;
 		} else {
-- 
2.13.1
