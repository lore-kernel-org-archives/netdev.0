From: pablo@netfilter.org
Subject: [PATCH 1/2] netfilter: ipset: timeout values corrupted on set resize
Date: Tue, 26 Feb 2013 14:45:19 +0100
Message-ID: <1361886320-9492-2-git-send-email-pablo@netfilter.org>
References: <1361886320-9492-1-git-send-email-pablo@netfilter.org>
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: netfilter-devel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from slan-550-85.anhosting.com ([209.236.71.68]:18916 "EHLO
	slan-550-85.anhosting.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751503Ab3BZNph (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 26 Feb 2013 08:45:37 -0500
In-Reply-To: <1361886320-9492-1-git-send-email-pablo@netfilter.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Josh Hunt <johunt@akamai.com>

If a resize is triggered on a set with timeouts enabled, the timeout
values will get corrupted when copying them to the new set. This occured
b/c the wrong timeout value is supplied to type_pf_elem_tadd().

This also adds simple debug statement similar to the one in type_pf_resize().

Signed-off-by: Josh Hunt <johunt@akamai.com>
Signed-off-by: Jozsef Kadlecsik <kadlec@blackhole.kfki.hu>
---
 include/linux/netfilter/ipset/ip_set_ahash.h |    4 +++-
 1 file changed, 3 insertions(+), 1 deletion(-)

diff --git a/include/linux/netfilter/ipset/ip_set_ahash.h b/include/linux/netfilter/ipset/ip_set_ahash.h
index ef9acd3..01d25e6 100644
--- a/include/linux/netfilter/ipset/ip_set_ahash.h
+++ b/include/linux/netfilter/ipset/ip_set_ahash.h
@@ -854,6 +854,8 @@ type_pf_tresize(struct ip_set *set, bool retried)
 retry:
 	ret = 0;
 	htable_bits++;
+	pr_debug("attempt to resize set %s from %u to %u, t %p\n",
+		 set->name, orig->htable_bits, htable_bits, orig);
 	if (!htable_bits) {
 		/* In case we have plenty of memory :-) */
 		pr_warning("Cannot increase the hashsize of set %s further\n",
@@ -873,7 +875,7 @@ retry:
 			data = ahash_tdata(n, j);
 			m = hbucket(t, HKEY(data, h->initval, htable_bits));
 			ret = type_pf_elem_tadd(m, data, AHASH_MAX(h), 0,
-						type_pf_data_timeout(data));
+						ip_set_timeout_get(type_pf_data_timeout(data)));
 			if (ret < 0) {
 				read_unlock_bh(&set->lock);
 				ahash_destroy(t);
-- 
1.7.10.4
