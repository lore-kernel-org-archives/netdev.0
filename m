From: Saeed Mahameed <saeedm@dev.mellanox.co.il>
Subject: Re: [PATCH net-next 09/18] net/mlx5e: Write UC/MC list and promisc
 mode into vport context
Date: Mon, 23 Nov 2015 21:59:08 +0200
Message-ID: <CALzJLG-kGuYk6RoZF5_cw=2nXxO6Ek6UWrW8rnbuUeyt9R8UYg@mail.gmail.com>
References: <1448277111-16474-1-git-send-email-ogerlitz@mellanox.com>
	<1448277111-16474-10-git-send-email-ogerlitz@mellanox.com>
	<56534B8F.7040006@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Or Gerlitz <ogerlitz@mellanox.com>,
	"David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org,
	Don Dutile <ddutile@redhat.com>,
	Doug Ledford <dledford@redhat.com>,
	Saeed Mahameed <saeedm@mellanox.com>,
	Tal Alon <talal@mellanox.com>,
	Hadar Har-Zion <hadarh@mellanox.com>,
	Rony Efraim <ronye@mellanox.com>
To: Alexander Duyck <alexander.duyck@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-yk0-f172.google.com ([209.85.160.172]:35108 "EHLO
	mail-yk0-f172.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752942AbbKWT7I (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 23 Nov 2015 14:59:08 -0500
Received: by ykba77 with SMTP id a77so249922210ykb.2
        for <netdev@vger.kernel.org>; Mon, 23 Nov 2015 11:59:08 -0800 (PST)
In-Reply-To: <56534B8F.7040006@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Nov 23, 2015 at 7:23 PM, Alexander Duyck
<alexander.duyck@gmail.com> wrote:
> On 11/23/2015 03:11 AM, Or Gerlitz wrote:
>>
>> From: Saeed Mahameed <saeedm@mellanox.com>
>>
>> Each Vport/vNIC must notify underlying e-Switch layer
>> for UC/MC list and promisc mode updates, in-order to update
>> l2 tables and SR-IOV FDB tables.
>>
>> We do that at set_rx_mode ndo.
>>
>> preperation for ethernet-SRIOV and l2 table management.
>>
>> Signed-off-by: Saeed Mahameed <saeedm@mellanox.com>
>> Signed-off-by: Or Gerlitz <ogerlitz@mellanox.com>
>> ---
>>   .../ethernet/mellanox/mlx5/core/en_flow_table.c    | 99
>> ++++++++++++++++++++++
>>   1 file changed, 99 insertions(+)
>>
>> diff --git a/drivers/net/ethernet/mellanox/mlx5/core/en_flow_table.c
>> b/drivers/net/ethernet/mellanox/mlx5/core/en_flow_table.c
>> index 22d603f..9a021be 100644
>> --- a/drivers/net/ethernet/mellanox/mlx5/core/en_flow_table.c
>> +++ b/drivers/net/ethernet/mellanox/mlx5/core/en_flow_table.c
>> @@ -671,6 +671,103 @@ static void mlx5e_sync_netdev_addr(struct mlx5e_priv
>> *priv)
>>         netif_addr_unlock_bh(netdev);
>>   }
>>
>> +/* Returns a pointer to an array of type u8[][ETH_ALEN] */
>> +static u8 (*mlx5e_build_addr_array(struct mlx5e_priv *priv, int
>> list_type,
>> +                                  int *size))[ETH_ALEN]
>
>
> This is just ugly.  Isn't there a way you can just return a u8 pointer and
> assume the ETH_ALEN stride?  If nothing else it seems like it would be
> better to just create a structure or typedef containing the u8 array and to
> return a pointer to that since all the ETH_ALEN here really represents is a
> stride within your array.
>
I thought twice before writing the code this way, Indeed it looks ugly
although it is a standard C syntax, it might be cleaner to just have a
typedef or a structure.
Will try your suggestion.

>
>> +{
>> +       bool is_uc = (list_type == MLX5_NVPRT_LIST_TYPE_UC);
>> +       struct net_device *ndev = priv->netdev;
>> +       struct mlx5e_eth_addr_hash_node *hn;
>> +       struct hlist_head *addr_list;
>> +       u8 (*addr_array)[ETH_ALEN];
>> +       struct hlist_node *tmp;
>> +       int max_list_size;
>> +       int list_size;
>> +       int hi;
>> +       int i;
>> +
>> +       list_size = is_uc ? 0 : (priv->eth_addr.broadcast_enabled ? 1 :
>> 0);
>> +       max_list_size = is_uc ?
>> +               1 << MLX5_CAP_GEN(priv->mdev, log_max_current_uc_list) :
>> +               1 << MLX5_CAP_GEN(priv->mdev, log_max_current_mc_list);
>> +
>> +       addr_list = is_uc ? priv->eth_addr.netdev_uc :
>> priv->eth_addr.netdev_mc;
>> +       mlx5e_for_each_hash_node(hn, tmp, addr_list, hi)
>> +               list_size++;
>> +
>> +       if (list_size > max_list_size) {
>> +               netdev_warn(ndev,
>> +                           "netdev %s list size (%d) > (%d) max vport
>> list size, some addresses will be dropped\n",
>> +                           is_uc ? "UC" : "MC", list_size,
>> max_list_size);
>> +               list_size = max_list_size;
>> +       }
>> +
>> +       addr_array = kcalloc(list_size, ETH_ALEN, GFP_KERNEL);
>> +       if (!addr_array)
>> +               return NULL;
>> +
>> +       i = 0;
>> +       if (is_uc) { /* Make sure our own address is pushed first */
>> +               mlx5e_for_each_hash_node(hn, tmp, addr_list, hi) {
>> +                       if (ether_addr_equal(ndev->dev_addr, hn->ai.addr))
>> {
>> +                               ether_addr_copy(addr_array[i++],
>> ndev->dev_addr);
>> +                               break;
>> +                       }
>> +               }
>> +       }
>> +
>
>
> What is the point of this loop?  Is there a chance that the device address
> isn't going to be in the list somewhere?  Otherwise it seems like you could
> just follow the pattern you did for the broadcast address and just copy the
> dev_addr directly instead of crawling through the loop.
>
The main Idea of traversing in this loop is to handle the case where the
device uc list is sent empty, in this case I don't need any kind of
special logic to know whether I need to push the dev_addr directly or
not at all.

Regarding your question whether the device address going to be in the list,
the answer is yes and it is always there when the device is up, we do push
it ourselves in mlx5e_sync_netdev_addr.

for the broadcast address the pattern already existed before this patch,
and the broadcast address is not part if the netdev mc_list, so this is just
the way to handle it.

Anyway, I tend to agree with you, the loop looks redundant.
I will do some thinking offline and will come up with a better approach.

Thanks.

>
>> +       if (!is_uc && priv->eth_addr.broadcast_enabled)
>> +               ether_addr_copy(addr_array[i++], ndev->broadcast);
>> +
>> +       mlx5e_for_each_hash_node(hn, tmp, addr_list, hi) {
>> +               if (ether_addr_equal(ndev->dev_addr, hn->ai.addr))
>> +                       continue;
>> +               if (i >= list_size)
>> +                       break;
>> +               ether_addr_copy(addr_array[i++], hn->ai.addr);
>> +       }
>> +
>> +       *size = list_size;
>> +       return addr_array;
>> +}
>> +
>> +static void mlx5e_vport_context_update_addr_list(struct mlx5e_priv *priv,
>> +                                                int list_type)
>> +{
>> +       bool is_uc = (list_type == MLX5_NVPRT_LIST_TYPE_UC);
>> +       u8 (*mac_list)[ETH_ALEN];
>> +       int list_size;
>> +       int err;
>> +
>> +       mac_list = mlx5e_build_addr_array(priv, list_type, &list_size);
>> +       if (!mac_list) {
>> +               err = -ENOMEM;
>> +               goto out;
>> +       }
>> +
>> +       err = mlx5_modify_nic_vport_mac_list(priv->mdev,
>> +                                            list_type,
>> +                                            mac_list,
>> +                                            list_size);
>> +out:
>> +       if (err)
>> +               netdev_err(priv->netdev,
>> +                          "Failed to modify vport %s list err(%d)\n",
>> +                          is_uc ? "UC" : "MC", err);
>> +       kfree(mac_list);
>> +}
>> +
>> +static void mlx5e_vport_context_update(struct mlx5e_priv *priv)
>> +{
>> +       struct mlx5e_eth_addr_db *ea = &priv->eth_addr;
>> +
>> +       mlx5e_vport_context_update_addr_list(priv,
>> MLX5_NVPRT_LIST_TYPE_UC);
>> +       mlx5e_vport_context_update_addr_list(priv,
>> MLX5_NVPRT_LIST_TYPE_MC);
>> +       mlx5_modify_nic_vport_promisc(priv->mdev, 0,
>> +                                     ea->allmulti_enabled,
>> +                                     ea->promisc_enabled);
>> +}
>> +
>>   static void mlx5e_apply_netdev_addr(struct mlx5e_priv *priv)
>>   {
>>         struct mlx5e_eth_addr_hash_node *hn;
>> @@ -748,6 +845,8 @@ void mlx5e_set_rx_mode_work(struct work_struct *work)
>>         ea->promisc_enabled   = promisc_enabled;
>>         ea->allmulti_enabled  = allmulti_enabled;
>>         ea->broadcast_enabled = broadcast_enabled;
>> +
>> +       mlx5e_vport_context_update(priv);
>>   }
>>
>>   void mlx5e_init_eth_addr(struct mlx5e_priv *priv)
>>
>
> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
