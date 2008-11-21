From: Eric Dumazet <dada1@cosmosbay.com>
Subject: [PATCH] fs: pipe/sockets/anon dentries should have themselves as
 parent
Date: Fri, 21 Nov 2008 18:58:29 +0100
Message-ID: <4926F6C5.9030108@cosmosbay.com>
References: <Pine.LNX.4.64.0811201727070.9089@quilx.com> <20081121083044.GL16242@elte.hu> <49267694.1030506@cosmosbay.com> <20081121.010508.40225532.davem@davemloft.net> <4926AEDB.10007@cosmosbay.com> <4926D022.5060008@cosmosbay.com> <20081121153626.GA9281@infradead.org>
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="------------080507060605070601070305"
Cc: David Miller <davem@davemloft.net>, mingo@elte.hu,
	cl@linux-foundation.org, rjw@sisk.pl, linux-kernel@vger.kernel.org,
	kernel-testers@vger.kernel.org, efault@gmx.de,
	a.p.zijlstra@chello.nl, Linux Netdev List <netdev@vger.kernel.org>,
	viro@zeniv.linux.org.uk, linux-fsdevel@vger.kernel.org
To: Christoph Hellwig <hch@infradead.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from gw1.cosmosbay.com ([86.65.150.130]:60467 "EHLO
	gw1.cosmosbay.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753858AbYKUR7c (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 21 Nov 2008 12:59:32 -0500
In-Reply-To: <20081121153626.GA9281@infradead.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This is a multi-part message in MIME format.
--------------080507060605070601070305
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: quoted-printable

Christoph Hellwig a =E9crit :
> On Fri, Nov 21, 2008 at 04:13:38PM +0100, Eric Dumazet wrote:
>> [PATCH] fs: pipe/sockets/anon dentries should not have a parent
>>
>> Linking pipe/sockets/anon dentries to one root 'parent' has no functio=
nal
>> impact at all, but a scalability one.
>>
>> We can avoid touching a cache line at allocation stage (inside d_alloc=
(), no need
>> to touch root->d_count), but also at freeing time (in d_kill, decremen=
ting d_count)
>> We avoid an expensive atomic_dec_and_lock() call on the root dentry.
>>
>> If we correct dnotify_parent() and inotify_d_instantiate() to take int=
o account
>> a NULL d_parent, we can call d_alloc() with a NULL parent instead of r=
oot dentry.
>=20
> Sorry folks, but a NULL d_parent is a no-go from the VFS perspective,
> but you can set d_parent to the dentry itself which is the magic used
> for root of tree dentries.  They should also be marked
> DCACHE_DISCONNECTED to make sure this is not unexpected.
>=20
> And this kind of stuff really needs to go through -fsdevel.

Thanks Christoph for your review, sorry for fsdevel being forgotten.

d_alloc_root() is not an option here, since we also want such dentries
to be unhashed. So here is a second version, with the introduction
of a new helper, d_alloc_unhashed(), to be used by pipes, sockets and ano=
n

I got even better numbers, probably because dnotify/inotify dont have
the NULL d_parent test anymore.

[PATCH] fs: pipe/sockets/anon dentries should have themselves as parent


Linking pipe/sockets/anon dentries to one root 'parent' has no functional=

impact at all, but a scalability one.

We can avoid touching a cache line at allocation stage (inside d_alloc(),=
 no need
to touch root->d_count), but also at freeing time (in d_kill, decrementin=
g d_count)
We avoid an expensive atomic_dec_and_lock() call on the root dentry.

We add d_alloc_unhashed(const char *name, struct inode *inode) helper
to be used by pipes/socket/anon. This function is about the same as
d_alloc_root() but for unhashed entries.

Before patch, time to run 8 *  1 million of close(socket()) calls on 8 CP=
US was :

real    0m27.496s
user    0m0.657s
sys     3m39.092s

After patch :

real    0m23.843s
user    0m0.616s
sys     3m9.732s


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
CPU: Core 2, speed 3000.11 MHz (estimated)
Counted CPU_CLK_UNHALTED events (Clock cycles when not halted) with a uni=
t mask of 0x00 (Unhalted core cycles) count 100000
samples  cum. samples  %        cum. %     symbol name
148703   148703        10.8581  10.8581    inet_create
116680   265383         8.5198  19.3779    new_inode
108912   374295         7.9526  27.3306    init_file
82911    457206         6.0541  33.3846    kmem_cache_alloc
65690    522896         4.7966  38.1812    wake_up_inode
53286    576182         3.8909  42.0721    _atomic_dec_and_lock
43814    619996         3.1992  45.2713    generic_forget_inode
41993    661989         3.0663  48.3376    d_alloc
41244    703233         3.0116  51.3492    kmem_cache_free
39244    742477         2.8655  54.2148    tcp_v4_init_sock
37402    779879         2.7310  56.9458    tcp_close
33336    813215         2.4342  59.3800    sysenter_past_esp
28596    841811         2.0880  61.4680    inode_has_buffers
25769    867580         1.8816  63.3496    d_kill
22606    890186         1.6507  65.0003    dentry_iput
20224    910410         1.4767  66.4770    vfs_dq_drop
19800    930210         1.4458  67.9228    __copy_from_user_ll

Signed-off-by: Eric Dumazet <dada1@cosmosbay.com>
---
 fs/anon_inodes.c       |    9 +--------
 fs/dcache.c            |   31 +++++++++++++++++++++++++++++++
 fs/pipe.c              |   10 +---------
 include/linux/dcache.h |    1 +
 net/socket.c           |   10 +---------
 5 files changed, 35 insertions(+), 26 deletions(-)

--------------080507060605070601070305
Content-Type: text/plain;
 name="d_alloc_unhashed.patch"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="d_alloc_unhashed.patch"

diff --git a/fs/anon_inodes.c b/fs/anon_inodes.c
index 3662dd4..9fd0515 100644
--- a/fs/anon_inodes.c
+++ b/fs/anon_inodes.c
@@ -71,7 +71,6 @@ static struct dentry_operations anon_inodefs_dentry_operations = {
 int anon_inode_getfd(const char *name, const struct file_operations *fops,
 		     void *priv, int flags)
 {
-	struct qstr this;
 	struct dentry *dentry;
 	struct file *file;
 	int error, fd;
@@ -89,10 +88,7 @@ int anon_inode_getfd(const char *name, const struct file_operations *fops,
 	 * using the inode sequence number.
 	 */
 	error = -ENOMEM;
-	this.name = name;
-	this.len = strlen(name);
-	this.hash = 0;
-	dentry = d_alloc(anon_inode_mnt->mnt_sb->s_root, &this);
+	dentry = d_alloc_unhashed(name, anon_inode_inode);
 	if (!dentry)
 		goto err_put_unused_fd;
 
@@ -104,9 +100,6 @@ int anon_inode_getfd(const char *name, const struct file_operations *fops,
 	atomic_inc(&anon_inode_inode->i_count);
 
 	dentry->d_op = &anon_inodefs_dentry_operations;
-	/* Do not publish this dentry inside the global dentry hash table */
-	dentry->d_flags &= ~DCACHE_UNHASHED;
-	d_instantiate(dentry, anon_inode_inode);
 
 	error = -ENFILE;
 	file = alloc_file(anon_inode_mnt, dentry,
diff --git a/fs/dcache.c b/fs/dcache.c
index a1d86c7..a5477fd 100644
--- a/fs/dcache.c
+++ b/fs/dcache.c
@@ -1111,6 +1111,37 @@ struct dentry * d_alloc_root(struct inode * root_inode)
 	return res;
 }
 
+/**
+ * d_alloc_unhashed - allocate unhashed dentry
+ * @inode: inode to allocate the dentry for
+ * @name: dentry name
+ *
+ * Allocate an unhashed dentry for the inode given. The inode is
+ * instantiated and returned. %NULL is returned if there is insufficient
+ * memory. Unhashed dentries have themselves as a parent.
+ */
+ 
+struct dentry * d_alloc_unhashed(const char *name, struct inode *inode)
+{
+	struct qstr q = { .name = name, .len = strlen(name) };
+	struct dentry *res;
+
+	res = d_alloc(NULL, &q);
+	if (res) {
+		res->d_sb = inode->i_sb;
+		res->d_parent = res;
+		/*
+		 * We dont want to push this dentry into global dentry hash table.
+		 * We pretend dentry is already hashed, by unsetting DCACHE_UNHASHED
+		 * This permits a working /proc/$pid/fd/XXX on sockets,pipes,anon
+		 */
+		res->d_flags &= ~DCACHE_UNHASHED;
+		res->d_flags |= DCACHE_DISCONNECTED;
+		d_instantiate(res, inode);
+	}
+	return res;
+}
+
 static inline struct hlist_head *d_hash(struct dentry *parent,
 					unsigned long hash)
 {
diff --git a/fs/pipe.c b/fs/pipe.c
index 7aea8b8..29fcac2 100644
--- a/fs/pipe.c
+++ b/fs/pipe.c
@@ -918,7 +918,6 @@ struct file *create_write_pipe(int flags)
 	struct inode *inode;
 	struct file *f;
 	struct dentry *dentry;
-	struct qstr name = { .name = "" };
 
 	err = -ENFILE;
 	inode = get_pipe_inode();
@@ -926,18 +925,11 @@ struct file *create_write_pipe(int flags)
 		goto err;
 
 	err = -ENOMEM;
-	dentry = d_alloc(pipe_mnt->mnt_sb->s_root, &name);
+	dentry = d_alloc_unhashed("", inode);
 	if (!dentry)
 		goto err_inode;
 
 	dentry->d_op = &pipefs_dentry_operations;
-	/*
-	 * We dont want to publish this dentry into global dentry hash table.
-	 * We pretend dentry is already hashed, by unsetting DCACHE_UNHASHED
-	 * This permits a working /proc/$pid/fd/XXX on pipes
-	 */
-	dentry->d_flags &= ~DCACHE_UNHASHED;
-	d_instantiate(dentry, inode);
 
 	err = -ENFILE;
 	f = alloc_file(pipe_mnt, dentry, FMODE_WRITE, &write_pipefifo_fops);
diff --git a/include/linux/dcache.h b/include/linux/dcache.h
index a37359d..12438d6 100644
--- a/include/linux/dcache.h
+++ b/include/linux/dcache.h
@@ -238,6 +238,7 @@ extern int d_invalidate(struct dentry *);
 
 /* only used at mount-time */
 extern struct dentry * d_alloc_root(struct inode *);
+extern struct dentry * d_alloc_unhashed(const char *, struct inode *);
 
 /* <clickety>-<click> the ramfs-type tree */
 extern void d_genocide(struct dentry *);
diff --git a/net/socket.c b/net/socket.c
index e9d65ea..b659b5d 100644
--- a/net/socket.c
+++ b/net/socket.c
@@ -371,20 +371,12 @@ static int sock_alloc_fd(struct file **filep, int flags)
 static int sock_attach_fd(struct socket *sock, struct file *file, int flags)
 {
 	struct dentry *dentry;
-	struct qstr name = { .name = "" };
 
-	dentry = d_alloc(sock_mnt->mnt_sb->s_root, &name);
+	dentry = d_alloc_unhashed("", SOCK_INODE(sock));
 	if (unlikely(!dentry))
 		return -ENOMEM;
 
 	dentry->d_op = &sockfs_dentry_operations;
-	/*
-	 * We dont want to push this dentry into global dentry hash table.
-	 * We pretend dentry is already hashed, by unsetting DCACHE_UNHASHED
-	 * This permits a working /proc/$pid/fd/XXX on sockets
-	 */
-	dentry->d_flags &= ~DCACHE_UNHASHED;
-	d_instantiate(dentry, SOCK_INODE(sock));
 
 	sock->file = file;
 	init_file(file, sock_mnt, dentry, FMODE_READ | FMODE_WRITE,

--------------080507060605070601070305--
