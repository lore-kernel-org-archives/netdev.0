From: Mahesh Bandewar <maheshb@google.com>
Subject: Re: [PATCH net-next 4/4] bonding: Do not ignore notifications for ARP-work-queue
Date: Thu, 12 Mar 2015 19:03:48 -0700
Message-ID: <CAF2d9jjJEUSxX+9kbRx9=yBbkKKyt7mc1_2u-GdgMppr42-R=g@mail.gmail.com>
References: <1426139679-27249-1-git-send-email-maheshb@google.com> <5501BAE9.1000102@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Jay Vosburgh <j.vosburgh@gmail.com>,
	Andy Gospodarek <andy@greyhouse.net>,
	Veaceslav Falico <vfalico@gmail.com>,
	David Miller <davem@davemloft.net>,
	Maciej Zenczykowski <maze@google.com>,
	netdev <netdev@vger.kernel.org>,
	Eric Dumazet <edumazet@google.com>
To: Nikolay Aleksandrov <nikolay@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-oi0-f54.google.com ([209.85.218.54]:43351 "EHLO
	mail-oi0-f54.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752286AbbCMCEJ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 12 Mar 2015 22:04:09 -0400
Received: by oibg201 with SMTP id g201so17831466oib.10
        for <netdev@vger.kernel.org>; Thu, 12 Mar 2015 19:04:08 -0700 (PDT)
In-Reply-To: <5501BAE9.1000102@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Mar 12, 2015 at 9:12 AM, Nikolay Aleksandrov <nikolay@redhat.com> wrote:
> On 03/12/2015 06:54 AM, Mahesh Bandewar wrote:
>> This patch adds code to reschedule the ARP-work (aggressively)
>> to handle the notifications before resuming the regular cycle.
>>
>> Signed-off-by: Mahesh Bandewar <maheshb@google.com>
>> ---
>>  drivers/net/bonding/bond_main.c | 38 ++++++++++++++++++++++----------------
>>  1 file changed, 22 insertions(+), 16 deletions(-)
>>
>> diff --git a/drivers/net/bonding/bond_main.c b/drivers/net/bonding/bond_main.c
>> index 54ecb7a22bae..882974d543d2 100644
>> --- a/drivers/net/bonding/bond_main.c
>> +++ b/drivers/net/bonding/bond_main.c
>> @@ -2814,17 +2814,20 @@ static void bond_activebackup_arp_mon(struct work_struct *work)
>>                                           arp_work.work);
>>       bool should_notify_peers = false;
>>       bool should_notify_rtnl = false;
>> -     int delta_in_ticks;
>> +     unsigned long delta_in_ticks;
>>
>>       delta_in_ticks = msecs_to_jiffies(bond->params.arp_interval);
>>
>>       if (!bond_has_slaves(bond))
>>               goto re_arm;
>>
>> -     rcu_read_lock();
>> -
>>       should_notify_peers = bond_should_notify_peers(bond);
>> +     if (bond_get_notif_pending(bond, BOND_ARP_NOTIF)) {
>> +             rcu_read_lock();
>> +             goto eval_arp_probe;
>> +     }
>>
>> +     rcu_read_lock();
> ^^^^^^^
> Since rcu_read_lock() is acquired in both cases, why don't you leave it
> where it is now ? Then you'll be able to save a line and drop the { }
> on the "if" above.
>
OK, I was under false impression of not-needing-rcu for
should_notify_peers() and hence removed the rcu_read_lock() from the
original location. I'll reinstate.

>
>>       if (bond_ab_arp_inspect(bond)) {
>>               rcu_read_unlock();
>>
>> @@ -2841,25 +2844,28 @@ static void bond_activebackup_arp_mon(struct work_struct *work)
>>               rcu_read_lock();
>>       }
>>
>> +eval_arp_probe:
>>       should_notify_rtnl = bond_ab_arp_probe(bond);
> ^^^^^
> Keep in mind that bond_ab_arp_probe() calls bond_arp_send_all() each time
> if we have an active slave. We could be sending ARP requests each tick
> until rtnl gets acquired.
>
well, that will not be a good behavior however seldom it would be.
I'll update code to avoid that in the next patch-set.

>>       rcu_read_unlock();
>>
>>  re_arm:
>> -     if (bond->params.arp_interval)
>> -             queue_delayed_work(bond->wq, &bond->arp_work, delta_in_ticks);
>> -
>>       if (should_notify_peers || should_notify_rtnl) {
>> -             if (!rtnl_trylock())
>> -                     return;
>> -
>> -             if (should_notify_peers)
>> -                     call_netdevice_notifiers(NETDEV_NOTIFY_PEERS,
>> -                                              bond->dev);
>> -             if (should_notify_rtnl)
>> -                     bond_slave_state_notify(bond);
>> -
>> -             rtnl_unlock();
>> +             if (!rtnl_trylock()) {
>> +                     delta_in_ticks = 1;
>> +                     bond_set_notif_pending(bond, BOND_ARP_NOTIF, 1);
>> +             } else {
>> +                     if (should_notify_rtnl)
>> +                             bond_slave_state_notify(bond);
>> +                     if (should_notify_peers)
>> +                             call_netdevice_notifiers(NETDEV_NOTIFY_PEERS,
>> +                                                      bond->dev);
>> +                     rtnl_unlock();
>> +                     bond_set_notif_pending(bond, BOND_ARP_NOTIF, 0);
>> +             }
>>       }
>> +
>> +     if (bond->params.arp_interval)
>> +             queue_delayed_work(bond->wq, &bond->arp_work, delta_in_ticks);
>>  }
>>
>>  /*-------------------------- netdev event handling --------------------------*/
>>
>
