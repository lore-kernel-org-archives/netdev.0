From: David Miller <davem@davemloft.net>
Subject: Re: [patch net-next 2/4] rtnetlink: add HW/SW stats distinction in
 rtnl_fill_stats
Date: Thu, 12 May 2016 11:51:11 -0400 (EDT)
Message-ID: <20160512.115111.1092968654376249787.davem@davemloft.net>
References: <1463053730-14991-1-git-send-email-jiri@resnulli.us>
	<1463053730-14991-3-git-send-email-jiri@resnulli.us>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, nogahf@mellanox.com, idosch@mellanox.com,
	eladr@mellanox.com, yotamg@mellanox.com, ogerlitz@mellanox.com,
	roopa@cumulusnetworks.com, nikolay@cumulusnetworks.com,
	linville@tuxdriver.com, tgraf@suug.ch, gospo@cumulusnetworks.com,
	sfeldma@gmail.com, sd@queasysnail.net, eranbe@mellanox.com,
	ast@plumgrid.com, edumazet@google.com, hannes@stressinduktion.org
To: jiri@resnulli.us
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:57768 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932297AbcELPvT (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 12 May 2016 11:51:19 -0400
In-Reply-To: <1463053730-14991-3-git-send-email-jiri@resnulli.us>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jiri Pirko <jiri@resnulli.us>
Date: Thu, 12 May 2016 13:48:48 +0200

>  	sp = nla_data(attr);
>  	dev_get_stats(dev, sp);
>  
> +	err = dev_get_sw_stats(dev, &sw_stats);
> +	if (!err) {
> +		attr = nla_reserve_64bit(skb, IFLA_SW_STATS64,
> +					 sizeof(struct rtnl_link_stats64),
> +					 IFLA_PAD);
> +
> +		if (!attr)
> +			return -EMSGSIZE;
> +
> +		copy_rtnl_link_stats64(nla_data(attr), &sw_stats);
> +	}

Jiri, the whole point of the 64-bit padding stuff is so that we don't
need to copy the stats twice, once onto an on-stack copy and then
again to the attribute.

The way this sw stats stuff is designed you can't do it right.  It is
absolutely essential that the nla_reserve_64bits() call occur first,
and then you pass nla_data(attr) directly into the sw stats NDO operation.

Please rearrange this whole mechanism so that you can pass the NLA
attribute pointer down into the driver rather than doing all of these
copies.

Thanks.
