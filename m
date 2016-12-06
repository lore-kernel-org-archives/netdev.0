From: Yuval Shaia <yuval.shaia-QHcLZuEGTsvQT0dZR+AlfA@public.gmane.org>
Subject: Re: [PATCH] net: return value of skb_linearize should be handled in
 Linux kernel
Date: Tue, 6 Dec 2016 18:57:21 +0200
Message-ID: <20161206165721.GB5023@yuval-lap.uk.oracle.com>
References: <1481008233-16777-1-git-send-email-zhouzhouyi@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: faisal.latif-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org, dledford-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org, sean.hefty-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org,
        hal.rosenstock-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org, jeffrey.t.kirsher-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org,
        QLogic-Storage-Upstream-h88ZbnxC6KDQT0dZR+AlfA@public.gmane.org, jejb-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org,
        martin.petersen-QHcLZuEGTsvQT0dZR+AlfA@public.gmane.org, jth-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org, jon.maloy-IzeFyvvaP7pWk0Htik3J/w@public.gmane.org,
        ying.xue-CWA4WttNNZF54TAoqtyWWQ@public.gmane.org, davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org,
        linux-rdma-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
        intel-wired-lan-qjLDD68F18P21nG7glBr7A@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
        linux-scsi-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, fcoe-devel-s9riP+hp16TNLxjTenLetw@public.gmane.org,
        tipc-discussion-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org
To: Zhouyi Zhou <zhouzhouyi-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Return-path: <linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <1481008233-16777-1-git-send-email-zhouzhouyi-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Sender: linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Tue, Dec 06, 2016 at 03:10:33PM +0800, Zhouyi Zhou wrote:
> kmalloc_reserve may fail to allocate memory inside skb_linearize, 
> which means skb_linearize's return value should not be ignored. 
> Following patch correct the uses of skb_linearize.
> 
> Compiled in x86_64

FWIW compiled also on SPARC

Reviewed-by: Yuval Shaia <yuval.shaia-QHcLZuEGTsvQT0dZR+AlfA@public.gmane.org>

