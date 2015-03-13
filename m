From: Mahesh Bandewar <maheshb@google.com>
Subject: Re: [PATCH net-next 2/4] bonding: Do not ignore notifications for miimon-work-queue
Date: Thu, 12 Mar 2015 18:54:09 -0700
Message-ID: <CAF2d9jjDCh0n12BDuw0Arjs3gb0CG73R53QxFLpFmp-2VBjCbg@mail.gmail.com>
References: <1426139677-27167-1-git-send-email-maheshb@google.com> <1426152880.11398.151.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Jay Vosburgh <j.vosburgh@gmail.com>,
	Andy Gospodarek <andy@greyhouse.net>,
	Veaceslav Falico <vfalico@gmail.com>,
	Nikolay Aleksandrov <nikolay@redhat.com>,
	David Miller <davem@davemloft.net>,
	Maciej Zenczykowski <maze@google.com>,
	netdev <netdev@vger.kernel.org>,
	Eric Dumazet <edumazet@google.com>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ob0-f180.google.com ([209.85.214.180]:46508 "EHLO
	mail-ob0-f180.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753112AbbCMBya (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 12 Mar 2015 21:54:30 -0400
Received: by obcva2 with SMTP id va2so17610358obc.13
        for <netdev@vger.kernel.org>; Thu, 12 Mar 2015 18:54:30 -0700 (PDT)
In-Reply-To: <1426152880.11398.151.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Mar 12, 2015 at 2:34 AM, Eric Dumazet <eric.dumazet@gmail.com> wrote:
> On Wed, 2015-03-11 at 22:54 -0700, Mahesh Bandewar wrote:
>> This patch adds code to reschedule the mii-work (aggressively)
>> just to handle the notification before resuming the regular
>> cycle.
>>
>> Signed-off-by: Mahesh Bandewar <maheshb@google.com>
>> ---
>>  drivers/net/bonding/bond_main.c | 24 +++++++++++++++---------
>>  1 file changed, 15 insertions(+), 9 deletions(-)
>>
>> diff --git a/drivers/net/bonding/bond_main.c b/drivers/net/bonding/bond_main.c
>> index 19eabea2d7d9..54ecb7a22bae 100644
>> --- a/drivers/net/bonding/bond_main.c
>> +++ b/drivers/net/bonding/bond_main.c
>> @@ -2143,10 +2143,13 @@ static void bond_mii_monitor(struct work_struct *work)
>>       if (!bond_has_slaves(bond))
>>               goto re_arm;
>>
>> -     rcu_read_lock();
>> -
>> +     if (bond_get_notif_pending(bond, BOND_MII_NOTIF)) {
>> +             should_notify_peers = true;
>> +             goto re_arm;
>> +     }
>>       should_notify_peers = bond_should_notify_peers(bond);
>>
>> +     rcu_read_lock();
>>       if (bond_miimon_inspect(bond)) {
>>               rcu_read_unlock();
>>
>> @@ -2164,15 +2167,18 @@ static void bond_mii_monitor(struct work_struct *work)
>>               rcu_read_unlock();
>>
>>  re_arm:
>> -     if (bond->params.miimon)
>> -             queue_delayed_work(bond->wq, &bond->mii_work, delay);
>> -
>>       if (should_notify_peers) {
>> -             if (!rtnl_trylock())
>> -                     return;
>> -             call_netdevice_notifiers(NETDEV_NOTIFY_PEERS, bond->dev);
>> -             rtnl_unlock();
>> +             if (!rtnl_trylock()) {
>> +                     delay = 1;
>> +                     bond_set_notif_pending(bond, BOND_MII_NOTIF, 1);
>> +             } else {
>> +                     call_netdevice_notifiers(NETDEV_NOTIFY_PEERS, bond->dev);
>> +                     rtnl_unlock();
>> +                     bond_set_notif_pending(bond, BOND_MII_NOTIF, 0);
>
> You probably should clear notif bit before releasing rtnl
>
> (same remark for patches 3 & 4)
>
Since this op is atomic and does not need lock, I used it in the
current fashion. I probably won't need to clear it if I use the
test_and_clear instead of current test_bit() in get_notif_pending()

>> +             }
>>       }
>> +     if (bond->params.miimon)
>> +             queue_delayed_work(bond->wq, &bond->mii_work, delay);
>>  }
>>
>>  static bool bond_has_this_ip(struct bonding *bond, __be32 ip)
>
>
