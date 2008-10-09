From: Jarek Poplawski <jarkao2@gmail.com>
Subject: Re: Possible regression in HTB
Date: Thu, 9 Oct 2008 06:21:45 +0000
Message-ID: <20081009062145.GA4159@ff.dom.local>
References: <48EB5A92.6010704@trash.net> <20081007220022.GA2664@ami.dom.local> <20081008002153.GL12021@verge.net.au> <48EBFF5E.1090902@trash.net> <20081008065551.GB4174@ff.dom.local> <20081008072203.GJ22396@verge.net.au> <20081008080340.GE4174@ff.dom.local> <20081009005437.GA6342@verge.net.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Patrick McHardy <kaber@trash.net>, netdev@vger.kernel.org,
	David Miller <davem@davemloft.net>,
	Martin Devera <devik@cdi.cz>
To: Simon Horman <horms@verge.net.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ug-out-1314.google.com ([66.249.92.173]:27930 "EHLO
	ug-out-1314.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755932AbYJIGVy (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 9 Oct 2008 02:21:54 -0400
Received: by ug-out-1314.google.com with SMTP id k3so825253ugf.37
        for <netdev@vger.kernel.org>; Wed, 08 Oct 2008 23:21:52 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <20081009005437.GA6342@verge.net.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Oct 09, 2008 at 11:54:40AM +1100, Simon Horman wrote:
> On Wed, Oct 08, 2008 at 08:03:40AM +0000, Jarek Poplawski wrote:
...
> > OK. But as Patrick mentioned it would be interesting to try a little
> > below hardware limits: 950, or maybe lower, until HTB starts getting
> > accuracy.
> 
> Hi,

Hi Simon,

> 
> it seems that for my particular setup the magic number is 935Mbit/s.
> 
> 
> Kernel is net-next-2.6 071d7ab6649eb34a873a53e71635186e9117101d
> ("ipvs: Remove stray file left over from ipvs move"),
> which is after Jarek's "pkt_sched: Update qdisc requeue stats in
> dev_requeue_skb()" patch.
> 
> ideal (based on 950Mbit/s aggregate)
> 500mbit class (10194): 500mbit + 250mbit/7*5 == 678.57mbit
> 100mbit class (10196): 100mbit + 250mbit/7*1 == 135.71mbit
> 100mbit class (10197): 100mbit + 250mbit/7*1 == 135.71mbit
>                                                 ==========
> 						950.00mbit
> n=900
> 10194: 677727637bits/s 677Mbits/s
> 10197: 136662048bits/s 136Mbits/s
> 10196: 136725637bits/s 136Mbits/s
> -----------------------------------
> total: 951115322bits/s 951Mbits/s
> 
> n=920
> 10194: 676271338bits/s 676Mbits/s
> 10197: 137301090bits/s 137Mbits/s
> 10196: 137301877bits/s 137Mbits/s
> -----------------------------------
> total: 950874306bits/s 950Mbits/s
> 
> n=930
> 10194: 674681581bits/s 674Mbits/s
> 10197: 137538965bits/s 137Mbits/s
> 10196: 137541320bits/s 137Mbits/s
> -----------------------------------
> total: 949761866bits/s 949Mbits/s
> 
> n=933
> 10194: 675568704bits/s 675Mbits/s
> 10197: 137661437bits/s 137Mbits/s
> 10196: 137662221bits/s 137Mbits/s
> -----------------------------------
> total: 950892362bits/s 950Mbits/s
> 
> n=934
> 10194: 675399128bits/s 675Mbits/s
> 10197: 137653586bits/s 137Mbits/s
> 10196: 137704613bits/s 137Mbits/s
> -----------------------------------
> total: 950757328bits/s 950Mbits/s
> 
> n=935
> 10194: 675169893bits/s 675Mbits/s
> 10197: 137667714bits/s 137Mbits/s
> 10196: 137670858bits/s 137Mbits/s
> -----------------------------------
> total: 950508466bits/s 950Mbits/s
> 
> n=936
> 10194: 385295016bits/s 385Mbits/s
> 10197: 285078114bits/s 285Mbits/s
> 10196: 286588581bits/s 286Mbits/s
> -----------------------------------
> total: 956961712bits/s 956Mbits/s

It's hard to believe so small change can matter so much here!!!
Great testing!

It seems it's safer to use something below such magic number, and
generally 10% below hardware limit could be the rule.

It also looks like my idea that the first class could get not enough
packets was wrong. It seems it's rather blocked by other classes when
HTB thinks it can lend more.

Anyway, I'm also surprised HTB could be still so exact: congratulations
Martin!

Simon, if I don't miss something, I guess you should be OK with these
last changes in requeuing? The older way did some safety for such
overestimated configs by hiding the real problem, but there were the
costs: cpu etc.

Thanks,
Jarek P.

> 
> n=937
> 10194: 384569616bits/s 384Mbits/s
> 10197: 285480072bits/s 285Mbits/s
> 10196: 286627050bits/s 286Mbits/s
> -----------------------------------
> total: 956676738bits/s 956Mbits/s
> 
> n=940
> 10194: 384577466bits/s 384Mbits/s
> 10197: 285655138bits/s 285Mbits/s
> 10196: 286846872bits/s 286Mbits/s
> -----------------------------------
> total: 957079477bits/s 957Mbits/s
> 
> n=950
> 10194: 384097789bits/s 384Mbits/s
> 10197: 285950325bits/s 285Mbits/s
> 10196: 286894760bits/s 286Mbits/s
> -----------------------------------
> total: 956942874bits/s 956Mbits/s
> 
> n=1000
> 10194: 384639482bits/s 384Mbits/s
> 10197: 285133069bits/s 285Mbits/s
> 10196: 287172674bits/s 287Mbits/s
> -----------------------------------
> total: 956945226bits/s 956Mbits/s
> 
> 
> # HTB
> ###########################################################################
> n=933
> 
> tc qdisc del dev eth0 root
> 
> tc qdisc add dev eth0 root handle 1: htb default 10 r2q $((n * 10))
> 
> tc class add dev eth0 parent 1:  classid 1:1   htb \
>         rate ${n}Mbit ceil ${n}Mbit
> 
> tc class add dev eth0 parent 1:1 classid 1:10 htb \
>         rate ${n}Mbit ceil ${n}Mbit
> tc class add dev eth0 parent 1:1 classid 1:11 htb \
>         rate 500Mbit ceil ${n}Mbit
> tc class add dev eth0 parent 1:1 classid 1:12 htb \
>         rate 100Mbit ceil ${n}Mbit
> tc class add dev eth0 parent 1:1 classid 1:13 htb \
>         rate 100Mbit ceil ${n}Mbit
> 
> #tc filter add dev eth0 protocol ip parent 1: \
> #       u32 match ip src 172.17.60.194 flowid 1:11
> #tc filter add dev eth0 protocol ip parent 1: \
> #       u32 match ip src 172.17.60.196 flowid 1:12
> #tc filter add dev eth0 protocol ip parent 1: \
> #       u32 match ip src 172.17.60.197 flowid 1:13
> 
> tc filter add dev eth0 protocol ip parent 1: \
>         u32 match ip dport 10194 0xffff flowid 1:11
> tc filter add dev eth0 protocol ip parent 1: \
>         u32 match ip dport 10196 0xffff flowid 1:12
> tc filter add dev eth0 protocol ip parent 1: \
>         u32 match ip dport 10197 0xffff flowid 1:13
> 
> tc -s -d class show dev eth0
> 
