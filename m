From: Saeed Mahameed <saeedm@dev.mellanox.co.il>
Subject: Re: [net 02/14] net/mlx5: Consider tx_enabled in all modes on remap
Date: Thu, 27 Jul 2017 16:33:23 +0300
Message-ID: <CALzJLG9JNYP41UqagGoCsjB5JZb-TaDHVnSEHHtNL8WJmA5P0w@mail.gmail.com>
References: <20170727102532.2317-1-saeedm@mellanox.com> <20170727102532.2317-3-saeedm@mellanox.com>
 <a88eb0e5-9164-1d7a-5077-eb90848e129b@cogentembedded.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Cc: Saeed Mahameed <saeedm@mellanox.com>,
        "David S. Miller" <davem@davemloft.net>,
        Linux Netdev List <netdev@vger.kernel.org>,
        Aviv Heller <avivh@mellanox.com>
To: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qk0-f195.google.com ([209.85.220.195]:32825 "EHLO
        mail-qk0-f195.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751533AbdG0Ndo (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 27 Jul 2017 09:33:44 -0400
Received: by mail-qk0-f195.google.com with SMTP id d145so15762159qkc.0
        for <netdev@vger.kernel.org>; Thu, 27 Jul 2017 06:33:44 -0700 (PDT)
In-Reply-To: <a88eb0e5-9164-1d7a-5077-eb90848e129b@cogentembedded.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Jul 27, 2017 at 2:55 PM, Sergei Shtylyov
<sergei.shtylyov@cogentembedded.com> wrote:
> Hello!
>
>
> On 07/27/2017 01:25 PM, Saeed Mahameed wrote:
>
>> From: Aviv Heller <avivh@mellanox.com>
>>
>> The tx_enabled lag event field is used to determine whether a slave is
>> active.
>> Current logic uses this value only if the mode is active-backup.
>>
>> However, LACP mode, although considered a load balancing mode, can mark
>> a slave as inactive in certain situations (e.g., LACP timeout).
>>
>> This fix takes the tx_enabled value into account when remapping, with
>> no respect to the LAG mode (this should not affect the behavior in XOR
>> mode, since in this mode both slaves are marked as active).
>>
>> Fixes: 7907f23adc18 (net/mlx5: Implement RoCE LAG feature)
>> Signed-off-by: Aviv Heller <avivh@mellanox.com>
>> Signed-off-by: Saeed Mahameed <saeedm@mellanox.com>
>> ---
>>  drivers/net/ethernet/mellanox/mlx5/core/lag.c | 26
>> +++++++++++---------------
>>  1 file changed, 11 insertions(+), 15 deletions(-)
>>
>> diff --git a/drivers/net/ethernet/mellanox/mlx5/core/lag.c
>> b/drivers/net/ethernet/mellanox/mlx5/core/lag.c
>> index a3a836bdcfd2..654b02e7d1aa 100644
>> --- a/drivers/net/ethernet/mellanox/mlx5/core/lag.c
>> +++ b/drivers/net/ethernet/mellanox/mlx5/core/lag.c
>> @@ -162,21 +162,17 @@ static bool mlx5_lag_is_bonded(struct mlx5_lag
>> *ldev)
>>  static void mlx5_infer_tx_affinity_mapping(struct lag_tracker *tracker,
>>                                            u8 *port1, u8 *port2)
>>  {
>> -       if (tracker->tx_type == NETDEV_LAG_TX_TYPE_ACTIVEBACKUP) {
>> -               if (tracker->netdev_state[0].tx_enabled) {
>> -                       *port1 = 1;
>> -                       *port2 = 1;
>> -               } else {
>> -                       *port1 = 2;
>> -                       *port2 = 2;
>> -               }
>> -       } else {
>> -               *port1 = 1;
>> -               *port2 = 2;
>> -               if (!tracker->netdev_state[0].link_up)
>> -                       *port1 = 2;
>> -               else if (!tracker->netdev_state[1].link_up)
>> -                       *port2 = 1;
>> +       *port1 = 1;
>> +       *port2 = 2;
>> +       if (!tracker->netdev_state[0].tx_enabled ||
>> +           !tracker->netdev_state[0].link_up) {
>> +               *port1 = 2;
>> +               return;
>> +       }
>> +
>> +       if (!tracker->netdev_state[1].tx_enabled ||
>> +           !tracker->netdev_state[1].link_up) {
>> +               *port2 = 1;
>>         }
>
>
>    {} not needed here.

Right, will fix and resubmit, Thanks Sergei.

>
> [...]
>
> MBR, Sergei
>
