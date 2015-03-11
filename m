From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: Why do we prefer skb->priority to tc filters?
Date: Wed, 11 Mar 2015 11:25:40 -0700
Message-ID: <1426098340.11398.59.camel@edumazet-glaptop2.roam.corp.google.com>
References: <CAHA+R7Oz=Je_avfzjLib0YaQRUArEpt+sm1qNqcV_oEvUp3=eA@mail.gmail.com>
	 <CAHA+R7Os6=uxTAYr=0ZrCKZpySNJ4QoT=mJa5daGJ_0zgD1Y7w@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>,
	Jamal Hadi Salim <jhs@mojatatu.com>,
	David Miller <davem@davemloft.net>
To: Cong Wang <cwang@twopensource.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ie0-f169.google.com ([209.85.223.169]:34017 "EHLO
	mail-ie0-f169.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751113AbbCKSZn (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 11 Mar 2015 14:25:43 -0400
Received: by iecsl2 with SMTP id sl2so1768791iec.1
        for <netdev@vger.kernel.org>; Wed, 11 Mar 2015 11:25:43 -0700 (PDT)
In-Reply-To: <CAHA+R7Os6=uxTAYr=0ZrCKZpySNJ4QoT=mJa5daGJ_0zgD1Y7w@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2015-03-11 at 11:08 -0700, Cong Wang wrote:
> On Wed, Mar 11, 2015 at 10:34 AM, Cong Wang <cwang@twopensource.com> wrote:
> >
> > Given that skb->priority can be specified in user-space, doesn't this
> > mean some application can always override our rules specified by tc
> > filters? I think we should always respect tc filters over any
> > application setting.
> >
> 
> Hmm, on the other hand, skb->priority can be changed in cgroup
> too, in this case the current behavior seems correct. :-/ Interesting.

Note that even HTB has the following code :

static struct htb_class *htb_classify(struct sk_buff *skb, struct Qdisc *sch,
                                      int *qerr)
{
        struct htb_sched *q = qdisc_priv(sch);
        struct htb_class *cl;
        struct tcf_result res;
        struct tcf_proto *tcf;
        int result;

        /* allow to select class by setting skb->priority to valid classid;
         * note that nfmark can be used too by attaching filter fw with no
         * rules in it
         */
        if (skb->priority == sch->handle)
                return HTB_DIRECT;      /* X:0 (direct flow) selected */
        cl = htb_find(skb->priority, sch);
        if (cl) {
                if (cl->level == 0)
                        return cl;
                /* Start with inner filter chain if a non-leaf class is selected */
                tcf = rcu_dereference_bh(cl->filter_list);
        } else {
                tcf = rcu_dereference_bh(q->filter_list);
        }


So if skb->priority happens to match sch->handle or any class handle,
we queue packet into a queue, without calling tc_classify()
