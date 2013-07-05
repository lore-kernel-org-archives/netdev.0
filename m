From: Robert Hancock <hancockrwd@gmail.com>
Subject: KVM VM shutdown triggers BUG from network bridge code in 3.9.9
Date: Thu, 04 Jul 2013 22:30:36 -0600
Message-ID: <51D64BEC.7090208@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
To: stephen@networkplumber.org, netdev <netdev@vger.kernel.org>,
	linux-kernel <linux-kernel@vger.kernel.org>,
	David Miller <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

I've run into a problem after updating to Fedora 19 where if I shut down 
a Windows 7 KVM virtual machine, the machine hits a kernel panic. There 
are a few reports of this on 3.9.8 and 3.9.9 kernels here:

https://bugzilla.redhat.com/show_bug.cgi?id=981437

The panic is "kernel BUG at kernel/timer.c:729!" and the stack traces 
all seem basically the same, something like this one (captured with kdump):

  #7 [ffff880214d25c10] mod_timer+501 at ffffffff8106d905
  #8 [ffff880214d25c50] br_multicast_del_pg.isra.20+261 at 
ffffffffa0731d25 [bridge]
  #9 [ffff880214d25c80] br_multicast_disable_port+88 at ffffffffa0732948 
[bridge]
#10 [ffff880214d25cb0] br_stp_disable_port+154 at ffffffffa072bcca [bridge]
#11 [ffff880214d25ce8] br_device_event+520 at ffffffffa072a4e8 [bridge]
#12 [ffff880214d25d18] notifier_call_chain+76 at ffffffff8164aafc
#13 [ffff880214d25d50] raw_notifier_call_chain+22 at ffffffff810858f6
#14 [ffff880214d25d60] call_netdevice_notifiers+45 at ffffffff81536aad
#15 [ffff880214d25d80] dev_close_many+183 at ffffffff81536d17
#16 [ffff880214d25dc0] rollback_registered_many+168 at ffffffff81537f68
#17 [ffff880214d25de8] rollback_registered+49 at ffffffff81538101
#18 [ffff880214d25e10] unregister_netdevice_queue+72 at ffffffff815390d8
#19 [ffff880214d25e30] __tun_detach+272 at ffffffffa074c2f0 [tun]
#20 [ffff880214d25e88] tun_chr_close+45 at ffffffffa074c4bd [tun]
#21 [ffff880214d25ea8] __fput+225 at ffffffff8119b1f1
#22 [ffff880214d25ef0] ____fput+14 at ffffffff8119b3fe
#23 [ffff880214d25f00] task_work_run+159 at ffffffff8107cf7f
#24 [ffff880214d25f30] do_notify_resume+97 at ffffffff810139e1
#25 [ffff880214d25f50] int_signal+18 at ffffffff8164f292

It seems like the error is being triggered by the virtual network 
interface being torn down, though I have no idea why (from all reports 
so far) it only happens when shutting down a Windows 7 VM, or why this 
didn't happen in Fedora 18 (something to do with older kvm/qemu/libvirt 
perhaps..)
