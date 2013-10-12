From: Vlad Yasevich <vyasevich@gmail.com>
Subject: Re: [PATCHv2 2/2] Don't compute checksum value for SCTP skb with, CHECKSUM_PARTIAL set
Date: Sat, 12 Oct 2013 09:06:27 -0400
Message-ID: <b4c6105a-057c-4fd7-9b49-99df902447d8@email.android.com>
References: <1381384296-1821-1-git-send-email-fan.du@windriver.com> <20131010131116.GA16147@hmsreliant.think-freely.org> <5257A3D6.3010002@windriver.com> <52580A68.9040502@gmail.com> <52591A1E.7010705@windriver.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Neil Horman <nhorman@tuxdriver.com>, steffen.klassert@secunet.com,
	davem@davemloft.net, netdev@vger.kernel.org
To: Fan Du <fan.du@windriver.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qc0-f176.google.com ([209.85.216.176]:57260 "EHLO
	mail-qc0-f176.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750716Ab3JLNGe (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 12 Oct 2013 09:06:34 -0400
Received: by mail-qc0-f176.google.com with SMTP id t7so3798701qcv.35
        for <netdev@vger.kernel.org>; Sat, 12 Oct 2013 06:06:33 -0700 (PDT)
In-Reply-To: <52591A1E.7010705@windriver.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>



=46an Du <fan.du@windriver.com> wrote:

>
>
>On 2013=E5=B9=B410=E6=9C=8811=E6=97=A5 22:25, Vlad Yasevich wrote:
>> On 10/11/2013 03:08 AM, Fan Du wrote:
>>>
>>>
>>> On 2013=E5=B9=B410=E6=9C=8810=E6=97=A5 21:11, Neil Horman wrote:
>>>> On Thu, Oct 10, 2013 at 01:51:36PM +0800, Fan Du wrote:
>>>>> igb/ixgbe have hardware sctp checksum support, when this feature
>is
>>>>> enabled
>>>>> and also IPsec is armed to protect sctp traffic, ugly things
>happened as
>>>>> xfrm_output checks CHECKSUM_PARTIAL to do check sum operation(sum
>>>>> every thing
>>>>> up and pack the 16bits result in the checksum field). The result
>is fail
>>>>> establishment of sctp communication.
>>>>>
>>>> Shouldn't this be fixed in the xfrm code then? E.g. check the
>device
>>>> features
>>>> for SCTP checksum offloading and and skip the checksum during xfrm
>>>> output if its
>>>> available?
>>>>
>>>> Or am I missing something?
>>>> Neil
>>>>
>>>>
>>>
>>>
>>> From cff25810910603ff991f0c56441d6de8dc33a822 Mon Sep 17 00:00:00
>2001
>>> From: Fan Du <fan.du@windriver.com>
>>> Date: Fri, 11 Oct 2013 14:31:57 +0800
>>> Subject: [PATCH 2/2] Don't compute checksum value for SCTP skb with
>>> CHECKSUM_PARTIAL set
>>> MIME-Version: 1.0
>>> Content-Type: text/plain; charset=3DUTF-8
>>> Content-Transfer-Encoding: 8bit
>>>
>>> IPsec is not enabled in this scenario:
>>>
>>> SCTP skb set CHECKSUM_PARTIAL to indicate hardware is capable of
>doing
>>> SCTP checksum(crc32-c) scoping the whole SCTP packet range. However
>when
>>> such kind of skb is delivered through IPv4/v6 output handler,
>IPv4/v6 stack
>>> interpret CHECKSUM_PARTIAL by calling skb_checksum_help to compute
>16bits
>>> checksum value by summing everything up, the whole SCTP packet in
>software
>>> manner=EF=BC=81 After this skb reach NIC, after hardware doing its =
SCTP
>checking
>>> business, a crc32-c value will overwrite the value IPv4/v6 stack
>computed
>>> before.
>>>
>>> This patch solves this by introducing skb_is_sctpv4/6 to optimize
>such
>>> case.
>>>
>>> Signed-off-by: Fan Du <fan.du@windriver.com>
>>> ---
>>> v2:
>>> Rework this problem by introducing skb_is_scktv4/6
>>>
>>> ---
>>> include/linux/ip.h | 5 +++++
>>> include/linux/ipv6.h | 6 ++++++
>>> include/linux/skbuff.h | 1 -
>>> net/core/skbuff.c | 1 +
>>> net/ipv4/ip_output.c | 4 +++-
>>> net/ipv6/ip6_output.c | 1 +
>>> net/xfrm/xfrm_output.c | 20 +++++++++++++++-----
>>> 7 files changed, 31 insertions(+), 7 deletions(-)
>>>
>>> diff --git a/include/linux/ip.h b/include/linux/ip.h
>>> index 492bc65..f556292 100644
>>> --- a/include/linux/ip.h
>>> +++ b/include/linux/ip.h
>>> @@ -19,6 +19,7 @@
>>>
>>> #include <linux/skbuff.h>
>>> #include <uapi/linux/ip.h>
>>> +#include <uapi/linux/in.h>
>>>
>>> static inline struct iphdr *ip_hdr(const struct sk_buff *skb)
>>> {
>>> @@ -34,4 +35,8 @@ static inline struct iphdr *ipip_hdr(const struct
>>> sk_buff *skb)
>>> {
>>> return (struct iphdr *)skb_transport_header(skb);
>>> }
>>> +static inline int skb_is_sctpv4(const struct sk_buff *skb)
>>> +{
>>> + return ip_hdr(skb)->protocol =3D=3D IPPROTO_SCTP;
>>> +}
>>> #endif /* _LINUX_IP_H */
>>> diff --git a/include/linux/ipv6.h b/include/linux/ipv6.h
>>> index 28ea384..6e17c04 100644
>>> --- a/include/linux/ipv6.h
>>> +++ b/include/linux/ipv6.h
>>> @@ -2,6 +2,7 @@
>>> #define _IPV6_H
>>>
>>> #include <uapi/linux/ipv6.h>
>>> +#include <uapi/linux/in.h>
>>>
>>> #define ipv6_optlen(p) (((p)->hdrlen+1) << 3)
>>> /*
>>> @@ -387,4 +388,9 @@ static inline struct raw6_sock *raw6_sk(const
>struct
>>> sock *sk)
>>> ((__sk)->sk_bound_dev_if =3D=3D (__dif))) && \
>>> net_eq(sock_net(__sk), (__net)))
>>>
>>> +static inline int skb_is_sctpv6(const struct sk_buff *skb)
>>> +{
>>> + return ipv6_hdr(skb)->nexthdr =3D=3D IPPROTO_SCTP;
>>> +}
>>> +
>>> #endif /* _IPV6_H */
>>> diff --git a/include/linux/skbuff.h b/include/linux/skbuff.h
>>> index 2ddb48d..b36d0cc 100644
>>> --- a/include/linux/skbuff.h
>>> +++ b/include/linux/skbuff.h
>>> @@ -2393,7 +2393,6 @@ extern void skb_split(struct sk_buff *skb,
>>> extern int skb_shift(struct sk_buff *tgt, struct sk_buff *skb,
>>> int shiftlen);
>>> extern void skb_scrub_packet(struct sk_buff *skb, bool xnet);
>>> -
>>> extern struct sk_buff *skb_segment(struct sk_buff *skb,
>>> netdev_features_t features);
>>>
>>> diff --git a/net/core/skbuff.c b/net/core/skbuff.c
>>> index d81cff1..54d6172 100644
>>> --- a/net/core/skbuff.c
>>> +++ b/net/core/skbuff.c
>>> @@ -3526,3 +3526,4 @@ void skb_scrub_packet(struct sk_buff *skb,
>bool xnet)
>>> nf_reset_trace(skb);
>>> }
>>> EXPORT_SYMBOL_GPL(skb_scrub_packet);
>>> +
>>> diff --git a/net/ipv4/ip_output.c b/net/ipv4/ip_output.c
>>> index a04d872..8676b2c 100644
>>> --- a/net/ipv4/ip_output.c
>>> +++ b/net/ipv4/ip_output.c
>>> @@ -587,7 +587,9 @@ slow_path_clean:
>>>
>>> slow_path:
>>> /* for offloaded checksums cleanup checksum before fragmentation */
>>> - if ((skb->ip_summed =3D=3D CHECKSUM_PARTIAL) &&
>skb_checksum_help(skb))
>>> + if ((skb->ip_summed =3D=3D CHECKSUM_PARTIAL) &&
>>> + !skb_is_sctpv4(skb) &&
>>> + skb_checksum_help(skb))
>>> goto fail;
>>> iph =3D ip_hdr(skb);
>>>
>>> diff --git a/net/ipv6/ip6_output.c b/net/ipv6/ip6_output.c
>>> index 3a692d5..9b27d95 100644
>>> --- a/net/ipv6/ip6_output.c
>>> +++ b/net/ipv6/ip6_output.c
>>> @@ -671,6 +671,7 @@ slow_path_clean:
>>>
>>> slow_path:
>>> if ((skb->ip_summed =3D=3D CHECKSUM_PARTIAL) &&
>>> + !skb_is_sctpv6(skb) &&
>>> skb_checksum_help(skb))
>>> goto fail;
>>>
>>
>> No, this isn't right. This is a case where IP fragmentation is
>> required, and the above code will cause SCTP checksum to not be
>> computed.
>
>Ok, I got my ball, ten bucks bet this correct ;)
>
>IPv4:
>after skb reach fragmentation part, CHECKSUM_PARTIAL denotes
>L4 layer protocol need to be checksummed, then IPv4 checksum is
>recomputed for each fragmented IPv4 packet.
>
>IPv6:
>Here IPv6 doesn't need checksum for its header, again
>CHECKSUM_PARTIAL denotes L4 layer protocol need to be checksummed.
>
>So all in all, this is the right place to distinguish SCTP skb out,
>and skip checksum operation as hw does it thereafter.
>

 How does HW compute SCTP checksum when the data is split between skb?
Each skb will be submitted separately to the HW.
I think we need to fall back to SW checksum when packer will be fragmen=
ted.

-vlad
=20
>Q.E.D.
>
>
>> Looks like SCTP needs to compute the checksum in the case where
>> skb will be fragmented.
>>
>> An alternative, that will also allow us to get rid of patch 1
>> in the serices is to have a checksum handler offload function
>> that can be used to compute checksum in this case.
>>
>> -vlad
>>
>>> diff --git a/net/xfrm/xfrm_output.c b/net/xfrm/xfrm_output.c
>>> index 3bb2cdc..ddef94a 100644
>>> --- a/net/xfrm/xfrm_output.c
>>> +++ b/net/xfrm/xfrm_output.c
>>> @@ -180,6 +180,14 @@ static int xfrm_output_gso(struct sk_buff *skb=
)
>>> return 0;
>>> }
>>>
>>> +static int skb_is_sctp(const struct sk_buff *skb)
>>> +{
>>> + if (skb->protocol =3D=3D __constant_htons(ETH_P_IP))
>>> + return skb_is_sctpv4(skb);
>>> + else
>>> + return skb_is_sctpv6(skb);
>>> +}
>>> +
>>> int xfrm_output(struct sk_buff *skb)
>>> {
>>> struct net *net =3D dev_net(skb_dst(skb)->dev);
>>> @@ -189,11 +197,13 @@ int xfrm_output(struct sk_buff *skb)
>>> return xfrm_output_gso(skb);
>>>
>>> if (skb->ip_summed =3D=3D CHECKSUM_PARTIAL) {
>>> - err =3D skb_checksum_help(skb);
>>> - if (err) {
>>> - XFRM_INC_STATS(net, LINUX_MIB_XFRMOUTERROR);
>>> - kfree_skb(skb);
>>> - return err;
>>> + if (!skb_is_sctp(skb)) {
>>> + err =3D skb_checksum_help(skb);
>>> + if (err) {
>>> + XFRM_INC_STATS(net, LINUX_MIB_XFRMOUTERROR);
>>> + kfree_skb(skb);
>>> + return err;
>>> + }
>>> }
>>> }
>>>
>>
>>

--=20
Sent from my Android phone with K-9 Mail. Please excuse my brevity.
