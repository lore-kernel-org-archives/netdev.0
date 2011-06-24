From: Martin Jackson <mjackson220.list@gmail.com>
Subject: ppp_deflate + kmalloc
Date: Fri, 24 Jun 2011 15:41:21 +0200
Message-ID: <BANLkTi=+2dqr1LPwG8MHpcYOyzJH57iavw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: linux-ppp@vger.kernel.org, netdev@vger.kernel.org
To: paulus@samba.org
Return-path: <linux-ppp-owner@vger.kernel.org>
Sender: linux-ppp-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi,

In our android froyo-based system (omap3 hardware), we are getting the
following problem where the ppp driver cannot kmalloc enough memory
for the decomp buffer in the ppp driver.

Trying to make a 4th-order kmalloc (I think that amounts to 64kB)
seems ambitious. I do not understand why vmalloc is not being used
here, like it is for the compression buffer. Is using vmalloc here an
acceptable solution?

pppd: page allocation failure. order:4, mode:0x44d0
[<c016bc10>] (unwind_backtrace+0x0/0xdc) from [<c01fea80>]
(__alloc_pages_nodemask+0x4c4/0x5a4)
[<c01fea80>] (__alloc_pages_nodemask+0x4c4/0x5a4) from [<c01feb70>]
(__get_free_pages+0x10/0x3c)
[<c01feb70>] (__get_free_pages+0x10/0x3c) from [<c021cc24>]
(__kmalloc+0x3c/0x220)
[<c021cc24>] (__kmalloc+0x3c/0x220) from [<c03519d8>]
(z_decomp_alloc+0x120/0x164)
[<c03519d8>] (z_decomp_alloc+0x120/0x164) from [<c034de14>]
(ppp_ioctl+0xae4/0xf18)
[<c034de14>] (ppp_ioctl+0xae4/0xf18) from [<c022cd3c>] (vfs_ioctl+0x2c/0x8c)
[<c022cd3c>] (vfs_ioctl+0x2c/0x8c) from [<c022d3e8>] (do_vfs_ioctl+0x55c/0x5a0)
[<c022d3e8>] (do_vfs_ioctl+0x55c/0x5a0) from [<c022d478>] (sys_ioctl+0x4c/0x6c)
[<c022d478>] (sys_ioctl+0x4c/0x6c) from [<c0166f80>] (ret_fast_syscall+0x0/0x38)
Mem-info:
Normal per-cpu:
CPU    0: hi:   90, btch:  15 usd:   0
active_anon:6829 inactive_anon:6914 isolated_anon:0
 active_file:14397 inactive_file:14438 isolated_file:0
 unevictable:0 dirty:12 writeback:0 unstable:0
 free:901 slab_reclaimable:1040 slab_unreclaimable:1117
 mapped:12160 shmem:64 pagetables:1576 bounce:0
Normal free:3604kB min:2036kB low:2544kB high:3052kB
active_anon:27316kB inactive_anon:27656kB active_file:57588kB
inactive_file:57752kB unevictable:0kB isolated(anon):0kB
isolated(file):0kB present:260096kB mlocked:0kB dirty:48kB
writeback:0kB mapped:48640kB shmem:256kB slab_reclaimable:4160kB
slab_unreclaimable:4468kB kernel_stack:2128kB pagetables:6304kB
unstable:0kB bounce:0kB writeback_tmp:0kB pages_scanned:0
all_unreclaimable? no
lowmem_reserve[]: 0 0
Normal: 359*4kB 183*8kB 42*16kB 1*32kB 0*64kB 0*128kB 0*256kB 0*512kB
0*1024kB 0*2048kB 0*4096kB = 3604kB
28899 total pagecache pages
65536 pages of RAM
1299 free pages
13785 reserved pages
1482 slab pages
89904 pages shared
0 pages swap cached


This is how I worked around it.


--- a/drivers/net/ppp_deflate.c
+++ b/drivers/net/ppp_deflate.c
@@ -305,7 +305,7 @@ static void z_decomp_free(void *arg)

        if (state) {
                zlib_inflateEnd(&state->strm);
-               kfree(state->strm.workspace);
+               vfree(state->strm.workspace);
                kfree(state);
        }
 }
@@ -345,8 +345,7 @@ static void *z_decomp_alloc(unsigned char
*options, int opt_len)

        state->w_size         = w_size;
        state->strm.next_out  = NULL;
-       state->strm.workspace = kmalloc(zlib_inflate_workspacesize(),
-                                       GFP_KERNEL|__GFP_REPEAT);
+       state->strm.workspace = vmalloc(zlib_inflate_workspacesize());
        if (state->strm.workspace == NULL)
                goto out_free;


Best regards,

Martin Jackson
