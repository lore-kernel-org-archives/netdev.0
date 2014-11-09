From: Or Gerlitz <gerlitz.or@gmail.com>
Subject: Re: [PATCH V2 net-next 2/2] net/mlx4_en: Extend checksum offloading
 by CHECKSUM COMPLETE
Date: Sun, 9 Nov 2014 10:24:41 +0200
Message-ID: <CAJ3xEMg4Nhd1B4iO20=Xt=Z9jeYJVbVnXdgz5Q1w0KQ+9kVYRQ@mail.gmail.com>
References: <1415291324-22069-1-git-send-email-ogerlitz@mellanox.com>
	<1415291324-22069-3-git-send-email-ogerlitz@mellanox.com>
	<545C8582.4070408@dev.mellanox.co.il>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: "David S. Miller" <davem@davemloft.net>,
	Linux Netdev List <netdev@vger.kernel.org>,
	Matan Barak <matanb@mellanox.com>,
	Saeed Mahameed <saeedm@mellanox.com>,
	Shani Michaeli <shanim@mellanox.com>,
	Jerry Chu <hkchu@google.com>
To: Amir Vadai <amirv@mellanox.com>, Ido Shamay <idos@mellanox.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ob0-f180.google.com ([209.85.214.180]:61746 "EHLO
	mail-ob0-f180.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750769AbaKIIYm (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 9 Nov 2014 03:24:42 -0500
Received: by mail-ob0-f180.google.com with SMTP id wp4so4354967obc.25
        for <netdev@vger.kernel.org>; Sun, 09 Nov 2014 00:24:41 -0800 (PST)
In-Reply-To: <545C8582.4070408@dev.mellanox.co.il>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Nov 7, 2014 at 10:40 AM, Ido Shamay <idos@dev.mellanox.co.il> wrote:
> On 11/6/2014 6:28 PM, Or Gerlitz wrote:
>>
>>                 if (likely(dev->features & NETIF_F_RXCSUM)) {
>> -                       if ((cqe->status &
>> cpu_to_be16(MLX4_CQE_STATUS_IPOK)) &&
>> -                           (cqe->checksum == cpu_to_be16(0xffff))) {
>> -                               ring->csum_ok++;
>> -                               ip_summed = CHECKSUM_UNNECESSARY;
>> +                       if (cqe->status & cpu_to_be16(MLX4_CQE_STATUS_TCP
>> |
>> +
>> MLX4_CQE_STATUS_UDP)) {
>> +                               if ((cqe->status &
>> cpu_to_be16(MLX4_CQE_STATUS_IPOK)) &&
>> +                                   cqe->checksum == cpu_to_be16(0xffff))
>> {
>> +                                       ip_summed = CHECKSUM_UNNECESSARY;
>> +                                       ring->csum_ok++;
>> +                               } else {
>> +                                       ip_summed = CHECKSUM_NONE;
>> +                                       ring->csum_none++;
>> +                               }
>>                         } else {
>> -                               ip_summed = CHECKSUM_NONE;
>> -                               ring->csum_none++;
>> +                               if (priv->flags &
>> MLX4_EN_FLAG_RX_CSUM_NON_TCP_UDP &&
>> +                                   (cqe->status &
>> cpu_to_be16(MLX4_CQE_STATUS_IPV4 |
>> +
>> MLX4_CQE_STATUS_IPV6))) {
>> +                                       ip_summed = CHECKSUM_COMPLETE;
>> +                                       ring->csum_complete++;
>> +                               } else {
>> +                                       ip_summed = CHECKSUM_NONE;
>> +                                       ring->csum_none++;
>> +                               }
>>                         }
>>                 } else {
>>                         ip_summed = CHECKSUM_NONE;
>> @@ -776,6 +874,14 @@ int mlx4_en_process_rx_cq(struct net_device *dev,
>> struct mlx4_en_cq *cq, int bud
>>                         if (!nr)
>>                                 goto next;
>>
>> +                       if (ip_summed == CHECKSUM_COMPLETE) {
>> +                               va =
>> skb_frag_address(skb_shinfo(gro_skb)->frags);
>> +                               if (check_csum(cqe, gro_skb, va,
>> ring->hwtstamp_rx_filter)) {
>> +                                       ip_summed = CHECKSUM_NONE;
>> +                                       ring->csum_none++;
>
>
> When check_csum returns non zero value, then ring->csum_complete counter was
> already incremented, and now we are incrementing ring->csum_none (for the
> same packet), so need to --ring->csum_complete.

Thanks Ido, I'll fix that.

Amir, I saw the little noise you just reported on too but didn't want
to re-spin V1 just for that, thanks for catching this up.


>
>
>
>
> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
