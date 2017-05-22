From: Jesper Dangaard Brouer <brouer@redhat.com>
Subject: Re: [RFC net-next PATCH 4/5] net: new XDP feature for reading HW
 rxhash from drivers
Date: Mon, 22 May 2017 08:39:35 +0200
Message-ID: <20170522083935.4d82174f@redhat.com>
References: <149512205297.14733.15729847433404265933.stgit@firesoul>
        <149512210827.14733.13997041998775151648.stgit@firesoul>
        <CALx6S35Y3j=S7GpJ8=Z8E2X+106ToOV_bMeNsKHqG5JFtiC4Ag@mail.gmail.com>
        <20170521180435.56dcd76b@redhat.com>
        <CALx6S34-4kQLQLkU9QRjyfZ808f_hXV4N+bh+XG8iu1BtQOUSA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Daniel Borkmann <borkmann@iogearbox.net>,
        Alexei Starovoitov <alexei.starovoitov@gmail.com>,
        Linux Kernel Network Developers <netdev@vger.kernel.org>,
        brouer@redhat.com
To: Tom Herbert <tom@herbertland.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:51150 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1752478AbdEVGjp (ORCPT <rfc822;netdev@vger.kernel.org>);
        Mon, 22 May 2017 02:39:45 -0400
In-Reply-To: <CALx6S34-4kQLQLkU9QRjyfZ808f_hXV4N+bh+XG8iu1BtQOUSA@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, 21 May 2017 15:10:29 -0700
Tom Herbert <tom@herbertland.com> wrote:

> On Sun, May 21, 2017 at 9:04 AM, Jesper Dangaard Brouer
> <brouer@redhat.com> wrote:
> > On Sat, 20 May 2017 09:16:09 -0700
> > Tom Herbert <tom@herbertland.com> wrote:
> >  
> >> > +/* XDP rxhash have an associated type, which is related to the RSS
> >> > + * (Receive Side Scaling) standard, but NIC HW have different mapping
> >> > + * and support. Thus, create mapping that is interesting for XDP.  XDP
> >> > + * would primarly want insight into L3 and L4 protocol info.
> >> > + *
> >> > + * TODO: Likely need to get extended with "L3_IPV6_EX" due RSS standard
> >> > + *
> >> > + * The HASH_TYPE will be returned from bpf helper as the top 32-bit of
> >> > + * the 64-bit rxhash (internally type stored in xdp_buff->flags).
> >> > + */
> >> > +#define XDP_HASH(x)            ((x) & ((1ULL << 32)-1))
> >> > +#define XDP_HASH_TYPE(x)       ((x) >> 32)
> >> > +
> >> > +#define XDP_HASH_TYPE_L3_SHIFT 0
> >> > +#define XDP_HASH_TYPE_L3_BITS  3
> >> > +#define XDP_HASH_TYPE_L3_MASK  ((1ULL << XDP_HASH_TYPE_L3_BITS)-1)
> >> > +#define XDP_HASH_TYPE_L3(x)    ((x) & XDP_HASH_TYPE_L3_MASK)
> >> > +enum {
> >> > +       XDP_HASH_TYPE_L3_IPV4 = 1,
> >> > +       XDP_HASH_TYPE_L3_IPV6,
> >> > +};
> >> > +
> >> > +#define XDP_HASH_TYPE_L4_SHIFT XDP_HASH_TYPE_L3_BITS
> >> > +#define XDP_HASH_TYPE_L4_BITS  5
> >> > +#define XDP_HASH_TYPE_L4_MASK                                          \
> >> > +       (((1ULL << XDP_HASH_TYPE_L4_BITS)-1) << XDP_HASH_TYPE_L4_SHIFT)
> >> > +#define XDP_HASH_TYPE_L4(x)    ((x) & XDP_HASH_TYPE_L4_MASK)
> >> > +enum {
> >> > +       _XDP_HASH_TYPE_L4_TCP = 1,
> >> > +       _XDP_HASH_TYPE_L4_UDP,
> >> > +};
> >> > +#define XDP_HASH_TYPE_L4_TCP (_XDP_HASH_TYPE_L4_TCP << XDP_HASH_TYPE_L4_SHIFT)
> >> > +#define XDP_HASH_TYPE_L4_UDP (_XDP_HASH_TYPE_L4_UDP << XDP_HASH_TYPE_L4_SHIFT)
> >> > +  
> >> Hi Jesper,
> >>
> >> Why do we need these indicators for protocol specific hash? It seems
> >> like L4 and L3 is useful differentiation and protocol agnostic (I'm
> >> still holding out hope that SCTP will be deployed some day ;-) )  
> >
> > I'm not sure I understood the question fully, but let me try to answer
> > anyway.  To me it seems obvious that you would want to know the
> > protocol/L4 type, as this helps avoid hash collisions between UDP and
> > TCP flows.  I can easily imagine someone constructing an UDP packet
> > that could hash collide with a given TCP flow.
> >
> > And yes, i40 support matching SCTP, and we will create a
> > XDP_HASH_TYPE_L4_SCTP when adding XDP rxhash support for that driver.
> >  
> But where would this information be used? We don't save it in skbuff,
> don't use it in RPS, RFS. RSS doesn't use it for packet steering so
> the hash collision problem already exists at the device level. If
> there is a collision problem between two protocols then maybe hash
> should be over 5-tuple instead...

One use-case (I heard at a customer) was that they had (web-)servers
that didn't serve any UDP traffic, thus they simply block/drop all
incoming UDP on the service NIC (as an ACL in the switch). (The servers
own DNS lookups and NTP goes through the management NIC to internal
DNS/NTP servers).

Another use-case: Inside an XDP/bpf program is can be used for
splitting protocol processing, into different tail calls, before even
touching packet-data.  I can imagine the bpf TCP handling code is
larger, thus an optimization is to have a separate tail call for the
UDP protocol handling.  One could also transfer/queue all TCP traffic
to other CPU(s) like RPS, just without touching packet memory.


This info is saved in the skb, but due to space constrains, it is
reduced to a single bit, namely skb->l4_hash, iif some
RSS-proto/XDP_HASH_TYPE_L4_* bit was set.  And the network stack do use
and react on this.

-- 
Best regards,
  Jesper Dangaard Brouer
  MSc.CS, Principal Kernel Engineer at Red Hat
  LinkedIn: http://www.linkedin.com/in/brouer
