From: Eric Dumazet <dada1@cosmosbay.com>
Subject: [PATCH 0/6] fs: Scalability of sockets/pipes allocation/deallocation
 on SMP
Date: Thu, 27 Nov 2008 00:27:38 +0100
Message-ID: <492DDB6A.8090806@cosmosbay.com>
References: <Pine.LNX.4.64.0811201727070.9089@quilx.com> <20081121083044.GL16242@elte.hu> <49267694.1030506@cosmosbay.com> <20081121.010508.40225532.davem@davemloft.net> <4926AEDB.10007@cosmosbay.com> <4926D022.5060008@cosmosbay.com> <20081121152148.GA20388@elte.hu> <4926D39D.9050603@cosmosbay.com> <20081121153453.GA23713@elte.hu>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>,
	"Rafael J. Wysocki" <rjw@sisk.pl>, linux-kernel@vger.kernel.org,
	kernel-testers@vger.kernel.org, Mike Galbraith <efault@gmx.de>,
	Peter Zijlstra <a.p.zijlstra@chello.nl>,
	Linux Netdev List <netdev@vger.kernel.org>,
	Christoph Lameter <cl@linux-foundation.org>,
	Christoph Hellwig <hch@infradead.org>
To: Ingo Molnar <mingo@elte.hu>
Return-path: <netdev-owner@vger.kernel.org>
Received: from gw1.cosmosbay.com ([86.65.150.130]:58231 "EHLO
	gw1.cosmosbay.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752566AbYKZX3S (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 26 Nov 2008 18:29:18 -0500
In-Reply-To: <20081121153453.GA23713@elte.hu>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi all

Short summary : Nice speedups for allocation/deallocation of sockets/pipes
(From 27.5 seconds to 1.6 second)

Long version :

To allocate a socket or a pipe we :

0) Do the usual file table manipulation (pretty scalable these days,
 but would be faster if 'struct files' were using SLAB_DESTROY_BY_RCU
 and avoid call_rcu() cache killer)

1) allocate an inode with new_inode()
 This function :
  - locks inode_lock,
  - dirties nr_inodes counter
  - dirties inode_in_use list  (for sockets/pipes, this is useless)
  - dirties superblock s_inodes. 
  - dirties last_ino counter
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

This patch series get rid of all contended cache lines for sockets, pipes
and anonymous fd  (signalfd, timerfd, ...)

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

real    2.229s     <<<< instead of 27.496s >>>
user    0.695s
sys     16.903s

Oprofile results (for the 8 process run, 3 times):
CPU: Core 2, speed 2999.74 MHz (estimated)
Counted CPU_CLK_UNHALTED events (Clock cycles when not halted) with a unit
mask of 0x00 (Unhalted core cycles) count 100000
samples  cum. samples  %        cum. %     symbol name
143791   143791        11.7849  11.7849    __slab_free
128404   272195        10.5238  22.3087    add_partial
99150    371345         8.1262  30.4349    kmem_cache_alloc
52031    423376         4.2644  34.6993    sysenter_past_esp
47752    471128         3.9137  38.6130    kmem_cache_free
47429    518557         3.8872  42.5002    tcp_close
34376    552933         2.8174  45.3176    __percpu_counter_add
29046    581979         2.3806  47.6982    copy_from_user
28249    610228         2.3152  50.0134    init_timer
26220    636448         2.1490  52.1624    __slab_alloc
23402    659850         1.9180  54.0803    discard_slab
20560    680410         1.6851  55.7654    __call_rcu
18288    698698         1.4989  57.2643    d_alloc
16425    715123         1.3462  58.6104    get_empty_filp
16237    731360         1.3308  59.9412    __fput
15729    747089         1.2891  61.2303    alloc_fd
15021    762110         1.2311  62.4614    alloc_inode
14690    776800         1.2040  63.6654    sys_close
14666    791466         1.2020  64.8674    inet_create
13638    805104         1.1178  65.9852    dput
12503    817607         1.0247  67.0099    iput_special
12231    829838         1.0024  68.0123    lock_sock_nested
12210    842048         1.0007  69.0130    fd_install
12137    854185         0.9947  70.0078    d_alloc_special
12058    866243         0.9883  70.9960    sock_init_data
11200    877443         0.9179  71.9140    release_sock
11114    888557         0.9109  72.8248    inotify_d_instantiate

The last point is about SLUB being hit hard, unless we
use slub_min_order=3 at boot, or we use Christoph Lameter
patch (struct file RCU optimizations)
http://thread.gmane.org/gmane.linux.kernel/418615

If we boot machine with slub_min_order=3, SLUB overhead disappears.

New cost if run on one cpu :

real    1.307s
user    0.094s
sys     1.214s

If run on 8 CPUS :

real    1.625s     <<<< instead of 27.496s or 2.229s >>>
user    0.771s
sys     12.061s

