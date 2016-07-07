From: Alexander Duyck <alexander.duyck@gmail.com>
Subject: Re: Resurrecting due to huge ipoib perf regression - [BUG] skb
 corruption and kernel panic at forwarding with fragmentation
Date: Thu, 7 Jul 2016 11:13:01 -0700
Message-ID: <CAKgT0UerNfn9Uas34y6_+Fa4ALCcToQvNdbEkH1erVosa=xvXg@mail.gmail.com>
References: <CAL1RGDV3u4bzuyGkMZGJQOiXje_qVh7AA-2nJMm2J2TR60H72g@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Konstantin Khlebnikov <koct9i@gmail.com>,
	"linux-rdma@vger.kernel.org" <linux-rdma@vger.kernel.org>,
	Florian Westphal <fw@strlen.de>,
	Thadeu Lima de Souza Cascardo <cascardo@redhat.com>,
	Cong Wang <xiyou.wangcong@gmail.com>,
	Linux Kernel Network Developers <netdev@vger.kernel.org>,
	David Miller <davem@davemloft.net>,
	Eric Dumazet <edumazet@google.com>,
	Linux Kernel Mailing List <linux-kernel@vger.kernel.org>
To: Roland Dreier <roland@purestorage.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-io0-f174.google.com ([209.85.223.174]:36106 "EHLO
	mail-io0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753124AbcGGSnu (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 7 Jul 2016 14:43:50 -0400
In-Reply-To: <CAL1RGDV3u4bzuyGkMZGJQOiXje_qVh7AA-2nJMm2J2TR60H72g@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Jul 6, 2016 at 11:25 PM, Roland Dreier <roland@purestorage.com> wrote:
> On Thu, Jan 7, 2016 at 3:00 AM, Konstantin Khlebnikov <koct9i@gmail.com> wrote:
>> Or just shift GSO CB and add couple checks like
>> BUILD_BUG_ON(sizeof(SKB_GSO_CB(skb)->room) < sizeof(*IPCB(skb)));
>
> Resurrecting this old thread, because the patch that ultimately went
> upstream (commit 9207f9d45b0a / net: preserve IP control block during
> GSO segmentation) causes a huge IPoIB performance regression (to the
> point of being unusable):
> https://bugzilla.kernel.org/show_bug.cgi?id=111921
>
> I don't think anyone has explained what goes wrong or why IPoIB works
> the way it does.  The underlying difference that IPoIB has from other
> drivers is that there are two levels of address resolution.  First,
> normal ARP / ND resolves an IP address to a "hardware" address.  The
> difference is that in IPoIB, the hardware address is an IB GID (plus a
> QPN, but we can ignore that).  To actually send data to that GID, the
> IPoIB driver has to do a second lookup - it needs to ask the IB subnet
> manager for a path record that tells it how to reach that GID.
>
> In particular this means that "destination address" (as the IP / ARP
> layer understands it) actually isn't in the packet anywhere - there's
> nothing like an ethernet header as there is for "normal" network
> drivers.  Instead, the driver stashes the address in skb->cb during
> hard_header_ops->create() and then looks at it in the xmit routine -
> this was designed way back around when commit a0417fa3a18a / net: Make
> qdisc_skb_cb upper size bound explicit. was merged.  The expectation
> was that the part of the cb after sizeof (struct qdisc_skb_cb) would
> be preserved.
>
> The problem with commit 9207f9d45b0a is that GSO operations now access
> cb after SKB_SGO_CB_OFFSET==32, which lands right in the middle of
> where IPoIB stashes its hwaddr.

Really I don't know if the problem is GSO so much as the desire to
maintain the control buffer between layers.  Really this kind of
violates how we have documented the control buffer in skbuff.h.

> It seems that the intent of the commit is to preserve the IP control
> block - struct inet_skb_parm (and presumably struct inet6_skb_parm) -
> even when using SKB_GSO_CB().  Seems like both inet_skb_parm and
> inet6_skb_parm are 20 bytes.  IPoIB uses the part of cb after 28
> bytes, so if we could squeeze struct skb_gso_cb down to 8 bytes and
> set SKB_SGO_CB_OFFSET to 20, then everything would work.  The struct
> is
>
> struct skb_gso_cb {
>         int     mac_offset;
>         int     encap_level;
>         __u16   csum_start;
> };

This is based on an out-dated version of this struct.  The 4.7 RC
kernel has a few more fields that were added to support local checksum
offload for encapsulated frames.

> is it feasible to make encap_level a __u16 (which would make the
> overall struct exactly 8 bytes)?  If I understand this correctly, 64K
> nested encapsulations seems like quite a bit for a packet...

The smallest we could probably get this structure at this point would
be around 10 bytes assuming we could make the offsets and encap level
only be a 16 bit field.  The added size is due to a wsum that was
added to keep a running checksum so we could keep csum_offset and
csum_start fields while generating a running checksum for the frame in
GSO.

> Or, earlier in this thread, having the GSO in ip_output and other gso
> paths save and restore the IP/IP6 control block was suggested as an
> alternate approach.  I don't know if there are performance
> implications to that.

Copying a block of data back and forth will always come at a cost.  In
addition, I don't see why we need to be moving the IP/IP6 control
block around.  If the IPoIB hwaddr is the only concern why couldn't it
be saved/restored instead?

> What is the best way to keep the crash fix but not kill IPoIB performance?

It seems like what would probably need to happen is to move where the
IPoIB address is stored.  I'm not sure the control buffer is really
the best place for it since the cb gets overwritten at various levels,
and storing 20 bytes makes it hard to avoid bumping up against the
size restrictions of the buffer.  Seeing as how the IPoIB hwaddr is
generated around the same time we generate the L2 header for the
frame, I wonder if you couldn't get away with using a bit of extra skb
headroom to store it and then use a offset from the MAC header to
access it.  An added bonus would be that with a few tricks with
SKB_GSO_CB(skb)->mac_offset you might even be able to set things up so
that you copy the hwaddr when you copy the header for each fragment
instead of having to go and copy the hwaddr out of the cb and clone it
for each frame.

Anyway I don't have that strong an understanding on IPoIB, but thought
I would add my $.02 since I noticed you were referencing an outdated
skb_gso_cb structure.

- Alex