> 
> Signed-off-by: Zhouyi Zhou <zhouzhouyi-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
> ---
>  drivers/infiniband/hw/nes/nes_nic.c           | 5 +++--
>  drivers/net/ethernet/intel/ixgbe/ixgbe_fcoe.c | 6 +++++-
>  drivers/net/ethernet/intel/ixgbe/ixgbe_main.c | 3 +--
>  drivers/scsi/bnx2fc/bnx2fc_fcoe.c             | 7 +++++--
>  drivers/scsi/fcoe/fcoe.c                      | 5 ++++-
>  net/tipc/link.c                               | 3 ++-
>  net/tipc/name_distr.c                         | 5 ++++-
>  7 files changed, 24 insertions(+), 10 deletions(-)
> 
> diff --git a/drivers/infiniband/hw/nes/nes_nic.c b/drivers/infiniband/hw/nes/nes_nic.c
> index 2b27d13..69372ea 100644
> --- a/drivers/infiniband/hw/nes/nes_nic.c
> +++ b/drivers/infiniband/hw/nes/nes_nic.c
> @@ -662,10 +662,11 @@ static int nes_netdev_start_xmit(struct sk_buff *skb, struct net_device *netdev)
>  				nesnic->sq_head &= nesnic->sq_size-1;
>  			}
>  		} else {
> -			nesvnic->linearized_skbs++;
>  			hoffset = skb_transport_header(skb) - skb->data;
>  			nhoffset = skb_network_header(skb) - skb->data;
> -			skb_linearize(skb);
> +			if (skb_linearize(skb))
> +				return NETDEV_TX_BUSY;
> +			nesvnic->linearized_skbs++;
>  			skb_set_transport_header(skb, hoffset);
>  			skb_set_network_header(skb, nhoffset);
>  			if (!nes_nic_send(skb, netdev))
> diff --git a/drivers/net/ethernet/intel/ixgbe/ixgbe_fcoe.c b/drivers/net/ethernet/intel/ixgbe/ixgbe_fcoe.c
> index 2a653ec..ab787cb 100644
> --- a/drivers/net/ethernet/intel/ixgbe/ixgbe_fcoe.c
> +++ b/drivers/net/ethernet/intel/ixgbe/ixgbe_fcoe.c
> @@ -490,7 +490,11 @@ int ixgbe_fcoe_ddp(struct ixgbe_adapter *adapter,
>  	 */
>  	if ((fh->fh_r_ctl == FC_RCTL_DD_SOL_DATA) &&
>  	    (fctl & FC_FC_END_SEQ)) {
> -		skb_linearize(skb);
> +		int err = 0;
> +
> +		err = skb_linearize(skb);
> +		if (err)
> +			return err;
>  		crc = (struct fcoe_crc_eof *)skb_put(skb, sizeof(*crc));
>  		crc->fcoe_eof = FC_EOF_T;
>  	}
> diff --git a/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c b/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
> index fee1f29..4926d48 100644
> --- a/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
> +++ b/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
> @@ -2173,8 +2173,7 @@ static int ixgbe_clean_rx_irq(struct ixgbe_q_vector *q_vector,
>  				total_rx_bytes += ddp_bytes;
>  				total_rx_packets += DIV_ROUND_UP(ddp_bytes,
>  								 mss);
> -			}
> -			if (!ddp_bytes) {
> +			} else {
>  				dev_kfree_skb_any(skb);
>  				continue;
>  			}
> diff --git a/drivers/scsi/bnx2fc/bnx2fc_fcoe.c b/drivers/scsi/bnx2fc/bnx2fc_fcoe.c
> index f9ddb61..197d02e 100644
> --- a/drivers/scsi/bnx2fc/bnx2fc_fcoe.c
> +++ b/drivers/scsi/bnx2fc/bnx2fc_fcoe.c
> @@ -542,8 +542,11 @@ static void bnx2fc_recv_frame(struct sk_buff *skb)
>  		return;
>  	}
>  
> -	if (skb_is_nonlinear(skb))
> -		skb_linearize(skb);
> +	if (skb_linearize(skb)) {
> +		kfree_skb(skb);
> +		return;
> +	}
> +
>  	mac = eth_hdr(skb)->h_source;
>  	dest_mac = eth_hdr(skb)->h_dest;
>  
> diff --git a/drivers/scsi/fcoe/fcoe.c b/drivers/scsi/fcoe/fcoe.c
> index 9bd41a3..f691b97 100644
> --- a/drivers/scsi/fcoe/fcoe.c
> +++ b/drivers/scsi/fcoe/fcoe.c
> @@ -1685,7 +1685,10 @@ static void fcoe_recv_frame(struct sk_buff *skb)
>  			skb->dev ? skb->dev->name : "<NULL>");
>  
>  	port = lport_priv(lport);
> -	skb_linearize(skb); /* check for skb_is_nonlinear is within skb_linearize */
> +	if (skb_linearize(skb)) {
> +		kfree_skb(skb);
> +		return;
> +	}
>  
>  	/*
>  	 * Frame length checks and setting up the header pointers
> diff --git a/net/tipc/link.c b/net/tipc/link.c
> index bda89bf..077c570 100644
> --- a/net/tipc/link.c
> +++ b/net/tipc/link.c
> @@ -1446,7 +1446,8 @@ static int tipc_link_proto_rcv(struct tipc_link *l, struct sk_buff *skb,
>  	if (tipc_own_addr(l->net) > msg_prevnode(hdr))
>  		l->net_plane = msg_net_plane(hdr);
>  
> -	skb_linearize(skb);
> +	if (skb_linearize(skb))
> +		goto exit;
>  	hdr = buf_msg(skb);
>  	data = msg_data(hdr);
>  
> diff --git a/net/tipc/name_distr.c b/net/tipc/name_distr.c
> index c1cfd92..4e05d2a 100644
> --- a/net/tipc/name_distr.c
> +++ b/net/tipc/name_distr.c
> @@ -356,7 +356,10 @@ void tipc_named_rcv(struct net *net, struct sk_buff_head *inputq)
>  
>  	spin_lock_bh(&tn->nametbl_lock);
>  	for (skb = skb_dequeue(inputq); skb; skb = skb_dequeue(inputq)) {
> -		skb_linearize(skb);
> +		if (skb_linearize(skb)) {
> +			kfree_skb(skb);
> +			continue;
> +		}
>  		msg = buf_msg(skb);
>  		mtype = msg_type(msg);
>  		item = (struct distr_item *)msg_data(msg);
> -- 
> 1.9.1
> 
> --
> To unsubscribe from this list: send the line "unsubscribe linux-rdma" in
> the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
--
To unsubscribe from this list: send the line "unsubscribe linux-rdma" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
