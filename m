From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH] net: return value of skb_linearize should be handled in
 Linux kernel
Date: Tue, 06 Dec 2016 22:51:19 -0800
Message-ID: <1481093479.18162.639.camel@edumazet-glaptop3.roam.corp.google.com>
References: <1481008233-16777-1-git-send-email-zhouzhouyi@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: faisal.latif@intel.com, dledford@redhat.com, sean.hefty@intel.com,
        hal.rosenstock@gmail.com, jeffrey.t.kirsher@intel.com,
        QLogic-Storage-Upstream@qlogic.com, jejb@linux.vnet.ibm.com,
        martin.petersen@oracle.com, jth@kernel.org, jon.maloy@ericsson.com,
        ying.xue@windriver.com, davem@davemloft.net,
        linux-rdma@vger.kernel.org, linux-kernel@vger.kernel.org,
        intel-wired-lan@lists.osuosl.org, netdev@vger.kernel.org,
        linux-scsi@vger.kernel.org, fcoe-devel@open-fcoe.org,
        tipc-discussion@lists.sourceforge.net
To: Zhouyi Zhou <zhouzhouyi@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1481008233-16777-1-git-send-email-zhouzhouyi@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, 2016-12-06 at 15:10 +0800, Zhouyi Zhou wrote:
> kmalloc_reserve may fail to allocate memory inside skb_linearize, 
> which means skb_linearize's return value should not be ignored. 
> Following patch correct the uses of skb_linearize.
> 
> Compiled in x86_64
> 
> Signed-off-by: Zhouyi Zhou <zhouzhouyi@gmail.com>
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

This would live lock.

Please drop the packet.

You probably should send one patch per driver, to ease code review and
acceptance.
