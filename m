From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: Re: OOPS in nf_ct_unlink_expect_report using Polycom RealPresence
 Mobile
Date: Mon, 3 Feb 2014 13:14:15 +0100
Message-ID: <20140203121415.GA12777@localhost>
References: <20140131120527.Horde.-3YzQu5S8WWBx7vuVVNdBA2@bigboss.aws-it.at>
 <20140131125014.Horde.G2TRlt-60JJ0Nl_3Y8IniQ2@bigboss.aws-it.at>
 <20140131170402.Horde.yIFUeQVjLycuS_8PGQoKmg5@aws-it.at>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="bp/iNruPH9dso1Pn"
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	netfilter@vger.kernel.org, Alexey Dobriyan <adobriyan@gmail.com>,
	netfilter-devel <netfilter-devel@vger.kernel.org>
To: astx <astx@aws-it.at>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20140131170402.Horde.yIFUeQVjLycuS_8PGQoKmg5@aws-it.at>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


--bp/iNruPH9dso1Pn
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline

On Fri, Jan 31, 2014 at 05:04:02PM +0100, astx wrote:
> Dear Alexey,
> 
> seems to help. Thank you for your quick response. Kernel 3.10.28 is
> now stable using h323 / Polycom.

Thanks, if no objection, will pass this patch to David.

--bp/iNruPH9dso1Pn
Content-Type: text/x-diff; charset=us-ascii
Content-Disposition: attachment; filename="0001-netfilter-nf_nat_h323-fix-crash-in-nf_ct_unlink_expe.patch"

>From d98506139d6e192705422ffba13bc2ff476ac513 Mon Sep 17 00:00:00 2001
From: Alexey Dobriyan <adobriyan@gmail.com>
Date: Mon, 3 Feb 2014 13:07:24 +0100
Subject: [PATCH] netfilter: nf_nat_h323: fix crash in
 nf_ct_unlink_expect_report()

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


--bp/iNruPH9dso1Pn--
