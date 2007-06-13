From: "Satyam Sharma" <satyam.sharma@gmail.com>
Subject: Re: [RFC][PATCH -mm take5 4/7] using symlink for the net_device
Date: Wed, 13 Jun 2007 22:19:39 +0530
Message-ID: <a781481a0706130949j7b35e33ds9cda5d8a551c9d7d@mail.gmail.com>
References: <466FC455.5060001@bx.jp.nec.com> <466FC6ED.9060208@bx.jp.nec.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: "Matt Mackall" <mpm@selenic.com>,
	"Andrew Morton" <akpm@linux-foundation.org>,
	"David Miller" <davem@davemloft.net>, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org
To: "Keiichi KII" <k-keiichi@bx.jp.nec.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from nz-out-0506.google.com ([64.233.162.237]:52582 "EHLO
	nz-out-0506.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758642AbXFMQtk (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 13 Jun 2007 12:49:40 -0400
Received: by nz-out-0506.google.com with SMTP id n1so283171nzf
        for <netdev@vger.kernel.org>; Wed, 13 Jun 2007 09:49:39 -0700 (PDT)
In-Reply-To: <466FC6ED.9060208@bx.jp.nec.com>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi,

On 6/13/07, Keiichi KII <k-keiichi@bx.jp.nec.com> wrote:
> [...]
> +static DECLARE_MUTEX(netdev_change_sem);

The preferred style these days is to use a DEFINE_MUTEX
(and the struct mutex primitives) for such locks that are used
as binary semaphores.

BTW, a comment here to note what this lock protects is required.
[ You don't really need to give a comment for the target_list_lock
because it's defined just below the "target_list". It's not equally obvious
at first glance what is protected by the netdev_change_sem, however. ]

> +       down(&netdev_change_sem);
> +       up(&netdev_change_sem);

So these become mutex_lock and mutex_unlock.

> +static int netconsole_event(struct notifier_block *this, unsigned long event,
> +                           void *ptr)
> +{
> +       int error = 0;
> +       unsigned long flags;
> +       char *old_link_name = NULL, *new_link_name = NULL;
> +       struct netconsole_target *nt, *tmp;
> +       struct net_device *dev = ptr;
> +       LIST_HEAD(modify_target_list);
> +
> +       if (event == NETDEV_CHANGENAME) {
> +               spin_lock_irqsave(&target_list_lock, flags);
> +               list_for_each_entry_safe(nt, tmp, &target_list, list)
> +                       if (nt->np.dev == dev)
> +                               list_move(&nt->list, &modify_target_list);
> +               spin_unlock_irqrestore(&target_list_lock, flags);
> +
> +               down(&netdev_change_sem);
> +               list_for_each_entry(nt, &modify_target_list, list) {
> +                       new_link_name = make_netdev_class_name(dev->name);
> +                       old_link_name = make_netdev_class_name(nt->np.dev_name);
> +                       if (!new_link_name || !old_link_name) {
> +                               printk(KERN_ERR "netconsole: "
> +                                      "make_netdev_class_name() failed!\n");
> +                               kfree(new_link_name);
> +                               kfree(old_link_name);
> +                               continue;

Sorry, but we're not covering from the error condition fully here. Note
that later you merge the temporary modify_target_list entirely back
into the target_list ... which would still contain these erroneous
nodes. A full cleanup (kobject_unregister the entry, and then list_del
from modify_target_list) is required here, before continuing.

> +                       }
> +                       sysfs_remove_link(&nt->obj, old_link_name);
> +                       error = sysfs_create_link(&nt->obj,
> +                                                 &nt->np.dev->dev.kobj,
> +                                                 new_link_name);
> +                       if (error)
> +                               printk(KERN_ERR "can't create link: %s\n",
> +                                      new_link_name);

Same here, a fuller cleanup is required to recover from the error
condition here, then kfree()'s and then stick a "continue;" here, else ...

> +                       strcpy(nt->np.dev_name, dev->name);

... you'll have move this up.

> +                       kfree(new_link_name);
> +                       kfree(old_link_name);
> +               }
> +               up(&netdev_change_sem);
> +
> +               spin_lock_irqsave(&target_list_lock, flags);
> +               list_for_each_entry_safe(nt, tmp, &modify_target_list, list)
> +                       list_move(&nt->list, &target_list);
> +               spin_unlock_irqrestore(&target_list_lock, flags);
> +       }
> +
> +       return NOTIFY_DONE;
> +}

Satyam
