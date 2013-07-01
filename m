From: Jiri Pirko <jiri@resnulli.us>
Subject: Re: [patch net-next] nlmon: use standard rtnetlink link api for add/del devices
Date: Mon, 1 Jul 2013 18:46:58 +0200
Message-ID: <57A93F4E-A5CF-42D7-B4D0-14EF54E7E83D@resnulli.us>
References: <1372691242-9365-1-git-send-email-jiri@resnulli.us> <51D1ACF0.40802@redhat.com>
Mime-Version: 1.0 (1.0)
Content-Type: text/plain;
	charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"davem@davemloft.net" <davem@davemloft.net>
To: Daniel Borkmann <dborkman@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ea0-f173.google.com ([209.85.215.173]:39539 "EHLO
	mail-ea0-f173.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752769Ab3GAQrE (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 1 Jul 2013 12:47:04 -0400
Received: by mail-ea0-f173.google.com with SMTP id g15so2207678eak.32
        for <netdev@vger.kernel.org>; Mon, 01 Jul 2013 09:47:02 -0700 (PDT)
In-Reply-To: <51D1ACF0.40802@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


1. 7. 2013 v 18:23, Daniel Borkmann <dborkman@redhat.com>:

> On 07/01/2013 05:07 PM, Jiri Pirko wrote:
>> It is not nice when netdev is created right after module load and with
>> some implicit name. So rather change nlmon to use standard rtnl link API.
>> 
>> Signed-off-by: Jiri Pirko <jiri@resnulli.us>
>> ---
>>  drivers/net/nlmon.c | 48 +++++++++++++++++++++++++++---------------------
>>  1 file changed, 27 insertions(+), 21 deletions(-)
>> 
>> diff --git a/drivers/net/nlmon.c b/drivers/net/nlmon.c
>> index a0baf56..59fbac5 100644
>> --- a/drivers/net/nlmon.c
>> +++ b/drivers/net/nlmon.c
>> @@ -4,6 +4,7 @@
>>  #include <linux/netlink.h>
>>  #include <net/net_namespace.h>
>>  #include <linux/if_arp.h>
>> +#include <net/rtnetlink.h>
>> 
>>  struct pcpu_lstats {
>>      u64 packets;
>> @@ -56,16 +57,23 @@ static void nlmon_dev_uninit(struct net_device *dev)
>>      free_percpu(dev->lstats);
>>  }
>> 
>> -static struct netlink_tap nlmon_tap;
>> +struct nlmon {
>> +    struct netlink_tap nt;
>> +};
>> 
>>  static int nlmon_open(struct net_device *dev)
>>  {
>> -    return netlink_add_tap(&nlmon_tap);
>> +    struct nlmon *nlmon = netdev_priv(dev);
>> +
>> +    nlmon->nt.module = THIS_MODULE;
> 
> nlmon->nt.dev = dev;
> 
> .. is missing here I think, otherwise looks good.
> 

Right, will fix that.

>> +    return netlink_add_tap(&nlmon->nt);
>>  }
>> 
>>  static int nlmon_close(struct net_device *dev)
>>  {
>> -    return netlink_remove_tap(&nlmon_tap);
>> +    struct nlmon *nlmon = netdev_priv(dev);
>> +
>> +    return netlink_remove_tap(&nlmon->nt);
>>  }
>> 
>>  static struct rtnl_link_stats64 *
>> @@ -119,10 +127,6 @@ static const struct net_device_ops nlmon_ops = {
>>      .ndo_change_mtu = nlmon_change_mtu,
>>  };
>> 
>> -static struct netlink_tap nlmon_tap __read_mostly = {
>> -    .module = THIS_MODULE,
>> -};
>> -
>>  static void nlmon_setup(struct net_device *dev)
>>  {
>>      dev->type = ARPHRD_NETLINK;
>> @@ -142,27 +146,28 @@ static void nlmon_setup(struct net_device *dev)
>>      dev->mtu = NLMSG_GOODSIZE;
>>  }
>> 
>> -static __init int nlmon_register(void)
>> +static int nlmon_validate(struct nlattr *tb[], struct nlattr *data[])
>>  {
>> -    int err;
>> -    struct net_device *nldev;
>> -
>> -    nldev = nlmon_tap.dev = alloc_netdev(0, "netlink", nlmon_setup);
>> -    if (unlikely(nldev == NULL))
>> -        return -ENOMEM;
>> +    if (tb[IFLA_ADDRESS])
>> +        return -EINVAL;
>> +    return 0;
>> +}
>> 
>> -    err = register_netdev(nldev);
>> -    if (unlikely(err))
>> -        free_netdev(nldev);
>> +static struct rtnl_link_ops nlmon_link_ops __read_mostly = {
>> +    .kind            = "nlmon",
>> +    .priv_size        = sizeof(struct nlmon),
>> +    .setup            = nlmon_setup,
>> +    .validate        = nlmon_validate,
>> +};
>> 
>> -    return err;
>> +static __init int nlmon_register(void)
>> +{
>> +    return rtnl_link_register(&nlmon_link_ops);
>>  }
>> 
>>  static __exit void nlmon_unregister(void)
>>  {
>> -    struct net_device *nldev = nlmon_tap.dev;
>> -
>> -    unregister_netdev(nldev);
>> +    rtnl_link_unregister(&nlmon_link_ops);
>>  }
>> 
>>  module_init(nlmon_register);
>> @@ -172,3 +177,4 @@ MODULE_LICENSE("GPL v2");
>>  MODULE_AUTHOR("Daniel Borkmann <dborkman@redhat.com>");
>>  MODULE_AUTHOR("Mathieu Geli <geli@enseirb.fr>");
>>  MODULE_DESCRIPTION("Netlink monitoring device");
>> +MODULE_ALIAS_RTNL_LINK("nlmon");
>> 
