From: Alessandro Suardi <alessandro.suardi@gmail.com>
Subject: Re: [PATCH] ipv4: fix fib metrics
Date: Fri, 25 Mar 2011 02:04:44 +0100
Message-ID: <AANLkTi=hgOcwO8ojQBtmqbROS1qrhm5HCmq7tRxesc=6@mail.gmail.com>
References: <1301005107.2714.113.camel@edumazet-laptop>
	<AANLkTinv+XGBjbFoK6vpyiDW6gBEBKFjUef+mCAMJU9i@mail.gmail.com>
	<1301005946.2714.130.camel@edumazet-laptop>
	<20110324.153623.45921344.davem@davemloft.net>
	<1301006652.2714.145.camel@edumazet-laptop>
	<AANLkTi=Xb3KCBKoVCcaVD5iyCtMCAnYaGF_DTeFQ0ays@mail.gmail.com>
	<AANLkTinh9Li7DGgSqcZ+p9peS5XrHWomerSvKTYwHZ9-@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Eric Dumazet <eric.dumazet@gmail.com>,
	David Miller <davem@davemloft.net>,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org
To: Kyle Moffett <kyle@moffetthome.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-iy0-f174.google.com ([209.85.210.174]:36377 "EHLO
	mail-iy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755505Ab1CYBEp convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 24 Mar 2011 21:04:45 -0400
In-Reply-To: <AANLkTinh9Li7DGgSqcZ+p9peS5XrHWomerSvKTYwHZ9-@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Mar 25, 2011 at 1:53 AM, Kyle Moffett <kyle@moffetthome.net> wr=
ote:
> On Thu, Mar 24, 2011 at 20:12, Alessandro Suardi
> <alessandro.suardi@gmail.com> wrote:
>> On Thu, Mar 24, 2011 at 11:44 PM, Eric Dumazet <eric.dumazet@gmail.c=
om> wrote:
>>> Le jeudi 24 mars 2011 =E0 15:36 -0700, David Miller a =E9crit :
>>>> From: Eric Dumazet <eric.dumazet@gmail.com>
>>>> Date: Thu, 24 Mar 2011 23:32:26 +0100
>>>>
>>>> > Then it doesnt work anymore because it parses an ipip field from
>>>> > ip route get ...
>>>> >
>>>> > $ ip ro get 192.168.1.1
>>>> > 192.168.1.1 dev wlan0 =A0src 192.168.1.21
>>>> > =A0 =A0 cache =A0ipid 0x784c mtu 1500 advmss 1460 hoplimit 64
>>>> >
>>>> >
>>>> > Maybe you upgraded iproute2
>>>>
>>>> I'm leaning towards app bug too.
>>>>
>>>> These default metrics wouldn't get printed before, but now because=
 of
>>>> how metrics are handled, they will.
>>>>
>>>> Userland needs to cope properly with this.
>>>
>>>
>>> BTW, ipip is not always printed (even on old kernels) : One needs t=
o
>>> actually need ipip generation .
>>>
>>> edumazet@edumazet-laptop:~$ ping 4.4.4.4
>>> PING 4.4.4.4 (4.4.4.4) 56(84) bytes of data.
>>> ^C
>>>
>>> edumazet@edumazet-laptop:~$ ip ro get 4.4.4.4
>>> 4.4.4.4 dev ppp0 =A0src 10.150.51.210
>>> =A0 =A0cache =A0mtu 1500 advmss 1460 hoplimit 64
>>>
>>> edumazet@edumazet-laptop:~$ ping -s 2000 4.4.4.4
>>> PING 4.4.4.4 (4.4.4.4) 2000(2028) bytes of data.
>>> ^C
>>>
>>> edumazet@edumazet-laptop:~$ ip ro get 4.4.4.4
>>> 4.4.4.4 dev ppp0 =A0src 10.150.51.210
>>> =A0 =A0cache =A0ipid 0xf99a mtu 1500 advmss 1460 hoplimit 64
>>>
>>>
>>> This on a 2.6.35 kernel
>>>
>>> I suspect Alessandro tool had a bug anyway.
>>
>> I still contend this is a kernel regression :)
>>
>>
>> vpnc is a custom build from trunk as of June 2010, with openssl supp=
ort
>> =A0to talk to my corporate VPN concentrator:
>>
> [...snip...]
>>
>> My iproute package, on this up-to-date Fedora 14 x86_64, has last be=
en
>> =A0updated on 20 Nov 2010, and back then I was running 2.6.37-rc2-gi=
t4
>> =A0(I keep around my historical .config files, so I know for sure).
>>
>> [root@duff ~]# ip -V
>> ip utility, iproute2-ss100804
>> [root@duff ~]# rpm -qf /sbin/ip
>> iproute-2.6.35-6.fc14.x86_64
>>
>> The behavior of this version of 'ip' as invoked by this version of '=
vpnc'
>> =A0is something that has worked for the last 4 months, and isn't wor=
king
>> =A0right now. Furthermore, previous versions of 'ip' in Fedora 14 we=
re
>> =A0also working with the same 'vpnc', which means it's actually 9 mo=
nths
>> =A0minimum of working behavior.
>>
>> If some change in the kernel broke my userspace, this usually qualif=
ies
>> =A0as a regression.
>>
>> That said, if you can point me to a working version of iproute with =
the
>> =A0current kernel, I have no problem in upgrading it :)
>
> Historically you could usually take the text output of "ip route get"
> and feed it right back to "ip route add", and it would work, but this
> was never guaranteed.
>
> Recently, the "ip route get" command started printing extra statistic=
s
> (like "ipid") after the other information, but obviously those
> statistics are not valid for an "ip route add" command.
>
> The kernel bug was that the "ip" command was not always getting those
> statistics from the kernel, so obviously they would not be printed.
>
> Unfortunately vpnc still tries to pass the entire output of "ip route
> get" as arguments to "ip route add"; the latter command reports an
> error when it gets the statistics from the former command as input.
>
> So this is certainly not a kernel bug. =A0At *best* it's an iproute b=
ug,
> depending on whether or not this is considered valid:
> =A0RT=3D"$(ip route get [...])"
> =A0ip route flush
> =A0ip route add ${RT}

=46air enough, I get it.

Looks like the fix_ip_get_output() function in /etc/vpnc/vpnc-script
 needs to be augmented from the current

  sed 's/cache//;s/metric \?[0-9]\+ [0-9]\+//g;s/hoplimit [0-9]\+//g'

 to something slightly more comprehensive.


Thanks for the explanation - will keep around -git2 for my vpnc
 needs until I get this one sorted out :)

--alessandro

=A0"There's always a siren singing you to shipwreck"

=A0=A0 (Radiohead, "There There")
