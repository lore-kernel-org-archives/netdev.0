From: David Brownell <david-b@pacbell.net>
Subject: 2.5.50 BUG_TRAP on !dev->deadbeaf, and oopses
Date: Sat, 30 Nov 2002 13:09:30 -0800
Sender: netdev-bounce@oss.sgi.com
Message-ID: <3DE9290A.7070502@pacbell.net>
Mime-Version: 1.0
Content-Type: text/plain; format=flowed; charset=us-ascii
Content-Transfer-Encoding: 7bit
Return-path: <netdev-bounce@oss.sgi.com>
To: netdev@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Since sometime before 2.5.4x kernels, many of the usb networking drivers
running on 2.5 tend to trigger trouble like this (full text appended)
when they unplug.  The drivers in question didn't change how they talked
to the network stack; the stack started to complain, and oopses started:

   KERNEL: assertion (!dev->deadbeaf) failed at net/core/dev.c(2544)

I think there's another bug, beyond the obvious speling erorz.  Namely,
that "deadbeaf" is only set after that BUG_TRAP, or on one error path.
The assertion prevents hotpluggable network drivers from unregistering
when the hardware goes away ... which is a regression.

For now I'm just commenting out that broken assertion, but I wonder
if a better fix wouldn't be a "no deadbeaf" diet for the kernel.  But
there might be more problems than that.


The next message I got (at least in this 2.5.50 oops) was

   unregister_netdevice: device /dfd74058 never was registered

That's odd because we know for a fact that the earlier call to
register_netdev() returned.  Something got deeply confused,
and likely that caused the oops.

I remember seeing similar failures with the 'pegasus' driver,
with the "deadbeaf" problem and an oops, but I don't remember
whether those oopses were at all like this one (or gave that
"never registered" message).

Since there have been 2.5 kernels, using essentially identical
drivers, that don't trigger any of those problems, I'm wondering
what's up..  I'm suspecting the networking code caused all of
these, now that the sysfs-related bugs in usbcore (which caused
different unplug problems) seem to be mostly gone.  Suggestions?

- Dave


Here's the full trace, pretty typical of what I've seen when
unplugging those network devices:


KERNEL: assertion (!dev->deadbeaf) failed at net/core/dev.c(2544)
unregister_netdevice: device /dfd74058 never was registered
eip: c0107bf0
------------[ cut here ]------------
kernel BUG at include/asm/spinlock.h:123!
invalid operand: 0000
CPU:    0
EIP:    0060:[<c0107c4f>]    Tainted: G S
EFLAGS: 00010086
EIP is at __down+0x5f/0x1c0
eax: 0000000e   ebx: dfd74034   ecx: 00000000   edx: 0000ac2c
esi: dfd74034   edi: dfd7402c   ebp: 00000286   esp: db5dde38
ds: 0068   es: 0068   ss: 0068
Process khubd (pid: 913, threadinfo=db5dc000 task=d64eb940)
Stack: c027b05c c0107bf0 d64eb940 00000000 d64eb940 c011bec0 00000000 00000000
        dfd74058 dfd74058 dfa5c504 dfd74034 e08897e0 dfd7402c db5dde84 c010807b
        dfd74034 00000000 00000000 c6f7e000 e08897a8 e088991e 00000077 e0854302
Call Trace:
  [<c0107bf0>] __down+0x0/0x1c0
  [<c011bec0>] default_wake_function+0x0/0x40
  [<e08897e0>] +0x0/0x18 [usbnet]
  [<c010807b>] __down_failed+0xb/0x14
  [<e08897a8>] .text.lock.usbnet+0x9b/0xd3 [usbnet]
  [<e088991e>] +0x36/0x2d8 [usbnet]
  [<e0854302>] +0x36/0x1174 [usbcore]
  [<e0889820>] usbnet_driver+0x0/0xc0 [usbnet]
  [<e0889820>] usbnet_driver+0x0/0xc0 [usbnet]
  [<e0846248>] usb_device_remove+0xc8/0x140 [usbcore]
  [<e0889838>] usbnet_driver+0x18/0xc0 [usbnet]
  [<c01c8a52>] detach+0x42/0x50
  [<e085a360>] usb_bus_type+0x0/0x120 [usbcore]
  [<e085a394>] usb_bus_type+0x34/0x120 [usbcore]
  [<c01c8a70>] device_detach+0x10/0x20
  [<e0889838>] usbnet_driver+0x18/0xc0 [usbnet]
  [<c01c8bca>] bus_remove_device+0x5a/0xb0
  [<c01c8138>] device_del+0x78/0xa0
  [<c01c816b>] device_unregister+0xb/0x16
  [<e0846b55>] usb_disconnect+0x95/0xf0 [usbcore]
  [<e0849250>] usb_hub_port_connect_change+0xa0/0x2c0 [usbcore]
  [<e084965b>] usb_hub_events+0x1eb/0x420 [usbcore]
  [<e0857300>] +0x1ec0/0x3d20 [usbcore]
  [<e08498c5>] usb_hub_thread+0x35/0x100 [usbcore]
  [<c01091c9>] ret_from_fork+0x5/0x14
  [<c011bec0>] default_wake_function+0x0/0x40
  [<e085a4b8>] khubd_wait+0x8/0x10 [usbcore]
  [<e085a4b8>] khubd_wait+0x8/0x10 [usbcore]
  [<e0849890>] usb_hub_thread+0x0/0x100 [usbcore]
  [<c0107029>] kernel_thread_helper+0x5/0xc

Code: 0f 0b 7b 00 44 af 27 c0 59 5b 8d b4 26 00 00 00 00 f0 fe 4e
  <6>note: khubd[913] exited with preempt_count 1


Note that killing khubd() like that meant that no usb
device connects or disconnects can be processed again
without rebooting.
