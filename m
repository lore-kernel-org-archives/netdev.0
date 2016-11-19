From: Alexey Dobriyan <adobriyan@gmail.com>
Subject: [PATCH] netlink: use "unsigned int" in nla_next()
Date: Sat, 19 Nov 2016 03:54:35 +0300
Message-ID: <20161119005435.GD1200@avx2>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f65.google.com ([74.125.82.65]:33149 "EHLO
        mail-wm0-f65.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751716AbcKRWyo (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 18 Nov 2016 17:54:44 -0500
Received: by mail-wm0-f65.google.com with SMTP id u144so10788005wmu.0
        for <netdev@vger.kernel.org>; Fri, 18 Nov 2016 14:54:44 -0800 (PST)
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

->nla_len is unsigned entity (it's length after all) and u16,
thus it can't overflow when being aligned into int/unsigned int.

(nlmsg_next has the same code, but I didn't yet convince myself
it is correct to do so).

There is pointer arithmetic in this function and offset being
unsigned is better:

	add/remove: 0/0 grow/shrink: 1/64 up/down: 5/-309 (-304)
	function                                     old     new   delta
	nl80211_set_wiphy                           1444    1449      +5
	team_nl_cmd_options_set                      997     995      -2
	tcf_em_tree_validate                         872     870      -2
	switchdev_port_bridge_setlink                352     350      -2
	switchdev_port_br_afspec                     312     310      -2
	rtm_to_fib_config                            428     426      -2
	qla4xxx_sysfs_ddb_set_param                 2193    2191      -2
	qla4xxx_iface_set_param                     4470    4468      -2
	ovs_nla_free_flow_actions                    152     150      -2
	output_userspace                             518     516      -2
		...
	nl80211_set_reg                              654     649      -5
	validate_scan_freqs                          148     142      -6
	validate_linkmsg                             288     282      -6
	nl80211_parse_connkeys                       489     483      -6
	nlattr_set                                   231     224      -7
	nf_tables_delsetelem                         267     260      -7
	do_setlink                                  3416    3408      -8
	netlbl_cipsov4_add_std                      1672    1659     -13
	nl80211_parse_sched_scan                    2902    2888     -14
	nl80211_trigger_scan                        1738    1720     -18
	do_execute_actions                          2821    2738     -83
	Total: Before=154865355, After=154865051, chg -0.00%

Signed-off-by: Alexey Dobriyan <adobriyan@gmail.com>
---

 include/net/netlink.h |    2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

--- a/include/net/netlink.h
+++ b/include/net/netlink.h
@@ -713,7 +713,7 @@ static inline bool nla_ok(const struct nlattr *nla, int remaining)
  */
 static inline struct nlattr *nla_next(const struct nlattr *nla, int *remaining)
 {
-	int totlen = NLA_ALIGN(nla->nla_len);
+	unsigned int totlen = NLA_ALIGN(nla->nla_len);
 
 	*remaining -= totlen;
 	return (struct nlattr *) ((char *) nla + totlen);
