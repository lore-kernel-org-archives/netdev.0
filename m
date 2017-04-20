From: Vlad Yasevich <vyasevic@redhat.com>
Subject: Re: [PATCH V2 net] netdevice: Include NETIF_F_HW_CSUM when
 intersecting features
Date: Thu, 20 Apr 2017 19:19:55 -0400
Message-ID: <b34063e7-e0c2-583d-f809-02386fc175de@redhat.com>
References: <1492715844-30273-1-git-send-email-vyasevic@redhat.com>
 <CAKgT0UcHtWYQDcYda+i8R8WhBKeWbOBZRHDcAmJXZYuP1RM7-Q@mail.gmail.com>
Reply-To: vyasevic@redhat.com
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: Netdev <netdev@vger.kernel.org>, Michal Kubecek <mkubecek@suse.cz>,
        Tom Herbert <tom@herbertland.com>
To: Alexander Duyck <alexander.duyck@gmail.com>,
        Vladislav Yasevich <vyasevich@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:53774 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S947776AbdDTXT5 (ORCPT <rfc822;netdev@vger.kernel.org>);
        Thu, 20 Apr 2017 19:19:57 -0400
In-Reply-To: <CAKgT0UcHtWYQDcYda+i8R8WhBKeWbOBZRHDcAmJXZYuP1RM7-Q@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 04/20/2017 06:31 PM, Alexander Duyck wrote:
> On Thu, Apr 20, 2017 at 12:17 PM, Vladislav Yasevich
> <vyasevich@gmail.com> wrote:
>> While hardware device use either NETIF_F_(IP|IPV6)_CSUM or
>> NETIF_F_HW_CSUM, all of the software devices use HW_CSUM.
>> This results in an interesting situation when the software
>> device is configured on top of hw device using (IP|IPV6)_CSUM.
>> In this situation, the user can't turn off checksum offloading
>> features on the software device.
> 
> Why wouldn't they be able to? It seems like the software device
> shouldn't be setting IP_CSUM or IPV6_CSUM feature flags, but they will
> be set in the intersect features. The result won't have
> NETIF_F_HW_CSUM set, but it should advertise the features of the lower
> device instead.

The can't because the upper software devices typically has HW_CSUM set in
hw_features and features.  When we intersect with a lower device which has
IP|IPV6 set, we end up with a software device that has IP|IPV6 set.  However,
the the hw_features have HW_CSUM, you end with a "fixed" setting of IP|IPV6
which can't be controlled now on the software device.

I've had a situation where trying to debug something, to turn off checksum
offloading on a vlan, I had to turn it of on the hw itself which effects all
traffic now.

We should be able to control it properly.

> 
>> This patch resolves that by adding NETIF_F_HW_CSUM to the mask
>> if a feature set includes only IP|IPV6 csum.  This allows the user
>> to control the upper (software) device checksum, while at the same
>> time correctly propagating lower device changes up.
> 
> You can't go this way. HW_CSUM is an all inclusive feature flag,
> whereas IP_CSUM and IPV6_CSUM specify only specific offload types.
> With your change the lower device could disable IPV6_CSUM for instance
> but you would still end up advertising checksum offload via HW_CSUM.
> 
>> CC: Michal Kubecek <mkubecek@suse.cz>
>> CC: Alexander Duyck <alexander.duyck@gmail.com>
>> CC: Tom Herbert <tom@herbertland.com>
>> Signed-off-by: Vladislav Yasevich <vyasevic@redhat.com>
>>
>> ---
>>
>> V2: Addressed comments from Alex Duyck.  I tested this with hacked virtio
>> device that set IP|IPV6 checksums instead of HW.  Configuring a vlan on
>> top gave the vlan device with 'ip-generic: on' setting (using HW checksum).
>> This allows me to change vlan checksum offloads independent of virt-io nic.
>> Changes to virtio-nic propagated up to vlan, turning off the offloading
>> correctly.
>>
>>  include/linux/netdevice.h | 8 ++++----
>>  1 file changed, 4 insertions(+), 4 deletions(-)
>>
>> diff --git a/include/linux/netdevice.h b/include/linux/netdevice.h
>> index b0aa089..81aed2f 100644
>> --- a/include/linux/netdevice.h
>> +++ b/include/linux/netdevice.h
>> @@ -4009,10 +4009,10 @@ static inline netdev_features_t netdev_intersect_features(netdev_features_t f1,
>>                                                           netdev_features_t f2)
>>  {
>>         if ((f1 ^ f2) & NETIF_F_HW_CSUM) {
>> -               if (f1 & NETIF_F_HW_CSUM)
>> -                       f1 |= (NETIF_F_IP_CSUM|NETIF_F_IPV6_CSUM);
>> -               else
>> -                       f2 |= (NETIF_F_IP_CSUM|NETIF_F_IPV6_CSUM);
>> +               if (f1 & (NETIF_F_IP_CSUM | NETIF_F_IPV6_CSUM))
>> +                       f1 |= NETIF_F_HW_CSUM;
>> +               if(f2 & (NETIF_F_IP_CSUM | NETIF_F_IPV6_CSUM))
>> +                       f2 |= NETIF_F_HW_CSUM;
>>         }
>>
>>         return f1 & f2;
>> --
>> 2.7.4
>>
> 
> This doesn't work. "NETIF_F_IP_CSUM | NETIF_F_IPV6_CSUM" doesn't
> equate to "NETIF_F_HW_CSUM". The problem is NETIF_F_HW_CSUM is a
> catch-all, the IP and IPV6 CSUM flags are not. Right now you would
> introduce escapes on devices that enable IP but not IPv6, or the other
> way around.
> 
> Can you point to the exact case where this code is an issue? It seems
> like maybe you are wanting to have NETIF_F_HW_CSUM set if you support
> offloading a given protocol. You might want to look at how we dealt
> with this in the GSO code path so that if we could offload the
> checksum we set NETIF_F_HW_CSUM based on protocol and the CSUM offload
> feature bit for that protocol.
> 

What I'd like to be able to do is control features on the software device
without having to turn them off on the HW.  As it stands right now, we can't
do that.  If you want to try, configure a vlan on top of any device that
sets IP|IPV6 csum features.

I was trying to fix it in the common place.  It actually works correctly
since the software checksum gets computed correctly lower in the stack,
so there is no actual escape.

Having said that, the other alternative is to inherit hw_features from
lower devices.  BTW, bonding I think has a similar "issue" you are
describing since it prefers HW_CSUM if any of the slaves have it set.

-vlad

> - Alex
> 
