From: Daniel Lezcano <daniel.lezcano@free.fr>
Subject: Re: dev_get_valid_name buggy with hash collision
Date: Tue, 18 May 2010 16:55:36 +0200
Message-ID: <4BF2AA68.5090008@free.fr>
References: <4BF26926.4070507@free.fr> <201005181529.37420.opurdila@ixiacom.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Linux Netdev List <netdev@vger.kernel.org>
To: Octavian Purdila <opurdila@ixiacom.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mtagate5.de.ibm.com ([195.212.17.165]:32898 "EHLO
	mtagate5.de.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757580Ab0EROzj (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 18 May 2010 10:55:39 -0400
Received: from d12nrmr1607.megacenter.de.ibm.com (d12nrmr1607.megacenter.de.ibm.com [9.149.167.49])
	by mtagate5.de.ibm.com (8.13.1/8.13.1) with ESMTP id o4IEtbaq006051
	for <netdev@vger.kernel.org>; Tue, 18 May 2010 14:55:37 GMT
Received: from d12av01.megacenter.de.ibm.com (d12av01.megacenter.de.ibm.com [9.149.165.212])
	by d12nrmr1607.megacenter.de.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id o4IEtb8i1716228
	for <netdev@vger.kernel.org>; Tue, 18 May 2010 16:55:37 +0200
Received: from d12av01.megacenter.de.ibm.com (loopback [127.0.0.1])
	by d12av01.megacenter.de.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id o4IEtb8r022483
	for <netdev@vger.kernel.org>; Tue, 18 May 2010 16:55:37 +0200
In-Reply-To: <201005181529.37420.opurdila@ixiacom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 05/18/2010 02:29 PM, Octavian Purdila wrote:
> On Tuesday 18 May 2010 13:17:10 you wrote:
>
>    
>> the commit:
>>
>> commit d90310243fd750240755e217c5faa13e24f41536
>> Author: Octavian Purdila<opurdila@ixiacom.com>
>> Date:   Wed Nov 18 02:36:59 2009 +0000
>>
>>       net: device name allocation cleanups
>>
>> introduced a bug when there is a hash collision making impossible to
>> rename a device with eth%d
>>
>>      

[ ... ]

>> --- net-2.6.orig/net/core/dev.c
>> +++ net-2.6/net/core/dev.c
>> @@ -936,18 +936,22 @@ int dev_alloc_name(struct net_device *de
>> }
>> EXPORT_SYMBOL(dev_alloc_name);
>>
>> -static int dev_get_valid_name(struct net *net, const char *name, char *buf,
>> -                             bool fmt)
>> +static int dev_get_valid_name(struct net_device *dev, const char *name, bool
>>      
> fmt)
>    
>> {
>> +       struct net *net;
>> +
>> +       BUG_ON(!dev_net(dev));
>> +       net = dev_net(dev);
>> +
>>         if (!dev_valid_name(name))
>>                 return -EINVAL;
>>
>>         if (fmt&&  strchr(name, '%'))
>> -               return __dev_alloc_name(net, name, buf);
>> +               return dev_alloc_name(dev, name);
>>         else if (__dev_get_by_name(net, name))
>>                 return -EEXIST;
>> -       else if (buf != name)
>> -               strlcpy(buf, name, IFNAMSIZ);
>> +       else if (strncmp(dev->name, name, IFNAMSIZ))
>> +                strlcpy(dev->name, name, IFNAMSIZ);
>>
>>      
> Why do the strncmp, can't we preserve the (buf != name) condition

The 'buf' parameter is no longer passed to the function. We have the 
'dev'  and the 'newname' parameters.
The pointer test was just to check 'dev_get_valid_name' was called from 
the 'register_netdevice' function context with 'dev_get_valid_name(net, 
dev->name, dev->name, 0)'. Comparing the strings is valid in this case.

Otherwise dev_get_valid_name is called from:

  *  "dev_change_net_namespace" with "dev%d" or "ifname" specified 
within the netlink message. Both are different pointers, the first will 
fall in the "if (fmt && strchr(name, '%'))".

  * "dev_change_name", where the pointers are different and the strings 
are different.

I think it is safe to do the string comparison here. But maybe there are 
a few simplifications (eg. remove fmt) to do.
If you agree, I will send this patch against net-2.6 and the 
simplifications against net-next-2.6.

Thanks
   -- Daniel


