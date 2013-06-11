From: Ben Hutchings <bhutchings@solarflare.com>
Subject: Re: [PATCH 1/3] batman-adv: wait for rtnl in
 batadv_store_mesh_iface instead of failing if it is taken
Date: Tue, 11 Jun 2013 15:09:30 +0100
Message-ID: <1370959770.1954.3.camel@bwh-desktop.uk.level5networks.com>
References: <1370932501-3937-1-git-send-email-ordex@autistici.org>
	 <1370932501-3937-2-git-send-email-ordex@autistici.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: <davem@davemloft.net>, <netdev@vger.kernel.org>,
	<b.a.t.m.a.n@lists.open-mesh.org>,
	Matthias Schiffer <mschiffer@universe-factory.net>,
	Marek Lindner <lindner_marek@yahoo.de>
To: Antonio Quartulli <ordex@autistici.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from webmail.solarflare.com ([12.187.104.25]:34122 "EHLO
	webmail.solarflare.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751720Ab3FKOJi (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 11 Jun 2013 10:09:38 -0400
In-Reply-To: <1370932501-3937-2-git-send-email-ordex@autistici.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2013-06-11 at 08:34 +0200, Antonio Quartulli wrote:
> From: Matthias Schiffer <mschiffer@universe-factory.net>
> 
> The rtnl_lock in batadv_store_mesh_iface has been converted to a rtnl_trylock
> some time ago to avoid a possible deadlock between rtnl and s_active on removal
> of the sysfs nodes.
> 
> The behaviour introduced by that was quite confusing as it could lead to the
> sysfs store to fail, making batman-adv setup scripts unreliable.

I think what you actually wanted was ERESTARTNOINTR.  But the real
problem is that neither of these error codes is valid unless the system
call is aborted due to a signal.

Ben.

>  As recently the
> sysfs removal was postponed to a worker not running with the rtnl taken, the
> deadlock can't occur any more and it is safe to change the trylock back to a
> lock to make the sysfs store reliable again.
> 
> Signed-off-by: Matthias Schiffer <mschiffer@universe-factory.net>
> Reviewed-by: Simon Wunderlich <siwu@hrz.tu-chemnitz.de>
> Signed-off-by: Marek Lindner <lindner_marek@yahoo.de>
> Signed-off-by: Antonio Quartulli <ordex@autistici.org>
> ---
>  net/batman-adv/sysfs.c | 5 +----
>  1 file changed, 1 insertion(+), 4 deletions(-)
> 
> diff --git a/net/batman-adv/sysfs.c b/net/batman-adv/sysfs.c
> index 15a22ef..929e304 100644
> --- a/net/batman-adv/sysfs.c
> +++ b/net/batman-adv/sysfs.c
> @@ -582,10 +582,7 @@ static ssize_t batadv_store_mesh_iface(struct kobject *kobj,
>  	    (strncmp(hard_iface->soft_iface->name, buff, IFNAMSIZ) == 0))
>  		goto out;
>  
> -	if (!rtnl_trylock()) {
> -		ret = -ERESTARTSYS;
> -		goto out;
> -	}
> +	rtnl_lock();
>  
>  	if (status_tmp == BATADV_IF_NOT_IN_USE) {
>  		batadv_hardif_disable_interface(hard_iface,

-- 
Ben Hutchings, Staff Engineer, Solarflare
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.
