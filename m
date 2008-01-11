From: Dzianis Kahanovich <mahatma@bspu.unibel.by>
Subject: Re: [PATCH 2.6.23+] ingress classify to [nf]mark
Date: Fri, 11 Jan 2008 15:24:51 -0200
Message-ID: <4787A663.4030204@bspu.unibel.by>
References: <47866C69.3080904@bspu.unibel.by> <1200001167.4443.38.camel@localhost>
Reply-To: mahatma@eu.by
Mime-Version: 1.0
Content-Type: text/plain; charset=KOI8-R; format=flowed
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.bspu.unibel.by ([195.50.2.21]:43349 "EHLO
	mail.bspu.unibel.by" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1760728AbYAKOVU (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 11 Jan 2008 09:21:20 -0500
Received: from [10.200.200.1] ([10.200.200.1])
	by mail.bspu.unibel.by (8.14.1/8.14.0) with ESMTP id m0BDOwlX016768
	for <netdev@vger.kernel.org>; Fri, 11 Jan 2008 15:24:59 +0200
In-Reply-To: <1200001167.4443.38.camel@localhost>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

jamal wrote:

>> To "classid x:y" = "mark=mark&x|y" ("classid :y" = "-j MARK --set-mark y", etc).
>>
>> --- linux-2.6.23-gentoo-r2/net/sched/Kconfig
>> +++ linux-2.6.23-gentoo-r2.fixed/net/sched/Kconfig
>> @@ -222,6 +222,16 @@
> [..]
>>   			skb->tc_index = TC_H_MIN(res.classid);
>> +#ifdef CONFIG_NET_SCH_INGRESS_TC2MARK
>> +			skb->mark = (skb->mark&(res.classid>>16))|TC_H_MIN(res.classid);
>> +#endif
>>   		default:
> 
> 
> Please either use ipt action and netfilter fwmarker for this activity or

Sorry. There are only unsuccessful attempt to popularize my working solution.
Really I just use "#define tc_index mark" (in skbuff.h or sch_ingress.c) or 
something like this:

--- linux-2.6.23-gentoo-r2/net/sched/Kconfig
+++ linux-2.6.23-gentoo-r2.fixed/net/sched/Kconfig
@@ -222,6 +222,16 @@
  	  To compile this code as a module, choose M here: the
  	  module will be called sch_ingress.

+config NET_SCH_INGRESS_TC2MARK
+	bool "ingress tc_index -> mark"
+	depends on NET_SCH_INGRESS && NET_CLS_ACT
+	---help---
+	  This enables access to "mark" value via "tc_index" alias
+	  in ingress and unify this values (usage example: set "flowid :2"
+	  in ingress and use it value as "mark" in any way - netfilter, etc).
+	
+	  But tc_index may be undefined - use "flowid :0".
+
  comment "Classification"

  config NET_CLS
--- linux-2.6.23-gentoo-r2/net/sched/sch_ingress.c
+++ linux-2.6.23-gentoo-r2.fixed/net/sched/sch_ingress.c
@@ -18,6 +18,9 @@
  #include <net/netlink.h>
  #include <net/pkt_sched.h>

+#ifdef CONFIG_NET_SCH_INGRESS_TC2MARK
+#define tc_index mark
+#endif

  #undef DEBUG_INGRESS



> create a new action. 
> If you choose the later (example because you want to dynamically compute
> the mark), look at net/sched/act_simple.c to start from and i can help
> you if you have any questions.
>  
> If you want to use ipt action, the syntax would be something like:
> 
> ---
> tc qdisc add dev XXX ingress
> tc filter add dev XXX parent ffff: protocol ip prio 5 \
> u32 blah bleh \
> flowid 1:12 action ipt -j mark --set-mark 13 

Yes, I do so. But there are simple:
---
if [[ $[TC_INDEX2MARK] == 0 ]] ; then
  c=${c//action ipt -j MARK --set-mark /flowid :}
fi
$c
---

Simpliest:
--- linux-2.6.23-gentoo-r2/net/sched/sch_ingress.c
+++ linux-2.6.23-gentoo-r2.fixed/net/sched/sch_ingress.c
@@ -222,6 +222,16 @@
-   			skb->tc_index = TC_H_MIN(res.classid);
+   			skb->tc_index = TC_H_MIN(mark=res.classid);


-- 
WBR,
Denis Kaganovich,  mahatma@eu.by  http://mahatma.bspu.unibel.by
