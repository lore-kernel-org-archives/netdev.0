From: Stephen Hemminger <stephen@networkplumber.org>
Subject: Re: [E1000-devel] [net-next v4 7/8] i40e: sysfs and debugfs
 interfaces
Date: Wed, 4 Sep 2013 17:37:59 -0700
Message-ID: <20130904173759.7c2eec52@nehalam.linuxnetplumber.net>
References: <1378336629-24224-1-git-send-email-jeffrey.t.kirsher@intel.com>
	<1378336629-24224-8-git-send-email-jeffrey.t.kirsher@intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, e1000-devel@lists.sourceforge.net,
	netdev@vger.kernel.org,
	Jesse Brandeburg <jesse.brandeburg@intel.com>,
	gospo@redhat.com, sassmann@redhat.com
To: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pb0-f43.google.com ([209.85.160.43]:52662 "EHLO
	mail-pb0-f43.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1760774Ab3IEAiE (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 4 Sep 2013 20:38:04 -0400
Received: by mail-pb0-f43.google.com with SMTP id md4so1047260pbc.16
        for <netdev@vger.kernel.org>; Wed, 04 Sep 2013 17:38:02 -0700 (PDT)
In-Reply-To: <1378336629-24224-8-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


I don't think you need this. If you put a NULL pointer in for the __ATTR()
then it will do the right thing for you.

> +/**
> + * i40e_sys_store_ro - callback for readonly attributes in sysfs
> + * @kobj: object in the sysfs model
> + * @attr: attribute being read
> + * @buf: buffer to put data
> + * @count: buffer size
> + **/
> +static ssize_t i40e_sys_store_ro(struct kobject *kobj,
> +				 struct kobj_attribute *attr,
> +				 const char *buf, size_t count)
> +{
> +	return -1;
> +}
> +

These are bogus, just return an error code or make don't define
the file in the first place. Returning error in contents
is not useful for programmatic usage.

> +
> +/**
> + * i40e_sys_veb_svlan_read - read the VEB svlan
> + **/
> +static ssize_t i40e_sys_veb_svlan_read(struct kobject *kobj,
> +				       struct kobj_attribute *attr,
> +				       char *buf)
> +{
> +	return snprintf(buf, PAGE_SIZE, "(not implemented)\n");
> +}
> +

The store routines should all be checking for permissions.

	if (!ns_capable(net->user_ns, CAP_NET_ADMIN))
		return -EPERM;


The sysfs API is doing writes to device state without locking.
You probably want to do:
	if (!rtnl_trylock())
		return restart_syscall();

...
	rtnl_unlock();


Also, anything in sysfs is device specific and you really need to make
a strong case for why your device is special and needs an exception.
Other devices will have hardware switches and doing something through
sysfs is going to create a pain for any controller application.

I vote against including the sysfs VEB stuff because it will become
a lifetime ABI.
