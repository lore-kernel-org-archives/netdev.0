From: Alexander Duyck <alexander.h.duyck@intel.com>
Subject: Re: [PATCH net-next] igbvf: do not force carrier off
	in igbvf_msix_other()
Date: Thu, 08 Aug 2013 09:09:39 -0700
Message-ID: <5203C2C3.3030205@intel.com>
References: <1375963002-1624-1-git-send-email-sassmann@kpanic.de>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: e1000-devel@lists.sourceforge.net, netdev@vger.kernel.org,
	davem@davemloft.net
To: Stefan Assmann <sassmann@kpanic.de>
Return-path: <e1000-devel-bounces@lists.sourceforge.net>
In-Reply-To: <1375963002-1624-1-git-send-email-sassmann@kpanic.de>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/e1000-devel>,
	<mailto:e1000-devel-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum_name=e1000-devel>
List-Post: <mailto:e1000-devel@lists.sourceforge.net>
List-Help: <mailto:e1000-devel-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/e1000-devel>,
	<mailto:e1000-devel-request@lists.sourceforge.net?subject=subscribe>
Errors-To: e1000-devel-bounces@lists.sourceforge.net
List-Id: netdev.vger.kernel.org

On 08/08/2013 04:56 AM, Stefan Assmann wrote:
> Currently carrier is forced off in igbvf_msix_other(). This seems
> unnecessary and causes multiple calls to igbvf_watchdog_task(), resulting
> in multiple link up messages when calling dhclient for example.
> [  111.818106] igbvf 0000:00:04.0: Link is Up 1000 Mbps Full Duplex
> [  111.819347] IPv6: ADDRCONF(NETDEV_UP): eth5: link is not ready
> [  111.820509] IPv6: ADDRCONF(NETDEV_CHANGE): eth5: link becomes ready
> [  111.822983] igbvf 0000:00:04.0: Link is Up 1000 Mbps Full Duplex
> [  115.152421] igbvf 0000:00:04.0: Link is Up 1000 Mbps Full Duplex
> compared to
> [ 1040.422161] igbvf 0000:00:04.0: Link is Up 1000 Mbps Full Duplex
> [ 1040.423447] IPv6: ADDRCONF(NETDEV_UP): eth5: link is not ready
> [ 1040.424622] IPv6: ADDRCONF(NETDEV_CHANGE): eth5: link becomes ready
> when this patch is applied.
>
> Signed-off-by: Stefan Assmann <sassmann@kpanic.de>
> ---
>  drivers/net/ethernet/intel/igbvf/netdev.c | 2 --
>  1 file changed, 2 deletions(-)
>
> diff --git a/drivers/net/ethernet/intel/igbvf/netdev.c b/drivers/net/ethernet/intel/igbvf/netdev.c
> index 93eb7ee..f041586 100644
> --- a/drivers/net/ethernet/intel/igbvf/netdev.c
> +++ b/drivers/net/ethernet/intel/igbvf/netdev.c
> @@ -876,8 +876,6 @@ static irqreturn_t igbvf_msix_other(int irq, void *data)
>  
>  	adapter->int_counter1++;
>  
> -	netif_carrier_off(netdev);
> -	hw->mac.get_link_status = 1;
>  	if (!test_bit(__IGBVF_DOWN, &adapter->state))
>  		mod_timer(&adapter->watchdog_timer, jiffies + 1);
>  

While this patch helps to squelch the messages, did you test to see what
happens if for example you bring the PF interface down while the VFs are
trying to function?  The reason for switching the carrier off is because
most interrupts on the mailbox indicate that something has been changed
in the underlying interface.  If for example the PF is about to disable
the interfaces it should be triggering this interrupt.  Otherwise you
are just setting up the VF to dump out a number of Tx hang and watchdog
messages.

Thanks,

Alex

------------------------------------------------------------------------------
Get 100% visibility into Java/.NET code with AppDynamics Lite!
It's a free troubleshooting tool designed for production.
Get down to code-level detail for bottlenecks, with <2% overhead. 
Download for free and get started troubleshooting in minutes. 
http://pubads.g.doubleclick.net/gampad/clk?id=48897031&iu=/4140/ostg.clktrk
_______________________________________________
E1000-devel mailing list
E1000-devel@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/e1000-devel
To learn more about Intel&#174; Ethernet, visit http://communities.intel.com/community/wired
