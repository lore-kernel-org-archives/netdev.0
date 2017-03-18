From: Tom Herbert <tom@herbertland.com>
Subject: Re: [PATCH RFC net-next v2 1/4] skbuff: add stub to help computing
 crc32c on SCTP packets
Date: Sat, 18 Mar 2017 15:35:54 -0700
Message-ID: <CALx6S34cSH+z+humkp5s7UHAqnafHHB-GTqobHyb-SfKNe+MiA@mail.gmail.com>
References: <1488202783.2713.67.camel@redhat.com> <56fcd0848eae2b0693797e09500892659323546c.1488199633.git.dcaratti@redhat.com>
 <CAKgT0Udbs_=vanS+oF8ePXTNjEfsq9y==bhtQ-5Cxb-g+iO4bg@mail.gmail.com>
 <1488837077.3068.13.camel@redhat.com> <CAKgT0Uf6i+TmMyywgT7-X=n+P+a4_U1Z+Qrts7v1=v79MPsS+w@mail.gmail.com>
 <1489843045.2456.2.camel@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Alexander Duyck <alexander.duyck@gmail.com>,
        David Laight <David.Laight@aculab.com>,
        "David S . Miller" <davem@davemloft.net>,
        Linux Kernel Network Developers <netdev@vger.kernel.org>,
        "linux-sctp @ vger . kernel . org" <linux-sctp@vger.kernel.org>,
        Marcelo Ricardo Leitner <marcelo.leitner@gmail.com>
