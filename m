From: Vlad Yasevich <vyasevich@gmail.com>
Subject: Re: [PATCH] net: Correctly sync addresses from multiple sources to
 single device
Date: Wed, 22 Jan 2014 10:06:49 -0500
Message-ID: <52DFDE89.4060905@gmail.com>
References: <1389988332-22472-1-git-send-email-vyasevic@redhat.com> <52DFD32D.4060805@oktetlabs.ru>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, davem@davemloft.net,
	"Alexandra N. Kossovsky" <Alexandra.Kossovsky@oktetlabs.ru>,
	Konstantin Ushakov <Konstantin.Ushakov@oktetlabs.ru>
To: Andrey Dmitrov <andrey.dmitrov@oktetlabs.ru>,
	Vlad Yasevich <vyasevic@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qc0-f178.google.com ([209.85.216.178]:35202 "EHLO
	mail-qc0-f178.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755385AbaAVPGw (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 22 Jan 2014 10:06:52 -0500
Received: by mail-qc0-f178.google.com with SMTP id m20so604996qcx.37
        for <netdev@vger.kernel.org>; Wed, 22 Jan 2014 07:06:51 -0800 (PST)
In-Reply-To: <52DFD32D.4060805@oktetlabs.ru>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 01/22/2014 09:18 AM, Andrey Dmitrov wrote:
> On 01/17/2014 11:52 PM, Vlad Yasevich wrote:
>> When we have multiple devices attempting to sync the same address
>> to a single destination, each device should be permitted to sync
>> it once.  To accomplish this, pass the sync count of the source
>> address to __hw_addr_add_ex().  'sync_cnt' tracks how many time
>> a given address has been successfully synced.  If the address
>> is found in the destination list, but the 'sync_cnt' of the source
>> is 0, then this address has not been synced from this interface
>> and we need to allow the sync operation to succeed thus incrementing
>> reference counts.
>>
>> Reported-by: Andrey Dmitrov <andrey.dmitrov@oktetlabs.ru>
>> CC: Andrey Dmitrov <andrey.dmitrov@oktetlabs.ru>
>> Signed-off-by: Vlad Yasevich <vyasevic@redhat.com>
>> ---
>>   net/core/dev_addr_lists.c | 12 +++++++-----
>>   1 file changed, 7 insertions(+), 5 deletions(-)
>>
>> diff --git a/net/core/dev_addr_lists.c b/net/core/dev_addr_lists.c
>> index ec40a84..bd1b880 100644
>> --- a/net/core/dev_addr_lists.c
>> +++ b/net/core/dev_addr_lists.c
>> @@ -48,7 +48,8 @@ static int __hw_addr_create_ex(struct
>> netdev_hw_addr_list *list,
>>     static int __hw_addr_add_ex(struct netdev_hw_addr_list *list,
>>                   const unsigned char *addr, int addr_len,
>> -                unsigned char addr_type, bool global, bool sync)
>> +                unsigned char addr_type, bool global, bool sync,
>> +                int sync_count)
>>   {
>>       struct netdev_hw_addr *ha;
>>   @@ -66,7 +67,7 @@ static int __hw_addr_add_ex(struct
>> netdev_hw_addr_list *list,
>>                       ha->global_use =3D true;
>>               }
>>               if (sync) {
>> -                if (ha->synced)
>> +                if (ha->synced && sync_count)
>>                       return -EEXIST;
>>                   else
>>                       ha->synced =3D true;
>> @@ -84,7 +85,8 @@ static int __hw_addr_add(struct netdev_hw_addr_lis=
t
>> *list,
>>                const unsigned char *addr, int addr_len,
>>                unsigned char addr_type)
>>   {
>> -    return __hw_addr_add_ex(list, addr, addr_len, addr_type, false,
>> false);
>> +    return __hw_addr_add_ex(list, addr, addr_len, addr_type, false,
>> false,
>> +                0);
>>   }
>>     static int __hw_addr_del_entry(struct netdev_hw_addr_list *list,
>> @@ -139,7 +141,7 @@ static int __hw_addr_sync_one(struct
>> netdev_hw_addr_list *to_list,
>>       int err;
>>         err =3D __hw_addr_add_ex(to_list, ha->addr, addr_len, ha->ty=
pe,
>> -                   false, true);
>> +                   false, true, ha->sync_count);
>>       if (err && err !=3D -EEXIST)
>>           return err;
>>   @@ -676,7 +678,7 @@ static int __dev_mc_add(struct net_device *dev=
,
>> const unsigned char *addr,
>>         netif_addr_lock_bh(dev);
>>       err =3D __hw_addr_add_ex(&dev->mc, addr, dev->addr_len,
>> -                   NETDEV_HW_ADDR_T_MULTICAST, global, false);
>> +                   NETDEV_HW_ADDR_T_MULTICAST, global, false, 0);
>>       if (!err)
>>           __dev_set_rx_mode(dev);
>>       netif_addr_unlock_bh(dev);
>=20
> Thanks. The patch was tested with linux-3.12.6.
>=20
> However, while building the kernel I got complains on:
>=20
>>     err =3D __hw_addr_add_ex(to_list, ha->addr, addr_len, ha->type,
>> -                   false, true);
>> +                   false, true, ha->sync_count);
>=20
> Namely ha (struct netdev_hw_addr) has no field sync_count. It has syn=
c_cnt.
> So I=E2=80=99ve fixed this when testing the patch. Is it a typo or so=
mething
> intentional?
>=20
> Your patch solves the initial problem, but it looks like it introduce=
s a
> new one.
>=20
> When interface joins multicast group corresponding MAC address is add=
ed
> to the interface maddr list. It should be removed when socket explici=
tly
> leaves the group or is just closed. It=E2=80=99s the case without you=
r patch.
> However, with the patched kernel address is still there after socket =
is
> closed.
>=20
> You can reproduce it with mcast_client binary (mcast_client.c was
> attached to the first letter in the thread). To be specific:
>=20
> $ ip maddr show eth3
> 9:  eth3
>  link  33:33:00:00:00:01 users 3
>  link  01:00:5e:00:00:01 users 3
>  link  33:33:ff:01:39:7c users 3
>  link  01:80:c2:00:00:21 users 2
>  inet  224.0.0.1
>  inet6 ff02::1:ff01:397c
>  inet6 ff02::1
>  inet6 ff01::1
>=20
> $ gcc mcast_client.c -o cl
> $ sudo ./cl
> Abort it with Ctrl+c
> $ ip maddr show eth3
> 9:  eth3
>  link  33:33:00:00:00:01 users 3
>  link  01:00:5e:00:00:01 users 3
>  link  33:33:ff:01:39:7c users 3
>  link  01:80:c2:00:00:21 users 2
>  link  01:00:5e:11:58:a8
>  inet  224.0.0.1
>  inet6 ff02::1:ff01:397c
>  inet6 ff02::1
>  inet6 ff01::1
>=20
> 'link 01:00:5e:11:58:a8=E2=80=99 address is still there. Should=E2=80=
=99ve been removed.

You are right.  Sync really doesn't deal well with with multiple source=
s
syncing the same address.  Looks like we need to keep track of how
many time the address has been synced from the different sources.

Looks like I have to restore
commit 4543fbefe6e06a9e40d9f2b28d688393a299f079. :)

-vlad
>=20
> Andrey
> --=20
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
