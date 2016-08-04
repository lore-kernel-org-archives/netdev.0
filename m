From: Feng Gao <gfree.wind@gmail.com>
Subject: Re: [PATCH v3 1/1] rps: Inspect PPTP encapsulated by GRE to get flow hash
Date: Thu, 4 Aug 2016 15:37:17 +0800
Message-ID: <CA+6hz4pfWm6J9s=fzFrdPZinJ9jMiTUUcdPoJU7P0-uGbWQVng@mail.gmail.com>
References: <1470235960-4740-1-git-send-email-fgao@ikuai8.com>
 <97A6D3EA-B8BF-48FB-AFC7-FA39D315BB73@redfish-solutions.com>
 <CA+6hz4q6vH_2Roa00xF1GaCw9rJmCP6EUt1m7GzE6o3O98_iAQ@mail.gmail.com> <ee89e2b3-3803-a456-4995-fefdb685ecb2@redfish-solutions.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 8BIT
Cc: fgao@48lvckh6395k16k5.yundunddos.com,
	"David S. Miller" <davem@davemloft.net>,
	Stephen Hemminger <stephen@networkplumber.org>,
	Pravin B Shelar <pshelar@nicira.com>,
	Tom Herbert <tom@herbertland.com>,
	Alex Duyck <aduyck@mirantis.com>,
	Linux Kernel Network Developers <netdev@vger.kernel.org>
