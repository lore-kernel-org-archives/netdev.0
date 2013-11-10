From: Ding Tianhong <dthxman@gmail.com>
Subject: Re: [PATCH net-next v2 6/10] bonding: rebuild the lock use for bond_activebackup_arp_mon()
Date: Sun, 10 Nov 2013 12:08:02 +0800
Message-ID: <527F06A2.2070407@gmail.com>
References: <527C4784.1030402@huawei.com> <527D0AEF.1060802@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Ding Tianhong <dingtianhong@huawei.com>,
	Jay Vosburgh <fubar@us.ibm.com>,
	Andy Gospodarek <andy@greyhouse.net>,
	"David S. Miller" <davem@davemloft.net>,
	Veaceslav Falico <vfalico@redhat.com>,
	Netdev <netdev@vger.kernel.org>
To: Nikolay Aleksandrov <nikolay@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f46.google.com ([209.85.220.46]:58888 "EHLO
	mail-pa0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758589Ab3KJESr (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 9 Nov 2013 23:18:47 -0500
Received: by mail-pa0-f46.google.com with SMTP id kl14so2587716pab.33
        for <netdev@vger.kernel.org>; Sat, 09 Nov 2013 20:18:47 -0800 (PST)
In-Reply-To: <527D0AEF.1060802@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


>> +	rcu_read_unlock();
>>   
>>   re_arm:
>>   	if (bond->params.arp_interval)
>>   		queue_delayed_work(bond->wq, &bond->arp_work, delta_in_ticks);
>>   
>> -	read_unlock(&bond->lock);
>> -
>>   	if (should_notify_peers) {
>>   		if (!rtnl_trylock())
>>   			return;
>> diff --git a/drivers/net/bonding/bonding.h b/drivers/net/bonding/bonding.h
>> index deb9738..90b745c 100644
>> --- a/drivers/net/bonding/bonding.h
>> +++ b/drivers/net/bonding/bonding.h
>> @@ -97,6 +97,13 @@
>>   		netdev_adjacent_get_private(bond_slave_list(bond)->prev) : \
>>   		NULL)
>>   
>> +#define bond_first_slave_rcu(bond) \
>> +	({struct list_head *__ptr = (bond_slave_list(bond)); \
>> +	 struct list_head *__next = ACCESS_ONCE(__ptr->next); \
>> +	 likely(__ptr != __next) ? \
>> +	 netdev_adjacent_get_private_rcu(__next) : NULL; \
>> +	 })
>> +
> Honestly, I don't like this, it sure can be re-written in a more
> straight-forward manner.

I have re-write the function by 2 ways, the first one just like 
list_first_or_null_rcu,
the second one just used the exist function 
netdev_lower_get_next_private_rcu,
I think the first one is better, it is more exactly.

1:

+#define bond_first_slave_rcu(bond) \
+	({struct list_head *__ptr = (bond_slave_list(bond)); \
+	 struct list_head *__next = ACCESS_ONCE(__ptr->next); \
+	 likely(__ptr != __next) ? \
+	 (list_entry_rcu(__next, struct netdev_adjacent, list))->private : NULL; \
+	 })
+

2:

+#define bond_first_slave_rcu(bond) \
+	({struct list_head *iter = (bond_slave_list(bond)); \
+	 netdev_lower_get_next_private_rcu(bond->dev, &iter) ? : NULL; \
+	})


what do you think about is, maybe you have more wonderful idea, pls 
remind me,
thanks

Regards
Ding

> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
>
