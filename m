From: Cong Wang <xiyou.wangcong@gmail.com>
Subject: Re: [RFC Patch net-next 4/4] net_sched: make ingress qdisc lockless
Date: Thu, 9 Jan 2014 17:21:54 -0800
Message-ID: <CAM_iQpWTVeoB+gEuZ+K=e_Buk5Fcj6e=rUsbD=SF4pzu=JLiEA@mail.gmail.com>
References: <1389291593-2494-1-git-send-email-xiyou.wangcong@gmail.com>
	<1389291593-2494-5-git-send-email-xiyou.wangcong@gmail.com>
	<1389313313.31367.74.camel@edumazet-glaptop2.roam.corp.google.com>
	<CAM_iQpUj9kg=15K3yyOWuMEaxWQC2TUStAMjHrn+ixbGyYHK0Q@mail.gmail.com>
	<1389316283.31367.79.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Linux Kernel Network Developers <netdev@vger.kernel.org>,
	John Fastabend <john.fastabend@gmail.com>,
	"David S. Miller" <davem@davemloft.net>,
	Jamal Hadi Salim <jhs@mojatatu.com>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ob0-f180.google.com ([209.85.214.180]:33500 "EHLO
	mail-ob0-f180.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757356AbaAJBVz (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 9 Jan 2014 20:21:55 -0500
Received: by mail-ob0-f180.google.com with SMTP id wo20so4054681obc.25
        for <netdev@vger.kernel.org>; Thu, 09 Jan 2014 17:21:54 -0800 (PST)
In-Reply-To: <1389316283.31367.79.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Jan 9, 2014 at 5:11 PM, Eric Dumazet <eric.dumazet@gmail.com> wrote:
>
> Well, there is one qdisc, and if your NIC is multiqueue, with for
> example 32 queues, you can have 32 cpu happily using this qdisc at once.

I did see this, but still don't see the problem.

>
> Thats why you need the spinlock.
>

It looks like you are saying we queue the packets somewhere
in qdisc_enqueue_root() therefore needs a spinlock, but looking
at the code:

static inline int qdisc_enqueue(struct sk_buff *skb, struct Qdisc *sch)
{
        qdisc_calculate_pkt_len(skb, sch);
        return sch->enqueue(skb, sch);
}

static inline int qdisc_enqueue_root(struct sk_buff *skb, struct Qdisc *sch)
{
        qdisc_skb_cb(skb)->pkt_len = skb->len;
        return qdisc_enqueue(skb, sch) & NET_XMIT_MASK;
}

so it almost equals to calling ->enqueue directly, for ingress, which is
ingress_enqueue(). Except updating some stats, the only thing
it does is calling tc_classify().

So where is the problem at qdisc layer? I must miss something too obvious...
