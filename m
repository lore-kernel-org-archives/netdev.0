From: ebiederm@xmission.com (Eric W. Biederman)
Subject: Re: [PATCH 2/6] netns: Teach network device kobjects which namespace they are in.
Date: Wed, 05 May 2010 12:56:41 -0700
Message-ID: <m14oim2kcm.fsf@fess.ebiederm.org>
References: <m1fx3hk6gw.fsf@fess.ebiederm.org>
	<1273019809-16472-2-git-send-email-ebiederm@xmission.com>
	<20100505151746.GA15654@us.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Greg Kroah-Hartman <gregkh@suse.de>,
	Kay Sievers <kay.sievers@vrfy.org>,
	linux-kernel@vger.kernel.org, Tejun Heo <tj@kernel.org>,
	Cornelia Huck <cornelia.huck@de.ibm.com>,
	Eric Dumazet <eric.dumazet@gmail.com>,
	Benjamin LaHaise <bcrl@lhnet.ca>, netdev@vger.kernel.org,
	David Miller <davem@davemloft.net>
To: "Serge E. Hallyn" <serue@us.ibm.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20100505151746.GA15654@us.ibm.com> (Serge E. Hallyn's message of "Wed\, 5 May 2010 10\:17\:46 -0500")
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

"Serge E. Hallyn" <serue@us.ibm.com> writes:

> Quoting Eric W. Biederman (ebiederm@xmission.com):
>> diff --git a/net/Kconfig b/net/Kconfig
>> index 041c35e..265e33b 100644
>> --- a/net/Kconfig
>> +++ b/net/Kconfig
>> @@ -45,6 +45,14 @@ config COMPAT_NETLINK_MESSAGES
>> 
>>  menu "Networking options"
>> 
>> +config NET_NS
>> +	bool "Network namespace support"
>> +	default n
>> +	depends on EXPERIMENTAL && NAMESPACES
>> +	help
>> +	  Allow user space to create what appear to be multiple instances
>> +	  of the network stack.
>> +
>
> Hi Eric,
>
> I'm confused - NET_NS is defined in init/Kconfig right now.  Is the tree
> you're working from very different from mine, or is this the unfortunate
> rekult of the patches sitting so long?

Old patches, nothing that complains when you make a mistake like this,
and apparently I have a blind spot in my personal code review.

At one point it was not possible to enable the network namespace until
the sysfs stuff was enabled, but things have been going on long enough
that we worked around that restriction.

>>  source "net/packet/Kconfig"
>>  source "net/unix/Kconfig"
>>  source "net/xfrm/Kconfig"
>> diff --git a/net/core/net-sysfs.c b/net/core/net-sysfs.c
>> index 099c753..1b98e36 100644
>> --- a/net/core/net-sysfs.c
>> +++ b/net/core/net-sysfs.c
>> @@ -13,7 +13,9 @@
>>  #include <linux/kernel.h>
>>  #include <linux/netdevice.h>
>>  #include <linux/if_arp.h>
>> +#include <linux/nsproxy.h>
>>  #include <net/sock.h>
>> +#include <net/net_namespace.h>
>>  #include <linux/rtnetlink.h>
>>  #include <linux/wireless.h>
>>  #include <net/wext.h>
>> @@ -466,6 +468,37 @@ static struct attribute_group wireless_group = {
>>  };
>>  #endif
>> 
>> +static const void *net_current_ns(void)
>> +{
>> +	return current->nsproxy->net_ns;
>> +}
>> +
>> +static const void *net_initial_ns(void)
>> +{
>> +	return &init_net;
>> +}
>> +
>> +static const void *net_netlink_ns(struct sock *sk)
>> +{
>> +	return sock_net(sk);
>> +}
>> +
>> +static struct kobj_ns_type_operations net_ns_type_operations = {
>> +	.type = KOBJ_NS_TYPE_NET,
>> +	.current_ns = net_current_ns,
>> +	.netlink_ns = net_netlink_ns,
>> +	.initial_ns = net_initial_ns,
>> +};
>> +
>> +static void net_kobj_ns_exit(struct net *net)
>> +{
>> +	kobj_ns_exit(KOBJ_NS_TYPE_NET, net);
>> +}
>> +
>> +static struct pernet_operations sysfs_net_ops = {
>> +	.exit = net_kobj_ns_exit,
>> +};
>> +
>>  #endif /* CONFIG_SYSFS */
>
> ...
>
>>  int netdev_kobject_init(void)
>>  {
>> +	kobj_ns_type_register(&net_ns_type_operations);
>> +#ifdef CONFIG_SYSFS
>> +	register_pernet_subsys(&sysfs_net_ops);
>> +#endif
>>  	return class_register(&net_class);
>
> I think the kobj_ns_type_register() needs to be under
> ifdef CONFIG_SYSFS as well, bc net_ns_type_operations is defined
> under ifdef CONFIG_SYSFS.

kobj_ns_type_register should not be under CONFIG_SYSFS.  Which means
that kobj_ns_type_operations needs not to be under CONFIG_SYSFS as
well.  That you for spotting that bug.

Grr.

Eric
