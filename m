From: David Stevens <dlstevens@us.ibm.com>
Subject: Re: [PATCH v3 1/1] igmp: call ip_mc_clear_src() only when we have no users
 of ip_mc_list
Date: Mon, 23 May 2011 10:41:03 -0700
Message-ID: <OF8F2A5C61.8060D0CC-ON88257899.00610B06-88257899.006123E3@us.ibm.com>
References: <20110515165945.GA20024@darkmag.usersys.redhat.com> <20110516.140359.111037536766782557.davem@davemloft.net> <OF948388D5.90B3F5A7-ON88257892.006C3228-88257892.0071B9D5@us.ibm.com> <20110517133801.GC30366@darkmag.usersys.redhat.com> <20110517143756.GE30366@darkmag.usersys.redhat.com> <OF11F57B2A.6B43B7E6-ON88257893.005490B0-88257893.00615176@us.ibm.com> <20110520162709.GA3497@darkmag.usersys.redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Cc: David Miller <davem@davemloft.net>, jmorris@namei.org,
	kaber@trash.net, kuznet@ms2.inr.ac.ru,
	linux-kernel@vger.kernel.org, mmarek@suse.cz,
	netdev@vger.kernel.org, netdev-owner@vger.kernel.org,
	pekkas@netcore.fi, yoshfuji@linux-ipv6.org
To: Veaceslav Falico <vfalico@redhat.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20110520162709.GA3497@darkmag.usersys.redhat.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

netdev-owner@vger.kernel.org wrote on 05/20/2011 09:27:09 AM:

> From: Veaceslav Falico <vfalico@redhat.com>

Looks ok to me:

Acked-by: David L Stevens <dlstevens@us.ibm.com>

> 
> So, does this patch seem ok? If yes, I'll send it with the changelog.
> 
> ---
> diff --git a/net/ipv4/igmp.c b/net/ipv4/igmp.c
> index 1fd3d9c..57ca93a 100644
> --- a/net/ipv4/igmp.c
> +++ b/net/ipv4/igmp.c
> @@ -1169,20 +1169,18 @@ static void igmp_group_dropped(struct ip_mc_list 
*im)
> 
>     if (!in_dev->dead) {
>        if (IGMP_V1_SEEN(in_dev))
> -         goto done;
> +         return;
>        if (IGMP_V2_SEEN(in_dev)) {
>           if (reporter)
>              igmp_send_report(in_dev, im, IGMP_HOST_LEAVE_MESSAGE);
> -         goto done;
> +         return;
>        }
>        /* IGMPv3 */
>        igmpv3_add_delrec(in_dev, im);
> 
>        igmp_ifc_event(in_dev);
>     }
> -done:
>  #endif
> -   ip_mc_clear_src(im);
>  }
> 
>  static void igmp_group_added(struct ip_mc_list *im)
> @@ -1319,6 +1317,7 @@ void ip_mc_dec_group(struct in_device *in_dev,
> __be32 addr)
>              *ip = i->next_rcu;
>              in_dev->mc_count--;
>              igmp_group_dropped(i);
> +            ip_mc_clear_src(i);
> 
>              if (!in_dev->dead)
>                 ip_rt_multicast_event(in_dev);
> @@ -1428,7 +1427,8 @@ void ip_mc_destroy_dev(struct in_device *in_dev)
>        in_dev->mc_list = i->next_rcu;
>        in_dev->mc_count--;
> 
> -      igmp_group_dropped(i);
> +      /* We've dropped the groups in ip_mc_down already */
> +      ip_mc_clear_src(i);
>        ip_ma_put(i);
>     }
>  }
> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
