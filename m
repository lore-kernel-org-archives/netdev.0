From: Alexander Potapenko <glider@google.com>
Subject: [PATCH v2] net: don't call strlen on non-terminated string in dev_set_alias()
Date: Wed, 31 May 2017 14:51:50 +0200
Message-ID: <20170531125150.28798-1-glider@google.com>
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org
To: dvyukov@google.com, kcc@google.com, edumazet@google.com,
        davem@davemloft.net
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

KMSAN reported a use of uninitialized memory in dev_set_alias(),
which was caused by calling strlcpy() (which in turn called strlen())
on the user-supplied non-terminated string.

Signed-off-by: Alexander Potapenko <glider@google.com>
---
v2: fixed an off-by-one error spotted by Dmitry Vyukov

For the record, here is the KMSAN report:

==================================================================
BUG: KMSAN: use of unitialized memory in strlcpy+0x8b/0x1b0
CPU: 0 PID: 1062 Comm: probe Not tainted 4.11.0-rc5+ #2763
Hardware name: QEMU Standard PC (i440FX + PIIX, 1996), BIOS Bochs 01/01/2011
Call Trace:
 __dump_stack lib/dump_stack.c:16
 dump_stack+0x143/0x1b0 lib/dump_stack.c:52
 kmsan_report+0x12a/0x180 mm/kmsan/kmsan.c:1016
 __kmsan_warning_32+0x66/0xb0 mm/kmsan/kmsan_instr.c:491
 strlen lib/string.c:484
 strlcpy+0x8b/0x1b0 lib/string.c:144
 dev_set_alias+0x295/0x360 net/core/dev.c:1255
 do_setlink+0xfe5/0x5750 net/core/rtnetlink.c:2007
 rtnl_setlink+0x469/0x4f0 net/core/rtnetlink.c:2249
 rtnetlink_rcv_msg+0x5da/0xb40 net/core/rtnetlink.c:4107
 netlink_rcv_skb+0x339/0x5a0 net/netlink/af_netlink.c:2339
 rtnetlink_rcv+0x83/0xa0 net/core/rtnetlink.c:4113
 netlink_unicast_kernel net/netlink/af_netlink.c:1272
 netlink_unicast+0x13b7/0x1480 net/netlink/af_netlink.c:1298
 netlink_sendmsg+0x10b8/0x10f0 net/netlink/af_netlink.c:1844
 sock_sendmsg_nosec net/socket.c:633
 sock_sendmsg net/socket.c:643
 sock_write_iter+0x395/0x440 net/socket.c:857
 call_write_iter ./include/linux/fs.h:1733
 new_sync_write fs/read_write.c:497
 __vfs_write+0x619/0x700 fs/read_write.c:510
 vfs_write+0x47e/0x8a0 fs/read_write.c:558
 SYSC_write+0x17e/0x2f0 fs/read_write.c:605
 SyS_write+0x87/0xb0 fs/read_write.c:597
 entry_SYSCALL_64_fastpath+0x13/0x94 arch/x86/entry/entry_64.S:204
RIP: 0033:0x4052f1
RSP: 002b:00007fde1ed05d80 EFLAGS: 00000293 ORIG_RAX: 0000000000000001
RAX: ffffffffffffffda RBX: 0000000000000000 RCX: 00000000004052f1
RDX: 0000000000000026 RSI: 00000000006cf0c0 RDI: 0000000000000032
RBP: 00007fde1ed05da0 R08: 00007fde1ed06700 R09: 00007fde1ed06700
R10: 00007fde1ed069d0 R11: 0000000000000293 R12: 0000000000000000
R13: 0000000000000000 R14: 00007fde1ed069c0 R15: 00007fde1ed06700
origin: 00000000aec00057
 save_stack_trace+0x59/0x60 arch/x86/kernel/stacktrace.c:59
 kmsan_save_stack_with_flags mm/kmsan/kmsan.c:352
 kmsan_internal_poison_shadow+0xb1/0x1a0 mm/kmsan/kmsan.c:247
 kmsan_poison_shadow+0x6d/0xc0 mm/kmsan/kmsan.c:260
 slab_alloc_node mm/slub.c:2743
 __kmalloc_node_track_caller+0x1f4/0x390 mm/slub.c:4349
 __kmalloc_reserve net/core/skbuff.c:138
 __alloc_skb+0x2cd/0x740 net/core/skbuff.c:231
 alloc_skb ./include/linux/skbuff.h:933
 netlink_alloc_large_skb net/netlink/af_netlink.c:1144
 netlink_sendmsg+0x934/0x10f0 net/netlink/af_netlink.c:1819
 sock_sendmsg_nosec net/socket.c:633
 sock_sendmsg net/socket.c:643
 sock_write_iter+0x395/0x440 net/socket.c:857
 call_write_iter ./include/linux/fs.h:1733
 new_sync_write fs/read_write.c:497
 __vfs_write+0x619/0x700 fs/read_write.c:510
 vfs_write+0x47e/0x8a0 fs/read_write.c:558
 SYSC_write+0x17e/0x2f0 fs/read_write.c:605
 SyS_write+0x87/0xb0 fs/read_write.c:597
 entry_SYSCALL_64_fastpath+0x13/0x94 arch/x86/entry/entry_64.S:204
==================================================================

and the reproducer:
==================================================================
  #include <pthread.h>
  
  int sock = -1;
  char buf[] = "\x26\x00\x00\x00\x13\x00\x47\xf1\x07\x01\xc1\xb0"
               "\x0e\x00\x00\x00\x00\x00\x00\x00\x01\x00\x00\x00"
               "\x09\xef\x18\xff\xff\x00\xf1\x32\x05\x00\x14\x00"
               "\x6e\x35";
  
  void do_work(int arg) {
    switch (arg) {
     case 0:
      sock = socket(0x10, 0x3, 0x0);
      break;
     case 1:
      write(sock, buf, 0x26);
      break;
    }
  }
  
  void *thread_fn(void *arg) {
    int actual_arg = (int)arg;
    int iter = 10000, i;
    for (i = 0; i < iter; i++) {
      do_work(actual_arg);
      usleep(100);
    }
    return NULL;
  }
  
  int main() {
    pthread_t thr[4];
    int i;
    for (i = 0; i < 4; i++) {
      pthread_create(&thr, NULL, thread_fn, (void*)(i % 2));
    }
    sleep(10);
    return 0;
  }
==================================================================
---
 net/core/dev.c | 5 ++++-
 1 file changed, 4 insertions(+), 1 deletion(-)

diff --git a/net/core/dev.c b/net/core/dev.c
index fca407b4a6ea..757069baffa9 100644
--- a/net/core/dev.c
+++ b/net/core/dev.c
@@ -1254,7 +1254,10 @@ int dev_set_alias(struct net_device *dev, const char *alias, size_t len)
 		return -ENOMEM;
 	dev->ifalias = new_ifalias;
 
-	strlcpy(dev->ifalias, alias, len+1);
+	/* alias comes from the userspace and may not be zero-terminated.
+	 */
+	memcpy(dev->ifalias, alias, len);
+	dev->ifalias[len] = 0;
 	return len;
 }
 
-- 
2.13.0.219.gdb65acc882-goog
