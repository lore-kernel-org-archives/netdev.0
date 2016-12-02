From: Alexey Dobriyan <adobriyan@gmail.com>
Subject: [PATCH] netlink: 2-clause nla_ok()
Date: Fri, 2 Dec 2016 03:59:06 +0300
Message-ID: <20161202005906.GA31170@avx2>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-lf0-f65.google.com ([209.85.215.65]:36343 "EHLO
        mail-lf0-f65.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753026AbcLAXPM (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 1 Dec 2016 18:15:12 -0500
Received: by mail-lf0-f65.google.com with SMTP id o20so20503321lfg.3
        for <netdev@vger.kernel.org>; Thu, 01 Dec 2016 15:15:11 -0800 (PST)
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

nla_ok() consists of 3 clauses:

	1) int rem >= (int)sizeof(struct nlattr)

	2) u16 nla_len >= sizeof(struct nlattr)

	3) u16 nla_len <= int rem

The statement is that clause (1) is redundant.

What it does is ensuring that "rem" is a positive number,
so that in clause (3) positive number will be compared to positive number
with no problems.

However, "u16" fully fits into "int" and integers do not change value
when upcasting even to signed type. Negative integers will be rejected
by clause (3) just fine. Small positive integers will be rejected
by transitivity of comparison operator.

NOTE: all of the above DOES NOT apply to nlmsg_ok() where ->nlmsg_len is
u32(!), so 3 clauses AND A CAST TO INT are necessary.

Obligatory space savings report: -1.6 KB

	$ ./scripts/bloat-o-meter ../vmlinux-000* ../vmlinux-001*
	add/remove: 0/0 grow/shrink: 3/63 up/down: 35/-1692 (-1657)
	function                                     old     new   delta
	validate_scan_freqs                          142     155     +13
	tcf_em_tree_validate                         867     879     +12
	dcbnl_ieee_del                               328     338     +10
	netlbl_cipsov4_add_common.isra               218     215      -3
		...
	ovs_nla_put_actions                          888     806     -82
	netlbl_cipsov4_add_std                      1648    1566     -82
	nl80211_parse_sched_scan                    2889    2780    -109
	ip_tun_from_nlattr                          3086    2945    -141

Signed-off-by: Alexey Dobriyan <adobriyan@gmail.com>
---

 include/net/netlink.h |    3 +--
 1 file changed, 1 insertion(+), 2 deletions(-)

--- a/include/net/netlink.h
+++ b/include/net/netlink.h
@@ -698,8 +698,7 @@ static inline int nla_len(const struct nlattr *nla)
  */
 static inline int nla_ok(const struct nlattr *nla, int remaining)
 {
-	return remaining >= (int) sizeof(*nla) &&
-	       nla->nla_len >= sizeof(*nla) &&
+	return nla->nla_len >= sizeof(*nla) &&
 	       nla->nla_len <= remaining;
 }
 
