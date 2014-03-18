From: Li RongQing <roy.qing.li@gmail.com>
Subject: Re: [PATCH] netpoll: send arp reply on master device immediately
Date: Tue, 18 Mar 2014 08:04:38 +0800
Message-ID: <CAJFZqHz98BgYENLrHvUCw2fr40hhV7EoAirnXsaahjau+QzN9Q@mail.gmail.com>
References: <1395042106-25179-1-git-send-email-roy.qing.li@gmail.com>
	<5326ED6E.9030001@cogentembedded.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: netdev@vger.kernel.org, Cong Wang <amwang@redhat.com>,
	nhorman@tuxdriver.com
To: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qa0-f47.google.com ([209.85.216.47]:43134 "EHLO
	mail-qa0-f47.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751144AbaCRAEj (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 17 Mar 2014 20:04:39 -0400
Received: by mail-qa0-f47.google.com with SMTP id w5so6187333qac.34
        for <netdev@vger.kernel.org>; Mon, 17 Mar 2014 17:04:38 -0700 (PDT)
In-Reply-To: <5326ED6E.9030001@cogentembedded.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

this patch can be dropped since other patch has been merged into
net-next[netpoll: Remove dead packet receive code
(CONFIG_NETPOLL_TRAP)]

On Mon, Mar 17, 2014 at 8:41 PM, Sergei Shtylyov
<sergei.shtylyov@cogentembedded.com> wrote:
> Hello.
>
>
> On 17-03-2014 11:41, roy.qing.li@gmail.com wrote:
>
>> From: Li RongQing <roy.qing.li@gmail.com>
>
>
>> 1. the arp queue has been moved from slave device to master, so the
>> master device netpoll_info should be as input of service_arp_queue()
>> 2. not need to check if ni is NULL or not, since it has been used before.
>
>
>> Signed-off-by: Li RongQing <roy.qing.li@gmail.com>
>> Cc: WANG Cong <amwang@redhat.com>
>> Cc: Neil Horman <nhorman@tuxdriver.com>
>> ---
>>   net/core/netpoll.c |   26 ++++++++++++--------------
>>   1 file changed, 12 insertions(+), 14 deletions(-)
>
>
>> diff --git a/net/core/netpoll.c b/net/core/netpoll.c
>> index a664f78..dd0a796 100644
>> --- a/net/core/netpoll.c
>> +++ b/net/core/netpoll.c
>> @@ -229,21 +229,19 @@ static void netpoll_poll_dev(struct net_device *dev)
>>         up(&ni->dev_lock);
>>
>>         if (dev->flags & IFF_SLAVE) {
>
> [...]
>
>> +               struct net_device *bond_dev;
>> +               struct sk_buff *skb;
>> +               struct netpoll_info *bond_ni;
>>
>> -       service_neigh_queue(ni);
>> +               bond_dev = netdev_master_upper_dev_get_rcu(dev);
>> +               bond_ni = rcu_dereference_bh(bond_dev->npinfo);
>> +               while ((skb = skb_dequeue(&ni->neigh_tx))) {
>> +                       skb->dev = bond_dev;
>> +                       skb_queue_tail(&bond_ni->neigh_tx, skb);
>> +               }
>> +               service_neigh_queue(bond_ni);
>> +       } else
>> +               service_neigh_queue(ni);
>
>
>     The *else* branch should also have {}, according to
> Documentation/CodingStyle.
>
> WBR, Sergei
>
