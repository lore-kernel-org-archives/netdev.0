From: Vlad Yasevich <vyasevic@redhat.com>
Subject: Re: [PATCHv2] net: core: Always propagate flag changes to interfaces
Date: Tue, 19 Nov 2013 20:41:00 -0500
Message-ID: <528C132C.9070700@redhat.com>
References: <1384907865-14409-1-git-send-email-vyasevic@redhat.com>
Reply-To: vyasevic@redhat.com
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:46797 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753622Ab3KTBlB (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 19 Nov 2013 20:41:01 -0500
Received: from int-mx12.intmail.prod.int.phx2.redhat.com (int-mx12.intmail.prod.int.phx2.redhat.com [10.5.11.25])
	by mx1.redhat.com (8.14.4/8.14.4) with ESMTP id rAK1f1sY023364
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-SHA bits=256 verify=OK)
	for <netdev@vger.kernel.org>; Tue, 19 Nov 2013 20:41:01 -0500
In-Reply-To: <1384907865-14409-1-git-send-email-vyasevic@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 11/19/2013 07:37 PM, Vlad Yasevich wrote:
> The following commit:
>     b6c40d68ff6498b7f63ddf97cf0aa818d748dee7
>     net: only invoke dev->change_rx_flags when device is UP
> 
> tried to fix a problem with VLAN devices and promiscuouse flag setting.
> The issue was that VLAN device was setting a flag on an interface that
> was down, thus resulting in bad promiscuity count.
> This commit blocked flag propagation to any device that is currently
> down.
> 
> A later commit:
>     deede2fabe24e00bd7e246eb81cd5767dc6fcfc7
>     vlan: Don't propagate flag changes on down interfaces
> 
> fixed VLAN code to only propagate flags when the VLAN interface is up,
> thus fixing the same issue as above, only localized to VLAN.
> 
> The problem we have now is that if we have create a complex stack
> involving multiple software devices like bridges, bonds, and vlans,
> then it is possible that the flags would not propagate properly to
> the physical devices.  A simple examle of the scenario is the
> following:
> 
>   eth0----> bond0 ----> bridge0 ---> vlan50
> 
> If bond0 or eth0 happen to be down at the time bond0 is added to
> the bridge, then eth0 will never have promisc mode set which is
> currently required for operation as part of the bridge.  As a
> result, packets with vlan50 will be dropped by the interface.
> 
> The only 2 devices that implement the special flag handling are
> VLAN and DSA and they both have required code to prevent incorrect
> flag propagation.  As a result we can remove the generic solution
> introduced in b6c40d68ff6498b7f63ddf97cf0aa818d748dee7 and leave
> it to the individual devices to decide whether they will block
> flag propagation or not.
> 
> Reported-by: Stefan Priebe <s.priebe@profihost.ag>
> Suggested-by: Veaceslav Falico <vfalico@redhat.com>
> Signed-off-by: Vlad Yasevich <vyasevic@redhat.com>
> ---
> v1-v2: rebased on the proper net tree.
> 
>  net/core/dev.c | 6 +-----
>  1 file changed, 1 insertion(+), 5 deletions(-)
> 
> diff --git a/net/core/dev.c b/net/core/dev.c
> index 974143d..d856e34 100644
> --- a/net/core/dev.c
> +++ b/net/core/dev.c
> @@ -4991,7 +4991,7 @@ static void dev_change_rx_flags(struct net_device *dev, int flags)
>  {
>  	const struct net_device_ops *ops = dev->netdev_ops;
>  
> -	if ((dev->flags & IFF_UP) && ops->ndo_change_rx_flags)
> +	if (ops->ndo_change_rx_flags)
>  		ops->ndo_change_rx_flags(dev, flags);
>  }
>  
> @@ -6885,10 +6885,6 @@ static struct pernet_operations __net_initdata default_device_ops = {
>  	.exit = default_device_exit,
>  	.exit_batch = default_device_exit_batch,
>  };
> -
> -/*
> - *	Initialize the DEV module. At boot time this walks the device list and
> - *	unhooks any devices that fail to initialise (normally hardware not
>   *	present) and leaves us with a valid list of present and active devices.
>   *
>   */
> 
Hm.. not sure where this last hunk came from...  taking a look.  sorry
about this.

-vlad
