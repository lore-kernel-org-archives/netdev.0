From: Vlad Yasevich <vyasevich@gmail.com>
Subject: Re: [PATCHv3 net] {xfrm, sctp} Stick to software crc32 even if hardware
 is capable of that
Date: Tue, 15 Oct 2013 21:52:01 -0400
Message-ID: <525DF141.6060302@gmail.com>
References: <1381828777-15894-1-git-send-email-fan.du@windriver.com> <525DE666.10308@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: steffen.klassert@secunet.com, davem@davemloft.net,
	netdev@vger.kernel.org
To: Fan Du <fan.du@windriver.com>, nhorman@tuxdriver.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qc0-f170.google.com ([209.85.216.170]:53246 "EHLO
	mail-qc0-f170.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751147Ab3JPBwI (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 15 Oct 2013 21:52:08 -0400
Received: by mail-qc0-f170.google.com with SMTP id n9so69994qcw.15
        for <netdev@vger.kernel.org>; Tue, 15 Oct 2013 18:52:07 -0700 (PDT)
In-Reply-To: <525DE666.10308@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 10/15/2013 09:05 PM, Vlad Yasevich wrote:
> On 10/15/2013 05:19 AM, Fan Du wrote:
>> igb/ixgbe have hardware sctp checksum support, when this feature is
>> enabled
>> and also IPsec is armed to protect sctp traffic, ugly things happened as
>> xfrm_output checks CHECKSUM_PARTIAL to do check sum operation(sum
>> every thing
>> up and pack the 16bits result in the checksum field). The result is fail
>> establishment of sctp communication.
>>
>> Signed-off-by: Fan Du <fan.du@windriver.com>
>> Cc: Vlad Yasevich <vyasevich@gmail.com>
>> Cc: Neil Horman <nhorman@tuxdriver.com>
>> Cc: Steffen Klassert <steffen.klassert@secunet.com>
>> Acked-by: Vlad Yasevich <vyasevich@gmail.com>
>
> Looks good to me.
>

Just tryied applying this and looks like you based this on net-next.
This fixes a rather ugly bug when checksum offloading is done.
I am going to rebase this and re-submit for net.

-vlad

> -vlad
>
>> ---
>> v3:
>>    - Rename is_xfrm_armed by dst_xfrm
>>    - Move this funtion in include/net/dst.h
>>
>> v2:
>>    - Split v1 into two separate patches.
>>
>> ---
>>   include/net/dst.h |   12 ++++++++++++
>>   net/sctp/output.c |    3 ++-
>>   2 files changed, 14 insertions(+), 1 deletion(-)
>>
>> diff --git a/include/net/dst.h b/include/net/dst.h
>> index 211dcf1..44995c1 100644
>> --- a/include/net/dst.h
>> +++ b/include/net/dst.h
>> @@ -478,10 +478,22 @@ static inline struct dst_entry
>> *xfrm_lookup(struct net *net,
>>   {
>>       return dst_orig;
>>   }
>> +
>> +static inline struct xfrm_state *dst_xfrm(const struct dst_entry *dst)
>> +{
>> +    return NULL;
>> +}
>> +
>>   #else
>>   struct dst_entry *xfrm_lookup(struct net *net, struct dst_entry
>> *dst_orig,
>>                     const struct flowi *fl, struct sock *sk,
>>                     int flags);
>> +
>> +/* skb attached with this dst needs transformation if dst->xfrm is
>> valid */
>> +static inline struct xfrm_state *dst_xfrm(const struct dst_entry *dst)
>> +{
>> +    return dst->xfrm;
>> +}
>>   #endif
>>
>>   #endif /* _NET_DST_H */
>> diff --git a/net/sctp/output.c b/net/sctp/output.c
>> index 0ac3a65..24b3718 100644
>> --- a/net/sctp/output.c
>> +++ b/net/sctp/output.c
>> @@ -536,7 +536,8 @@ int sctp_packet_transmit(struct sctp_packet *packet)
>>        * by CRC32-C as described in <draft-ietf-tsvwg-sctpcsum-02.txt>.
>>        */
>>       if (!sctp_checksum_disable) {
>> -        if (!(dst->dev->features & NETIF_F_SCTP_CSUM)) {
>> +        if (!(dst->dev->features & NETIF_F_SCTP_CSUM) ||
>> +            (dst_xfrm(dst) != NULL)) {
>>               __u32 crc32 = sctp_start_cksum((__u8 *)sh, cksum_buf_len);
>>
>>               /* 3) Put the resultant value into the checksum field in
>> the
>>
>
