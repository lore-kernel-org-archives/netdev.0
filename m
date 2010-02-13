From: Sridhar Samudrala <sri@us.ibm.com>
Subject: Re: [PATCH net-next-2.6] macvtap: Add GSO/csum offload support
Date: Sat, 13 Feb 2010 12:55:37 -0800
Message-ID: <4B7711C9.2090800@us.ibm.com>
References: <1266013667.6105.18.camel@w-sridhar.beaverton.ibm.com> <1266044316.10419.3.camel@w-sridhar.beaverton.ibm.com> <201002131834.00612.arnd@arndb.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15; format=flowed
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>,
	Herbert Xu <herbert@gondor.apana.org.au>,
	netdev <netdev@vger.kernel.org>
To: Arnd Bergmann <arnd@arndb.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from e31.co.us.ibm.com ([32.97.110.149]:36188 "EHLO
	e31.co.us.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757901Ab0BMU41 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 13 Feb 2010 15:56:27 -0500
Received: from d03relay01.boulder.ibm.com (d03relay01.boulder.ibm.com [9.17.195.226])
	by e31.co.us.ibm.com (8.14.3/8.13.1) with ESMTP id o1DKlvuf026628
	for <netdev@vger.kernel.org>; Sat, 13 Feb 2010 13:47:57 -0700
Received: from d03av01.boulder.ibm.com (d03av01.boulder.ibm.com [9.17.195.167])
	by d03relay01.boulder.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id o1DKuOnW158660
	for <netdev@vger.kernel.org>; Sat, 13 Feb 2010 13:56:24 -0700
Received: from d03av01.boulder.ibm.com (loopback [127.0.0.1])
	by d03av01.boulder.ibm.com (8.14.3/8.13.1/NCO v10.0 AVout) with ESMTP id o1DKuO55031017
	for <netdev@vger.kernel.org>; Sat, 13 Feb 2010 13:56:24 -0700
In-Reply-To: <201002131834.00612.arnd@arndb.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 2/13/2010 9:34 AM, Arnd Bergmann wrote:
> Hi Sridhar,
>
> On Saturday 13 February 2010, Sridhar Samudrala wrote:
>
>    
>> This patch adds GSO/checksum offload support to macvtap driver and applies
>> on top of Arnd's refcnt bugfix.
>> 	http://patchwork.ozlabs.org/patch/45136/
>>      
> Sorry for messing this up by replacing that patch with a different one.
> It shouldn't be hard to rebase this one though, which I'll probably do on Monday.
> Please tell me if you want to do it yourself instead.
>    
No problem. If you get to it before, it is fine with me.
>> @@ -286,6 +288,7 @@ static int macvtap_open(struct inode *inode, struct file *file)
>>   	sock_init_data(&q->sock,&q->sk);
>>   	q->sk.sk_allocation = GFP_ATOMIC; /* for now */
>>   	q->sk.sk_write_space = macvtap_sock_write_space;
>> +	q->flags = IFF_VNET_HDR;
>>
>>   	err = macvtap_set_queue(dev, file, q);
>>   	if (err)
>>      
> Making IFF_VNET_HDR the default probably prevents the driver from working
> with applications that don't known about VNET_HDR, e.g. anything other
> than qemu. I believe qemu always tries setting it though, which would make
> a default value of !IFF_NET_HDR fine.
>    
Yes. It is better to make the default as !IFF_VNET_HDR
> Also, what about IFF_TAP and IFF_NO_PI, should those be always set?
>    
Atleast it is not required for qemu to have these flags set. If we are 
not doing anything different based on
these flags, i felt we don't need to have them.
>    
>> @@ -499,18 +648,14 @@ static long macvtap_ioctl(struct file *file, unsigned int cmd,
>>   		return 0;
>>
>>   	case TUNSETOFFLOAD:
>> -		/* let the user check for future flags */
>> -		if (arg&  ~(TUN_F_CSUM | TUN_F_TSO4 | TUN_F_TSO6 |
>> -			  TUN_F_TSO_ECN | TUN_F_UFO))
>> -			return -EINVAL;
>> -
>> -		/* TODO: add support for these, so far we don't
>> -			 support any offload */
>> -		if (arg&  (TUN_F_CSUM | TUN_F_TSO4 | TUN_F_TSO6 |
>> -			 TUN_F_TSO_ECN | TUN_F_UFO))
>> -			return -EINVAL;
>> -
>> -		return 0;
>> +		q = macvtap_file_get_queue(file);
>> +		if (!q)
>> +			return -ENOLINK;
>> +		ret = 0;
>> +		if (!(q->flags&  IFF_VNET_HDR))
>> +			ret =  -EINVAL;
>> +		macvtap_file_put_queue(q);
>> +		return ret;
>>
>>   	default:
>>   		return -EINVAL;
>>      
> At least the first check needs to be in there, in case we are running with
> new user space that knows additional flags. Moreover, shouldn't we check
> the flags against the capabilities of vlan->lowerdev? I though it would be
> best to report the capabilities of the real hardware to the guest kernel
> so it can do the right thing.
>    
Originally, i also thought we should check these based on the real 
device capabilities. But later i realized,
that it is not really required as we fall back to software offload via 
dev_gso_segment() call in dev_hard_start_xmit()
if the real device doesn't support any of the offloads. So we can 
advertise that all the offloads are supported to
the guest and let host deal with any offloads that are not supported by 
the real device.

Thanks
Sridhar

