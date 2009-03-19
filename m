From: ebiederm@xmission.com (Eric W. Biederman)
Subject: Re: [lxc-devel] Poor bridging performance on 10 GbE
Date: Wed, 18 Mar 2009 17:50:16 -0700
Message-ID: <m1wsamcp4n.fsf@fess.ebiederm.org>
References: <b30d1c3b0903180221h5175618eue162ffdec3817b4c@mail.gmail.com>
	<49C0C87B.7070507@fr.ibm.com>
	<b30d1c3b0903180856r6dce554ap35b8d6a3ee7829e0@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Daniel Lezcano <dlezcano@fr.ibm.com>,
	Linux Containers <containers@lists.osdl.org>,
	Linux Netdev List <netdev@vger.kernel.org>,
	lxc-devel@lists.sourceforge.net
To: Ryousei Takano <ryousei@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from out01.mta.xmission.com ([166.70.13.231]:36026 "EHLO
	out01.mta.xmission.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752718AbZCSAu0 convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 18 Mar 2009 20:50:26 -0400
In-Reply-To: <b30d1c3b0903180856r6dce554ap35b8d6a3ee7829e0@mail.gmail.com> (Ryousei Takano's message of "Thu\, 19 Mar 2009 00\:56\:53 +0900")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Ryousei Takano <ryousei@gmail.com> writes:

> I am using VServer because other virtualization mechanisms, including=
 OpenVZ,
> Xen, and KVM cannot fully utilize the network bandwidth of 10 GbE.
>
> Here are the results of netperf bencmark:
> 	vanilla (2.6.27-9)		9525.94
> 	Vserver (2.6.27.10)	9521.79
> 	OpenVZ (2.6.27.10)	2049.89
> 	Xen (2.6.26.1)		1011.47
> 	KVM (2.6.27-9)		1022.42
>
> Now I am interesting to use LXC instead of VServer.

A good argument.

>>> Using a macvlan device, the throughput was 9.6 Gbps. But, using a v=
eth
>>> device,
>>> the throughput was only 2.7 Gbps.
>>
>> Yeah, definitively the macvlan interfaces is the best in terms of
>> performances but with the restriction of not being able to communica=
te
>> between containers on the same hosts.
>>
> This restriction is not so big issue for my purpose.

Right.  I have been trying to figure out what the best way to cope
with that restriction is.

>>> I also checked the host OS's performance when I used a veth device.
>>> I observed a strange phenomenon.
>>>
>>> Before issuing lxc-start command, the throughput was 9.6 Gbps.
>>> Here is the output of brctl show:
>>> =C2=A0 =C2=A0 =C2=A0 =C2=A0$ brctl show
>>> =C2=A0 =C2=A0 =C2=A0 =C2=A0bridge name =C2=A0 =C2=A0 bridge id =C2=A0=
 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 STP enabled =C2=A0 =C2=A0 in=
terfaces
>>> =C2=A0 =C2=A0 =C2=A0 =C2=A0br0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 8000.0060dd470d49 =C2=A0 =C2=A0 =C2=A0 no =C2=A0 =C2=A0 =C2=A0 =C2=A0=
 =C2=A0 =C2=A0 =C2=A0eth1
>>>
>>> After issuing lxc-start command, the throughput decreased to 3.2 Gb=
ps.
>>> Here is the output of brctl show:
>>> =C2=A0 =C2=A0 =C2=A0 =C2=A0$ sudo brctl show
>>> =C2=A0 =C2=A0 =C2=A0 =C2=A0bridge name =C2=A0 =C2=A0 bridge id =C2=A0=
 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 STP enabled =C2=A0 =C2=A0 in=
terfaces
>>> =C2=A0 =C2=A0 =C2=A0 =C2=A0br0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 8000.0060dd470d49 =C2=A0 =C2=A0 =C2=A0 no =C2=A0 =C2=A0 =C2=A0 =C2=A0=
 =C2=A0 =C2=A0 =C2=A0eth1
>>> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0=
 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =
=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0veth0_7573
>>>
>>> I wonder why the performance is greatly influenced by adding a veth=
 device
>>> to a bridge device.
>>
>> Hmm, good question :)

Bridging last I looked uses the least common denominator of hardware
offloads.  Which likely explains why adding a veth decreased your
bridging performance.

>>> Here is my experimental setting:
>>> =C2=A0 =C2=A0 =C2=A0 =C2=A0OS: Ubuntu server 8.10 amd64
>>> =C2=A0 =C2=A0 =C2=A0 =C2=A0Kernel: 2.6.27-rc8 (checkout from the lx=
c git repository)
>>
>> I would recommend to use the 2.6.29-rc8 vanilla because this kernel =
does no
>> longer need patches, a lot of fixes were done in the network namespa=
ce and
>> maybe the bridge has been improved in the meantime :)
>>
> I checked out the 2.6.29-rc8 vanilla kernel.
> The performance after issuing lxc-start improved to 8.7 Gbps!
> It's a big improvement, while some performance loss remains.
> Can not we avoid this loss?

Good question.  Any chance you can profile this and see where the
performance loss seems to be coming from?

Eric
