From: Jesse Gross <jesse@nicira.com>
Subject: Re: [PATCH net-next 1/2] net: More fine-grained support for
 encapsulated GSO features
Date: Thu, 2 May 2013 09:53:25 -0700
Message-ID: <CAEP_g=_0cOnE1Bhm5PGPhPTBvBEjoN_+oS-zUeNBM4ZyoJe-yg@mail.gmail.com>
References: <1366683556-4956-2-git-send-email-horms@verge.net.au>
 <alpine.LFD.2.02.1304231354440.5598@morpheus.jf.intel.com>
 <20130425073644.GC7936@verge.net.au> <CAEP_g=_xZOjn6ByhM3sKw-f2Ui9kjnb1wUJ2EGBBg3GD5JnmLw@mail.gmail.com>
 <20130430032121.GC26726@verge.net.au> <CAEP_g=-9abqxGyox7s4jjzTdPFTXmnLU6gkq+ihGwXJg-NAdaA@mail.gmail.com>
 <20130501075029.GD27158@verge.net.au> <CAEP_g=8_W4Y7zEG2ANjSV91wC8-b+i5XcY-RDa6_w7nvuuHyUA@mail.gmail.com>
 <20130501225706.GC6517@verge.net.au> <CAEP_g=9jRXMZgm9DB=oz+-08d3dPCptB+VY86n2qtq0RhTooKg@mail.gmail.com>
 <20130502053144.GA19430@verge.net.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Joseph Gasparakis <joseph.gasparakis@intel.com>,
	"dev@openvswitch.org" <dev@openvswitch.org>,
	netdev <netdev@vger.kernel.org>,
	Jarno Rajahalme <jarno.rajahalme@nsn.com>,
	Peter P Waskiewicz Jr <peter.p.waskiewicz.jr@intel.com>,
	Alexander Duyck <alexander.h.duyck@intel.com>,
	Eric Dumazet <eric.dumazet@gmail.com>,
	=?UTF-8?Q?Maciej_=C5=BBenczykowski?= <maze@google.com>
