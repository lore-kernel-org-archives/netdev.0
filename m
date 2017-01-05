From: Michael Chan <michael.chan@broadcom.com>
Subject: Re: [PATCH] tg3: Avoid NULL pointer dereference in tg3_get_nstats()
Date: Thu, 5 Jan 2017 12:04:13 -0800
Message-ID: <CACKFLimPkD6hxECA+ZhH+7BVmVSoJ1GfAMZyJ7S50CbhiuC0mA@mail.gmail.com>
References: <1483625601-10552-1-git-send-email-wangyufen@huawei.com> <20170105.123337.2237827308340782208.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: wangyufen@huawei.com, Siva Reddy Kallam <siva.kallam@broadcom.com>,
        "prashant.sreedharan@broadcom.com" <prashant@broadcom.com>,
        "michael.chan@broadcom.com" <mchan@broadcom.com>,
        Netdev <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-oi0-f52.google.com ([209.85.218.52]:33237 "EHLO
        mail-oi0-f52.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1033131AbdAEUEO (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 5 Jan 2017 15:04:14 -0500
Received: by mail-oi0-f52.google.com with SMTP id 128so398166319oig.0
        for <netdev@vger.kernel.org>; Thu, 05 Jan 2017 12:04:14 -0800 (PST)
In-Reply-To: <20170105.123337.2237827308340782208.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Jan 5, 2017 at 9:33 AM, David Miller <davem@davemloft.net> wrote:
> From: Wang Yufen <wangyufen@huawei.com>
> Date: Thu, 5 Jan 2017 22:13:21 +0800
>
>> From: Yufen Wang <wangyufen@huawei.com>
>>
>> A possible NULL pointer dereference in tg3_get_stats64 while doing
>> tg3_free_consistent.
>  ...
>> This patch avoids the NULL pointer dereference by using !tg3_flag(tp, INIT_COMPLETE)
>> instate of !tp->hw_stats.
>>
>> Signed-off-by: Yufen Wang <wangyufen@huawei.com>
>> ---
>>  drivers/net/ethernet/broadcom/tg3.c | 2 +-
>>  1 file changed, 1 insertion(+), 1 deletion(-)
>>
>> diff --git a/drivers/net/ethernet/broadcom/tg3.c b/drivers/net/ethernet/broadcom/tg3.c
>> index 185e9e0..012f18d 100644
>> --- a/drivers/net/ethernet/broadcom/tg3.c
>> +++ b/drivers/net/ethernet/broadcom/tg3.c
>> @@ -14148,7 +14148,7 @@ static struct rtnl_link_stats64 *tg3_get_stats64(struct net_device *dev,
>>       struct tg3 *tp = netdev_priv(dev);
>>
>>       spin_lock_bh(&tp->lock);
>> -     if (!tp->hw_stats) {
>> +     if (!tg3_flag(tp, INIT_COMPLETE)) {
>
> The real issue is the manner and order in which the driver performs
> initialization actions relative to netif_device_{attach,detach}().
>
> That is what needs to be fixed here, instead of adding more and more
> ad-hoc tests to the various methods which can be invoked once the
> netif_device_attach() occurs.

Normally, ndo_get_stats64() should be under rtnl lock in the netlink
code path and we should be safe. We only free tp->hw_stats under rtnl
lock in the close path or ethtool path.

But it looks like ndo_get_stats() can be called without rtnl lock from
net-procfs.c.  So it is possible that we'll read tp->hw_stats after it
has been freed.  For example, if we are reading /proc/net/dev and
closing tg3 at the same time.  David, is not taking rtnl_lock in
net-procfs.c by design?
