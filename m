From: Fan Du <fan.du@windriver.com>
Subject: Re: [PATCH net] {xfrm, sctp} Stick to software crc32 even if hardware
 is capable of that
Date: Fri, 11 Oct 2013 15:02:44 +0800
Message-ID: <5257A294.7020803@windriver.com>
References: <1381384296-1821-1-git-send-email-fan.du@windriver.com> <5256B578.8040101@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: <nhorman@tuxdriver.com>, <steffen.klassert@secunet.com>,
	<davem@davemloft.net>, <netdev@vger.kernel.org>
To: Vlad Yasevich <vyasevich@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.windriver.com ([147.11.1.11]:63743 "EHLO
	mail.windriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752632Ab3JKHDq (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 11 Oct 2013 03:03:46 -0400
In-Reply-To: <5256B578.8040101@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>



On 2013=E5=B9=B410=E6=9C=8810=E6=97=A5 22:11, Vlad Yasevich wrote:
> On 10/10/2013 01:51 AM, Fan Du wrote:
>> igb/ixgbe have hardware sctp checksum support, when this feature is =
enabled
>> and also IPsec is armed to protect sctp traffic, ugly things happene=
d as
>> xfrm_output checks CHECKSUM_PARTIAL to do check sum operation(sum ev=
ery thing
>> up and pack the 16bits result in the checksum field). The result is =
fail
>> establishment of sctp communication.
>>
>> And I saw another point in this part of code, when IPsec is not arme=
d,
>> sctp communication is good, however setting setting CHECKSUM_PARTIAL=
 will
>> make xfrm_output compute dummy checksum values which will be overwri=
tten by
>> hardware lately.
>>
>> So this patch try to solve above two issues together.
>>
>> Signed-off-by: Fan Du <fan.du@windriver.com>
>> ---
>> note:
>> igb/ixgbe hardware is not handy on my side, so just build test only.
>>
>> ---
>> net/sctp/output.c | 27 +++++++++++++++++++--------
>> 1 file changed, 19 insertions(+), 8 deletions(-)
>>
>> diff --git a/net/sctp/output.c b/net/sctp/output.c
>> index 0ac3a65..f0b9cc5 100644
>> --- a/net/sctp/output.c
>> +++ b/net/sctp/output.c
>> @@ -372,6 +372,16 @@ static void sctp_packet_set_owner_w(struct sk_b=
uff *skb, struct sock *sk)
>> atomic_inc(&sk->sk_wmem_alloc);
>> }
>>
>> +static int is_xfrm_armed(struct dst_entry *dst)
>> +{
>> +#ifdef CONFIG_XFRM
>> + /* If dst->xfrm is valid, this skb needs to be transformed */
>> + return dst->xfrm !=3D NULL;
>> +#else
>> + return 0;
>> +#endif
>> +}
>> +
>> /* All packets are sent to the network through this function from
>> * sctp_outq_tail().
>> *
>> @@ -536,20 +546,21 @@ int sctp_packet_transmit(struct sctp_packet *p=
acket)
>> * by CRC32-C as described in <draft-ietf-tsvwg-sctpcsum-02.txt>.
>> */
>> if (!sctp_checksum_disable) {
>> - if (!(dst->dev->features & NETIF_F_SCTP_CSUM)) {
>> + if ((!(dst->dev->features & NETIF_F_SCTP_CSUM)) ||
>> + is_xfrm_armed(dst)) {
>> +
>> __u32 crc32 =3D sctp_start_cksum((__u8 *)sh, cksum_buf_len);
>>
>> /* 3) Put the resultant value into the checksum field in the
>> * common header, and leave the rest of the bits unchanged.
>> */
>> sh->checksum =3D sctp_end_cksum(crc32);
>> - } else {
>> - /* no need to seed pseudo checksum for SCTP */
>> - nskb->ip_summed =3D CHECKSUM_PARTIAL;
>> - nskb->csum_start =3D (skb_transport_header(nskb) -
>> - nskb->head);
>> - nskb->csum_offset =3D offsetof(struct sctphdr, checksum);
>> - }
>> + } else
>> + /* Mark skb as CHECKSUM_UNNECESSARY to let hardware compute
>> + * the checksum, and also avoid xfrm_output to do unceccessary
>> + * checksum.
>> + */
>> + nskb->ip_summed =3D CHECKSUM_UNNECESSARY;
>> }
>
> In addition to what Niel said, the use of CHECKSUM_UNNECESSARY is
> incorrect as it will cause the nic to not compute the checksum.
> The checksum offload depends on the use of CHECKSUM_PARTIAL.

My bad, my head is cramed with IPsec recently :( We should fix this in =
ipv4/v6 output path.

> -vlad
>
>
>>
>> /* IP layer ECN support
>>
>
>

--=20
=E6=B5=AE=E6=B2=89=E9=9A=8F=E6=B5=AA=E5=8F=AA=E8=AE=B0=E4=BB=8A=E6=9C=9D=
=E7=AC=91

--fan
