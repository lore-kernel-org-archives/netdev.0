From: David Ahern <dsahern@gmail.com>
Subject: Re: [PATCH net-next v2 1/1] bridge: return error code when deleting
 Vlan
Date: Thu, 12 Oct 2017 08:19:10 -0600
Message-ID: <fef6f65d-473c-ee8e-51cc-1382cb6f84b9@gmail.com>
References: <1507816314-2896-1-git-send-email-mrv@mojatatu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: stephen@networkplumber.org, netdev@vger.kernel.org
To: Roman Mashak <mrv@mojatatu.com>, davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f195.google.com ([209.85.192.195]:50703 "EHLO
        mail-pf0-f195.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751434AbdJLOTO (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 12 Oct 2017 10:19:14 -0400
Received: by mail-pf0-f195.google.com with SMTP id m63so5014657pfk.7
        for <netdev@vger.kernel.org>; Thu, 12 Oct 2017 07:19:14 -0700 (PDT)
In-Reply-To: <1507816314-2896-1-git-send-email-mrv@mojatatu.com>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 10/12/17 7:51 AM, Roman Mashak wrote:
> v2:
>  Return err immediately if nbp_vlan_delete() fails (pointed by David Ahern)
> 
> Signed-off-by: Roman Mashak <mrv@mojatatu.com>
> ---
>  net/bridge/br_netlink.c | 8 +++++---
>  1 file changed, 5 insertions(+), 3 deletions(-)
> 
> diff --git a/net/bridge/br_netlink.c b/net/bridge/br_netlink.c
> index f0e8268..1efdd48 100644
> --- a/net/bridge/br_netlink.c
> +++ b/net/bridge/br_netlink.c
> @@ -527,11 +527,13 @@ static int br_vlan_info(struct net_bridge *br, struct net_bridge_port *p,
>  
>  	case RTM_DELLINK:
>  		if (p) {
> -			nbp_vlan_delete(p, vinfo->vid);
> +			err = nbp_vlan_delete(p, vinfo->vid);
> +			if (err)
> +				break;

I'm not sure a break is the right thing to do. Seems like you leave it
in a half configured state.

>  			if (vinfo->flags & BRIDGE_VLAN_INFO_MASTER)
> -				br_vlan_delete(p->br, vinfo->vid);
> +				err = br_vlan_delete(p->br, vinfo->vid);
>  		} else {
> -			br_vlan_delete(br, vinfo->vid);
> +			err = br_vlan_delete(br, vinfo->vid);
>  		}
>  		break;
>  	}
> 

Why do you want to return the error code here? Walking the code paths
seems like ENOENT or err from switchdev_port_obj_del are the 2 error
possibilities.
