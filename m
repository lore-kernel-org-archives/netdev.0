From: Alexander Duyck <alexander.h.duyck@redhat.com>
Subject: Re: [RFC] use smp_load_acquire()/smp_store_release()
Date: Wed, 29 Oct 2014 14:13:51 -0700
Message-ID: <5451588F.6020505@redhat.com>
References: <1414594159.631.85.camel@edumazet-glaptop2.roam.corp.google.com>	 <545112E0.40106@redhat.com> <1414610868.2420.52.camel@jtkirshe-mobl> <1414612620.631.98.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev <netdev@vger.kernel.org>
To: Eric Dumazet <eric.dumazet@gmail.com>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:46622 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756291AbaJ2VNz (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 29 Oct 2014 17:13:55 -0400
In-Reply-To: <1414612620.631.98.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


On 10/29/2014 12:57 PM, Eric Dumazet wrote:
> On Wed, 2014-10-29 at 12:27 -0700, Jeff Kirsher wrote:
>> On Wed, 2014-10-29 at 09:16 -0700, Alexander Duyck wrote:
>>> On 10/29/2014 07:49 AM, Eric Dumazet wrote:
>>>> Hi Alexander
>>>>
>>>> The memory barriers added in commit
>>>> b37c0fbe3f6dfba1f8ad2aed47fb40578a254635
>>>> ("net: Add memory barriers to prevent possible race in byte queue
>>>> limits")
>>>>
>>>> have heavy cost.
>>>>
>>>> It seems we could use smp_load_acquire() and smp_store_release()
>>>> instead ?
>>>>
>>>> I'll post a patch later today. I would be interested if someone wa=
s able
>>>> to test it, as your commit apparently was tested and known to fix =
a
>>>> reproducible race.
>>>>
>>>> Thanks !
>> Eric- just CC me on the patch you post and I will see what I can do
>> about getting validation eyes on it.
> Thanks guys, will do, and will CC Paul as well.
>
> Alexander, here is the following profile showing the cost of the
> 'mfence', in a typical rpc workload (a lot of IRQ are generated for T=
X
> completions, because RPC tend to send small packets)
>
>    0.11 =E2=94=82       je     33a
>         =E2=94=82       mov    -0x3c(%rbp),%esi
>    0.06 =E2=94=82       lea    0xc0(%rbx),%rdi
>    0.06 =E2=94=82       callq  dql_completed
>    0.06 =E2=94=82       mfence
>   38.68 =E2=94=82       mov    0xc4(%rbx),%edx
>    1.83 =E2=94=82       mov    0xc0(%rbx),%eax
>         =E2=94=82       cmp    %eax,%edx
>    0.22 =E2=94=82       js     333
>    0.11 =E2=94=82       lock   btrl $0x1,0x98(%rbx)

It might be worthwhile to see if it would be possible to combine BQL=20
with the mechanism the drivers have for handling descriptors/packets. =20
Otherwise you are going to be pulling one barrier just to hit another=20
right after it.

Also depending on what driver it is that the trace is from you may want=
=20
to check and see if you have any MMIO transactions occurring right=20
before you make the call, otherwise that may be the actual cause for th=
e=20
significant cost as you are having to flush non-coherent memory before=20
you can resume operation.

Thanks,

Alex
