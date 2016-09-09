From: Nikolay Aleksandrov <nikolay@cumulusnetworks.com>
Subject: Re: [patch net-next v8 2/3] net: core: Add offload stats to if_stats_msg
Date: Fri, 9 Sep 2016 16:39:12 +0300
Message-ID: <72691810-B520-4E46-8B45-83C540039173@cumulusnetworks.com>
References: <1473315593-2078-1-git-send-email-jiri@resnulli.us> <1473315593-2078-3-git-send-email-jiri@resnulli.us> <0332598A-EFF4-4BB0-BDAE-6A673F54A229@cumulusnetworks.com>
Mime-Version: 1.0 (Mac OS X Mail 9.3 \(3124\))
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: quoted-printable
Cc: Jiri Pirko <jiri@resnulli.us>,
        Linux Kernel Network Developers <netdev@vger.kernel.org>,
        "David S. Miller" <davem@davemloft.net>, nogahf@mellanox.com,
        idosch@mellanox.com, eladr@mellanox.com, yotamg@mellanox.com,
        ogerlitz@mellanox.com, roopa@cumulusnetworks.com,
        linville@tuxdriver.com, tgraf@suug.ch, gospo@cumulusnetworks.com,
        sfeldma@gmail.com, sd@queasysnail.net, eranbe@mellanox.com,
        ast@plumgrid.com, edumazet@google.com, hannes@stressinduktion.org,
        f.fainelli@gmail.com, dsa@cumulusnetworks.com
To: Nikolay Aleksandrov <nikolay@cumulusnetworks.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f42.google.com ([74.125.82.42]:37522 "EHLO
        mail-wm0-f42.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750992AbcIINjK (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 9 Sep 2016 09:39:10 -0400
Received: by mail-wm0-f42.google.com with SMTP id w12so33798157wmf.0
        for <netdev@vger.kernel.org>; Fri, 09 Sep 2016 06:39:09 -0700 (PDT)
In-Reply-To: <0332598A-EFF4-4BB0-BDAE-6A673F54A229@cumulusnetworks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


> On Sep 9, 2016, at 4:36 PM, Nikolay Aleksandrov =
<nikolay@cumulusnetworks.com> wrote:
>=20
>>=20
>> On Sep 8, 2016, at 9:19 AM, Jiri Pirko <jiri@resnulli.us> wrote:
>>=20
>> From: Nogah Frankel <nogahf@mellanox.com>
>>=20
>> Add a nested attribute of offload stats to if_stats_msg
>> named IFLA_STATS_LINK_OFFLOAD_XSTATS.
>> Under it, add SW stats, meaning stats only per packets that went via
>> slowpath to the cpu, named IFLA_OFFLOAD_XSTATS_CPU_HIT.
>>=20
>> Signed-off-by: Nogah Frankel <nogahf@mellanox.com>
>> Signed-off-by: Jiri Pirko <jiri@mellanox.com>
>> ---
>> include/uapi/linux/if_link.h |  9 ++++
>> net/core/rtnetlink.c         | 97 =
++++++++++++++++++++++++++++++++++++++++++--
>> 2 files changed, 102 insertions(+), 4 deletions(-)
>>=20
> [snip]
>> @@ -3655,6 +3725,22 @@ static int rtnl_fill_statsinfo(struct sk_buff =
*skb, struct net_device *dev,
>> 		}
>> 	}
>>=20
>> +	if (stats_attr_valid(filter_mask, =
IFLA_STATS_LINK_OFFLOAD_XSTATS,
>> +			     *idxattr)) {
>> +		attr =3D nla_nest_start(skb, =
IFLA_STATS_LINK_OFFLOAD_XSTATS);
>> +		if (!attr)
>> +			goto nla_put_failure;
>> +
>> +		err =3D rtnl_get_offload_stats(skb, dev);
>> +		if (err =3D=3D -ENODATA)
>> +			nla_nest_cancel(skb, attr);
>> +		else
>> +			nla_nest_end(skb, attr);
>> +
>> +		if ((err) && (err !=3D -ENODATA))
>> +			goto nla_put_failure;
>> +	}
>> +
>=20
> Hmm, actually on a second read I think there=E2=80=99s a potential =
problem here. Since you don=E2=80=99t set *idxattr and if the space
> isn=E2=80=99t enough the dump will get restarted and this will lead to =
an infinite loop.

Err, poor choice of words. I meant the loop will be for userspace since =
the dump will err out at the same spot all the time so it
won=E2=80=99t be able to ever finish. :-)

> I.e. if the previous attributes filled the skb and there=E2=80=99s not =
enough room for this one, it will return an error
> but *idxattr will be =3D=3D 0 from the previous attribute thus the =
whole dump will be restarted (this is in case someone
> requests this attribute with some of the others of course).
>=20
> Cheers,
> Nik
>=20
>=20
>> 	nlmsg_end(skb, nlh);
>>=20
>> 	return 0;
>> @@ -3712,6 +3798,9 @@ static size_t if_nlmsg_stats_size(const struct =
net_device *dev,
>> 		}
>> 	}
>>=20
>> +	if (stats_attr_valid(filter_mask, =
IFLA_STATS_LINK_OFFLOAD_XSTATS, 0))
>> +		size +=3D rtnl_get_offload_stats_size(dev);
>> +
>> 	return size;
>> }
>>=20
>> --=20
>> 2.5.5
