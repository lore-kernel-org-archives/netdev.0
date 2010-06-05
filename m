From: Changli Gao <xiaosuo@gmail.com>
Subject: Re: [PATCH] act_mirred: don't clone skb when skb isn't shared
Date: Sat, 5 Jun 2010 21:33:03 +0800
Message-ID: <AANLkTinh6OylNU8NLXB6ZSb012AmzkFhzFQWPR-iAsrf@mail.gmail.com>
References: <1275658990-15838-1-git-send-email-xiaosuo@gmail.com>
	<1275742435.3490.31.camel@bigi> <AANLkTikHqzIr-SjPZe-iiMPxVG9PRR9-0A9qeMwzfLYp@mail.gmail.com>
	<1275744299.3490.48.camel@bigi>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org
To: hadi@cyberus.ca
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-px0-f174.google.com ([209.85.212.174]:48458 "EHLO
	mail-px0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754032Ab0FENdY (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 5 Jun 2010 09:33:24 -0400
Received: by pxi8 with SMTP id 8so622170pxi.19
        for <netdev@vger.kernel.org>; Sat, 05 Jun 2010 06:33:23 -0700 (PDT)
In-Reply-To: <1275744299.3490.48.camel@bigi>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, Jun 5, 2010 at 9:24 PM, jamal <hadi@cyberus.ca> wrote:
> On Sat, 2010-06-05 at 21:07 +0800, Changli Gao wrote:
>
>> Thanks. BTW: act_nat.c doesn't obey the following rule, and you plan
>> to remove TC_MUNGED and TC_OK2MUNGE?
>
>> 2) If you munge any packet thou shalt call pskb_expand_head in the case
>> someone else is referencing the skb. After that you "own" the skb.
>> You must also tell us if it is ok to munge the packet (TC_OK2MUNGE),
>> this way any action downstream can stomp on the packet.
>
> That rule still applies but it is upto the discretion of the action.
> i.e if the act_nat thinks it is ok for others down the street to trample
> on the packet, it should tell us so. Maybe i should change the wording
> to use the word "may" in that 3rd sentence.
> [I will kill (low prio) TC_OK2MUNGE but not TC_MUNGED.]
>

If you kill TC_OK2MUNGE, you should kill TC_MUNGED too, as it will
become useless.

localhost linux # grep MUNGE net/sched/ -R
net/sched/act_pedit.c:  if (!(skb->tc_verd & TC_OK2MUNGE)) {
net/sched/act_pedit.c:                  skb->tc_verd =
SET_TC_MUNGED(skb->tc_verd);
net/sched/act_api.c:                    if (TC_MUNGED & skb->tc_verd) {
net/sched/act_api.c:                            skb->tc_verd =
SET_TC_OK2MUNGE(skb->tc_verd);
net/sched/act_api.c:                            skb->tc_verd =
CLR_TC_MUNGED(skb->tc_verd);

int tcf_action_exec(struct sk_buff *skb, struct tc_action *act,
                    struct tcf_result *res)
{
        struct tc_action *a;
        int ret = -1;

        if (skb->tc_verd & TC_NCLS) {
                skb->tc_verd = CLR_TC_NCLS(skb->tc_verd);
                ret = TC_ACT_OK;
                goto exec_done;
        }
        while ((a = act) != NULL) {
repeat:
                if (a->ops && a->ops->act) {
                        ret = a->ops->act(skb, a, res);
                        if (TC_MUNGED & skb->tc_verd) {
                                /* copied already, allow trampling */
                                skb->tc_verd = SET_TC_OK2MUNGE(skb->tc_verd);
                                skb->tc_verd = CLR_TC_MUNGED(skb->tc_verd);
                        }
                        if (ret == TC_ACT_REPEAT)
                                goto repeat;    /* we need a ttl - JHS */
                        if (ret != TC_ACT_PIPE)
                                goto exec_done;
                }
                act = a->next;
        }
exec_done:
        return ret;
}

The bit OK2MUNGE relies on MUNGED only.

-- 
Regards,
Changli Gao(xiaosuo@gmail.com)
