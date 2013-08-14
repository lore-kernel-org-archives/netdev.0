From: Vlad Yasevich <vyasevic@redhat.com>
Subject: Re: [PATCH v2] macvtap: Correctly set tap features when IFF_VNET_HDR
 is disabled.
Date: Wed, 14 Aug 2013 15:14:33 -0400
Message-ID: <520BD719.6010601@redhat.com>
References: <1376499820-27764-1-git-send-email-vyasevic@redhat.com> <20130814175014.GB17580@redhat.com>
Reply-To: vyasevic@redhat.com
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: "Michael S. Tsirkin" <mst@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:40363 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1758396Ab3HNTOe (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 14 Aug 2013 15:14:34 -0400
Received: from int-mx09.intmail.prod.int.phx2.redhat.com (int-mx09.intmail.prod.int.phx2.redhat.com [10.5.11.22])
	by mx1.redhat.com (8.14.4/8.14.4) with ESMTP id r7EJEYiu008314
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-SHA bits=256 verify=OK)
	for <netdev@vger.kernel.org>; Wed, 14 Aug 2013 15:14:34 -0400
In-Reply-To: <20130814175014.GB17580@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 08/14/2013 01:50 PM, Michael S. Tsirkin wrote:
> On Wed, Aug 14, 2013 at 01:03:40PM -0400, Vlad Yasevich wrote:
>> When the user turns off IFF_VNET_HDR flag, attempts to change
>> offload features via TUNSETOFFLOAD do not work.  This could cause
>> GSO packets to be delivered to the user when the user is
>> not prepared to handle them.
>>
>> To solve, allow processing of TUNSETOFFLOAD when IFF_VNET_HDR is
>> disabled.  Treat any attempt to enable offloads as an error in
>> this case.
>> We also need to update the TUN_FEATURES mask to include all checksum
>> options as the underlying device may have something other then
>> HW_CSUM set.
>
> This last looks like a completely unrelated change,
> does it not?
> Would be nice to have it in a separate patchset with some
> examples of broken configurations.

sure.  can do.

>
>>
>> Change since v1:
>>    - Removed the call to update offloads when IFF_VNET_HDR is turned off.
>>    - Changed the macvtap version of TUN_OFFLOADS to include all checksum
>>      offloads since the physical nic may have them set.
>>    - Treat enabling of offloads without vnet_hdr support as error.
>>
>> Signed-off-by: Vlad Yasevich <vyasevic@redhat.com>
>> ---
>>   drivers/net/macvtap.c | 12 +++++++-----
>>   1 file changed, 7 insertions(+), 5 deletions(-)
>>
>> diff --git a/drivers/net/macvtap.c b/drivers/net/macvtap.c
>> index a98fb0e..3acfc37 100644
>> --- a/drivers/net/macvtap.c
>> +++ b/drivers/net/macvtap.c
>> @@ -65,7 +65,7 @@ static struct cdev macvtap_cdev;
>>
>>   static const struct proto_ops macvtap_socket_ops;
>>
>> -#define TUN_OFFLOADS (NETIF_F_HW_CSUM | NETIF_F_TSO_ECN | NETIF_F_TSO | \
>> +#define TUN_OFFLOADS (NETIF_F_ALL_CSUM | NETIF_F_TSO_ECN | NETIF_F_TSO | \
>>   		      NETIF_F_TSO6 | NETIF_F_UFO)
>>   #define RX_OFFLOADS (NETIF_F_GRO | NETIF_F_LRO)
>>   /*
>> @@ -1024,6 +1024,12 @@ static int set_offload(struct macvtap_queue *q, unsigned long arg)
>>   	if (!vlan)
>>   		return -ENOLINK;
>>
>> +	/* If the user is trying to set offloads while IFF_VNET_HDR is
>> +	 * off, report it as an error.
>> +	 */
>> +	if (!(q->flags & IFF_VNET_HDR) && arg)
>> +		return -EINVAL;
>> +
>
> This function has a single caller so it should matter,
> but I'm just curious why are you moving the test here from
> macvtap_ioctl?
>

I thought the same thing.  I can certainly move it back.  Will make the 
patch smaller.

>>   	features = vlan->dev->features;
>>
>>   	if (arg & TUN_F_CSUM) {
>> @@ -1155,10 +1161,6 @@ static long macvtap_ioctl(struct file *file, unsigned int cmd,
>>   			    TUN_F_TSO_ECN | TUN_F_UFO))
>>   			return -EINVAL;
>>
>> -		/* TODO: only accept frames with the features that
>> -			 got enabled for forwarded frames */
>
> Why do you drop this btw? you disagree we should do this
> eventually? Maybe a separate patch too.

I thought that this comment related to the check for VNET_HDR.
I am having a hard time understanding the meaning behind this comment.
Is the meaning that if GSO is disabled, we shouldn't accept GSO?  This
kind the reverse of what we've been doing.

Or is more along the lines of dropping dropping GSO_GRE for now since
we don't support that offload function yet?

-vlad
>
>> -		if (!(q->flags & IFF_VNET_HDR))
>> -			return  -EINVAL;
>>   		rtnl_lock();
>>   		ret = set_offload(q, arg);
>>   		rtnl_unlock();
>> --
>> 1.8.1.4
