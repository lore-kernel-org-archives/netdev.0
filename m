From: Xin Long <lucien.xin@gmail.com>
Subject: Re: [PATCHv2 net] bridge: a netlink notification should be sent
 whenever those attributes change
Date: Tue, 8 Mar 2016 19:32:59 +0800
Message-ID: <CADvbK_do0-Hmz2vc6KnKkgDkZDsHYri3GBQOTEQ4oTB6D68qzA@mail.gmail.com>
References: <b58f9a4012cfc37e730916a092f2ff5530b299fd.1457407644.git.lucien.xin@gmail.com>
	<56DE9EF3.4010501@cumulusnetworks.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: network dev <netdev@vger.kernel.org>, davem <davem@davemloft.net>,
	Hannes Frederic Sowa <hannes@stressinduktion.org>
To: Nikolay Aleksandrov <nikolay@cumulusnetworks.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-oi0-f51.google.com ([209.85.218.51]:35269 "EHLO
	mail-oi0-f51.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932986AbcCHLdB (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 8 Mar 2016 06:33:01 -0500
Received: by mail-oi0-f51.google.com with SMTP id c203so8221929oia.2
        for <netdev@vger.kernel.org>; Tue, 08 Mar 2016 03:33:00 -0800 (PST)
In-Reply-To: <56DE9EF3.4010501@cumulusnetworks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Mar 8, 2016 at 5:44 PM, Nikolay Aleksandrov
<nikolay@cumulusnetworks.com> wrote:
> On 03/08/2016 04:27 AM, Xin Long wrote:
>> Now when we change the attributes of bridge or br_port by netlink,
>> a relevant netlink notification will be sent, but if we change them
>> by ioctl or sysfs, no notification will be sent.
>>
>> we should ensure that whenever those attributes change internally or from
>> sysfs/ioctl, that a netlink notification is sent out to listeners.
>>
>> Also, NetworkManager will use this in the future to listen for out-of-band
>> bridge master attribute updates and incorporate them into the runtime
>> configuration.
>>
>> Signed-off-by: Xin Long <lucien.xin@gmail.com>
>> ---
>>  net/bridge/br_ioctl.c    | 40 ++++++++++++++++++++++++----------------
>>  net/bridge/br_sysfs_br.c |  5 +++++
>>  net/bridge/br_sysfs_if.c |  6 +++++-
>>  3 files changed, 34 insertions(+), 17 deletions(-)
>>
>
> The patch should be targeted at net-next, not net.
got it.

>
>> diff --git a/net/bridge/br_ioctl.c b/net/bridge/br_ioctl.c
>> index 263b4de..f8fc624 100644
>> --- a/net/bridge/br_ioctl.c
>> +++ b/net/bridge/br_ioctl.c
> [snip]
>>  static int old_deviceless(struct net *net, void __user *uarg)
>> diff --git a/net/bridge/br_sysfs_br.c b/net/bridge/br_sysfs_br.c
>> index 6b80914..09608e6 100644
>> --- a/net/bridge/br_sysfs_br.c
>> +++ b/net/bridge/br_sysfs_br.c
>> @@ -44,6 +44,11 @@ static ssize_t store_bridge_parm(struct device *d,
>>               return -EINVAL;
>>
>>       err = (*set)(br, val);
>> +     if (!err) {
>> +             rtnl_lock();
>
> This will deadlock, there's a reason rtnl_trylock() is used in sysfs options.
> As I said the br_sysfs_br.c would need more work.
>
>> +             netdev_state_change(br->dev);
>> +             rtnl_unlock();
>> +     }
>>       return err ? err : len;
>>  }
>>
>> diff --git a/net/bridge/br_sysfs_if.c b/net/bridge/br_sysfs_if.c
>> index efe415a..64c8422 100644
>> --- a/net/bridge/br_sysfs_if.c
>> +++ b/net/bridge/br_sysfs_if.c
>> @@ -253,8 +253,12 @@ static ssize_t brport_store(struct kobject *kobj,
>>                       spin_lock_bh(&p->br->lock);
>>                       ret = brport_attr->store(p, val);
>>                       spin_unlock_bh(&p->br->lock);
>> -                     if (ret == 0)
>> +                     if (!ret) {
>> +                             rtnl_lock();
>
> rtnl is already held here, this way you deadlock. Again I'm really
> curious how this patch was tested, you'd have deadlocked immediately.
> On your next submission I'd suggest you add some notes on how you tested
> the patch.
sorry, I thought here is similar, :D.  I will do it next submission
thanks.

>
>> +                             br_ifinfo_notify(RTM_NEWLINK, p);
>> +                             rtnl_unlock();
>>                               ret = count;
>> +                     }
>>               }
>>               rtnl_unlock();
>>       }
>>
>
