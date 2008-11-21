From: Eric Dumazet <dada1-fPLkHRcR87vqlBn2x/YWAg@public.gmane.org>
Subject: [PATCH] fs: pipe/sockets/anon dentries should not have a parent
Date: Fri, 21 Nov 2008 16:13:38 +0100
Message-ID: <4926D022.5060008@cosmosbay.com>
References: <Pine.LNX.4.64.0811201727070.9089@quilx.com>	<20081121083044.GL16242@elte.hu>	<49267694.1030506@cosmosbay.com> <20081121.010508.40225532.davem@davemloft.net> <4926AEDB.10007@cosmosbay.com>
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="------------010601020708030600090301"
Cc: cl-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org, rjw-KKrjLPT3xs0@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	kernel-testers-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, efault-Mmb7MZpHnFY@public.gmane.org,
	a.p.zijlstra-/NLkJaSkS4VmR6Xm/wNWPw@public.gmane.org, Linux Netdev List <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
To: David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>, mingo-X9Un+BFzKDI@public.gmane.org
Return-path: <kernel-testers-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <4926AEDB.10007-fPLkHRcR87vqlBn2x/YWAg@public.gmane.org>
Sender: kernel-testers-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

This is a multi-part message in MIME format.
--------------010601020708030600090301
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: quoted-printable

