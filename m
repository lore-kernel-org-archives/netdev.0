From: KY Srinivasan <kys@microsoft.com>
Subject: RE: [PATCH net-next] hv_netvsc: don't make assumptions on struct
 flow_keys layout
Date: Fri, 8 Jan 2016 03:49:17 +0000
Message-ID: <BY2PR0301MB1654E8D1527055DCF31139D2A0F60@BY2PR0301MB1654.namprd03.prod.outlook.com>
References: <1452159189-11473-1-git-send-email-vkuznets@redhat.com>
 <1452171150.8255.207.camel@edumazet-glaptop2.roam.corp.google.com>
 <877fjlfrid.fsf@vitty.brq.redhat.com> <568F0A90.8040109@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: Tom Herbert <tom@herbertland.com>, Haiyang Zhang <haiyangz@microsoft.com>,
 "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
 "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
 "devel@linuxdriverproject.org" <devel@linuxdriverproject.org>,
 David Miller <davem@davemloft.net>
To: John Fastabend <john.fastabend@gmail.com>, Vitaly Kuznetsov
 <vkuznets@redhat.com>, Simon Xiao <sixiao@microsoft.com>, Eric Dumazet
 <eric.dumazet@gmail.com>
Return-path: <driverdev-devel-bounces@linuxdriverproject.org>
In-Reply-To: <568F0A90.8040109@gmail.com>
Content-Language: en-US
List-Unsubscribe: <http://driverdev.linuxdriverproject.org/mailman/options/driverdev-devel>,
 <mailto:driverdev-devel-request@linuxdriverproject.org?subject=unsubscribe>
List-Archive: <http://driverdev.linuxdriverproject.org/pipermail/driverdev-devel/>
List-Post: <mailto:driverdev-devel@linuxdriverproject.org>
List-Help: <mailto:driverdev-devel-request@linuxdriverproject.org?subject=help>
List-Subscribe: <http://driverdev.linuxdriverproject.org/mailman/listinfo/driverdev-devel>,
 <mailto:driverdev-devel-request@linuxdriverproject.org?subject=subscribe>
Errors-To: driverdev-devel-bounces@linuxdriverproject.org
Sender: "devel" <driverdev-devel-bounces@linuxdriverproject.org>
List-Id: netdev.vger.kernel.org



> -----Original Message-----
> From: John Fastabend [mailto:john.fastabend@gmail.com]
> Sent: Thursday, January 7, 2016 5:02 PM
> To: Vitaly Kuznetsov <vkuznets@redhat.com>; Simon Xiao
> <sixiao@microsoft.com>; Eric Dumazet <eric.dumazet@gmail.com>
> Cc: Tom Herbert <tom@herbertland.com>; netdev@vger.kernel.org; KY
> Srinivasan <kys@microsoft.com>; Haiyang Zhang <haiyangz@microsoft.com>;
> devel@linuxdriverproject.org; linux-kernel@vger.kernel.org; David Miller
> <davem@davemloft.net>
> Subject: Re: [PATCH net-next] hv_netvsc: don't make assumptions on struct
> flow_keys layout
> 
> On 16-01-07 05:28 AM, Vitaly Kuznetsov wrote:
> > Eric Dumazet <eric.dumazet@gmail.com> writes:
> >
> >> On Thu, 2016-01-07 at 10:33 +0100, Vitaly Kuznetsov wrote:
> >>> Recent changes to 'struct flow_keys' (e.g commit d34af823ff40 ("net: Add
> >>>  VLAN ID to flow_keys")) introduced a performance regression in netvsc
> >>> driver. Is problem is, however, not the above mentioned commit but the
> >>> fact that netvsc_set_hash() function did some assumptions on the struct
> >>> flow_keys data layout and this is wrong. We need to extract the data we
> >>> need (src/dst addresses and ports) after the dissect.
> >>>
> >>> The issue could also be solved in a completely different way: as suggested
> >>> by Eric instead of our own homegrown netvsc_set_hash() we could use
> >>> skb_get_hash() which does more or less the same. Unfortunately, the
> >>> testing done by Simon showed that Hyper-V hosts are not happy with our
> >>> Jenkins hash, selecting the output queue with the current algorithm based
> >>> on Toeplitz hash works significantly better.
> >>
> 
> Also can I ask the maybe naive question. It looks like the hypervisor
> is populating some table via a mailbox msg and this is used to select
> the queues I guess with some sort of weighting function?
> 
> What happens if you just remove select_queue altogether? Or maybe just
> what is this 16 entry table doing? How does this work on my larger
> systems with 64+ cores can I only use 16 cores? Sorry I really have
> no experience with hyperV and this got me curious.

We will limit the number of VRSS channels to the number of CPUs in
a NUMA node. If the number of CPUs in a NUMA node exceeds 8, we
will only open up 8 VRSS channels. On the host side currently traffic
spreading is done in software and we have found that limiting to 8 CPUs
gives us the best throughput. In Windows Server 2016, we will be 
distributing traffic on the host in hardware; the heuristics in the guest
may change.

Regards,

K. Y
> 
> Thanks,
> John
> 
> >> Were tests done on IPv6 traffic ?
> >>
> >
> > Simon, could you please test this patch for IPv6 and show us the numbers?
> >
> >> Toeplitz hash takes at least 100 ns to hash 12 bytes (one iteration per
> >> bit : 96 iterations)
> >>
> >> For IPv6 it is 3 times this, since we have to hash 36 bytes.
> >>
> >> I do not see how it can compete with skb_get_hash() that directly gives
> >> skb->hash for local TCP flows.
> >>
> >
> > My guess is that this is not the bottleneck, something is happening
> > behind the scene with out packets in Hyper-V host (e.g. re-distributing
> > them to hardware queues?) but I don't know the internals, Microsoft
> > folks could probably comment.
> >
> >
> >> See commits b73c3d0e4f0e1961e15bec18720e48aabebe2109
> >> ("net: Save TX flow hash in sock and set in skbuf on xmit")
> >> and 877d1f6291f8e391237e324be58479a3e3a7407c
> >> ("net: Set sk_txhash from a random number")
> >>
> >> I understand Microsoft loves Toeplitz, but this looks not well placed
> >> here.
> >>
> >> I suspect there is another problem.
> >>
> >> Please share your numbers and test methodology, and the alternative
> >> patch Simon tested so that we can double check it.
> >>
> >
> > Alternative patch which uses skb_get_hash() attached. Simon, could you
> > please share the rest (environment, metodology, numbers) with us here?
> > Thanks!
> >
> >> Thanks.
> >>
> >> PS: For the time being this patch can probably be applied on -net tree,
> >> as it fixes a real bug.
> >
