From: Or Gerlitz <or.gerlitz@gmail.com>
Subject: Re: [PATCH V1 net-next 2/7] mlx4_core: For RoCE, allow slaves to set
 the GID entry at that slave's index
Date: Tue, 11 Mar 2014 22:12:33 +0200
Message-ID: <CAJZOPZJJ9YaTpzx-M9r-M7-fZq1m2YFjhKzffUH=eHhyvsvQtw@mail.gmail.com>
References: <1394542976-20095-1-git-send-email-ogerlitz@mellanox.com>
	<1394542976-20095-3-git-send-email-ogerlitz@mellanox.com>
	<531F6004.4070208@cogentembedded.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: Or Gerlitz <ogerlitz@mellanox.com>,
	David Miller <davem@davemloft.net>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	Roland Dreier <roland@kernel.org>,
	Jack Morgenstein <jackm@dev.mellanox.co.il>,
	Amir Vadai <amirv@mellanox.com>
To: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f53.google.com ([209.85.220.53]:49956 "EHLO
	mail-pa0-f53.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755257AbaCKUMe (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 11 Mar 2014 16:12:34 -0400
Received: by mail-pa0-f53.google.com with SMTP id ld10so38793pab.26
        for <netdev@vger.kernel.org>; Tue, 11 Mar 2014 13:12:33 -0700 (PDT)
In-Reply-To: <531F6004.4070208@cogentembedded.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Mar 11, 2014 at 9:12 PM, Sergei Shtylyov
<sergei.shtylyov@cogentembedded.com> wrote:
> Hello.
>
>
> On 03/11/2014 04:02 PM, Or Gerlitz wrote:
>
>> From: Jack Morgenstein <jackm@dev.mellanox.co.il>
>
>
>> For IB transport, the host determines the slave GIDs. For ETH (RoCE),
>> however, the slave's GID is determined by the IP address that the slave
>> itself assigns to the ETH device used by RoCE.
>
>
>> In this case, the slave must be able to write its GIDs to the HCA gid
>> table
>> (at the GID indices that slave "owns").
>
>
>> This commit adds processing for the SET_PORT_GID_TABLE opcode modifier
>> for the SET_PORT command wrapper (so that slaves may modify their GIDS
>> for RoCE).
>
>
>> Signed-off-by: Jack Morgenstein <jackm@dev.mellanox.co.il>
>> Signed-off-by: Or Gerlitz <ogerlitz@mellanox.com>
>> ---
>>   drivers/net/ethernet/mellanox/mlx4/port.c |   27
>> ++++++++++++++++++++++++++-
>>   1 files changed, 26 insertions(+), 1 deletions(-)
>
>
>> diff --git a/drivers/net/ethernet/mellanox/mlx4/port.c
>> b/drivers/net/ethernet/mellanox/mlx4/port.c
>> index 9c063d6..095f74d 100644
>> --- a/drivers/net/ethernet/mellanox/mlx4/port.c
>> +++ b/drivers/net/ethernet/mellanox/mlx4/port.c
>
> [...]
>
>> @@ -581,6 +584,28 @@ static int mlx4_common_set_port(struct mlx4_dev *dev,
>> int slave, u32 in_mod,
>>
>>                         gen_context->mtu =
>> cpu_to_be16(master->max_mtu[port]);
>>                         break;
>> +               case MLX4_SET_PORT_GID_TABLE:
>> +                       gid_entry = (struct mlx4_roce_gid_entry
>> *)(inbox->buf);
>> +                       /* check that do not have duplicates */
>> +                       if (memcmp(gid_entry->raw, zgid_entry.raw, 16)) {
>> +                               for (i = 0; i < MLX4_ROCE_MAX_GIDS; i++) {
>> +                                       if (slave != i &&
>> +                                           !memcmp(gid_entry->raw,
>> priv->roce_gids[port - 1][i].raw, 16)) {
>
>
>    This line is over 80 columns, as checkpatch.pl would have told.

Indeed, I don't think the 80 columns warning of checkpatch is
considered a gating factor for accepting patches, so I would prefer
not to re-spin the series just to fix this sort of warnings.


>
>
>> +                                               mlx4_warn(dev, "requested
>> gid entry for slave:%d "
>> +                                                         "is a duplicate
>> of slave %d\n",
>
>
>     checkpatch.pl would have warned not to break up the string literal here
> -- it's an exception from the 80-column rule.

I see, yep, I assume we can fix that if needed.
