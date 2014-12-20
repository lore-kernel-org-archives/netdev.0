From: "Jia-Ju Bai" <baijiaju1990@163.com>
Subject: Re: [PATCH] e100 in linux-3.18.0: some potential bugs
Date: Sat, 20 Dec 2014 22:32:03 +0800
Message-ID: <000201d01c61$bdb956b0$392c0410$@163.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: e1000-devel@lists.sourceforge.net, netdev@vger.kernel.org,
	linux.nics@intel.com, Linux-nics@isotope.jf.intel.com
To: "'Sergei Shtylyov'" <sergei.shtylyov@cogentembedded.com>,
	<todd.fujinaka@intel.com>
Return-path: <e1000-devel-bounces@lists.sourceforge.net>
Content-Language: zh-cn
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/e1000-devel>,
	<mailto:e1000-devel-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum_name=e1000-devel>
List-Post: <mailto:e1000-devel@lists.sourceforge.net>
List-Help: <mailto:e1000-devel-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/e1000-devel>,
	<mailto:e1000-devel-request@lists.sourceforge.net?subject=subscribe>
Errors-To: e1000-devel-bounces@lists.sourceforge.net
List-Id: netdev.vger.kernel.org

I am inexperienced in submitting patches, sorry. I have revised my patch:

1.Check whether pci_pool_create is failed in e100_probe to avoid null
dereference in pci_pool_alloc(in e100_alloc_cbs).
2.Add netif_napi_del to match the call of netif_napi_add.
Signed-off-by: Jia-Ju Bai <baijiaju1990@163.com>
diff --git a/drivers/net/ethernet/intel/e100.c
b/drivers/net/ethernet/intel/e100.c
index 781065e..a58ab2e 100644
--- a/drivers/net/ethernet/intel/e100.c
+++ b/drivers/net/ethernet/intel/e100.c
@@ -2969,6 +2969,10 @@ static int e100_probe(struct pci_dev *pdev, const
struct pci_device_id *ent)
 			   nic->params.cbs.max * sizeof(struct cb),
 			   sizeof(u32),
 			   0);
+	if (!nic->cbs_pool) {
+		err = -ENOMEM;
+		goto err_out_pool;
+	}
 	netif_info(nic, probe, nic->netdev,
 		   "addr 0x%llx, irq %d, MAC addr %pM\n",
 		   (unsigned long long)pci_resource_start(pdev, use_io ? 1 :
0),
@@ -2976,6 +2980,8 @@ static int e100_probe(struct pci_dev *pdev, const
struct pci_device_id *ent)
 
 	return 0;
 
+err_out_pool:
+	unregister_netdev(netdev);
 err_out_free:
 	e100_free(nic);
 err_out_iounmap:
@@ -2985,6 +2991,7 @@ err_out_free_res:
 err_out_disable_pdev:
 	pci_disable_device(pdev);
 err_out_free_dev:
+	netif_napi_del(&nic->napi);
 	free_netdev(netdev);
 	return err;
 }
@@ -2995,6 +3002,7 @@ static void e100_remove(struct pci_dev *pdev)
 
 	if (netdev) {
 		struct nic *nic = netdev_priv(netdev);
+		netif_napi_del(&nic->napi);
 		unregister_netdev(netdev);
 		e100_free(nic);
 		pci_iounmap(pdev, nic->csr);


Is it okay?



On 12/20/2014 10:40 AM, Jia-Ju Bai wrote:

> I have actually tested e100 driver on the real hardware(Intel 82559 
> PCI Ethernet Controller), and find some bugs:
> The target file is drivers/net/ethernet/intel/e100.c, which is used to 
> build e100.ko.

> (1) The function pci_pool_create is called by e100_probe when 
> initializing the ethernet card driver. But when pci_pool_create is 
> failed, which means that it returns NULL to nic->cbs_pool, the system 
> crash will happen. Because pci_pool_alloc (in e100_alloc_cbs in 
> e100_up in e100_open) need to use
> nic->cbs_pool to allocate the resource, but it is NULL. I suggest that 
> nic->a
> check can be added in the code to detect whether pci_pool_create 
> returns NULL.
> (2) In the normal process, netif_napi_add is called in e100_probe, but 
> netif_napi_del is not called in e100_remove. However, many other 
> ethernet card drivers call them in pairs, even in the error handling 
> paths, such as
> r8169 and igb.

    Fixing one issue per patch is the rule of thumb.

> Meanwhile, I also write the patch to fix the bugs. I have run the 
> patch on the hardware, it can work normally and fix the above bugs.

    Again, your sign-off is required. See Documentation/SubmittingPatches.

> diff --git a/drivers/net/ethernet/intel/e100.c
> b/drivers/net/ethernet/intel/e100.c
> index 781065e..2631d3f 100644
> --- a/drivers/net/ethernet/intel/e100.c
> +++ b/drivers/net/ethernet/intel/e100.c
> @@ -2969,6 +2969,11 @@ static int e100_probe(struct pci_dev *pdev, 
> const struct pci_device_id *ent)
>   			   nic->params.cbs.max * sizeof(struct cb),
>   			   sizeof(u32),
>   			   0);
> +	if(!(nic->cbs_pool))

    Space needed after *if*. Please run your patches thru
scripts/checkpatch.pl.

[...]

WBR, Sergei




------------------------------------------------------------------------------
Download BIRT iHub F-Type - The Free Enterprise-Grade BIRT Server
from Actuate! Instantly Supercharge Your Business Reports and Dashboards
with Interactivity, Sharing, Native Excel Exports, App Integration & more
Get technology previously reserved for billion-dollar corporations, FREE
http://pubads.g.doubleclick.net/gampad/clk?id=164703151&iu=/4140/ostg.clktrk
_______________________________________________
E1000-devel mailing list
E1000-devel@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/e1000-devel
To learn more about Intel&#174; Ethernet, visit http://communities.intel.com/community/wired
