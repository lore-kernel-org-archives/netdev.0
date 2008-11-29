From: Eric Dumazet <dada1@cosmosbay.com>
Subject: [PATCH v2 0/5] fs: Scalability of sockets/pipes allocation/deallocation
 on SMP
Date: Sat, 29 Nov 2008 09:43:28 +0100
Message-ID: <493100B0.6090104@cosmosbay.com>
References: <Pine.LNX.4.64.0811201727070.9089@quilx.com> <20081121083044.GL16242@elte.hu> <49267694.1030506@cosmosbay.com> <20081121.010508.40225532.davem@davemloft.net> <4926AEDB.10007@cosmosbay.com> <4926D022.5060008@cosmosbay.com> <20081121152148.GA20388@elte.hu> <4926D39D.9050603@cosmosbay.com> <20081121153453.GA23713@elte.hu> <492DDB6A.8090806@cosmosbay.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>,
	"Rafael J. Wysocki" <rjw@sisk.pl>, linux-kernel@vger.kernel.org,
	"kernel-testers@vger.kernel.org >> Kernel Testers List"
	<kernel-testers@vger.kernel.org>, Mike Galbraith <efault@gmx.de>,
	Peter Zijlstra <a.p.zijlstra@chello.nl>,
	Linux Netdev List <netdev@vger.kernel.org>,
	Christoph Lameter <cl@linux-foundation.org>,
	linux-fsdevel@vger.kernel.org, Al Viro <viro@ZenIV.linux.org.uk>
To: Ingo Molnar <mingo@elte.hu>, Christoph Hellwig <hch@infradead.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from gw1.cosmosbay.com ([86.65.150.130]:34449 "EHLO
	gw1.cosmosbay.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750895AbYK2In6 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 29 Nov 2008 03:43:58 -0500
In-Reply-To: <492DDB6A.8090806@cosmosbay.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi all

Short summary : Nice speedups for allocation/deallocation of sockets/pipes
(From 27.5 seconds to 2.9 seconds (2.3 seconds with SLUB tweaks))

Long version :

For this second version, I removed the mntput()/mntget() optimization
since most reviewers are not convinced it is usefull.
This is a four lines patch that can be reconsidered later.

I chose the name SINGLE instead of SPECIAL to name
isolated dentries (for sockets, pipes, anonymous fd) that
have no parent and no relationship in the vfs.

Thanks all

To allocate a socket or a pipe we :

0) Do the usual file table manipulation (pretty scalable these days,
but would be faster if 'struct files' were using SLAB_DESTROY_BY_RCU
and avoid call_rcu() cache killer)

1) allocate an inode with new_inode()
This function :
- locks inode_lock,
- dirties nr_inodes counter
- dirties inode_in_use list  (for sockets/pipes, this is useless)
- dirties superblock s_inodes.  - dirties last_ino counter
All these are in different cache lines unfortunatly.

2) allocate a dentry
d_alloc() takes dcache_lock,
insert dentry on its parent list (dirtying sock_mnt->mnt_sb->s_root)
dirties nr_dentry

3) d_instantiate() dentry  (dcache_lock taken again)

4) init_file() -> atomic_inc() on sock_mnt->refcount


At close() time, we must undo the things. Its even more expensive because
of the _atomic_dec_and_lock() that stress a lot, and because of two cache
lines that are touched when an element is deleted from a list
(previous and next items)

This is really bad, since sockets/pipes dont need to be visible in dcache
or an inode list per super block.

This patch series get rid of all but one contended cache lines for
sockets, pipes and anonymous fd  (signalfd, timerfd, ...)

Sample program :

for (i = 0; i < 1000000; i++)
	close(socket(AF_INET, SOCK_STREAM, 0));

Cost if one cpu runs the program :

real    1.561s
user    0.092s
sys     1.469s

Cost if 8 processes are launched on a 8 CPU machine
(benchmark named socket8) :

real    27.496s   <<<< !!!! >>>>
user    0.657s
sys     3m39.092s

Oprofile results (for the 8 process run, 3 times):

CPU: Core 2, speed 3000.03 MHz (estimated)
Counted CPU_CLK_UNHALTED events (Clock cycles when not halted) with a unit
mask of 0x00 (Unhalted core cycles) count 100000
samples  cum. samples  %        cum. %     symbol name
3347352  3347352       28.0232  28.0232    _atomic_dec_and_lock
3301428  6648780       27.6388  55.6620    d_instantiate
2971130  9619910       24.8736  80.5355    d_alloc
241318   9861228        2.0203  82.5558    init_file
146190   10007418       1.2239  83.7797    __slab_free
144149   10151567       1.2068  84.9864    inotify_d_instantiate
143971   10295538       1.2053  86.1917    inet_create
137168   10432706       1.1483  87.3401    new_inode
117549   10550255       0.9841  88.3242    add_partial
110795   10661050       0.9275  89.2517    generic_drop_inode
107137   10768187       0.8969  90.1486    kmem_cache_alloc
94029    10862216       0.7872  90.9358    tcp_close
82837    10945053       0.6935  91.6293    dput
67486    11012539       0.5650  92.1943    dentry_iput
57751    11070290       0.4835  92.6778    iput
54327    11124617       0.4548  93.1326    tcp_v4_init_sock
49921    11174538       0.4179  93.5505    sysenter_past_esp
47616    11222154       0.3986  93.9491    kmem_cache_free
30792    11252946       0.2578  94.2069    clear_inode
27540    11280486       0.2306  94.4375    copy_from_user
26509    11306995       0.2219  94.6594    init_timer
26363    11333358       0.2207  94.8801    discard_slab
25284    11358642       0.2117  95.0918    __fput
22482    11381124       0.1882  95.2800    __percpu_counter_add
20369    11401493       0.1705  95.4505    sock_alloc
18501    11419994       0.1549  95.6054    inet_csk_destroy_sock
17923    11437917       0.1500  95.7555    sys_close


