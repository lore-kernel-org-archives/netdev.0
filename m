From: John Fastabend via iovisor-dev <iovisor-dev-9jONkmmOlFHEE9lA1F8Ukti2O/JbrIOy@public.gmane.org>
Subject: Re: XDP seeking input from NIC hardware vendors
Date: Tue, 12 Jul 2016 12:13:01 -0700
Message-ID: <5785413D.4050901@gmail.com>
References: <20160707124245.6d95635a@redhat.com>
	<D6BB30FE66EA894C9F13C9E3CDDF00F564E5FB81@fmsmsx115.amr.corp.intel.com>
	<20160708022210.GA12244@ast-mbp.thefacebook.com>
	<20160708144453.345b51e5@jkicinski-Precision-T1700>
	<20160708171943.0e1ce8d7@redhat.com>
	<20160708170751.2eaae790@jkicinski-Precision-T1700>
	<577FD8A5.8020700@gmail.com>
	<20160708185107.10c0dbe4@jkicinski-Precision-T1700>
	<20160709132726.3cbccf11@redhat.com>
	<20160712022423.GA47757@ast-mbp.thefacebook.com>
Reply-To: John Fastabend <john.fastabend-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: Jakub Kicinski <jakub.kicinski-wFxRvT7yatFl57MIdRCFDg@public.gmane.org>,
	"netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	"iovisor-dev-9jONkmmOlFHEE9lA1F8Ukti2O/JbrIOy@public.gmane.org" <iovisor-dev-9jONkmmOlFHEE9lA1F8Ukti2O/JbrIOy@public.gmane.org>,
	"Fastabend, John R" <john.r.fastabend-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>,
	Edward Cree <ecree-s/n/eUQHGBpZroRs9YW3xA@public.gmane.org>,
	Simon Horman <simon.horman-wFxRvT7yatFl57MIdRCFDg@public.gmane.org>,
	Rana Shahout <ranas-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>,
	Or Gerlitz <ogerlitz-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>, Ari Saha <as754m-60p5jsuXm+c@public.gmane.org>
To: Alexei Starovoitov <alexei.starovoitov-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>,
	Jesper Dangaard Brouer <brouer-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
Return-path: <iovisor-dev-bounces-9jONkmmOlFHEE9lA1F8Ukti2O/JbrIOy@public.gmane.org>
In-Reply-To: <20160712022423.GA47757-+o4/htvd0TDFYCXBM6kdu7fOX0fSgVTm@public.gmane.org>
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

On 16-07-11 07:24 PM, Alexei Starovoitov wrote:
> On Sat, Jul 09, 2016 at 01:27:26PM +0200, Jesper Dangaard Brouer wrote:
>> On Fri, 8 Jul 2016 18:51:07 +0100
>> Jakub Kicinski <jakub.kicinski-wFxRvT7yatFl57MIdRCFDg@public.gmane.org> wrote:
>>
>>> On Fri, 8 Jul 2016 09:45:25 -0700, John Fastabend wrote:
>>>> The only distinction between VFs and queue groupings on my side is VFs
>>>> provide RSS where as queue groupings have to be selected explicitly.
>>>> In a programmable NIC world the distinction might be lost if a "RSS"
>>>> program can be loaded into the NIC to select queues but for existing
>>>> hardware the distinction is there.  
>>>
>>> To do BPF RSS we need a way to select the queue which I think is all
>>> Jesper wanted.  So we will have to tackle the queue selection at some
>>> point.  The main obstacle with it for me is to define what queue
>>> selection means when program is not offloaded to HW...  Implementing
>>> queue selection on HW side is trivial.
>>
>> Yes, I do see the problem of fallback, when the programs "filter" demux
>> cannot be offloaded to hardware.
>>
>> First I though it was a good idea to keep the "demux-filter" part of
>> the eBPF program, as software fallback can still apply this filter in
>> SW, and just mark the packets as not-zero-copy-safe.  But when HW
>> offloading is not possible, then packets can be delivered every RX
>> queue, and SW would need to handle that, which hard to keep transparent.
>>
>>
>>>> If you demux using a eBPF program or via a filter model like
>>>> flow_director or cls_{u32|flower} I think we can support both. And this
>>>> just depends on the programmability of the hardware. Note flow_director
>>>> and cls_{u32|flower} steering to VFs is already in place.  
>>
>> Maybe we should keep HW demuxing as a separate setup step.
>>
>> Today I can almost do what I want: by setting up ntuple filters, and (if
>> Alexei allows it) assign an application specific XDP eBPF program to a
>> specific RX queue.
>>
>>  ethtool -K eth2 ntuple on
>>  ethtool -N eth2 flow-type udp4 dst-ip 192.168.254.1 dst-port 53 action 42
>>
>> Then the XDP program can be attached to RX queue 42, and
>> promise/guarantee that it will consume all packet.  And then the
>> backing page-pool can allow zero-copy RX (and enable scrubbing when
>> refilling pool).
> 
> so such ntuple rule will send udp4 traffic for specific ip and port
> into a queue then it will somehow gets zero-copied to vm?
> . looks like a lot of other pieces about zero-copy and qemu need to be
> implemented (or at least architected) for this scheme to be conceivable
> . and when all that happens what vm is going to do with this very specific
> traffic? vm won't have any tcp or even ping?

I have perhaps a different motivation to have queue steering in 'tc
cls-u32' and eventually xdp. The general idea is I have thousands of
queues and I can bind applications to the queues. When I know an
application is bound to a queue I can enable per queue busy polling (to
be implemented), set specific interrupt rates on the queue
(implementation will be posted soon), bind the queue to the correct
cpu, etc.

ntuple works OK for this now but xdp provides more flexibility and
also lets us add additional policy on the queue other than simply
queue steering.

I'm not convinced though that the demux queue selection should be part
of the XDP program itself just because it has no software analog to me
it sits in front of the set of XDP programs. But I think I could perhaps
be convinced it does if there is some reasonable way to do it. I guess
the single program method would result in an XDP program that read like

  if (rx_queue == x)
       do_foo
  if (rx_queue == y)
       do_bar

A hardware jit may be able to sort that out. Or use per queue sections.

> 
> the network virtualization traffic is typically encapsulated,
> so if xdp is used to do steer the traffic, the program would need
> to figure out vm id based on headers, strip tunnel, apply policy before
> forwarding the packet further. Clearly hw ntuple is not going to suffice.
>
> If there is no networking virtualization and VMs are operating in the
> flat network, then there is no policy, no ip filter, no vm migration.
> Only mac per vm and sriov handles this case just fine.
> When hw becomes more programmable we'll be able to load xdp program
> into hw that does tunnel, policy and forwards into vf then sriov will
> become actually usable for cloud providers.

Yep :)

> hw xdp into vf is more interesting than into a queue, since there is
> more than one queue/interrupt per vf and network heavy vm can actually
> consume large amount of traffic.
> 

Another use case I have is to make a really high performance AF_PACKET
interface. So if there was a way to say bind a queue to an AF_PACKET
ring and run a policy XDP program before hitting the AF_PACKET
descriptor bit that would be really interesting because it would solve
some of my need for poll mode drivers in userspace.

.John
