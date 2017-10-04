From: Roopa Prabhu <roopa@cumulusnetworks.com>
Subject: Re: [Bridge] [PATCH net-next v4 1/3] bridge: add new
 BR_NEIGH_SUPPRESS port flag to suppress arp and nd flood
Date: Wed, 4 Oct 2017 09:06:53 -0700
Message-ID: <CAJieiUhjH+gLKMvQmJj12_zFOnOQCMU7CLo__8wHyd0Ngxb+xw@mail.gmail.com>
References: <1507093953-59929-1-git-send-email-roopa@cumulusnetworks.com>
 <1507093953-59929-2-git-send-email-roopa@cumulusnetworks.com> <c4a04560-07c8-7d9e-d64c-558f99cfc653@lab.ntt.co.jp>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Cc: "davem@davemloft.net" <davem@davemloft.net>,
        Nikolay Aleksandrov <nikolay@cumulusnetworks.com>,
        "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
        bridge@lists.linux-foundation.org
To: Toshiaki Makita <makita.toshiaki@lab.ntt.co.jp>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ua0-f170.google.com ([209.85.217.170]:44025 "EHLO
        mail-ua0-f170.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751120AbdJDQGy (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 4 Oct 2017 12:06:54 -0400
Received: by mail-ua0-f170.google.com with SMTP id 88so3274980uar.0
        for <netdev@vger.kernel.org>; Wed, 04 Oct 2017 09:06:54 -0700 (PDT)
In-Reply-To: <c4a04560-07c8-7d9e-d64c-558f99cfc653@lab.ntt.co.jp>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Oct 4, 2017 at 12:21 AM, Toshiaki Makita
<makita.toshiaki@lab.ntt.co.jp> wrote:
> On 2017/10/04 14:12, Roopa Prabhu wrote:
>> From: Roopa Prabhu <roopa@cumulusnetworks.com>
>>
>> This patch adds a new bridge port flag BR_NEIGH_SUPPRESS to
>> suppress arp and nd flood on bridge ports. It implements
>> rfc7432, section 10.
>> https://tools.ietf.org/html/rfc7432#section-10
>> for ethernet VPN deployments. It is similar to the existing
>> BR_ARP_PROXY flag but has a few semantic differences to conform
>> to EVPN standard. In case of EVPN, it is mainly used to
>> avoid flooding to tunnel ports like vxlan. Unlike the existing
>> flags it suppresses flood of all neigh discovery packets
>> (arp, nd) to tunnel ports.
>>
>> This patch adds netlink and sysfs support to set this bridge port
>> flag.
>>
>> Signed-off-by: Roopa Prabhu <roopa@cumulusnetworks.com>
>> ---
> ...
>> diff --git a/net/bridge/br_netlink.c b/net/bridge/br_netlink.c
>> index dea88a2..d8c2706 100644
>> --- a/net/bridge/br_netlink.c
>> +++ b/net/bridge/br_netlink.c
>> @@ -138,6 +138,7 @@ static inline size_t br_port_info_size(void)
>>               + nla_total_size(1)     /* IFLA_BRPORT_PROXYARP */
>>               + nla_total_size(1)     /* IFLA_BRPORT_PROXYARP_WIFI */
>>               + nla_total_size(1)     /* IFLA_BRPORT_VLAN_TUNNEL */
>> +             + nla_total_size(1)     /* IFLA_BRPORT_NEIGH_SUPPRESS */
>>               + nla_total_size(sizeof(struct ifla_bridge_id)) /* IFLA_BRPORT_ROOT_ID */
>>               + nla_total_size(sizeof(struct ifla_bridge_id)) /* IFLA_BRPORT_BRIDGE_ID */
>>               + nla_total_size(sizeof(u16))   /* IFLA_BRPORT_DESIGNATED_PORT */
>> @@ -210,7 +211,9 @@ static int br_port_fill_attrs(struct sk_buff *skb,
>>           nla_put_u8(skb, IFLA_BRPORT_CONFIG_PENDING, p->config_pending) ||
>>           nla_put_u8(skb, IFLA_BRPORT_VLAN_TUNNEL, !!(p->flags &
>>                                                       BR_VLAN_TUNNEL)) ||
>> -         nla_put_u16(skb, IFLA_BRPORT_GROUP_FWD_MASK, p->group_fwd_mask))
>> +         nla_put_u16(skb, IFLA_BRPORT_GROUP_FWD_MASK, p->group_fwd_mask) ||
>> +         nla_put_u8(skb, IFLA_BRPORT_NEIGH_SUPPRESS, !!(p->flags &
>> +                                                     BR_NEIGH_SUPPRESS)))
>
> Wouldn't it be better to make the indentation like this?
>
> ... !!(p->flags &
>        BR_NEIGH_SUPPRESS)))


not intentional. I think i will actually move the full condition on
the next line.

>
>>               return -EMSGSIZE;
>>
>>       timerval = br_timer_value(&p->message_age_timer);
>> @@ -692,6 +695,7 @@ static int br_setport(struct net_bridge_port *p, struct nlattr *tb[])
>>  {
>>       unsigned long old_flags = p->flags;
>>       bool br_vlan_tunnel_old = false;
>> +     int neigh_suppress_old = 0;
>>       int err;
>>
>>       err = br_set_port_flag(p, tb, IFLA_BRPORT_MODE, BR_HAIRPIN_MODE);
>> @@ -785,6 +789,12 @@ static int br_setport(struct net_bridge_port *p, struct nlattr *tb[])
>>               p->group_fwd_mask = fwd_mask;
>>       }
>>
>> +     neigh_suppress_old = (p->flags & BR_NEIGH_SUPPRESS);
>> +     br_set_port_flag(p, tb, IFLA_BRPORT_NEIGH_SUPPRESS,
>> +                      BR_NEIGH_SUPPRESS);
>> +     if (neigh_suppress_old != (p->flags & BR_NEIGH_SUPPRESS))
>> +             br_recalculate_neigh_suppress_enabled(p->br);
>> +
>
> You are calling br_recalculate_neigh_suppress_enabled() from within
> br_port_flags_change() immediately after this.
> I think you can just call br_set_port_flag() here.
>
>>       br_port_flags_change(p, old_flags ^ p->flags);
>>       return 0;
>>  }

you are right, i will remove the redundant call to recalc neigh_suppress
