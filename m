From: Fengguang Wu <fengguang.wu@intel.com>
Subject: Re: [net/bpf] 3051bf36c2 BUG: unable to handle kernel paging request
 at 0000a7cf
Date: Fri, 3 Mar 2017 04:23:38 +0800
Message-ID: <20170302202338.ci6wwb3yzjmdy4n2@wfg-t540p.sh.intel.com>
References: <20170301125426.l4nf65rx4wahohyl@wfg-t540p.sh.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Cc: Linus Torvalds <torvalds@linux-foundation.org>,
        Daniel Borkmann <daniel@iogearbox.net>,
        LKML <linux-kernel@vger.kernel.org>, LKP <lkp@01.org>
To: netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20170301125426.l4nf65rx4wahohyl@wfg-t540p.sh.intel.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, Mar 01, 2017 at 08:54:26PM +0800, Fengguang Wu wrote:
>Hi all,
>
>Is it BPF triggering BUGs all over the places?

It looks so, and here is a fix.

>1e74a2eb1f  Merge tag 'gcc-plugins-v4.11-rc1' of git://git.kernel.org/pub/scm/linux/kernel/git/kees/linux
>005c3490e9  Revert "ath10k: Search SMBIOS for OEM board file extension"
>3051bf36c2  Merge git://git.kernel.org/pub/scm/linux/kernel/git/davem/net-next
>+-------------------------------------------------------+------------+------------+------------+
>|                                                       | 1e74a2eb1f | 005c3490e9 | 3051bf36c2 |
>+-------------------------------------------------------+------------+------------+------------+
>| boot_successes                                        | 1223       | 1098       | 242        |
>| boot_failures                                         | 1          | 126        | 72         |
>| BUG:unable_to_handle_kernel                           | 1          | 117        | 69         |
>| Oops                                                  | 1          | 126        | 72         |
>| EIP:perf_callchain_user                               | 1          |            |            |
>| Kernel_panic-not_syncing:Fatal_exception              | 1          | 121        | 67         |
>| EIP:netlink_release                                   | 0          | 20         | 3          |
>| EIP:bpf_prog_free                                     | 0          | 22         | 3          |
>| EIP:filp_close                                        | 0          | 64         | 23         |
>| EIP:netlink_update_listeners                          | 0          | 10         | 9          |
>| EIP:security_inode_getattr                            | 0          | 2          |            |
>| EIP:__lock_acquire                                    | 0          | 1          | 11         |
>| Kernel_panic-not_syncing:Fatal_exception_in_interrupt | 0          | 5          | 4          |
>| EIP:__rcu_process_callbacks                           | 0          | 2          |            |
>| EIP:__fget_light                                      | 0          | 1          |            |
>| EIP:__unix_remove_socket                              | 0          | 0          | 13         |
>| INFO:trying_to_register_non-static_key                | 0          | 0          | 2          |
>| EIP:mnt_want_write_file                               | 0          | 0          | 1          |
>| EIP:skb_dequeue                                       | 0          | 0          | 1          |
>| EIP:strlen                                            | 0          | 0          | 1          |
>| EIP:__netlink_lookup                                  | 0          | 0          | 2          |
>| EIP:vfs_fsync_range                                   | 0          | 0          | 1          |
>| EIP:__unix_find_socket_byname                         | 0          | 0          | 1          |
>| EIP:release_sock                                      | 0          | 0          | 1          |
>+-------------------------------------------------------+------------+------------+------------+

I confirm that the below patch provided by Daniel fixes the above
issues on mainline kernel, too. Where should this patch be sent to?
It'd be very noisy if all these Oops hit the upcoming RC1 kernel.

Daniel thinks there may be deeper problem in i386 set_memory_rw().
However that could take much longer time to debug.

Thanks,
Fengguang
---

Re: [bpf] 9d876e79df:  BUG: unable to handle kernel paging request at 653a8346

> On Tue, Feb 28, 2017 at 04:39:36PM +0100, Daniel Borkmann wrote:

I have a rough feeling what it is, but I didn't have cycles to work on
it yet (due to travel, sorry about that). The issue is likely shut down
by just doing:

---
 arch/x86/Kconfig |    2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

--- linux.orig/arch/x86/Kconfig	2017-03-03 03:44:35.962022996 +0800
+++ linux/arch/x86/Kconfig	2017-03-03 03:44:35.962022996 +0800
@@ -54,7 +54,7 @@ config X86
 	select ARCH_HAS_KCOV			if X86_64
 	select ARCH_HAS_MMIO_FLUSH
 	select ARCH_HAS_PMEM_API		if X86_64
-	select ARCH_HAS_SET_MEMORY
+	select ARCH_HAS_SET_MEMORY		if X86_64
 	select ARCH_HAS_SG_CHAIN
 	select ARCH_HAS_STRICT_KERNEL_RWX
 	select ARCH_HAS_STRICT_MODULE_RWX
