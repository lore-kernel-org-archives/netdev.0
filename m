From: Joe Perches <joe@perches.com>
Subject: Re: [PATCH v2 net-next 1/2] net: use dev->name in netdev_pr* when
 it's available
Date: Thu, 17 Jul 2014 09:18:44 -0700
Message-ID: <1405613924.12363.24.camel@joe-AO725>
References: <1405606186-13703-1-git-send-email-vfalico@gmail.com>
	 <1405606186-13703-2-git-send-email-vfalico@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, "David S. Miller" <davem@davemloft.net>,
	Tom Gundersen <teg@jklm.no>
To: Veaceslav Falico <vfalico@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtprelay0098.hostedemail.com ([216.40.44.98]:44431 "EHLO
	smtprelay.hostedemail.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S965092AbaGQQSu (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 17 Jul 2014 12:18:50 -0400
In-Reply-To: <1405606186-13703-2-git-send-email-vfalico@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2014-07-17 at 16:09 +0200, Veaceslav Falico wrote:
> netdev_name() returns dev->name only when the net_device is in
> NETREG_REGISTERED state.
> 
> However, dev->name is always populated on creation, so we can easily use
> it.
> 
> There are two cases when there's no real name - when it's an empty string
> or when the name is in form of "eth%d", then netdev_name() returns "unnamed
> net_device".
> 
> CC: "David S. Miller" <davem@davemloft.net>
> CC: Tom Gundersen <teg@jklm.no>
> Signed-off-by: Veaceslav Falico <vfalico@gmail.com>
> ---
> 
> Notes:
>     v1->v2:
>     Also account for an empty string, as Tom Gundersen suggested.
> 
>  include/linux/netdevice.h | 4 ++--
>  1 file changed, 2 insertions(+), 2 deletions(-)
> 
> diff --git a/include/linux/netdevice.h b/include/linux/netdevice.h
> index 15ed750..70256aa 100644
> --- a/include/linux/netdevice.h
> +++ b/include/linux/netdevice.h
> @@ -3383,8 +3383,8 @@ extern struct pernet_operations __net_initdata loopback_net_ops;
>  
>  static inline const char *netdev_name(const struct net_device *dev)
>  {
> -	if (dev->reg_state != NETREG_REGISTERED)
> -		return "(unregistered net_device)";
> +	if (!dev->name[0] || strchr(dev->name, '%'))
> +		return "(unnamed net_device)";
>  	return dev->name;
>  }
>  

Maybe this should not be inline and become something like:

const char *netdev_name(const struct net_device *dev)
{
	if (dev->reg_state == NETREG_REGISTERED)
		return dev->name;

	if (!dev->name[0])
		return "(unnamed net_device)";

	if (!strchr(dev->name, '%'))
		return "(unregistered net_device)";

	return dev->name;
}
EXPORT_SYMBOL(netdev_name);