This patch serie avoids all contented cache lines and makes this "bench"
pretty fast.


New cost if run on one cpu :

real    1.325s   (instead of 1.561s)
user    0.091s
sys     1.234s


If run on 8 CPUS :

real    0m2.971s
user    0m0.726s
sys     0m21.310s

CPU: Core 2, speed 3000.04 MHz (estimated)
Counted CPU_CLK_UNHALTED events (Clock cycles when not halted) with a unit mask of 0x00 (Unhalted core cycles) count 100
000
samples  cum. samples  %        cum. %     symbol name
189772   189772        12.7205  12.7205    _atomic_dec_and_lock
140467   330239         9.4155  22.1360    __slab_free
128210   458449         8.5940  30.7300    add_partial
121578   580027         8.1494  38.8794    kmem_cache_alloc
72626    652653         4.8681  43.7475    init_file
62720    715373         4.2041  47.9517    __percpu_counter_add
51632    767005         3.4609  51.4126    sysenter_past_esp
49196    816201         3.2976  54.7102    tcp_close
47933    864134         3.2130  57.9231    kmem_cache_free
29628    893762         1.9860  59.9091    copy_from_user
28443    922205         1.9065  61.8157    init_timer
25602    947807         1.7161  63.5318    __slab_alloc
22139    969946         1.4840  65.0158    discard_slab
20428    990374         1.3693  66.3851    __call_rcu
18174    1008548        1.2182  67.6033    alloc_fd
17643    1026191        1.1826  68.7859    __fput
17374    1043565        1.1646  69.9505    d_alloc
17196    1060761        1.1527  71.1031    sys_close
17024    1077785        1.1411  72.2442    inet_create
15208    1092993        1.0194  73.2636    alloc_inode
12201    1105194        0.8178  74.0815    fd_install
12167    1117361        0.8156  74.8970    lock_sock_nested
12123    1129484        0.8126  75.7096    get_empty_filp
11648    1141132        0.7808  76.4904    release_sock
11509    1152641        0.7715  77.2619    dput
11335    1163976        0.7598  78.0216    sock_init_data
11038    1175014        0.7399  78.7615    inet_csk_destroy_sock
10880    1185894        0.7293  79.4908    drop_file_write_access
10083    1195977        0.6759  80.1667    inotify_d_instantiate
9216     1205193        0.6178  80.7844    local_bh_enable_ip
8881     1214074        0.5953  81.3797    sysenter_do_call
8759     1222833        0.5871  81.9668    setup_object
8489     1231322        0.5690  82.5359    iput_single

So we now hit mntput()/mntget() and SLUB.

The last point is about SLUB being hit hard, unless we
use slub_min_order=3 (or slub_min_objects=45) at boot,
or we use Christoph Lameter patch (struct file RCU optimizations)
http://thread.gmane.org/gmane.linux.kernel/418615

If we boot machine with slub_min_order=3, SLUB overhead disappears.

If run on 8 CPUS :

real    0m2.315s
user    0m0.752s
sys     0m17.324s

CPU: Core 2, speed 3000.15 MHz (estimated)
Counted CPU_CLK_UNHALTED events (Clock cycles when not halted) with a unit
mask of 0x00 (Unhalted core cycles) count 100000
samples  cum. samples  %        cum. %     symbol name
199409   199409        15.6440  15.6440    _atomic_dec_and_lock    (mntput())
141606   341015        11.1092  26.7532    kmem_cache_alloc
76071    417086         5.9679  32.7211    init_file
70595    487681         5.5383  38.2595    __percpu_counter_add
51595    539276         4.0477  42.3072    sysenter_past_esp
49313    588589         3.8687  46.1759    tcp_close
45503    634092         3.5698  49.7457    kmem_cache_free
41413    675505         3.2489  52.9946    __slab_free
29911    705416         2.3466  55.3412    copy_from_user
28979    734395         2.2735  57.6146    init_timer
22251    756646         1.7456  59.3602    get_empty_filp
19942    776588         1.5645  60.9247    __call_rcu
18348    794936         1.4394  62.3642    __fput
18328    813264         1.4379  63.8020    alloc_fd
17395    830659         1.3647  65.1667    sys_close
17301    847960         1.3573  66.5240    d_alloc
16570    864530         1.2999  67.8239    inet_create
15522    880052         1.2177  69.0417    alloc_inode
13185    893237         1.0344  70.0761    setup_object
12359    905596         0.9696  71.0456    fd_install
12275    917871         0.9630  72.0086    lock_sock_nested
11924    929795         0.9355  72.9441    release_sock
11790    941585         0.9249  73.8690    sock_init_data
11310    952895         0.8873  74.7563    dput
10924    963819         0.8570  75.6133    drop_file_write_access
10903    974722         0.8554  76.4687    inet_csk_destroy_sock
10184    984906         0.7990  77.2676    inotify_d_instantiate
9372     994278         0.7353  78.0029    local_bh_enable_ip
8901     1003179        0.6983  78.7012    sysenter_do_call
8569     1011748        0.6723  79.3735    iput_single
8194     1019942        0.6428  80.0163    inet_release


