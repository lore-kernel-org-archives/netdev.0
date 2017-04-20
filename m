From: =?UTF-8?B?TWFoZXNoIEJhbmRld2FyICjgpK7gpLngpYfgpLYg4KSs4KSC4KSh4KWH4KS14KS+4KSwKQ==?=
        <maheshb@google.com>
Subject: Re: [PATCH next] bonding: fix wq initialization for links created via netlink
Date: Thu, 20 Apr 2017 11:44:28 -0700
Message-ID: <CAF2d9jhKB2R-u_RmHKT1ogvCR5TwtOzz=WWkeAfx_AMJGCJW7Q@mail.gmail.com>
References: <20170420003042.18045-1-mahesh@bandewar.net> <CAPWQB7Hj-W9NPEUSBBCh6Av8ri0mScs+SWCc=mc=yCQkD3w90w@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Mahesh Bandewar <mahesh@bandewar.net>,
        Jay Vosburgh <j.vosburgh@gmail.com>,
        Andy Gospodarek <andy@greyhouse.net>,
        Veaceslav Falico <vfalico@gmail.com>,
        Nikolay Aleksandrov <nikolay@redhat.com>,
        David Miller <davem@davemloft.net>,
        Eric Dumazet <edumazet@google.com>,
        netdev <netdev@vger.kernel.org>
To: Joe Stringer <joe@ovn.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-io0-f169.google.com ([209.85.223.169]:34670 "EHLO
        mail-io0-f169.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S946737AbdDTSou (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 20 Apr 2017 14:44:50 -0400
Received: by mail-io0-f169.google.com with SMTP id a103so82724246ioj.1
        for <netdev@vger.kernel.org>; Thu, 20 Apr 2017 11:44:50 -0700 (PDT)
In-Reply-To: <CAPWQB7Hj-W9NPEUSBBCh6Av8ri0mScs+SWCc=mc=yCQkD3w90w@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Apr 20, 2017 at 11:06 AM, Joe Stringer <joe@ovn.org> wrote:
> On 19 April 2017 at 17:30, Mahesh Bandewar <mahesh@bandewar.net> wrote:
>> From: Mahesh Bandewar <maheshb@google.com>
>>
[...]
>>
>> Fixes: 4493b81bea ("bonding: initialize work-queues during creation of bond")
>> Reported-by: Joe Stringer <joe@ovn.org>
>> Signed-off-by: Mahesh Bandewar <maheshb@google.com>
>> ---
>
> Thanks Mahesh, this fixes the issue I was observing.
>
> Tested-by: Joe Stringer <joe@ovn.org>
>
Thanks for the confirmation Joe.

>>  drivers/net/bonding/bond_main.c    | 2 +-
>>  drivers/net/bonding/bond_netlink.c | 5 +++++
>>  include/net/bonding.h              | 1 +
>>  3 files changed, 7 insertions(+), 1 deletion(-)
>>
>> diff --git a/drivers/net/bonding/bond_main.c b/drivers/net/bonding/bond_main.c
>> index 6bd3b50faf48..e549bf6f5cac 100644
>> --- a/drivers/net/bonding/bond_main.c
>> +++ b/drivers/net/bonding/bond_main.c
>> @@ -3243,7 +3243,7 @@ u32 bond_xmit_hash(struct bonding *bond, struct sk_buff *skb)
>>
>>  /*-------------------------- Device entry points ----------------------------*/
>>
>> -static void bond_work_init_all(struct bonding *bond)
>> +void bond_work_init_all(struct bonding *bond)
>>  {
>>         INIT_DELAYED_WORK(&bond->mcast_work,
>>                           bond_resend_igmp_join_requests_delayed);
>> diff --git a/drivers/net/bonding/bond_netlink.c b/drivers/net/bonding/bond_netlink.c
>> index b8df0f5e8c25..31b9f37c7dbd 100644
>> --- a/drivers/net/bonding/bond_netlink.c
>> +++ b/drivers/net/bonding/bond_netlink.c
>> @@ -449,6 +449,11 @@ static int bond_newlink(struct net *src_net, struct net_device *bond_dev,
>>         err = register_netdevice(bond_dev);
>>
>>         netif_carrier_off(bond_dev);
>> +       if (err >= 0) {
>
> register_netdevice() returns 0 on success according to its
> documentation, does it need to handle positive err values?
>
Yes, that's not needed and could cause problems. Will update the patch.

>> +               struct bonding *bond = netdev_priv(bond_dev);
>> +
>> +               bond_work_init_all(bond);
>> +       }
>>
>>         return err;
>>  }
>> diff --git a/include/net/bonding.h b/include/net/bonding.h
>> index 04a21e8048be..b00508d22e0a 100644
>> --- a/include/net/bonding.h
>> +++ b/include/net/bonding.h
>> @@ -614,6 +614,7 @@ struct bond_vlan_tag *bond_verify_device_path(struct net_device *start_dev,
>>                                               int level);
>>  int bond_update_slave_arr(struct bonding *bond, struct slave *skipslave);
>>  void bond_slave_arr_work_rearm(struct bonding *bond, unsigned long delay);
>> +void bond_work_init_all(struct bonding *bond);
>>
>>  #ifdef CONFIG_PROC_FS
>>  void bond_create_proc_entry(struct bonding *bond);
>> --
>> 2.12.2.816.g2cccc81164-goog
>>
