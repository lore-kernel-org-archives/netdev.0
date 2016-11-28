From: Andrey Konovalov <andreyknvl@google.com>
Subject: Re: net/sctp: vmalloc allocation failure in sctp_setsockopt/xt_alloc_table_info
Date: Mon, 28 Nov 2016 15:33:40 +0100
Message-ID: <CAAeHK+xJmwF6hddS-sO-y3HQkRicwQN=ZceFWTZT2M_0h4E2hQ@mail.gmail.com>
References: <CAAeHK+wecw6ST_DWJQBLFNwVsOVgderGE-EEJiN0-kf796XHtw@mail.gmail.com>
 <20161128141340.GA29839@hmsreliant.think-freely.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Vlad Yasevich <vyasevich@gmail.com>, linux-sctp@vger.kernel.org,
        netdev <netdev@vger.kernel.org>,
        LKML <linux-kernel@vger.kernel.org>,
        Pablo Neira Ayuso <pablo@netfilter.org>,
        Patrick McHardy <kaber@trash.net>,
        Jozsef Kadlecsik <kadlec@blackhole.kfki.hu>,
        "David S. Miller" <davem@davemloft.net>,
        netfilter-devel@vger.kernel.org, coreteam@netfilter.org,
        Dmitry Vyukov <dvyukov@google.com>,
        Kostya Serebryany <kcc@google.com>,
        Eric Dumazet <edumazet@google.com>,
        syzkaller <syzkaller@googlegroups.com>
To: Neil Horman <nhorman@tuxdriver.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20161128141340.GA29839@hmsreliant.think-freely.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, Nov 28, 2016 at 3:13 PM, Neil Horman <nhorman@tuxdriver.com> wrote:
> On Mon, Nov 28, 2016 at 02:00:19PM +0100, Andrey Konovalov wrote:
>> Hi!
>>
>> I've got the following error report while running the syzkaller fuzzer.
>>
>> On commit d8e435f3ab6fea2ea324dce72b51dd7761747523 (Nov 26).
>>
>> A reproducer is attached.
>>
>> a.out: vmalloc: allocation failure, allocated 823562240 of 1427091456
>> bytes, mode:0x24000c2(GFP_KERNEL|__GFP_HIGHMEM)
>>
> How much total ram do you have in this system?  The call appears to be
> attempting to allocate 1.3 Gb of data.  Even using vmalloc to allow
> discontiguous allocation, thats alot of memory, and if enough is in use already,
> I could make the argument that this might be expected behavior.

Hi Neail,

I have 2 Gb.

Just tested with 4 Gb, everything seems to be working fine.
So I guess this is not actually a bug and allocating 1.3 Gb is OK.

Thanks!

