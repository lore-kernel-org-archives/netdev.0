From: paul.moore@hp.com
Subject: [PATCH 05/13] NetLabel: check for a CIPSOv4 option before we do call into the CIPSOv4 layer
Date: Fri, 17 Nov 2006 17:38:47 -0500
Message-ID: <20061117224333.829365000@hp.com>
References: <20061117223842.399078000@hp.com>
Cc: jmorris@namei.org, Paul Moore <paul.moore@hp.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from atlrel8.hp.com ([156.153.255.206]:9389 "EHLO atlrel8.hp.com")
	by vger.kernel.org with ESMTP id S1755988AbWKQWnf (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 17 Nov 2006 17:43:35 -0500
To: netdev@vger.kernel.org, selinux@tycho.nsa.gov
Content-Disposition: inline; filename=netlabel-cipso_earlycheck
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Paul Moore <paul.moore@hp.com>

Right now the NetLabel code always jumps into the CIPSOv4 layer to determine if
a CIPSO IP option is present.  However, we can do this check directly in the
NetLabel code by making use of the CIPSO_V4_OPTEXIST() macro which should save
us a function call in the common case of not having a CIPSOv4 option present.

Signed-off-by: Paul Moore <paul.moore@hp.com>
---
 net/ipv4/cipso_ipv4.c        |    2 --
 net/netlabel/netlabel_kapi.c |    6 ++----
 2 files changed, 2 insertions(+), 6 deletions(-)

Index: net-2.6.20_netlabel-base-work/net/ipv4/cipso_ipv4.c
===================================================================
--- net-2.6.20_netlabel-base-work.orig/net/ipv4/cipso_ipv4.c
+++ net-2.6.20_netlabel-base-work/net/ipv4/cipso_ipv4.c
@@ -1436,8 +1436,6 @@ int cipso_v4_skbuff_getattr(const struct
 	u32 doi;
 	struct cipso_v4_doi *doi_def;
 
-	if (!CIPSO_V4_OPTEXIST(skb))
-		return -ENOMSG;
 	cipso_ptr = CIPSO_V4_OPTPTR(skb);
 	if (cipso_v4_cache_check(cipso_ptr, cipso_ptr[1], secattr) == 0)
 		return 0;
Index: net-2.6.20_netlabel-base-work/net/netlabel/netlabel_kapi.c
===================================================================
--- net-2.6.20_netlabel-base-work.orig/net/netlabel/netlabel_kapi.c
+++ net-2.6.20_netlabel-base-work/net/netlabel/netlabel_kapi.c
@@ -149,10 +149,8 @@ int netlbl_socket_getattr(const struct s
 int netlbl_skbuff_getattr(const struct sk_buff *skb,
 			  struct netlbl_lsm_secattr *secattr)
 {
-	int ret_val;
-
-	ret_val = cipso_v4_skbuff_getattr(skb, secattr);
-	if (ret_val == 0)
+	if (CIPSO_V4_OPTEXIST(skb) &&
+	    cipso_v4_skbuff_getattr(skb, secattr) == 0)
 		return 0;
 
 	return netlbl_unlabel_getattr(secattr);

--
paul moore
linux security @ hp
