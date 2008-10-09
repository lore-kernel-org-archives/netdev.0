From: Simon Horman <horms@verge.net.au>
Subject: Re: Possible regression in HTB
Date: Thu, 9 Oct 2008 11:54:40 +1100
Message-ID: <20081009005437.GA6342@verge.net.au>
References: <48EB5A92.6010704@trash.net> <20081007220022.GA2664@ami.dom.local> <20081008002153.GL12021@verge.net.au> <48EBFF5E.1090902@trash.net> <20081008065551.GB4174@ff.dom.local> <20081008072203.GJ22396@verge.net.au> <20081008080340.GE4174@ff.dom.local>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Patrick McHardy <kaber@trash.net>, netdev@vger.kernel.org,
	David Miller <davem@davemloft.net>,
	Martin Devera <devik@cdi.cz>
To: Jarek Poplawski <jarkao2@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from kirsty.vergenet.net ([202.4.237.240]:58522 "EHLO
	kirsty.vergenet.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752649AbYJIAym (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 8 Oct 2008 20:54:42 -0400
Content-Disposition: inline
In-Reply-To: <20081008080340.GE4174@ff.dom.local>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Oct 08, 2008 at 08:03:40AM +0000, Jarek Poplawski wrote:
> On Wed, Oct 08, 2008 at 06:22:04PM +1100, Simon Horman wrote:
> > On Wed, Oct 08, 2008 at 06:55:51AM +0000, Jarek Poplawski wrote:
> > > On Wed, Oct 08, 2008 at 02:31:26AM +0200, Patrick McHardy wrote:
> > > ...
> > > > I'm pretty sure that the differences are caused by HTB not being
> > > > in control of the queue since the device is the real bottleneck
> > > > in this configuration.
> > > 
> > > Yes, otherwise there would be no requeuing. And, btw. the golden rule
> > > of scheduling/shaping is limiting below "hardware" limits.
> > > 
> > > > Its quite possible that there simply might
> > > > a subtle timing change that causes feedback through HTBs borrowing
> > > > and ceiling.
> > > 
> > > I'd add my previous suspicion there could be not enough enqeuing on
> > > time for the fastest class (could be also very bursty), so other
> > > classes can borrow more.
> > > 
> > > >
> > > > So what would really be useful to understand this is to make HTB
> > > > control the queue and see if it behaves as expected.
> > > >
> > > 
> > > Right, trying with lower rates/ceils should explain this.
> > 
> > As I mentioned earlier things seem to work quite well with lower
> > rates/ceilings. When I set up the classes with 10x lower values
> > for rate and celing, as follows:
> > 
> > 
> >                            [ rate=100Mbit/s ]
> >                            [ ceil=100Mbit/s ]
> >                                   |
> >              +--------------------+--------------------+
> >              |                    |                    |
> >       [ rate= 50Mbit/s ]   [ rate= 10Mbit/s ]   [ rate= 10Mbit/s ]
> >       [ ceil=100Mbit/s ]   [ ceil=100Mbit/s ]   [ ceil= 100Mbit/s ]
> > 
> > Then I get results that are fairly close to the ideal values.
> > 
> > net-next-2.6 - d877984
> > ----------------------
> > 10194: 68075482bits/s 68Mbits/s
> > 10197: 14464848bits/s 14Mbits/s
> > 10196: 14465632bits/s 14Mbits/s
> > -----------------------------------
> > total: 97005962bits/s 97Mbits/s
> > 
> > And I get those kind of results consistently for various
> > different kernel versions.
> 
> OK. But as Patrick mentioned it would be interesting to try a little
> below hardware limits: 950, or maybe lower, until HTB starts getting
> accuracy.

Hi,

it seems that for my particular setup the magic number is 935Mbit/s.


Kernel is net-next-2.6 071d7ab6649eb34a873a53e71635186e9117101d
("ipvs: Remove stray file left over from ipvs move"),
which is after Jarek's "pkt_sched: Update qdisc requeue stats in
dev_requeue_skb()" patch.

ideal (based on 950Mbit/s aggregate)
500mbit class (10194): 500mbit + 250mbit/7*5 == 678.57mbit
100mbit class (10196): 100mbit + 250mbit/7*1 == 135.71mbit
100mbit class (10197): 100mbit + 250mbit/7*1 == 135.71mbit
                                                ==========
						950.00mbit
n=900
10194: 677727637bits/s 677Mbits/s
10197: 136662048bits/s 136Mbits/s
10196: 136725637bits/s 136Mbits/s
-----------------------------------
total: 951115322bits/s 951Mbits/s

n=920
10194: 676271338bits/s 676Mbits/s
10197: 137301090bits/s 137Mbits/s
10196: 137301877bits/s 137Mbits/s
-----------------------------------
total: 950874306bits/s 950Mbits/s

n=930
10194: 674681581bits/s 674Mbits/s
10197: 137538965bits/s 137Mbits/s
10196: 137541320bits/s 137Mbits/s
-----------------------------------
total: 949761866bits/s 949Mbits/s

n=933
10194: 675568704bits/s 675Mbits/s
10197: 137661437bits/s 137Mbits/s
10196: 137662221bits/s 137Mbits/s
-----------------------------------
total: 950892362bits/s 950Mbits/s

n=934
10194: 675399128bits/s 675Mbits/s
10197: 137653586bits/s 137Mbits/s
10196: 137704613bits/s 137Mbits/s
-----------------------------------
total: 950757328bits/s 950Mbits/s

n=935
10194: 675169893bits/s 675Mbits/s
10197: 137667714bits/s 137Mbits/s
10196: 137670858bits/s 137Mbits/s
-----------------------------------
total: 950508466bits/s 950Mbits/s

n=936
10194: 385295016bits/s 385Mbits/s
10197: 285078114bits/s 285Mbits/s
10196: 286588581bits/s 286Mbits/s
-----------------------------------
total: 956961712bits/s 956Mbits/s

n=937
10194: 384569616bits/s 384Mbits/s
10197: 285480072bits/s 285Mbits/s
10196: 286627050bits/s 286Mbits/s
-----------------------------------
total: 956676738bits/s 956Mbits/s

n=940
10194: 384577466bits/s 384Mbits/s
10197: 285655138bits/s 285Mbits/s
10196: 286846872bits/s 286Mbits/s
-----------------------------------
total: 957079477bits/s 957Mbits/s

n=950
10194: 384097789bits/s 384Mbits/s
10197: 285950325bits/s 285Mbits/s
10196: 286894760bits/s 286Mbits/s
-----------------------------------
total: 956942874bits/s 956Mbits/s

n=1000
10194: 384639482bits/s 384Mbits/s
10197: 285133069bits/s 285Mbits/s
10196: 287172674bits/s 287Mbits/s
-----------------------------------
total: 956945226bits/s 956Mbits/s


# HTB
###########################################################################
n=933

tc qdisc del dev eth0 root

tc qdisc add dev eth0 root handle 1: htb default 10 r2q $((n * 10))

tc class add dev eth0 parent 1:  classid 1:1   htb \
        rate ${n}Mbit ceil ${n}Mbit

tc class add dev eth0 parent 1:1 classid 1:10 htb \
        rate ${n}Mbit ceil ${n}Mbit
tc class add dev eth0 parent 1:1 classid 1:11 htb \
        rate 500Mbit ceil ${n}Mbit
tc class add dev eth0 parent 1:1 classid 1:12 htb \
        rate 100Mbit ceil ${n}Mbit
tc class add dev eth0 parent 1:1 classid 1:13 htb \
        rate 100Mbit ceil ${n}Mbit

#tc filter add dev eth0 protocol ip parent 1: \
#       u32 match ip src 172.17.60.194 flowid 1:11
#tc filter add dev eth0 protocol ip parent 1: \
#       u32 match ip src 172.17.60.196 flowid 1:12
#tc filter add dev eth0 protocol ip parent 1: \
#       u32 match ip src 172.17.60.197 flowid 1:13

tc filter add dev eth0 protocol ip parent 1: \
        u32 match ip dport 10194 0xffff flowid 1:11
tc filter add dev eth0 protocol ip parent 1: \
        u32 match ip dport 10196 0xffff flowid 1:12
tc filter add dev eth0 protocol ip parent 1: \
        u32 match ip dport 10197 0xffff flowid 1:13

tc -s -d class show dev eth0

