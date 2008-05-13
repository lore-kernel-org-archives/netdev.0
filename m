From: Benjamin Thery <benjamin.thery@bull.net>
Subject: Re: kobject: Fix kobject_rename and !CONFIG_SYSFS
Date: Tue, 13 May 2008 16:25:01 +0200
Message-ID: <4829A4BD.3020007@bull.net>
References: <m163tocw43.fsf_-_@frodo.ebiederm.org>	<20080512220232.GA16914@kroah.com> <m1prrqbseh.fsf@frodo.ebiederm.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Greg KH <greg@kroah.com>, Randy Dunlap <randy.dunlap@oracle.com>,
	Greg KH <gregkh@suse.de>,
	Andrew Morton <akpm@linux-foundation.org>,
	linux-kernel@vger.kernel.org, Tejun Heo <htejun@gmail.com>,
	Al Viro <viro@ftp.linux.org.uk>,
	Daniel Lezcano <dlezcano@fr.ibm.com>,
	"Serge E. Hallyn" <serue@us.ibm.com>,
	Pavel Emelyanov <xemul@openvz.org>, netdev@vger.kernel.org
To: "Eric W. Biederman" <ebiederm@xmission.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ecfrec.frec.bull.fr ([129.183.4.8]:55231 "EHLO
	ecfrec.frec.bull.fr" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756924AbYEMOYk (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 13 May 2008 10:24:40 -0400
In-Reply-To: <m1prrqbseh.fsf@frodo.ebiederm.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Eric W. Biederman wrote:
> Greg KH <greg@kroah.com> writes:
> 
>> Eric, Randy Dunlap has found that this patch breaks the build when
>> CONFIG_SYSFS is not enabled.  Can you please fix it up before I send it
>> to Linus?
>>
>> The exact error is:
>> In file included from /local/linsrc/next-20080509/include/linux/kobject.h:21,
>>                  from /local/linsrc/next-20080509/include/linux/module.h:16,
>>                  from /local/linsrc/next-20080509/include/linux/crypto.h:21,
>>                  from
>> /local/linsrc/next-20080509/arch/x86/kernel/asm-offsets_64.c:7,
>>                  from
>> /local/linsrc/next-20080509/arch/x86/kernel/asm-offsets.c:4:
>> /local/linsrc/next-20080509/include/linux/sysfs.h: In function
>> 'sysfs_rename_dir':
>> /local/linsrc/next-20080509/include/linux/sysfs.h:142: error: implicit
>> declaration of function 'kobject_set_name'
> 
> I will take a look in the morning and see if I can see what is wrong.
> 
> Which tree was this error against?  I thought I tested this case,
> and I'm wondering if there might be another patch that is hiding
> kobject_set_name.

Argh, headers "cross-dependencies":

* linux/kobject.h includes linux/sysfs.h before defining
   kobject_set_name()

* linux/sysfs.h needs to include linux/kobject.h to find
   kobject_set_name() definition (for inlined sysfs_rename_dir() when
   CONFIG_SYSFS=n)


sysfs_rename_dir() is only called by kobject.c, kobject_rename().
I guess this kind of patch is not acceptable to fix the depency?


Index: linux-2.6/lib/kobject.c
===================================================================
--- linux-2.6.orig/lib/kobject.c        2008-05-13 15:14:38.000000000 +0200
+++ linux-2.6/lib/kobject.c     2008-05-13 15:58:37.000000000 +0200
@@ -416,8 +416,11 @@ int kobject_rename(struct kobject *kobj,
         envp[0] = devpath_string;
         envp[1] = NULL;

+#ifdef CONFIG_SYSFS
         error = sysfs_rename_dir(kobj, new_name);
-
+#else
+       error = kobject_set_name(kobj, "%s", new_name);
+#endif
         /* This function is mostly/only used for network interface.
          * Some hotplug package track interfaces by their name and
          * therefore want to know when the name is changed by the user. */


-Benjamin

> 
> Eric
> 
> 


-- 
B e n j a m i n   T h e r y  - BULL/DT/Open Software R&D

    http://www.bull.com
