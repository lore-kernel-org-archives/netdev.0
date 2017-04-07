From: Tom Herbert <tom@herbertland.com>
Subject: Re: [PATCH RFC net-next v3 4/7] net: use skb->csum_algo to identify
 packets needing crc32c
Date: Fri, 7 Apr 2017 11:11:11 -0700
Message-ID: <CALx6S36rem=OuN_At6qYA=se5cpuYM1N2R8efoaszvo8b8Tz5A@mail.gmail.com>
References: <cover.1491562390.git.dcaratti@redhat.com> <CALx6S34cSH+z+humkp5s7UHAqnafHHB-GTqobHyb-SfKNe+MiA@mail.gmail.com>
 <1b776a2f30504c01cbad6a9230840dd0e79ffc0c.1491562390.git.dcaratti@redhat.com>
 <CALx6S34DdGZo7e1e37UCtpZ48jgdvHJ5nR=keyGFq3O3-b2_YQ@mail.gmail.com> <1491586160.2505.87.camel@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Alexander Duyck <alexander.duyck@gmail.com>,
        David Laight <David.Laight@aculab.com>,
        "David S . Miller" <davem@davemloft.net>,
        Marcelo Ricardo Leitner <marcelo.leitner@gmail.com>,
        Linux Kernel Network Developers <netdev@vger.kernel.org>,
        "linux-sctp @ vger . kernel . org" <linux-sctp@vger.kernel.org>
