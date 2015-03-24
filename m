From: Mahesh Bandewar <maheshb@google.com>
Subject: Re: [PATCH net] ipvlan: fix addr hash list corruption
Date: Tue, 24 Mar 2015 16:16:38 -0700
Message-ID: <CAF2d9jh+VozezamrEK_6vfTvY8LZSzw9n-bJjSX3G11RXmfz3w@mail.gmail.com>
References: <2ca7312e5e3df10ce129315f89c3ab5d82d4d428.1427145009.git.jbenc@redhat.com>
 <20150324.130037.1897087027068811494.davem@davemloft.net> <20150324180628.278017fb@griffin>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: David Miller <davem@davemloft.net>,
	linux-netdev <netdev@vger.kernel.org>, dcbw@redhat.com
To: Jiri Benc <jbenc@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ob0-f174.google.com ([209.85.214.174]:34671 "EHLO
	mail-ob0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751803AbbCXXQ7 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 24 Mar 2015 19:16:59 -0400
Received: by obbgg8 with SMTP id gg8so6560195obb.1
        for <netdev@vger.kernel.org>; Tue, 24 Mar 2015 16:16:58 -0700 (PDT)
In-Reply-To: <20150324180628.278017fb@griffin>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Mar 24, 2015 at 10:06 AM, Jiri Benc <jbenc@redhat.com> wrote:
> On Tue, 24 Mar 2015 13:00:37 -0400 (EDT), David Miller wrote:
>> From: Jiri Benc <jbenc@redhat.com>
>> Date: Mon, 23 Mar 2015 22:10:19 +0100
>>
>> > @@ -504,7 +504,8 @@ static void ipvlan_link_delete(struct net_device *dev, struct list_head *head)
>> >
>> >     if (ipvlan->ipv6cnt > 0 || ipvlan->ipv4cnt > 0) {
>> >             list_for_each_entry_safe(addr, next, &ipvlan->addrs, anode) {
>> > -                   ipvlan_ht_addr_del(addr, !dev->dismantle);
>> > +                   if (netif_running(dev))
>> > +                           ipvlan_ht_addr_del(addr, !dev->dismantle);
>> >                     list_del_rcu(&addr->anode);
>> >             }
>> >     }
>>
>> This is so error prone, because you are depending upon so many implementation
>> details to infer a boolean state "is this address hashed".
>>
>> So just add the boolean state to struct ipvl_addr, and manage it in
>> the ipvlan_ht_addr_{add,del}() code.
>
> I had that originally but then decided to go with smaller memory
> footprint. Which obviously doesn't matter much here. I'll send v2 with
> the boolean state.
>
Hi Jiri,

Well, we already have hlist_unhashed().The following patch should fix
the duplicate addition as well as deletion. Please give it a try.

diff --git a/drivers/net/ipvlan/ipvlan_core.c b/drivers/net/ipvlan/ipvlan_core.c
index 2a175006028b..8a542b9340c4 100644
--- a/drivers/net/ipvlan/ipvlan_core.c
+++ b/drivers/net/ipvlan/ipvlan_core.c
@@ -81,12 +81,13 @@ void ipvlan_ht_addr_add(struct ipvl_dev *ipvlan,
struct ipvl_addr *addr)
        hash = (addr->atype == IPVL_IPV6) ?
               ipvlan_get_v6_hash(&addr->ip6addr) :
               ipvlan_get_v4_hash(&addr->ip4addr);
-       hlist_add_head_rcu(&addr->hlnode, &port->hlhead[hash]);
+       if (hlist_unhashed(&addr->hlnode))
+               hlist_add_head_rcu(&addr->hlnode, &port->hlhead[hash]);
 }

 void ipvlan_ht_addr_del(struct ipvl_addr *addr, bool sync)
 {
-       hlist_del_rcu(&addr->hlnode);
+       hlist_del_init_rcu(&addr->hlnode);
        if (sync)
                synchronize_rcu();
 }

Thanks,
--mahesh..
>  Jiri
>
> --
> Jiri Benc
