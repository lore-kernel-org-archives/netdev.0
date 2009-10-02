From: Jarek Poplawski <jarkao2@gmail.com>
Subject: Re: [RFC] pkt_sched: gen_estimator: Dont report fake rate
	estimators
Date: Fri, 2 Oct 2009 07:08:19 +0000
Message-ID: <20091002070819.GA9694@ff.dom.local>
References: <4AC51D3D.8010700@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: eric.dumazet@gmail.com, kaber@trash.net, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bw0-f210.google.com ([209.85.218.210]:39404 "EHLO
	mail-bw0-f210.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757091AbZJBHIX (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 2 Oct 2009 03:08:23 -0400
Received: by bwz6 with SMTP id 6so745161bwz.37
        for <netdev@vger.kernel.org>; Fri, 02 Oct 2009 00:08:26 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <4AC51D3D.8010700@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 01-10-2009 23:21, Jarek Poplawski wrote:
> David Miller wrote, On 10/01/2009 11:14 PM:
> 
>> From: Jarek Poplawski <jarkao2@gmail.com>
>> Date: Thu, 01 Oct 2009 23:05:53 +0200
>>
>>> Since you ask... I wonder about this whole int plus quite a bit of
>>> struct unreadability for one flag only. Maybe it could be queried
>>> on qdisc level (with a flag if necessary), and additional parameter
>>> of gnet_stats_copy_rate_est()? (Qdiscs should have no problem with
>>> setting this param for their classes too.)
>> Certainly, that's another approach to this problem.
>>
>> But logically, just like we wouldn't emit a block of RED scheduler
>> data to 'tc' unless RED is actually configured, it seems consistent to
>> not emit estimator data when no estimator is even there.
> 
> Sure! I've exaggerated with this additional parameter. ;-)

To make my point clare: why not something like this?:

static int tc_fill_qdisc(struct sk_buff *skb, struct Qdisc *q, u32 clid,
                         u32 pid, u32 seq, u16 flags, int event)
{
	...
	if (gnet_stats_copy_basic(&d, &q->bstats) < 0 ||
	    (gen_estimator_active(&q->bstats, &q->rate_est) &&
             gnet_stats_copy_rate_est(&d, &q->rate_est) < 0) ||
            gnet_stats_copy_queue(&d, &q->qstats) < 0)
                goto nla_put_failure;

BTW, I'm not sure we need to chanage user visible API for this.
(Is it really expected to work after updating gen_stats.h only in
iproute?)

Jarek P.
