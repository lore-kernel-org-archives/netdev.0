From: Cong Wang <xiyou.wangcong-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Subject: Re: [PATCH] net: return value of skb_linearize should be handled in
 Linux kernel
Date: Tue, 6 Dec 2016 21:02:02 -0800
Message-ID: <CAM_iQpX0nA10tCzfZr_q5i6V2hWqfMUkvXdfo+Ro1TWHOEVi_A@mail.gmail.com>
References: <1481008233-16777-1-git-send-email-zhouzhouyi@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: faisal.latif-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org, dledford-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org, sean.hefty-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org,
        hal.rosenstock-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org,
        Jeff Kirsher <jeffrey.t.kirsher-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>,
        QLogic-Storage-Upstream-h88ZbnxC6KDQT0dZR+AlfA@public.gmane.org, jejb-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org,
        "Martin K. Petersen" <martin.petersen-QHcLZuEGTsvQT0dZR+AlfA@public.gmane.org>, jth-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org,
        jon.maloy-IzeFyvvaP7pWk0Htik3J/w@public.gmane.org, ying.xue-CWA4WttNNZF54TAoqtyWWQ@public.gmane.org,
        David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>, linux-rdma-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
        LKML <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
        intel-wired-lan <intel-wired-lan-qjLDD68F18P21nG7glBr7A@public.gmane.org>,
        Linux Kernel Network Developers <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
        linux-scsi-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, fcoe-devel-s9riP+hp16TNLxjTenLetw@public.gmane.org,
        tipc-discussion-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org
To: Zhouyi Zhou <zhouzhouyi-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Return-path: <linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <1481008233-16777-1-git-send-email-zhouzhouyi-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Sender: linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Mon, Dec 5, 2016 at 11:10 PM, Zhouyi Zhou <zhouzhouyi-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org> wrote:
> diff --git a/drivers/net/ethernet/intel/ixgbe/ixgbe_fcoe.c b/drivers/net/ethernet/intel/ixgbe/ixgbe_fcoe.c
> index 2a653ec..ab787cb 100644
> --- a/drivers/net/ethernet/intel/ixgbe/ixgbe_fcoe.c
> +++ b/drivers/net/ethernet/intel/ixgbe/ixgbe_fcoe.c
> @@ -490,7 +490,11 @@ int ixgbe_fcoe_ddp(struct ixgbe_adapter *adapter,
>          */
>         if ((fh->fh_r_ctl == FC_RCTL_DD_SOL_DATA) &&
>             (fctl & FC_FC_END_SEQ)) {
> -               skb_linearize(skb);
> +               int err = 0;
> +
> +               err = skb_linearize(skb);
> +               if (err)
> +                       return err;


You can reuse 'rc' instead of adding 'err'.



>                 crc = (struct fcoe_crc_eof *)skb_put(skb, sizeof(*crc));
>                 crc->fcoe_eof = FC_EOF_T;
>         }
> diff --git a/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c b/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
> index fee1f29..4926d48 100644
> --- a/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
> +++ b/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
> @@ -2173,8 +2173,7 @@ static int ixgbe_clean_rx_irq(struct ixgbe_q_vector *q_vector,
>                                 total_rx_bytes += ddp_bytes;
>                                 total_rx_packets += DIV_ROUND_UP(ddp_bytes,
>                                                                  mss);
> -                       }
> -                       if (!ddp_bytes) {
> +                       } else {
>                                 dev_kfree_skb_any(skb);
>                                 continue;
>                         }


This piece doesn't seem to be related.
--
To unsubscribe from this list: send the line "unsubscribe linux-rdma" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
