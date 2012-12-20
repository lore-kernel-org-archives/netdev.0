From: Shmulik Ladkani <shmulik.ladkani@gmail.com>
Subject: Re: [PATCH net-next V4 03/13] bridge: Validate that vlan is
 permitted on ingress
Date: Thu, 20 Dec 2012 16:07:13 +0200
Message-ID: <20121220160713.30cdfc05@pixies.home.jungo.com>
References: <1355939304-21804-1-git-send-email-vyasevic@redhat.com>
	<1355939304-21804-4-git-send-email-vyasevic@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, shemminger@vyatta.com, davem@davemloft.net,
	or.gerlitz@gmail.com, jhs@mojatatu.com, mst@redhat.com,
	erdnetdev@gmail.com, jiri@resnulli.us
To: Vlad Yasevich <vyasevic@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-we0-f171.google.com ([74.125.82.171]:33336 "EHLO
	mail-we0-f171.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751709Ab2LTOHV (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 20 Dec 2012 09:07:21 -0500
Received: by mail-we0-f171.google.com with SMTP id u3so1637580wey.30
        for <netdev@vger.kernel.org>; Thu, 20 Dec 2012 06:07:19 -0800 (PST)
In-Reply-To: <1355939304-21804-4-git-send-email-vyasevic@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Vlad,

On Wed, 19 Dec 2012 12:48:14 -0500 Vlad Yasevich <vyasevic@redhat.com> wrote:
> +static bool br_allowed_ingress(struct net_bridge_port *p, struct sk_buff *skb)
> +{
> +	struct net_port_vlan *pve;
> +	u16 vid;
> +
> +	/* If there are no vlan in the permitted list, all packets are
> +	 * permitted.
> +	 */
> +	if (list_empty(&p->vlan_list))
> +		return true;

I assumed the default policy would be Drop in such case, otherwise
leaking between vlan domains is possible.
Or maybe, ingress policy when port isn't a member of ingress VID should
be configurable (drop/allow).

> +	vid = br_get_vlan(skb);
> +	pve = nbp_vlan_find(p, vid);

Why search by iterating through NBP's vlan_list?
You know the VID (hence may fetch the net_bridge_vlan from the hash), so
why don't you directly consult the net_bridge_vlan's port_bitmap?

> @@ -54,6 +74,9 @@ int br_handle_frame_finish(struct sk_buff *skb)
>  	if (!p || p->state == BR_STATE_DISABLED)
>  		goto drop;
>  
> +	if (!br_allowed_ingress(p, skb))
> +		goto drop;
> +

This condition should be also encorporated upon "ingress" at the "bridge
master port" (that is, early at br_dev_xmit).
Think of the "bridge master port" as yet another port:
upon "ingress" (meaning, tx packets from the ip stack), we should
also enforce any ingress permission rules.

Regards,
Shmulik
