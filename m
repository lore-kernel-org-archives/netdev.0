From: Kosuke Tatsukawa <tatsu@ab.jp.nec.com>
Subject: Re: [PATCH] net: bonding: Fix transmit load balancing in
 balance-alb mode if specified by sysfs
Date: Fri, 8 Sep 2017 14:17:03 +0000
Message-ID: <17EC94B0A072C34B8DCF0D30AD16044A0298684C@BPXM09GP.gisp.nec.co.jp>
References: <99818f9e-7ee0-4e53-b2be-b61b958f87e7@cumulusnetworks.com>
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
Return-path: <netdev-owner@vger.kernel.org>
Received: from tyo162.gate.nec.co.jp ([114.179.232.162]:37847 "EHLO
        tyo162.gate.nec.co.jp" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1754599AbdIHOSN (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 8 Sep 2017 10:18:13 -0400
In-Reply-To: <99818f9e-7ee0-4e53-b2be-b61b958f87e7@cumulusnetworks.com>
Content-Language: ja-JP
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,

> On 08/09/17 13:10, Nikolay Aleksandrov wrote:
>> On 08/09/17 05:06, Kosuke Tatsukawa wrote:
>>> Hi,
>>>
>>>> On  7.09.2017 01:47, Kosuke Tatsukawa wrote:
>>>>> Commit cbf5ecb30560 ("net: bonding: Fix transmit load balancing in
>>>>> balance-alb mode") tried to fix transmit dynamic load balancing in
>>>>> balance-alb mode, which wasn't working after commit 8b426dc54cf4
>>>>> ("bonding: remove hardcoded value").
>>>>>
>>>>> It turned out that my previous patch only fixed the case when
>>>>> balance-alb was specified as bonding module parameter, and not when
>>>>> balance-alb mode was set using /sys/class/net/*/bonding/mode (the most
>>>>> common usage).  In the latter case, tlb_dynamic_lb was set up according
>>>>> to the default mode of the bonding interface, which happens to be
>>>>> balance-rr.
>>>>>
>>>>> This additional patch addresses this issue by setting up tlb_dynamic_lb
>>>>> to 1 if "mode" is set to balance-alb through the sysfs interface.
>>>>>
>>>>> I didn't add code to change tlb_balance_lb back to the default value for
>>>>> other modes, because "mode" is usually set up only once during
>>>>> initialization, and it's not worthwhile to change the static variable
>>>>> bonding_defaults in bond_main.c to a global variable just for this
>>>>> purpose.
>>>>>
>>>>> Commit 8b426dc54cf4 also changes the value of tlb_dynamic_lb for
>>>>> balance-tlb mode if it is set up using the sysfs interface.  I didn't
>>>>> change that behavior, because the value of tlb_balance_lb can be changed
>>>>> using the sysfs interface for balance-tlb, and I didn't like changing
>>>>> the default value back and forth for balance-tlb.
>>>>>
>>>>> As for balance-alb, /sys/class/net/*/bonding/tlb_balance_lb cannot be
>>>>> written to.  However, I think balance-alb with tlb_dynamic_lb set to 0
>>>>> is not an intended usage, so there is little use making it writable at
>>>>> this moment.
>>>>>
>>>>> Fixes: 8b426dc54cf4 ("bonding: remove hardcoded value")
>>>>> Reported-by: Reinis Rozitis <r@roze.lv>
>>>>> Signed-off-by: Kosuke Tatsukawa <tatsu@ab.jp.nec.com>
>>>>> Cc: stable@vger.kernel.org  # v4.12+
>>>>> ---
>>>>>  drivers/net/bonding/bond_options.c |    3 +++
>>>>>  1 files changed, 3 insertions(+), 0 deletions(-)
>>>>>
>>>>
>>>> I don't believe this to be the right solution, hardcoding it like this
>>>> changes user-visible behaviour. The issue is that if someone configured
>>>> it to be 0 in tlb mode, suddenly it will become 1 and will silently
>>>> override their config if they switch the mode to alb. Also it robs users
>>>> from their choice.
>>>>
>>>> If you think this should be settable in ALB mode, then IMO you should
>>>> edit tlb_dynamic_lb option's unsuppmodes and allow it to be set in ALB.
>>>> That would also be consistent with how it's handled in TLB mode.
>>>
>>> No, I don't think tlb_dynamic_lb should be settable in balance-alb at
>>> this point.  All the current commits regarding tlb_dynamic_lb are for
>>> balance-tlb mode, so I don't think balance-alb with tlb_dynamic_lb set
>>> to 0 is an intended usage.
>>>
>>>
>>>> Going back and looking at your previous fix I'd argue that it is also
>>>> wrong, you should've removed the mode check altogether to return the
>>>> original behaviour where the dynamic_lb is set to 1 (enabled) by
>>>> default and then ALB mode would've had it, of course that would've left
>>>> the case of setting it to 0 in TLB mode and switching to ALB, but that
>>>> is a different issue.
>>>
>>> Maybe balance-alb shouldn't be dependent on tlb_dynamic_lb.
>>> tlb_dynamic_lb is referenced in the following functions.
>>>
>>>  + bond_do_alb_xmit()  -- Used by both balance-tlb and balance-alb
>>>  + bond_tlb_xmit()  -- Only used by balance-tlb
>>>  + bond_open()  -- Used by both balance-tlb and balance-alb
>>>  + bond_check_params()  -- Used during module initialization
>>>  + bond_fill_info()  -- Used to get/set value
>>>  + bond_option_tlb_dynamic_lb_set()  -- Used to get/set value
>>>  + bonding_show_tlb_dynamic_lb()  -- Used to get/set value
>>>  + bond_is_nondyn_tlb()  -- Only referenced if balance-tlb mode
>>>
>>> The following untested patch adds code to make balance-alb work as if
>>> tlb_dynamic_lb==1 for the functions which affect balance-alb mode.  It
>>> also reverts my previous patch.
>>>
>>> What do you think about this approach?
>>> ---
>>> Kosuke TATSUKAWA  | 1st Platform Software Division
>>>                   | NEC Solution Innovators
>>>                   | tatsu@ab.jp.nec.com
>>>
>> 
>> Logically the approach looks good, that being said it adds unnecessary tests in
>> the fast path, why not just something like the patch below ? That only leaves the
>> problem if it is zeroed in TLB and switched to ALB mode, and that is a one line
>> fix to unsuppmodes just allow it to be set for that specific case. The below
>> returns the default behaviour before the commit in your Fixes tag.
>> 
>> 
> 
> Actually I'm fine with your approach, too. It will fix this regardless of the
> value of tlb_dynamic_lb which sounds good to me for the price of a test in
> the fast path.

If you're concerned about the additional test in the fast path, how
about the patch below.  I've added an arguemnt to bond_do_alb_xmit()
to handle both balance-tlb and balance-alb similary.

I'm not sure if this causes any problem if tlb_dynamic_lb is changed
while calling bond_do_alb_xmit() in balance-tlb mode.
---
Kosuke TATSUKAWA  | 1st Platform Software Division
                  | NEC Solution Innovators
                  | tatsu@ab.jp.nec.com

------------------------------------------------------------------------
 drivers/net/bonding/bond_alb.c  |   11 ++++++-----
 drivers/net/bonding/bond_main.c |    5 +++--
 2 files changed, 9 insertions(+), 7 deletions(-)

diff --git a/drivers/net/bonding/bond_alb.c b/drivers/net/bonding/bond_alb.c
index c02cc81..7710f20 100644
--- a/drivers/net/bonding/bond_alb.c
+++ b/drivers/net/bonding/bond_alb.c
@@ -1317,7 +1317,7 @@ void bond_alb_deinitialize(struct bonding *bond)
 }
 
 static int bond_do_alb_xmit(struct sk_buff *skb, struct bonding *bond,
-			    struct slave *tx_slave)
+			    struct slave *tx_slave, int tlb_dynamic_lb)
 {
 	struct alb_bond_info *bond_info = &(BOND_ALB_INFO(bond));
 	struct ethhdr *eth_data = eth_hdr(skb);
@@ -1325,7 +1325,7 @@ static int bond_do_alb_xmit(struct sk_buff *skb, struct bonding *bond,
 	if (!tx_slave) {
 		/* unbalanced or unassigned, send through primary */
 		tx_slave = rcu_dereference(bond->curr_active_slave);
-		if (bond->params.tlb_dynamic_lb)
+		if (tlb_dynamic_lb)
 			bond_info->unbalanced_load += skb->len;
 	}
 
@@ -1339,7 +1339,7 @@ static int bond_do_alb_xmit(struct sk_buff *skb, struct bonding *bond,
 		goto out;
 	}
 
-	if (tx_slave && bond->params.tlb_dynamic_lb) {
+	if (tx_slave && tlb_dynamic_lb) {
 		spin_lock(&bond->mode_lock);
 		__tlb_clear_slave(bond, tx_slave, 0);
 		spin_unlock(&bond->mode_lock);
@@ -1386,7 +1386,8 @@ int bond_tlb_xmit(struct sk_buff *skb, struct net_device *bond_dev)
 			break;
 		}
 	}
-	return bond_do_alb_xmit(skb, bond, tx_slave);
+	return bond_do_alb_xmit(skb, bond, tx_slave,
+				bond->params.tlb_dynamic_lb);
 }
 
 int bond_alb_xmit(struct sk_buff *skb, struct net_device *bond_dev)
@@ -1483,7 +1484,7 @@ int bond_alb_xmit(struct sk_buff *skb, struct net_device *bond_dev)
 		tx_slave = tlb_choose_channel(bond, hash_index, skb->len);
 	}
 
-	return bond_do_alb_xmit(skb, bond, tx_slave);
+	return bond_do_alb_xmit(skb, bond, tx_slave, 1);
 }
 
 void bond_alb_monitor(struct work_struct *work)
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
+		    (BOND_MODE(bond) == BOND_MODE_TLB))
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
