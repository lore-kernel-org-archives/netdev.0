From: Ryousei Takano <ryousei@gmail.com>
Subject: Re: [lxc-devel] Poor bridging performance on 10 GbE
Date: Thu, 19 Mar 2009 00:56:53 +0900
Message-ID: <b30d1c3b0903180856r6dce554ap35b8d6a3ee7829e0@mail.gmail.com>
References: <b30d1c3b0903180221h5175618eue162ffdec3817b4c@mail.gmail.com>
	 <49C0C87B.7070507@fr.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: lxc-devel@lists.sourceforge.net,
	Linux Containers <containers@lists.osdl.org>,
	Linux Netdev List <netdev@vger.kernel.org>
To: Daniel Lezcano <dlezcano@fr.ibm.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rv-out-0506.google.com ([209.85.198.231]:40982 "EHLO
	rv-out-0506.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751184AbZCRP4y convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 18 Mar 2009 11:56:54 -0400
Received: by rv-out-0506.google.com with SMTP id f9so64820rvb.1
        for <netdev@vger.kernel.org>; Wed, 18 Mar 2009 08:56:53 -0700 (PDT)
In-Reply-To: <49C0C87B.7070507@fr.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Daniel,

On Wed, Mar 18, 2009 at 7:10 PM, Daniel Lezcano <dlezcano@fr.ibm.com> w=
rote:
> Ryousei Takano wrote:
>>
>> Hi all,
>>
>> I am evaluating the networking performance of lxc on 10 Gigabit Ethe=
rnet
>> by
>> using netperf benchmark.
>
> Thanks for doing benchmarking.
> I did two years ago similar tests and there is an analysis of the
> performances at:
> http://lxc.sourceforge.net/network/benchs.php
>
> It is not up to date, but that will give you some clues of what is ha=
ppening
> with this overhead.
>
I am using VServer because other virtualization mechanisms, including O=
penVZ,
Xen, and KVM cannot fully utilize the network bandwidth of 10 GbE.

Here are the results of netperf bencmark:
	vanilla (2.6.27-9)		9525.94
	Vserver (2.6.27.10)	9521.79
	OpenVZ (2.6.27.10)	2049.89
	Xen (2.6.26.1)		1011.47
	KVM (2.6.27-9)		1022.42

Now I am interesting to use LXC instead of VServer.

>> Using a macvlan device, the throughput was 9.6 Gbps. But, using a ve=
th
>> device,
>> the throughput was only 2.7 Gbps.
>
> Yeah, definitively the macvlan interfaces is the best in terms of
> performances but with the restriction of not being able to communicat=
e
> between containers on the same hosts.
>
This restriction is not so big issue for my purpose.

> There are some discussions around that:
>
> http://marc.info/?l=3Dlinux-netdev&m=3D123643508124711&w=3D2
>
> The veth is a virtual device hence it has not offloading. When the pa=
cket
> are sent out, the network stack looks at the nic offloading capabilit=
y which
> is not present. So the kernel will compute the checksums instead of l=
etting
> the nic to do that either if the packet is transmitted through the ph=
ysical
> nic. This is a well known issue related to network virtualization and=
 xen
> has developed a specific network driver:
> http://www.cse.psu.edu/~bhuvan/teaching/spring06/papers/xen-net-opt.p=
df
>
>> I think this is because the overhead of bridging devices is high.
>
> Yes, bridging adds some overhead and AFAIR bridging + netfilter does =
some
> skb copy.
>
Thank you for pointers.

>> I also checked the host OS's performance when I used a veth device.
>> I observed a strange phenomenon.
>>
>> Before issuing lxc-start command, the throughput was 9.6 Gbps.
>> Here is the output of brctl show:
>> =A0 =A0 =A0 =A0$ brctl show
>> =A0 =A0 =A0 =A0bridge name =A0 =A0 bridge id =A0 =A0 =A0 =A0 =A0 =A0=
 =A0 STP enabled =A0 =A0 interfaces
>> =A0 =A0 =A0 =A0br0 =A0 =A0 =A0 =A0 =A0 =A0 8000.0060dd470d49 =A0 =A0=
 =A0 no =A0 =A0 =A0 =A0 =A0 =A0 =A0eth1
>>
>> After issuing lxc-start command, the throughput decreased to 3.2 Gbp=
s.
>> Here is the output of brctl show:
>> =A0 =A0 =A0 =A0$ sudo brctl show
>> =A0 =A0 =A0 =A0bridge name =A0 =A0 bridge id =A0 =A0 =A0 =A0 =A0 =A0=
 =A0 STP enabled =A0 =A0 interfaces
>> =A0 =A0 =A0 =A0br0 =A0 =A0 =A0 =A0 =A0 =A0 8000.0060dd470d49 =A0 =A0=
 =A0 no =A0 =A0 =A0 =A0 =A0 =A0 =A0eth1
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =
=A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0veth0_7573
>>
>> I wonder why the performance is greatly influenced by adding a veth =
device
>> to a bridge device.
>
> Hmm, good question :)
>
>> Here is my experimental setting:
>> =A0 =A0 =A0 =A0OS: Ubuntu server 8.10 amd64
>> =A0 =A0 =A0 =A0Kernel: 2.6.27-rc8 (checkout from the lxc git reposit=
ory)
>
> I would recommend to use the 2.6.29-rc8 vanilla because this kernel d=
oes no
> longer need patches, a lot of fixes were done in the network namespac=
e and
> maybe the bridge has been improved in the meantime :)
>
I checked out the 2.6.29-rc8 vanilla kernel.
The performance after issuing lxc-start improved to 8.7 Gbps!
It's a big improvement, while some performance loss remains.
Can not we avoid this loss?

>> =A0 =A0 =A0 =A0Userland tool: 0.6.0
>> =A0 =A0 =A0 =A0NIC: Myricom Myri-10G
>>
>> Any comments and suggestions will be appreciate.
>> If this list is not proper place to talk about this problem, can any=
one
>> tell me
>> the proper one?
>
> The performances question is more related to the network virtualizati=
on
> implementation and should be sent to netdev@ and containers@ (added i=
n the
> Cc' of this email), of course people at lxc-devel@ will be interested=
 by
> these aspects, so lxc-devel@ is the right mailing list too.
>
> Thanks for your testings
> =A0-- Daniel
>

Best regards,
Ryousei Takano
