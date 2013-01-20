From: Shmulik Ladkani <shmulik.ladkani@gmail.com>
Subject: Re: [PATCH net-next V6 03/14] bridge: Validate that vlan is
 permitted on ingress
Date: Mon, 21 Jan 2013 00:27:10 +0200
Message-ID: <20130121002710.5189a959.shmulik.ladkani@gmail.com>
References: <1358360289-23249-1-git-send-email-vyasevic@redhat.com>
	<1358360289-23249-4-git-send-email-vyasevic@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, bridge@lists.linux-foundation.org,
	davem@davemloft.net, shemminger@vyatta.com, mst@redhat.com
To: Vlad Yasevich <vyasevic@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ea0-f196.google.com ([209.85.215.196]:62831 "EHLO
	mail-ea0-f196.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752522Ab3ATW1U (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 20 Jan 2013 17:27:20 -0500
Received: by mail-ea0-f196.google.com with SMTP id e13so1035008eaa.7
        for <netdev@vger.kernel.org>; Sun, 20 Jan 2013 14:27:19 -0800 (PST)
In-Reply-To: <1358360289-23249-4-git-send-email-vyasevic@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Vlad,

On Wed, 16 Jan 2013 13:17:58 -0500 Vlad Yasevich <vyasevic@redhat.com> wrote:
> @@ -45,6 +45,9 @@ netdev_tx_t br_dev_xmit(struct sk_buff *skb, struct net_device *dev)
>  	brstats->tx_bytes += skb->len;
>  	u64_stats_update_end(&brstats->syncp);
>  
> +	if (!br_allowed_ingress(&br->vlan_info, skb))
> +		goto out;
> +

Shouldn't you consume the 'skb' in case "not allowed"? the 'out' label
doesn't take care of that.

> +bool br_allowed_ingress(struct net_port_vlans *v, struct sk_buff *skb)
> +{
> +	struct net_port_vlan *pve;
> +	u16 vid;
> +
> +	/* If there are no vlan in the permitted list, all packets are
> +	 * permitted.
> +	 */
> +	if (list_empty(&v->vlan_list))
> +		return true;

Rethinking this, after discussed at [1].
The above means the port having no vlans is actually a member of every
possible vlan.
IMO it might not be what users expect, and may complicate things.

Maybe we should adapt a simpler approach:
If the bridge is a vlan enabled bridge, and the port is not a member of
the given vid, drop.
If the bridge is "vlan disabled", then all packets are permitted.

Regards,
Shmulik

[1]
http://marc.info/?l=linux-netdev&m=135602065425514&w=2