To: Davide Caratti <dcaratti@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qk0-f193.google.com ([209.85.220.193]:36233 "EHLO
        mail-qk0-f193.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752848AbdDGSLN (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 7 Apr 2017 14:11:13 -0400
Received: by mail-qk0-f193.google.com with SMTP id v75so11161889qkb.3
        for <netdev@vger.kernel.org>; Fri, 07 Apr 2017 11:11:12 -0700 (PDT)
In-Reply-To: <1491586160.2505.87.camel@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Apr 7, 2017 at 10:29 AM, Davide Caratti <dcaratti@redhat.com> wrote:
> hello Tom,
>
> On Fri, 2017-04-07 at 08:43 -0700, Tom Herbert wrote:
>> On Fri, Apr 7, 2017 at 7:16 AM, Davide Caratti <dcaratti@redhat.com> wrote:
>> > @@ -742,8 +744,10 @@ struct sk_buff {
>> >         __u8                    csum_valid:1;
>> >         __u8                    csum_complete_sw:1;
>> >         __u8                    csum_level:2;
>> > -       __u8                    __unused:1; /* one bit hole */
>> > -
>> > +       enum {
>> > +               INTERNET_CHECKSUM = 0,
>> > +               CRC32C_CHECKSUM,
>> > +       }                       csum_algo:1;
>>
>> I am worried this opens the door to a new open ended functionality
>> that will be rarely used in practice. Checksum offload is pervasive,
>> CRC offload is still a very narrow use case.
>
> thank you for the prompt response. I thought there was a silent
> agreement on that - Alexander proposed usage of an enum bitfield to be
> ready for FCoE (and I'm not against it, unless I have to find a second
> free bit in struct sk_buff :-) ). But maybe I'm misunderstanding your
> concern: is it the  name of the variable, (csum_algo instead of
> crc32c_csum), or the usage of enum bitfield (or both?) ?
>
> On Fri, 2017-04-07 at 08:43 -0700, Tom Herbert wrote:
>> Adding yet more
>> CRC/checksum variants will need more bits. It may be sufficient for
>> now just to make this a single bit which indicates "ones' checksum" or
>> indicates "other". In this case of "other" we need some analysis so
>> determine which checksum it is, this might be something that flow
>> dissector could support.
>
> ... which is my intent: by the way, from my perspective, we don't need more than 1 bit
> to extend the functionality. While reviewing my code, I was also considering
> extending the witdth of skb->ip_summed from 2 to 3 bit, so that it was possible
> to
>
Maybe just call it csum_not_ip then. Then just do "if
(unlikely(skb->csum_not_ip)) ..."

> #define
>
> CRC32C_PARTIAL <- for SCTP
> CRC_PARTIAL <- for FCoE
> CHECKSUM_PARTIAL <- for everything else
>
> It's conceptually the same thing, and the free bit is used more
> efficiently. But then I would need to check all places where
> CHECKSUM_PARTIAL is used in assignments and test: so, I told myself it's
> not worth doing it until somebody requests to extend this functionality to
> FCoE.
>
I've thought about extending ip_summed before with something like
csum_invalid. I think it opens up a can of worms since ip_summed is
being used in so many places already and the semantics of each value
have to be extremely well defined for the whole system (this is one
place where we can't tolerate any ambiguity at all and it everything
needs to be clearly documented).

>> > @@ -3129,6 +3133,14 @@ struct skb_checksum_ops {
>> >
>> >  extern const struct skb_checksum_ops *crc32c_csum_stub __read_mostly;
>> >
>> > +static inline void skb_set_crc32c_ipsummed(struct sk_buff *skb,
>> > +                                          const u8 ip_summed)
>> > +{
>> > +       skb->csum_algo = ip_summed == CHECKSUM_PARTIAL ? CRC32C_CHECKSUM :
>> > +               INTERNET_CHECKSUM;
>> > +       skb->ip_summed = ip_summed;
>>
>> This seems odd to me. skb->csum_algo and skb->ip_summed always end up
>> having the same value.
>
> this is accidentally true for CHEKSUM_NONE and CHECKSUM_PARTIAL, and only
> if skb carries a SCTP packet. This was my intent:
>
> ip_summed  (2 bit)                     | csum_algo     (1 bit)
> ---------------------------------------+-------------------
> CHEKSUM_NONE = 0                       | INTERNET_CHECKSUM = 0
> CHECKSUM_PARTIAL = 1                   | CRC32C_CHECKSUM = 1
> CHECKSUM_COMPLETE = 2 (not applicable) | INTERNET_CHECKSUM = 0 (don't care)
> CHECKSUM_UNNECESSARY = 3               | INTERNET_CHECKSUM = 0
>
> I can do this in a more explicit way, changing the prototype to
>
> static inline void skb_set_crc32c_ipsummed(struct sk_buff *skb,
>                                            const u8 ip_summed,
>                                            const u8 csum_algo)
>
> (with the advantage of saving a test on the value of ip_summed).
> Find in the comment below the reason why I'm clearing csum_algo every time
> the SCTP CRC32c is computed.
>
>> > --- a/net/netfilter/ipvs/ip_vs_proto_sctp.c
>> > +++ b/net/netfilter/ipvs/ip_vs_proto_sctp.c
>> > @@ -81,7 +81,7 @@ static void sctp_nat_csum(struct sk_buff *skb, sctp_sctphdr_t *sctph,
>> >                           unsigned int sctphoff)
>> >  {
>> >         sctph->checksum = sctp_compute_cksum(skb, sctphoff);
>> > -       skb->ip_summed = CHECKSUM_UNNECESSARY;
>> > +       skb_set_crc32c_ipsummed(skb, CHECKSUM_UNNECESSARY);
>>
>> The old code is better. CHECKSUM_UNNECESSARY already applies to non IP
>> checksums. There is nothing special about crc32 in this regard and
>> skb->csum_algo should only be valid when skb->ip_summed ==
>> CHECKSUM_PARTIAL so no need to set it here. This point should also be
>> in documentation.
>
> In my understanding, csum_algo needs to be set to INTERNET_CHECKSUM after the
> CRC32c is computed. Otherwise, after subsequent operation on the skb (e.g. it
> is encapsulated in a UDP frame), there is the possibility for skb->ip_summed
> to become CHECKSUM_PARTIAL again. So, to ensure that skb_checksum_help() and
> not skb_crc32c_help() will be called, csum_algo must be 0.
>
ip_summed should no longer be CHECKSUM_PARTIAL with CRC32c is computed.

> To minimize the impact of the patch, I substituted all assignments of skb->ip_summed,
> done by SCTP-related code, with calls to skb_set_crc32c_ipsummed(). The alternative is
> to explicitly set csum_algo to 0 (INTERNET_CHECKSUM) in SCTP-related code. Do you agree?
>
No, like I said the only case where this new bit is relevant is when
CHECKSUM_PARTIAL for a CRC is being done. When it's set for offloading
sctp crc it must be set. When CRC is resolved, in the helper for
instance, it must be cleared. If these rules are properly followed
then the bit will be zero in all other cases without needing any
additional work or conditionals.

Tom

> thank you in advance,
> regards
> --
> davide
>
