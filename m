From: Florian Fainelli <f.fainelli@gmail.com>
Subject: Re: [patch net-next v3 09/17] bridge: add API to notify bridge driver
 of learned FBD on offloaded device
Date: Tue, 25 Nov 2014 14:44:57 -0800
Message-ID: <54750669.4090406@gmail.com>
References: <1416911328-10979-1-git-send-email-jiri@resnulli.us> <1416911328-10979-10-git-send-email-jiri@resnulli.us>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, nhorman@tuxdriver.com, andy@greyhouse.net,
	tgraf@suug.ch, dborkman@redhat.com, ogerlitz@mellanox.com,
	jesse@nicira.com, pshelar@nicira.com, azhou@nicira.com,
	ben@decadent.org.uk, stephen@networkplumber.org,
	jeffrey.t.kirsher@intel.com, vyasevic@redhat.com,
	xiyou.wangcong@gmail.com, john.r.fastabend@intel.com,
	edumazet@google.com, jhs@mojatatu.com, sfeldma@gmail.com,
	roopa@cumulusnetworks.com, linville@tuxdriver.com,
	jasowang@redhat.com, ebiederm@xmission.com,
	nicolas.dichtel@6wind.com, ryazanov.s.a@gmail.com,
	buytenh@wantstofly.org, aviadr@mellanox.com, nbd@openwrt.org,
	alexei.starovoitov@gmail.com, Neil.Jerram@metaswitch.com,
	ronye@mellanox.com, simon.horman@netronome.com,
	alexander.h.duyck@redhat.com, john.ronciak@intel.com,
	mleitner@redhat.com, shrijeet@gmail.com, gospo@cumulusnetworks.com,
	bcrl@kvack.org
To: Jiri Pirko <jiri@resnulli.us>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f42.google.com ([209.85.220.42]:60056 "EHLO
	mail-pa0-f42.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751346AbaKYWpC (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 25 Nov 2014 17:45:02 -0500
Received: by mail-pa0-f42.google.com with SMTP id et14so1512280pad.1
        for <netdev@vger.kernel.org>; Tue, 25 Nov 2014 14:45:01 -0800 (PST)
In-Reply-To: <1416911328-10979-10-git-send-email-jiri@resnulli.us>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 25/11/14 02:28, Jiri Pirko wrote:
> From: Scott Feldman <sfeldma@gmail.com>
> 
> When the swdev device learns a new mac/vlan on a port, it sends some async
> notification to the driver and the driver installs an FDB in the device.
> To give a holistic system view, the learned mac/vlan should be reflected
> in the bridge's FBD table, so the user, using normal iproute2 cmds, can view
> what is currently learned by the device.  This API on the bridge driver gives
> a way for the swdev driver to install an FBD entry in the bridge FBD table.
> (And remove one).
> 
> This is equivalent to the device running these cmds:
> 
>   bridge fdb [add|del] <mac> dev <dev> vid <vlan id> master
> 
> This patch needs some extra eyeballs for review, in paricular around the
> locking and contexts.
> 
> Signed-off-by: Scott Feldman <sfeldma@gmail.com>
> Signed-off-by: Jiri Pirko <jiri@resnulli.us>
> ---

[snip]

> diff --git a/include/uapi/linux/neighbour.h b/include/uapi/linux/neighbour.h
> index 4a1d7e9..3a9b0df 100644
> --- a/include/uapi/linux/neighbour.h
> +++ b/include/uapi/linux/neighbour.h
> @@ -40,6 +40,7 @@ enum {
>  
>  #define NTF_SELF	0x02
>  #define NTF_MASTER	0x04
> +#define NTF_EXT_LEARNED	0x10

This file could use some re-ordering to have the constants in ascending
order.

[snip]

> +	head = &br->hash[br_mac_hash(addr, vid)];
> +	fdb = fdb_find(head, addr, vid);
> +	if (!fdb) {
> +		fdb = fdb_create(head, p, addr, vid);
> +		if (!fdb) {
> +			err = -ENOMEM;
> +			goto err_unlock;
> +		}
> +		fdb->added_by_external_learn = 1;
> +		fdb_notify(br, fdb, RTM_NEWNEIGH);
> +	} else if (fdb->added_by_external_learn) {
> +		/* Refresh entry */
> +		fdb->updated = fdb->used = jiffies;
> +	} else if (!fdb->added_by_user) {
> +		/* Take over SW learned entry */
> +		fdb->added_by_external_learn = 1;
> +		fdb->updated = jiffies;
> +		fdb_notify(br, fdb, RTM_NEWNEIGH);
> +	}

Is there any case where this fdb entry gets re-used and is no longer
added by an external learning? Should we clear this flag somewhere?

[snip]

> +EXPORT_SYMBOL(br_fdb_external_learn_del);
> diff --git a/net/bridge/br_private.h b/net/bridge/br_private.h
> index 4f577c4..02cd63b 100644
> --- a/net/bridge/br_private.h
> +++ b/net/bridge/br_private.h
> @@ -101,6 +101,7 @@ struct net_bridge_fdb_entry
>  	unsigned char			is_local;
>  	unsigned char			is_static;
>  	unsigned char			added_by_user;
> +	unsigned char			added_by_external_learn;

Pheww, we could be saving some memory footprint here by using different
types here ;)
--
Florian
