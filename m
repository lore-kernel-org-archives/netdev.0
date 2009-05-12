From: Wei Yongjun <yjwei@cn.fujitsu.com>
Subject: Re: [PowerPC] Next May 8 boot failure: OOPS during ibmveth moduleinit
Date: Tue, 12 May 2009 16:17:32 +0800
Message-ID: <4A09309C.8000404@cn.fujitsu.com>
References: <20090508180251.f53f204e.sfr@canb.auug.org.au>	<4A042B20.4090903@in.ibm.com>	<20090508.125722.54378771.davem@davemloft.net>	<20090508223332.GA4881@psychotron.englab.brq.redhat.com>	<4A085B3D.5000806@in.ibm.com>	<20090512170458.39c4ffb7.sfr@canb.auug.org.au> <20090512174451.eeed4126.sfr@canb.auug.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>,
	Sachin Sant <sachinp@in.ibm.com>,
	Jiri Pirko <jpirko@redhat.com>, linux-next@vger.kernel.org,
	linuxppc-dev@ozlabs.org, netdev@vger.kernel.org
To: Stephen Rothwell <sfr@canb.auug.org.au>
Return-path: <linux-next-owner@vger.kernel.org>
In-Reply-To: <20090512174451.eeed4126.sfr@canb.auug.org.au>
Sender: linux-next-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Stephen Rothwell wrote:
> Hi Dave,
>
> This fixes it (I wonder if this bug is lurking in any other drivers):
>   

Yes, there are some other exists. This spatch script can help to found this.
(http://www.emn.fr/x-info/coccinelle/)

# cat netdev_dev_addr.cocci
@@
struct net_device *dev;
@@
memcpy(
- &dev->dev_addr
+ dev->dev_addr
, ...);

@@
struct net_device *dev;
expression E;
@@
memcpy(E,
- &dev->dev_addr
+ dev->dev_addr
, ...);

@@
expression E;
@@
- &E->dev_addr
+ E->dev_addr


> From: Stephen Rothwell <sfr@canb.auug.org.au>
> Date: Tue, 12 May 2009 17:24:02 +1000
> Subject: [PATCH] net/ibmveth: fix panic in probe
>
> netdev->dev_addr changed from being an array to being a pointer, so we
> should not take its address for memcpy().
>
> Signed-off-by: Stephen Rothwell <sfr@canb.auug.org.au>
> ---
>  drivers/net/ibmveth.c |    2 +-
>  1 files changed, 1 insertions(+), 1 deletions(-)
>
> diff --git a/drivers/net/ibmveth.c b/drivers/net/ibmveth.c
> index 7902e5e..8daffad 100644
> --- a/drivers/net/ibmveth.c
> +++ b/drivers/net/ibmveth.c
> @@ -1285,7 +1285,7 @@ static int __devinit ibmveth_probe(struct vio_dev *dev, const struct vio_device_
>   	netdev->features |= NETIF_F_LLTX;
>  	spin_lock_init(&adapter->stats_lock);
>  
> -	memcpy(&netdev->dev_addr, &adapter->mac_addr, netdev->addr_len);
> +	memcpy(netdev->dev_addr, &adapter->mac_addr, netdev->addr_len);
>  
>  	for(i = 0; i<IbmVethNumBufferPools; i++) {
>  		struct kobject *kobj = &adapter->rx_buff_pool[i].kobj;
>   

maybe this line should be fix too.


@@ -1368,7 +1368,7 @@ static void ibmveth_proc_unregister_driv
 static int ibmveth_show(struct seq_file *seq, void *v)
 {
 	struct ibmveth_adapter *adapter = seq->private;
-	char *current_mac = ((char*) &adapter->netdev->dev_addr);
+	char *current_mac = ((char*) adapter->netdev->dev_addr);
 	char *firmware_mac = ((char*) &adapter->mac_addr) ;
 
 	seq_printf(seq, "%s %s\n\n", ibmveth_driver_string, ibmveth_driver_version);
