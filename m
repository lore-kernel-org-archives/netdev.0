From: "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>
Subject: Re: [PATCH] 9p: Don't use ATTR_* values from fs.h in userspace facing structs
Date: Sun, 18 Dec 2011 14:13:02 +0530
Message-ID: <87mxaqgtih.fsf@linux.vnet.ibm.com>
References: <1324134422-16642-1-git-send-email-levinsasha928@gmail.com> <20111217174725.GW2203@ZenIV.linux.org.uk> <87pqfmgtph.fsf@linux.vnet.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: ericvh@gmail.com, rminnich@sandia.gov, lucho@ionkov.net,
	davem@davemloft.net, jvrao@linux.vnet.ibm.com,
	v9fs-developer@lists.sourceforge.net, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: Al Viro <viro@ZenIV.linux.org.uk>,
	Sasha Levin <levinsasha928@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <87pqfmgtph.fsf@linux.vnet.ibm.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Sun, 18 Dec 2011 14:08:50 +0530, "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com> wrote:
> On Sat, 17 Dec 2011 17:47:25 +0000, Al Viro <viro@ZenIV.linux.org.uk> wrote:
> > On Sat, Dec 17, 2011 at 05:07:02PM +0200, Sasha Levin wrote:
> > > struct p9_iattr_dotl is userspace facing, but the 'valid' field is documented
> > > as follows:
> > > 
> > > 	 * @valid: bitfield specifying which fields are valid
> > > 	 *         same as in struct iattr
> > > 
> > > Which means that the user has to know about kernel internal ATTR_* values.
> > > 
> > > On Fri, 2011-12-16 at 23:30 +0000, Al Viro wrote:
> > > > They *are* kernel internal values and 9P is asking for trouble exposing
> > > > them.  Translation: tomorrow we might reassign those as we bloody wish
> > > > and any userland code that happens to rely on their values will break.
> > > > At which point we'll handle complaints by pointing and laughing.
> > > >
> > > > It's a 9P bug; fix it there.  Turning random internal constants into a part
> > > > of ABI is not going to work.
> > > 
> > > Signed-off-by: Sasha Levin <levinsasha928@gmail.com>
> > > ---
> > >  fs/9p/vfs_inode_dotl.c |   31 ++++++++++++++++++++++++++++++-
> > >  include/net/9p/9p.h    |   18 ++++++++++++++++++
> > >  2 files changed, 48 insertions(+), 1 deletions(-)
> > > 
> > > diff --git a/fs/9p/vfs_inode_dotl.c b/fs/9p/vfs_inode_dotl.c
> > > index 0b5745e..a948214 100644
> > > --- a/fs/9p/vfs_inode_dotl.c
> > > +++ b/fs/9p/vfs_inode_dotl.c
> > > @@ -523,6 +523,35 @@ v9fs_vfs_getattr_dotl(struct vfsmount *mnt, struct dentry *dentry,
> > >  	return 0;
> > >  }
> > >  
> > > +int v9fs_vfs_iattr_to_9p_valid(u32 ia_valid)
> > > +{
> > > +	u32 valid = 0, i;
> > > +	static u32 attr_map[][2] = {
> > > +		{ATTR_MODE,		P9_ATTR_MODE},
> > > +		{ATTR_UID,		P9_ATTR_UID},
> > > +		{ATTR_SIZE,		P9_ATTR_SIZE},
> > > +		{ATTR_ATIME,		P9_ATTR_ATIME},
> > > +		{ATTR_MTIME,		P9_ATTR_MTIME},
> > > +		{ATTR_CTIME,		P9_ATTR_CTIME},
> > > +		{ATTR_ATIME_SET,	P9_ATTR_ATIME_SET},
> > > +		{ATTR_MTIME_SET,	P9_ATTR_MTIME_SET},
> > > +		{ATTR_FORCE,		P9_ATTR_FORCE},
> > > +		{ATTR_ATTR_FLAG,	P9_ATTR_ATTR_FLAG},
> > > +		{ATTR_KILL_SUID,	P9_ATTR_KILL_SUID},
> > > +		{ATTR_KILL_SGID,	P9_ATTR_KILL_SGID},
> > > +		{ATTR_FILE,		P9_ATTR_FILE},
> > > +		{ATTR_KILL_PRIV,	P9_ATTR_KILL_PRIV},
> > > +		{ATTR_OPEN,		P9_ATTR_OPEN},
> > > +		{ATTR_TIMES_SET,	P9_ATTR_TIMES_SET},
> > > +	};
> > 
> > a) ATTR_GID is lost
> > b) passing ATTR_FILE is bloody pointless; look at what it does and
> > realize that 9p doesn't as much as look at ia_file.
> > c) ATTR_KILL_PRIV is very dubious; what's the legitimate use of that
> > puppy in fs code?
> > 
> > Look, that's the problem with exposing this stuff to protocol; you don't
> > get clear semantics and are you seriously asking for trouble on kernel
> > changes.  Suppose tomorrow we get rid of e.g. ATTR_KILL_PRIV; what are you
> > guys going to do?  Hope that no 9p server has behaviour dependent on that
> > flag being set or cleared?
> > 
> > Don't turn the kernel internals into a part of ABI.  And blind bulk remapping
> > of constants is exactly that...
> > 
> 

qemu part if you are interested.