To: Simon Horman <horms@verge.net.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from na3sys009aog111.obsmtp.com ([74.125.149.205]:34559 "HELO
	na3sys009aog111.obsmtp.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with SMTP id S1758913Ab3EBQx5 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 2 May 2013 12:53:57 -0400
Received: by mail-ia0-f199.google.com with SMTP id t4so2921427iag.10
        for <netdev@vger.kernel.org>; Thu, 02 May 2013 09:53:47 -0700 (PDT)
In-Reply-To: <20130502053144.GA19430@verge.net.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, May 1, 2013 at 10:31 PM, Simon Horman <horms@verge.net.au> wrote:
> On Wed, May 01, 2013 at 09:53:42PM -0700, Jesse Gross wrote:
>> On Wed, May 1, 2013 at 3:57 PM, Simon Horman <horms@verge.net.au> wrote:
>> > On Wed, May 01, 2013 at 11:16:40AM -0700, Jesse Gross wrote:
>> >> On Wed, May 1, 2013 at 12:50 AM, Simon Horman <horms@verge.net.au> wrote:
>> >> > On Tue, Apr 30, 2013 at 09:19:51AM -0700, Jesse Gross wrote:
>> >> >> On Mon, Apr 29, 2013 at 8:21 PM, Simon Horman <horms@verge.net.au> wrote:
>> >> >> > On Fri, Apr 26, 2013 at 04:03:21PM -0700, Jesse Gross wrote:
>> >> >> >> On Thu, Apr 25, 2013 at 12:36 AM, Simon Horman <horms@verge.net.au> wrote:
>> >> >> >> > On Tue, Apr 23, 2013 at 02:00:19PM -0700, Joseph Gasparakis wrote:
>> >> >> >> >> Any particular reason to introduce skb->encapsulation_features instead of
>> >> >> >> >> using the existing skb->encapsulation? Also I don't see it used in your
>> >> >> >> >> second patch either.
>> >> >> >> >
>> >> >> >> > My reasoning is that skb->encapsulation seems to alter the behaviour of
>> >> >> >> > many different locations and I'm not sure that any of them, other than the
>> >> >> >> > one in dev_hard_start_xmit() make sense for MPLS.
>> >> >> >>
>> >> >> >> The problem is the meaning of skb->encapsulation isn't really defined
>> >> >> >> clearly and I'm certain that the current implementation is not going
>> >> >> >> to work in the future. Depending on your perspective, vlans, MPLS,
>> >> >> >> tunnels, etc. can all be considered forms of encapsulation but clearly
>> >> >> >> there are many NICs that have different capabilities across those. I
>> >> >> >> believe the intention here was really to describe L3 tunnels as
>> >> >> >> encapsulation, in which case MPLS really shouldn't be using this
>> >> >> >> mechanism at all.
>> >> >> >>
>> >> >> >> Now there is some overlap, especially today since most currently
>> >> >> >> shipping silicon wasn't designed to support tunnels and so is using
>> >> >> >> some form of offset based offloads. In that case, all forms of
>> >> >> >> encapsulation are pretty similar. However, in the future that won't be
>> >> >> >> the case as support for specific protocols is implemented for higher
>> >> >> >> performance and richer support. When that happens, not only will MPLS
>> >> >> >> and tunnels have different capabilities but various forms tunnels
>> >> >> >> might as well.
>> >> >> >
>> >> >> > Wouldn't be possible to describe those differences using,
>> >> >> > dev->hw_enc_features? I assumed that was its purpose.
>> >> >>
>> >> >> If there truly are differences between the offload capabilities of
>> >> >> MPLS and L3 tunnels then no, it's not possible, because it's a single
>> >> >> field. It's certainly not a valid assumption that a NIC that can do
>> >> >> TSO over GRE can also do it over MPLS.
>> >> >>
>> >> >> However, it's unlikely that there are truly significant differences
>> >> >> between various encapsulation formats on a per-feature basis. I think
>> >> >> what we need to do is separate out the ability to understand the
>> >> >> headers from the capabilities so you have two fields: header (none,
>> >> >> VLAN, QinQ, MPLS, VXLAN, GRE, etc.) and feature (checksum, SG, TSO,
>> >> >> etc.) rather than the product of each. Otherwise, we end up with a ton
>> >> >> of different combinations.
>> >> >
>> >> > I'm not quite sure that I follow.
>> >> >
>> >> > Is your idea to replace skb->encapsulation (a single bit) with
>> >> > a field that corresponds to the outer-most (encapsulation) header in use
>> >> > and has bits for none, VLAN, QinQ, MPLS, VXLAN, GRE, etc...?
>> >>
>> >> No, I'm talking about netdev features. You can already tell the
>> >> encapsulation type of a packet by looking at the EtherType.
>> >
>> > Now I am completely confused about what are the two fields that you
>> > refer to in your previous email.
>>
>> I have always been referring to the netdev features for various
>> protocol types. This is because considering MPLS as a form of
>> encapsulation for the purpose of offloads buckets too many protocols
>> into the same set and NICs will have varying features for those.
>> Trying to avoid this by having a bit for offloadable encapsulations is
>> just going to be very confusing and not very future proof.
>>
>> > In regards to looking ath the ethernet type:
>> >
>> > One of the tricky parts of MPLS is that the packet itself does not contain
>> > the ethernet type or any other way of knowing the type of the inner-packet.
>> > Information that is needed for GSO.
>>
>> I'm aware of that. However, you were referring to the type of
>> encapsulation. It is easy to determine that a packet is MPLS.
>>
>> > My proposal to get around this is to leave skb->protocol as the
>> > original, in the case we are interested in non-MPLS, ethernet type.
>>
>> At the very least, this is not consistent with how it is currently
>> handled (for example, with VLANs) and seems difficult to do properly.
>> However, I have not seen any further analysis since the last time that
>> we discussed this.
>
> Unfortunately my efforts to solicit feedback from others regarding
> that have not been successful.

Give me a break, Simon. These are your patches and therefore it is
your responsibility to do the analysis. This has come up over and over
again and I'm not happy about it.

Rather than trying to respond to me as quickly as possible, you need
to slow down, take a step back, and think about the correct direction.
Given that some of these patches have revision numbers in the 20s you
have nothing to complain about as far as receiving help.

In order to assist you in this, I'm going to drop all of your pending
patches from my queue and not respond to anything further from you
until the merge window is open again.
