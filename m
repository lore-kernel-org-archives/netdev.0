From: =?ISO-8859-2?Q?Pawe=B3_Staszewski?= <pstaszewski@itcare.pl>
Subject: Re: iproute2 action/policer question
Date: Mon, 15 Jun 2009 18:13:32 +0200
Message-ID: <4A36732C.8080903@itcare.pl>
References: <20090615111927.GA12316@ff.dom.local>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-2;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Linux Network Development list <netdev@vger.kernel.org>,
	Jamal Hadi Salim <hadi@cyberus.ca>
To: Jarek Poplawski <jarkao2@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.iq.pl ([86.111.241.19]:41435 "EHLO smtp.iq.pl"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752674AbZFOQNc (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 15 Jun 2009 12:13:32 -0400
In-Reply-To: <20090615111927.GA12316@ff.dom.local>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Jarek Poplawski pisze:
> On 09-06-2009 22:10, Pawe=B3 Staszewski wrote:
>  =20
>> Hello
>>
>> I ask this question here
>> Someone here know proper use of iproute actions/policers ?
>> i want to achive somethink like this
>>    =20
>
> Hi,
> I'm not actions/policers expert but here are a few comments.
>
>  =20
>> $TC qdisc del dev eth0 root
>>
>> $TC qdisc add dev eth0 root handle 1: hfsc default 10
>>
>>
>> $TC class add dev eth0 parent 1:0 classid 1:2 hfsc ls m2 1kbit ul m2=
=20
>> 10240kbit
>> $TC class add dev eth0 parent 1:0 classid 1:3 hfsc ls m2 1kbit ul m2=
=20
>> 10240kbit
>> $TC class add dev eth0 parent 1:0 classid 1:10 hfsc ls m2 1kbit ul m=
2=20
>> 10240kbit
>>
>> $TC filter add dev eth0 parent 1: protocol ip prio 2 u32 match ip sr=
c=20
>> 10.0.0.1 flowid 1:2
>> $TC qdisc add dev eth0 parent 1:2 handle 2: sfq perturb 120
>> #$TC filter add dev eth0 parent 1: protocol ip prio 10 u32 match ip =
src=20
>> 0/0 flowid 1:3
>> $TC qdisc add dev eth0 parent 1:3 handle 3: sfq perturb 120
>>
>>
>> #$TC filter add dev eth0 parent 1: protocol ip prio 10 u32 match ip =
src=20
>> 0/0 flowid 1:3 action ipt -j MARK --set-mark 0x555 drop
>>
>> $TC filter add dev eth0 parent 1: protocol ip prio 10 u32 \
>>   match ip src 0/0 flowid 1:3 \
>>   action ipt -j MARK --set-mark 1 \
>>   action police rate 1kbit burst 1k drop
>>
>> So i want to MARK packet by use of action then pass packet to next=20
>> action and drop if exceed 1kbit
>>
>> This is only a sample but is not working
>>    =20
>
> IMHO something like this should work. (I've checked it with a bit
> higher police rates/burst and htb.) I'm not sure you've properly
> checked the effects, because these stats below could be simply
> not updated etc.
>
>  =20
>> tc -s -d filter show dev eth0
>> filter parent 1: protocol ip pref 2 u32
>> filter parent 1: protocol ip pref 2 u32 fh 800: ht divisor 1
>> filter parent 1: protocol ip pref 2 u32 fh 800::800 order 2048 key h=
t=20
>> 800 bkt 0 flowid 1:2  (rule hit 7913 success 7803)
>>   match 5ef6801c/ffffffff at 12 (success 7803 )
>> filter parent 1: protocol ip pref 10 u32
>> filter parent 1: protocol ip pref 10 u32 fh 801: ht divisor 1
>> filter parent 1: protocol ip pref 10 u32 fh 801::800 order 2048 key =
ht=20
>> 801 bkt 0 flowid 1:3  (rule hit 110 success 110)
>>   match 00000000/00000000 at 12 (success 110 )
>>         action order 1: tablename: mangle  hook: NF_IP_POST_ROUTING
>>         target MARK xset 0x1/0xffffffff
>>         index 13 ref 1 bind 1 installed 407 sec used 2 sec
>>         Action statistics:
>>         Sent 42351 bytes 110 pkt (dropped 0, overlimits 0 requeues 0=
)
>>         rate 0bit 0pps backlog 0b 0p requeues 0
>>
>>         action order 2:  police 0x4 rate 1000bit burst 1023b mtu 2Kb=
=20
>> action drop overhead 0b
>> ref 1 bind 1
>>         Action statistics:
>>         Sent 42351 bytes 110 pkt (dropped 0, overlimits 32 requeues =
0)
>>         rate 0bit 0pps backlog 0b 0p requeues 0
>>
>> iptables -L -n -v -t mangle
>>    =20
>
> I don't know exactly the ipt action internals, so I could be wrong,
> but it seems it marks packets as expected, but it could be done out
> of the iptables chain so after these LOGs. Anyway, I managed to use i=
t
> with fw filter to classify according to the mark.
>
>  =20
>> Chain PREROUTING (policy ACCEPT 19M packets, 19G bytes)
>>  pkts bytes target     prot opt in     out     source              =20
>> destination
>>     0     0 LOG        all  --  *      *       0.0.0.0/0           =20
>> 0.0.0.0/0           mark match 0x1 LOG flags 0 level 4
>>
>> Chain INPUT (policy ACCEPT 19M packets, 19G bytes)
>>  pkts bytes target     prot opt in     out     source              =20
>> destination
>>
>> Chain FORWARD (policy ACCEPT 0 packets, 0 bytes)
>>  pkts bytes target     prot opt in     out     source              =20
>> destination
>>     0     0 LOG        all  --  *      *       0.0.0.0/0           =20
>> 0.0.0.0/0           mark match 0x1 LOG flags 0 level 4
>>
>> Chain OUTPUT (policy ACCEPT 11M packets, 17G bytes)
>>  pkts bytes target     prot opt in     out     source              =20
>> destination
>>
>> Chain POSTROUTING (policy ACCEPT 11M packets, 17G bytes)
>>  pkts bytes target     prot opt in     out     source              =20
>> destination
>>     0     0 LOG        all  --  *      *       0.0.0.0/0           =20
>> 0.0.0.0/0           mark match 0x1 LOG flags 0 level 4
>>
>>
>>
>>
>>
>>
>> Also is there someone who knows which actions from iptables can be u=
sed=20
>> in iproute2 ?
>>    =20
>
> According to iproute2/doc/actions/actions_general mangle targets
> should work; and you could also try (if it doesn't work then probably
> it can't be used...;-)
>
> But... I'm neither able to configure/compile it with the current
> iproute2/iptables, nor test it with distro's builds (Debian testing).
> After some checking I found iproute2 needs updating, because iptables
> changes API (xtables.h) virtually with every new version, so I don't
> even blame the ipt author or distro maintainer.
>
>  =20
>> because command like this ios not working:
>> tc filter add dev eth0 parent 1: protocol ip prio 10 u32 match ip sr=
c=20
>> 0/0 flowid 1:3 action ipt -j LOG
>>  failed to find target LOG
>>
>> bad action parsing
>> parse_action: bad value (3:ipt)!
>> Illegal "action"
>>
>>
>> iptables -t mangle -A FORWARD -j LOG
>> is working.
>> lsmod
>> Module                  Size  Used by
>> ipt_LOG                 4696  3
>> act_ipt                 3776  1
>> ifb                     3444  0
>> act_mirred              3328  0
>>
>>
>>
>> What is the clue of this
>> So i want to make filter rule on the end of some traffic management=20
>> based on iproute2 (this filter rule will be like default class so it=
=20
>> catch all unclassified traffic and LOG or MARK this traffic, and i c=
an=20
>> know that somewhere in my net is unclassified ip address.)
>> Because in normal operation if you use only iproute2 you have defaul=
t=20
>> class and you dont know what is going to this default class - this i=
s=20
>> hard if you use hfsc because of default class that is always active =
and=20
>> matches all traffic from interface that root is attached.
>>    =20
>
> I guess, after studying these iproute2 docs examples you should be
> able to do such tricks eg. with mirred and other actions even without
> ipt. Or you could ask authors for more docs...
>
>  =20
Yes. i know that i can make mirred redirect action to some dummy=20
inteface and then i can log on this device using iptables "LOG" target=20
(and this is working for me now) but i was thinking about something=20
simpler/faster and without special copying packets to dummy or ifb devi=
ce.



> Cheers,
> Jarek P.
>
> PS: the tc classifier maintainer added to Cc.
>
>
>  =20


Regards
Pawe=B3 Staszewski
