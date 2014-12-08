From: "Kirill A. Shutemov" <kirill@shutemov.name>
Subject: Re: [RFC][PATCHES] iov_iter.c rewrite
Date: Mon, 8 Dec 2014 18:46:50 +0200
Message-ID: <20141208164650.GB29028@node.dhcp.inet.fi>
References: <20141204202011.GO29748@ZenIV.linux.org.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Linus Torvalds <torvalds@linux-foundation.org>,
	linux-kernel@vger.kernel.org, linux-fsdevel@vger.kernel.org,
	netdev@vger.kernel.org
To: Al Viro <viro@ZenIV.linux.org.uk>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20141204202011.GO29748@ZenIV.linux.org.uk>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, Dec 04, 2014 at 08:20:11PM +0000, Al Viro wrote:
> 	First of all, I want to apologize for the nastiness of preprocessor
> use in this series.  Seeing that the whole "macros that look like new kinds
> of C statements" thing (including list_for_each_...(), etc) is very much not
> to my liking, I really don't trust my taste on finer details and I'd very
> much like some feedback.
> 
> 	The reason for doing that kind of tricks is that iov_iter.c keeps
> growing more and more boilerplate code.  For iov_iter-net series we need
> 	* csum_and_copy_from_iter()
> 	* csum_and_copy_to_iter()
> 	* copy_from_iter_nocache()
> That's 3 new primitives, each in 2 variants (iovec and bvec).
> 	* ITER_KVEC handled without going through uaccess.h stuff (and
> independent of set_fs() state).
> And *that* means 3 variants intstead of 2 for most of the existing primitives.
> That's far too much, and the amount of copies of the same logics would pretty
> much guarantee that it will be a breeding ground for hard-to-kill bugs.
> 
> 	The following series (also in vfs.git#iov_iter) actually manages to
> do all of the above *and* shrink the damn thing quite a bit.  The generated
> code appears to be no worse than before.  The price is a couple of iterator
> macros - iterate_all_kinds() and iterate_and_advance().  They are given an
> iov_iter, size (i.e. the amount of data in iov_iter beginning we want to go
> through), name of the loop variable and 3 variants of loop body - for iovec,
> bvec and kvec resp.  Loop variable is declared *inside* the expansion of those
> suckers according to the kind of iov_iter - it's struct iovec, struct bio_vec
> or struct kvec, covering the current range to deal with.
> 	The difference between those two is that iterate_and_advance() will
> advance the iov_iter by the amount it has handled and iterate_all_kinds()
> will leave iov_iter unchanged.
> 
> 	Unless I hear anybody yelling, it goes into vfs.git#for-next today,
> so if you have objections, suggestions, etc., give those *now*.
> 
> Al Viro (13):
>       iov_iter.c: macros for iterating over iov_iter
>       iov_iter.c: iterate_and_advance
>       iov_iter.c: convert iov_iter_npages() to iterate_all_kinds
>       iov_iter.c: convert iov_iter_get_pages() to iterate_all_kinds
>       iov_iter.c: convert iov_iter_get_pages_alloc() to iterate_all_kinds
>       iov_iter.c: convert iov_iter_zero() to iterate_and_advance
>       iov_iter.c: get rid of bvec_copy_page_{to,from}_iter()
>       iov_iter.c: convert copy_from_iter() to iterate_and_advance
>       iov_iter.c: convert copy_to_iter() to iterate_and_advance
>       iov_iter.c: handle ITER_KVEC directly
>       csum_and_copy_..._iter()
>       new helper: iov_iter_kvec()
>       copy_from_iter_nocache()

I guess this crash is related to the patchset.

[  102.337742] ------------[ cut here ]------------
[  102.338270] kernel BUG at /home/kas/git/public/linux-next/arch/x86/mm/physaddr.c:26!
[  102.339043] invalid opcode: 0000 [#1] SMP DEBUG_PAGEALLOC
[  102.339622] Modules linked in:
[  102.339951] CPU: 2 PID: 6029 Comm: trinity-c23 Not tainted 3.18.0-next-20141208-00036-gc7edb4791544-dirty #269
[  102.340011] Hardware name: QEMU Standard PC (Q35 + ICH9, 2009), BIOS rel-1.7.5-0-ge51488c-20140602_164612-nilsson.home.kraxel.org 04/01/2014
[  102.340011] task: ffff880041c51510 ti: ffff880049c70000 task.ti: ffff880049c70000
[  102.340011] RIP: 0010:[<ffffffff8104d8c0>]  [<ffffffff8104d8c0>] __phys_addr+0x40/0x60
[  102.340011] RSP: 0018:ffff880049c73838  EFLAGS: 00010206
[  102.340011] RAX: 00004100174b4000 RBX: ffff880049c73b08 RCX: 0000000000000028
[  102.340011] RDX: 0000000000000041 RSI: ffff88015dc980a8 RDI: ffffc900174b4000
[  102.340011] RBP: ffff880049c73838 R08: ffffc900174b4000 R09: 000000000000000c
[  102.340011] R10: 0000000000000000 R11: 0000000000000000 R12: ffff88015dc980a8
[  102.340011] R13: ffffc900174f4000 R14: ffffea0000000000 R15: ffffc900174b4000
[  102.340011] FS:  00007fcdd37fb700(0000) GS:ffff88017aa00000(0000) knlGS:0000000000000000
[  102.340011] CS:  0010 DS: 0000 ES: 0000 CR0: 0000000080050033
[  102.340011] CR2: 00000000006246a8 CR3: 0000000068dbb000 CR4: 00000000001406e0
[  102.340011] Stack:
[  102.340011]  ffff880049c73888 ffffffff8117a96b 0000000000000002 0000000000040000
[  102.340011]  ffffffff81204b3f ffff88015dc98028 0000000000000000 ffff880049c73a78
[  102.340011]  ffff88015dc98000 ffff880049c73a10 ffff880049c73978 ffffffff81203ec9
[  102.340011] Call Trace:
[  102.340011]  [<ffffffff8117a96b>] iov_iter_get_pages+0x17b/0x390
[  102.340011]  [<ffffffff81204b3f>] ? __blockdev_direct_IO+0x15f/0x16a0
[  102.340011]  [<ffffffff81203ec9>] do_direct_IO+0x10a9/0x1bc0
[  102.340011]  [<ffffffff810a92d8>] ? lockdep_init_map+0x68/0x5c0
[  102.340011]  [<ffffffff81204d6c>] __blockdev_direct_IO+0x38c/0x16a0
[  102.340011]  [<ffffffff810a9d27>] ? __lock_acquire+0x4f7/0xd40
[  102.340011]  [<ffffffff810a73f9>] ? mark_held_locks+0x79/0xb0
[  102.340011]  [<ffffffff8133b510>] ? xfs_get_blocks+0x20/0x20
[  102.340011]  [<ffffffff81338ff0>] xfs_vm_direct_IO+0x120/0x140
[  102.340011]  [<ffffffff8133b510>] ? xfs_get_blocks+0x20/0x20
[  102.340011]  [<ffffffff810aa773>] ? lock_release_non_nested+0x203/0x3d0
[  102.340011]  [<ffffffff8135b9a7>] ? xfs_ilock+0x167/0x2e0
[  102.340011]  [<ffffffff8114d957>] generic_file_read_iter+0x517/0x6a0
[  102.340011]  [<ffffffff810a73f9>] ? mark_held_locks+0x79/0xb0
[  102.340011]  [<ffffffff8185e192>] ? __mutex_unlock_slowpath+0xb2/0x190
[  102.340011]  [<ffffffff8134bc2f>] xfs_file_read_iter+0x12f/0x460
[  102.340011]  [<ffffffff811c237e>] new_sync_read+0x7e/0xb0
[  102.340011]  [<ffffffff811c3528>] __vfs_read+0x18/0x50
[  102.340011]  [<ffffffff811c35ed>] vfs_read+0x8d/0x150
[  102.340011]  [<ffffffff811c89e8>] kernel_read+0x48/0x60
[  102.340011]  [<ffffffff810f4a92>] copy_module_from_fd.isra.51+0x112/0x170
[  102.340011]  [<ffffffff810f7646>] SyS_finit_module+0x56/0x80
[  102.340011]  [<ffffffff81861f92>] system_call_fastpath+0x12/0x17
[  102.340011] Code: 00 00 00 00 00 78 00 00 48 01 f8 48 39 c2 72 1b 0f b6 0d 9d 7a ec 00 48 89 c2 48 d3 ea 48 85 d2 75 09 5d c3 0f 1f 80 00 00 00 00 <0f> 0b 66 0f 1f 44 00 00 48 89 d0 48 03 05 3e 87 dc 00 48 81 fa 
[  102.340011] RIP  [<ffffffff8104d8c0>] __phys_addr+0x40/0x60
[  102.340011]  RSP <ffff880049c73838>
[  102.371939] ---[ end trace e07368268cd6b49c ]---


-- 
 Kirill A. Shutemov
