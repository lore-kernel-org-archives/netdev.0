From: Shmulik Ladkani <shmulik.ladkani@gmail.com>
Subject: Re: [PATCH net-next V6 02/14] bridge: Add vlan filtering
 infrastructure
Date: Sun, 20 Jan 2013 23:38:51 +0200
Message-ID: <20130120233851.3f589fa4.shmulik.ladkani@gmail.com>
References: <1358360289-23249-1-git-send-email-vyasevic@redhat.com>
	<1358360289-23249-3-git-send-email-vyasevic@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, bridge@lists.linux-foundation.org,
	davem@davemloft.net, shemminger@vyatta.com, mst@redhat.com
To: Vlad Yasevich <vyasevic@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f174.google.com ([209.85.212.174]:34367 "EHLO
	mail-wi0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752503Ab3ATVjC (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 20 Jan 2013 16:39:02 -0500
Received: by mail-wi0-f174.google.com with SMTP id hq4so6635440wib.1
        for <netdev@vger.kernel.org>; Sun, 20 Jan 2013 13:39:01 -0800 (PST)
In-Reply-To: <1358360289-23249-3-git-send-email-vyasevic@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Vlad,

On Wed, 16 Jan 2013 13:17:57 -0500 Vlad Yasevich <vyasevic@redhat.com> wrote:
> @@ -156,6 +183,7 @@ struct net_bridge_port
>  #ifdef CONFIG_NET_POLL_CONTROLLER
>  	struct netpoll			*np;
>  #endif
> +	struct net_port_vlans		vlan_info;

(here and at 'struct net_bridge' as well)

Not sure what the policy is; Isn't it preferred to enclose the new
fields under CONFIG_BRIDGE_VLAN_FILTERING?

> +static inline struct net_bridge *vlans_to_bridge(struct net_port_vlans *vlans)
> +{
> +	struct net_bridge *br;
> +
> +	if (!vlans->port_idx)
> +		br = container_of((vlans), struct net_bridge, vlan_info);
> +	else
> +		br = vlans_to_port(vlans)->br;
> +
> +	return br;
> +}

Guess it would simplify things if the bridge "master port" had an 'nbp'
representation of its own ;-)

> +extern struct net_bridge_vlan *br_vlan_find(struct net_bridge *br, u16 vid);

Seems 'br_vlan_find' can be declared static within br_vlan.c.

> +extern void br_vlan_flush(struct net_bridge *br);

According to your preference, consider s/br_vlan_flush/br_vlans_flush/
since it better suggest acting on all bridge's vlans.

> +extern void nbp_vlan_flush(struct net_port_vlans *vlans);

According to your preference, consider s/nbp_vlan_flush/nbp_vlans_flush/
since it better suggest acting on all port's vlans.

> +void br_vlan_flush(struct net_bridge *br)
> +{
> +	struct net_bridge_vlan *vlan;
> +	struct hlist_node *node;
> +	struct hlist_node *tmp;
> +	int i;
> +
> +	nbp_vlan_flush(&br->vlan_info);
> +
> +	/* Make sure that there are no vlans left in the bridge after
> +	* all the ports have been removed.
> +	*/

Improper indent.

> +	for (i = 0; i < BR_VID_HASH_SIZE; i++) {
> +		hlist_for_each_entry_safe(vlan, node, tmp,
> +					  &br->vlan_hlist[i], hlist) {
> +			br_vlan_del(vlan);

Can there be any vlans left at that point? Shouldn't del_nbp() on all
ports take care of that?
Also, if there _were_ any vlans left (whose bitmap isn't cleared),
'br_vlan_del' won't do a thing.
Am I missing something?

Regards,
Shmulik
