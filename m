From: Nikolay Aleksandrov <nikolay@cumulusnetworks.com>
Subject: Re: [patch net-next v9 2/3] net: core: Add offload stats to if_stats_msg
Date: Fri, 16 Sep 2016 11:00:46 +0300
Message-ID: <6226A529-D83B-4B77-8091-E6E8528B0063@cumulusnetworks.com>
References: <1473845322-16679-1-git-send-email-jiri@resnulli.us> <1473845322-16679-3-git-send-email-jiri@resnulli.us>
Mime-Version: 1.0 (Mac OS X Mail 9.3 \(3124\))
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: quoted-printable
Cc: Linux Kernel Network Developers <netdev@vger.kernel.org>,
        "David S. Miller" <davem@davemloft.net>, nogahf@mellanox.com,
        Ido Schimmel <idosch@mellanox.com>, eladr@mellanox.com,
        yotamg@mellanox.com, ogerlitz@mellanox.com,
        Roopa Prabhu <roopa@cumulusnetworks.com>,
        linville@tuxdriver.com, tgraf@suug.ch,
        Andy Gospodarek <gospo@cumulusnetworks.com>, sfeldma@gmail.com,
        sd@queasysnail.net, eranbe@mellanox.com, ast@plumgrid.com,
        edumazet@google.com, hannes@stressinduktion.org,
        f.fainelli@gmail.com, dsa@cumulusnetworks.com
To: Jiri Pirko <jiri@resnulli.us>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f46.google.com ([74.125.82.46]:38349 "EHLO
        mail-wm0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1757792AbcIPIAr (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 16 Sep 2016 04:00:47 -0400
Received: by mail-wm0-f46.google.com with SMTP id 1so25942958wmz.1
        for <netdev@vger.kernel.org>; Fri, 16 Sep 2016 01:00:46 -0700 (PDT)
In-Reply-To: <1473845322-16679-3-git-send-email-jiri@resnulli.us>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


> On Sep 14, 2016, at 12:28 PM, Jiri Pirko <jiri@resnulli.us> wrote:
>=20
> From: Nogah Frankel <nogahf@mellanox.com>
>=20
> Add a nested attribute of offload stats to if_stats_msg
> named IFLA_STATS_LINK_OFFLOAD_XSTATS.
> Under it, add SW stats, meaning stats only per packets that went via
> slowpath to the cpu, named IFLA_OFFLOAD_XSTATS_CPU_HIT.
>=20
> Signed-off-by: Nogah Frankel <nogahf@mellanox.com>
> Signed-off-by: Jiri Pirko <jiri@mellanox.com>
> ---
> include/uapi/linux/if_link.h |   9 ++++
> net/core/rtnetlink.c         | 111 =
+++++++++++++++++++++++++++++++++++++++++--
> 2 files changed, 116 insertions(+), 4 deletions(-)
>=20
[snip]
> @@ -3655,6 +3737,24 @@ static int rtnl_fill_statsinfo(struct sk_buff =
*skb, struct net_device *dev,
> 		}
> 	}
>=20
> +	if (stats_attr_valid(filter_mask, =
IFLA_STATS_LINK_OFFLOAD_XSTATS,
> +			     *idxattr)) {
> +		*idxattr =3D IFLA_STATS_LINK_OFFLOAD_XSTATS;
> +		attr =3D nla_nest_start(skb, =
IFLA_STATS_LINK_OFFLOAD_XSTATS);
> +		if (!attr)
> +			goto nla_put_failure;
> +
> +		err =3D rtnl_get_offload_stats(skb, dev, prividx);
> +		if (err =3D=3D -ENODATA)
> +			nla_nest_cancel(skb, attr);
> +		else
> +			nla_nest_end(skb, attr);
> +
> +		if ((err) && (err !=3D -ENODATA))
                       ^^^^       ^^^^^^^^^^^^^^^^^^
The extra braces are still there. [1]
The rest looks good to me.

Thanks,
 Nik

[1] http://www.spinics.net/lists/netdev/msg394257.html

> +			goto nla_put_failure;
> +		*idxattr =3D 0;
> +	}
> +
> 	nlmsg_end(skb, nlh);
>=20
> 	return 0;
> @@ -3708,6 +3808,9 @@ static size_t if_nlmsg_stats_size(const struct =
net_device *dev,
> 		}
> 	}
>=20
> +	if (stats_attr_valid(filter_mask, =
IFLA_STATS_LINK_OFFLOAD_XSTATS, 0))
> +		size +=3D rtnl_get_offload_stats_size(dev);
> +
> 	return size;
> }
>=20
> --=20
> 2.5.5
>=20
