From: Hans Westgaard Ry <hans.westgaard.ry@oracle.com>
Subject: Re: [PATCH] net: add per device sg_max_frags for skb
Date: Wed, 13 Jan 2016 14:57:44 +0100
Message-ID: <569657D8.1020807@oracle.com>
References: <1452086182-26748-1-git-send-email-hans.westgaard.ry@oracle.com>
 <063D6719AE5E284EB5DD2968C1650D6D1CCBE5AA@AcuExch.aculab.com>
 <568F87AC.60405@oracle.com> <568FA1E5.7060204@stressinduktion.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>,
	James Morris <jmorris@namei.org>,
	Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>,
	Patrick McHardy <kaber@trash.net>,
	Alexei Starovoitov <ast@plumgrid.com>,
	Jiri Pirko <jiri@mellanox.com>,
	Eric Dumazet <edumazet@google.com>,
	Daniel Borkmann <daniel@iogearbox.net>,
	Nicolas Dichtel <nicolas.dichtel@6wind.com>,
	"Eric W. Biederman " <ebiederm@xmission.com>,
	Salam Noureddine <noureddine@arista.com>,
	Jarod Wilson <jarod@redhat.com>,
	Toshiaki Makita <makita.toshiaki@lab.ntt.co.jp>,
	Julian Anastasov <ja@ssi.bg>,
	Ying Xue <ying.xue@windriver.com>,
	Craig Gallek <kraig@google.com>,
	Mel Gorman <mgorman@techsingularity.net>,
	Edward Jee <edjee@google.com>,
	Julia Lawall <julia.lawall@lip6.fr>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	Haakon Bugge <haakon.bugge@oracle.co
To: Hannes Frederic Sowa <hannes@stressinduktion.org>,
	David Laight <David.Laight@ACULAB.COM>,
	"David S. Miller" <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <568FA1E5.7060204@stressinduktion.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org



On 01/08/2016 12:47 PM, Hannes Frederic Sowa wrote:
> On 08.01.2016 10:55, Hans Westgaard Ry wrote:
>>
>>
>> On 01/06/2016 02:59 PM, David Laight wrote:
>>> From: Hans Westgaard Ry
>>>> Sent: 06 January 2016 13:16
>>>> Devices may have limits on the number of fragments in an skb they
>>>> support. Current codebase uses a constant as maximum for number of
>>>> fragments (MAX_SKB_FRAGS) one skb can hold and use.
>>>>
>>>> When enabling scatter/gather and running traffic with many small
>>>> messages the codebase uses the maximum number of fragments and thereby
>>>> violates the max for certain devices.
>>>>
>>>> An example of such a violation is when running IPoIB on a HCA
>>>> supporting 16 SGE on an architecture with 4K pagesize. The
>>>> MAX_SKB_FRAGS will be 17 (64K/4K+1) and because IPoIB adds yet another
>>>> segment we end up with send_requests with 18 SGE resulting in
>>>> kernel-panic.
>>>>
>>>> The patch allows the device to limit the maximum number fragments used
>>>> in one skb.
>>> This doesn't seem to me to be the correct way to fix this.
>>> Anything that adds an extra fragment (in this case IPoIB) should allow
>>> for the skb already having the maximum number of fragments.
>>> Fully linearising the skb is overkill, but I think the first fragment
>>> can be added to the linear part of the skb.
>>>
>>>     David
>>>
>>>
>> When IpoIB handles a skb-request it converts fragments to SGEs to
>> be handled by a HCA.
>> The problem arises when the HCA have a limited number of SGEs less than
>> MAX_SKB_FRAGS.
>> (it gets a little worse since IPoIB need to yet another segment)
>> I have not found any easy way of fixing this with currenct codebase.
>
> I think because of the complex forwarding nature, a global counter 
> which driver's can reduce during initialization time is the only 
> solution I see right now without changing the layout of the skb later on.
>
> Unfortunately this doesn't resolve the cases were virtual machines 
> inject gso skbs, for those there still needs to be a slow path to do 
> the reformatting of the skb. :/
>
> Bye,
> Hannes
>
>
The use-case for this patch is an application which sends many small 
messages, by write(2) on a TCP socket which has Nagle enabled. A 
scatter-gather capable NIC (potentially also supporting tso) will then 
be asked to send an skb containing up to MAX_SKB_FRAGS worth of 
fragments (17 considering a 4kb page size, hypothetically 65 considering 
an arch supporting 1kb page size).

Now, if the NIC hardware supports less _gather-fragments_, said hardware 
must run with scatter-gather disabled - or - the NIC driver has to 
implement a partial linearization of the skb to reduce #frags to what 
the hardware supports. The latter is far from elegant, and must be 
implemented in all NIC drivers which have this restriction.

This patch provides the flexibility to choose the maximum number of 
fragments that can be passed down to the NIC in order to
utilize the NIC SG hardware features.


In our view we are discussing two different issues:

    1. Is it reasonable that a NIC can restrict #frags in an skb when 
transmitting?
    2. If yes to the above, how is this implemented the best possible way.

Thanks a lot for feedback on the implementation from David Laight, Eric 
Dumazet and Hannes Fredreric Sowa.

What do you think?

        Hans
