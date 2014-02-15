From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net-next 0/7] clear old options when old qdisc's replaced
Date: Fri, 14 Feb 2014 18:53:01 -0800
Message-ID: <1392432781.24974.9.camel@edumazet-glaptop2.roam.corp.google.com>
References: <1392366970-11592-1-git-send-email-yangyingliang@huawei.com>
	 <1392381841.24974.5.camel@edumazet-glaptop2.roam.corp.google.com>
	 <52FECEF6.2070605@huawei.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, davem@davemloft.net,
	stephen@networkplumber.org
To: Yang Yingliang <yangyingliang@huawei.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f170.google.com ([209.85.192.170]:41872 "EHLO
	mail-pd0-f170.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751480AbaBOCxE (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 14 Feb 2014 21:53:04 -0500
Received: by mail-pd0-f170.google.com with SMTP id p10so12804012pdj.1
        for <netdev@vger.kernel.org>; Fri, 14 Feb 2014 18:53:03 -0800 (PST)
In-Reply-To: <52FECEF6.2070605@huawei.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, 2014-02-15 at 10:20 +0800, Yang Yingliang wrote:
> On 2014/2/14 20:44, Eric Dumazet wrote:
> > On Fri, 2014-02-14 at 16:36 +0800, Yang Yingliang wrote:
> >> I've added a netem qdisc with rate option, then I replace this qdisc
> >> without rate option but with latency option. The rate option is still
> >> there.
> >>
> >> E.g.
> >>   # tc qdisc add dev eth4 handle 1: root netem rate 10mbit
> >>   # tc qdisc show
> >>     qdisc netem 1: dev eth4 root refcnt 2 limit 1000 rate 10Mbit
> >>
> >>   # tc qdisc replace dev eth4 handle 1: root netem latency 10ms
> >>   # tc qdisc show
> >>     qdisc netem 1: dev eth4 root refcnt 2 limit 1000 delay 10.0ms rate 10Mbit
> >>
> >> The old options need be cleared after the qdisc is replaced.
> > 
> > Not at all. Test your changes with "tc qdisc change ... "
> > 
> > 
> With "tc qdisc change ... ", it will only change the options that specified in command.
> It's proper, I think.
> 
>    # tc qdisc add dev eth4 handle 1: root netem rate 10mbit
>    # tc qdisc show
>      qdisc netem 1: dev eth4 root refcnt 2 limit 1000 rate 10Mbit
> 
>    # tc qdisc replace dev eth4 handle 1: root netem latency 10ms
>    # tc qdisc show
>      qdisc netem 1: dev eth4 root refcnt 2 limit 1000 delay 10.0ms rate 10Mbit
> 
> "rate" is not cleared.
> 
> But with other qdiscs, such as tbf and htb etc, their usage not complete same as netem's,
> when we use "tc qdisc change ... ", the old options will be cleared. Maybe we should make
> their useages of "change" same as netem's?

qdisc change should only change the parameters you specified in the
command line.

For example, if I want to change my fq qdisc pacing I use :

tc qdisc change dev eth0 root fq pacing

or

tc qdisc change dev eth0 root fq nopacing

In your patches, you for example clear ecn if not specified, its wrong.

        if (tb[TCA_NETEM_ECN])
                q->ecn = nla_get_u32(tb[TCA_NETEM_ECN]);
+       else
+               q->ecn = 0;
