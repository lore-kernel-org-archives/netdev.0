From: Denis Vlasenko <vda@ilport.com.ua>
Subject: tcf_generic_walker(): what's going on?
Date: Thu, 6 Apr 2006 09:11:00 +0300
Message-ID: <200604060911.01140.vda@ilport.com.ua>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1751100AbWDFGLW@vger.kernel.org>
To: linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	kuznet@ms2.inr.ac.ru, "David S. Miller" <davem@davemloft.net>
Content-Disposition: inline
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

While hunting down oversized inlines
I stumbled on tcf_generic_walker().

It is defined in two separate files:
once as an inline in include/net/pkt_act.h
(really big one, ~750 bytes of code)
and once as a static function in net/sched/act_police.c

These two instances are not identical.
Second one has one extra parameter (int type)
and it uses it like this:

        for (i = 0; i < MY_TAB_SIZE; i++) {
                p = tcf_police_ht[tcf_police_hash(i)];

                for (; p; p = p->next) {
                        index++;
                        if (index < s_i)
                                continue;
                        a->priv = p;
                        a->order = index;
                        r = (struct rtattr*) skb->tail;
                        RTA_PUT(skb, a->order, 0, NULL);
+                       if (type == RTM_DELACTION)
+                               err = tcf_action_dump_1(skb, a, 0, 1);
+                       else
+                               err = tcf_action_dump_1(skb, a, 0, 0);

Having two functions with same name is rather confusing.
Worse, they are both are called via five different
tc_action_ops structs: 

static struct tc_action_ops act_ipt_ops = {
...
        .walk           =       tcf_generic_walker

and I fail to understand how it is supposed to work,
considering the fact that these two tcf_generic_walker's
have different prototypes.

1) What should I do with tcf_generic_walker?
2) Should I deinline huge inlines in include/net/pkt_act.h?
   If yes, to which .c file should I move them?
--
vda