To: Davide Caratti <dcaratti@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qk0-f180.google.com ([209.85.220.180]:33781 "EHLO
        mail-qk0-f180.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751222AbdCRWnp (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sat, 18 Mar 2017 18:43:45 -0400
Received: by mail-qk0-f180.google.com with SMTP id y76so88025655qkb.0
        for <netdev@vger.kernel.org>; Sat, 18 Mar 2017 15:43:45 -0700 (PDT)
In-Reply-To: <1489843045.2456.2.camel@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, Mar 18, 2017 at 6:17 AM, Davide Caratti <dcaratti@redhat.com> wrote:
> hello Alexander and Tom,
>
> On Tue, 2017-03-07 at 10:06 -0800, Alexander Duyck wrote:
>>
>> You might even take this one step
>> further.  You could convert crc32_csum into a 1 bit enum for now.
>> Basically you would use 0 for 1's compliement csum, and 1 to represent
>> a crc32c csum.  Then if we end up having to add another bit for
>> something like FCoE in the future it would give us 4 possible checksum
>> types instead of just giving us 1 with a bit mask.
> <...>
>> I would say if you can't use an extra bit to indicate the checksum type
>> you probably don't have too much other choice.
>
> Unluckily, there are no free bits in struct sk_buff (i.e. there is 1 + 8
> bits after skb->xmit_more, but its content would be be lost after
> __copy_skb_header() _ so simply we can't use them).
> As soon as two bits in sk_buff are freed, we will be able to rely on the
> skb metadata, instead of inspecting the packet headers, to understand
> what algorithm is used to ensure data integrity in the packet.
>
>> As far as the patch you provided I would say it is a good start, but
>> was a bit to aggressive in a few spots.  For now we don't have support
>> for offloading crc32c when encapsulating a frame so you don't need to
>> worry about that too much for now.
>
> Ok _ so, skb_csum_hwoffload_help(skb, features) will assume that skb needs
> crc32c if all the following conditions are met:
> - feature bitmask does not have NETIF_F_SCTP_CRC bit set
> - skb->csum_offset is equal to 8 (i.e. offsetof(struct sctphdr,checksum)).
> - skb is carrying an (outer, non encapsulated) IPv4/IPv6 header with
> protocol number equal to 132 (i.e. IPPROTO_SCTP)
>
That's too complicated. Just create a non_ip_csum bit in skbuff.
csum_bad can replaced with this I think. If the bit is set then more
work can be done to differentiate between alternative checksums.

Tom

> In any other case, we will compute the internet checksum or do nothing _
> just what it's happening right now for non-GSO packets reaching
> validate_xmit_skb(). I think this implementation can be extended to the
> FCoE case if needed.
>
>> Also as far as the features test
>> you should only need to find that one of the feature bits is set in
>> the list you were testing.  What might make sense would be to look
>> into updating can_checksum_protocol to possibly factor in csum_offset
>> when determining if we can offload it or not.
>
> Looking again at the code, I noticed that the number of test on 'features'
> bits can be reduced: see below.
>
> can_checksum_protocol() takes an ethertype as parameter, so we would need
> to invent a non-standardized valure for SCTP. Moreover, it is used in
> skb_segment() for GSO: so, adding extra CPU cycles would affect
> performance on a path where the kernel is already showing the right
> behavior (GSO SCTP packets have their CRC32 computed correctly when
> sctp_gso_segment() is called).
>
>
> hello Tom,
>> > On Tue, 2017-02-28 at 11:50 -0800, Tom Herbert wrote:
>> > >
>> > > Return value looks complex. Maybe we should just change
>> > > skb_csum_*_help to return bool, true of checksum was handled false if
>> > > not.
>> >
>> > These functions can return -EINVAL if skb is a GSO packet, or -ENOMEM if
>> > skb_linearize(skb) or pskb_expand_head(skb) fail, or 0. I would preserve the
>> > return value of skb_checksum_help() and provide similar range of return values
>> > for skb_sctp_csum_help() (also known as skb_crc32c_csum_help()): this can
>> > help eventual future attempts to remove skb_warn_bad_offload(). It makes
>> > sense to make boolean the return value of skb_csum_hwoffload_help(),
>> > since we are using it only for non-GSO packets.
>
> the above statement is still valid after the body of the function changed. A
> very small thing: according to the kernel coding style, I should find a
> 'predicative' name for this function. Something like
>
> skb_can_resolve_partial_csum(),
>
> (which is terrible, I know)
>
> or similar / better.
>
> Please let me know if you think the code below is ok for you.
> Thank you in advance!
>
> regards,
>
> --
> davide
>
>
> --- a/net/core/dev.c
> +++ b/net/core/dev.c
> @@ -2987,6 +2987,38 @@ static struct sk_buff *validate_xmit_vlan(struct sk_buff *skb,
>         return skb;
>  }
>
> +static bool skb_csum_hwoffload_help(struct sk_buff *skb,
> +                                   netdev_features_t features)
> +{
> +       bool crc32c_csum_hwoff = !!(features & NETIF_F_SCTP_CRC);
> +       bool inet_csum_hwoff = !!(features & NETIF_F_CSUM_MASK);
> +       unsigned int offset = 0;
> +
> +       if (crc32c_csum_hwoff && inet_csum_hwoff)
> +               return true;
> +
> +       if (skb->encapsulation ||
> +           skb->csum_offset != offsetof(struct sctphdr, checksum))
> +               goto inet_csum;
> +
> +       switch (vlan_get_protocol(skb)) {
> +       case ntohs(ETH_P_IP):
> +               if (ip_hdr(skb)->protocol == IPPROTO_SCTP)
> +                       goto crc32c_csum;
> +               break;
> +       case ntohs(ETH_P_IPV6):
> +               if (ipv6_find_hdr(skb, &offset, IPPROTO_SCTP, NULL, NULL) ==
> +                   IPPROTO_SCTP)
> +                       goto crc32c_csum;
> +               break;
> +       }
> +inet_csum:
> +       return inet_csum_hwoff ? true : !skb_checksum_help(skb);
> +
> +crc32c_csum:
> +       return crc32c_csum_hwoff ? true : !skb_crc32c_csum_help(skb);
> +}
> +
>  static struct sk_buff *validate_xmit_skb(struct sk_buff *skb, struct net_device *dev)
>  {
>         netdev_features_t features;
> @@ -3022,8 +3054,7 @@ static struct sk_buff *validate_xmit_skb(struct sk_buff *skb, struct net_device
>                         else
>                                 skb_set_transport_header(skb,
>                                                          skb_checksum_start_offset(skb));
> -                       if (!(features & NETIF_F_CSUM_MASK) &&
> -                           skb_checksum_help(skb))
> +                       if (skb_csum_hwoffload_help(skb, features) == false)
>                                 goto out_kfree_skb;
>                 }
>         }
>
>
>
