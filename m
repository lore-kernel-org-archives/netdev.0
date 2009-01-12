From: Li Zefan <lizf@cn.fujitsu.com>
Subject: Re: [Devel] Re: [RFC][PATCH] IP address restricting cgroup subsystem
Date: Mon, 12 Jan 2009 10:20:16 +0800
Message-ID: <496AA8E0.2070002@cn.fujitsu.com>
References: <20090106230554.GB25228@eskarina.localdomain.pl>	 <49644526.8030205@cn.fujitsu.com> <20090107073831.GA23648@megiteam.pl>	 <49646993.6080802@cn.fujitsu.com> <20090107091600.GA17612@megiteam.pl>	 <496476FD.8090209@cn.fujitsu.com>	 <6599ad830901091338t38f5d5bav6adcd55ea188e28d@mail.gmail.com>	 <49682921.4020100@cn.fujitsu.com> <6599ad830901100814g5faeb611v7a36eed987c103ff@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: Grzegorz Nosek <root@localdomain.pl>, containers@lists.osdl.org,
	netdev@vger.kernel.org
To: Paul Menage <menage@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from cn.fujitsu.com ([222.73.24.84]:52190 "EHLO song.cn.fujitsu.com"
	rhost-flags-OK-FAIL-OK-OK) by vger.kernel.org with ESMTP
	id S1751174AbZALCVM (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 11 Jan 2009 21:21:12 -0500
In-Reply-To: <6599ad830901100814g5faeb611v7a36eed987c103ff@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Paul Menage wrote:
> On Fri, Jan 9, 2009 at 8:50 PM, Li Zefan <lizf@cn.fujitsu.com> wrote:
>>> For checking the "children" list, you can just lock
>>> ipaddr_subsys.hierarchy_mutex.
>>>
>> Unfortunately hierarchy_mutex can't be used here, since hierarchy_mutex
>> doesn't protect subsys's create() method, and the create() will access
>> parent cgroup's data.
>>
> 
> But that can be solved by putting a spinlock in the ipaddr_cgroup
> structure and taking it in the write handler (and the connect/bind
> handlers, which should also be using RCU), and taking the parent
> structure's lock before copying from it in the create callback. No
> need for something as heavy as cgroup_lock().
> 

Still won't work. :(

================
lock(ipaddr_subsys.hierarchy_mutex);

if (list_empty(&cgrp->children) &&
    parent->ipv4_addr == INADDR_ANY)
						create()
						  parent->spin_lock();
						  cgrp->ipv4_addr = parent->ipv4_addr;
						  parent->spin_unlock();
	ipcgroup->spin_lock();
	ipcgroup->ipv4_addr = new_addr;
	ipcgroup->spin_unlock();

unlock(ipaddr_subsys.hierarchy_mutex);
						list_add(&cgrp->sibling, &cgrp->parent->children);
================

And neither can it work to hold hierarchy_mutex in subsys's create().

I think the only way to make hierarchy_mutex works for this issue is:

@@ -2403,16 +2403,18 @@ static long cgroup_create(struct cgroup *parent, struct
        if (notify_on_release(parent))
                set_bit(CGRP_NOTIFY_ON_RELEASE, &cgrp->flags);

+       cgroup_lock_hierarchy(root);
+
        for_each_subsys(root, ss) {
                struct cgroup_subsys_state *css = ss->create(ss, cgrp);
                if (IS_ERR(css)) {
+                       cgroup_unlock_hierarchy(root);
                        err = PTR_ERR(css);
                        goto err_destroy;
                }
                init_cgroup_css(css, ss, cgrp);
        }

-       cgroup_lock_hierarchy(root);
        list_add(&cgrp->sibling, &cgrp->parent->children);
        cgroup_unlock_hierarchy(root);
        root->number_of_cgroups++;


