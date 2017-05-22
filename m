From: Tom Herbert <tom@herbertland.com>
Subject: Re: [RFC net-next PATCH 4/5] net: new XDP feature for reading HW
 rxhash from drivers
Date: Mon, 22 May 2017 14:32:04 -0700
Message-ID: <CALx6S34xYbRgo81OhEKr_Zob5kFnoXyFQ3p_JdPVk89z77u4Fw@mail.gmail.com>
References: <149512205297.14733.15729847433404265933.stgit@firesoul>
 <149512210827.14733.13997041998775151648.stgit@firesoul> <CALx6S35Y3j=S7GpJ8=Z8E2X+106ToOV_bMeNsKHqG5JFtiC4Ag@mail.gmail.com>
 <20170521180435.56dcd76b@redhat.com> <CALx6S34-4kQLQLkU9QRjyfZ808f_hXV4N+bh+XG8iu1BtQOUSA@mail.gmail.com>
 <20170522083935.4d82174f@redhat.com> <20170522224229.540ce059@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Cc: Daniel Borkmann <borkmann@iogearbox.net>,
        Alexei Starovoitov <alexei.starovoitov@gmail.com>,
        Linux Kernel Network Developers <netdev@vger.kernel.org>
To: Jesper Dangaard Brouer <brouer@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qt0-f175.google.com ([209.85.216.175]:35146 "EHLO
        mail-qt0-f175.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S933607AbdEVVcG (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 22 May 2017 17:32:06 -0400
Received: by mail-qt0-f175.google.com with SMTP id v27so112831341qtg.2
        for <netdev@vger.kernel.org>; Mon, 22 May 2017 14:32:06 -0700 (PDT)
In-Reply-To: <20170522224229.540ce059@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, May 22, 2017 at 1:42 PM, Jesper Dangaard Brouer
<brouer@redhat.com> wrote:
> On Mon, 22 May 2017 08:39:35 +0200
> Jesper Dangaard Brouer <brouer@redhat.com> wrote:
>
>> On Sun, 21 May 2017 15:10:29 -0700
>> Tom Herbert <tom@herbertland.com> wrote:
>>
>> > On Sun, May 21, 2017 at 9:04 AM, Jesper Dangaard Brouer
>> > <brouer@redhat.com> wrote:
>> > > On Sat, 20 May 2017 09:16:09 -0700
>> > > Tom Herbert <tom@herbertland.com> wrote:
>> > >
>> > >> > +/* XDP rxhash have an associated type, which is related to the RSS
>> > >> > + * (Receive Side Scaling) standard, but NIC HW have different mapping
>> > >> > + * and support. Thus, create mapping that is interesting for XDP.  XDP
>> > >> > + * would primarly want insight into L3 and L4 protocol info.
>> > >> > + *
>> > >> > + * TODO: Likely need to get extended with "L3_IPV6_EX" due RSS standard
>> > >> > + *
>> > >> > + * The HASH_TYPE will be returned from bpf helper as the top 32-bit of
>> > >> > + * the 64-bit rxhash (internally type stored in xdp_buff->flags).
>> > >> > + */
>> > >> > +#define XDP_HASH(x)            ((x) & ((1ULL << 32)-1))
>> > >> > +#define XDP_HASH_TYPE(x)       ((x) >> 32)
>> > >> > +
>> > >> > +#define XDP_HASH_TYPE_L3_SHIFT 0
>> > >> > +#define XDP_HASH_TYPE_L3_BITS  3
>> > >> > +#define XDP_HASH_TYPE_L3_MASK  ((1ULL << XDP_HASH_TYPE_L3_BITS)-1)
>> > >> > +#define XDP_HASH_TYPE_L3(x)    ((x) & XDP_HASH_TYPE_L3_MASK)
>> > >> > +enum {
>> > >> > +       XDP_HASH_TYPE_L3_IPV4 = 1,
>> > >> > +       XDP_HASH_TYPE_L3_IPV6,
>> > >> > +};
>> > >> > +
>> > >> > +#define XDP_HASH_TYPE_L4_SHIFT XDP_HASH_TYPE_L3_BITS
>> > >> > +#define XDP_HASH_TYPE_L4_BITS  5
>> > >> > +#define XDP_HASH_TYPE_L4_MASK                                          \
>> > >> > +       (((1ULL << XDP_HASH_TYPE_L4_BITS)-1) << XDP_HASH_TYPE_L4_SHIFT)
>> > >> > +#define XDP_HASH_TYPE_L4(x)    ((x) & XDP_HASH_TYPE_L4_MASK)
>> > >> > +enum {
>> > >> > +       _XDP_HASH_TYPE_L4_TCP = 1,
>> > >> > +       _XDP_HASH_TYPE_L4_UDP,
>> > >> > +};
>> > >> > +#define XDP_HASH_TYPE_L4_TCP (_XDP_HASH_TYPE_L4_TCP << XDP_HASH_TYPE_L4_SHIFT)
>> > >> > +#define XDP_HASH_TYPE_L4_UDP (_XDP_HASH_TYPE_L4_UDP << XDP_HASH_TYPE_L4_SHIFT)
>> > >> > +
>> > >> Hi Jesper,
>> > >>
>> > >> Why do we need these indicators for protocol specific hash? It seems
>> > >> like L4 and L3 is useful differentiation and protocol agnostic (I'm
>> > >> still holding out hope that SCTP will be deployed some day ;-) )
>> > >
>> > > I'm not sure I understood the question fully, but let me try to answer
>> > > anyway.  To me it seems obvious that you would want to know the
>> > > protocol/L4 type, as this helps avoid hash collisions between UDP and
>> > > TCP flows.  I can easily imagine someone constructing an UDP packet
>> > > that could hash collide with a given TCP flow.
>> > >
>> > > And yes, i40 support matching SCTP, and we will create a
>> > > XDP_HASH_TYPE_L4_SCTP when adding XDP rxhash support for that driver.
>> > >
>> > But where would this information be used? We don't save it in skbuff,
>> > don't use it in RPS, RFS. RSS doesn't use it for packet steering so
>> > the hash collision problem already exists at the device level. If
>> > there is a collision problem between two protocols then maybe hash
>> > should be over 5-tuple instead...
>>
>> One use-case (I heard at a customer) was that they had (web-)servers
>> that didn't serve any UDP traffic, thus they simply block/drop all
>> incoming UDP on the service NIC (as an ACL in the switch). (The servers
>> own DNS lookups and NTP goes through the management NIC to internal
>> DNS/NTP servers).
>>
>> Another use-case: Inside an XDP/bpf program is can be used for
>> splitting protocol processing, into different tail calls, before even
>> touching packet-data.  I can imagine the bpf TCP handling code is
>> larger, thus an optimization is to have a separate tail call for the
>> UDP protocol handling.  One could also transfer/queue all TCP traffic
>> to other CPU(s) like RPS, just without touching packet memory.
>>
>>
>> This info is saved in the skb, but due to space constrains, it is
>> reduced to a single bit, namely skb->l4_hash, iif some
>> RSS-proto/XDP_HASH_TYPE_L4_* bit was set.  And the network stack do use
>> and react on this.
>
> I also want to mention another real-customer use-case.  Some
> deployments have a VXLAN based networks, but some NICs cannot
> understand VXLAN do cannot do proper RSS rx-hashing, which resulted in
> bad CPU scaling as all VXLAN packets gets delivered to the same CPU.
>
They need to turn on RSS for UDP I think.

> Thus, I would like to implement recalculation of the RXHASH in XDP, as
> that would save me implementing yet another extension to the flow
> dissector, that the kernel would have to carry forever, while this is
> just a matter of NIC hashing getting improved.
>
> With the extra L3 and L4 info, I'm assuming that XDP_HASH_TYPE_L3(x)
> and XDP_HASH_TYPE_L4(x) will be zero for VXLAN as the NIC cannot
> identify this.  Thus, I can at an early stage know which packets needs
> to get a new rxhash.
>
> I've seen a similar problem with Q-in-Q double tagged VLANs, failing
> the RSS-hash distribution the same way...
>
That's fine, but I'm still not seeing that differentiating the hash
created from different protocols is really helps. The most correct way
moving forward to generate a flow hash is use IPv6 flow label. This
eliminates either the device or software from needing to do DPI into
protocols, over extension headers, etc. In this case though we declare
a hash based on flow label as L4, but have no idea and really don't
care what protocol it's for (and in fact for something like IPsec we
can't even know).

The idea that the world is composed of just TCP and UDP is a delusion
espoused by NIC implementations, in SW we can and should do better
than that with protocol agnostic mechanisms.

Tom

> I hope that explains what this can be use for(?)
>
> --
> Best regards,
>   Jesper Dangaard Brouer
>   MSc.CS, Principal Kernel Engineer at Red Hat
>   LinkedIn: http://www.linkedin.com/in/brouer