commit 9a45b894ab6d5e4480e721a40e8e8c160344c9fe
Author: Aneesh Kumar K.V <aneesh.kumar@linux.vnet.ibm.com>
Date:   Sat Dec 17 21:02:57 2011 +0530

    hw/9pfs: iattr_valid flags are kernel internal flags map them to 9p values.
    
    Kernel internal values can change, add protocol values for these constant and
    use them.
    
    Signed-off-by: Aneesh Kumar K.V <aneesh.kumar@linux.vnet.ibm.com>

diff --git a/hw/9pfs/virtio-9p.c b/hw/9pfs/virtio-9p.c
index b3fc3d0..567f6cb 100644
--- a/hw/9pfs/virtio-9p.c
+++ b/hw/9pfs/virtio-9p.c
@@ -1293,17 +1293,18 @@ out_nofid:
     complete_pdu(s, pdu, retval);
 }
 
-/* From Linux kernel code */
-#define ATTR_MODE    (1 << 0)
-#define ATTR_UID     (1 << 1)
-#define ATTR_GID     (1 << 2)
-#define ATTR_SIZE    (1 << 3)
-#define ATTR_ATIME   (1 << 4)
-#define ATTR_MTIME   (1 << 5)
-#define ATTR_CTIME   (1 << 6)
-#define ATTR_MASK    127
-#define ATTR_ATIME_SET  (1 << 7)
-#define ATTR_MTIME_SET  (1 << 8)
+/* Attribute flags */
+#define P9_ATTR_MODE       (1 << 0)
+#define P9_ATTR_UID        (1 << 1)
+#define P9_ATTR_GID        (1 << 2)
+#define P9_ATTR_SIZE       (1 << 3)
+#define P9_ATTR_ATIME      (1 << 4)
+#define P9_ATTR_MTIME      (1 << 5)
+#define P9_ATTR_CTIME      (1 << 6)
+#define P9_ATTR_ATIME_SET  (1 << 7)
+#define P9_ATTR_MTIME_SET  (1 << 8)
+
+#define P9_ATTR_MASK    127
 
 static void v9fs_setattr(void *opaque)
 {
@@ -1322,16 +1323,16 @@ static void v9fs_setattr(void *opaque)
         err = -EINVAL;
         goto out_nofid;
     }
-    if (v9iattr.valid & ATTR_MODE) {
+    if (v9iattr.valid & P9_ATTR_MODE) {
         err = v9fs_co_chmod(pdu, &fidp->path, v9iattr.mode);
         if (err < 0) {
             goto out;
         }
     }
-    if (v9iattr.valid & (ATTR_ATIME | ATTR_MTIME)) {
+    if (v9iattr.valid & (P9_ATTR_ATIME | P9_ATTR_MTIME)) {
         struct timespec times[2];
-        if (v9iattr.valid & ATTR_ATIME) {
-            if (v9iattr.valid & ATTR_ATIME_SET) {
+        if (v9iattr.valid & P9_ATTR_ATIME) {
+            if (v9iattr.valid & P9_ATTR_ATIME_SET) {
                 times[0].tv_sec = v9iattr.atime_sec;
                 times[0].tv_nsec = v9iattr.atime_nsec;
             } else {
@@ -1340,8 +1341,8 @@ static void v9fs_setattr(void *opaque)
         } else {
             times[0].tv_nsec = UTIME_OMIT;
         }
-        if (v9iattr.valid & ATTR_MTIME) {
-            if (v9iattr.valid & ATTR_MTIME_SET) {
+        if (v9iattr.valid & P9_ATTR_MTIME) {
+            if (v9iattr.valid & P9_ATTR_MTIME_SET) {
                 times[1].tv_sec = v9iattr.mtime_sec;
                 times[1].tv_nsec = v9iattr.mtime_nsec;
             } else {
@@ -1359,13 +1360,13 @@ static void v9fs_setattr(void *opaque)
      * If the only valid entry in iattr is ctime we can call
      * chown(-1,-1) to update the ctime of the file
      */
-    if ((v9iattr.valid & (ATTR_UID | ATTR_GID)) ||
-        ((v9iattr.valid & ATTR_CTIME)
-         && !((v9iattr.valid & ATTR_MASK) & ~ATTR_CTIME))) {
-        if (!(v9iattr.valid & ATTR_UID)) {
+    if ((v9iattr.valid & (P9_ATTR_UID | P9_ATTR_GID)) ||
+        ((v9iattr.valid & P9_ATTR_CTIME)
+         && !((v9iattr.valid & P9_ATTR_MASK) & ~P9_ATTR_CTIME))) {
+        if (!(v9iattr.valid & P9_ATTR_UID)) {
             v9iattr.uid = -1;
         }
-        if (!(v9iattr.valid & ATTR_GID)) {
+        if (!(v9iattr.valid & P9_ATTR_GID)) {
             v9iattr.gid = -1;
         }
         err = v9fs_co_chown(pdu, &fidp->path, v9iattr.uid,
@@ -1374,7 +1375,7 @@ static void v9fs_setattr(void *opaque)
             goto out;
         }
     }
-    if (v9iattr.valid & (ATTR_SIZE)) {
+    if (v9iattr.valid & (P9_ATTR_SIZE)) {
         err = v9fs_co_truncate(pdu, &fidp->path, v9iattr.size);
         if (err < 0) {
             goto out;
