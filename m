From: Keiichi KII <k-keiichi@bx.jp.nec.com>
Subject: Re: [RFC][PATCH -mm take5 4/7] using symlink for the net_device
Date: Tue, 19 Jun 2007 19:04:19 +0900
Message-ID: <4677AA23.1080708@bx.jp.nec.com>
References: <466FC455.5060001@bx.jp.nec.com> <466FC6ED.9060208@bx.jp.nec.com>	 <a781481a0706130949j7b35e33ds9cda5d8a551c9d7d@mail.gmail.com> <a781481a0706131203g405a4407y1212bb397f14e8eb@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Matt Mackall <mpm@selenic.com>,
	Andrew Morton <akpm@linux-foundation.org>,
	David Miller <davem@davemloft.net>,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org
To: Satyam Sharma <satyam.sharma@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from TYO201.gate.nec.co.jp ([202.32.8.193]:51234 "EHLO
	tyo201.gate.nec.co.jp" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758689AbXFSKEd (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 19 Jun 2007 06:04:33 -0400
In-Reply-To: <a781481a0706131203g405a4407y1212bb397f14e8eb@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hello Satyam,

> and this is why we have to use the dual-list mechanism to react to the net
> device rename. This isn't so obvious, a comment at the point where you
> declare modify_target_list would be nice? (BTW temporary_list would be
> a better name for that, IMO)

All right, my patches are short of comments. So, I will add comments 
to the ambiguous codes.

> Ok, so reading through the code makes it obvious that this mutex is used
> to protect against the following race:
> 
> Thread #1                               Thread #2
> =========                               =========
> 
> [ NETDEV_CHANGENAME notifier ]          [ ioctl(NETCON_REMOVE_TARGET) ]
> 
> netconsole_event()
> move from target_list to temp list
> work on temp list
>                                        kobject_unregister()
>                                        -> release_target()
>                                           -> remove_target()
> move back to target_list
> 
> Which would mean a deleted/removed target added back => *boom*
> 
> But, the race still hasn't been closed properly!
> 
> You're taking the mutex only around "work on temp list" which is
> insufficient, you need to ensure atomicity inside netconsole_event()
> _completely_ like this (renaming netdev_change_sem to
> netdev_changename_mtx):

After the target moves from target_list to temporary_list, 
the kobject_unregister() of possible raced target isn't called 
in ioctl(NETCON_REMOVE_TARGET) because the target_list doesn't contain 
the target .

I have the wrong idea?

>> +static char *make_netdev_class_name(char *netdev_name)
>> +{
>> +       char *name;
>> +
>> +       name = kasprintf(GFP_KERNEL, "net:%s", netdev_name);
> 
> Why the "net:" prefix in the filename?

Because I drew upon dev_change_name() method in net/core/dev.c.
The device_rename() in the above function makes use of same prefix 
related to netdev.

>>  static int setup_target_sysfs(struct netconsole_target *nt)
>>  {
>> +       int retval = 0;
>> +       char *name;
>> +
>>         kobject_set_name(&nt->obj, "port%d", nt->id);
>>         nt->obj.parent = &netconsole_miscdev.this_device->kobj;
>>         nt->obj.ktype = &target_ktype;
>> -       return kobject_register(&nt->obj);
>> +       retval = kobject_register(&nt->obj);
>> +       name = make_netdev_class_name(nt->np.dev_name);
>> +       if (!name)
>> +               return -ENOMEM;
> 
> Just call kasprintf() directly, why the obfuscation?
> 

I drew upon dev_change_name() method in net/core/dev.c.

Thanks
-- 
Keiichi KII
NEC Corporation OSS Platform Development Division
E-mail: k-keiichi@bx.jp.nec.com


