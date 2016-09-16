From: =?UTF-8?B?TWFoZXNoIEJhbmRld2FyICjgpK7gpLngpYfgpLYg4KSs4KSC4KSh4KWH4KS14KS+4KSwKQ==?=
        <maheshb@google.com>
Subject: Re: [PATCHv3 next 3/3] ipvlan: Introduce l3s mode
Date: Fri, 16 Sep 2016 10:29:45 -0700
Message-ID: <CAF2d9jg4-d_CfQUO1gD269BZM1ZeZKu+QeHsJ84zK=xNqt6TCA@mail.gmail.com>
References: <1473984847-32243-1-git-send-email-mahesh@bandewar.net> <037780fb-984c-cc69-969e-2c98bc406dc9@cumulusnetworks.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Mahesh Bandewar <mahesh@bandewar.net>,
        netdev <netdev@vger.kernel.org>,
        Eric Dumazet <edumazet@google.com>,
        David Miller <davem@davemloft.net>
To: David Ahern <dsa@cumulusnetworks.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-yb0-f181.google.com ([209.85.213.181]:33109 "EHLO
        mail-yb0-f181.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753154AbcIPRaG (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 16 Sep 2016 13:30:06 -0400
Received: by mail-yb0-f181.google.com with SMTP id i66so54832004yba.0
        for <netdev@vger.kernel.org>; Fri, 16 Sep 2016 10:30:06 -0700 (PDT)
In-Reply-To: <037780fb-984c-cc69-969e-2c98bc406dc9@cumulusnetworks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Sep 15, 2016 at 6:49 PM, David Ahern <dsa@cumulusnetworks.com> wrote:
> On 9/15/16 6:14 PM, Mahesh Bandewar wrote:
>> diff --git a/drivers/net/ipvlan/ipvlan.h b/drivers/net/ipvlan/ipvlan.h
>> index 695a5dc9ace3..371f4548c42d 100644
>> --- a/drivers/net/ipvlan/ipvlan.h
>> +++ b/drivers/net/ipvlan/ipvlan.h
>> @@ -23,11 +23,13 @@
>>  #include <linux/if_vlan.h>
>>  #include <linux/ip.h>
>>  #include <linux/inetdevice.h>
>> +#include <linux/netfilter.h>
>>  #include <net/ip.h>
>>  #include <net/ip6_route.h>
>>  #include <net/rtnetlink.h>
>>  #include <net/route.h>
>>  #include <net/addrconf.h>
>> +#include <net/l3mdev.h>
>>
>>  #define IPVLAN_DRV   "ipvlan"
>>  #define IPV_DRV_VER  "0.1"
>> @@ -96,6 +98,7 @@ struct ipvl_port {
>>       struct work_struct      wq;
>>       struct sk_buff_head     backlog;
>>       int                     count;
>> +     bool                    hooks_attached;
>
> With a refcnt on the hook registration you don't need this bool and removing simplifies the set_mode logic.
>
not sure it simplifies the logic, but mode change fact can be used
instead of relying on the value of hooks_attached (so it's more
indirect).
>
>> diff --git a/drivers/net/ipvlan/ipvlan_main.c b/drivers/net/ipvlan/ipvlan_main.c
>> index 18b4e8c7f68a..aca690f41559 100644
>> --- a/drivers/net/ipvlan/ipvlan_main.c
>> +++ b/drivers/net/ipvlan/ipvlan_main.c
>
> ....
>
>> +static void ipvlan_unregister_nf_hook(void)
>> +{
>> +     BUG_ON(!ipvl_nf_hook_refcnt);
>
> not a panic() worthy issue. just a pr_warn or WARN_ON_ONCE should be ok.
>
sure, I don't think it would ever hit considering that RTNL mutex is
protecting all these updates (for now). But would definitely prefer
something there (probably WARN_ON) as a protection.
>
