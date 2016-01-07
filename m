From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Subject: Re: [PATCH net-next v3 8/8] geneve: break dependency to network
 drivers
Date: Thu, 7 Jan 2016 01:39:44 +0100
Message-ID: <568DB3D0.1040109@stressinduktion.org>
References: <1452123571-19140-1-git-send-email-hannes@stressinduktion.org>
 <1452123571-19140-9-git-send-email-hannes@stressinduktion.org>
 <CAEh+42h79Sxc4JwzH_zMm+MZ-CmQWGdX1Qiz7epJmj2nCiAAVQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Linux Kernel Network Developers <netdev@vger.kernel.org>
To: Jesse Gross <jesse@kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from out5-smtp.messagingengine.com ([66.111.4.29]:60718 "EHLO
	out5-smtp.messagingengine.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751032AbcAGAjr (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 6 Jan 2016 19:39:47 -0500
Received: from compute2.internal (compute2.nyi.internal [10.202.2.42])
	by mailout.nyi.internal (Postfix) with ESMTP id 433AE208E1
	for <netdev@vger.kernel.org>; Wed,  6 Jan 2016 19:39:47 -0500 (EST)
In-Reply-To: <CAEh+42h79Sxc4JwzH_zMm+MZ-CmQWGdX1Qiz7epJmj2nCiAAVQ@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Jesse,

On 07.01.2016 01:18, Jesse Gross wrote:
> On Wed, Jan 6, 2016 at 3:39 PM, Hannes Frederic Sowa
> <hannes@stressinduktion.org> wrote:
>> Signed-off-by: Hannes Frederic Sowa <hannes@stressinduktion.org>
>> ---
>>   drivers/net/geneve.c | 30 +++++++++++++++++++++++++++---
>>   include/net/geneve.h |  7 +++----
>>   2 files changed, 30 insertions(+), 7 deletions(-)
>
> Thanks a lot for going through all the drivers! You found more things
> than I thought. I noticed just a couple new things with this version
> but overall I think it is a good direction.
>
>> diff --git a/drivers/net/geneve.c b/drivers/net/geneve.c
>> index 24b077a32c1c9c..5b8d728b1204be 100644
>> --- a/drivers/net/geneve.c
>> +++ b/drivers/net/geneve.c
>> @@ -1110,7 +1110,7 @@ static struct device_type geneve_type = {
>>    * supply the listening GENEVE udp ports. Callers are expected
>>    * to implement the ndo_add_geneve_port.
>>    */
>> -void geneve_get_rx_port(struct net_device *dev)
>> +static void geneve_notify_refresh_netdev(struct net_device *dev)
>>   {
>>          struct net *net = dev_net(dev);
>>          struct geneve_net *gn = net_generic(net, geneve_net_id);
>
> Both this function and the corresponding one in VXLAN assume that the
> add port NDO is implemented and blindly dereference the pointer. Now
> that all protocols get refreshed at the same time, we should check
> first. There's also a comment above the function that says this, which
> we can remove now.

Absolutely, will fix this in the next version. With the separate 
offloading types this wouldn't be possible. Thanks for seeing this!

I actually had this in a follow-up patch because I want to call this on 
NETDEV_REGISTER, too, so we don't need to add the geneve/vxlan functions 
to the drivers in ndo_start anymore.

> I also think we can update the comments in netdevice.h for the
> VXLAN/Geneve add/remove NDOs to say that they are protected by RTNL.

Will do. Thanks!

>> diff --git a/include/net/geneve.h b/include/net/geneve.h
>> index e6c23dc765f7ec..7d52077b72faa3 100644
>> --- a/include/net/geneve.h
>> +++ b/include/net/geneve.h
>> -#if IS_ENABLED(CONFIG_GENEVE)
>> -void geneve_get_rx_port(struct net_device *netdev);
>> -#else
>>   static inline void geneve_get_rx_port(struct net_device *netdev)
>>   {
>> +       call_netdevice_notifiers(NETDEV_REFRESH_OFFLOADS, netdev);
>>   }
>> -#endif
>
> I think we should merge vxlan_get_rx_port() and geneve_get_rx_port()
> into a single generic function. For drivers that support both, they
> now have two calls to get notified for all offloaded ports. This
> actually can cause problems related to duplicates, similar to what you
> feared before.

Agreed. I add comments to the offloading functions in netdevice.h so 
they need to be implemented in a idempotent way and review the drivers 
how they deal with it.

Thanks for the review,
Hannes
