From: Mike Rapoport <mike.rapoport@ravellosystems.com>
Subject: Re: [PATCH net-next v4 2/2] vxlan: allow specifying multiple default destinations
Date: Mon, 24 Jun 2013 09:58:42 +0300
Message-ID: <CAF1J0HM2vuGfVg-p8pARzOR1bz+X6bs_yMHXPBM45k4Ty9OcUA@mail.gmail.com>
References: <1372004543-24675-1-git-send-email-mike.rapoport@ravellosystems.com>
	<1372004543-24675-3-git-send-email-mike.rapoport@ravellosystems.com>
	<kq8q3h$9lu$1@ger.gmane.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: netdev@vger.kernel.org
To: Cong Wang <xiyou.wangcong@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from na3sys010aog110.obsmtp.com ([74.125.245.88]:46097 "HELO
	na3sys010aog110.obsmtp.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with SMTP id S1752495Ab3FXG6n (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 24 Jun 2013 02:58:43 -0400
Received: by mail-ob0-f169.google.com with SMTP id up14so10594440obb.0
        for <netdev@vger.kernel.org>; Sun, 23 Jun 2013 23:58:42 -0700 (PDT)
In-Reply-To: <kq8q3h$9lu$1@ger.gmane.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Jun 24, 2013 at 9:48 AM, Cong Wang <xiyou.wangcong@gmail.com> wrote:
> On Sun, 23 Jun 2013 at 16:22 GMT, Mike Rapoport <mike.rapoport@ravellosystems.com> wrote:
>>  static int vxlan_validate(struct nlattr *tb[], struct nlattr *data[])
>>  {
>> +     int err;
>> +
>>       if (tb[IFLA_ADDRESS]) {
>>               if (nla_len(tb[IFLA_ADDRESS]) != ETH_ALEN) {
>>                       pr_debug("invalid link address (not ethernet)\n");
>> @@ -1460,6 +1599,10 @@ static int vxlan_validate(struct nlattr *tb[], struct nlattr *data[])
>>               }
>>       }
>>
>> +     err = vxlan_validate_remotes(data[IFLA_VXLAN_REMOTES]);
>> +     if (err)
>> +             return err;
>> +
>>       return 0;
>>  }
>
>
> Seems you can simply return vxlan_validate_remotes(...); here.

Yes, but I believe it's better looking this way.

>> +static int vxlan_fill_remotes_info(struct sk_buff *skb,
>> +                                const struct vxlan_dev *vxlan)
>> +{
>> +     struct vxlan_rdst *rd;
>> +     struct nlattr *nest, *rdst_nest;
>> +     __be32 ip;
>> +     int i = 1;
>> +
>> +     if (!vxlan->remotes_cnt)
>> +             return 0;
>> +
>> +     nest = nla_nest_start(skb, IFLA_VXLAN_REMOTES);
>> +     if (nest == NULL)
>> +             goto nla_put_failure;
>> +
>> +     list_for_each_entry_rcu(rd, &vxlan->remotes, list) {
>
>
> Need RCU read lock here?

Why? The remotes list can be modified only via netlink with rtnl_lock held...

>
>> +             ip = rd->remote_ip;
>> +
>> +             if (ip == vxlan->default_dst.remote_ip)
>> +                     continue;
>> +
>> +             rdst_nest = nla_nest_start(skb, i);
>> +             if (rdst_nest == NULL)
>> +                     goto nla_put_failure;
>> +
>> +             if (nla_put_be32(skb, IFLA_VXLAN_REMOTE_ADDR, ip))
>> +                     goto nla_put_failure;
>> +
>> +             nla_nest_end(skb, rdst_nest);
>> +             i++;
>> +     }
>> +
>> +     nla_nest_end(skb, nest);
>> +
>> +     return 0;
>> +
>> +nla_put_failure:
>> +     return -EMSGSIZE;
>> +}
>> +
>
>
> Thanks!
>
> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html



--
Sincerely yours,
Mike.
