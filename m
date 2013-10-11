From: Vlad Yasevich <vyasevich@gmail.com>
Subject: Re: [PATCHv2 1/2 ] {xfrm, sctp} Stick to software crc32 even if hardware
 is capable of that
Date: Fri, 11 Oct 2013 10:04:15 -0400
Message-ID: <5258055F.5060703@gmail.com>
References: <1381384296-1821-1-git-send-email-fan.du@windriver.com> <20131010131116.GA16147@hmsreliant.think-freely.org> <5257A349.3010605@windriver.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: Fan Du <fan.du@windriver.com>, Neil Horman <nhorman@tuxdriver.com>,
	steffen.klassert@secunet.com, davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qc0-f175.google.com ([209.85.216.175]:38036 "EHLO
	mail-qc0-f175.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753438Ab3JKOES (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 11 Oct 2013 10:04:18 -0400
Received: by mail-qc0-f175.google.com with SMTP id v2so2935439qcr.34
        for <netdev@vger.kernel.org>; Fri, 11 Oct 2013 07:04:18 -0700 (PDT)
In-Reply-To: <5257A349.3010605@windriver.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 10/11/2013 03:05 AM, Fan Du wrote:
>
>
> On 2013=E5=B9=B410=E6=9C=8810=E6=97=A5 21:11, Neil Horman wrote:
>> On Thu, Oct 10, 2013 at 01:51:36PM +0800, Fan Du wrote:
>>> igb/ixgbe have hardware sctp checksum support, when this feature is
>>> enabled
>>> and also IPsec is armed to protect sctp traffic, ugly things happen=
ed as
>>> xfrm_output checks CHECKSUM_PARTIAL to do check sum operation(sum
>>> every thing
>>> up and pack the 16bits result in the checksum field). The result is=
 fail
>>> establishment of sctp communication.
>>>
>> Shouldn't this be fixed in the xfrm code then?  E.g. check the devic=
e
>> features
>> for SCTP checksum offloading and and skip the checksum during xfrm
>> output if its
>> available?
>>
>> Or am I missing something?
>> Neil
>>
>>
>
>
>  From 014276de0877f11d46e1704114a7d91f19221a63 Mon Sep 17 00:00:00 20=
01
> From: Fan Du <fan.du@windriver.com>
> Date: Fri, 11 Oct 2013 14:24:33 +0800
> Subject: [PATCH 1/2] {xfrm, sctp} Stick to software crc32 even if
> hardware is
>   capable of that
>
> igb/ixgbe have hardware sctp checksum support, when this feature is e=
nabled
> and also IPsec is armed to protect sctp traffic, ugly things happened=
 as
> xfrm_output checks CHECKSUM_PARTIAL to do check sum operation(sum eve=
ry
> thing
> up and pack the 16bits result in the checksum field). The result is f=
ail
> establishment of sctp communication.
>
> Signed-off-by: Fan Du <fan.du@windriver.com>
> ---
> v2:
>    Leave ip_summed as CHECKSUM_PARTIAL as before, the second patch wi=
ll
> fix this.
>
> ---
>   net/sctp/output.c |   14 +++++++++++++-
>   1 file changed, 13 insertions(+), 1 deletion(-)
>
> diff --git a/net/sctp/output.c b/net/sctp/output.c
> index 0ac3a65..6de6402 100644
> --- a/net/sctp/output.c
> +++ b/net/sctp/output.c
> @@ -372,6 +372,16 @@ static void sctp_packet_set_owner_w(struct sk_bu=
ff
> *skb, struct sock *sk)
>       atomic_inc(&sk->sk_wmem_alloc);
>   }
>
> +static int is_xfrm_armed(struct dst_entry *dst)
> +{
> +#ifdef CONFIG_XFRM
> +    /* If dst->xfrm is valid, this skb needs to be transformed */
> +    return dst->xfrm !=3D NULL;
> +#else
> +    return 0;
> +#endif
> +}
> +

I would really prefer to have an accessor function to dst->xfrm, but
I see that everyone codes it inside the #ifdef.  Gack.

>   /* All packets are sent to the network through this function from
>    * sctp_outq_tail().
>    *
> @@ -536,7 +546,9 @@ int sctp_packet_transmit(struct sctp_packet *pack=
et)
>        * by CRC32-C as described in <draft-ietf-tsvwg-sctpcsum-02.txt=
>.
>        */
>       if (!sctp_checksum_disable) {
> -        if (!(dst->dev->features & NETIF_F_SCTP_CSUM)) {
> +        if ((!(dst->dev->features & NETIF_F_SCTP_CSUM)) ||
> +            is_xfrm_armed(dst)) {
> +
>               __u32 crc32 =3D sctp_start_cksum((__u8 *)sh, cksum_buf_=
len);
>
>               /* 3) Put the resultant value into the checksum field i=
n the

Acked-by: Vlad Yasevich <vyasevich@gmail.com>

-vlad
