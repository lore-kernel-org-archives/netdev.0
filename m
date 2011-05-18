From: Prasanna Panchamukhi <ppanchamukhi@riverbed.com>
Subject: Re: [PATCH] e100: Fix race condition in e100_down()
	while testing
Date: Tue, 17 May 2011 20:07:21 -0700
Message-ID: <4DD337E9.9080907@riverbed.com>
References: <1305670825-13603-1-git-send-email-prasanna.panchamukhi@riverbed.com>
Reply-To: prasanna.panchamukhi@riverbed.com
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: "e1000-devel@lists.sourceforge.net" <e1000-devel@lists.sourceforge.net>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"bruce.w.allan@intel.com" <bruce.w.allan@intel.com>,
	"jesse.brandeburg@intel.com" <jesse.brandeburg@intel.com>
Return-path: <e1000-devel-bounces@lists.sourceforge.net>
In-Reply-To: <1305670825-13603-1-git-send-email-prasanna.panchamukhi@riverbed.com>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/e1000-devel>,
	<mailto:e1000-devel-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum_name=e1000-devel>
List-Post: <mailto:e1000-devel@lists.sourceforge.net>
List-Help: <mailto:e1000-devel-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/e1000-devel>,
	<mailto:e1000-devel-request@lists.sourceforge.net?subject=subscribe>
Errors-To: e1000-devel-bounces@lists.sourceforge.net
List-Id: netdev.vger.kernel.org

Please ignore this, sending and updated one..

On 05/17/2011 03:20 PM, prasanna.panchamukhi@riverbed.com wrote:
> There is a race condition between e100_down() and e100_diag_test().
> During device testing e100_diag_test() ends up calling e100_up()/e100_down()
> even while the driver is already in e100_down().
> This patch fixes the above race condition by changing
> e100_up()/e100_down() to dev_open() and dev_close().
> Also fixes the race between e100_open() and e100_diag_test().
>
> Signed-off-by: Prasanna S. Panchamukh<prasanna.panchamukhi@riverbed.com>
> ---
>   drivers/net/e100.c |   21 +++++++++++++++++----
>   1 files changed, 17 insertions(+), 4 deletions(-)
>
> diff --git a/drivers/net/e100.c b/drivers/net/e100.c
> index b0aa9e6..abbf229 100644
> --- a/drivers/net/e100.c
> +++ b/drivers/net/e100.c
> @@ -425,6 +425,10 @@ enum cb_command {
>   	cb_el     = 0x8000,
>   };
>
> +enum e100_state_t {
> +	__E100_TESTING
> +};
> +
>   struct rfd {
>   	__le16 status;
>   	__le16 command;
> @@ -623,6 +627,7 @@ struct nic {
>   	__le16 eeprom[256];
>   	spinlock_t mdio_lock;
>   	const struct firmware *fw;
> +	unsigned long state;
>   };
>
>   static inline void e100_write_flush(struct nic *nic)
> @@ -2570,8 +2575,10 @@ static void e100_diag_test(struct net_device *netdev,
>   {
>   	struct ethtool_cmd cmd;
>   	struct nic *nic = netdev_priv(netdev);
> +	int if_running = netif_running(netdev);
>   	int i, err;
>
> +	set_bit(__E100_TESTING,&nic->state);
>   	memset(data, 0, E100_TEST_LEN * sizeof(u64));
>   	data[0] = !mii_link_ok(&nic->mii);
>   	data[1] = e100_eeprom_load(nic);
> @@ -2580,8 +2587,9 @@ static void e100_diag_test(struct net_device *netdev,
>   		/* save speed, duplex&  autoneg settings */
>   		err = mii_ethtool_gset(&nic->mii,&cmd);
>
> -		if (netif_running(netdev))
> -			e100_down(nic);
> +		if (if_running)
> +			/* indicate we're in test mode */
> +			dev_open(netdev);
>   		data[2] = e100_self_test(nic);
>   		data[3] = e100_loopback_test(nic, lb_mac);
>   		data[4] = e100_loopback_test(nic, lb_phy);
> @@ -2589,12 +2597,13 @@ static void e100_diag_test(struct net_device *netdev,
>   		/* restore speed, duplex&  autoneg settings */
>   		err = mii_ethtool_sset(&nic->mii,&cmd);
>
> -		if (netif_running(netdev))
> -			e100_up(nic);
> +		if (if_running)
> +			dev_open(netdev);
>   	}
>   	for (i = 0; i<  E100_TEST_LEN; i++)
>   		test->flags |= data[i] ? ETH_TEST_FL_FAILED : 0;
>
> +	clear_bit(__E100_TESTING,&nic->state);
>   	msleep_interruptible(4 * 1000);
>   }
>
> @@ -2724,6 +2733,10 @@ static int e100_open(struct net_device *netdev)
>   	struct nic *nic = netdev_priv(netdev);
>   	int err = 0;
>
> +	/* disallow open during testing */
> +	if (test_bit(__E100_TESTING,&nic->state))
> +		return -EBUSY;
> +
>   	netif_carrier_off(netdev);
>   	if ((err = e100_up(nic)))
>   		netif_err(nic, ifup, nic->netdev, "Cannot open interface, aborting\n");


------------------------------------------------------------------------------
What Every C/C++ and Fortran developer Should Know!
Read this article and learn how Intel has extended the reach of its 
next-generation tools to help Windows* and Linux* C/C++ and Fortran 
developers boost performance applications - including clusters. 
http://p.sf.net/sfu/intel-dev2devmay
_______________________________________________
E1000-devel mailing list
E1000-devel@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/e1000-devel
To learn more about Intel&#174; Ethernet, visit http://communities.intel.com/community/wired
