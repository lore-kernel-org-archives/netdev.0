From: Jesse Gross <jesse@nicira.com>
Subject: Re: [PATCH net-next 1/2] net: More fine-grained support for
 encapsulated GSO features
Date: Tue, 30 Apr 2013 09:19:51 -0700
Message-ID: <CAEP_g=-9abqxGyox7s4jjzTdPFTXmnLU6gkq+ihGwXJg-NAdaA@mail.gmail.com>
References: <1366683556-4956-1-git-send-email-horms@verge.net.au>
 <1366683556-4956-2-git-send-email-horms@verge.net.au> <alpine.LFD.2.02.1304231354440.5598@morpheus.jf.intel.com>
 <20130425073644.GC7936@verge.net.au> <CAEP_g=_xZOjn6ByhM3sKw-f2Ui9kjnb1wUJ2EGBBg3GD5JnmLw@mail.gmail.com>
 <20130430032121.GC26726@verge.net.au>
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
Received: from na3sys009aog121.obsmtp.com ([74.125.149.145]:37779 "HELO
	na3sys009aog121.obsmtp.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with SMTP id S1760893Ab3D3QUM (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 30 Apr 2013 12:20:12 -0400
Received: by mail-oa0-f71.google.com with SMTP id o17so3910035oag.10
        for <netdev@vger.kernel.org>; Tue, 30 Apr 2013 09:20:11 -0700 (PDT)
In-Reply-To: <20130430032121.GC26726@verge.net.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Apr 29, 2013 at 8:21 PM, Simon Horman <horms@verge.net.au> wrote:
> On Fri, Apr 26, 2013 at 04:03:21PM -0700, Jesse Gross wrote:
>> On Thu, Apr 25, 2013 at 12:36 AM, Simon Horman <horms@verge.net.au> wrote:
>> > On Tue, Apr 23, 2013 at 02:00:19PM -0700, Joseph Gasparakis wrote:
>> >> Any particular reason to introduce skb->encapsulation_features instead of
>> >> using the existing skb->encapsulation? Also I don't see it used in your
>> >> second patch either.
>> >
>> > My reasoning is that skb->encapsulation seems to alter the behaviour of
>> > many different locations and I'm not sure that any of them, other than the
>> > one in dev_hard_start_xmit() make sense for MPLS.
>>
>> The problem is the meaning of skb->encapsulation isn't really defined
>> clearly and I'm certain that the current implementation is not going
>> to work in the future. Depending on your perspective, vlans, MPLS,
>> tunnels, etc. can all be considered forms of encapsulation but clearly
>> there are many NICs that have different capabilities across those. I
>> believe the intention here was really to describe L3 tunnels as
>> encapsulation, in which case MPLS really shouldn't be using this
>> mechanism at all.
>>
>> Now there is some overlap, especially today since most currently
>> shipping silicon wasn't designed to support tunnels and so is using
>> some form of offset based offloads. In that case, all forms of
>> encapsulation are pretty similar. However, in the future that won't be
>> the case as support for specific protocols is implemented for higher
>> performance and richer support. When that happens, not only will MPLS
>> and tunnels have different capabilities but various forms tunnels
>> might as well.
>
> Wouldn't be possible to describe those differences using,
> dev->hw_enc_features? I assumed that was its purpose.

If there truly are differences between the offload capabilities of
MPLS and L3 tunnels then no, it's not possible, because it's a single
field. It's certainly not a valid assumption that a NIC that can do
TSO over GRE can also do it over MPLS.

However, it's unlikely that there are truly significant differences
between various encapsulation formats on a per-feature basis. I think
what we need to do is separate out the ability to understand the
headers from the capabilities so you have two fields: header (none,
VLAN, QinQ, MPLS, VXLAN, GRE, etc.) and feature (checksum, SG, TSO,
etc.) rather than the product of each. Otherwise, we end up with a ton
of different combinations.
