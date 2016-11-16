From: Daniel Borkmann <daniel@iogearbox.net>
Subject: Re: [PATCH net-next v2 3/4] bpf, mlx5: drop priv->xdp_prog reference
 on netdev cleanup
Date: Wed, 16 Nov 2016 16:55:38 +0100
Message-ID: <582C817A.4030902@iogearbox.net>
References: <cover.1479253024.git.daniel@iogearbox.net> <4617cac95e3ca1b608f5d0a55709b0534c168943.1479253024.git.daniel@iogearbox.net> <CALzJLG9Rzds3H-wXnjCg=_2oGV-33TY714Hx0n+NyVsZzcBBfA@mail.gmail.com> <582C7F11.7000006@iogearbox.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@davemloft.net>,
        Alexei Starovoitov <alexei.starovoitov@gmail.com>,
        Brenden Blanco <bblanco@plumgrid.com>, zhiyisun@gmail.com,
        Rana Shahout <ranas@mellanox.com>,
        Saeed Mahameed <saeedm@mellanox.com>,
        Linux Netdev List <netdev@vger.kernel.org>
To: Saeed Mahameed <saeedm@dev.mellanox.co.il>
Return-path: <netdev-owner@vger.kernel.org>
Received: from www62.your-server.de ([213.133.104.62]:40808 "EHLO
        www62.your-server.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751464AbcKPPzo (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 16 Nov 2016 10:55:44 -0500
In-Reply-To: <582C7F11.7000006@iogearbox.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 11/16/2016 04:45 PM, Daniel Borkmann wrote:
> On 11/16/2016 01:51 PM, Saeed Mahameed wrote:
>> On Wed, Nov 16, 2016 at 2:04 AM, Daniel Borkmann <daniel@iogearbox.net> wrote:
>>> mlx5e_xdp_set() is currently the only place where we drop reference on the
>>> prog sitting in priv->xdp_prog when it's exchanged by a new one. We also
>>> need to make sure that we eventually release that reference, for example,
>>> in case the netdev is dismantled.
>>>
>>> Fixes: 86994156c736 ("net/mlx5e: XDP fast RX drop bpf programs support")
>>> Signed-off-by: Daniel Borkmann <daniel@iogearbox.net>
>>> ---
>>>   drivers/net/ethernet/mellanox/mlx5/core/en_main.c | 3 +++
>>>   1 file changed, 3 insertions(+)
>>>
>>> diff --git a/drivers/net/ethernet/mellanox/mlx5/core/en_main.c b/drivers/net/ethernet/mellanox/mlx5/core/en_main.c
>>> index cf26672..60fe54c 100644
>>> --- a/drivers/net/ethernet/mellanox/mlx5/core/en_main.c
>>> +++ b/drivers/net/ethernet/mellanox/mlx5/core/en_main.c
>>> @@ -3715,6 +3715,9 @@ static void mlx5e_nic_cleanup(struct mlx5e_priv *priv)
>>>
>>>          if (MLX5_CAP_GEN(mdev, vport_group_manager))
>>>                  mlx5_eswitch_unregister_vport_rep(esw, 0);
>>> +
>>> +       if (priv->xdp_prog)
>>> +               bpf_prog_put(priv->xdp_prog);
>>>   }
>>
>> I thought that on unregister_netdev  ndo_xdp_set will be called with
>> NULL prog to cleanup. like any other resources (Vlans/mac_lists/
>> etc..), why xdp should be different ?
>> Anyway if this is the case, I am ok with this fix, you can even send
>> it to net (it looks like a serious leak).
>
> The only interaction with ndo_xdp() right now is dev_change_xdp_fd()
> and the currently a bit terse dump via rtnl_xdp_fill(). The latter
> only tells whether something is actually attached and will have more
> info in near future, but doesn't alter anything.
>
> dev_change_xdp_fd() is only triggered from user side via netlink when
> IFLA_XDP container attr is around, so no automatic cleanup here. This
> means as per documentation in enum xdp_netdev_command, that the driver
> has full ownership, thus needs to bpf_prog_put().

Note that without patch 2/4, just sending this one to net doesn't really
solve anything, since there the mlx5e_xdp_set() still has the incorrect
bpf_prog_add(prog, 1) around. So it's the whole series if so. I had it
originally targeted at net, but Alexei suggested net-next; I don't really
mind either way, so I agreed to go for net-next.