To: Philp Prindeville <philipp@redfish-solutions.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-vk0-f66.google.com ([209.85.213.66]:36008 "EHLO
	mail-vk0-f66.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752677AbcHDJv7 convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 4 Aug 2016 05:51:59 -0400
Received: by mail-vk0-f66.google.com with SMTP id t129so3809048vkg.3
        for <netdev@vger.kernel.org>; Thu, 04 Aug 2016 02:51:02 -0700 (PDT)
In-Reply-To: <ee89e2b3-3803-a456-4995-fefdb685ecb2@redfish-solutions.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Tom & Philp,

The v4 patch is sent already.
Could you help review again please?

Tom,
I follow your modification.

Philp,
I define one new struct gre_full_hdr which contains the completed gre
header, for example, csum, key, and so on.
And these members are not defined in gre_base_hdr.
It is only used to offset the sizeof type.

BTW, I find the struct and macro about pptp and gre  are redundant.
I want to refactor them in other patches.

On Thu, Aug 4, 2016 at 8:33 AM, Philp Prindeville
<philipp@redfish-solutions.com> wrote:
> Inline
>
>
>
> On 08/03/2016 05:58 PM, Feng Gao wrote:
>>
>> inline comment.
>> There are two comments that I am not clear.
>>
>> Best Regards
>> Feng
>>
>> On Thu, Aug 4, 2016 at 4:43 AM, Philip Prindeville
>> <philipp@redfish-solutions.com> wrote:
>>>
>>> Inline…
>>>
>>>> On Aug 3, 2016, at 8:52 AM, fgao@48lvckh6395k16k5.yundunddos.com wrote:
>>>>
>>>> From: Gao Feng <fgao@ikuai8.com>
>>>>
>>>> The PPTP is encapsulated by GRE header with that GRE_VERSION bits
>>>> must contain one. But current GRE RPS needs the GRE_VERSION must be
>>>> zero. So RPS does not work for PPTP traffic.
>>>>
>>>> In my test environment, there are four MIPS cores, and all traffic
>>>> are passed through by PPTP. As a result, only one core is 100% busy
>>>> while other three cores are very idle. After this patch, the usage
>>>> of four cores are balanced well.
>>>>
>>>> Signed-off-by: Gao Feng <fgao@ikuai8.com>
>>>> ---
>>>> v3: 1) Move struct pptp_gre_header defination into new file pptp.h
>>>>      2) Use sizeof GRE and PPTP type instead of literal value;
>>>>      3) Remove strict flag check for PPTP to robust;
>>>>      4) Consolidate the codes again;
>>>> v2: Update according to Tom and Philp's advice.
>>>>      1) Consolidate the codes with GRE version 0 path;
>>>>      2) Use PPP_PROTOCOL to get ppp protol;
>>>>      3) Set the FLOW_DIS_ENCAPSULATION flag;
>>>> v1: Intial patch
>>>>
>>>> drivers/net/ppp/pptp.c         |  36 +----------
>>>> include/net/pptp.h             |  40 ++++++++++++
>>>> include/uapi/linux/if_tunnel.h |   7 +-
>>>> net/core/flow_dissector.c      | 141
>>>> +++++++++++++++++++++++++----------------
>>>> 4 files changed, 134 insertions(+), 90 deletions(-)
>>>> create mode 100644 include/net/pptp.h
>>>>
>>>> diff --git a/drivers/net/ppp/pptp.c b/drivers/net/ppp/pptp.c
>>>> index ae0905e..3e68dbc 100644
>>>> --- a/drivers/net/ppp/pptp.c
>>>> +++ b/drivers/net/ppp/pptp.c
>>>> @@ -37,6 +37,7 @@
>>>> #include <net/icmp.h>
>>>> #include <net/route.h>
>>>> #include <net/gre.h>
>>>> +#include <net/pptp.h>
>>>>
>>>> #include <linux/uaccess.h>
>>>>
>>>> @@ -53,41 +54,6 @@ static struct proto pptp_sk_proto __read_mostly;
>>>> static const struct ppp_channel_ops pptp_chan_ops;
>>>> static const struct proto_ops pptp_ops;
>>>>
>>>> -#define PPP_LCP_ECHOREQ 0x09
>>>> -#define PPP_LCP_ECHOREP 0x0A
>>>> -#define SC_RCV_BITS  (SC_RCV_B7_1|SC_RCV_B7_0|SC_RCV_ODDP|SC_RCV_EVNP)
>>>> -
>>>> -#define MISSING_WINDOW 20
>>>> -#define WRAPPED(curseq, lastseq)\
>>>> -     ((((curseq) & 0xffffff00) == 0) &&\
>>>> -     (((lastseq) & 0xffffff00) == 0xffffff00))
>>>> -
>>>> -#define PPTP_GRE_PROTO  0x880B
>>>> -#define PPTP_GRE_VER    0x1
>>>> -
>>>> -#define PPTP_GRE_FLAG_C      0x80
>>>> -#define PPTP_GRE_FLAG_R      0x40
>>>> -#define PPTP_GRE_FLAG_K      0x20
>>>> -#define PPTP_GRE_FLAG_S      0x10
>>>> -#define PPTP_GRE_FLAG_A      0x80
>>>> -
>>>> -#define PPTP_GRE_IS_C(f) ((f)&PPTP_GRE_FLAG_C)
>>>> -#define PPTP_GRE_IS_R(f) ((f)&PPTP_GRE_FLAG_R)
>>>> -#define PPTP_GRE_IS_K(f) ((f)&PPTP_GRE_FLAG_K)
>>>> -#define PPTP_GRE_IS_S(f) ((f)&PPTP_GRE_FLAG_S)
>>>> -#define PPTP_GRE_IS_A(f) ((f)&PPTP_GRE_FLAG_A)
>>>> -
>>>> -#define PPTP_HEADER_OVERHEAD (2+sizeof(struct pptp_gre_header))
>>>> -struct pptp_gre_header {
>>>> -     u8  flags;
>>>> -     u8  ver;
>>>> -     __be16 protocol;
>>>> -     __be16 payload_len;
>>>> -     __be16 call_id;
>>>> -     __be32 seq;
>>>> -     __be32 ack;
>>>> -} __packed;
>>>> -
>>>> static struct pppox_sock *lookup_chan(u16 call_id, __be32 s_addr)
>>>> {
>>>>        struct pppox_sock *sock;
>>>> diff --git a/include/net/pptp.h b/include/net/pptp.h
>>>> new file mode 100644
>>>> index 0000000..301d3e2
>>>> --- /dev/null
>>>> +++ b/include/net/pptp.h
>>>> @@ -0,0 +1,40 @@
>>>> +#ifndef _NET_PPTP_H
>>>> +#define _NET_PPTP_H
>>>> +
>>>> +#define PPP_LCP_ECHOREQ 0x09
>>>> +#define PPP_LCP_ECHOREP 0x0A
>>>> +#define SC_RCV_BITS
>>>> (SC_RCV_B7_1|SC_RCV_B7_0|SC_RCV_ODDP|SC_RCV_EVNP)
>>>> +
>>>> +#define MISSING_WINDOW 20
>>>> +#define WRAPPED(curseq, lastseq)\
>>>> +     ((((curseq) & 0xffffff00) == 0) &&\
>>>> +     (((lastseq) & 0xffffff00) == 0xffffff00))
>>>> +
>>>> +#define PPTP_GRE_PROTO  0x880B
>>>> +#define PPTP_GRE_VER    0x1
>>>
>>> What about macros for accessing the lower 3 bits of the version?
>>
>> There is already one macro "GRE_VERSION" as the mask to get version.
>
>
> Yup, sorry.  Missed that.
>
>
>
>>
>>>
>>>> +
>>>> +#define PPTP_GRE_FLAG_C 0x80
>>>> +#define PPTP_GRE_FLAG_R 0x40
>>>> +#define PPTP_GRE_FLAG_K 0x20
>>>> +#define PPTP_GRE_FLAG_S 0x10
>>>> +#define PPTP_GRE_FLAG_A 0x80
>>>> +
>>>> +#define PPTP_GRE_IS_C(f) ((f)&PPTP_GRE_FLAG_C)
>>>> +#define PPTP_GRE_IS_R(f) ((f)&PPTP_GRE_FLAG_R)
>>>> +#define PPTP_GRE_IS_K(f) ((f)&PPTP_GRE_FLAG_K)
>>>> +#define PPTP_GRE_IS_S(f) ((f)&PPTP_GRE_FLAG_S)
>>>> +#define PPTP_GRE_IS_A(f) ((f)&PPTP_GRE_FLAG_A)
>>>> +
>>>> +#define PPTP_HEADER_OVERHEAD (2+sizeof(struct pptp_gre_header))
>>>> +struct pptp_gre_header {
>>>> +     u8  flags;
>>>> +     u8  ver;
>>>> +     __be16 protocol;
>>>> +     __be16 payload_len;
>>>> +     __be16 call_id;
>>>> +     __be32 seq;
>>>> +     __be32 ack;
>>>> +} __packed;
>>>
>>>
>>> What about a definition of a V0 (RFC-1701) packet?  We’re handling both,
>>> so it makes sense to define both.
>>
>> I don't get you. The struct "gre_base_hdr" is defined in gre.h. Do you
>> mean define them in same file ?
>
>
> Sorry, I phrased that poorly.  Yes, they're both defined (in different
> headers)... but when you're parsing the v0 header you're not referencing the
> gre_base_hdr members to calculate your offsets.
>
> -Philip
>
>
>
>>
>>>
>>>> +
>>>> +
>>>> +#endif
>>>> diff --git a/include/uapi/linux/if_tunnel.h
>>>> b/include/uapi/linux/if_tunnel.h
>>>> index 1046f55..7d889db 100644
>>>> --- a/include/uapi/linux/if_tunnel.h
>>>> +++ b/include/uapi/linux/if_tunnel.h
>>>> @@ -24,9 +24,14 @@
>>>> #define GRE_SEQ               __cpu_to_be16(0x1000)
>>>> #define GRE_STRICT    __cpu_to_be16(0x0800)
>>>> #define GRE_REC               __cpu_to_be16(0x0700)
>>>> -#define GRE_FLAGS    __cpu_to_be16(0x00F8)
>>>> +#define GRE_ACK              __cpu_to_be16(0x0080)
>>>> +#define GRE_FLAGS    __cpu_to_be16(0x0078)
>>>> #define GRE_VERSION   __cpu_to_be16(0x0007)
>>>>
>>>> +#define GRE_VERSION_1        __cpu_to_be16(0x0001)
>>>> +#define GRE_PROTO_PPP        __cpu_to_be16(0x880b)
>>>> +
>>>> +
>>>> struct ip_tunnel_parm {
>>>>        char                    name[IFNAMSIZ];
>>>>        int                     link;
>>>> diff --git a/net/core/flow_dissector.c b/net/core/flow_dissector.c
>>>> index 61ad43f..52b7c3c 100644
>>>> --- a/net/core/flow_dissector.c
>>>> +++ b/net/core/flow_dissector.c
>>>> @@ -6,6 +6,8 @@
>>>> #include <linux/if_vlan.h>
>>>> #include <net/ip.h>
>>>> #include <net/ipv6.h>
>>>> +#include <net/gre.h>
>>>> +#include <net/pptp.h>
>>>> #include <linux/igmp.h>
>>>> #include <linux/icmp.h>
>>>> #include <linux/sctp.h>
>>>> @@ -338,71 +340,102 @@ mpls:
>>>> ip_proto_again:
>>>>        switch (ip_proto) {
>>>>        case IPPROTO_GRE: {
>>>> -             struct gre_hdr {
>>>> -                     __be16 flags;
>>>> -                     __be16 proto;
>>>> -             } *hdr, _hdr;
>>>> +             struct gre_base_hdr *hdr, _hdr;
>>>>
>>>>                hdr = __skb_header_pointer(skb, nhoff, sizeof(_hdr),
>>>> data, hlen, &_hdr);
>>>>                if (!hdr)
>>>>                        goto out_bad;
>>>> -             /*
>>>> -              * Only look inside GRE if version zero and no
>>>> -              * routing
>>>> -              */
>>>> -             if (hdr->flags & (GRE_VERSION | GRE_ROUTING))
>>>> -                     break;
>>>>
>>>> -             proto = hdr->proto;
>>>> -             nhoff += 4;
>>>> -             if (hdr->flags & GRE_CSUM)
>>>> -                     nhoff += 4;
>>>> -             if (hdr->flags & GRE_KEY) {
>>>> -                     const __be32 *keyid;
>>>> -                     __be32 _keyid;
>>>> +             /* Only look inside GRE without routing */
>>>> +             if (!(hdr->flags & GRE_ROUTING)) {
>>>> +                     int offset = 0;
>>>>
>>>> -                     keyid = __skb_header_pointer(skb, nhoff,
>>>> sizeof(_keyid),
>>>> -                                                  data, hlen, &_keyid);
>>>> +                     proto = hdr->protocol;
>>>>
>>>> -                     if (!keyid)
>>>> -                             goto out_bad;
>>>> +                     if (hdr->flags & GRE_VERSION) {
>>>> +                             /* Maybe PPTP in GRE */
>>>> +                             if (!(proto == GRE_PROTO_PPP &&
>>>> (hdr->flags & GRE_KEY) &&
>>>> +                                  (hdr->flags & GRE_VERSION) ==
>>>> GRE_VERSION_1))
>>>> +                                     break;
>>>> +                     }
>>>>
>>>> -                     if (dissector_uses_key(flow_dissector,
>>>> -
>>>> FLOW_DISSECTOR_KEY_GRE_KEYID)) {
>>>> -                             key_keyid =
>>>> skb_flow_dissector_target(flow_dissector,
>>>> -
>>>> FLOW_DISSECTOR_KEY_GRE_KEYID,
>>>> -
>>>> target_container);
>>>> -                             key_keyid->keyid = *keyid;
>>>> +                     offset += sizeof(struct gre_base_hdr);
>>>> +
>>>> +                     if (hdr->flags & GRE_CSUM)
>>>> +                             offset += sizeof(__be32);
>>>
>>>
>>> This doesn’t tell me as much as taking the sizeof() of the particular
>>> field (by name) in the packet that you’re skipping.  Best way to do this is
>>> naming the field in the structure…
>>>
>>>
>>>> +
>>>> +                     if (hdr->flags & GRE_KEY) {
>>>> +                             const __be32 *keyid;
>>>> +                             __be32 _keyid;
>>>> +
>>>> +                             keyid = __skb_header_pointer(skb, nhoff +
>>>> offset, sizeof(_keyid),
>>>> +                                                          data, hlen,
>>>> &_keyid);
>>>> +
>>>> +                             if (!keyid)
>>>> +                                     goto out_bad;
>>>> +
>>>> +                             if (dissector_uses_key(flow_dissector,
>>>> +
>>>> FLOW_DISSECTOR_KEY_GRE_KEYID)) {
>>>> +                                     key_keyid =
>>>> skb_flow_dissector_target(flow_dissector,
>>>> +
>>>> FLOW_DISSECTOR_KEY_GRE_KEYID,
>>>> +
>>>> target_container);
>>>> +                                     key_keyid->keyid = *keyid;
>>>> +                             }
>>>> +                             offset += sizeof(_keyid);
>>>
>>>
>>> Same issue here.
>>>
>>>
>>>>                        }
>>>> -                     nhoff += 4;
>>>> -             }
>>>> -             if (hdr->flags & GRE_SEQ)
>>>> -                     nhoff += 4;
>>>> -             if (proto == htons(ETH_P_TEB)) {
>>>> -                     const struct ethhdr *eth;
>>>> -                     struct ethhdr _eth;
>>>> -
>>>> -                     eth = __skb_header_pointer(skb, nhoff,
>>>> -                                                sizeof(_eth),
>>>> -                                                data, hlen, &_eth);
>>>> -                     if (!eth)
>>>> -                             goto out_bad;
>>>> -                     proto = eth->h_proto;
>>>> -                     nhoff += sizeof(*eth);
>>>> -
>>>> -                     /* Cap headers that we access via pointers at the
>>>> -                      * end of the Ethernet header as our maximum
>>>> alignment
>>>> -                      * at that point is only 2 bytes.
>>>> -                      */
>>>> -                     if (NET_IP_ALIGN)
>>>> -                             hlen = nhoff;
>>>> -             }
>>>>
>>>> -             key_control->flags |= FLOW_DIS_ENCAPSULATION;
>>>> -             if (flags & FLOW_DISSECTOR_F_STOP_AT_ENCAP)
>>>> -                     goto out_good;
>>>> +                     if (hdr->flags & GRE_SEQ)
>>>> +                             offset += sizeof(((struct pptp_gre_header
>>>> *)0)->seq);
>>>> +
>>>> +                     if (hdr->flags & GRE_ACK)
>>>> +                             offset += sizeof(((struct pptp_gre_header
>>>> *)0)->ack);
>>>
>>>
>>> Much better.
>>>
>>> -Philip
>>>
>>>
>>>> +
>>>> +                     if (proto == GRE_PROTO_PPP) {
>>>> +                             u8 _ppp_hdr[PPP_HDRLEN];
>>>> +                             u8 *ppp_hdr;
>>>> +
>>>> +                             ppp_hdr = skb_header_pointer(skb, nhoff +
>>>> offset,
>>>> +
>>>> sizeof(_ppp_hdr), _ppp_hdr);
>>>> +                             if (!ppp_hdr)
>>>> +                                     goto out_bad;
>>>> +
>>>> +                             proto = PPP_PROTOCOL(ppp_hdr);
>>>> +                             if (proto == PPP_IP)
>>>> +                                     proto = htons(ETH_P_IP);
>>>> +                             else if (proto == PPP_IPV6)
>>>> +                                     proto = htons(ETH_P_IPV6);
>>>> +                             else
>>>> +                                     break;
>>>> +
>>>> +                             offset += PPP_HDRLEN;
>>>> +                     } else if (proto == htons(ETH_P_TEB)) {
>>>> +                             const struct ethhdr *eth;
>>>> +                             struct ethhdr _eth;
>>>> +
>>>> +                             eth = __skb_header_pointer(skb, nhoff +
>>>> offset,
>>>> +                                                        sizeof(_eth),
>>>> +                                                        data, hlen,
>>>> &_eth);
>>>> +                             if (!eth)
>>>> +                                     goto out_bad;
>>>> +                             proto = eth->h_proto;
>>>> +                             offset += sizeof(*eth);
>>>> +
>>>> +                             /* Cap headers that we access via pointers
>>>> at the
>>>> +                              * end of the Ethernet header as our
>>>> maximum alignment
>>>> +                              * at that point is only 2 bytes.
>>>> +                              */
>>>> +                             if (NET_IP_ALIGN)
>>>> +                                     hlen = (nhoff + offset);
>>>> +                     }
>>>>
>>>> -             goto again;
>>>> +                     nhoff += offset;
>>>> +                     key_control->flags |= FLOW_DIS_ENCAPSULATION;
>>>> +                     if (flags & FLOW_DISSECTOR_F_STOP_AT_ENCAP)
>>>> +                             goto out_good;
>>>> +
>>>> +                     goto again;
>>>> +             }
>>>> +             break;
>>>>        }
>>>>        case NEXTHDR_HOP:
>>>>        case NEXTHDR_ROUTING:
>>>> --
>>>> 1.9.1
>>>>
>
