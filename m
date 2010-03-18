From: Changli Gao <xiaosuo@gmail.com>
Subject: Re: [PATCH v7] rps: Receive Packet Steering
Date: Thu, 18 Mar 2010 14:48:29 +0800
Message-ID: <412e6f7f1003172348s1f113734h882779d9acd08ddc@mail.gmail.com>
References: <65634d661003121508m3d348973k63a6ae9ca1f12f9f@mail.gmail.com>
	<1268773227.2932.34.camel@edumazet-laptop> <20100316.141311.262178287.davem@davemloft.net>
	<412e6f7f1003161854w32ed4516w2e52003097051fc7@mail.gmail.com>
	<1268809673.2932.62.camel@edumazet-laptop> <412e6f7f1003170059r1f0fa4cfrbe8b3f22102ee9d9@mail.gmail.com>
	<1268834957.2899.352.camel@edumazet-laptop> <65634d661003170801x1042a6am563c9d937ba672a4@mail.gmail.com>
	<4BA16AB8.3090800@google.com> <1268893232.2894.65.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Tom Herbert <therbert@google.com>,
	David Miller <davem@davemloft.net>, netdev@vger.kernel.org
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-iw0-f178.google.com ([209.85.223.178]:64211 "EHLO
	mail-iw0-f178.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752772Ab0CRGsu convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 18 Mar 2010 02:48:50 -0400
Received: by iwn8 with SMTP id 8so997911iwn.16
        for <netdev@vger.kernel.org>; Wed, 17 Mar 2010 23:48:49 -0700 (PDT)
In-Reply-To: <1268893232.2894.65.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Mar 18, 2010 at 2:20 PM, Eric Dumazet <eric.dumazet@gmail.com> =
wrote:
> Le mercredi 17 mars 2010 =C3=A0 16:50 -0700, Tom Herbert a =C3=A9crit=
 :
>>
>> Here is a patch for this...
>>
>> Allow specification of CPUs in rps to be done with a vector instead =
of a bit map. =C2=A0This allows relative weighting of CPUs in the map b=
y repeating ones to give higher weight.
>>
>> For example "echo 0 0 0 3 4 4 4 4 > /sys/class/net/eth0/queues/rx-0/=
rps_cpus"
>>
>> assigns CPUs 0, 3, and 4 to the RPS mask with relative weights 3, 1,=
 and 4 respectively.
>>
>
> Hmm...
>
> I believe we should keep existing sysfs cpumask interface, because it=
s
> the only workable thing on a PAGE_SIZE=3D4096 machine with 4096 cpus.
>
> strlen("0 1 2 3 4 ... 4095") =3D 19369
>
> Using base 16 instead of base 10 -> 16111
>

sigh! How about adding file for each cpu weight setting.

=2E../rx-0/rps_cpu0...n

BTW: I think exporting the hook of hash function will help in some
case. So users can choose which hash to use depend on their
applications. I know FreeBSD supports hash based on flow, source or
CPU. Some network application have multiple instances for taking full
advantage of the SMP/C hardware, and each instance binds to a special
CPU/Core, so they need some kind of load distributing algorithm for
load balancing.

=46or example, memcached uses hash based on key, and its developer may
implement a hash function for RPS. Then it apply the following
iptables rule:

iptables -A PREROUTING -t nat -m cpu --cpuid 0 -m tcp --dport 1234
--REDIRECT 8081
iptables -A PREROUTING -t nat -m cpu --cpuid 0 -m tcp --dport 1234
--REDIRECT 8082
=2E..

No other things to change, it can take full advantage of the
underlying hardware transparently.

--=20
Regards=EF=BC=8C
Changli Gao(xiaosuo@gmail.com)