This patch serie contains 5 patches, against net-next-2.6 tree
(because this tree already contains network improvement on this
subject, but should apply on other trees)

[PATCH 1/5] fs: Use a percpu_counter to track nr_dentry

Adding a percpu_counter nr_dentry avoids cache line ping pongs
between cpus to maintain this metric, and dcache_lock is
no more needed to protect dentry_stat.nr_dentry

We centralize nr_dentry updates at the right place :
- increments in d_alloc()
- decrements in d_free()

d_alloc() can avoid taking dcache_lock if parent is NULL

(socket8 bench result : 27.5s to 25s)

[PATCH 2/5] fs: Use a percpu_counter to track nr_inodes

Avoids cache line ping pongs between cpus and prepare next patch,
because updates of nr_inodes dont need inode_lock anymore.

(socket8 bench result : no difference at this point)

[PATCH 3/5] fs: Introduce a per_cpu last_ino allocator

new_inode() dirties a contended cache line to get increasing
inode numbers.

Solve this problem by providing to each cpu a per_cpu variable,
feeded by the shared last_ino, but once every 1024 allocations.

This reduce contention on the shared last_ino, and give same
spreading ino numbers than before.
(same wraparound after 2^32 allocations)

(socket8 bench result : no difference)


[PATCH 4/5] fs: Introduce SINGLE dentries for pipes, socket, anon fd

Sockets, pipes and anonymous fds have interesting properties.

Like other files, they use a dentry and an inode.

But dentries for these kind of files are not hashed into dcache,
since there is no way someone can lookup such a file in the vfs tree.
(/proc/{pid}/fd/{number} uses a different mechanism)

Still, allocating and freeing such dentries are expensive processes,
because we currently take dcache_lock inside d_alloc(), d_instantiate(),
and dput(). This lock is very contended on SMP machines.

This patch defines a new DCACHE_SINGLE flag, to mark a dentry as
a single one (for sockets, pipes, anonymous fd), and a new
d_alloc_single(const struct qstr *name, struct inode *inode)
method, called by the three subsystems.

Internally, dput() can take a fast path to dput_single() for
SINGLE dentries. No more atomic_dec_and_lock()
for such dentries.


Differences betwen an SINGLE dentry and a normal one are :

1) SINGLE dentry has the DCACHE_SINGLE flag
2) SINGLE dentry's parent is itself (DCACHE_DISCONNECTED)
This to avoid taking a reference on sb 'root' dentry, shared
by too many dentries.
3) They are not hashed into global hash table (DCACHE_UNHASHED)
4) Their d_alias list is empty

(socket8 bench result : from 25s to 19.9s)

[PATCH 5/5] fs: new_inode_single() and iput_single()

Goal of this patch is to not touch inode_lock for socket/pipes/anonfd
inodes allocation/freeing.

SINGLE dentries are attached to inodes that dont need to be linked
in a list of inodes, being "inode_in_use" or "sb->s_inodes"
As inode_lock was taken only to protect these lists, we avoid 
taking it as well.

Using iput_single() from dput_single() avoids taking inode_lock
at freeing time.

This patch has a very noticeable effect, because we avoid dirtying of 
three contended cache lines in new_inode(), and five cache lines
in iput()

(socket8 bench result : from 19.9s to 2.3s)


Signed-off-by: Eric Dumazet <dada1@cosmosbay.com>
---
Overall diffstat :

 fs/anon_inodes.c       |   18 ------
 fs/dcache.c            |  100 ++++++++++++++++++++++++++++++--------
 fs/fs-writeback.c      |    2
 fs/inode.c             |  101 +++++++++++++++++++++++++++++++--------
 fs/pipe.c              |   25 +--------
 include/linux/dcache.h |    9 +++
 include/linux/fs.h     |   17 ++++++
 kernel/sysctl.c        |    6 +-
 mm/page-writeback.c    |    2
 net/socket.c           |   26 +---------
 10 files changed, 200 insertions(+), 106 deletions(-)

