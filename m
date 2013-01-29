From: Cong Wang <xiyou.wangcong@gmail.com>
Subject: No sysfs directory for openvswitch module when built-in
Date: Tue, 29 Jan 2013 22:15:18 +0800
Message-ID: <CAM_iQpVgEchb8UsxUP=w6OMbYx=zuP2yv=QwFhe8rPCbNBreVg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: LKML <linux-kernel@vger.kernel.org>,
	Linux Kernel Network Developers <netdev@vger.kernel.org>
To: Rusty Russell <rusty@rustcorp.com.au>,
	Jesse Gross <jesse@nicira.com>,
	"David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-vb0-f45.google.com ([209.85.212.45]:61153 "EHLO
	mail-vb0-f45.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753628Ab3A2OPT (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 29 Jan 2013 09:15:19 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello, Rusty, Jesse,

I met an interesting problem when I compile openvswitch module as a
built-in (actually I compile ALL kernel modules as built-in), there is
no /sys/module/openvswitch/ directory created by the kernel in this
case.

What's worse, the user-space init script thinks openvswitch module is
not loaded by checking the exist of this directory, therefore refuses
to start.

After digging a little deeper, I found the cause of this problem is
actually that the core kernel doesn't create directory for any kernel
module without a module version or any module parameters when
built-in. Openvswitch is exactly such a module!!

I believe there is nothing wrong either in the user-space init script,
or in the openvswitch kernel module. So, the question why core kernel
doesn't create module directory for such modules?

>From the code:

static int __init param_sysfs_init(void)
{
        module_kset = kset_create_and_add("module", &module_uevent_ops, NULL);
        if (!module_kset) {
                printk(KERN_WARNING "%s (%d): error creating kset\n",
                        __FILE__, __LINE__);
                return -ENOMEM;
        }
        module_sysfs_initialized = 1;

        version_sysfs_builtin();
        param_sysfs_builtin();

        return 0;
}

it seems there is no way to get the name of the kernel module in such
case, the above searches module name either in parameter or in version
information. But I may miss something here...

We can certainly workaround this issue by providing a (dummy) version
in openvswitch module, but the more important question is can't we fix
this in core kernel? It is perfectly valid to provide a kernel module
without either a module version or any module parameter.

What do you think?

Thanks!