Oprofile results (for the 8 process run, 3 times):
CPU: Core 2, speed 3000.05 MHz (estimated)
Counted CPU_CLK_UNHALTED events (Clock cycles when not halted) with a unit
mask of 0x00 (Unhalted core cycles) count 100000
samples  cum. samples  %        cum. %     symbol name
108005   108005        11.0758  11.0758    kmem_cache_alloc
52023    160028         5.3349  16.4107    sysenter_past_esp
47363    207391         4.8570  21.2678    tcp_close
45430    252821         4.6588  25.9266    kmem_cache_free
36566    289387         3.7498  29.6764    __percpu_counter_add
36085    325472         3.7005  33.3769    __slab_free
29185    354657         2.9929  36.3698    copy_from_user
28210    382867         2.8929  39.2627    init_timer
25663    408530         2.6317  41.8944    d_alloc_special
22360    430890         2.2930  44.1874    cap_file_alloc_security
19237    450127         1.9727  46.1601    __call_rcu
19097    469224         1.9584  48.1185    d_alloc
16962    486186         1.7394  49.8580    alloc_fd
16315    502501         1.6731  51.5311    __fput
16102    518603         1.6512  53.1823    get_empty_filp
14954    533557         1.5335  54.7158    inet_create
14468    548025         1.4837  56.1995    alloc_inode
14198    562223         1.4560  57.6555    sys_close
13905    576128         1.4259  59.0814    dput
12262    588390         1.2575  60.3389    lock_sock_nested
12203    600593         1.2514  61.5903    sock_attach_fd
12147    612740         1.2457  62.8360    iput_special
12049    624789         1.2356  64.0716    fd_install
12033    636822         1.2340  65.3056    sock_init_data
11999    648821         1.2305  66.5361    release_sock
11231    660052         1.1517  67.6878    inotify_d_instantiate
11068    671120         1.1350  68.8228    inet_csk_destroy_sock


This patch serie contains 6 patches, against net-next-2.6 tree
(because this tree already contains network improvement on this
subject, but should apply on other trees)

[PATCH 1/6] fs: Introduce a per_cpu nr_dentry

Adding a per_cpu nr_dentry avoids cache line ping pongs between
cpus to maintain this metric.

We centralize decrements of nr_dentry in d_free(),
and increments in d_alloc().

d_alloc() can avoid taking dcache_lock if parent is NULL


[PATCH 2/6] fs: Introduce special dentries for pipes, socket, anon fd

Sockets, pipes and anonymous fds have interesting properties.

Like other files, they use a dentry and an inode.

But dentries for these kind of files are not hashed into dcache,
since there is no way someone can lookup such a file in the vfs tree.
(/proc/{pid}/fd/{number} uses a different mechanism)

Still, allocating and freeing such dentries are expensive processes,
because we currently take dcache_lock inside d_alloc(), d_instantiate(),
and dput(). This lock is very contended on SMP machines.

This patch defines a new DCACHE_SPECIAL flag, to mark a dentry as
a special one (for sockets, pipes, anonymous fd), and a new
d_alloc_special(const struct qstr *name, struct inode *inode)
method, called by the three subsystems.

Internally, dput() can take a fast path to dput_special() for
special dentries.

Differences betwen a special dentry and a normal one are :

1) Special dentry has the DCACHE_SPECIAL flag
2) Special dentry's parent are themselves
  This to avoid taking a reference on 'root' dentry, shared
  by too many dentries.
3) They are not hashed into global hash table
4) Their d_alias list is empty

Internally, dput() can avoid an expensive atomic_dec_and_lock()
for special dentries.


(socket8 bench result : from 27.5s to 25.5s) 

[PATCH 3/6] fs: Introduce a per_cpu last_ino allocator

new_inode() dirties a contended cache line to get inode numbers.

Solve this problem by providing to each cpu a per_cpu variable,
feeded by the shared last_ino, but once every 1024 allocations.

This reduce contention on the shared last_ino.

Note : last_ino_get() method must be called with preemption disabled.

(socket8 bench result : 25.5s to 25s almost no differences, but 
this is because inode_lock cost is too heavy for the moment)

[PATCH 4/6] fs: Introduce a per_cpu nr_inodes

Avoids cache line ping pongs between cpus and prepare next patch,
because updates of nr_inodes dont need inode_lock anymore.

(socket8 bench result : 25s to 20.5s)

[PATCH 5/6] fs: Introduce special inodes

 Goal of this patch is to not touch inode_lock for socket/pipes/anonfd
 inodes allocation/freeing.

 In new_inode(), we test if super block has MS_SPECIAL flag set.
 If yes, we dont put inode in "inode_in_use" list nor "sb->s_inodes" list
 As inode_lock was taken only to protect these lists, we avoid it as well

 Using iput_special() from dput_special() avoids taking inode_lock
 at freeing time.

 This patch has a very noticeable effect, because we avoid dirtying 
 of three contended cache lines in new_inode(), and five cache lines
 in iput()

Note: Not sure if we can use MS_SPECIAL=MS_NOUSER, or if we
really need a different flag.

(socket8 bench result : from 20.5s to 2.94s) 

[PATCH 6/6] fs: Introduce kern_mount_special() to mount special vfs

This function arms a flag (MNT_SPECIAL) on the vfs, to avoid
refcounting on permanent system vfs.
Use this function for sockets, pipes, anonymous fds.

(socket8 bench result : from 2.94s to 2.23s)

Signed-off-by: Eric Dumazet <dada1@cosmosbay.com>
---
Overall diffstat :

 fs/anon_inodes.c       |   19 +-----
 fs/dcache.c            |  106 ++++++++++++++++++++++++++++++++-------
 fs/fs-writeback.c      |    2
 fs/inode.c             |  101 +++++++++++++++++++++++++++++++------
 fs/pipe.c              |   28 +---------
 fs/super.c             |    9 +++
 include/linux/dcache.h |    2
 include/linux/fs.h     |    8 ++
 include/linux/mount.h  |    5 +
 kernel/sysctl.c        |    6 +-
 mm/page-writeback.c    |    2
 net/socket.c           |   27 +--------
 12 files changed, 212 insertions(+), 103 deletions(-)

