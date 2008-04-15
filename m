From: Patrick McHardy <kaber@trash.net>
Subject: Re: [PATCH net-2.6.26 5/10][VLAN]: Add a net argument to proc init
 and cleanup calls.
Date: Tue, 15 Apr 2008 14:26:15 +0200
Message-ID: <48049EE7.1090407@trash.net>
References: <4804989F.1060503@openvz.org> <48049B01.80403@openvz.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15; format=flowed
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>,
	Linux Netdev List <netdev@vger.kernel.org>
To: Pavel Emelyanov <xemul@openvz.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:35656 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754069AbYDOM0Z (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 15 Apr 2008 08:26:25 -0400
In-Reply-To: <48049B01.80403@openvz.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Pavel Emelyanov wrote:
> All proc files will be created in each net, so prepare them for 
> this change now, not to mess it with real creation patch.
> 
> The net != &init_net checks in them are for git-bisect sanity, 
> but I will drop them soon.
> 
> Signed-off-by: Pavel Emelyanov <xemul@openvz.org>
> 
> ---
>  net/8021q/vlan.c     |   15 +++++++--------
>  net/8021q/vlanproc.c |   12 +++++++++---
>  net/8021q/vlanproc.h |   10 ++++++----
>  3 files changed, 22 insertions(+), 15 deletions(-)
> 
> diff --git a/net/8021q/vlan.c b/net/8021q/vlan.c
> index 9296601..541542e 100644
> --- a/net/8021q/vlan.c
> +++ b/net/8021q/vlan.c
> @@ -642,8 +642,14 @@ static int vlan_init_net(struct net *net)
>  	if (err < 0)
>  		goto err_assign;
>  
> +	err = vlan_proc_init(net);
> +	if (err < 0)
> +		goto err_proc;
> +
>  	return 0;
>  
> +err_proc:
> +	/* nothing */

What is going to clean up net_generic_assign above?

>  err_assign:
>  	kfree(vn);
>  err_alloc:
> @@ -655,6 +661,7 @@ static void vlan_exit_net(struct net *net)
>  	struct vlan_net *vn;
>  
>  	vn = net_generic(net, vlan_net_id);
> +	vlan_proc_cleanup(net);
>  	kfree(vn);
>  }
>  
> @@ -674,10 +681,6 @@ static int __init vlan_proto_init(void)
>  	if (err < 0)
>  		goto err0;
>  
> -	err = vlan_proc_init();
> -	if (err < 0)
> -		goto err1;
> -
>  	err = register_netdevice_notifier(&vlan_notifier_block);
>  	if (err < 0)
>  		goto err2;
> @@ -693,8 +696,6 @@ static int __init vlan_proto_init(void)
>  err3:
>  	unregister_netdevice_notifier(&vlan_notifier_block);
>  err2:
> -	vlan_proc_cleanup();
> -err1:
>  	unregister_pernet_gen_device(vlan_net_id, &vlan_net_ops);
>  err0:
>  	return err;

This could be done nicer, not leaving holes in the numbering.
