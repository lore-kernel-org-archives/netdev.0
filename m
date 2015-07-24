From: Scott Feldman <sfeldma@gmail.com>
Subject: Re: [patch net-next 2/4] mlxsw: Add PCI bus implementation
Date: Thu, 23 Jul 2015 21:52:16 -0700
Message-ID: <CAE4R7bBGErUyi64gdfSi+L-XkQLH5VMmpLM+TYoXzCYs021aLA@mail.gmail.com>
References: <1437666216-3149-1-git-send-email-jiri@resnulli.us> <1437666216-3149-3-git-send-email-jiri@resnulli.us>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Netdev <netdev@vger.kernel.org>,
	"David S. Miller" <davem@davemloft.net>, idosch@mellanox.com,
	eladr@mellanox.com,
	"ogerlitz@mellanox.com" <ogerlitz@mellanox.com>,
	Roopa Prabhu <roopa@cumulusnetworks.com>,
	Florian Fainelli <f.fainelli@gmail.com>,
	Thomas Graf <tgraf@suug.ch>, ast@plumgrid.com,
	Jamal Hadi Salim <jhs@mojatatu.com>,
	Daniel Borkmann <daniel@iogearbox.net>,
	john fastabend <john.fastabend@gmail.com>,
	"simon.horman@netronome.com" <simon.horman@netronome.com>,
	John Linville <linville@tuxdriver.com>,
	Andy Gospodarek <andy@greyhouse.net>,
	Shrijeet Mukherjee <shm@cumulusnetworks.com>,
	"nhorman@tuxdriver.com" <nhorman@tuxdriver.com>,
	Jiri Pirko <jiri@mellanox.com>
To: Jiri Pirko <jiri@resnulli.us>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ob0-f181.google.com ([209.85.214.181]:35947 "EHLO
	mail-ob0-f181.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750827AbbGXEwg (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 24 Jul 2015 00:52:36 -0400
Received: by obnw1 with SMTP id w1so9704800obn.3
        for <netdev@vger.kernel.org>; Thu, 23 Jul 2015 21:52:35 -0700 (PDT)
In-Reply-To: <1437666216-3149-3-git-send-email-jiri@resnulli.us>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Jul 23, 2015 at 8:43 AM, Jiri Pirko <jiri@resnulli.us> wrote:
> From: Jiri Pirko <jiri@mellanox.com>
>
> Add PCI bus implementation for Mellanox Technologies Switch ASICs. This
> includes firmware initialization, async queues manipulation and command
> interface implementation.
>
> Signed-off-by: Jiri Pirko <jiri@mellanox.com>
> Signed-off-by: Ido Schimmel <idosch@mellanox.com>
> Signed-off-by: Elad Raz <eladr@mellanox.com>

[cut]

> +static int mlxsw_pci_skb_transmit(void *bus_priv, struct sk_buff *skb,
> +                                 const struct mlxsw_tx_info *tx_info)
> +{
> +       struct mlxsw_pci *mlxsw_pci = bus_priv;
> +       struct mlxsw_pci_queue *q;
> +       struct mlxsw_pci_queue_elem_info *elem_info;
> +       char *wqe;
> +       int i;
> +       int err;
> +
> +       if (skb_shinfo(skb)->nr_frags > MLXSW_PCI_WQE_SG_ENTRIES - 1)
> +               return -EINVAL;

Can you skb_linearize() here to try to continue?

> +       q = mlxsw_pci_sdq_pick(mlxsw_pci, tx_info);
> +       spin_lock_bh(&q->lock);
> +       elem_info = mlxsw_pci_queue_elem_info_producer_get(q);
> +       if (!elem_info) {
> +               /* queue is full */
> +               err = -EAGAIN;
> +               goto unlock;
> +       }
> +       elem_info->u.sdq.skb = skb;
> +
> +       wqe = elem_info->elem;
> +       mlxsw_pci_wqe_c_set(wqe, 1); /* always report completion */
> +       mlxsw_pci_wqe_lp_set(wqe, !!tx_info->is_emad);
> +       mlxsw_pci_wqe_type_set(wqe, MLXSW_PCI_WQE_TYPE_ETHERNET);
> +
> +       err = mlxsw_pci_wqe_frag_map(mlxsw_pci, wqe, 0, skb->data,
> +                                    skb_headlen(skb), DMA_TO_DEVICE);
> +       if (err)
> +               goto unlock;
> +
> +       for (i = 0; i < skb_shinfo(skb)->nr_frags; i++) {
> +               const skb_frag_t *frag = &skb_shinfo(skb)->frags[i];
> +
> +               err = mlxsw_pci_wqe_frag_map(mlxsw_pci, wqe, i + 1,
> +                                            skb_frag_address(frag),
> +                                            skb_frag_size(frag),
> +                                            DMA_TO_DEVICE);
> +               if (err)
> +                       goto unmap_frags;
> +       }
> +
> +       /* Set unused sq entries byte count to zero. */
> +       for (i++; i < MLXSW_PCI_WQE_SG_ENTRIES; i++)
> +               mlxsw_pci_wqe_byte_count_set(wqe, i, 0);

Is hw OK with not clearing the unused sq entries dma_address?  Setting
byte_count to zero must be sufficient?

> +
> +       /* Everything is set up, ring producer doorbell to get HW going */
> +       q->producer_counter++;
> +       mlxsw_pci_queue_doorbell_producer_ring(mlxsw_pci, q);
> +
> +       goto unlock;
> +
> +unmap_frags:
> +       for (; i >= 0; i--)
> +               mlxsw_pci_wqe_frag_unmap(mlxsw_pci, wqe, i, DMA_TO_DEVICE);
> +unlock:
> +       spin_unlock_bh(&q->lock);
> +       return err;
> +}
> +
> +static int mlxsw_pci_cmd_exec(void *bus_priv, u16 opcode, u8 opcode_mod,
> +                             u32 in_mod, bool out_mbox_direct,
> +                             char *in_mbox, size_t in_mbox_size,
> +                             char *out_mbox, size_t out_mbox_size,
> +                             u8 *p_status)
> +{
> +       struct mlxsw_pci *mlxsw_pci = bus_priv;
> +       dma_addr_t in_mapaddr = 0;
> +       dma_addr_t out_mapaddr = 0;
> +       bool evreq = mlxsw_pci->cmd.nopoll;
> +       unsigned long timeout = msecs_to_jiffies(MLXSW_PCI_CIR_TIMEOUT_MSECS);
> +       bool *p_wait_done = &mlxsw_pci->cmd.wait_done;

Why is this initialized and then later set to false?
