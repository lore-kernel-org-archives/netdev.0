From: Vlad Yasevich <vyasevic@redhat.com>
Subject: Re: [PATCH net] netdevice: Prefer NETIF_F_HW_CSUM when intersecting
 features
Date: Thu, 20 Apr 2017 15:07:45 -0400
Message-ID: <4c47351b-083c-1390-02ce-d889c700553b@redhat.com>
References: <1492650743-28164-1-git-send-email-vyasevic@redhat.com>
 <CAKgT0Ue67jdAcFeyXqv4Nr8+A-oKNBk7+xV_WmcfWdrNRgRGTQ@mail.gmail.com>
Reply-To: vyasevic@redhat.com
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: Netdev <netdev@vger.kernel.org>, Tom Herbert <tom@herbertland.com>,
        Michal Kubecek <mkubecek@suse.cz>
To: Alexander Duyck <alexander.duyck@gmail.com>,
        Vladislav Yasevich <vyasevich@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:56494 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S943375AbdDTTHr (ORCPT <rfc822;netdev@vger.kernel.org>);
        Thu, 20 Apr 2017 15:07:47 -0400
In-Reply-To: <CAKgT0Ue67jdAcFeyXqv4Nr8+A-oKNBk7+xV_WmcfWdrNRgRGTQ@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 04/20/2017 02:36 PM, Alexander Duyck wrote:
> On Wed, Apr 19, 2017 at 6:12 PM, Vladislav Yasevich <vyasevich@gmail.com> wrote:
>> While hardware device use either NETIF_F_(IP|IPV6)_CSUM or
>> NETIF_F_HW_CSUM, all of the software devices use HW_CSUM.
>> This results in an interesting situation when the software
>> device is configured on top of hw device using (IP|IPV6)_CSUM.
>> In this situation, the user can't turn off checksum offloading
>> features on the software device.
>>
>> This patch resolves that by prefering the NETIF_F_HW_CSUM setting
>> when computing a feature intersect.
>>
>> Signed-off-by: Vladislav Yasevich <vyasevic@redhat.com>
>> ---
>>  include/linux/netdevice.h | 4 ++--
>>  1 file changed, 2 insertions(+), 2 deletions(-)
>>
>> diff --git a/include/linux/netdevice.h b/include/linux/netdevice.h
>> index 97456b25..3d811c1 100644
>> --- a/include/linux/netdevice.h
>> +++ b/include/linux/netdevice.h
>> @@ -4019,9 +4019,9 @@ static inline netdev_features_t netdev_intersect_features(netdev_features_t f1,
>>  {
>>         if ((f1 ^ f2) & NETIF_F_HW_CSUM) {
>>                 if (f1 & NETIF_F_HW_CSUM)
>> -                       f1 |= (NETIF_F_IP_CSUM|NETIF_F_IPV6_CSUM);
>> +                       f2 |= NETIF_F_HW_CSUM;
>>                 else
>> -                       f2 |= (NETIF_F_IP_CSUM|NETIF_F_IPV6_CSUM);
>> +                       f1 |= NETIF_F_HW_CSUM;
>>         }
>>
>>         return f1 & f2;
>> --
>> 2.7.4
>>
> 
> This doesn't seem right to me. I can see promoting NETIF_F_HW_CSUM to
> also include IP_CSUM and IPV6_CSUM but all this seems to do is force
> NETIF_F_HW_CSUM on always if either side has it enabled. That doesn't
> seem like an intersection at all to me.

I think it needs to be the other way around.  At least that's what I've
been observing...


> 
> What this code is supposed to do is make it so that if we are testing
> for NETIF_F_IP_CSUM and NETIF_F_HW_CSUM is set it will return true.
> The code as it is now will always return true if we test for
> NETIF_F_HW_CSUM since it will just set it on the other side for us.
> 

Yes, you are right.  The way the code is now, if we turn off checksum
offload on the lower device, the upper device doesn't change.

What we really want to do is add HW_CSUM to the mask if IP|IPV6 is set.
That way, if lower device has IP|IPV6,  it will end up with IP|IPV6|HW.
This way, controlling IP csums on the lower device will turn off the
checksum on the upper, while at the same time give us the ability to
control the checksum offload on the upper device itself.

Thanks.  I'll resubmit a v2.

-vlad
