From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net-next v2] net: dev: fix the incorrect hold of net
 namespace's lo device
Date: Fri, 24 Aug 2012 06:56:22 +0200
Message-ID: <1345784182.5904.1920.camel@edumazet-glaptop>
References: <1345772215-30379-1-git-send-email-gaofeng@cn.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, netdev@vger.kernel.org,
	"Eric W. Biederman" <ebiederm@xmission.com>
To: Gao feng <gaofeng@cn.fujitsu.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wg0-f44.google.com ([74.125.82.44]:49527 "EHLO
	mail-wg0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750847Ab2HXE40 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 24 Aug 2012 00:56:26 -0400
Received: by wgbdr13 with SMTP id dr13so1176963wgb.1
        for <netdev@vger.kernel.org>; Thu, 23 Aug 2012 21:56:25 -0700 (PDT)
In-Reply-To: <1345772215-30379-1-git-send-email-gaofeng@cn.fujitsu.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 2012-08-24 at 09:36 +0800, Gao feng wrote:
> When moving a net device from one net namespace to another
> net namespace,dev_change_net_namespace calls NETDEV_DOWN
> event,so the original net namespace's dst entries which
> beloned to this net device will be put into dst_garbage
> list.
> 
> then dev_change_net_namespace will set this net device's
> net to the new net namespace.
> 
> If we unregister this net device's driver, this will trigger
> the NETDEV_UNREGISTER_FINAL event, dst_ifdown will be called,
> and get this net device's dst entries from dst_garbage list,
> put these entries' dev to the new net namespace's lo device.
> 
> It's not what we want,actually we need these dst entries hold
> the original net namespace's lo device,this incorrect device
> holding will trigger emg message like below.
> unregister_netdevice: waiting for lo to become free. Usage count = 1
> 
> so we should call NETDEV_UNREGISTER_FINAL event in
> dev_change_net_namespace too,in order to make sure dst entries
> already in the dst_garbage list, we need rcu_barrier before we
> call NETDEV_UNREGISTER_FINAL event.
> 
> With help form Eric Dumazet.
> 
> Signed-off-by: Gao feng <gaofeng@cn.fujitsu.com>
> Cc: Eric Dumazet <eric.dumazet@gmail.com>
> Cc: "Eric W. Biederman" <ebiederm@xmission.com>
> ---
>  net/core/dev.c |    2 ++
>  1 files changed, 2 insertions(+), 0 deletions(-)
> 
> diff --git a/net/core/dev.c b/net/core/dev.c
> index bc857fe..6956d4c 100644
> --- a/net/core/dev.c
> +++ b/net/core/dev.c
> @@ -6256,6 +6256,8 @@ int dev_change_net_namespace(struct net_device *dev, struct net *net, const char
>  	   the device is just moving and can keep their slaves up.
>  	*/
>  	call_netdevice_notifiers(NETDEV_UNREGISTER, dev);
> +	rcu_barrier();
> +	call_netdevice_notifiers(NETDEV_UNREGISTER_FINAL, dev);
>  	rtmsg_ifinfo(RTM_DELLINK, dev, ~0U);
>  
>  	/*

Acked-by: Eric Dumazet <edumazet@google.com>

Thanks !
