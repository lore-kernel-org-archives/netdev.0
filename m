From: Sasha Levin <sasha.levin@oracle.com>
Subject: net: panic when removing device due to vrf
Date: Thu, 01 Oct 2015 18:50:34 -0400
Message-ID: <560DB8BA.9020700@oracle.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@davemloft.net>,
	LKML <linux-kernel@vger.kernel.org>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: dsa@cumulusnetworks.com
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi David,

Commit 93a7e7e837 ("net: Remove the now unused vrf_ptr") is causing a panic whenever
I unplug a network device:

[ 5657.008034] kernel BUG at net/core/dev.c:5219!
[ 5657.008034] invalid opcode: 0000 [#1] PREEMPT SMP DEBUG_PAGEALLOC KASAN
[ 5657.008034] Modules linked in:
[ 5657.008034] CPU: 4 PID: 25688 Comm: trinity-c134 Not tainted 4.3.0-rc3-next-20151001-sasha-00077-g0b55
fd2-dirty #2587
[ 5657.008034] task: ffff8800506e0000 ti: ffff880009340000 task.ti: ffff880009340000
[ 5657.008034] RIP: __netdev_adjacent_dev_remove (net/core/dev.c:5219)
[ 5657.008034] RSP: 0018:ffff8800093474f0  EFLAGS: 00010282
[ 5657.008034] RAX: 0000000000000027 RBX: ffff8800a60330b8 RCX: 0000000000000000
[ 5657.008034] RDX: 0000000000000000 RSI: ffffffffaa54dc14 RDI: ffffed0001268e94
[ 5657.008034] RBP: ffff880009347520 R08: 0000000000000001 R09: 0000000000000000
[ 5657.008034] R10: 0000000000000000 R11: 0000000000000001 R12: ffff8800a60330d0
[ 5657.008034] R13: 0000000000000000 R14: 0000000000000000 R15: ffff8800a6033000
[ 5657.008034] FS:  00007ff2875b3700(0000) GS:ffff8801d0600000(0000) knlGS:0000000000000000
[ 5657.008034] CS:  0010 DS: 0000 ES: 0000 CR0: 000000008005003b
[ 5657.008034] CR2: 0000000000639518 CR3: 00000000093da000 CR4: 00000000000006a0
[ 5657.008034] Stack:
[ 5657.008034]  ffff8800506e0000 0000000000000000 ffff8800a6033000 0000000000000000
[ 5657.008034]  ffff8800a6033000 ffff8800a6033000 ffff880009347540 ffffffffa9457c3e
[ 5657.008034]  0000000000000000 ffff8800a6033000 ffff880009347560 ffffffffa9457c77
[ 5657.008034] Call Trace:
[ 5657.008034] __netdev_adjacent_dev_unlink (net/core/dev.c:5286)
[ 5657.008034] __netdev_adjacent_dev_unlink_neighbour (net/core/dev.c:5316)
[ 5657.008034] netdev_upper_dev_unlink (net/core/dev.c:5496)
[ 5657.008034] do_vrf_del_slave (drivers/net/vrf.c:465)
[ 5657.008034] vrf_device_event (drivers/net/vrf.c:683)
[ 5657.008034] notifier_call_chain (kernel/notifier.c:93)
[ 5657.008034] raw_notifier_call_chain (kernel/notifier.c:402)
[ 5657.008034] call_netdevice_notifiers_info (net/core/dev.c:1615)
[ 5657.008034] rollback_registered_many (net/core/dev.c:6211)
[ 5657.008034] rollback_registered (net/core/dev.c:6251)
[ 5657.008034] unregister_netdevice_queue (include/linux/list.h:77 net/core/dev.c:6155 net/core/dev.c:7140)
[ 5657.008034] unregister_netdev (net/core/dev.c:7180)
[ 5657.008034] virtnet_remove (drivers/net/virtio_net.c:1941)
[ 5657.008034] virtio_dev_remove (drivers/virtio/virtio.c:265)
[ 5657.008034] __device_release_driver (drivers/base/dd.c:691)
[ 5657.008034] device_release_driver (include/linux/device.h:959 drivers/base/dd.c:722)
[ 5657.008034] bus_remove_device (drivers/base/bus.c:602)
[ 5657.008034] device_del (drivers/base/core.c:1267)
[ 5657.008034] device_unregister (drivers/base/core.c:1214 drivers/base/core.c:1300)
[ 5657.008034] unregister_virtio_device (drivers/virtio/virtio.c:338)
[ 5657.008034] virtio_pci_remove (drivers/virtio/virtio_pci_common.c:551)
[ 5657.008034] pci_device_remove (include/linux/compiler.h:206 ./arch/x86/include/asm/atomic.h:27 ./arch/x86/include/asm/atomic.h:212 include/linux/atomic.h:349 include/linux/pm_runtime.h:71 drivers/pci/pci-driver.c:428)
[ 5657.008034] __device_release_driver (drivers/base/dd.c:691)
[ 5657.008034] device_release_driver (include/linux/device.h:959 drivers/base/dd.c:722)
[ 5657.059545] pci_stop_bus_device (drivers/pci/remove.c:26 drivers/pci/remove.c:79)
[ 5657.059545] pci_stop_and_remove_bus_device_locked (drivers/pci/remove.c:114 drivers/pci/remove.c:121)
[ 5657.059545] remove_store (drivers/pci/pci-sysfs.c:366)
[ 5657.059545] dev_attr_store (drivers/base/core.c:137)
[ 5657.059545] sysfs_kf_write (fs/sysfs/file.c:131)
[ 5657.059545] kernfs_fop_write (fs/kernfs/file.c:312)
[ 5657.059545] __vfs_write (fs/read_write.c:489)
[ 5657.059545] vfs_write (fs/read_write.c:539)
[ 5657.059545] SyS_pwrite64 (include/linux/file.h:38 fs/read_write.c:628 fs/read_write.c:614)
[ 5657.059545] tracesys_phase2 (arch/x86/entry/entry_64.S:270)
[ 5657.059545] Code: 48 8b 55 d0 4c 8b 63 18 49 8d 5c 24 e8 4c 39 e2 75 ac eb 05 48 85 db 75 14 4c 89 f2 4c 89 fe 48 c7 c7 20 79 2f ac e8 b2 ed 1d f8 <0f> 0b 4c 8d 63 0a 48 b8 00 00 00 00 00 fc ff df 4c 89 e1 48 c1
All code
========
   0:   48 8b 55 d0             mov    -0x30(%rbp),%rdx
   4:   4c 8b 63 18             mov    0x18(%rbx),%r12
   8:   49 8d 5c 24 e8          lea    -0x18(%r12),%rbx
   d:   4c 39 e2                cmp    %r12,%rdx
  10:   75 ac                   jne    0xffffffffffffffbe
  12:   eb 05                   jmp    0x19
  14:   48 85 db                test   %rbx,%rbx
  17:   75 14                   jne    0x2d
  19:   4c 89 f2                mov    %r14,%rdx
  1c:   4c 89 fe                mov    %r15,%rsi
  1f:   48 c7 c7 20 79 2f ac    mov    $0xffffffffac2f7920,%rdi
  26:   e8 b2 ed 1d f8          callq  0xfffffffff81deddd
  2b:*  0f 0b                   ud2             <-- trapping instruction
  2d:   4c 8d 63 0a             lea    0xa(%rbx),%r12
  31:   48 b8 00 00 00 00 00    movabs $0xdffffc0000000000,%rax
  38:   fc ff df
  3b:   4c 89 e1                mov    %r12,%rcx
  3e:   48                      rex.W
  3f:   c1                      .byte 0xc1
        ...

Code starting with the faulting instruction
===========================================
   0:   0f 0b                   ud2
   2:   4c 8d 63 0a             lea    0xa(%rbx),%r12
   6:   48 b8 00 00 00 00 00    movabs $0xdffffc0000000000,%rax
   d:   fc ff df
  10:   4c 89 e1                mov    %r12,%rcx
  13:   48                      rex.W
  14:   c1                      .byte 0xc1
        ...
[ 5657.059545] RIP __netdev_adjacent_dev_remove (net/core/dev.c:5219)
[ 5657.059545]  RSP <ffff8800093474f0>
