From: Kosuke Tatsukawa <tatsu@ab.jp.nec.com>
Subject: Re: [PATCH] net: bonding: Fix transmit load balancing in
 balance-alb mode if specified by sysfs
Date: Fri, 8 Sep 2017 02:06:16 +0000
Message-ID: <17EC94B0A072C34B8DCF0D30AD16044A029864AC@BPXM09GP.gisp.nec.co.jp>
References: <c9b6ae59-741b-3ecd-47ff-1d5b41710607@cumulusnetworks.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="iso-2022-jp"
Content-Transfer-Encoding: 8BIT
Cc: Jay Vosburgh <j.vosburgh@gmail.com>,
        Veaceslav Falico <vfalico@gmail.com>,
        Andy Gospodarek <andy@greyhouse.net>,
        "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
        "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
        Reinis Rozitis <r@roze.lv>
To: Nikolay Aleksandrov <nikolay@cumulusnetworks.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <c9b6ae59-741b-3ecd-47ff-1d5b41710607@cumulusnetworks.com>
Content-Language: ja-JP
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi,

> On  7.09.2017 01:47, Kosuke Tatsukawa wrote:
>> Commit cbf5ecb30560 ("net: bonding: Fix transmit load balancing in
>> balance-alb mode") tried to fix transmit dynamic load balancing in
>> balance-alb mode, which wasn't working after commit 8b426dc54cf4
>> ("bonding: remove hardcoded value").
>> 
>> It turned out that my previous patch only fixed the case when
>> balance-alb was specified as bonding module parameter, and not when
>> balance-alb mode was set using /sys/class/net/*/bonding/mode (the most
>> common usage).  In the latter case, tlb_dynamic_lb was set up according
>> to the default mode of the bonding interface, which happens to be
>> balance-rr.
>> 
>> This additional patch addresses this issue by setting up tlb_dynamic_lb
>> to 1 if "mode" is set to balance-alb through the sysfs interface.
>> 
>> I didn't add code to change tlb_balance_lb back to the default value for
>> other modes, because "mode" is usually set up only once during
>> initialization, and it's not worthwhile to change the static variable
>> bonding_defaults in bond_main.c to a global variable just for this
>> purpose.
>> 
>> Commit 8b426dc54cf4 also changes the value of tlb_dynamic_lb for
>> balance-tlb mode if it is set up using the sysfs interface.  I didn't
>> change that behavior, because the value of tlb_balance_lb can be changed
>> using the sysfs interface for balance-tlb, and I didn't like changing
>> the default value back and forth for balance-tlb.
>> 
>> As for balance-alb, /sys/class/net/*/bonding/tlb_balance_lb cannot be
>> written to.  However, I think balance-alb with tlb_dynamic_lb set to 0
>> is not an intended usage, so there is little use making it writable at
>> this moment.
>> 
>> Fixes: 8b426dc54cf4 ("bonding: remove hardcoded value")
>> Reported-by: Reinis Rozitis <r@roze.lv>
>> Signed-off-by: Kosuke Tatsukawa <tatsu@ab.jp.nec.com>
>> Cc: stable@vger.kernel.org  # v4.12+
>> ---
>>  drivers/net/bonding/bond_options.c |    3 +++
>>  1 files changed, 3 insertions(+), 0 deletions(-)
>> 
> 
> I don't believe this to be the right solution, hardcoding it like this
> changes user-visible behaviour. The issue is that if someone configured
> it to be 0 in tlb mode, suddenly it will become 1 and will silently
> override their config if they switch the mode to alb. Also it robs users
> from their choice.
> 
> If you think this should be settable in ALB mode, then IMO you should
> edit tlb_dynamic_lb option's unsuppmodes and allow it to be set in ALB.
> That would also be consistent with how it's handled in TLB mode.

No, I don't think tlb_dynamic_lb should be settable in balance-alb at
this point.  All the current commits regarding tlb_dynamic_lb are for
balance-tlb mode, so I don't think balance-alb with tlb_dynamic_lb set
to 0 is an intended usage.


> Going back and looking at your previous fix I'd argue that it is also
> wrong, you should've removed the mode check altogether to return the
> original behaviour where the dynamic_lb is set to 1 (enabled) by
> default and then ALB mode would've had it, of course that would've left
> the case of setting it to 0 in TLB mode and switching to ALB, but that
> is a different issue.

Maybe balance-alb shouldn't be dependent on tlb_dynamic_lb.
tlb_dynamic_lb is referenced in the following functions.

 + bond_do_alb_xmit()  -- Used by both balance-tlb and balance-alb
 + bond_tlb_xmit()  -- Only used by balance-tlb
 + bond_open()  -- Used by both balance-tlb and balance-alb
 + bond_check_params()  -- Used during module initialization
 + bond_fill_info()  -- Used to get/set value
 + bond_option_tlb_dynamic_lb_set()  -- Used to get/set value
 + bonding_show_tlb_dynamic_lb()  -- Used to get/set value
 + bond_is_nondyn_tlb()  -- Only referenced if balance-tlb mode

The following untested patch adds code to make balance-alb work as if
tlb_dynamic_lb==1 for the functions which affect balance-alb mode.  It
also reverts my previous patch.

What do you think about this approach?
---
Kosuke TATSUKAWA  | 1st Platform Software Division
                  | NEC Solution Innovators
                  | tatsu@ab.jp.nec.com

------------------------------------------------------------------------
 drivers/net/bonding/bond_alb.c  |    6 ++++--
 drivers/net/bonding/bond_main.c |    5 +++--
 2 files changed, 7 insertions(+), 4 deletions(-)

diff --git a/drivers/net/bonding/bond_alb.c b/drivers/net/bonding/bond_alb.c
index c02cc81..a9229b5 100644
--- a/drivers/net/bonding/bond_alb.c
+++ b/drivers/net/bonding/bond_alb.c
@@ -1325,7 +1325,8 @@ static int bond_do_alb_xmit(struct sk_buff *skb, struct bonding *bond,
 	if (!tx_slave) {
 		/* unbalanced or unassigned, send through primary */
 		tx_slave = rcu_dereference(bond->curr_active_slave);
-		if (bond->params.tlb_dynamic_lb)
+		if (bond->params.tlb_dynamic_lb ||
+		    (BOND_MODE(bond) == BOND_MODE_ALB))
 			bond_info->unbalanced_load += skb->len;
 	}
 
@@ -1339,7 +1340,8 @@ static int bond_do_alb_xmit(struct sk_buff *skb, struct bonding *bond,
 		goto out;
 	}
 
-	if (tx_slave && bond->params.tlb_dynamic_lb) {
+	if (tx_slave && (bond->params.tlb_dynamic_lb ||
+			 BOND_MODE(bond) == BOND_MODE_ALB)) {
 		spin_lock(&bond->mode_lock);
 		__tlb_clear_slave(bond, tx_slave, 0);
 		spin_unlock(&bond->mode_lock);
diff --git a/drivers/net/bonding/bond_main.c b/drivers/net/bonding/bond_main.c
index fc63992..bcb71e7 100644
--- a/drivers/net/bonding/bond_main.c
+++ b/drivers/net/bonding/bond_main.c
@@ -3305,7 +3305,8 @@ static int bond_open(struct net_device *bond_dev)
 		 */
 		if (bond_alb_initialize(bond, (BOND_MODE(bond) == BOND_MODE_ALB)))
 			return -ENOMEM;
-		if (bond->params.tlb_dynamic_lb)
+		if (bond->params.tlb_dynamic_lb ||
+		    (BOND_MODE(bond) == BOND_MODE_ALB))
 			queue_delayed_work(bond->wq, &bond->alb_work, 0);
 	}
 
@@ -4601,7 +4602,7 @@ static int bond_check_params(struct bond_params *params)
 	}
 	ad_user_port_key = valptr->value;
 
-	if ((bond_mode == BOND_MODE_TLB) || (bond_mode == BOND_MODE_ALB)) {
+	if (bond_mode == BOND_MODE_TLB) {
 		bond_opt_initstr(&newval, "default");
 		valptr = bond_opt_parse(bond_opt_get(BOND_OPT_TLB_DYNAMIC_LB),
 					&newval);
