From: Feng Gao <gfree.wind@gmail.com>
Subject: Re: [PATCH 1/1] rps: Inspect PPTP encapsulated by GRE to get flow hash
Date: Thu, 28 Jul 2016 08:35:33 +0800
Message-ID: <CA+6hz4pmip8A63FOutUUp=p9M5XyCg6ywvezvqbboFY0EsdPqQ@mail.gmail.com>
References: <1469662978-19814-1-git-send-email-fgao@ikuai8.com>
 <CALx6S35PxNML7YiBGEf=-FXUuwSVphXmB_y3Ta31fx4EUkWiWQ@mail.gmail.com> <CA+6hz4rgf-_NtAKNAgE69q7UO_B2QS+QWE21MyMVwH74qOTgSQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Gao Feng <fgao@ikuai8.com>,
	"David S. Miller" <davem@davemloft.net>,
	philipp@redfish-solutions.com,
	Stephen Hemminger <stephen@networkplumber.org>,
	Pravin B Shelar <pshelar@nicira.com>,
	Alex Duyck <aduyck@mirantis.com>,
	Linux Kernel Network Developers <netdev@vger.kernel.org>
To: Tom Herbert <tom@herbertland.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ua0-f194.google.com ([209.85.217.194]:35416 "EHLO
	mail-ua0-f194.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932335AbcG1Afe (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 27 Jul 2016 20:35:34 -0400
Received: by mail-ua0-f194.google.com with SMTP id 100so1966216uaq.2
        for <netdev@vger.kernel.org>; Wed, 27 Jul 2016 17:35:34 -0700 (PDT)
In-Reply-To: <CA+6hz4rgf-_NtAKNAgE69q7UO_B2QS+QWE21MyMVwH74qOTgSQ@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Tom,

I think maybe it is not good idea to consolidate these codes with the
version 0 path.

Because I need to check the flags strictly like this "!(hdr->flags &
(GRE_CSUM | GRE_ROUTING | GRE_STRICT | GRE_REC | GRE_FLAGS))".
These flag must be zero with PPTP GRE according to the RFC, but
original GRE only ask the "GRE_VERSION|GRE_ROUTING" must be zero.
And the inner proto structures are different between with the original
GRE and PPTP GRE.

So I think it would be more awkful if consolidate these codes, unless
we don't check the flags strictly.

On Thu, Jul 28, 2016 at 8:24 AM, Feng Gao <gfree.wind@gmail.com> wrote:
> Thanks Tom, I append some inline comments.
>
> BTW, forgive me reply the email by gmail because the original mail
> server doesn't support kernel email format.
> I will send the update later.
>
> Best Regards
> Feng
>
> On Thu, Jul 28, 2016 at 8:04 AM, Tom Herbert <tom@herbertland.com> wrote:
>>
>> On Wed, Jul 27, 2016 at 4:42 PM,  <fgao@ikuai8.com> wrote:
>> > From: Gao Feng <fgao@ikuai8.com>
>> >
>> > The PPTP is encapsulated by GRE header with that GRE_VERSION bits
>> > must contain one. But current GRE RPS needs the GRE_VERSION must be
>> > zero. So RPS does not work for PPTP traffic.
>> >
>> > In my test environment, there are four MIPS cores, and all traffic
>> > are passed through by PPTP. As a result, only one core is 100% busy
>> > while other three cores are very idle. After this patch, the usage
>> > of four cores are balanced well.
>> >
>> > Signed-off-by: Gao Feng <fgao@ikuai8.com>
>> > ---
>> >  v1: Initial patch
>> >
>> >  include/uapi/linux/if_tunnel.h |   5 +-
>> >  net/core/flow_dissector.c      | 138 ++++++++++++++++++++++++++---------------
>> >  2 files changed, 92 insertions(+), 51 deletions(-)
>> >
>> > diff --git a/include/uapi/linux/if_tunnel.h b/include/uapi/linux/if_tunnel.h
>> > index 1046f55..dda4e4b 100644
>> > --- a/include/uapi/linux/if_tunnel.h
>> > +++ b/include/uapi/linux/if_tunnel.h
>> > @@ -24,9 +24,12 @@
>> >  #define GRE_SEQ                __cpu_to_be16(0x1000)
>> >  #define GRE_STRICT     __cpu_to_be16(0x0800)
>> >  #define GRE_REC                __cpu_to_be16(0x0700)
>> > -#define GRE_FLAGS      __cpu_to_be16(0x00F8)
>> > +#define GRE_ACK                __cpu_to_be16(0x0080)
>> > +#define GRE_FLAGS      __cpu_to_be16(0x0078)
>> >  #define GRE_VERSION    __cpu_to_be16(0x0007)
>> >
>> > +#define GRE_PROTO_PPP  __cpu_to_be16(0x880b)
>> > +
>> >  struct ip_tunnel_parm {
>> >         char                    name[IFNAMSIZ];
>> >         int                     link;
>> > diff --git a/net/core/flow_dissector.c b/net/core/flow_dissector.c
>> > index 61ad43f..d95e060 100644
>> > --- a/net/core/flow_dissector.c
>> > +++ b/net/core/flow_dissector.c
>> > @@ -346,63 +346,101 @@ ip_proto_again:
>> >                 hdr = __skb_header_pointer(skb, nhoff, sizeof(_hdr), data, hlen, &_hdr);
>> >                 if (!hdr)
>> >                         goto out_bad;
>> > -               /*
>> > -                * Only look inside GRE if version zero and no
>> > -                * routing
>> > -                */
>> > -               if (hdr->flags & (GRE_VERSION | GRE_ROUTING))
>> > -                       break;
>> >
>> > -               proto = hdr->proto;
>> > -               nhoff += 4;
>> > -               if (hdr->flags & GRE_CSUM)
>> > +               /*
>> > +               * Only look inside GRE if version zero and no
>> > +               * routing
>>
>> This comment is no longer true, GRE version 1 is being handled.
>
> Ok, I get it. Thanks.
>
>>
>> > +               */
>> > +               if (!(hdr->flags & (GRE_VERSION | GRE_ROUTING))) {
>> > +                       proto = hdr->proto;
>> >                         nhoff += 4;
>> > -               if (hdr->flags & GRE_KEY) {
>> > -                       const __be32 *keyid;
>> > -                       __be32 _keyid;
>> > +                       if (hdr->flags & GRE_CSUM)
>> > +                               nhoff += 4;
>> > +                       if (hdr->flags & GRE_KEY) {
>> > +                               const __be32 *keyid;
>> > +                               __be32 _keyid;
>> > +
>> > +                               keyid = __skb_header_pointer(skb, nhoff, sizeof(_keyid),
>> > +                                                            data, hlen, &_keyid);
>> > +
>> > +                               if (!keyid)
>> > +                                       goto out_bad;
>> > +
>> > +                               if (dissector_uses_key(flow_dissector,
>> > +                                                      FLOW_DISSECTOR_KEY_GRE_KEYID)) {
>> > +                                       key_keyid = skb_flow_dissector_target(flow_dissector,
>> > +                                                                             FLOW_DISSECTOR_KEY_GRE_KEYID,
>> > +                                                                             target_container);
>> > +                                       key_keyid->keyid = *keyid;
>> > +                               }
>> > +                               nhoff += 4;
>> > +                       }
>> > +                       if (hdr->flags & GRE_SEQ)
>> > +                               nhoff += 4;
>> > +                       if (proto == htons(ETH_P_TEB)) {
>> > +                               const struct ethhdr *eth;
>> > +                               struct ethhdr _eth;
>> > +
>> > +                               eth = __skb_header_pointer(skb, nhoff,
>> > +                                                          sizeof(_eth),
>> > +                                                          data, hlen, &_eth);
>> > +                               if (!eth)
>> > +                                       goto out_bad;
>> > +                               proto = eth->h_proto;
>> > +                               nhoff += sizeof(*eth);
>> > +
>> > +                               /* Cap headers that we access via pointers at the
>> > +                                * end of the Ethernet header as our maximum alignment
>> > +                                * at that point is only 2 bytes.
>> > +                                */
>> > +                               if (NET_IP_ALIGN)
>> > +                                       hlen = nhoff;
>> > +                       }
>> >
>> > -                       keyid = __skb_header_pointer(skb, nhoff, sizeof(_keyid),
>> > -                                                    data, hlen, &_keyid);
>> > +                       key_control->flags |= FLOW_DIS_ENCAPSULATION;
>> > +                       if (flags & FLOW_DISSECTOR_F_STOP_AT_ENCAP)
>> > +                               goto out_good;
>> >
>> > -                       if (!keyid)
>> > +                       goto again;
>> > +               } else if (hdr->proto == GRE_PROTO_PPP && (hdr->flags & GRE_VERSION) &&
>> > +                       (hdr->flags & GRE_KEY) &&
>> > +                       !(hdr->flags & (GRE_CSUM | GRE_ROUTING | GRE_STRICT | GRE_REC | GRE_FLAGS))) {
>> > +                       /* It should be the PPTP in GRE
>> > +                        * We have checked the flags according to the
>> > +                        * RFC 2637
>> > +                        */
>> > +                       struct ppp_frame {
>> > +                               /* address & control, just ignore it */
>> > +                               __be16 ignore;
>> > +                               __be16 proto;
>> > +                       } *frame, _frame;
>>
>> Isn't there a common definition of a PPP frame?
>
> Sorry, I fail to find the common definition of PPP frame indeed by
> cscope search.
>
>>
>> > +                       int offset = 0;
>> > +
>> > +                       /* Skip GRE header */
>> > +                       offset += 4;
>> > +                       /* Skip payload length and call id */
>> > +                       offset += 4;
>> > +
>> > +                       if (hdr->flags & GRE_SEQ)
>> > +                               offset += 4;
>> > +
>> > +                       if (hdr->flags & GRE_ACK)
>> > +                               offset += 4;
>> > +
>> > +                       frame = skb_header_pointer(skb, nhoff + offset, sizeof(_frame), &_frame);
>> > +                       if (!frame)
>> >                                 goto out_bad;
>> > -
>> > -                       if (dissector_uses_key(flow_dissector,
>> > -                                              FLOW_DISSECTOR_KEY_GRE_KEYID)) {
>> > -                               key_keyid = skb_flow_dissector_target(flow_dissector,
>> > -                                                                     FLOW_DISSECTOR_KEY_GRE_KEYID,
>> > -                                                                     target_container);
>> > -                               key_keyid->keyid = *keyid;
>> > +                       if (frame->proto == __constant_htons(PPP_IP)) {
>> > +                               nhoff += (sizeof(*frame) + offset);
>> > +                               proto = __constant_htons(ETH_P_IP);
>> > +                               goto again;
>> > +                       } else if (frame->proto == __constant_htons(PPP_IPV6)) {
>> > +                               nhoff += (sizeof(*frame) + offset);
>> > +                               proto = __constant_htons(ETH_P_IPV6);
>> > +                               goto again;
>>
>> There's a lot of code replication here with the version 0 path. Please
>> consolidate these. Also, this looks an awful lot like ETH_P_PPP_SES,
>> can this code leverage that code?
>
> Ok, I could try to consolidate these codes with the version 0 path.
> About the ETH_P_PPP_SES, there are some differences between them.
> So I have no idea to leverage that code.
>
>>
>> >                         }
>> > -                       nhoff += 4;
>> >                 }
>> > -               if (hdr->flags & GRE_SEQ)
>> > -                       nhoff += 4;
>> > -               if (proto == htons(ETH_P_TEB)) {
>> > -                       const struct ethhdr *eth;
>> > -                       struct ethhdr _eth;
>> > -
>> > -                       eth = __skb_header_pointer(skb, nhoff,
>> > -                                                  sizeof(_eth),
>> > -                                                  data, hlen, &_eth);
>> > -                       if (!eth)
>> > -                               goto out_bad;
>> > -                       proto = eth->h_proto;
>> > -                       nhoff += sizeof(*eth);
>> > -
>> > -                       /* Cap headers that we access via pointers at the
>> > -                        * end of the Ethernet header as our maximum alignment
>> > -                        * at that point is only 2 bytes.
>> > -                        */
>> > -                       if (NET_IP_ALIGN)
>> > -                               hlen = nhoff;
>> > -               }
>> > -
>> > -               key_control->flags |= FLOW_DIS_ENCAPSULATION;
>> > -               if (flags & FLOW_DISSECTOR_F_STOP_AT_ENCAP)
>> > -                       goto out_good;
>> > -
>> > -               goto again;
>> > +               break;
>> >         }
>> >         case NEXTHDR_HOP:
>> >         case NEXTHDR_ROUTING:
>> > --
>> > 1.9.1
>> >
