From: Dan Carpenter <dan.carpenter@oracle.com>
Subject: Re: [PATCH 5/5] ixgbe: add driver set_max_vfs support
Date: Wed, 3 Oct 2012 21:45:02 +0300
Message-ID: <20121003184502.GM13767@mwanda>
References: <506C3B11.9010009@redhat.com>
	<1349286695-26713-1-git-send-email-yinghai@kernel.org>
	<1349286695-26713-6-git-send-email-yinghai@kernel.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: e1000-devel@lists.sourceforge.net,
	Greg Kroah-Hartman <gregkh@linuxfoundation.org>,
	linux-kernel@vger.kernel.org,
	Jesse Brandeburg <jesse.brandeburg@intel.com>,
	John Fastabend <john.r.fastabend@intel.com>,
	yuvalmin@broadcom.com, netdev@vger.kernel.org,
	Don Dutile <ddutile@redhat.com>, linux-pci@vger.kernel.org,
	Bjorn Helgaas <bhelgaas@google.com>, bhutchings@solarflare.com,
	"David S. Miller" <davem@davemloft.net>,
	davem@davemloft.net--no-chain-reply-to
To: Yinghai Lu <yinghai@kernel.org>
Return-path: <e1000-devel-bounces@lists.sourceforge.net>
Content-Disposition: inline
In-Reply-To: <1349286695-26713-6-git-send-email-yinghai@kernel.org>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/e1000-devel>,
	<mailto:e1000-devel-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum_name=e1000-devel>
List-Post: <mailto:e1000-devel@lists.sourceforge.net>
List-Help: <mailto:e1000-devel-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/e1000-devel>,
	<mailto:e1000-devel-request@lists.sourceforge.net?subject=subscribe>
Errors-To: e1000-devel-bounces@lists.sourceforge.net
List-Id: netdev.vger.kernel.org

On Wed, Oct 03, 2012 at 10:51:35AM -0700, Yinghai Lu wrote:
> Need ixgbe guys to close the loop to use set_max_vfs instead
> kernel parameters.
> 
> Signed-off-by: Yinghai Lu <yinghai@kernel.org>
> Cc: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
> Cc: Jesse Brandeburg <jesse.brandeburg@intel.com>
> Cc: Greg Rose <gregory.v.rose@intel.com>
> Cc: "David S. Miller" <davem@davemloft.net>
> Cc: John Fastabend <john.r.fastabend@intel.com>
> Cc: e1000-devel@lists.sourceforge.net
> Cc: netdev@vger.kernel.org
> ---
>  drivers/net/ethernet/intel/ixgbe/ixgbe.h      |    2 +
>  drivers/net/ethernet/intel/ixgbe/ixgbe_main.c |   44 +++++++++++++++++++-----
>  2 files changed, 37 insertions(+), 9 deletions(-)
> 
> diff --git a/drivers/net/ethernet/intel/ixgbe/ixgbe.h b/drivers/net/ethernet/intel/ixgbe/ixgbe.h
> index b9623e9..d39d975 100644
> --- a/drivers/net/ethernet/intel/ixgbe/ixgbe.h
> +++ b/drivers/net/ethernet/intel/ixgbe/ixgbe.h
> @@ -558,6 +558,8 @@ struct ixgbe_adapter {
>  	u32 interrupt_event;
>  	u32 led_reg;
>  
> +	struct ixgbe_info *ixgbe_info;
> +
>  #ifdef CONFIG_IXGBE_PTP
>  	struct ptp_clock *ptp_clock;
>  	struct ptp_clock_info ptp_caps;
> diff --git a/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c b/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
> index ee61819..1c097c7 100644
> --- a/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
> +++ b/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
> @@ -129,13 +129,6 @@ static struct notifier_block dca_notifier = {
>  };
>  #endif
>  
> -#ifdef CONFIG_PCI_IOV
> -static unsigned int max_vfs;
> -module_param(max_vfs, uint, 0);
> -MODULE_PARM_DESC(max_vfs,
> -		 "Maximum number of virtual functions to allocate per physical function - default is zero and maximum value is 63");
> -#endif /* CONFIG_PCI_IOV */
> -
>  static unsigned int allow_unsupported_sfp;
>  module_param(allow_unsupported_sfp, uint, 0);
>  MODULE_PARM_DESC(allow_unsupported_sfp,
> @@ -4496,7 +4489,7 @@ static int __devinit ixgbe_sw_init(struct ixgbe_adapter *adapter)
>  #ifdef CONFIG_PCI_IOV
>  	/* assign number of SR-IOV VFs */
>  	if (hw->mac.type != ixgbe_mac_82598EB)
> -		adapter->num_vfs = (max_vfs > 63) ? 0 : max_vfs;
> +		adapter->num_vfs = min_t(int, pdev->max_vfs, 63);

Could we make this min_t(uint, ...);

->max_vfs is type unsigned int. We take an unsigned long from sysfs.
We silently truncate it to an unsigned int.  Then we cast it to a
negative number and compare against 63 and take the minimum...

It's root only so it's not a problem but it's a hassle to audit.

regards,
dan carpenter


------------------------------------------------------------------------------
Don't let slow site performance ruin your business. Deploy New Relic APM
Deploy New Relic app performance management and know exactly
what is happening inside your Ruby, Python, PHP, Java, and .NET app
Try New Relic at no cost today and get our sweet Data Nerd shirt too!
http://p.sf.net/sfu/newrelic-dev2dev
_______________________________________________
E1000-devel mailing list
E1000-devel@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/e1000-devel
To learn more about Intel&#174; Ethernet, visit http://communities.intel.com/community/wired
