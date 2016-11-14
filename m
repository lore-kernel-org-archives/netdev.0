From: Daniel Borkmann <daniel@iogearbox.net>
Subject: Re: [PATCH net 2/3] bpf, mlx5: fix various refcount/prog issues in
 mlx5e_xdp_set
Date: Mon, 14 Nov 2016 20:05:56 +0100
Message-ID: <582A0B14.7080209@iogearbox.net>
References: <cover.1479080215.git.daniel@iogearbox.net> <03741f7075af64e83d23add379bdab41204396b0.1479080215.git.daniel@iogearbox.net> <af02aa53-0df6-e8b7-bcfe-5f765f5a8c09@mellanox.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: alexei.starovoitov@gmail.com, bblanco@plumgrid.com,
        tariqt@mellanox.com, zhiyisun@gmail.com, ranas@mellanox.com,
        netdev@vger.kernel.org
To: Saeed Mahameed <saeedm@mellanox.com>, davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from www62.your-server.de ([213.133.104.62]:41311 "EHLO
        www62.your-server.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753379AbcKNTGB (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 14 Nov 2016 14:06:01 -0500
In-Reply-To: <af02aa53-0df6-e8b7-bcfe-5f765f5a8c09@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 11/14/2016 07:27 PM, Saeed Mahameed wrote:
> On 11/14/2016 02:43 AM, Daniel Borkmann wrote:
>> There are multiple issues in mlx5e_xdp_set():
>>
>> 1) prog can be NULL, so calling unconditionally into bpf_prog_add(prog,
>>     priv->params.num_channels) can end badly.
>
> not correct, if prog is null we will never get to bpf_prog_add:
>
>          reset = (!priv->xdp_prog || !prog);
>          [...]
> 	if (!test_bit(MLX5E_STATE_OPENED, &priv->state) || reset)
> 		goto unlock;
>          bpf_prog_add...

Yep, I noticed already, dropped this from the changelog for net-next
rebase anyway.

>> 2) The batched bpf_prog_add() should be done at an earlier point in
>>     time. This makes sure that we cannot fail anymore at the time we
>>     want to set the program for each channel. This only means that we
>>     have to undo the bpf_prog_add() in case we return early due to
>>     reset or device not in MLX5E_STATE_OPENED yet. Note, err is 0 here.
>
> It is delayed for a reason, we do delayed batched bpf_prog_add()
> only when reset is not required (exchanging prog/old_prg) when both prog and old_prog are not null,
> which means the only thing that could fail in this case is bpf_prog_add.

Right, plus 3) below.

> so i don't see any reason for changing the logic, checking for  bpf_prog_add return value would be sufficient.

Yes, but if that fails, it would be better to check early for bailing out
since at this point in time undoing logic becomes unnecessary ugly.

> Sorry I need to go for now, I will continue reviewing this patch later.  but this patch looks a little bit exaggerated.
>
>> 3) When swapping the priv->xdp_prog, then no extra reference count must
>>     be taken since we got that from call path via dev_change_xdp_fd()
>>     already. Otherwise, we'd never be able to free the program. Also,
>>     bpf_prog_add() without checking the return code could fail.
>>
>> Fixes: 86994156c736 ("net/mlx5e: XDP fast RX drop bpf programs support")
>> Signed-off-by: Daniel Borkmann <daniel@iogearbox.net>
