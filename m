From: Cong Wang <xiyou.wangcong@gmail.com>
Subject: Re: [Patch net-next 3/5] ipv6: clean up ipv6_dev_ac_inc()
Date: Wed, 10 Sep 2014 14:32:30 -0700
Message-ID: <CAM_iQpWXL6MgYa2zV=7Kmv9NJBYGiTcQdZe7JRzFGougzGByqw@mail.gmail.com>
References: <1410306738-18036-1-git-send-email-xiyou.wangcong@gmail.com>
	<1410306738-18036-4-git-send-email-xiyou.wangcong@gmail.com>
	<1410351815.3135.14.camel@localhost>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Linux Kernel Network Developers <netdev@vger.kernel.org>,
	Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>,
	"David S. Miller" <davem@davemloft.net>
To: Hannes Frederic Sowa <hannes@stressinduktion.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ob0-f171.google.com ([209.85.214.171]:43383 "EHLO
	mail-ob0-f171.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752865AbaIJVcb (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 10 Sep 2014 17:32:31 -0400
Received: by mail-ob0-f171.google.com with SMTP id wn1so13814483obc.2
        for <netdev@vger.kernel.org>; Wed, 10 Sep 2014 14:32:30 -0700 (PDT)
In-Reply-To: <1410351815.3135.14.camel@localhost>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Sep 10, 2014 at 5:23 AM, Hannes Frederic Sowa
<hannes@stressinduktion.org> wrote:
> On Di, 2014-09-09 at 16:52 -0700, Cong Wang wrote:
>> +     in6_dev_hold(idev);
>
> Please move this in6_dev_hold down to where it gets attached to the
> ifacaddr6 and remove the in6_dev_put from below the out: label.


I thought it is for idev->lock in case of idev becomes a wild pointer
as well, but it seems its callers or at least RTNL should guarantee
idev is still valid. So yeah, then we can probably move it down.

>
>>       write_lock_bh(&idev->lock);
>>       if (idev->dead) {
>>               err = -ENODEV;
>> @@ -267,7 +262,7 @@ int ipv6_dev_ac_inc(struct net_device *dev, const struct in6_addr *addr)
>>       aca->aca_users = 1;
>>       /* aca_tstamp should be updated upon changes */
>>       aca->aca_cstamp = aca->aca_tstamp = jiffies;
>> -     atomic_set(&aca->aca_refcnt, 2);
>> +     atomic_set(&aca->aca_refcnt, 1);
>>       spin_lock_init(&aca->aca_lock);
>>
>>       aca->aca_next = idev->ac_list;
>> @@ -276,9 +271,7 @@ int ipv6_dev_ac_inc(struct net_device *dev, const struct in6_addr *addr)
>>
>>       ip6_ins_rt(rt);
>>
>> -     addrconf_join_solict(dev, &aca->aca_addr);
>> -
>> -     aca_put(aca);
>
> I am not sure why you changed the aca_refcnt code. idev->ac_list is only
> protected by idev->lock and you publish one reference and unlock, thus
> you need a second reference during addrconf_join_solict. All accesses
> should also be protected by rtnl, so it shouldn't be a problem, but if
> people review the code they might have problems to figure that out.
> Maybe you can also remove the idev->lock?
>

I was misled by the code, it is not easy to understand this since there
is no comment. I will refactor the code to make it more readable and
of course in a separated patch.

Thanks.
