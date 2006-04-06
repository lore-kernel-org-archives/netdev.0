From: Patrick McHardy <kaber@trash.net>
Subject: Re: tcf_generic_walker(): what's going on?
Date: Thu, 06 Apr 2006 10:50:57 +0200
Message-ID: <4434D671.6060103@trash.net>
References: <200604060911.01140.vda@ilport.com.ua>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	kuznet@ms2.inr.ac.ru, "David S. Miller" <davem@davemloft.net>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1751139AbWDFIx1@vger.kernel.org>
To: Denis Vlasenko <vda@ilport.com.ua>
In-Reply-To: <200604060911.01140.vda@ilport.com.ua>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Denis Vlasenko wrote:
> While hunting down oversized inlines
> I stumbled on tcf_generic_walker().
> 
> It is defined in two separate files:
> once as an inline in include/net/pkt_act.h
> (really big one, ~750 bytes of code)
> and once as a static function in net/sched/act_police.c
> 
> These two instances are not identical.
> Second one has one extra parameter (int type)
> and it uses it like this:
> 
>         for (i = 0; i < MY_TAB_SIZE; i++) {
>                 p = tcf_police_ht[tcf_police_hash(i)];
> 
>                 for (; p; p = p->next) {
>                         index++;
>                         if (index < s_i)
>                                 continue;
>                         a->priv = p;
>                         a->order = index;
>                         r = (struct rtattr*) skb->tail;
>                         RTA_PUT(skb, a->order, 0, NULL);
> +                       if (type == RTM_DELACTION)
> +                               err = tcf_action_dump_1(skb, a, 0, 1);
> +                       else
> +                               err = tcf_action_dump_1(skb, a, 0, 0);
> 
> Having two functions with same name is rather confusing.
> Worse, they are both are called via five different
> tc_action_ops structs: 
> 
> static struct tc_action_ops act_ipt_ops = {
> ...
>         .walk           =       tcf_generic_walker
> 
> and I fail to understand how it is supposed to work,
> considering the fact that these two tcf_generic_walker's
> have different prototypes.

This code is a lazy hack to achieve "genericness" by using
a "generic" inline functions and #defines to create
specialized instances.

> 1) What should I do with tcf_generic_walker?
> 2) Should I deinline huge inlines in include/net/pkt_act.h?
>    If yes, to which .c file should I move them?

Unforunately you can't do this without further restructuring,
look at how the tc actions use that file:

/* use generic hash table */
#define MY_TAB_SIZE     8
#define MY_TAB_MASK     (MY_TAB_SIZE - 1)
static u32 idx_gen;
static struct tcf_mirred *tcf_mirred_ht[MY_TAB_SIZE];
static DEFINE_RWLOCK(mirred_lock);

/* ovewrride the defaults */
#define tcf_st          tcf_mirred
#define tc_st           tc_mirred
#define tcf_t_lock      mirred_lock
#define tcf_ht          tcf_mirred_ht

#define CONFIG_NET_ACT_INIT 1
#include <net/pkt_act.h>

What needs to be done is to put a pointer to the hash, its size
and its lock in struct tc_action_ops and move the "generic"
functions to a seperate .c file and make them work on a struct
tcf_act_common.
