From: ebiederm@xmission.com (Eric W. Biederman)
Subject: Re: Trying to implement secondary loopback
Date: Fri, 15 Mar 2013 01:59:30 -0700
Message-ID: <87ip4t598t.fsf@xmission.com>
References: <513F1A17.1000809@hhi.fraunhofer.de>
	<CAFLxGvxcyDVwC-iys6UdKMBB6u3UQx6s7-mwm5caoNu=N7rmeA@mail.gmail.com>
	<3D7E565A361FB844A410A5EFCDD7BA4002ECF5@MXSRV3.fe.hhi.de>
	<87r4jjav00.fsf@xmission.com>
	<3D7E565A361FB844A410A5EFCDD7BA4002EF11@MXSRV3.fe.hhi.de>
	<878v5r9es7.fsf@xmission.com> <5142CE23.9070804@hhi.fraunhofer.de>
Mime-Version: 1.0
Content-Type: text/plain
Cc: richard -rw- weinberger <richard.weinberger@gmail.com>,
	"netdev\@vger.kernel.org" <netdev@vger.kernel.org>,
	"davem\@davemloft.net" <davem@davemloft.net>,
	"edumazet\@google.com" <edumazet@google.com>,
	"herbert\@gondor.apana.org.au" <herbert@gondor.apana.org.au>
To: Thomas Martitz <thomas.martitz@hhi.fraunhofer.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from out01.mta.xmission.com ([166.70.13.231]:55487 "EHLO
	out01.mta.xmission.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753727Ab3COI7l (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 15 Mar 2013 04:59:41 -0400
In-Reply-To: <5142CE23.9070804@hhi.fraunhofer.de> (Thomas Martitz's message of
	"Fri, 15 Mar 2013 08:30:43 +0100")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Thomas Martitz <thomas.martitz@hhi.fraunhofer.de> writes:

> Am 13.03.2013 22:21, schrieb Eric W. Biederman:
>> "Martitz, Thomas" <thomas.martitz@hhi.fraunhofer.de> writes:
>>
>>>> Von: Eric W. Biederman [ebiederm@xmission.com]
>>>>
>>>> The easy solution is to setup two network namespaces and two nics.
>>>> And transmit data from one network namespace to another, through your
>>>> nics.
>>
>>>
>>> That sounds a lot more involed than using loopback to send data back
>>> to the same process. And I guess just calling netif_rx() in the xmit()
>>> function wouldn't be sufficient either? Also I wouldn't know how to do
>>> that as I'm not yet very familiar with network namespaces (but that
>>> can clearly get fixed).
>>
>> It may sound involved but it is just a few lines of code to set up.
>>
>> ip netns add ns1
>> ip netns add ns2
>> ip link set nic1 netns ns1
>> ip link set nic2 netns ns2
>>
>> int main(int argc, char **argv)
>> {
>>          int netfd1, netfd2;
>>          int sk1, sk2;
>> 	netfd1 = open(/var/run/netns/nic1);
>> 	netfd2 = open(/var/run/netns/nic2);
>>
>> 	setns(netfd1, 0);
>> 	sk1 = socket(...);
>>
>>          setns(netfd2, 0);
>>          sk2 = socket(...);
>>
>>          /* test test test */
>> }
>>
>> And what is partidcularly interesting is that all of this works with
>> your drivers normal code paths without any kernel hacks.
>>
>> Eric
>>
>
>
> I have trouble understanding this approach. Does it mean that I have
> to expose two interfaces from my kernel module. I.e. call
> register_netdev() twice?

The suggestion was to have one driver, driving two identical nics
plugged into the same machine with a cable between them. That creates no
special cases on your side for testing.

Shrug.  It is your driver, and your hardware, feel free to 
develop however you want.

> Or use a "struct pernet_operations" to create
> a netdev on a per-namespace basis.
> If I do either of the above I end up with two "struct netdev" and two
> MAC addresses, which I don't really want. Also I would need to
> transfer from one netdev to the other in the driver's ndo_start_xmit()
> method instead of simply calling netif_rx().
>
> Perhaps I'm misunderstanding, I'm s
>
> During my development, looping back the data in ndo_start_xmit() is
> only a first step. The next step is to pass the data via PCIe and
> getting the same data back later. This is why I want to keep the
> loopback as simple/straightforward as possible.

I guess the question is why do you want to loopback the data?

For testing your NIC driver?  Or are you trying some strange scheme
where you try and offload processing between sockets on the same machine?

Eric