>
> Neil
>
>> oom_reaper: reaped process 3810 (a.out), now anon-rss:0kB,
>> file-rss:0kB, shmem-rss:0kB
>> a.out invoked oom-killer:
>> gfp_mask=0x24002c2(GFP_KERNEL|__GFP_HIGHMEM|__GFP_NOWARN), nodemask=0,
>> order=0, oom_score_adj=0
>> a.out cpuset=/ mems_allowed=0
>> CPU: 0 PID: 3814 Comm: a.out Not tainted 4.9.0-rc6+ #457
>> Hardware name: QEMU Standard PC (i440FX + PIIX, 1996), BIOS Bochs 01/01/2011
>>  ffff880068667380 ffffffff81c73b14 ffff880068667710 ffff88006b469018
>>  ffff880068667718 0000000000000000 ffff880068667400 ffffffff81641a87
>>  0000000000000000 0000000000000000 0000000000000297 ffffffff84d37280
>> Call Trace:
>>  [<     inline     >] __dump_stack lib/dump_stack.c:15
>>  [<ffffffff81c73b14>] dump_stack+0xb3/0x10f lib/dump_stack.c:51
>>  [<ffffffff81641a87>] dump_header.isra.21+0x16f/0x5f5 mm/oom_kill.c:416
>>  [<ffffffff8154bad8>] oom_kill_process+0x4d8/0xab0 mm/oom_kill.c:835
>>  [<ffffffff8154c77c>] out_of_memory+0x2dc/0x1790 mm/oom_kill.c:1044
>>  [<     inline     >] __alloc_pages_may_oom mm/page_alloc.c:3086
>>  [<ffffffff8155afb6>] __alloc_pages_slowpath+0x1886/0x1bf0 mm/page_alloc.c:3683
>>  [<ffffffff8155b8e2>] __alloc_pages_nodemask+0x5c2/0x710 mm/page_alloc.c:3781
>>  [<ffffffff816236a4>] alloc_pages_current+0xf4/0x400 mm/mempolicy.c:2072
>>  [<     inline     >] alloc_pages ./include/linux/gfp.h:469
>>  [<     inline     >] __vmalloc_area_node mm/vmalloc.c:1631
>>  [<ffffffff815f8eab>] __vmalloc_node_range+0x33b/0x690 mm/vmalloc.c:1691
>>  [<     inline     >] __vmalloc_node mm/vmalloc.c:1734
>>  [<     inline     >] __vmalloc_node_flags mm/vmalloc.c:1748
>>  [<ffffffff815f92cb>] vmalloc+0x5b/0x70 mm/vmalloc.c:1763
>>  [<ffffffff82fd0893>] xt_alloc_table_info+0x83/0x120
>> net/netfilter/x_tables.c:961
>>  [<     inline     >] do_replace net/ipv4/netfilter/ip_tables.c:1140
>>  [<ffffffff8335b420>] do_ipt_set_ctl+0x210/0x420
>> net/ipv4/netfilter/ip_tables.c:1687
>>  [<     inline     >] nf_sockopt net/netfilter/nf_sockopt.c:105
>>  [<ffffffff82efdab7>] nf_setsockopt+0x67/0xc0 net/netfilter/nf_sockopt.c:114
>>  [<ffffffff831be741>] ip_setsockopt+0xa1/0xb0 net/ipv4/ip_sockglue.c:1231
>>  [<ffffffff832700d5>] udp_setsockopt+0x45/0x80 net/ipv4/udp.c:2085
>>  [<ffffffff8346b31f>] ipv6_setsockopt+0x11f/0x140 net/ipv6/ipv6_sockglue.c:892
>>  [<ffffffff83a6cd5d>] sctp_setsockopt+0x15d/0x3d70 net/sctp/socket.c:3788
>>  [<ffffffff82ca40e6>] sock_common_setsockopt+0x96/0xd0 net/core/sock.c:2690
>>  [<     inline     >] SYSC_setsockopt net/socket.c:1757
>>  [<ffffffff82ca10c4>] SyS_setsockopt+0x154/0x240 net/socket.c:1736
>>  [<ffffffff840f2c41>] entry_SYSCALL_64_fastpath+0x1f/0xc2
>> arch/x86/entry/entry_64.S:209
>> CPU: 1 PID: 3810 Comm: a.out Not tainted 4.9.0-rc6+ #457
>> Mem-Info:
>> active_anon:1938 inactive_anon:75 isolated_anon:0
>>  active_file:14 inactive_file:30 isolated_file:4
>>  unevictable:0 dirty:0 writeback:0 unstable:0
>>  slab_reclaimable:3316 slab_unreclaimable:9767
>>  mapped:21 shmem:81 pagetables:309 bounce:0
>>  free:1 free_pcp:75 free_cma:0
>> Node 0 active_anon:7752kB inactive_anon:300kB active_file:56kB
>> inactive_file:120kB unevictable:0kB isolated(anon):0kB
>> isolated(file):16kB mapped:84kB dirty:0kB writeback:0kB shmem:324kB
>> writeback_tmp:0kB unstable:0kB pages_scanned:134 all_unreclaimable? no
>> Node 0 DMA free:4kB min:48kB low:60kB high:72kB active_anon:0kB
>> inactive_anon:0kB active_file:0kB inactive_file:0kB unevictable:0kB
>> writepending:0kB present:15992kB managed:15908kB mlocked:0kB
>> slab_reclaimable:0kB slab_unreclaimable:8kB kernel_stack:0kB
>> pagetables:0kB bounce:0kB free_pcp:0kB local_pcp:0kB free_cma:0kB
>> lowmem_reserve[]: 0 1641 1641 1641
>> Node 0 DMA32 free:0kB min:5156kB low:6836kB high:8516kB
>> active_anon:7752kB inactive_anon:300kB active_file:56kB
>> inactive_file:120kB unevictable:0kB writepending:0kB present:2080760kB
>> managed:1684640kB mlocked:0kB slab_reclaimable:13264kB
>> slab_unreclaimable:39060kB kernel_stack:2944kB pagetables:1236kB
>> bounce:0kB free_pcp:300kB local_pcp:120kB free_cma:0kB
>> lowmem_reserve[]: 0 0 0 0
>> Node 0 DMA: 0*4kB 0*8kB 0*16kB 0*32kB 0*64kB 0*128kB 0*256kB 0*512kB
>> 0*1024kB 0*2048kB 0*4096kB = 0kB
>> Node 0 DMA32: 0*4kB 0*8kB 0*16kB 0*32kB 0*64kB 0*128kB 0*256kB 0*512kB
>> 0*1024kB 0*2048kB 0*4096kB = 0kB
>> Node 0 hugepages_total=0 hugepages_free=0 hugepages_surp=0 hugepages_size=2048kB
>> 148 total pagecache pages
>> 0 pages in swap cache
>> Swap cache stats: add 0, delete 0, find 0/0
>> Free swap  = 0kB
>> Total swap = 0kB
>> 524188 pages RAM
>> 0 pages HighMem/MovableOnly
>> 99051 pages reserved
>> [ pid ]   uid  tgid total_vm      rss nr_ptes nr_pmds swapents
>> oom_score_adj name
>>     0  1767     5346      133      16       3        0         -1000 udevd
>>     0  1876     5315      122      15       3        0         -1000 udevd
>>     0  1877     5315      122      15       3        0         -1000 udevd
>>     0  3541     2493      573       8       3        0             0 dhclient
>>     0  3676    13231      171      22       3        0             0 rsyslogd
>>     0  3725     4725       52      15       3        0             0 cron
>>     0  3751    12490      155      28       3        0         -1000 sshd
>>     0  3775     3694       43      13       3        0             0 getty
>>     0  3776     3694       43      13       3        0             0 getty
>>     0  3777     3694       42      13       3        0             0 getty
>>     0  3778     3694       41      13       3        0             0 getty
>>     0  3779     3694       44      13       3        0             0 getty
>>     0  3780     3694       43      13       3        0             0 getty
>>     0  3785     3649       44      12       3        0             0 getty
>>     0  3797    17818      205      39       3        0             0 sshd
>>     0  3800     4474      126      15       3        0             0 bash
>>     0  3804     2053       22       9       3        0             0 a.out
>>     0  3805     2053       26       9       3        0             0 a.out
>>     0  3806    18488        0      18       3        0             0 a.out
>
>> // autogenerated by syzkaller (http://github.com/google/syzkaller)
>>
>> #ifndef __NR_mmap
>> #define __NR_mmap 9
>> #endif
>> #ifndef __NR_setsockopt
>> #define __NR_setsockopt 54
>> #endif
>> #ifndef __NR_syz_fuse_mount
>> #define __NR_syz_fuse_mount 1000004
>> #endif
>> #ifndef __NR_socket
>> #define __NR_socket 41
>> #endif
>> #ifndef __NR_syz_emit_ethernet
>> #define __NR_syz_emit_ethernet 1000006
>> #endif
>> #ifndef __NR_syz_fuseblk_mount
>> #define __NR_syz_fuseblk_mount 1000005
>> #endif
>> #ifndef __NR_syz_open_dev
>> #define __NR_syz_open_dev 1000002
>> #endif
>> #ifndef __NR_syz_open_pts
>> #define __NR_syz_open_pts 1000003
>> #endif
>> #ifndef __NR_syz_test
>> #define __NR_syz_test 1000001
>> #endif
>>
>> #define SYZ_SANDBOX_NONE 1
>> #define SYZ_REPEAT 1
>>
>> #define _GNU_SOURCE
>>
>> #include <sys/ioctl.h>
>> #include <sys/mount.h>
>> #include <sys/prctl.h>
>> #include <sys/resource.h>
>> #include <sys/socket.h>
>> #include <sys/stat.h>
>> #include <sys/syscall.h>
>> #include <sys/time.h>
>> #include <sys/types.h>
>> #include <sys/wait.h>
>>
>> #include <linux/capability.h>
>> #include <linux/if.h>
>> #include <linux/if_tun.h>
>> #include <linux/sched.h>
>> #include <net/if_arp.h>
>>
>> #include <assert.h>
>> #include <dirent.h>
>> #include <errno.h>
>> #include <fcntl.h>
>> #include <grp.h>
>> #include <pthread.h>
>> #include <setjmp.h>
>> #include <signal.h>
>> #include <stdarg.h>
>> #include <stddef.h>
>> #include <stdint.h>
>> #include <stdio.h>
>> #include <stdlib.h>
>> #include <string.h>
>> #include <unistd.h>
>>
>> const int kFailStatus = 67;
>> const int kErrorStatus = 68;
>> const int kRetryStatus = 69;
>>
>> __attribute__((noreturn)) void fail(const char* msg, ...)
>> {
>>   int e = errno;
>>   fflush(stdout);
>>   va_list args;
>>   va_start(args, msg);
>>   vfprintf(stderr, msg, args);
>>   va_end(args);
>>   fprintf(stderr, " (errno %d)\n", e);
>>   exit(kFailStatus);
>> }
>>
>> __attribute__((noreturn)) void exitf(const char* msg, ...)
>> {
>>   int e = errno;
>>   fflush(stdout);
>>   va_list args;
>>   va_start(args, msg);
>>   vfprintf(stderr, msg, args);
>>   va_end(args);
>>   fprintf(stderr, " (errno %d)\n", e);
>>   exit(kRetryStatus);
>> }
>>
>> static int flag_debug;
>>
>> void debug(const char* msg, ...)
>> {
>>   if (!flag_debug)
>>     return;
>>   va_list args;
>>   va_start(args, msg);
>>   vfprintf(stdout, msg, args);
>>   va_end(args);
>>   fflush(stdout);
>> }
>>
>> __thread int skip_segv;
>> __thread jmp_buf segv_env;
>>
>> static void segv_handler(int sig, siginfo_t* info, void* uctx)
>> {
>>   if (__atomic_load_n(&skip_segv, __ATOMIC_RELAXED))
>>     _longjmp(segv_env, 1);
>>   exit(sig);
>> }
>>
>> static void install_segv_handler()
>> {
>>   struct sigaction sa;
>>   memset(&sa, 0, sizeof(sa));
>>   sa.sa_sigaction = segv_handler;
>>   sa.sa_flags = SA_NODEFER | SA_SIGINFO;
>>   sigaction(SIGSEGV, &sa, NULL);
>>   sigaction(SIGBUS, &sa, NULL);
>> }
>>
>> #define NONFAILING(...)                                                \
>>   {                                                                    \
>>     __atomic_fetch_add(&skip_segv, 1, __ATOMIC_SEQ_CST);               \
>>     if (_setjmp(segv_env) == 0) {                                      \
>>       __VA_ARGS__;                                                     \
>>     }                                                                  \
>>     __atomic_fetch_sub(&skip_segv, 1, __ATOMIC_SEQ_CST);               \
>>   }
>>
>> static uintptr_t syz_open_dev(uintptr_t a0, uintptr_t a1, uintptr_t a2)
>> {
>>   if (a0 == 0xc || a0 == 0xb) {
>>     char buf[128];
>>     sprintf(buf, "/dev/%s/%d:%d", a0 == 0xc ? "char" : "block",
>>             (uint8_t)a1, (uint8_t)a2);
>>     return open(buf, O_RDWR, 0);
>>   } else {
>>     char buf[1024];
>>     char* hash;
>>     strncpy(buf, (char*)a0, sizeof(buf));
>>     buf[sizeof(buf) - 1] = 0;
>>     while ((hash = strchr(buf, '#'))) {
>>       *hash = '0' + (char)(a1 % 10);
>>       a1 /= 10;
>>     }
>>     return open(buf, a2, 0);
>>   }
>> }
>>
>> static uintptr_t syz_open_pts(uintptr_t a0, uintptr_t a1)
>> {
>>   int ptyno = 0;
>>   if (ioctl(a0, TIOCGPTN, &ptyno))
>>     return -1;
>>   char buf[128];
>>   sprintf(buf, "/dev/pts/%d", ptyno);
>>   return open(buf, a1, 0);
>> }
>>
>> static uintptr_t syz_fuse_mount(uintptr_t a0, uintptr_t a1,
>>                                 uintptr_t a2, uintptr_t a3,
>>                                 uintptr_t a4, uintptr_t a5)
>> {
>>   uint64_t target = a0;
>>   uint64_t mode = a1;
>>   uint64_t uid = a2;
>>   uint64_t gid = a3;
>>   uint64_t maxread = a4;
>>   uint64_t flags = a5;
>>
>>   int fd = open("/dev/fuse", O_RDWR);
>>   if (fd == -1)
>>     return fd;
>>   char buf[1024];
>>   sprintf(buf, "fd=%d,user_id=%ld,group_id=%ld,rootmode=0%o", fd,
>>           (long)uid, (long)gid, (unsigned)mode & ~3u);
>>   if (maxread != 0)
>>     sprintf(buf + strlen(buf), ",max_read=%ld", (long)maxread);
>>   if (mode & 1)
>>     strcat(buf, ",default_permissions");
>>   if (mode & 2)
>>     strcat(buf, ",allow_other");
>>   syscall(SYS_mount, "", target, "fuse", flags, buf);
>>   return fd;
>> }
>>
>> static uintptr_t syz_fuseblk_mount(uintptr_t a0, uintptr_t a1,
>>                                    uintptr_t a2, uintptr_t a3,
>>                                    uintptr_t a4, uintptr_t a5,
>>                                    uintptr_t a6, uintptr_t a7)
>> {
>>   uint64_t target = a0;
>>   uint64_t blkdev = a1;
>>   uint64_t mode = a2;
>>   uint64_t uid = a3;
>>   uint64_t gid = a4;
>>   uint64_t maxread = a5;
>>   uint64_t blksize = a6;
>>   uint64_t flags = a7;
>>
>>   int fd = open("/dev/fuse", O_RDWR);
>>   if (fd == -1)
>>     return fd;
>>   if (syscall(SYS_mknodat, AT_FDCWD, blkdev, S_IFBLK, makedev(7, 199)))
>>     return fd;
>>   char buf[256];
>>   sprintf(buf, "fd=%d,user_id=%ld,group_id=%ld,rootmode=0%o", fd,
>>           (long)uid, (long)gid, (unsigned)mode & ~3u);
>>   if (maxread != 0)
>>     sprintf(buf + strlen(buf), ",max_read=%ld", (long)maxread);
>>   if (blksize != 0)
>>     sprintf(buf + strlen(buf), ",blksize=%ld", (long)blksize);
>>   if (mode & 1)
>>     strcat(buf, ",default_permissions");
>>   if (mode & 2)
>>     strcat(buf, ",allow_other");
>>   syscall(SYS_mount, blkdev, target, "fuseblk", flags, buf);
>>   return fd;
>> }
>>
>> static uintptr_t execute_syscall(int nr, uintptr_t a0, uintptr_t a1,
>>                                  uintptr_t a2, uintptr_t a3,
>>                                  uintptr_t a4, uintptr_t a5,
>>                                  uintptr_t a6, uintptr_t a7,
>>                                  uintptr_t a8)
>> {
>>   switch (nr) {
>>   default:
>>     return syscall(nr, a0, a1, a2, a3, a4, a5);
>>   case __NR_syz_test:
>>     return 0;
>>   case __NR_syz_open_dev:
>>     return syz_open_dev(a0, a1, a2);
>>   case __NR_syz_open_pts:
>>     return syz_open_pts(a0, a1);
>>   case __NR_syz_fuse_mount:
>>     return syz_fuse_mount(a0, a1, a2, a3, a4, a5);
>>   case __NR_syz_fuseblk_mount:
>>     return syz_fuseblk_mount(a0, a1, a2, a3, a4, a5, a6, a7);
>>   }
>> }
>>
>> static void setup_main_process()
>> {
>>   struct sigaction sa;
>>   memset(&sa, 0, sizeof(sa));
>>   sa.sa_handler = SIG_IGN;
>>   syscall(SYS_rt_sigaction, 0x20, &sa, NULL, 8);
>>   syscall(SYS_rt_sigaction, 0x21, &sa, NULL, 8);
>>   install_segv_handler();
>>
>>   char tmpdir_template[] = "./syzkaller.XXXXXX";
>>   char* tmpdir = mkdtemp(tmpdir_template);
>>   if (!tmpdir)
>>     fail("failed to mkdtemp");
>>   if (chmod(tmpdir, 0777))
>>     fail("failed to chmod");
>>   if (chdir(tmpdir))
>>     fail("failed to chdir");
>> }
>>
>> static void loop();
>>
>> static void sandbox_common()
>> {
>>   prctl(PR_SET_PDEATHSIG, SIGKILL, 0, 0, 0);
>>   setpgrp();
>>   setsid();
>>
>>   struct rlimit rlim;
>>   rlim.rlim_cur = rlim.rlim_max = 128 << 20;
>>   setrlimit(RLIMIT_AS, &rlim);
>>   rlim.rlim_cur = rlim.rlim_max = 1 << 20;
>>   setrlimit(RLIMIT_FSIZE, &rlim);
>>   rlim.rlim_cur = rlim.rlim_max = 1 << 20;
>>   setrlimit(RLIMIT_STACK, &rlim);
>>   rlim.rlim_cur = rlim.rlim_max = 0;
>>   setrlimit(RLIMIT_CORE, &rlim);
>>
>>   unshare(CLONE_NEWNS);
>>   unshare(CLONE_NEWIPC);
>>   unshare(CLONE_IO);
>> }
>>
>> static int do_sandbox_none()
>> {
>>   int pid = fork();
>>   if (pid)
>>     return pid;
>>   sandbox_common();
>>   loop();
>>   exit(1);
>> }
>>
>> static void remove_dir(const char* dir)
>> {
>>   DIR* dp;
>>   struct dirent* ep;
>>   int iter = 0;
>>   int i;
>> retry:
>>   dp = opendir(dir);
>>   if (dp == NULL) {
>>     if (errno == EMFILE) {
>>       exitf("opendir(%s) failed due to NOFILE, exiting");
>>     }
>>     exitf("opendir(%s) failed", dir);
>>   }
>>   while ((ep = readdir(dp))) {
>>     if (strcmp(ep->d_name, ".") == 0 || strcmp(ep->d_name, "..") == 0)
>>       continue;
>>     char filename[FILENAME_MAX];
>>     snprintf(filename, sizeof(filename), "%s/%s", dir, ep->d_name);
>>     struct stat st;
>>     if (lstat(filename, &st))
>>       exitf("lstat(%s) failed", filename);
>>     if (S_ISDIR(st.st_mode)) {
>>       remove_dir(filename);
>>       continue;
>>     }
>>     for (i = 0;; i++) {
>>       debug("unlink(%s)\n", filename);
>>       if (unlink(filename) == 0)
>>         break;
>>       if (errno == EROFS) {
>>         debug("ignoring EROFS\n");
>>         break;
>>       }
>>       if (errno != EBUSY || i > 100)
>>         exitf("unlink(%s) failed", filename);
>>       debug("umount(%s)\n", filename);
>>       if (umount2(filename, MNT_DETACH))
>>         exitf("umount(%s) failed", filename);
>>     }
>>   }
>>   closedir(dp);
>>   for (i = 0;; i++) {
>>     debug("rmdir(%s)\n", dir);
>>     if (rmdir(dir) == 0)
>>       break;
>>     if (i < 100) {
>>       if (errno == EROFS) {
>>         debug("ignoring EROFS\n");
>>         break;
>>       }
>>       if (errno == EBUSY) {
>>         debug("umount(%s)\n", dir);
>>         if (umount2(dir, MNT_DETACH))
>>           exitf("umount(%s) failed", dir);
>>         continue;
>>       }
>>       if (errno == ENOTEMPTY) {
>>         if (iter < 100) {
>>           iter++;
>>           goto retry;
>>         }
>>       }
>>     }
>>     exitf("rmdir(%s) failed", dir);
>>   }
>> }
>>
>> static uint64_t current_time_ms()
>> {
>>   struct timespec ts;
>>
>>   if (clock_gettime(CLOCK_MONOTONIC, &ts))
>>     fail("clock_gettime failed");
>>   return (uint64_t)ts.tv_sec * 1000 + (uint64_t)ts.tv_nsec / 1000000;
>> }
>>
>> static void test();
>>
>> void loop()
>> {
>>   int iter;
>>   for (iter = 0;; iter++) {
>>     char cwdbuf[256];
>>     sprintf(cwdbuf, "./%d", iter);
>>     if (mkdir(cwdbuf, 0777))
>>       fail("failed to mkdir");
>>     int pid = fork();
>>     if (pid < 0)
>>       fail("clone failed");
>>     if (pid == 0) {
>>       prctl(PR_SET_PDEATHSIG, SIGKILL, 0, 0, 0);
>>       setpgrp();
>>       if (chdir(cwdbuf))
>>         fail("failed to chdir");
>>       test();
>>       exit(0);
>>     }
>>     int status = 0;
>>     uint64_t start = current_time_ms();
>>     for (;;) {
>>       int res = waitpid(pid, &status, __WALL | WNOHANG);
>>       int errno0 = errno;
>>       if (res == pid)
>>         break;
>>       usleep(1000);
>>       if (current_time_ms() - start > 5 * 1000) {
>>         kill(-pid, SIGKILL);
>>         kill(pid, SIGKILL);
>>         waitpid(pid, &status, __WALL);
>>         break;
>>       }
>>     }
>>     remove_dir(cwdbuf);
>>   }
>> }
>>
>> long r[5];
>> void* thr(void* arg)
>> {
>>   switch ((long)arg) {
>>   case 0:
>>     r[0] =
>>         execute_syscall(__NR_mmap, 0x20000000ul, 0xa000ul, 0x3ul,
>>                         0x32ul, 0xfffffffffffffffful, 0x0ul, 0, 0, 0);
>>     break;
>>   case 1:
>>     r[1] = execute_syscall(__NR_socket, 0xaul, 0x5ul, 0x84ul, 0, 0, 0,
>>                            0, 0, 0);
>>     break;
>>   case 2:
>>     r[2] = execute_syscall(__NR_socket, 0x1ful, 0x3ul, 0x6ul, 0, 0, 0,
>>                            0, 0, 0);
>>     break;
>>   case 3:
>>     NONFAILING(memcpy(
>>         (void*)0x20009000,
>>         "\x83\x15\xf6\xdb\x47\x14\xae\xe2\x8d\xb8\x4d\xb9\x0f\x32\xe7"
>>         "\xf5\xbc\xa6\xae\x9a\x2f\x19\xed\xf0\x75\x6a\x0b\xf0\x00\xe9"
>>         "\xe1\x0e\xb4\xa5\x19\x08\x88\xfc\x8b\x2d\xe2\x9a\x0f\x55\x00"
>>         "\x00\x00\x00\x00\x08\x27\xab\x8e\x7d\xcb\xcc\x15\x4e\x79\xe2"
>>         "\xd9\xca\x15\xc3\x66\xbd\x44\xa8\x53\x1f\xda\xab\xce\x98\x39"
>>         "\x40\x4e\x75\x57\xfd\x57\xc0\x01\x0b\xb0",
>>         85));
>>     r[4] = execute_syscall(__NR_setsockopt, r[1], 0x0ul, 0x40ul,
>>                            0x20009000ul, 0x55ul, 0, 0, 0, 0);
>>     break;
>>   }
>>   return 0;
>> }
>>
>> void test()
>> {
>>   long i;
>>   pthread_t th[8];
>>
>>   memset(r, -1, sizeof(r));
>>   srand(getpid());
>>   for (i = 0; i < 4; i++) {
>>     pthread_create(&th[i], 0, thr, (void*)i);
>>     usleep(10000);
>>   }
>>   for (i = 0; i < 4; i++) {
>>     pthread_create(&th[4 + i], 0, thr, (void*)i);
>>     if (rand() % 2)
>>       usleep(rand() % 10000);
>>   }
>>   usleep(100000);
>> }
>>
>> int main()
>> {
>>   setup_main_process();
>>   int pid = do_sandbox_none();
>>   int status = 0;
>>   while (waitpid(pid, &status, __WALL) != pid) {
>>   }
>>   return 0;
>> }
>
