From: "Michael S. Tsirkin" <mst@redhat.com>
Subject: Re: [PATCH 1/3] ipv6: Select fragment id during UFO/GSO segmentation
	if not set.
Date: Wed, 28 Jan 2015 17:49:37 +0200
Message-ID: <20150128154937.GA32439@redhat.com>
References: <1422366458.13969.11.camel@stressinduktion.org>
	<54C7A007.6050707@redhat.com>
	<1422374551.13969.35.camel@stressinduktion.org>
	<20150127160808.GA10765@redhat.com>
	<1422433508.4678.14.camel@stressinduktion.org>
	<20150128094658.GB16775@redhat.com>
	<1422441242.4678.32.camel@stressinduktion.org>
	<54C8EF25.1030302@redhat.com>
	<1422456339.4678.85.camel@stressinduktion.org>
	<54C8FFF3.7050800@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, Vladislav Yasevich <vyasevich@gmail.com>,
	virtualization@lists.linux-foundation.org, edumazet@google.com,
	Hannes Frederic Sowa <hannes@stressinduktion.org>,
	Ben Hutchings <ben@decadent.org.uk>
To: Vlad Yasevich <vyasevic@redhat.com>
Return-path: <virtualization-bounces@lists.linux-foundation.org>
Content-Disposition: inline
In-Reply-To: <54C8FFF3.7050800@redhat.com>
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/virtualization>,
	<mailto:virtualization-request@lists.linux-foundation.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/virtualization/>
List-Post: <mailto:virtualization@lists.linux-foundation.org>
List-Help: <mailto:virtualization-request@lists.linux-foundation.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/virtualization>,
	<mailto:virtualization-request@lists.linux-foundation.org?subject=subscribe>
Sender: virtualization-bounces@lists.linux-foundation.org
Errors-To: virtualization-bounces@lists.linux-foundation.org
List-Id: netdev.vger.kernel.org

