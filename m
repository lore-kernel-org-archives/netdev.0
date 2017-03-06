From: Florian Fainelli <f.fainelli@gmail.com>
Subject: Re: [PATCH net-next 1/5] ldmvsw: better use of link up and down on
 ldom vswitch
Date: Mon, 6 Mar 2017 15:53:50 -0800
Message-ID: <a4a24493-913a-dd97-44cb-60ae6ef495d7@gmail.com>
References: <1488842132-512058-1-git-send-email-shannon.nelson@oracle.com>
 <1488842132-512058-2-git-send-email-shannon.nelson@oracle.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: sparclinux@vger.kernel.org, linux-kernel@vger.kernel.org
To: Shannon Nelson <shannon.nelson@oracle.com>, netdev@vger.kernel.org,
        davem@davemloft.net
Return-path: <sparclinux-owner@vger.kernel.org>
In-Reply-To: <1488842132-512058-2-git-send-email-shannon.nelson@oracle.com>
Sender: sparclinux-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 03/06/2017 03:15 PM, Shannon Nelson wrote:
> When an ldom VM is bound, the network vswitch infrastructure is set up for
> it, but was being forced 'UP' by the userland switch configuration script.
> When 'UP' but not actually connected to a running VM, the ipv6 neighbor
> probes fail (not a horrible thing) and start cluttering up the kernel logs.
> Funny thing: these are debug messages that never actually show up, but
> we do see the net_ratelimited messages that say N callbacks were
> suppressed.
> 
> This patch defers the netif_carrier_on() until an actual link has been
> established with the VM, as indicated by receiving an LDC_EVENT_UP from
> the underlying LDC protocol.  Similarly, we take the link down when we
> see the LDC_EVENT_RESET.
> 
> Orabug: 25525312
> 
> Signed-off-by: Shannon Nelson <shannon.nelson@oracle.com>
> ---
>  drivers/net/ethernet/sun/ldmvsw.c         |   10 +++++++---
>  drivers/net/ethernet/sun/sunvnet_common.c |   14 ++++++++++++++
>  2 files changed, 21 insertions(+), 3 deletions(-)
> 
> diff --git a/drivers/net/ethernet/sun/ldmvsw.c b/drivers/net/ethernet/sun/ldmvsw.c
> index 89952de..c6f6d59 100644
> --- a/drivers/net/ethernet/sun/ldmvsw.c
> +++ b/drivers/net/ethernet/sun/ldmvsw.c
> @@ -41,8 +41,8 @@
>  static u8 vsw_port_hwaddr[ETH_ALEN] = {0xFE, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF};
>  
>  #define DRV_MODULE_NAME		"ldmvsw"
> -#define DRV_MODULE_VERSION	"1.1"
> -#define DRV_MODULE_RELDATE	"February 3, 2017"
> +#define DRV_MODULE_VERSION	"1.2"
> +#define DRV_MODULE_RELDATE	"March 4, 2017"
>  
>  static char version[] =
>  	DRV_MODULE_NAME " " DRV_MODULE_VERSION " (" DRV_MODULE_RELDATE ")";
> @@ -133,7 +133,6 @@ static void vsw_poll_controller(struct net_device *dev)
>  #endif
>  
>  static const struct net_device_ops vsw_ops = {
> -	.ndo_open		= sunvnet_open_common,

Is this change intentional? It was not entirely obvious where you would
be setting ::ndo_open in other places.
-- 
Florian
