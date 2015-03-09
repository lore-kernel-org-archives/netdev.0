From: Florian Fainelli <f.fainelli@gmail.com>
Subject: Re: [PATCH net-next 1/2] net: core: add of_find_net_device_by_node()
Date: Mon, 09 Mar 2015 12:31:00 -0700
Message-ID: <54FDF4F4.5000503@gmail.com>
References: <1425927750-23901-1-git-send-email-f.fainelli@gmail.com> <1425927750-23901-2-git-send-email-f.fainelli@gmail.com> <54FDF2EE.4070700@roeck-us.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, vivien.didelot@savoirfairelinux.com,
	jerome.oufella@savoirfairelinux.com, andrew@lunn.ch,
	cphealy@gmail.com, mathieu@codeaurora.org, jonasj76@gmail.com,
	andrey.volkov@nexvision.fr, Chris.Packham@alliedtelesis.co.nz
To: Guenter Roeck <linux@roeck-us.net>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f182.google.com ([209.85.192.182]:41698 "EHLO
	mail-pd0-f182.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752581AbbCITba (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 9 Mar 2015 15:31:30 -0400
Received: by pdjy10 with SMTP id y10so27287322pdj.8
        for <netdev@vger.kernel.org>; Mon, 09 Mar 2015 12:31:30 -0700 (PDT)
In-Reply-To: <54FDF2EE.4070700@roeck-us.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 09/03/15 12:22, Guenter Roeck wrote:
> On 03/09/2015 12:02 PM, Florian Fainelli wrote:
>> Add a helper function which allows getting the struct net_device pointer
>> associated with a given struct device_node pointer. This is useful for
>> instance for DSA Ethernet devices not backed by a platform_device, but
>> a PCI
>> device.
>>
>> Since we need to access net_class which is not accessible outside of
>> net/core/net-sysfs.c, this helper function is also added here and gated
>> with CONFIG_OF_NET.
>>
>> Network devices initialized with SET_NETDEV_DEV() are also taken into
>> account by checking for dev->parent first and then falling back to
>> checking the device pointer within struct net_device.
>>
>> Signed-off-by: Florian Fainelli <f.fainelli@gmail.com>
>> ---
>>   include/linux/of_net.h |  8 ++++++++
>>   net/core/net-sysfs.c   | 25 +++++++++++++++++++++++++
>>   2 files changed, 33 insertions(+)
>>
>> diff --git a/include/linux/of_net.h b/include/linux/of_net.h
>> index 34597c8c1a4c..395e2d55c16e 100644
>> --- a/include/linux/of_net.h
>> +++ b/include/linux/of_net.h
>> @@ -9,8 +9,11 @@
>>
>>   #ifdef CONFIG_OF_NET
>>   #include <linux/of.h>
>> +
>> +struct net_device;
>>   extern int of_get_phy_mode(struct device_node *np);
>>   extern const void *of_get_mac_address(struct device_node *np);
>> +extern struct net_device *of_find_net_device_by_node(struct
>> device_node *np);
>>   #else
>>   static inline int of_get_phy_mode(struct device_node *np)
>>   {
>> @@ -21,6 +24,11 @@ static inline const void *of_get_mac_address(struct
>> device_node *np)
>>   {
>>       return NULL;
>>   }
>> +
>> +static inline struct net_device *of_find_net_device_by_node(struct
>> device_node *np)
> 
> Checkpatch warning (line too long)
> 
>> +{
>> +    return NULL
>> +};
> 
> ; after } is unusual, and you need to add ; after NULL to get this to
> compile.

Good catch, thanks, I can't pretend I compiled the !OF_NET case, can I?

> 
>>   #endif
>>
>>   #endif /* __LINUX_OF_NET_H */
>> diff --git a/net/core/net-sysfs.c b/net/core/net-sysfs.c
>> index f2aa73bfb0e4..cf30620a88e1 100644
>> --- a/net/core/net-sysfs.c
>> +++ b/net/core/net-sysfs.c
>> @@ -23,6 +23,7 @@
>>   #include <linux/export.h>
>>   #include <linux/jiffies.h>
>>   #include <linux/pm_runtime.h>
>> +#include <linux/of.h>
>>
>>   #include "net-sysfs.h"
>>
>> @@ -1374,6 +1375,30 @@ static struct class net_class = {
>>       .namespace = net_namespace,
>>   };
>>
>> +#ifdef CONFIG_OF_NET
>> +static int of_dev_node_match(struct device *dev, const void *data)
>> +{
>> +    int ret = 0;
>> +
>> +    if (dev->parent)
>> +        ret = dev->parent->of_node == data;
>> +
>> +    return ret == 0 ? dev->of_node == data : ret;
> 
>     return ret ? : dev->of_node == data;
> 
> but that is really a matter of personal preference.

I kind of prefer treating the positive case as explicit, but either way
is fine.
-- 
Florian
