From: jamal <hadi@cyberus.ca>
Subject: Re: [RFC/PATCH] IMQ port to 2.6
Date: 26 Jan 2004 22:14:35 -0500
Sender: netdev-bounce@oss.sgi.com
Message-ID: <1075173275.1039.53.camel@jzny.localdomain>
References: <20040125152419.GA3208@penguin.localdomain>
	 <20040125164431.GA31548@louise.pinerecords.com>
	 <1075058539.1747.92.camel@jzny.localdomain>
	 <20040125202148.GA10599@usr.lcm.msu.ru>
	 <1075074316.1747.115.camel@jzny.localdomain>
	 <20040126001102.GA12303@usr.lcm.msu.ru>
	 <1075086588.1732.221.camel@jzny.localdomain>
	 <20040126093230.GA17811@usr.lcm.msu.ru>
	 <1075124312.1732.292.camel@jzny.localdomain>
	 <20040126135545.GA19497@usr.lcm.msu.ru>
	 <20040126152409.GA10053@louise.pinerecords.com>
Reply-To: hadi@cyberus.ca
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: "Vladimir B. Savkin" <master@sectorb.msk.ru>, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Tomas Szepe <szepe@pinerecords.com>
In-Reply-To: <20040126152409.GA10053@louise.pinerecords.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Mon, 2004-01-26 at 10:24, Tomas Szepe wrote:
[..]
> Actually, this is very much like what we're using IMQ for:
> 
>                   +-----------+ eth1 --- \
>                   | shaper    + eth2 ---
> Internet --- eth0 + in bridge + .    ---    ... WAN (10 C's of customer IPs)
>                   | setup     + .    ---
>                   +-----------+ ethN --- /
> 
> We're shaping single IPs and groups of IPs, applying tariff rates
> on the sum of inbound and outbound flow (this last point, I'm told,
> is the primary reason for our use of IMQ).]

This does not IMQ. I am going to type an example at the end of the
email.

> The machine also does
> IP accounting (through custom userland software based on libpcap)
> and has to be an ethernet bridge so that it can be replaced by
> a piece of wire should it fail and there was no backup hardware left.
> 

Ok, now you are throwing an extra  wrench ;->
As i mentioned earlier current dependency of ingress on netfilter
is the wrong abstraction (this also applies to IMQ). And for
this reason it must go. If you are running 2.4.x i can give you a patch
that fixes this and will get things working for you even when you use
bridging. Infact i will give example based on this patch.
BTW, how are you going to do SNAT with bridging?

The example below tries to show many things. Example sharing of
policers across many flows within a device, and across devices.
Also shows how to do it so that inbound and outbound are summed up.

I spent about 30 minutes coming up with this; i hope it illustrates
the potential

cheers,
jamal

---- start untested script here -------------------
#
#
# lets take example flow1 10.0.0.21 sits behind eth1 packets
# 
#
# the idea is to have 10.0.0.21/32 first try to use bandwith
# guaranteed to it (index 1) if exceeds that it gets demoted to mark 2
# and it tries to use bandwidth that is shared by all flows 
# behind eth1; (index 100)
# if that fails it gets demoted even more to mark 3 and it tries to use
# from a pool of bandwith available to every flow on every device
# index 300 if that fails then drop the packet etc
#
# on egress use the marks to select different priority queues.
# Give better treatment to mark 1 than 2 than 3 ..
#
# On the return path from internet to eth1, packets from
# internet to 10.0.0.21 are forced to use policer index 1
# and therefore ensuring that the bandwidth is allocated
# is the sum of inbound and outbound for that flow ..
# 
#
#add ingress qdisc
tc qdisc add dev eth1 ingress
#
tc filter add dev eth1 parent ffff: protocol ip prio 1 \
u32 match ip src 10.0.0.21/32 flowid 1:15 \
# first give it a mark of 1
action ipt -j mark --set-mark 1 index 2 \
# ensure policer index 1 is used
action police index 1 rate 1kbit burst 9k pipe \
# exceeded flows bound rate ..
action ipt -j mark --set-mark 2 \
#
action police index 200 mtu 5000 rate 1kbit burst 10k pipe \
action ipt -j mark --set-mark 3 \
action police index 300 mtu 5000 rate 1kbit burst 90k drop
#
#
# do something on eth0 with these firewall marks
# example use them to send packets to different classes/queue
# give priority to marks 1 then 2 then 3
#
.
.
.
# now the return path to 10.0.0.21 ...
tc qdisc add dev eth1 handle 1:0 root prio 
#
# note how exactly the same policer is used ("index 1")
tc filter add dev eth1 parent 1:0 protocol ip prio 1 \
u32 match ip dst 10.0.0.21/32 flowid 1:25 \
action police index 1 rate 1kbit burst 9k pipe 
.
.
.

look at the stats with "tc -s filter show parent ffff: dev eth1"
.
A sample would look like:

------------
jroot# tc -s filter show parent ffff: dev eth0
filter protocol ip pref 1 u32 
filter protocol ip pref 1 u32 fh 800: ht divisor 1 
filter protocol ip pref 1 u32 fh 800::800 order 2048 key ht 800 bkt 0 flowid 1:1
5
match 0a000015/ffffffff at 12
.
.
   action order 2: police 1 action pipe rate 1Kbit burst 9Kb mtu 2Kb 
         Sent 188832 bytes 2248 pkts (dropped 0, overlimits 2122) 
.
.

-------------


 
