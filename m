From: =?ISO-8859-2?Q?Pawe=B3_Staszewski?= <pstaszewski@itcare.pl>
Subject: Re: iproute2 action/policer question
Date: Mon, 15 Jun 2009 19:08:53 +0200
Message-ID: <4A368025.5000902@itcare.pl>
References: <20090615111927.GA12316@ff.dom.local> <1245072728.3948.14.camel@dogo.mojatatu.com> <20090615145222.GA2767@ami.dom.local> <4A367255.5050604@itcare.pl> <20090615163706.GA9469@ami.dom.local> <20090615164417.GB9469@ami.dom.local>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-2;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: jamal <hadi@cyberus.ca>,
	Linux Network Development list <netdev@vger.kernel.org>
To: Jarek Poplawski <jarkao2@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.iq.pl ([86.111.241.19]:57726 "EHLO smtp.iq.pl"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752457AbZFORIw (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 15 Jun 2009 13:08:52 -0400
In-Reply-To: <20090615164417.GB9469@ami.dom.local>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Jarek Poplawski pisze:
> On Mon, Jun 15, 2009 at 06:37:06PM +0200, Jarek Poplawski wrote:
>  =20
>> On Mon, Jun 15, 2009 at 06:09:57PM +0200, Pawe=B3 Staszewski wrote:
>>    =20
>>> Jarek Poplawski pisze:
>>>      =20
>>>> On Mon, Jun 15, 2009 at 09:32:08AM -0400, jamal wrote:
>>>>  =20
>>>>        =20
>>>>> On Mon, 2009-06-15 at 11:19 +0000, Jarek Poplawski wrote:
>>>>>
>>>>>    =20
>>>>>          =20
>>>>>>> This is only a sample but is not working
>>>>>>>        =20
>>>>>>>              =20
>>>>> It does seem to be working!
>>>>> How did you reach conclusion it wasnt working?
>>>>>
>>>>>    =20
>>>>>          =20
>>>>>>>         Action statistics:
>>>>>>>         Sent 42351 bytes 110 pkt (dropped 0, overlimits 32 requ=
eues 0)
>>>>>>>         rate 0bit 0pps backlog 0b 0p requeues 0
>>>>>>>        =20
>>>>>>>              =20
>>>>> 32 packets hit the policer - double check your parameters please =
to make
>>>>> sure they are correct.
>>>>>    =20
>>>>>          =20
>>>>  =20
>>>>        =20
>>> Yes. packets hits policer but second action dont drop packets.
>>>      =20
>> I guess Jamal meant 'hit the policer' =3D=3D 'dropped' (and 110 - 32
>> passed). So the question is how did you checked it's otherwise.
>>    =20
>
> Hmm... Not that we don't believe you, but some other (tc -s qdisc ?)
> stats with this would be appreciated before checking the code.;-)
>
>  =20

hmm...
Test that i make


ping -I 94.246.128.23 194.6.246.23 -s 900
PING 194.6.246.23 (194.6.246.23) from 94.246.128.23 : 900(928) bytes of=
=20
data.
908 bytes from 194.6.246.23: icmp_seq=3D1 ttl=3D63 time=3D0.595 ms
908 bytes from 194.6.246.23: icmp_seq=3D8 ttl=3D63 time=3D0.451 ms
^C
--- 194.6.246.23 ping statistics ---
9 packets transmitted, 2 received, 77% packet loss, time 8046ms


tc -s -d filter show dev eth0
filter parent 1: protocol ip pref 2 u32
filter parent 1: protocol ip pref 2 u32 fh 800: ht divisor 1
filter parent 1: protocol ip pref 2 u32 fh 800::800 order 2048 key ht=20
800 bkt 0 flowid 1:2  (rule hit 145 success 134)
  match 5ef6801c/ffffffff at 12 (success 134 )
filter parent 1: protocol ip pref 10 u32
filter parent 1: protocol ip pref 10 u32 fh 801: ht divisor 1
filter parent 1: protocol ip pref 10 u32 fh 801::800 order 2048 key ht=20
801 bkt 0 flowid 1:3  (rule hit 11 success 11)
  match 00000000/00000000 at 12 (success 11 )
        action order 1: tablename: mangle  hook: NF_IP_POST_ROUTING
        target MARK xset 0x1/0xffffffff
        index 20 ref 1 bind 1 installed 15 sec used 3 sec
        Action statistics:
        Sent 10762 bytes 11 pkt (dropped 0, overlimits 0 requeues 0)
        rate 0bit 0pps backlog 0b 0p requeues 0

        action order 2:  police 0xf rate 1000bit burst 1023b mtu 2Kb=20
action drop overhead 0b
ref 1 bind 1
        Action statistics:
        Sent 10762 bytes 11 pkt (dropped 0, overlimits 9 requeues 0)
        rate 0bit 0pps backlog 0b 0p requeues 0

tc -s -d qdisc show dev eth0
qdisc hfsc 1: root default 10
 Sent 32180 bytes 288 pkt (dropped 13, overlimits 77 requeues 0)
 rate 0bit 0pps backlog 0b 0p requeues 0
qdisc sfq 2: parent 1:2 limit 127p quantum 1514b flows 127/1024
 Sent 30296 bytes 286 pkt (dropped 0, overlimits 0 requeues 0)
 rate 0bit 0pps backlog 0b 0p requeues 0
qdisc sfq 3: parent 1:3 limit 127p quantum 1514b flows 127/1024
 Sent 1884 bytes 2 pkt (dropped 0, overlimits 0 requeues 0)
 rate 0bit 0pps backlog 0b 0p requeues 0

in stats i see overlimits / no drops

but packets are dropped :) yes sorry for this that i write before - tha=
t=20
there is no drops


But what with ipt -j MARK ?
Where i can catch this mark ?
Or i can't catch packet like this, but then for what will be this ipt=20
action ?


Because if i understand correct this action works like iptables -j MARK=
=20
in POSTROUTING mangle ?


> Jarek P.
> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
>
>
>  =20

