From: John Fastabend <john.fastabend@gmail.com>
Subject: Re: [PATCH net-next 1/3] net/dcb: Add IEEE QCN attribute
Date: Wed, 04 Mar 2015 09:19:34 -0800
Message-ID: <54F73EA6.2030006@gmail.com>
References: <1425473468-25969-1-git-send-email-ogerlitz@mellanox.com> <1425473468-25969-2-git-send-email-ogerlitz@mellanox.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@davemloft.net>,
	John Fastabend <john.r.fastabend@intel.com>,
	netdev@vger.kernel.org, Amir Vadai <amirv@mellanox.com>,
	Tal Alon <talal@mellanox.com>,
	Shani Michaeli <shanim@mellanox.com>,
	Shachar Raindel <raindel@mellanox.com>
To: Or Gerlitz <ogerlitz@mellanox.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ob0-f180.google.com ([209.85.214.180]:33604 "EHLO
	mail-ob0-f180.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758854AbbCDRTs (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 4 Mar 2015 12:19:48 -0500
Received: by obcvb8 with SMTP id vb8so4304276obc.0
        for <netdev@vger.kernel.org>; Wed, 04 Mar 2015 09:19:47 -0800 (PST)
In-Reply-To: <1425473468-25969-2-git-send-email-ogerlitz@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 03/04/2015 04:51 AM, Or Gerlitz wrote:
> From: Shani Michaeli <shanim@mellanox.com>
>
> As specified in 802.1Qau spec. Add this optional attribute to the
> DCB netlink layer. To allow for application to use the new attribute,
> NIC drivers should implement and register the  callbacks ieee_getqcn,
> ieee_setqcn and ieee_getqcnstats.
>
> The QCN attribute holds a set of parameters for management, and
> a set of statistics to provide informative data on Congestion-Control
> defined by this spec.
>
> Signed-off-by: Shani Michaeli <shanim@mellanox.com>
> Signed-off-by: Shachar Raindel <raindel@mellanox.com>
> Signed-off-by: Or Gerlitz <ogerlitz@mellanox.com>
> ---

Looks good to me. Do you have a QCN enabled switch? I looked at
implementing this awhile ago but didn't have any switch support so
I never did it.

Also do you have a user space client to configure this? I would like
it if someone wanted to add support to lldpad/dcbtool.

[...]

> +
> +/* This structure contains the IEEE 802.1Qau QCN managed object.
> + *
> + *@rpg_enable: enable QCN RP
> + *@rppp_max_rps: maximum number of RPs allowed for this CNPV on this port
> + *@rpg_time_reset: time between rate increases if no CNMs received.
> + *		   given in u-seconds
> + *@rpg_byte_reset: transmitted data between rate increases if no CNMs received.
> + *		   given in Bytes
> + *@rpg_threshold: The number of times rpByteStage or rpTimeStage can count
> + *		   before RP rate control state machine advances states
> + *@rpg_max_rate: the maxinun rate, in Mbits per second,
> + *		 at which an RP can transmit
> + *@rpg_ai_rate: The rate, in Mbits per second,
> + *		used to increase rpTargetRate in the RPR_ACTIVE_INCREASE
> + *@rpg_hai_rate: The rate, in Mbits per second,
> + *		 used to increase rpTargetRate in the RPR_HYPER_INCREASE state
> + *@rpg_gd: Upon CNM receive, flow rate is limited to (Fb/Gd)*CurrentRate.
> + *	   rpgGd is given as log2(Gd), where Gd may only be powers of 2
> + *@rpg_min_dec_fac: The minimum factor by which the current transmit rate
> + *		    can be changed by reception of a CNM.
> + *		    value is given as percentage (1-100)
> + *@rpg_min_rate: The minimum value, in bits per second, for rate to limit
> + *@cndd_state_machine: The state of the congestion notification domain
> + *		       defense state machine, as defined by IEEE 802.3Qau
> + *		       section 32.1.1. In the interior ready state,
> + *		       the QCN capable hardware may add CN-TAG TLV to the
> + *		       outgoing traffic, to specifically identify outgoing
> + *		       flows.
> + */

I'm assuming this structure maps to an IEEE MIB? Its a rather large
structure for a single netlink type but this seems to be how we built
the dcbnl interface and if it does seem logical that the structure is
one logical block, meaning you need to supply all fields.

[...]

>
> +	if (ops->ieee_getqcn) {
> +		struct ieee_qcn qcn;

you might consider adding a newline here it  is the best practice for
new code although dcbnl has plenty of examples where it doesn't use
this convention.


> +		memset(&qcn, 0, sizeof(qcn));
> +		err = ops->ieee_getqcn(netdev, &qcn);
> +		if (!err) {
> +			err = nla_put(skb, DCB_ATTR_IEEE_QCN,
> +				      sizeof(qcn), &qcn);
> +			if (err)
> +				return -EMSGSIZE;
> +		}
> +	}
> +
> +	if (ops->ieee_getqcnstats) {
> +		struct ieee_qcn_stats qcn_stats;

same here.

> +		memset(&qcn_stats, 0, sizeof(qcn_stats));
> +		err = ops->ieee_getqcnstats(netdev, &qcn_stats);
> +		if (!err) {
> +			err = nla_put(skb, DCB_ATTR_IEEE_QCN_STATS,
> +				      sizeof(qcn_stats), &qcn_stats);
> +			if (err)
> +				return -EMSGSIZE;
> +		}
> +	}
> +
>   	if (ops->ieee_getpfc) {
>   		struct ieee_pfc pfc;
>   		memset(&pfc, 0, sizeof(pfc));
> @@ -1379,8 +1405,9 @@ int dcbnl_cee_notify(struct net_device *dev, int event, int cmd,
>   }
>   EXPORT_SYMBOL(dcbnl_cee_notify);
>
> -/* Handle IEEE 802.1Qaz SET commands. If any requested operation can not
> - * be completed the entire msg is aborted and error value is returned.
> +/* Handle IEEE 802.1Qaz/802.1Qau/802.1Qbb SET commands.
> + * If any requested operation can not be completed
> + * the entire msg is aborted and error value is returned.
>    * No attempt is made to reconcile the case where only part of the
>    * cmd can be completed.
>    */
> @@ -1417,6 +1444,14 @@ static int dcbnl_ieee_set(struct net_device *netdev, struct nlmsghdr *nlh,
>   			goto err;
>   	}
>
> +	if (ieee[DCB_ATTR_IEEE_QCN] && ops->ieee_setqcn) {
> +		struct ieee_qcn *qcn =
> +			nla_data(ieee[DCB_ATTR_IEEE_QCN]);

same here.

> +		err = ops->ieee_setqcn(netdev, qcn);
> +		if (err)
> +			goto err;
> +	}
> +

[...]

Feel free to add my acked by if you respin it with the newlines.

Acked-by: John Fastabend <john.r.fastabend@intel.com>

-- 
John Fastabend         Intel Corporation
