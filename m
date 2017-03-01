From: Tom Herbert <tom@herbertland.com>
Subject: Re: [PATCH RFC net-next v2 1/4] skbuff: add stub to help computing
 crc32c on SCTP packets
Date: Tue, 28 Feb 2017 19:17:55 -0800
Message-ID: <CALx6S36oXDyrm=4Bi-EdKgCBYYHuHENCoFz8GMBm6RmGCCep6g@mail.gmail.com>
References: <1488202783.2713.67.camel@redhat.com> <56fcd0848eae2b0693797e09500892659323546c.1488199633.git.dcaratti@redhat.com>
 <CAKgT0Udbs_=vanS+oF8ePXTNjEfsq9y==bhtQ-5Cxb-g+iO4bg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Davide Caratti <dcaratti@redhat.com>,
        David Laight <David.Laight@aculab.com>,
        "David S . Miller" <davem@davemloft.net>,
        Linux Kernel Network Developers <netdev@vger.kernel.org>,
        "linux-sctp @ vger . kernel . org" <linux-sctp@vger.kernel.org>,
        Marcelo Ricardo Leitner <marcelo.leitner@gmail.com>
To: Alexander Duyck <alexander.duyck@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qk0-f194.google.com ([209.85.220.194]:35572 "EHLO
        mail-qk0-f194.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751468AbdCADR7 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 28 Feb 2017 22:17:59 -0500
Received: by mail-qk0-f194.google.com with SMTP id n127so7697466qkf.2
        for <netdev@vger.kernel.org>; Tue, 28 Feb 2017 19:17:56 -0800 (PST)
In-Reply-To: <CAKgT0Udbs_=vanS+oF8ePXTNjEfsq9y==bhtQ-5Cxb-g+iO4bg@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Feb 28, 2017 at 2:46 PM, Alexander Duyck
<alexander.duyck@gmail.com> wrote:
> On Tue, Feb 28, 2017 at 2:32 AM, Davide Caratti <dcaratti@redhat.com> wrote:
>> sctp_compute_checksum requires crc32c symbol (provided by libcrc32c), so
>> it can't be used in net core. Like it has been done previously with other
>> symbols (e.g. ipv6_dst_lookup), introduce a stub struct skb_checksum_ops
>> to allow computation of SCTP checksum in net core after sctp.ko (and thus
>> libcrc32c) has been loaded.
>
> At a minimum the name really needs to change.  SCTP does not do
> checksums.  It does a CRC, and a CRC is a very different thing.  The
> fact that somebody decided that offloading a CRC could use the same
> framework is very unfortunate, and your patch descriptions in this
> whole set are calling out a CRC as checksums which it is not.
>
> I don't want to see anything "checksum" or "csum" related in the
> naming when it comes to dealing with SCTP unless we absolutely have to
> have it.  So any function names or structures with sctp in the name
> should call out "crc32" or "crc", please don't use checksum.
>
Alexander,

I agree that internal functions to sctp should not refer to checksum,
but I think we need to take care to be consistent with any external
API (even if somebody made a mistake defining it this way :-) ). As
you know the checksum interface must be very precisely defined, there
is no leeway for ambiguity. Many places in the stack use csum and
CHECKSUM_* to refer to the API not the actual algorithm, others don't
(e.g. CHECKSUM_UNNECESSARY can apply to SCTP checksum,
CHECKSUM_COMPLETE must be an Internet checksum).

For instance, in that light skb_sctp_csum_help is appropriately named
I think because this is being called from skb_csum_help and refers to
the interface to resolve a checksum.

Tom

>> Reviewed-by: Marcelo Ricardo Leitner <marcelo.leitner@gmail.com>
>> Signed-off-by: Davide Caratti <dcaratti@redhat.com>
>> ---
>>  include/linux/skbuff.h |  2 ++
>>  net/core/skbuff.c      | 20 ++++++++++++++++++++
>>  net/sctp/offload.c     |  7 +++++++
>>  3 files changed, 29 insertions(+)
>>
>> diff --git a/include/linux/skbuff.h b/include/linux/skbuff.h
>> index 69ccd26..cab9a32 100644
>> --- a/include/linux/skbuff.h
>> +++ b/include/linux/skbuff.h
>> @@ -3125,6 +3125,8 @@ struct skb_checksum_ops {
>>         __wsum (*combine)(__wsum csum, __wsum csum2, int offset, int len);
>>  };
>>
>> +extern const struct skb_checksum_ops *sctp_csum_stub __read_mostly;
>> +
>>  __wsum __skb_checksum(const struct sk_buff *skb, int offset, int len,
>>                       __wsum csum, const struct skb_checksum_ops *ops);
>>  __wsum skb_checksum(const struct sk_buff *skb, int offset, int len,
>> diff --git a/net/core/skbuff.c b/net/core/skbuff.c
>> index f355795..64fd8fd 100644
>> --- a/net/core/skbuff.c
>> +++ b/net/core/skbuff.c
>> @@ -2242,6 +2242,26 @@ __wsum skb_copy_and_csum_bits(const struct sk_buff *skb, int offset,
>>  }
>>  EXPORT_SYMBOL(skb_copy_and_csum_bits);
>>
>> +static __wsum warn_sctp_csum_update(const void *buff, int len, __wsum sum)
>> +{
>> +       net_warn_ratelimited("attempt to compute crc32c without sctp.ko\n");
>> +       return 0;
>> +}
>> +
>> +static __wsum warn_sctp_csum_combine(__wsum csum, __wsum csum2,
>> +                                    int offset, int len)
>> +{
>> +       net_warn_ratelimited("attempt to compute crc32c without sctp.ko\n");
>> +       return 0;
>> +}
>> +
>> +const struct skb_checksum_ops *sctp_csum_stub __read_mostly =
>> +       &(struct skb_checksum_ops) {
>> +       .update  = warn_sctp_csum_update,
>> +       .combine = warn_sctp_csum_combine,
>> +};
>> +EXPORT_SYMBOL(sctp_csum_stub);
>> +
>>   /**
>>   *     skb_zerocopy_headlen - Calculate headroom needed for skb_zerocopy()
>>   *     @from: source buffer
>> diff --git a/net/sctp/offload.c b/net/sctp/offload.c
>> index 4f5a2b5..e9c3db0 100644
>> --- a/net/sctp/offload.c
>> +++ b/net/sctp/offload.c
>> @@ -98,6 +98,12 @@ static const struct net_offload sctp6_offload = {
>>         },
>>  };
>>
>> +static const struct skb_checksum_ops *sctp_csum_ops __read_mostly =
>> +       &(struct skb_checksum_ops) {
>> +       .update  = sctp_csum_update,
>> +       .combine = sctp_csum_combine,
>> +};
>> +
>>  int __init sctp_offload_init(void)
>>  {
>>         int ret;
>> @@ -110,6 +116,7 @@ int __init sctp_offload_init(void)
>>         if (ret)
>>                 goto ipv4;
>>
>> +       sctp_csum_stub = sctp_csum_ops;
>>         return ret;
>>
>>  ipv4:
>> --
>> 2.7.4
>>
