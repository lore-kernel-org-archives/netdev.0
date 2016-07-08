From: John Fastabend via iovisor-dev <iovisor-dev-9jONkmmOlFHEE9lA1F8Ukti2O/JbrIOy@public.gmane.org>
Subject: Re: XDP seeking input from NIC hardware vendors
Date: Fri, 8 Jul 2016 09:45:25 -0700
Message-ID: <577FD8A5.8020700@gmail.com>
References: <20160707124245.6d95635a@redhat.com>
	<D6BB30FE66EA894C9F13C9E3CDDF00F564E5FB81@fmsmsx115.amr.corp.intel.com>
	<20160708022210.GA12244@ast-mbp.thefacebook.com>
	<20160708144453.345b51e5@jkicinski-Precision-T1700>
	<20160708171943.0e1ce8d7@redhat.com>
	<20160708170751.2eaae790@jkicinski-Precision-T1700>
Reply-To: John Fastabend <john.fastabend-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: "netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	"iovisor-dev-9jONkmmOlFHEE9lA1F8Ukti2O/JbrIOy@public.gmane.org" <iovisor-dev-9jONkmmOlFHEE9lA1F8Ukti2O/JbrIOy@public.gmane.org>,
	"Fastabend, John R" <john.r.fastabend-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>,
	Edward Cree <ecree-s/n/eUQHGBpZroRs9YW3xA@public.gmane.org>,
	Simon Horman <simon.horman-wFxRvT7yatFl57MIdRCFDg@public.gmane.org>,
	Rana Shahout <ranas-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>,
	Or Gerlitz <ogerlitz-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>, Ari Saha <as754m-60p5jsuXm+c@public.gmane.org>
To: Jakub Kicinski <jakub.kicinski-wFxRvT7yatFl57MIdRCFDg@public.gmane.org>,
	Jesper Dangaard Brouer <brouer-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
Return-path: <iovisor-dev-bounces-9jONkmmOlFHEE9lA1F8Ukti2O/JbrIOy@public.gmane.org>
In-Reply-To: <20160708170751.2eaae790@jkicinski-Precision-T1700>
List-Unsubscribe: <https://lists.iovisor.org/mailman/options/iovisor-dev>,
	<mailto:iovisor-dev-request-9jONkmmOlFHEE9lA1F8Ukti2O/JbrIOy@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.iovisor.org/pipermail/iovisor-dev/>
List-Post: <mailto:iovisor-dev-9jONkmmOlFHEE9lA1F8Ukti2O/JbrIOy@public.gmane.org>
List-Help: <mailto:iovisor-dev-request-9jONkmmOlFHEE9lA1F8Ukti2O/JbrIOy@public.gmane.org?subject=help>
List-Subscribe: <https://lists.iovisor.org/mailman/listinfo/iovisor-dev>,
	<mailto:iovisor-dev-request-9jONkmmOlFHEE9lA1F8Ukti2O/JbrIOy@public.gmane.org?subject=subscribe>
Sender: iovisor-dev-bounces-9jONkmmOlFHEE9lA1F8Ukti2O/JbrIOy@public.gmane.org
Errors-To: iovisor-dev-bounces-9jONkmmOlFHEE9lA1F8Ukti2O/JbrIOy@public.gmane.org
List-Id: netdev.vger.kernel.org

On 16-07-08 09:07 AM, Jakub Kicinski wrote:
> On Fri, 8 Jul 2016 17:19:43 +0200, Jesper Dangaard Brouer wrote:
>> On Fri, 8 Jul 2016 14:44:53 +0100 Jakub Kicinski <jakub.kicinski-wFxRvT7yatFl57MIdRCFDg@public.gmane.org> wrote:
>>> On Thu, 7 Jul 2016 19:22:12 -0700, Alexei Starovoitov wrote:
>>>>> If the goal is to just separate XDP traffic from non-XDP traffic
>>>>> you could accomplish this with a combination of SR-IOV/macvlan to
>>>>> separate the device queues into multiple netdevs and then run XDP
>>>>> on just one of the netdevs. Then use flow director (ethtool) or
>>>>> 'tc cls_u32/flower' to steer traffic to the netdev. This is how
>>>>> we support multiple networking stacks on one device by the way it
>>>>> is called the bifurcated driver. Its not too far of a stretch to
>>>>> think we could offload some simple XDP programs to program the
>>>>> splitting of traffic instead of cls_u32/flower/flow_director and
>>>>> then you would have a stack of XDP programs. One running in
>>>>> hardware and a set running on the queues in software.      
>>>>
>>>>
>>>> the above sounds like much better approach then Jesper/mine
>>>> prog_per_ring stuff.
>>>>
>>>> If we can split the nic via sriov and have dedicated netdev via VF
>>>> just for XDP that's way cleaner approach. I guess we won't need to
>>>> do xdp_rxqmask after all.    
>>>
>>> +1
>>>
>>> I was thinking about using eBPF to direct to NIC queues but concluded
>>> that doing a redirect to a VF is cleaner.  Especially if the PF driver
>>> supports VF representatives we could potentially just use
>>> bpf_redirect(VFR netdev) and the VF doesn't even have to be handled by
>>> the same stack.  
>>
>> I actually disagree.
>>
>> I _do_ want to use the "filter" part of eBPF to direct to NIC queues, and
>> then run a single/specific XDP program on that queue.
>>
>> Why to I want this?
>>
>> This part of solving a very fundamental CS problem (early demux), when
>> wanting to support Zero-copy on RX.  The basic problem that the NIC
>> driver need to map RX pages into the RX ring, prior to receiving
>> packets. Thus, we need HW support to steer packets, for gaining enough
>> isolation (e.g between tenants domains) for allowing zero-copy.
>>
>>
>> Based on the flexibility of the HW-filter, the granularity achievable
>> for isolation (e.g. application specific) is much more flexible.  Than
>> splitting up the entire NIC with SR-IOV, VFs or macvlans.
> 
> I think of SR-IOV VFs a way of grouping queues.  If HW is capable of
> directing to a queue it's usually capable of directing to a VF as well.
> And the VF could have all other traffic disabled so you would get only
> packets directed to it by the (BPF) filter - same as you would for the
> queue.  Does that make sense for zero copy apps?
> 

The only distinction between VFs and queue groupings on my side is VFs
provide RSS where as queue groupings have to be selected explicitly.
In a programmable NIC world the distinction might be lost if a "RSS"
program can be loaded into the NIC to select queues but for existing
hardware the distinction is there.

If you demux using a eBPF program or via a filter model like
flow_director or cls_{u32|flower} I think we can support both. And this
just depends on the programmability of the hardware. Note flow_director
and cls_{u32|flower} steering to VFs is already in place.

The question I have is should the "filter" part of the eBPF program
be a separate program from the XDP program and loaded using specific
semantics (e.g. "load_hardware_demux" ndo op) at the risk of building
a ever growing set of "ndo" ops. If you are running multiple XDP
programs on the same NIC hardware then I think this actually makes
sense otherwise how would the hardware and even software find the
"demux" logic. In this model there is a "demux" program that selects
a queue/VF and a program that runs on the netdev queues.

Any thoughts?

.John