Eric Dumazet a =E9crit :
> David Miller a =E9crit :
>> From: Eric Dumazet <dada1-fPLkHRcR87vqlBn2x/YWAg@public.gmane.org>
>> Date: Fri, 21 Nov 2008 09:51:32 +0100
>>
>>> Now, I wish sockets and pipes not going through dcache, not tbench=20
>>> affair
>>> of course but real workloads...
>>>
>>> running 8 processes on a 8 way machine doing a
>>> for (;;)
>>>     close(socket(AF_INET, SOCK_STREAM, 0));
>>>
>>> is slow as hell, we hit so many contended cache lines ...
>>>
>>> ticket spin locks are slower in this case (dcache_lock for example
>>> is taken twice when we allocate a socket(), once in d_alloc(),=20
>>> another one
>>> in d_instantiate())
>>
>> As you of course know, this used to be a ton worse.  At least now
>> these things are unhashed. :)
>=20
> Well, this is dust compared to what we currently have.
>=20
> To allocate a socket we :
> 0) Do the usual file manipulation (pretty scalable these days)
>   (but recent drop_file_write_access() and co slow down a bit)
> 1) allocate an inode with new_inode()
>    This function :
>     - locks inode_lock,
>     - dirties nr_inodes counter
>     - dirties inode_in_use list  (for sockets, I doubt it is usefull)
>     - dirties superblock s_inodes.
>     - dirties last_ino counter
> All these are in different cache lines of course.
> 2) allocate a dentry
>   d_alloc() takes dcache_lock,
>   insert dentry on its parent list (dirtying sock_mnt->mnt_sb->s_root)
>   dirties nr_dentry
> 3) d_instantiate() dentry  (dcache_lock taken again)
> 4) init_file() -> atomic_inc on sock_mnt->refcount (in case we want to =

> umount this vfs ...)
>=20
>=20
>=20
> At close() time, we must undo the things. Its even more expensive becau=
se
> of the _atomic_dec_and_lock() that stress a lot, and because of two=20
> cache lines that are touched when an element is deleted from a list.
>=20
> for (i =3D 0; i < 1000*1000; i++)
>     close(socket(socket(AF_INET, SOCK_STREAM, 0));
>=20
> Cost if run one one cpu :
>=20
> real    0m1.561s
> user    0m0.092s
> sys     0m1.469s
>=20
> If run on 8 CPUS :
>=20
> real    0m27.496s
> user    0m0.657s
> sys     3m39.092s
>=20
>=20

[PATCH] fs: pipe/sockets/anon dentries should not have a parent

Linking pipe/sockets/anon dentries to one root 'parent' has no functional=

impact at all, but a scalability one.

We can avoid touching a cache line at allocation stage (inside d_alloc(),=
 no need
to touch root->d_count), but also at freeing time (in d_kill, decrementin=
g d_count)
We avoid an expensive atomic_dec_and_lock() call on the root dentry.

If we correct dnotify_parent() and inotify_d_instantiate() to take into a=
ccount
a NULL d_parent, we can call d_alloc() with a NULL parent instead of root=
 dentry.

Before patch, time to run 8 millions of close(socket()) calls on 8 CPUS w=
as :

real    0m27.496s
user    0m0.657s
sys     3m39.092s

After patch :

real    0m23.997s
user    0m0.682s
sys     3m11.193s


Old oprofile :
CPU: Core 2, speed 3000.11 MHz (estimated)
Counted CPU_CLK_UNHALTED events (Clock cycles when not halted) with a uni=
t mask of 0x00 (Unhalted core cycles) count 100000
samples  cum. samples  %        cum. %     symbol name
164257   164257        11.0245  11.0245    init_file
155488   319745        10.4359  21.4604    d_alloc
151887   471632        10.1942  31.6547    _atomic_dec_and_lock
91620    563252         6.1493  37.8039    inet_create
74245    637497         4.9831  42.7871    kmem_cache_alloc
46702    684199         3.1345  45.9216    dentry_iput
46186    730385         3.0999  49.0215    tcp_close
42824    773209         2.8742  51.8957    kmem_cache_free
37275    810484         2.5018  54.3975    wake_up_inode
36553    847037         2.4533  56.8508    tcp_v4_init_sock
35661    882698         2.3935  59.2443    inotify_d_instantiate
32998    915696         2.2147  61.4590    sysenter_past_esp
31442    947138         2.1103  63.5693    d_instantiate
31303    978441         2.1010  65.6703    generic_forget_inode
27533    1005974        1.8479  67.5183    vfs_dq_drop
24237    1030211        1.6267  69.1450    sock_attach_fd
19290    1049501        1.2947  70.4397    __copy_from_user_ll


New oprofile :
CPU: Core 2, speed 3000.24 MHz (estimated)
Counted CPU_CLK_UNHALTED events (Clock cycles when not halted) with a uni=
t mask of 0x00 (Unhalted core cycles) count 100000
samples  cum. samples  %        cum. %     symbol name
147287   147287        10.3984  10.3984    new_inode
144884   292171        10.2287  20.6271    inet_create
93670    385841         6.6131  27.2402    init_file
89852    475693         6.3435  33.5837    wake_up_inode
80910    556603         5.7122  39.2959    kmem_cache_alloc
53588    610191         3.7833  43.0792    _atomic_dec_and_lock
44341    654532         3.1305  46.2096    generic_forget_inode
38710    693242         2.7329  48.9425    kmem_cache_free
37605    730847         2.6549  51.5974    tcp_v4_init_sock
37228    768075         2.6283  54.2257    d_alloc
34085    802160         2.4064  56.6321    tcp_close
32550    834710         2.2980  58.9301    sysenter_past_esp
25931    860641         1.8307  60.7608    vfs_dq_drop
24458    885099         1.7267  62.4875    d_kill
22015    907114         1.5542  64.0418    dentry_iput
18877    925991         1.3327  65.3745    __copy_from_user_ll
17873    943864         1.2618  66.6363    mwait_idle

Signed-off-by: Eric Dumazet <dada1-fPLkHRcR87vqlBn2x/YWAg@public.gmane.org>
---
 fs/anon_inodes.c |    2 +-
 fs/dnotify.c     |    2 +-
 fs/inotify.c     |    2 +-
 fs/pipe.c        |    2 +-
 net/socket.c     |    2 +-
 5 files changed, 5 insertions(+), 5 deletions(-)

--------------010601020708030600090301
Content-Type: text/plain;
 name="null_parent.patch"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="null_parent.patch"

diff --git a/fs/anon_inodes.c b/fs/anon_inodes.c
index 3662dd4..22cce87 100644
--- a/fs/anon_inodes.c
+++ b/fs/anon_inodes.c
@@ -92,7 +92,7 @@ int anon_inode_getfd(const char *name, const struct file_operations *fops,
 	this.name = name;
 	this.len = strlen(name);
 	this.hash = 0;
-	dentry = d_alloc(anon_inode_mnt->mnt_sb->s_root, &this);
+	dentry = d_alloc(NULL, &this);
 	if (!dentry)
 		goto err_put_unused_fd;
 
diff --git a/fs/dnotify.c b/fs/dnotify.c
index 676073b..66066a3 100644
--- a/fs/dnotify.c
+++ b/fs/dnotify.c
@@ -173,7 +173,7 @@ void dnotify_parent(struct dentry *dentry, unsigned long event)
 
 	spin_lock(&dentry->d_lock);
 	parent = dentry->d_parent;
-	if (parent->d_inode->i_dnotify_mask & event) {
+	if (parent && parent->d_inode->i_dnotify_mask & event) {
 		dget(parent);
 		spin_unlock(&dentry->d_lock);
 		__inode_dir_notify(parent->d_inode, event);
diff --git a/fs/inotify.c b/fs/inotify.c
index 7bbed1b..9f051bb 100644
--- a/fs/inotify.c
+++ b/fs/inotify.c
@@ -270,7 +270,7 @@ void inotify_d_instantiate(struct dentry *entry, struct inode *inode)
 
 	spin_lock(&entry->d_lock);
 	parent = entry->d_parent;
-	if (parent->d_inode && inotify_inode_watched(parent->d_inode))
+	if (parent && parent->d_inode && inotify_inode_watched(parent->d_inode))
 		entry->d_flags |= DCACHE_INOTIFY_PARENT_WATCHED;
 	spin_unlock(&entry->d_lock);
 }
diff --git a/fs/pipe.c b/fs/pipe.c
index 7aea8b8..4b961bc 100644
--- a/fs/pipe.c
+++ b/fs/pipe.c
@@ -926,7 +926,7 @@ struct file *create_write_pipe(int flags)
 		goto err;
 
 	err = -ENOMEM;
-	dentry = d_alloc(pipe_mnt->mnt_sb->s_root, &name);
+	dentry = d_alloc(NULL, &name);
 	if (!dentry)
 		goto err_inode;
 
diff --git a/net/socket.c b/net/socket.c
index e9d65ea..b84de7d 100644
--- a/net/socket.c
+++ b/net/socket.c
@@ -373,7 +373,7 @@ static int sock_attach_fd(struct socket *sock, struct file *file, int flags)
 	struct dentry *dentry;
 	struct qstr name = { .name = "" };
 
-	dentry = d_alloc(sock_mnt->mnt_sb->s_root, &name);
+	dentry = d_alloc(NULL, &name);
 	if (unlikely(!dentry))
 		return -ENOMEM;
 

--------------010601020708030600090301--
