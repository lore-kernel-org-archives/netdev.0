From: Daniel Borkmann <daniel@iogearbox.net>
Subject: [PATCH net 3/3] ipv6, trace: fix tos reporting on fib6_table_lookup
Date: Fri, 18 Mar 2016 18:37:59 +0100
Message-ID: <d8639d9c343d1f2310904abafd21ef7f71e2609e.1458320940.git.daniel@iogearbox.net>
References: <cover.1458320940.git.daniel@iogearbox.net>
Cc: jbenc@redhat.com, linville@tuxdriver.com, jesse@kernel.org,
	dsa@cumulusnetworks.com, alexei.starovoitov@gmail.com,
	netdev@vger.kernel.org, Daniel Borkmann <daniel@iogearbox.net>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from www62.your-server.de ([213.133.104.62]:53371 "EHLO
	www62.your-server.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754974AbcCRRiS (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 18 Mar 2016 13:38:18 -0400
In-Reply-To: <cover.1458320940.git.daniel@iogearbox.net>
In-Reply-To: <cover.1458320940.git.daniel@iogearbox.net>
References: <cover.1458320940.git.daniel@iogearbox.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

flowi6_tos of struct flowi6 is unused in IPv6, therefore dumping tos on
that tracepoint will also give incorrect information wrt traffic class.

If we want to fix it, we need to extract it via ip6_tclass(flp->flowlabel).
While for the same test case I get a count of 0 non-zero tos values before
the change, they now start to show up after the change:

  # ./perf record -e fib6:fib6_table_lookup -a sleep 10
  # ./perf script | grep -v "tos 0" | wc -l
  60

Since there's no user in the kernel tree anymore of flowi6_tos, remove the
define to avoid any future confusion on this.

Fixes: b811580d91e9 ("net: IPv6 fib lookup tracepoint")
Signed-off-by: Daniel Borkmann <daniel@iogearbox.net>
---
 include/net/flow.h          | 2 +-
 include/trace/events/fib6.h | 2 +-
 2 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/include/net/flow.h b/include/net/flow.h
index 83969ee..d47ef4b 100644
--- a/include/net/flow.h
+++ b/include/net/flow.h
@@ -127,7 +127,6 @@ struct flowi6 {
 #define flowi6_oif		__fl_common.flowic_oif
 #define flowi6_iif		__fl_common.flowic_iif
 #define flowi6_mark		__fl_common.flowic_mark
-#define flowi6_tos		__fl_common.flowic_tos
 #define flowi6_scope		__fl_common.flowic_scope
 #define flowi6_proto		__fl_common.flowic_proto
 #define flowi6_flags		__fl_common.flowic_flags
@@ -135,6 +134,7 @@ struct flowi6 {
 #define flowi6_tun_key		__fl_common.flowic_tun_key
 	struct in6_addr		daddr;
 	struct in6_addr		saddr;
+	/* Note: flowi6_tos is encoded in flowlabel, too. */
 	__be32			flowlabel;
 	union flowi_uli		uli;
 #define fl6_sport		uli.ports.sport
diff --git a/include/trace/events/fib6.h b/include/trace/events/fib6.h
index 4cf6bac..d60096c 100644
--- a/include/trace/events/fib6.h
+++ b/include/trace/events/fib6.h
@@ -37,7 +37,7 @@ TRACE_EVENT(fib6_table_lookup,
 		__entry->tb_id = tb_id;
 		__entry->oif = flp->flowi6_oif;
 		__entry->iif = flp->flowi6_iif;
-		__entry->tos = flp->flowi6_tos;
+		__entry->tos = ip6_tclass(flp->flowlabel);
 		__entry->scope = flp->flowi6_scope;
 		__entry->flags = flp->flowi6_flags;
 
-- 
1.9.3
