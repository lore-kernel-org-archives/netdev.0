From: Pravin Shelar <pshelar@nicira.com>
Subject: Re: [PATCH net] openvswitch: Fix egress tunnel info.
Date: Mon, 5 Oct 2015 12:37:50 -0700
Message-ID: <CALnjE+rOO2Db-fk9zNgY6Wn1q_57Pr=ABB2vOf_L4zM_7Z8Sfw@mail.gmail.com>
References: <1444067897-1951-1-git-send-email-pshelar@nicira.com>
	<20151005204020.56f50496@griffin>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: netdev <netdev@vger.kernel.org>
To: Jiri Benc <jbenc@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-io0-f171.google.com ([209.85.223.171]:36026 "EHLO
	mail-io0-f171.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752174AbbJEThv (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 5 Oct 2015 15:37:51 -0400
Received: by ioii196 with SMTP id i196so197368144ioi.3
        for <netdev@vger.kernel.org>; Mon, 05 Oct 2015 12:37:50 -0700 (PDT)
In-Reply-To: <20151005204020.56f50496@griffin>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Oct 5, 2015 at 11:40 AM, Jiri Benc <jbenc@redhat.com> wrote:
> On Mon,  5 Oct 2015 10:58:17 -0700, Pravin B Shelar wrote:
>> --- a/drivers/net/vxlan.c
>> +++ b/drivers/net/vxlan.c
>> @@ -2337,6 +2337,51 @@ static int vxlan_change_mtu(struct net_device *dev, int new_mtu)
>>       return 0;
>>  }
>>
>> +static int egress_ipv4_tun_info(struct net_device *dev, struct sk_buff *skb,
>> +                             struct ip_tunnel_info *info,
>> +                             __be16 sport, __be16 dport,
>> +                             struct ip_tunnel_info *egress_tun_info,
>> +                             const void **egress_tun_opts)
>> +{
>> +     struct vxlan_dev *vxlan = netdev_priv(dev);
>> +     struct rtable *rt;
>> +     struct flowi4 fl4;
>> +
>> +     memset(&fl4, 0, sizeof(fl4));
>> +     fl4.flowi4_tos = RT_TOS(info->key.tos);
>> +     fl4.flowi4_mark = skb->mark;
>> +     fl4.flowi4_proto = IPPROTO_UDP;
>> +     fl4.daddr = info->key.u.ipv4.dst;
>> +
>> +     rt = ip_route_output_key(vxlan->net, &fl4);
>> +     if (IS_ERR(rt))
>> +             return PTR_ERR(rt);
>> +     ip_rt_put(rt);
>> +
>> +     ipv4_egress_info_init(egress_tun_info, egress_tun_opts, info,
>> +                           fl4.saddr, sport, dport);
>> +     return 0;
>> +}
>> +
>> +static int vxlan_egress_tun_info(struct net_device *dev, struct sk_buff *skb,
>> +                              struct ip_tunnel_info *egress_tun_info,
>> +                              const void **egress_tun_opts)
>> +{
>> +     struct ip_tunnel_info *info = skb_tunnel_info(skb);
>> +     struct vxlan_dev *vxlan = netdev_priv(dev);
>> +     __be16 sport, dport;
>> +
>> +     sport = udp_flow_src_port(dev_net(dev), skb, vxlan->cfg.port_min,
>> +                               vxlan->cfg.port_max, true);
>> +     dport = info->key.tp_dst ? : vxlan->cfg.dst_port;
>> +
>> +     if (ip_tunnel_info_af(info) == AF_INET)
>> +             return egress_ipv4_tun_info(dev, skb, info, sport, dport,
>> +                                         egress_tun_info,
>> +                                         egress_tun_opts);
>> +     return -EINVAL;
>> +}
>
> This duplicates a lot of code from vxlan_xmit_one. I think we want a
> common function (or functions) used by both this and xmit.
>

That would involve lot of refactoring vxlan xmit code. I do not want
to make such change in net tree at such late stage.
