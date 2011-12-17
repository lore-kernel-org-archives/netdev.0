From: Al Viro <viro@ZenIV.linux.org.uk>
Subject: Re: [PATCH] 9p: Don't use ATTR_* values from fs.h in userspace
 facing  structs
Date: Sat, 17 Dec 2011 17:47:25 +0000
Message-ID: <20111217174725.GW2203@ZenIV.linux.org.uk>
References: <1324134422-16642-1-git-send-email-levinsasha928@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: ericvh@gmail.com, rminnich@sandia.gov, lucho@ionkov.net,
	davem@davemloft.net, aneesh.kumar@linux.vnet.ibm.com,
	jvrao@linux.vnet.ibm.com, v9fs-developer@lists.sourceforge.net,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: Sasha Levin <levinsasha928@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <1324134422-16642-1-git-send-email-levinsasha928@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Sat, Dec 17, 2011 at 05:07:02PM +0200, Sasha Levin wrote:
> struct p9_iattr_dotl is userspace facing, but the 'valid' field is documented
> as follows:
> 
> 	 * @valid: bitfield specifying which fields are valid
> 	 *         same as in struct iattr
> 
> Which means that the user has to know about kernel internal ATTR_* values.
> 
> On Fri, 2011-12-16 at 23:30 +0000, Al Viro wrote:
> > They *are* kernel internal values and 9P is asking for trouble exposing
> > them.  Translation: tomorrow we might reassign those as we bloody wish
> > and any userland code that happens to rely on their values will break.
> > At which point we'll handle complaints by pointing and laughing.
> >
> > It's a 9P bug; fix it there.  Turning random internal constants into a part
> > of ABI is not going to work.
> 
> Signed-off-by: Sasha Levin <levinsasha928@gmail.com>
> ---
>  fs/9p/vfs_inode_dotl.c |   31 ++++++++++++++++++++++++++++++-
>  include/net/9p/9p.h    |   18 ++++++++++++++++++
>  2 files changed, 48 insertions(+), 1 deletions(-)
> 
> diff --git a/fs/9p/vfs_inode_dotl.c b/fs/9p/vfs_inode_dotl.c
> index 0b5745e..a948214 100644
> --- a/fs/9p/vfs_inode_dotl.c
> +++ b/fs/9p/vfs_inode_dotl.c
> @@ -523,6 +523,35 @@ v9fs_vfs_getattr_dotl(struct vfsmount *mnt, struct dentry *dentry,
>  	return 0;
>  }
>  
> +int v9fs_vfs_iattr_to_9p_valid(u32 ia_valid)
> +{
> +	u32 valid = 0, i;
> +	static u32 attr_map[][2] = {
> +		{ATTR_MODE,		P9_ATTR_MODE},
> +		{ATTR_UID,		P9_ATTR_UID},
> +		{ATTR_SIZE,		P9_ATTR_SIZE},
> +		{ATTR_ATIME,		P9_ATTR_ATIME},
> +		{ATTR_MTIME,		P9_ATTR_MTIME},
> +		{ATTR_CTIME,		P9_ATTR_CTIME},
> +		{ATTR_ATIME_SET,	P9_ATTR_ATIME_SET},
> +		{ATTR_MTIME_SET,	P9_ATTR_MTIME_SET},
> +		{ATTR_FORCE,		P9_ATTR_FORCE},
> +		{ATTR_ATTR_FLAG,	P9_ATTR_ATTR_FLAG},
> +		{ATTR_KILL_SUID,	P9_ATTR_KILL_SUID},
> +		{ATTR_KILL_SGID,	P9_ATTR_KILL_SGID},
> +		{ATTR_FILE,		P9_ATTR_FILE},
> +		{ATTR_KILL_PRIV,	P9_ATTR_KILL_PRIV},
> +		{ATTR_OPEN,		P9_ATTR_OPEN},
> +		{ATTR_TIMES_SET,	P9_ATTR_TIMES_SET},
> +	};

a) ATTR_GID is lost
b) passing ATTR_FILE is bloody pointless; look at what it does and
realize that 9p doesn't as much as look at ia_file.
c) ATTR_KILL_PRIV is very dubious; what's the legitimate use of that
puppy in fs code?

Look, that's the problem with exposing this stuff to protocol; you don't
get clear semantics and are you seriously asking for trouble on kernel
changes.  Suppose tomorrow we get rid of e.g. ATTR_KILL_PRIV; what are you
guys going to do?  Hope that no 9p server has behaviour dependent on that
flag being set or cleared?

Don't turn the kernel internals into a part of ABI.  And blind bulk remapping
of constants is exactly that...