On Wed, Jan 28, 2015 at 10:27:47AM -0500, Vlad Yasevich wrote:
> On 01/28/2015 09:45 AM, Hannes Frederic Sowa wrote:
> > Hi,
> > 
> > On Mi, 2015-01-28 at 09:16 -0500, Vlad Yasevich wrote:
> >> On 01/28/2015 05:34 AM, Hannes Frederic Sowa wrote:
> >>> Hi,
> >>>
> >>> On Mi, 2015-01-28 at 11:46 +0200, Michael S. Tsirkin wrote:
> >>>> On Wed, Jan 28, 2015 at 09:25:08AM +0100, Hannes Frederic Sowa wrote:
> >>>>> Hello,
> >>>>>
> >>>>> On Di, 2015-01-27 at 18:08 +0200, Michael S. Tsirkin wrote:
> >>>>>> On Tue, Jan 27, 2015 at 05:02:31PM +0100, Hannes Frederic Sowa wrote:
> >>>>>>> On Di, 2015-01-27 at 09:26 -0500, Vlad Yasevich wrote:
> >>>>>>>> On 01/27/2015 08:47 AM, Hannes Frederic Sowa wrote:
> >>>>>>>>> On Di, 2015-01-27 at 10:42 +0200, Michael S. Tsirkin wrote:
> >>>>>>>>>> On Tue, Jan 27, 2015 at 02:47:54AM +0000, Ben Hutchings wrote:
> >>>>>>>>>>> On Mon, 2015-01-26 at 09:37 -0500, Vladislav Yasevich wrote:
> >>>>>>>>>>>> If the IPv6 fragment id has not been set and we perform
> >>>>>>>>>>>> fragmentation due to UFO, select a new fragment id.
> >>>>>>>>>>>> When we store the fragment id into skb_shinfo, set the bit
> >>>>>>>>>>>> in the skb so we can re-use the selected id.
> >>>>>>>>>>>> This preserves the behavior of UFO packets generated on the
> >>>>>>>>>>>> host and solves the issue of id generation for packet sockets
> >>>>>>>>>>>> and tap/macvtap devices.
> >>>>>>>>>>>>
> >>>>>>>>>>>> This patch moves ipv6_select_ident() back in to the header file.  
> >>>>>>>>>>>> It also provides the helper function that sets skb_shinfo() frag
> >>>>>>>>>>>> id and sets the bit.
> >>>>>>>>>>>>
> >>>>>>>>>>>> It also makes sure that we select the fragment id when doing
> >>>>>>>>>>>> just gso validation, since it's possible for the packet to
> >>>>>>>>>>>> come from an untrusted source (VM) and be forwarded through
> >>>>>>>>>>>> a UFO enabled device which will expect the fragment id.
> >>>>>>>>>>>>
> >>>>>>>>>>>> CC: Eric Dumazet <edumazet@google.com>
> >>>>>>>>>>>> Signed-off-by: Vladislav Yasevich <vyasevic@redhat.com>
> >>>>>>>>>>>> ---
> >>>>>>>>>>>>  include/linux/skbuff.h |  3 ++-
> >>>>>>>>>>>>  include/net/ipv6.h     |  2 ++
> >>>>>>>>>>>>  net/ipv6/ip6_output.c  |  4 ++--
> >>>>>>>>>>>>  net/ipv6/output_core.c |  9 ++++++++-
> >>>>>>>>>>>>  net/ipv6/udp_offload.c | 10 +++++++++-
> >>>>>>>>>>>>  5 files changed, 23 insertions(+), 5 deletions(-)
> >>>>>>>>>>>>
> >>>>>>>>>>>> diff --git a/include/linux/skbuff.h b/include/linux/skbuff.h
> >>>>>>>>>>>> index 85ab7d7..3ad5203 100644
> >>>>>>>>>>>> --- a/include/linux/skbuff.h
> >>>>>>>>>>>> +++ b/include/linux/skbuff.h
> >>>>>>>>>>>> @@ -605,7 +605,8 @@ struct sk_buff {
> >>>>>>>>>>>>  	__u8			ipvs_property:1;
> >>>>>>>>>>>>  	__u8			inner_protocol_type:1;
> >>>>>>>>>>>>  	__u8			remcsum_offload:1;
> >>>>>>>>>>>> -	/* 3 or 5 bit hole */
> >>>>>>>>>>>> +	__u8			ufo_fragid_set:1;
> >>>>>>>>>>> [...]
> >>>>>>>>>>>
> >>>>>>>>>>> Doesn't the flag belong in struct skb_shared_info, rather than struct
> >>>>>>>>>>> sk_buff?  Otherwise this looks fine.
> >>>>>>>>>>>
> >>>>>>>>>>> Ben.
> >>>>>>>>>>
> >>>>>>>>>> Hmm we seem to be out of tx flags.
> >>>>>>>>>> Maybe ip6_frag_id == 0 should mean "not set".
> >>>>>>>>>
> >>>>>>>>> Maybe that is the best idea. Definitely the ufo_fragid_set bit should
> >>>>>>>>> move into the skb_shared_info area.
> >>>>>>>>
> >>>>>>>> That's what I originally wanted to do, but had to move and grow txflags thus
> >>>>>>>> skb_shinfo ended up growing.  I wanted to avoid that, so stole an skb flag.
> >>>>>>>>
> >>>>>>>> I considered treating fragid == 0 as unset, but a 0 fragid is perfectly valid
> >>>>>>>> from the protocol perspective and could actually be generated by the id generator
> >>>>>>>> functions.  This may cause us to call the id generation multiple times.
> >>>>>>>
> >>>>>>> Are there plans in the long run to let virtio_net transmit auxiliary
> >>>>>>> data to the other end so we can clean all of this this up one day?
> >>>>>>>
> >>>>>>> I don't like the whole situation: looking into the virtio_net headers
> >>>>>>> just adding a field for ipv6 fragmentation ids to those small structs
> >>>>>>> seems bloated, not doing it feels incorrect. :/
> >>>>>>>
> >>>>>>> Thoughts?
> >>>>>>>
> >>>>>>> Bye,
> >>>>>>> Hannes
> >>>>>>
> >>>>>> I'm not sure - what will be achieved by generating the IDs guest side as
> >>>>>> opposed to host side?  It's certainly harder to get hold of entropy
> >>>>>> guest-side.
> >>>>>
> >>>>> It is not only about entropy but about uniqueness.  Also fragmentation
> >>>>> ids should not be discoverable,
> >>>>
> >>>> I belive "predictable" is the language used by the IETF draft.
> >>>>
> >>>>> so there are several aspects:
> >>>>>
> >>>>> I see fragmentation id generation still as security critical:
> >>>>> When Eric patched the frag id generator in 04ca6973f7c1a0d ("ip: make IP
> >>>>> identifiers less predictable") I could patch my kernels and use the
> >>>>> patch regardless of the machine being virtualized or not. It was not
> >>>>> dependent on the hypervisor.
> >>>>
> >>>> And now it's even easier - just patch the hypervisor, and all VMs
> >>>> automatically benefit.
> >>>
> >>> Sometimes the hypervisor is not under my control. You would need to
> >>> patch both kernels in your case - non gso frames would still get the
> >>> fragmentation id generated in the host kernel.
> >>
> >> Why would non-gso frames need a frag id?  We are talking only UDP IPv6
> >> here, so there is no frag id generation if the packet does't need to
> >> be fragmented.
> > 
> > E.g. raw sockets still can generate fragments locally. It is also a
> > valid setup to have multiple interfaces in one machine, one that is UFO
> > enabled and one that isn't. In that case, fragmentation id generation
> > happens on different hosts which I want to avoid.
> 
> OK, so you are concerned about both host and guest generating fragment
> ids.  Host would do it for GSO frames and guest would do it for fragmented
> frames.  Yes, there is room for collision,

collision is not a problem. It is in fact unavoidable.

> which is why we are aiming to
> fix this with fragment id passing through virtio_net.  However, I am still
> trying to figure the best way to do this as it extends the virtio_net header
> and we want to do it right.
> 
> > 
> > I haven't looked closely but mismatch of MTUs on interfaces seems like
> > it could lead to unwanted fragmentation, e.g. see is_skb_forwardable
> > which is mostly always true for gso frames, so we never stop them on
> > bridges etc.
> 
> Yes,  this is one of the cases that gets triggered with VMs.
> 
> > 
> >>>>> I think that is the same reasoning why we
> >>>>> don't support TOE.
> >>>>> If we use one generator in the hypervisor in an openstack alike setting,
> >>>>> the host deals with quite a lot of overlay networks. A lot of default
> >>>>> configurations use the same addresses internally, so on the hypervisor
> >>>>> the frag id generators would interfere by design.
> >>>>> I could come up with an attack scenario for DNS servers (again :) ):
> >>>>>
> >>>>> You are sitting next to a DNS server on the same hypervisor and can send
> >>>>> packets without source validation (because that is handled later on in
> >>>>> case of openvswitch when the packet is put into the corresponding
> >>>>> overlay network). You emit a gso packet with the same source and
> >>>>> destination addresses as the DNS server would do and would get an
> >>>>> fragmentation id which is linearly (+ time delta) incremented depending
> >>>>> on the source and destination address. With such a leak you could start
> >>>>> trying attack and spoof DNS responses (fragmentation attacks etc.).
> >>>>> See also details on such kind of attacks in the description of commit
> >>>>> 04ca6973f7c1a0d.
> >>>>>
> >>>>> AFAIK IETF tried with IPv6 to push fragmentation id generation to the
> >>>>> end hosts, that's also the reason for the introduction of atomic
> >>>>> fragments (which are now being rolled back ;) ).
> >>>>>
> >>>>> Still it is better to generate a frag id on the hypervisor than just
> >>>>> sending a 0, so I am ok with this change, albeit not happy.
> >>>>>
> >>>>> Thanks,
> >>>>> Hannes
> >>>>>
> >>>>
> >>>> OK so to summarize, identifiers are only re-randomized once per jiffy,
> >>>> so you worry that within this window, an external observer can discover
> >>>> past fragment ID values and so predict the future ones.
> >>>> All that's required is that two paths go through the same box performing
> >>>> fragmentation.
> >>>>
> >>>> Is that a fair summary?
> >>>>
> >>>> If yes, we can make this a bit harder by mixing in some
> >>>> data per input and/or output devices.
> >>>>
> >>>> For example, just to give you the idea:
> >>>>
> >>>> diff --git a/net/core/dev.c b/net/core/dev.c
> >>>> index 683d493..4faa7ef 100644
> >>>> --- a/net/core/dev.c
> >>>> +++ b/net/core/dev.c
> >>>> @@ -3625,6 +3625,7 @@ static int __netif_receive_skb_core(struct sk_buff *skb, bool pfmemalloc)
> >>>>  	trace_netif_receive_skb(skb);
> >>>>  
> >>>>  	orig_dev = skb->dev;
> >>>> +	skb_shinfo(skb)->ip6_frag_id = skb->dev->ifindex;
> >>>>  
> >>>>  	skb_reset_network_header(skb);
> >>>>  	if (!skb_transport_header_was_set(skb))
> >>>> diff --git a/net/ipv6/ip6_output.c b/net/ipv6/ip6_output.c
> >>>> index ce69a12..819a821 100644
> >>>> --- a/net/ipv6/ip6_output.c
> >>>> +++ b/net/ipv6/ip6_output.c
> >>>> @@ -1092,7 +1092,8 @@ static inline int ip6_ufo_append_data(struct sock *sk,
> >>>>  				     sizeof(struct frag_hdr)) & ~7;
> >>>>  	skb_shinfo(skb)->gso_type = SKB_GSO_UDP;
> >>>>  	ipv6_select_ident(&fhdr, rt);
> >>>> -	skb_shinfo(skb)->ip6_frag_id = fhdr.identification;
> >>>> +	skb_shinfo(skb)->ip6_frag_id = jhash_1word(skb_shinfo(skb)->ip6_frag_id,
> >>>> +						   fhdr.identification);
> >>>>  
> >>>>  append:
> >>>>  	return skb_append_datato_frags(sk, skb, getfrag, from,
> >>>>
> >>>
> >>> I thought about mixing in the incoming interface identifier into the
> >>> frag id generation, but that could hurt us badly as soon as a VM has
> >>> more than one interface to the outside world and uses e.g. ECMP. We need
> >>> to make sure that those frag ids are unique and the kernel needs to be
> >>> better than just using a random number generator.
> >>>
> >>
> >> So the goal behind this series of patches is to restore VM functionality to
> >> pre-916e4cf46d0204 ("ipv6: reuse ip6_frag_id from ip6_ufo_append_data").
> > 
> > I understand (the patch fixed a NULL ptr deref btw.).
> > 
> > As I said, I don't want to stop this series (hopefully the flag can be
> > moved into skb_shared_info etc.), would look after that IMHO
> > (skb flags/IPCB and skb_shared_info have different semantics on
> > __skb_clone).
> > 
> > I think it is very much worth to try to move the fragmentation id
> > generation back to the end host and only use this as a fallback.
> 
> I think we are in agreement here.
> 
> -vlad
> > 
> > Bye,
> > Hannes
> > 
> > 
