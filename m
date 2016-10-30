From: Jakub Sitnicki <jkbs@redhat.com>
Subject: Re: [PATCH net-next 5/5] ipv6: Compute multipath hash for forwarded ICMP errors from offending packet
Date: Sun, 30 Oct 2016 14:03:11 +0100
Message-ID: <8760oa9egg.fsf@redhat.com>
References: <CALx6S35qmAwFfK1TNAcJJs1jK7JgM8U4MCh3wC8hkuf2qae+sw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Linux Kernel Network Developers <netdev@vger.kernel.org>,
        LKML <linux-kernel@vger.kernel.org>,
        "David S. Miller" <davem@davemloft.net>,
        Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>,
        James Morris <jmorris@namei.org>,
        Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>,
        Patrick McHardy <kaber@trash.net>
To: Tom Herbert <tom@herbertland.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-reply-to: <CALx6S35qmAwFfK1TNAcJJs1jK7JgM8U4MCh3wC8hkuf2qae+sw@mail.gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, Oct 28, 2016 at 02:25 PM GMT, Tom Herbert wrote:
> On Fri, Oct 28, 2016 at 1:32 AM, Jakub Sitnicki <jkbs@redhat.com> wrote:
>> On Thu, Oct 27, 2016 at 10:35 PM GMT, Tom Herbert wrote:
>>> On Mon, Oct 24, 2016 at 2:28 AM, Jakub Sitnicki <jkbs@redhat.com> wrote:
>>>> Same as for the transmit path, let's do our best to ensure that received
>>>> ICMP errors that may be subject to forwarding will be routed the same
>>>> path as flow that triggered the error, if it was going in the opposite
>>>> direction.
>>>>
>>> Unfortunately our ability to do this is generally quite limited. This
>>> patch will select the route for multipath, but I don't believe sets
>>> the same link in LAG and definitely can't help switches doing ECMP to
>>> route the ICMP packet in the same way as the flow would be. Did you
>>> see a problem that warrants solving this case?
>>
>> The motivation here is to bring IPv6 ECMP routing on par with IPv4 to
>> enable its wider use, targeting anycast services. Forwarding ICMP errors
>> back to the source host, at the L3 layer, is what we thought would be a
>> step forward.
>>
>> Similar to change in IPv4 routing introduced in commit 79a131592dbb
>> ("ipv4: ICMP packet inspection for multipath", [1]) we do our best at
>> L3, leaving any potential problems with LAG at lower layer (L2)
>> unaddressed.
>>
> ICMP will almost certainly take a different path in the network than
> TCP or UDP due to ECMP. If we ever get proper flow label support for
> ECMP then that could solve the problem if all the devices do a hash
> just on <srcIP, destIP, FlowLabel>.

Sorry for my late reply, I have been traveling.

I think that either I am missing something here, or the proposed changes
address just the problem that you have described.

Yes, if we compute the hash that drives the route choice over the IP
header of the ICMP error, then there is no guarantee it will travel back
to the sender of the offending packet that triggered the error.

That is why, we look at the offending packet carried by an ICMP error
and hash over its fields, instead. We need, however, to take care of two
things:

1) swap the source with the destination address, because we are
   forwarding the ICMP error in the opposite direction than the
   offending packet was going (see icmpv6_multipath_hash() introduced in
   patch 4/5); and

2) ensure the flow labels used in both directions are the same (either
   reflected by one side, or fixed, e.g. not used and set to 0), so that
   the 4-tuple we hash over when forwarding, <src addr, dst addr, flow
   label, next hdr>, is the same both ways, modulo the order of
   addresses.

> If this patch is being done to be compatible with IPv4 I guess that's
> okay, but it would be false advertisement to say this makes ICMP
> follow the same path as the flow being targeted in an error.
> Fortunately, I doubt anyone can have a dependency on this for ICMP.

I wouldn't want to propose anything that would be useless. If you think
that this is the case here, I would very much like to understand what
and why cannot work in practice.

Thanks for reviewing this series,
Jakub
