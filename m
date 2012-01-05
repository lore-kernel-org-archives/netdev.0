From: Thadeu Lima de Souza Cascardo <cascardo@linux.vnet.ibm.com>
Subject: Re: [PATCH] rds_rdma: don't assume infiniband device is PCI
Date: Thu, 5 Jan 2012 15:05:24 -0200
Message-ID: <20120105170523.GA19022@oc1711230544.ibm.com>
References: <ed54708d-990e-4c8f-8057-50a70f93d3d8@default>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: davem@davemloft.net, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, dledford@redhat.com,
	Jes.Sorensen@redhat.com, rds-devel@oss.oracle.com
To: Venkat Venkatsubra <venkat.x.venkatsubra@oracle.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <ed54708d-990e-4c8f-8057-50a70f93d3d8@default>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

> ----- Original Message -----
> From: cascardo@linux.vnet.ibm.com
> To: venkat.x.venkatsubra@oracle.com
> Cc: davem@davemloft.net, netdev@vger.kernel.org, linux-kernel@vger.kernel.org, cascardo@linux.vnet.ibm.com, dledford@redhat.com, Jes.Sorensen@redhat.com, rds-devel@oss.oracle.com
> Sent: Wednesday, January 4, 2012 4:03:42 PM GMT -06:00 US/Canada Central
> Subject: [PATCH] rds_rdma: don't assume infiniband device is PCI
> 
> RDS code assumes that the struct ib_device dma_device member, which is a
> pointer, points to a struct device embedded in a struct pci_dev.
> 
> This is not the case for ehca, for example, which is a OF driver, and
> makes dma_device point to a struct device embedded in a struct
> platform_device.
> 
> This will make the system crash when rds_rdma is loaded in a system
> with ehca, since it will try to access the bus member of a non-existent
> struct pci_dev.
> 
> The only reason rds_rdma uses the struct pci_dev is to get the NUMA node
> the device is attached to. Using dev_to_node for that is much better,
> since it won't assume which bus the infiniband is attached to.
> 
> Signed-off-by: Thadeu Lima de Souza Cascardo <cascardo@linux.vnet.ibm.com>
> Cc: dledford@redhat.com
> Cc: Jes.Sorensen@redhat.com
> Cc: Venkat Venkatsubra <venkat.x.venkatsubra@oracle.com>
> Cc: rds-devel@oss.oracle.com
> ---
>  net/rds/ib.h |    3 +--
>  1 files changed, 1 insertions(+), 2 deletions(-)
> 
> diff --git a/net/rds/ib.h b/net/rds/ib.h
> index edfaaaf..8d2b3d5 100644
> --- a/net/rds/ib.h
> +++ b/net/rds/ib.h
> @@ -186,8 +186,7 @@ struct rds_ib_device {
>  	struct work_struct	free_work;
>  };
>  
> -#define pcidev_to_node(pcidev) pcibus_to_node(pcidev->bus)
> -#define ibdev_to_node(ibdev) pcidev_to_node(to_pci_dev(ibdev->dma_device))
> +#define ibdev_to_node(ibdev) dev_to_node(ibdev->dma_device)
>  #define rdsibdev_to_node(rdsibdev) ibdev_to_node(rdsibdev->dev)
>  
>  /* bits for i_ack_flags */
> -- 
> 1.7.4.4
> 

On Thu, Jan 05, 2012 at 08:56:34AM -0800, Venkat Venkatsubra wrote:
> Hi Cascardo,
> 
> Your changes look good to me.
> But our latest code doesn't use this rdsibdev_to_node macro anywhere.
> Checking with the people in my group who know the history of the NUMA feature.
> Trying to find out if the call to kzalloc_node() can be replaced by kzalloc().
> In which case this macro can be removed.
> 
> I will keep you posted.
> 
> Venkat
> 

Hi, Venkat.

Do you have any public tree where we can track the last changes in RDS?
Note that I have changed ibsdev_to_node, which rdsibdev_to_node makes
use of. Anyway, replacing kzalloc_node with kzalloc has crossed my mind,
but since I was not sure if this would affect latency of RDS in any use
cases, I kept that and used a better function to get the node from the
device. And we have dev_to_node since 2.6.20, so it should not be a
problem to use it.

If possible, keep everyone copied and avoid top posting.

Regards.
Cascardo.
