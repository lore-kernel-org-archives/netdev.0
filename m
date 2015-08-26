From: Vlad Yasevich <vyasevic@redhat.com>
Subject: Re: [PATCH net-next] bridge: vlan: allow to suppress local mac install
 for all vlans
Date: Wed, 26 Aug 2015 08:42:22 -0400
Message-ID: <55DDB42E.5010802@redhat.com>
References: <1440464127-27391-1-git-send-email-razor@blackwall.org>
Reply-To: vyasevic@redhat.com
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Cc: toshiaki.makita1@gmail.com, stephen@networkplumber.org,
	bridge@lists.linux-foundation.org, wkok@cumulusnetworks.com,
	davem@davemloft.net,
	Nikolay Aleksandrov <nikolay@cumulusnetworks.com>
To: Nikolay Aleksandrov <razor@blackwall.org>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:43057 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751798AbbHZMmZ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 26 Aug 2015 08:42:25 -0400
In-Reply-To: <1440464127-27391-1-git-send-email-razor@blackwall.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 08/24/2015 08:55 PM, Nikolay Aleksandrov wrote:
> From: Nikolay Aleksandrov <nikolay@cumulusnetworks.com>
> 
> This patch adds a new knob that, when enabled, allows to suppress the
> installation of local fdb entries in newly created vlans. This could
> pose a big scalability issue if we have a large number of ports and a
> large number of vlans, e.g. in a 48 port device with 2000 vlans these
> entries easily go up to 96000.
> Note that packets for these macs are still received properly because they
> are added in vlan 0 as "own" macs and referenced when fdb lookup by vlan
> results in a miss.
> Also note that vlan membership of ingress port and the bridge device
> as egress are still being correctly enforced.
> 
> The default (0/off) is keeping the current behaviour.
> 
> Based on a patch by Wilson Kok (wkok@cumulusnetworks.com).
> 
> Signed-off-by: Nikolay Aleksandrov <nikolay@cumulusnetworks.com>
> ---
> As usual I'll post iproute2 patch if this one gets accepted.
> 

... snip...

> diff --git a/net/bridge/br_vlan.c b/net/bridge/br_vlan.c
> index 3cef6892c0bb..f9efa1b07994 100644
> --- a/net/bridge/br_vlan.c
> +++ b/net/bridge/br_vlan.c
> @@ -98,11 +98,12 @@ static int __vlan_add(struct net_port_vlans *v, u16 vid, u16 flags)
>  			return err;
>  	}
>  
> -	err = br_fdb_insert(br, p, dev->dev_addr, vid);
> -	if (err) {
> -		br_err(br, "failed insert local address into bridge "
> -		       "forwarding table\n");
> -		goto out_filt;
> +	if (!br_vlan_ignore_local_fdb(br) || !v->port_idx) {
> +		err = br_fdb_insert(br, p, dev->dev_addr, vid);
> +		if (err) {
> +			br_err(br, "failed insert local address into bridge forwarding table\n");
> +			goto out_filt;
> +		}
>  	}
>

One question.  Does it make sense to push this down into br_fdb_insert?
This patch prevents automatic entries from being added.  But what about
manual entries for a local fdb?  The code in br_fdb_add() will still a
vid 0 entry as well as entries for all vlans currently configured on the port.

-vlad

>  	set_bit(vid, v->vlan_bitmap);
> @@ -492,6 +493,13 @@ int br_vlan_filter_toggle(struct net_bridge *br, unsigned long val)
>  	return 0;
>  }
>  
> +int br_vlan_ignore_local_fdb_toggle(struct net_bridge *br, unsigned long val)
> +{
> +	br->vlan_ignore_local_fdb = val ? true : false;
> +
> +	return 0;
> +}
> +
>  int br_vlan_set_proto(struct net_bridge *br, unsigned long val)
>  {
>  	int err = 0;
> 
