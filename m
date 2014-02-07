From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: [PATCH 05/18] netfilter: nf_nat_h323: fix crash in nf_ct_unlink_expect_report()
Date: Fri,  7 Feb 2014 18:41:31 +0100
Message-ID: <1391794904-4017-6-git-send-email-pablo@netfilter.org>
References: <1391794904-4017-1-git-send-email-pablo@netfilter.org>
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: netfilter-devel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.us.es ([193.147.175.20]:41420 "EHLO mail.us.es"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751680AbaBGRmE (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 7 Feb 2014 12:42:04 -0500
In-Reply-To: <1391794904-4017-1-git-send-email-pablo@netfilter.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Alexey Dobriyan <adobriyan@gmail.com>

Similar bug fixed in SIP module in 3f509c6 ("netfilter: nf_nat_sip: fix
incorrect handling of EBUSY for RTCP expectation").

BUG: unable to handle kernel paging request at 00100104
IP: [<f8214f07>] nf_ct_unlink_expect_report+0x57/0xf0 [nf_conntrack]
...
Call Trace:
  [<c0244bd8>] ? del_timer+0x48/0x70
  [<f8215687>] nf_ct_remove_expectations+0x47/0x60 [nf_conntrack]
  [<f8211c99>] nf_ct_delete_from_lists+0x59/0x90 [nf_conntrack]
  [<f8212e5e>] death_by_timeout+0x14e/0x1c0 [nf_conntrack]
  [<f8212d10>] ? nf_conntrack_set_hashsize+0x190/0x190 [nf_conntrack]
  [<c024442d>] call_timer_fn+0x1d/0x80
  [<c024461e>] run_timer_softirq+0x18e/0x1a0
  [<f8212d10>] ? nf_conntrack_set_hashsize+0x190/0x190 [nf_conntrack]
  [<c023e6f3>] __do_softirq+0xa3/0x170
  [<c023e650>] ? __local_bh_enable+0x70/0x70
  <IRQ>
  [<c023e587>] ? irq_exit+0x67/0xa0
  [<c0202af6>] ? do_IRQ+0x46/0xb0
  [<c027ad05>] ? clockevents_notify+0x35/0x110
  [<c066ac6c>] ? common_interrupt+0x2c/0x40
  [<c056e3c1>] ? cpuidle_enter_state+0x41/0xf0
  [<c056e6fb>] ? cpuidle_idle_call+0x8b/0x100
  [<c02085f8>] ? arch_cpu_idle+0x8/0x30
  [<c027314b>] ? cpu_idle_loop+0x4b/0x140
  [<c0273258>] ? cpu_startup_entry+0x18/0x20
  [<c066056d>] ? rest_init+0x5d/0x70
  [<c0813ac8>] ? start_kernel+0x2ec/0x2f2
  [<c081364f>] ? repair_env_string+0x5b/0x5b
  [<c0813269>] ? i386_start_kernel+0x33/0x35

Signed-off-by: Alexey Dobriyan <adobriyan@gmail.com>
Signed-off-by: Pablo Neira Ayuso <pablo@netfilter.org>
---
 net/ipv4/netfilter/nf_nat_h323.c |    5 ++++-
 1 file changed, 4 insertions(+), 1 deletion(-)

diff --git a/net/ipv4/netfilter/nf_nat_h323.c b/net/ipv4/netfilter/nf_nat_h323.c
index 9eea059d..574f7eb 100644
--- a/net/ipv4/netfilter/nf_nat_h323.c
+++ b/net/ipv4/netfilter/nf_nat_h323.c
@@ -229,7 +229,10 @@ static int nat_rtp_rtcp(struct sk_buff *skb, struct nf_conn *ct,
 			ret = nf_ct_expect_related(rtcp_exp);
 			if (ret == 0)
 				break;
-			else if (ret != -EBUSY) {
+			else if (ret == -EBUSY) {
+				nf_ct_unexpect_related(rtp_exp);
+				continue;
+			} else if (ret < 0) {
 				nf_ct_unexpect_related(rtp_exp);
 				nated_port = 0;
 				break;
-- 
1.7.10.4
