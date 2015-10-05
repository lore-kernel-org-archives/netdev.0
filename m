From: David Ahern <dsa@cumulusnetworks.com>
Subject: [PATCH net-next] net: Fix vti use case with oif in dst lookups for IPv6
Date: Mon,  5 Oct 2015 08:32:51 -0600
Message-ID: <1444055571-82546-1-git-send-email-dsa@cumulusnetworks.com>
Cc: steffen.klassert@secunet.com, David Ahern <dsa@cumulusnetworks.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f54.google.com ([209.85.220.54]:33535 "EHLO
	mail-pa0-f54.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751027AbbJEOdQ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 5 Oct 2015 10:33:16 -0400
Received: by pacex6 with SMTP id ex6so178983429pac.0
        for <netdev@vger.kernel.org>; Mon, 05 Oct 2015 07:33:15 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

It occurred to me yesterday that 741a11d9e4103 ("net: ipv6: Add
RT6_LOOKUP_F_IFACE flag if oif is set") means that xfrm6_dst_lookup
needs the FLOWI_FLAG_SKIP_NH_OIF flag set. This latest commit causes
the oif to be considered in lookups which is known to break vti. This
explains why 58189ca7b274 did not the IPv6 change at the time it was
submitted.

Fixes: 42a7b32b73d6 ("xfrm: Add oif to dst lookups")
Signed-off-by: David Ahern <dsa@cumulusnetworks.com>
---
This is needed in 4.3.

 net/ipv6/xfrm6_policy.c | 1 +
 1 file changed, 1 insertion(+)

diff --git a/net/ipv6/xfrm6_policy.c b/net/ipv6/xfrm6_policy.c
index 30caa289c5db..5cedfda4b241 100644
--- a/net/ipv6/xfrm6_policy.c
+++ b/net/ipv6/xfrm6_policy.c
@@ -37,6 +37,7 @@ static struct dst_entry *xfrm6_dst_lookup(struct net *net, int tos, int oif,
 
 	memset(&fl6, 0, sizeof(fl6));
 	fl6.flowi6_oif = oif;
+	fl6.flowi6_flags = FLOWI_FLAG_SKIP_NH_OIF;
 	memcpy(&fl6.daddr, daddr, sizeof(fl6.daddr));
 	if (saddr)
 		memcpy(&fl6.saddr, saddr, sizeof(fl6.saddr));
-- 
1.9.1
