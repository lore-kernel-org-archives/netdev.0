From: Daniel Borkmann <daniel@iogearbox.net>
Subject: Re: [PATCH net 1/3] bpf, mlx5: fix mlx5e_create_rq taking reference
 on prog
Date: Mon, 14 Nov 2016 19:26:29 +0100
Message-ID: <582A01D5.6060608@iogearbox.net>
References: <cover.1479080215.git.daniel@iogearbox.net> <0447a6161550c466ef799b46095440949ffc7df0.1479080215.git.daniel@iogearbox.net> <918902f3-1852-ae68-b12d-eaa1c45bf641@mellanox.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: alexei.starovoitov@gmail.com, bblanco@plumgrid.com,
        tariqt@mellanox.com, zhiyisun@gmail.com, ranas@mellanox.com,
        netdev@vger.kernel.org
To: Saeed Mahameed <saeedm@mellanox.com>, davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from www62.your-server.de ([213.133.104.62]:36909 "EHLO
        www62.your-server.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S933225AbcKNS0e (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 14 Nov 2016 13:26:34 -0500
In-Reply-To: <918902f3-1852-ae68-b12d-eaa1c45bf641@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Saeed,

On 11/14/2016 07:15 PM, Saeed Mahameed wrote:
> On 11/14/2016 02:43 AM, Daniel Borkmann wrote:
>> In mlx5e_create_rq(), when creating a new queue, we call bpf_prog_add() but
>> without checking the return value. bpf_prog_add() can fail, so we really
>
> Didn't know this, thanks for noticing, I wonder why taking a reference for an object would fail ?
> especially when someone is requesting from the driver to take a reference to it ndo_xdp_set ?! sounds like a bad design.
>
> Anyway I will check that later.

See 92117d8443bc ("bpf: fix refcnt overflow").

>> must check it. Take the reference right when we assign it to the rq from
>> priv->xdp_prog, and just drop the reference on error path. Destruction in
>> mlx5e_destroy_rq() looks good, though.
>>
>> Fixes: 86994156c736 ("net/mlx5e: XDP fast RX drop bpf programs support")
>> Signed-off-by: Daniel Borkmann <daniel@iogearbox.net>
>> ---
>>   drivers/net/ethernet/mellanox/mlx5/core/en_main.c | 14 +++++++++++---
>>   kernel/bpf/syscall.c                              |  1 +
>>   2 files changed, 12 insertions(+), 3 deletions(-)
>>
>> diff --git a/drivers/net/ethernet/mellanox/mlx5/core/en_main.c b/drivers/net/ethernet/mellanox/mlx5/core/en_main.c
>> index 84e8b25..2b83667 100644
>> --- a/drivers/net/ethernet/mellanox/mlx5/core/en_main.c
>> +++ b/drivers/net/ethernet/mellanox/mlx5/core/en_main.c
>> @@ -489,7 +489,16 @@ static int mlx5e_create_rq(struct mlx5e_channel *c,
>>   	rq->channel = c;
>>   	rq->ix      = c->ix;
>>   	rq->priv    = c->priv;
>> +
>>   	rq->xdp_prog = priv->xdp_prog;
>
> Why keeping this assignment ? just test priv->xdp_prog.
>
>> +	if (rq->xdp_prog) {
>> +		rq->xdp_prog = bpf_prog_inc(rq->xdp_prog);
>> +		if (IS_ERR(rq->xdp_prog)) {
>> +			err = PTR_ERR(rq->xdp_prog);
>> +			rq->xdp_prog = NULL;
>> +			goto err_rq_wq_destroy;
>> +		}
>> +	}
>
> Try this, simpler and less indentations:
>
> rq->xdp_prog = priv->xdp_prog ? bpf_prog_inc(priv->xdp_prog) : NULL;
> if (IS_ERR(rq->xdp_prog)) {
> 	err = PTR_ERR(rq->xdp_prog);
> 	rq->xdp_prog = NULL;
> 	goto err_rq_wq_destroy;
> }

Sure, I don't mind. Will do.

Thanks,
Daniel
