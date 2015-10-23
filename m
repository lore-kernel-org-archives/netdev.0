From: Andrew Cooper <andrew.cooper3@citrix.com>
Subject: Re: [Xen-devel] [PATCH V3 1/2] xen-netback: limit xen vif max queues
 number to online cpus
Date: Fri, 23 Oct 2015 10:51:59 +0100
Message-ID: <562A033F.10702@citrix.com>
References: <562A0108.3070501@oracle.com> <562A018C.9060708@oracle.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="windows-1252"
Content-Transfer-Encoding: 7bit
Cc: <netdev@vger.kernel.org>, <xen-devel@lists.xenproject.org>
To: Joe Jin <joe.jin@oracle.com>, <wei.liu2@citrix.com>,
	Ian Campbell <ian.campbell@citrix.com>,
	Boris Ostrovsky <boris.ostrovsky@oracle.com>,
	Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>,
	"David S. Miller" <davem@davemloft.net>,
	Jan Beulich <JBeulich@suse.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.citrix.com ([66.165.176.63]:17680 "EHLO SMTP02.CITRIX.COM"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750825AbbJWJwC (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 23 Oct 2015 05:52:02 -0400
In-Reply-To: <562A018C.9060708@oracle.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 23/10/15 10:44, Joe Jin wrote:
> Should not allocate xen vif queues number more than online cpus.
>
> Signed-off-by: Joe Jin <joe.jin@oracle.com>
> Cc: Jan Beulich <JBeulich@suse.com>
> Cc: Wei Liu <wei.liu2@citrix.com>
> Cc: Ian Campbell <ian.campbell@citrix.com>
> Cc: Boris Ostrovsky <boris.ostrovsky@oracle.com>
> Cc: Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>
> ---
>  drivers/net/xen-netback/netback.c |   28 ++++++++++++++++++++++------
>  1 files changed, 22 insertions(+), 6 deletions(-)
>
> diff --git a/drivers/net/xen-netback/netback.c b/drivers/net/xen-netback/netback.c
> index ec98d43..021dcb0 100644
> --- a/drivers/net/xen-netback/netback.c
> +++ b/drivers/net/xen-netback/netback.c
> @@ -68,7 +68,9 @@ unsigned int rx_stall_timeout_msecs = 60000;
>  module_param(rx_stall_timeout_msecs, uint, 0444);
>  
>  unsigned int xenvif_max_queues;
> -module_param_named(max_queues, xenvif_max_queues, uint, 0644);
> +static int xennet_set_max_queues(const char *val, struct kernel_param *kp);
> +module_param_call(max_queues, xennet_set_max_queues, param_get_uint,
> +		  &xenvif_max_queues, 0644);
>  MODULE_PARM_DESC(max_queues,
>  		 "Maximum number of queues per virtual interface");
>  
> @@ -107,6 +109,20 @@ static struct xen_netif_rx_response *make_rx_response(struct xenvif_queue *queue
>  					     u16      size,
>  					     u16      flags);
>  
> +static int xennet_set_max_queues(const char *val, struct kernel_param *kp)
> +{
> +	unsigned int cpus = num_online_cpus();

This calculation is problematic in the scenario where a guest boots up,
then has more cpus hotplugged in, then wants to set up a sensible number
of queues.

~Andrew
