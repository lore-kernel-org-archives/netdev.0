From: acme@ghostprotocols.net
Subject: [PATCH 2/5] [INET6]: Reorganize struct inet6_dev to save 8 bytes
Date: Fri,  1 Feb 2008 20:23:33 -0200
Message-ID: <47a39bf1.1187460a.1e0d.ffff96f1@mx.google.com>
References: y
 <1201904616-4944-1-git-send-email-y>
 <1201904616-4944-2-git-send-email-y>
Cc: netdev@vger.kernel.org, Arnaldo Carvalho de Melo <acme@redhat.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from hs-out-0708.google.com ([64.233.178.246]:6790 "EHLO
	hs-out-2122.google.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1754231AbYBAWXy (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 1 Feb 2008 17:23:54 -0500
Received: by hs-out-2122.google.com with SMTP id 54so1062988hsz.5
        for <netdev@vger.kernel.org>; Fri, 01 Feb 2008 14:23:49 -0800 (PST)
In-Reply-To: <1201904616-4944-2-git-send-email-y>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Arnaldo Carvalho de Melo <acme@redhat.com>

And make it a multiple of a 64 bytes, reducing cacheline trashing:

Before:

[acme@doppio net-2.6]$ pahole -C inet6_dev net/dccp/ipv6.o
struct inet6_dev {
	<SNIP>
	long unsigned int          mc_maxdelay;          /*    48     8 */
	unsigned char              mc_qrv;               /*    56     1 */
	unsigned char              mc_gq_running;        /*    57     1 */
	unsigned char              mc_ifc_count;         /*    58     1 */

	/* XXX 5 bytes hole, try to pack */

	/* --- cacheline 1 boundary (64 bytes) --- */
	struct timer_list          mc_gq_timer;          /*    64    48 */
	<SNIP>
	__u32                      if_flags;             /*   180     4 */
	int                        dead;                 /*   184     4 */
	u8                         rndid[8];             /*   188     8 */

	/* XXX 4 bytes hole, try to pack */

	/* --- cacheline 3 boundary (192 bytes) was 8 bytes ago --- */
	struct timer_list          regen_timer;          /*   200    48 */

	<SNIP>

	/* size: 456, cachelines: 8 */
	/* sum members: 447, holes: 2, sum holes: 9 */
	/* last cacheline: 8 bytes */
};

After:

net-2.6/net/ipv6/af_inet6.c:
  struct inet6_dev |   -8
 1 struct changed

Signed-off-by: Arnaldo Carvalho de Melo <acme@redhat.com>
---
 include/net/if_inet6.h |    4 ++--
 1 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/include/net/if_inet6.h b/include/net/if_inet6.h
index b24508a..66c43e2 100644
--- a/include/net/if_inet6.h
+++ b/include/net/if_inet6.h
@@ -166,11 +166,11 @@ struct inet6_dev
 	struct ifmcaddr6	*mc_list;
 	struct ifmcaddr6	*mc_tomb;
 	rwlock_t		mc_lock;
-	unsigned long		mc_v1_seen;
-	unsigned long		mc_maxdelay;
 	unsigned char		mc_qrv;
 	unsigned char		mc_gq_running;
 	unsigned char		mc_ifc_count;
+	unsigned long		mc_v1_seen;
+	unsigned long		mc_maxdelay;
 	struct timer_list	mc_gq_timer;	/* general query timer */
 	struct timer_list	mc_ifc_timer;	/* interface change timer */
 
-- 
1.5.3.8

