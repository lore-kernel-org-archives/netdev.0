From: Eric Van Hensbergen <ericvh@gmail.com>
Subject: Re: [PATCH] 9p: Reduce object size with CONFIG_NET_9P_DEBUG
Date: Mon, 28 Nov 2011 09:10:05 -0600
Message-ID: <CAFkjPTmyn9POfTjYYjjYEaPt6M6Wdu-P=SEc=ZeTsbA+1=VraA@mail.gmail.com>
References: <1321661394.5917.7.camel@Joe-Laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Ron Minnich <rminnich@sandia.gov>,
	Latchesar Ionkov <lucho@ionkov.net>,
	"David S. Miller" <davem@davemloft.net>,
	v9fs-developer@lists.sourceforge.net, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org
To: Joe Perches <joe@perches.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1321661394.5917.7.camel@Joe-Laptop>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

sorry, just got to reviewing this because of holidays.

On Fri, Nov 18, 2011 at 6:09 PM, Joe Perches <joe@perches.com> wrote:
> Reduce object size by deduplicating formats.
>
> Use vsprintf extension %pV.
> Rename P9_DPRINTK uses to p9_debug, align arguments.
> Add function for _p9_debug and macro to add __func__.
> Add missing "\n"s to p9_debug uses.
> Remove embedded function names as p9_debug adds it.
> Remove P9_EPRINTK macro and convert use to pr_<level>.
> Add and use pr_fmt and pr_<level>.
>
> $ size fs/9p/built-in.o*
> =A0 text =A0 =A0data =A0 =A0 bss =A0 =A0 dec =A0 =A0 hex filename
> =A062133 =A0 =A0 984 =A0 16000 =A0 79117 =A0 1350d fs/9p/built-in.o.n=
ew
> =A067342 =A0 =A0 984 =A0 16928 =A0 85254 =A0 14d06 fs/9p/built-in.o.o=
ld
>
> Signed-off-by: Joe Perches <joe@perches.com>

These changes seem reasonable enough, but since you only made changes
in the fs/9p directory and not the net/9p directory which causes
net/9p build to break with this patch.

CC      net/9p/client.o
/home/ericvh/src/linux/v9fs-devel/net/9p/client.c: In function
=91get_protocol_version=92:
/home/ericvh/src/linux/v9fs-devel/net/9p/client.c:84:3: error:
implicit declaration of function =91P9_DPRINTK=92
[-Werror=3Dimplicit-function-declaration]
/home/ericvh/src/linux/v9fs-devel/net/9p/client.c: In function
=91p9_client_clunk=92:
/home/ericvh/src/linux/v9fs-devel/net/9p/client.c:1426:3: error:
implicit declaration of function =91P9_EPRINTK=92
[-Werror=3Dimplicit-function-declaration]
cc1: some warnings being treated as errors

make[3]: *** [net/9p/client.o] Error 1
make[2]: *** [net/9p] Error 2
make[1]: *** [net] Error 2
make: *** [sub-make] Error 2

           -eric


> ---
> =A0fs/9p/cache.c =A0 =A0 =A0 =A0 =A0| =A0 64 ++++++++++++++++++------=
------------
> =A0fs/9p/fid.c =A0 =A0 =A0 =A0 =A0 =A0| =A0 =A08 ++--
> =A0fs/9p/v9fs.c =A0 =A0 =A0 =A0 =A0 | =A0 83 ++++++++++++++++++++++++=
++++++----------------
> =A0fs/9p/vfs_addr.c =A0 =A0 =A0 | =A0 13 +++----
> =A0fs/9p/vfs_dentry.c =A0 =A0 | =A0 12 +++---
> =A0fs/9p/vfs_dir.c =A0 =A0 =A0 =A0| =A0 13 +++----
> =A0fs/9p/vfs_file.c =A0 =A0 =A0 | =A0 31 ++++++++---------
> =A0fs/9p/vfs_inode.c =A0 =A0 =A0| =A0 86 ++++++++++++++++++++++++----=
--------------------
> =A0fs/9p/vfs_inode_dotl.c | =A0 85 +++++++++++++++++++++++-----------=
-------------
> =A0fs/9p/vfs_super.c =A0 =A0 =A0| =A0 12 +++---
> =A0fs/9p/xattr.c =A0 =A0 =A0 =A0 =A0| =A0 16 ++++----
> =A0include/net/9p/9p.h =A0 =A0| =A0 28 ++++------------
> =A012 files changed, 228 insertions(+), 223 deletions(-)
>
> diff --git a/fs/9p/cache.c b/fs/9p/cache.c
> index 945aa5f..a9ea73d 100644
> --- a/fs/9p/cache.c
> +++ b/fs/9p/cache.c
> @@ -62,8 +62,8 @@ static uint16_t v9fs_cache_session_get_key(const vo=
id *cookie_netfs_data,
> =A0 =A0 =A0 =A0uint16_t klen =3D 0;
>
> =A0 =A0 =A0 =A0v9ses =3D (struct v9fs_session_info *)cookie_netfs_dat=
a;
> - =A0 =A0 =A0 P9_DPRINTK(P9_DEBUG_FSC, "session %p buf %p size %u", v=
9ses,
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0buffer, bufmax);
> + =A0 =A0 =A0 p9_debug(P9_DEBUG_FSC, "session %p buf %p size %u\n",
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0v9ses, buffer, bufmax);
>
> =A0 =A0 =A0 =A0if (v9ses->cachetag)
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0klen =3D strlen(v9ses->cachetag);
> @@ -72,7 +72,7 @@ static uint16_t v9fs_cache_session_get_key(const vo=
id *cookie_netfs_data,
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0return 0;
>
> =A0 =A0 =A0 =A0memcpy(buffer, v9ses->cachetag, klen);
> - =A0 =A0 =A0 P9_DPRINTK(P9_DEBUG_FSC, "cache session tag %s", v9ses-=
>cachetag);
> + =A0 =A0 =A0 p9_debug(P9_DEBUG_FSC, "cache session tag %s\n", v9ses-=
>cachetag);
> =A0 =A0 =A0 =A0return klen;
> =A0}
>
> @@ -91,14 +91,14 @@ void v9fs_cache_session_get_cookie(struct v9fs_se=
ssion_info *v9ses)
> =A0 =A0 =A0 =A0v9ses->fscache =3D fscache_acquire_cookie(v9fs_cache_n=
etfs.primary_index,
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0=
 =A0 =A0 =A0 =A0 =A0 =A0&v9fs_cache_session_index_def,
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0=
 =A0 =A0 =A0 =A0 =A0 =A0v9ses);
> - =A0 =A0 =A0 P9_DPRINTK(P9_DEBUG_FSC, "session %p get cookie %p", v9=
ses,
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0v9ses->fscache);
> + =A0 =A0 =A0 p9_debug(P9_DEBUG_FSC, "session %p get cookie %p\n",
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0v9ses, v9ses->fscache);
> =A0}
>
> =A0void v9fs_cache_session_put_cookie(struct v9fs_session_info *v9ses=
)
> =A0{
> - =A0 =A0 =A0 P9_DPRINTK(P9_DEBUG_FSC, "session %p put cookie %p", v9=
ses,
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0v9ses->fscache);
> + =A0 =A0 =A0 p9_debug(P9_DEBUG_FSC, "session %p put cookie %p\n",
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0v9ses, v9ses->fscache);
> =A0 =A0 =A0 =A0fscache_relinquish_cookie(v9ses->fscache, 0);
> =A0 =A0 =A0 =A0v9ses->fscache =3D NULL;
> =A0}
> @@ -109,8 +109,8 @@ static uint16_t v9fs_cache_inode_get_key(const vo=
id *cookie_netfs_data,
> =A0{
> =A0 =A0 =A0 =A0const struct v9fs_inode *v9inode =3D cookie_netfs_data=
;
> =A0 =A0 =A0 =A0memcpy(buffer, &v9inode->qid.path, sizeof(v9inode->qid=
=2Epath));
> - =A0 =A0 =A0 P9_DPRINTK(P9_DEBUG_FSC, "inode %p get key %llu", &v9in=
ode->vfs_inode,
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0v9inode->qid.path);
> + =A0 =A0 =A0 p9_debug(P9_DEBUG_FSC, "inode %p get key %llu\n",
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0&v9inode->vfs_inode, v9inode->qid.pa=
th);
> =A0 =A0 =A0 =A0return sizeof(v9inode->qid.path);
> =A0}
>
> @@ -120,8 +120,8 @@ static void v9fs_cache_inode_get_attr(const void =
*cookie_netfs_data,
> =A0 =A0 =A0 =A0const struct v9fs_inode *v9inode =3D cookie_netfs_data=
;
> =A0 =A0 =A0 =A0*size =3D i_size_read(&v9inode->vfs_inode);
>
> - =A0 =A0 =A0 P9_DPRINTK(P9_DEBUG_FSC, "inode %p get attr %llu", &v9i=
node->vfs_inode,
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0*size);
> + =A0 =A0 =A0 p9_debug(P9_DEBUG_FSC, "inode %p get attr %llu\n",
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0&v9inode->vfs_inode, *size);
> =A0}
>
> =A0static uint16_t v9fs_cache_inode_get_aux(const void *cookie_netfs_=
data,
> @@ -129,8 +129,8 @@ static uint16_t v9fs_cache_inode_get_aux(const vo=
id *cookie_netfs_data,
> =A0{
> =A0 =A0 =A0 =A0const struct v9fs_inode *v9inode =3D cookie_netfs_data=
;
> =A0 =A0 =A0 =A0memcpy(buffer, &v9inode->qid.version, sizeof(v9inode->=
qid.version));
> - =A0 =A0 =A0 P9_DPRINTK(P9_DEBUG_FSC, "inode %p get aux %u", &v9inod=
e->vfs_inode,
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0v9inode->qid.version);
> + =A0 =A0 =A0 p9_debug(P9_DEBUG_FSC, "inode %p get aux %u\n",
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0&v9inode->vfs_inode, v9inode->qid.ve=
rsion);
> =A0 =A0 =A0 =A0return sizeof(v9inode->qid.version);
> =A0}
>
> @@ -206,8 +206,8 @@ void v9fs_cache_inode_get_cookie(struct inode *in=
ode)
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0=
 =A0 =A0 =A0 =A0 =A0 =A0 =A0&v9fs_cache_inode_index_def,
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0=
 =A0 =A0 =A0 =A0 =A0 =A0 =A0v9inode);
>
> - =A0 =A0 =A0 P9_DPRINTK(P9_DEBUG_FSC, "inode %p get cookie %p", inod=
e,
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0v9inode->fscache);
> + =A0 =A0 =A0 p9_debug(P9_DEBUG_FSC, "inode %p get cookie %p\n",
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0inode, v9inode->fscache);
> =A0}
>
> =A0void v9fs_cache_inode_put_cookie(struct inode *inode)
> @@ -216,8 +216,8 @@ void v9fs_cache_inode_put_cookie(struct inode *in=
ode)
>
> =A0 =A0 =A0 =A0if (!v9inode->fscache)
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0return;
> - =A0 =A0 =A0 P9_DPRINTK(P9_DEBUG_FSC, "inode %p put cookie %p", inod=
e,
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0v9inode->fscache);
> + =A0 =A0 =A0 p9_debug(P9_DEBUG_FSC, "inode %p put cookie %p\n",
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0inode, v9inode->fscache);
>
> =A0 =A0 =A0 =A0fscache_relinquish_cookie(v9inode->fscache, 0);
> =A0 =A0 =A0 =A0v9inode->fscache =3D NULL;
> @@ -229,8 +229,8 @@ void v9fs_cache_inode_flush_cookie(struct inode *=
inode)
>
> =A0 =A0 =A0 =A0if (!v9inode->fscache)
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0return;
> - =A0 =A0 =A0 P9_DPRINTK(P9_DEBUG_FSC, "inode %p flush cookie %p", in=
ode,
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0v9inode->fscache);
> + =A0 =A0 =A0 p9_debug(P9_DEBUG_FSC, "inode %p flush cookie %p\n",
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0inode, v9inode->fscache);
>
> =A0 =A0 =A0 =A0fscache_relinquish_cookie(v9inode->fscache, 1);
> =A0 =A0 =A0 =A0v9inode->fscache =3D NULL;
> @@ -272,8 +272,8 @@ void v9fs_cache_inode_reset_cookie(struct inode *=
inode)
> =A0 =A0 =A0 =A0v9inode->fscache =3D fscache_acquire_cookie(v9ses->fsc=
ache,
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0=
 =A0 =A0 =A0 =A0 =A0 =A0 =A0&v9fs_cache_inode_index_def,
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0=
 =A0 =A0 =A0 =A0 =A0 =A0 =A0v9inode);
> - =A0 =A0 =A0 P9_DPRINTK(P9_DEBUG_FSC, "inode %p revalidating cookie =
old %p new %p",
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0inode, old, v9inode->fscache);
> + =A0 =A0 =A0 p9_debug(P9_DEBUG_FSC, "inode %p revalidating cookie ol=
d %p new %p\n",
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0inode, old, v9inode->fscache);
>
> =A0 =A0 =A0 =A0spin_unlock(&v9inode->fscache_lock);
> =A0}
> @@ -323,7 +323,7 @@ int __v9fs_readpage_from_fscache(struct inode *in=
ode, struct page *page)
> =A0 =A0 =A0 =A0int ret;
> =A0 =A0 =A0 =A0const struct v9fs_inode *v9inode =3D V9FS_I(inode);
>
> - =A0 =A0 =A0 P9_DPRINTK(P9_DEBUG_FSC, "inode %p page %p", inode, pag=
e);
> + =A0 =A0 =A0 p9_debug(P9_DEBUG_FSC, "inode %p page %p\n", inode, pag=
e);
> =A0 =A0 =A0 =A0if (!v9inode->fscache)
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0return -ENOBUFS;
>
> @@ -335,13 +335,13 @@ int __v9fs_readpage_from_fscache(struct inode *=
inode, struct page *page)
> =A0 =A0 =A0 =A0switch (ret) {
> =A0 =A0 =A0 =A0case -ENOBUFS:
> =A0 =A0 =A0 =A0case -ENODATA:
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 P9_DPRINTK(P9_DEBUG_FSC, "page/inode no=
t in cache %d", ret);
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 p9_debug(P9_DEBUG_FSC, "page/inode not =
in cache %d\n", ret);
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0return 1;
> =A0 =A0 =A0 =A0case 0:
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 P9_DPRINTK(P9_DEBUG_FSC, "BIO submitted=
");
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 p9_debug(P9_DEBUG_FSC, "BIO submitted\n=
");
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0return ret;
> =A0 =A0 =A0 =A0default:
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 P9_DPRINTK(P9_DEBUG_FSC, "ret %d", ret)=
;
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 p9_debug(P9_DEBUG_FSC, "ret %d\n", ret)=
;
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0return ret;
> =A0 =A0 =A0 =A0}
> =A0}
> @@ -361,7 +361,7 @@ int __v9fs_readpages_from_fscache(struct inode *i=
node,
> =A0 =A0 =A0 =A0int ret;
> =A0 =A0 =A0 =A0const struct v9fs_inode *v9inode =3D V9FS_I(inode);
>
> - =A0 =A0 =A0 P9_DPRINTK(P9_DEBUG_FSC, "inode %p pages %u", inode, *n=
r_pages);
> + =A0 =A0 =A0 p9_debug(P9_DEBUG_FSC, "inode %p pages %u\n", inode, *n=
r_pages);
> =A0 =A0 =A0 =A0if (!v9inode->fscache)
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0return -ENOBUFS;
>
> @@ -373,15 +373,15 @@ int __v9fs_readpages_from_fscache(struct inode =
*inode,
> =A0 =A0 =A0 =A0switch (ret) {
> =A0 =A0 =A0 =A0case -ENOBUFS:
> =A0 =A0 =A0 =A0case -ENODATA:
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 P9_DPRINTK(P9_DEBUG_FSC, "pages/inodes =
not in cache %d", ret);
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 p9_debug(P9_DEBUG_FSC, "pages/inodes no=
t in cache %d\n", ret);
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0return 1;
> =A0 =A0 =A0 =A0case 0:
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0BUG_ON(!list_empty(pages));
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0BUG_ON(*nr_pages !=3D 0);
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 P9_DPRINTK(P9_DEBUG_FSC, "BIO submitted=
");
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 p9_debug(P9_DEBUG_FSC, "BIO submitted\n=
");
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0return ret;
> =A0 =A0 =A0 =A0default:
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 P9_DPRINTK(P9_DEBUG_FSC, "ret %d", ret)=
;
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 p9_debug(P9_DEBUG_FSC, "ret %d\n", ret)=
;
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0return ret;
> =A0 =A0 =A0 =A0}
> =A0}
> @@ -396,9 +396,9 @@ void __v9fs_readpage_to_fscache(struct inode *ino=
de, struct page *page)
> =A0 =A0 =A0 =A0int ret;
> =A0 =A0 =A0 =A0const struct v9fs_inode *v9inode =3D V9FS_I(inode);
>
> - =A0 =A0 =A0 P9_DPRINTK(P9_DEBUG_FSC, "inode %p page %p", inode, pag=
e);
> + =A0 =A0 =A0 p9_debug(P9_DEBUG_FSC, "inode %p page %p\n", inode, pag=
e);
> =A0 =A0 =A0 =A0ret =3D fscache_write_page(v9inode->fscache, page, GFP=
_KERNEL);
> - =A0 =A0 =A0 P9_DPRINTK(P9_DEBUG_FSC, "ret =3D =A0%d", ret);
> + =A0 =A0 =A0 p9_debug(P9_DEBUG_FSC, "ret =3D =A0%d\n", ret);
> =A0 =A0 =A0 =A0if (ret !=3D 0)
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0v9fs_uncache_page(inode, page);
> =A0}
> @@ -409,7 +409,7 @@ void __v9fs_readpage_to_fscache(struct inode *ino=
de, struct page *page)
> =A0void __v9fs_fscache_wait_on_page_write(struct inode *inode, struct=
 page *page)
> =A0{
> =A0 =A0 =A0 =A0const struct v9fs_inode *v9inode =3D V9FS_I(inode);
> - =A0 =A0 =A0 P9_DPRINTK(P9_DEBUG_FSC, "inode %p page %p", inode, pag=
e);
> + =A0 =A0 =A0 p9_debug(P9_DEBUG_FSC, "inode %p page %p\n", inode, pag=
e);
> =A0 =A0 =A0 =A0if (PageFsCache(page))
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0fscache_wait_on_page_write(v9inode->fs=
cache, page);
> =A0}
> diff --git a/fs/9p/fid.c b/fs/9p/fid.c
> index 85b67ff..da8eefb 100644
> --- a/fs/9p/fid.c
> +++ b/fs/9p/fid.c
> @@ -45,8 +45,8 @@ int v9fs_fid_add(struct dentry *dentry, struct p9_f=
id *fid)
> =A0{
> =A0 =A0 =A0 =A0struct v9fs_dentry *dent;
>
> - =A0 =A0 =A0 P9_DPRINTK(P9_DEBUG_VFS, "fid %d dentry %s\n",
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0=
 =A0 =A0 fid->fid, dentry->d_name.name);
> + =A0 =A0 =A0 p9_debug(P9_DEBUG_VFS, "fid %d dentry %s\n",
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0fid->fid, dentry->d_name.name);
>
> =A0 =A0 =A0 =A0dent =3D dentry->d_fsdata;
> =A0 =A0 =A0 =A0if (!dent) {
> @@ -79,8 +79,8 @@ static struct p9_fid *v9fs_fid_find(struct dentry *=
dentry, u32 uid, int any)
> =A0 =A0 =A0 =A0struct v9fs_dentry *dent;
> =A0 =A0 =A0 =A0struct p9_fid *fid, *ret;
>
> - =A0 =A0 =A0 P9_DPRINTK(P9_DEBUG_VFS, " dentry: %s (%p) uid %d any %=
d\n",
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 dentry->d_name.name, dentry, uid, any);
> + =A0 =A0 =A0 p9_debug(P9_DEBUG_VFS, " dentry: %s (%p) uid %d any %d\=
n",
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0dentry->d_name.name, dentry, uid, an=
y);
> =A0 =A0 =A0 =A0dent =3D (struct v9fs_dentry *) dentry->d_fsdata;
> =A0 =A0 =A0 =A0ret =3D NULL;
> =A0 =A0 =A0 =A0if (dent) {
> diff --git a/fs/9p/v9fs.c b/fs/9p/v9fs.c
> index 2b78014..4afc182 100644
> --- a/fs/9p/v9fs.c
> +++ b/fs/9p/v9fs.c
> @@ -23,6 +23,8 @@
> =A0*
> =A0*/
>
> +#define pr_fmt(fmt) KBUILD_MODNAME ": " fmt
> +
> =A0#include <linux/module.h>
> =A0#include <linux/errno.h>
> =A0#include <linux/fs.h>
> @@ -85,15 +87,15 @@ static int get_cache_mode(char *s)
>
> =A0 =A0 =A0 =A0if (!strcmp(s, "loose")) {
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0version =3D CACHE_LOOSE;
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 P9_DPRINTK(P9_DEBUG_9P, "Cache mode: lo=
ose\n");
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 p9_debug(P9_DEBUG_9P, "Cache mode: loos=
e\n");
> =A0 =A0 =A0 =A0} else if (!strcmp(s, "fscache")) {
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0version =3D CACHE_FSCACHE;
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 P9_DPRINTK(P9_DEBUG_9P, "Cache mode: fs=
cache\n");
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 p9_debug(P9_DEBUG_9P, "Cache mode: fsca=
che\n");
> =A0 =A0 =A0 =A0} else if (!strcmp(s, "none")) {
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0version =3D CACHE_NONE;
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 P9_DPRINTK(P9_DEBUG_9P, "Cache mode: no=
ne\n");
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 p9_debug(P9_DEBUG_9P, "Cache mode: none=
\n");
> =A0 =A0 =A0 =A0} else
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 printk(KERN_INFO "9p: Unknown Cache mod=
e %s.\n", s);
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 pr_info("Unknown Cache mode %s\n", s);
> =A0 =A0 =A0 =A0return version;
> =A0}
>
> @@ -140,8 +142,8 @@ static int v9fs_parse_options(struct v9fs_session=
_info *v9ses, char *opts)
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0case Opt_debug:
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0r =3D match_int(&args[=
0], &option);
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0if (r < 0) {
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 P9_DPRI=
NTK(P9_DEBUG_ERROR,
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0=
 =A0 =A0 =A0 =A0"integer field, but no integer?\n");
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 p9_debu=
g(P9_DEBUG_ERROR,
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0=
 =A0 =A0 =A0"integer field, but no integer?\n");
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0ret =3D=
 r;
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0contin=
ue;
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0}
> @@ -154,8 +156,8 @@ static int v9fs_parse_options(struct v9fs_session=
_info *v9ses, char *opts)
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0case Opt_dfltuid:
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0r =3D match_int(&args[=
0], &option);
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0if (r < 0) {
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 P9_DPRI=
NTK(P9_DEBUG_ERROR,
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0=
 =A0 =A0 =A0 =A0"integer field, but no integer?\n");
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 p9_debu=
g(P9_DEBUG_ERROR,
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0=
 =A0 =A0 =A0"integer field, but no integer?\n");
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0ret =3D=
 r;
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0contin=
ue;
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0}
> @@ -164,8 +166,8 @@ static int v9fs_parse_options(struct v9fs_session=
_info *v9ses, char *opts)
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0case Opt_dfltgid:
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0r =3D match_int(&args[=
0], &option);
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0if (r < 0) {
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 P9_DPRI=
NTK(P9_DEBUG_ERROR,
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0=
 =A0 =A0 =A0 =A0"integer field, but no integer?\n");
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 p9_debu=
g(P9_DEBUG_ERROR,
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0=
 =A0 =A0 =A0"integer field, but no integer?\n");
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0ret =3D=
 r;
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0contin=
ue;
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0}
> @@ -174,8 +176,8 @@ static int v9fs_parse_options(struct v9fs_session=
_info *v9ses, char *opts)
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0case Opt_afid:
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0r =3D match_int(&args[=
0], &option);
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0if (r < 0) {
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 P9_DPRI=
NTK(P9_DEBUG_ERROR,
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0=
 =A0 =A0 =A0 =A0"integer field, but no integer?\n");
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 p9_debu=
g(P9_DEBUG_ERROR,
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0=
 =A0 =A0 =A0"integer field, but no integer?\n");
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0ret =3D=
 r;
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0contin=
ue;
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0}
> @@ -205,8 +207,8 @@ static int v9fs_parse_options(struct v9fs_session=
_info *v9ses, char *opts)
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0s =3D match_strdup(&ar=
gs[0]);
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0if (!s) {
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0ret =3D=
 -ENOMEM;
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 P9_DPRI=
NTK(P9_DEBUG_ERROR,
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 "pr=
oblem allocating copy of cache arg\n");
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 p9_debu=
g(P9_DEBUG_ERROR,
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0=
 =A0 =A0 =A0"problem allocating copy of cache arg\n");
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0goto f=
ree_and_return;
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0}
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0ret =3D get_cache_mode=
(s);
> @@ -223,8 +225,8 @@ static int v9fs_parse_options(struct v9fs_session=
_info *v9ses, char *opts)
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0s =3D match_strdup(&ar=
gs[0]);
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0if (!s) {
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0ret =3D=
 -ENOMEM;
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 P9_DPRI=
NTK(P9_DEBUG_ERROR,
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 "pr=
oblem allocating copy of access arg\n");
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 p9_debu=
g(P9_DEBUG_ERROR,
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0=
 =A0 =A0 =A0"problem allocating copy of access arg\n");
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0goto f=
ree_and_return;
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0}
>
> @@ -240,8 +242,8 @@ static int v9fs_parse_options(struct v9fs_session=
_info *v9ses, char *opts)
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0v9ses-=
>uid =3D simple_strtoul(s, &e, 10);
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0if (*e=
 !=3D '\0') {
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0=
 =A0 =A0ret =3D -EINVAL;
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0=
 =A0 =A0 printk(KERN_INFO "9p: Unknown access "
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0=
 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 "argument %s.\n", s);
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0=
 =A0 =A0 pr_info("Unknown access argument %s\n",
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0=
 =A0 =A0 =A0 =A0 =A0 =A0 s);
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0=
 =A0 =A0kfree(s);
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0=
 =A0 =A0goto free_and_return;
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0}
> @@ -254,9 +256,8 @@ static int v9fs_parse_options(struct v9fs_session=
_info *v9ses, char *opts)
> =A0#ifdef CONFIG_9P_FS_POSIX_ACL
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0v9ses->flags |=3D V9FS=
_POSIX_ACL;
> =A0#else
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 P9_DPRINTK(P9_DEBUG_ERR=
OR,
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0=
 =A0 =A0 "Not defined CONFIG_9P_FS_POSIX_ACL. "
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0=
 =A0 =A0 "Ignoring posixacl option\n");
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 p9_debug(P9_DEBUG_ERROR=
,
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0"Not=
 defined CONFIG_9P_FS_POSIX_ACL. Ignoring posixacl option\n");
> =A0#endif
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0break;
>
> @@ -318,7 +319,7 @@ struct p9_fid *v9fs_session_init(struct v9fs_sess=
ion_info *v9ses,
> =A0 =A0 =A0 =A0if (IS_ERR(v9ses->clnt)) {
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0retval =3D PTR_ERR(v9ses->clnt);
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0v9ses->clnt =3D NULL;
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 P9_DPRINTK(P9_DEBUG_ERROR, "problem ini=
tializing 9p client\n");
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 p9_debug(P9_DEBUG_ERROR, "problem initi=
alizing 9p client\n");
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0goto error;
> =A0 =A0 =A0 =A0}
>
> @@ -371,7 +372,7 @@ struct p9_fid *v9fs_session_init(struct v9fs_sess=
ion_info *v9ses,
> =A0 =A0 =A0 =A0if (IS_ERR(fid)) {
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0retval =3D PTR_ERR(fid);
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0fid =3D NULL;
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 P9_DPRINTK(P9_DEBUG_ERROR, "cannot atta=
ch\n");
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 p9_debug(P9_DEBUG_ERROR, "cannot attach=
\n");
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0goto error;
> =A0 =A0 =A0 =A0}
>
> @@ -429,7 +430,7 @@ void v9fs_session_close(struct v9fs_session_info =
*v9ses)
> =A0*/
>
> =A0void v9fs_session_cancel(struct v9fs_session_info *v9ses) {
> - =A0 =A0 =A0 P9_DPRINTK(P9_DEBUG_ERROR, "cancel session %p\n", v9ses=
);
> + =A0 =A0 =A0 p9_debug(P9_DEBUG_ERROR, "cancel session %p\n", v9ses);
> =A0 =A0 =A0 =A0p9_client_disconnect(v9ses->clnt);
> =A0}
>
> @@ -442,7 +443,7 @@ void v9fs_session_cancel(struct v9fs_session_info=
 *v9ses) {
>
> =A0void v9fs_session_begin_cancel(struct v9fs_session_info *v9ses)
> =A0{
> - =A0 =A0 =A0 P9_DPRINTK(P9_DEBUG_ERROR, "begin cancel session %p\n",=
 v9ses);
> + =A0 =A0 =A0 p9_debug(P9_DEBUG_ERROR, "begin cancel session %p\n", v=
9ses);
> =A0 =A0 =A0 =A0p9_client_begin_disconnect(v9ses->clnt);
> =A0}
>
> @@ -591,23 +592,23 @@ static void v9fs_cache_unregister(void)
> =A0static int __init init_v9fs(void)
> =A0{
> =A0 =A0 =A0 =A0int err;
> - =A0 =A0 =A0 printk(KERN_INFO "Installing v9fs 9p2000 file system su=
pport\n");
> + =A0 =A0 =A0 pr_info("Installing v9fs 9p2000 file system support\n")=
;
> =A0 =A0 =A0 =A0/* TODO: Setup list of registered trasnport modules */
> =A0 =A0 =A0 =A0err =3D register_filesystem(&v9fs_fs_type);
> =A0 =A0 =A0 =A0if (err < 0) {
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 printk(KERN_ERR "Failed to register fil=
esystem\n");
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 pr_err("Failed to register filesystem\n=
");
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0return err;
> =A0 =A0 =A0 =A0}
>
> =A0 =A0 =A0 =A0err =3D v9fs_cache_register();
> =A0 =A0 =A0 =A0if (err < 0) {
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 printk(KERN_ERR "Failed to register v9f=
s for caching\n");
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 pr_err("Failed to register v9fs for cac=
hing\n");
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0goto out_fs_unreg;
> =A0 =A0 =A0 =A0}
>
> =A0 =A0 =A0 =A0err =3D v9fs_sysfs_init();
> =A0 =A0 =A0 =A0if (err < 0) {
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 printk(KERN_ERR "Failed to register wit=
h sysfs\n");
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 pr_err("Failed to register with sysfs\n=
");
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0goto out_sysfs_cleanup;
> =A0 =A0 =A0 =A0}
>
> @@ -637,6 +638,30 @@ static void __exit exit_v9fs(void)
> =A0module_init(init_v9fs)
> =A0module_exit(exit_v9fs)
>
> +#ifdef CONFIG_NET_9P_DEBUG
> +void _p9_debug(enum p9_debug_flags level, const char *func,
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0const char *fmt, ...)
> +{
> + =A0 =A0 =A0 struct va_format vaf;
> + =A0 =A0 =A0 va_list args;
> +
> + =A0 =A0 =A0 if ((p9_debug_level & level) !=3D level)
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 return;
> +
> + =A0 =A0 =A0 va_start(args, fmt);
> +
> + =A0 =A0 =A0 vaf.fmt =3D fmt;
> + =A0 =A0 =A0 vaf.va =3D &args;
> +
> + =A0 =A0 =A0 if (level =3D=3D P9_DEBUG_9P)
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 pr_notice("(%8.8d) %pV", task_pid_nr(cu=
rrent), &vaf);
> + =A0 =A0 =A0 else
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 pr_notice("-- %s (%d): %pV", func, task=
_pid_nr(current), &vaf);
> +
> + =A0 =A0 =A0 va_end(args);
> +}
> +#endif
> +
> =A0MODULE_AUTHOR("Latchesar Ionkov <lucho@ionkov.net>");
> =A0MODULE_AUTHOR("Eric Van Hensbergen <ericvh@gmail.com>");
> =A0MODULE_AUTHOR("Ron Minnich <rminnich@lanl.gov>");
> diff --git a/fs/9p/vfs_addr.c b/fs/9p/vfs_addr.c
> index 2524e4c..0ad61c6 100644
> --- a/fs/9p/vfs_addr.c
> +++ b/fs/9p/vfs_addr.c
> @@ -56,7 +56,7 @@ static int v9fs_fid_readpage(struct p9_fid *fid, st=
ruct page *page)
> =A0 =A0 =A0 =A0struct inode *inode;
>
> =A0 =A0 =A0 =A0inode =3D page->mapping->host;
> - =A0 =A0 =A0 P9_DPRINTK(P9_DEBUG_VFS, "\n");
> + =A0 =A0 =A0 p9_debug(P9_DEBUG_VFS, "\n");
>
> =A0 =A0 =A0 =A0BUG_ON(!PageLocked(page));
>
> @@ -116,14 +116,14 @@ static int v9fs_vfs_readpages(struct file *filp=
, struct address_space *mapping,
> =A0 =A0 =A0 =A0struct inode *inode;
>
> =A0 =A0 =A0 =A0inode =3D mapping->host;
> - =A0 =A0 =A0 P9_DPRINTK(P9_DEBUG_VFS, "inode: %p file: %p\n", inode,=
 filp);
> + =A0 =A0 =A0 p9_debug(P9_DEBUG_VFS, "inode: %p file: %p\n", inode, f=
ilp);
>
> =A0 =A0 =A0 =A0ret =3D v9fs_readpages_from_fscache(inode, mapping, pa=
ges, &nr_pages);
> =A0 =A0 =A0 =A0if (ret =3D=3D 0)
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0return ret;
>
> =A0 =A0 =A0 =A0ret =3D read_cache_pages(mapping, pages, (void *)v9fs_=
vfs_readpage, filp);
> - =A0 =A0 =A0 P9_DPRINTK(P9_DEBUG_VFS, " =A0=3D %d\n", ret);
> + =A0 =A0 =A0 p9_debug(P9_DEBUG_VFS, " =A0=3D %d\n", ret);
> =A0 =A0 =A0 =A0return ret;
> =A0}
>
> @@ -263,10 +263,9 @@ v9fs_direct_IO(int rw, struct kiocb *iocb, const=
 struct iovec *iov,
> =A0 =A0 =A0 =A0 * Now that we do caching with cache mode enabled, We =
need
> =A0 =A0 =A0 =A0 * to support direct IO
> =A0 =A0 =A0 =A0 */
> - =A0 =A0 =A0 P9_DPRINTK(P9_DEBUG_VFS, "v9fs_direct_IO: v9fs_direct_I=
O (%s) "
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 "off/no(%lld/%lu) EINVA=
L\n",
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 iocb->ki_filp->f_path.d=
entry->d_name.name,
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 (long long) pos, nr_seg=
s);
> + =A0 =A0 =A0 p9_debug(P9_DEBUG_VFS, "v9fs_direct_IO: v9fs_direct_IO =
(%s) off/no(%lld/%lu) EINVAL\n",
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0iocb->ki_filp->f_path.dentry->d_name=
=2Ename,
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0(long long)pos, nr_segs);
>
> =A0 =A0 =A0 =A0return -EINVAL;
> =A0}
> diff --git a/fs/9p/vfs_dentry.c b/fs/9p/vfs_dentry.c
> index e022890..d529437 100644
> --- a/fs/9p/vfs_dentry.c
> +++ b/fs/9p/vfs_dentry.c
> @@ -53,8 +53,8 @@
>
> =A0static int v9fs_dentry_delete(const struct dentry *dentry)
> =A0{
> - =A0 =A0 =A0 P9_DPRINTK(P9_DEBUG_VFS, " dentry: %s (%p)\n", dentry->=
d_name.name,
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0=
 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0=
 dentry);
> + =A0 =A0 =A0 p9_debug(P9_DEBUG_VFS, " dentry: %s (%p)\n",
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0dentry->d_name.name, dentry);
>
> =A0 =A0 =A0 =A0return 1;
> =A0}
> @@ -66,8 +66,8 @@ static int v9fs_dentry_delete(const struct dentry *=
dentry)
> =A0*/
> =A0static int v9fs_cached_dentry_delete(const struct dentry *dentry)
> =A0{
> - =A0 =A0 =A0 P9_DPRINTK(P9_DEBUG_VFS, " dentry: %s (%p)\n",
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0dentry->d_name.name, dentry);
> + =A0 =A0 =A0 p9_debug(P9_DEBUG_VFS, " dentry: %s (%p)\n",
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0dentry->d_name.name, dentry);
>
> =A0 =A0 =A0 =A0/* Don't cache negative dentries */
> =A0 =A0 =A0 =A0if (!dentry->d_inode)
> @@ -86,8 +86,8 @@ static void v9fs_dentry_release(struct dentry *dent=
ry)
> =A0 =A0 =A0 =A0struct v9fs_dentry *dent;
> =A0 =A0 =A0 =A0struct p9_fid *temp, *current_fid;
>
> - =A0 =A0 =A0 P9_DPRINTK(P9_DEBUG_VFS, " dentry: %s (%p)\n", dentry->=
d_name.name,
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0=
 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0=
 dentry);
> + =A0 =A0 =A0 p9_debug(P9_DEBUG_VFS, " dentry: %s (%p)\n",
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0dentry->d_name.name, dentry);
> =A0 =A0 =A0 =A0dent =3D dentry->d_fsdata;
> =A0 =A0 =A0 =A0if (dent) {
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0list_for_each_entry_safe(current_fid, =
temp, &dent->fidlist,
> diff --git a/fs/9p/vfs_dir.c b/fs/9p/vfs_dir.c
> index 598fff1..ff911e7 100644
> --- a/fs/9p/vfs_dir.c
> +++ b/fs/9p/vfs_dir.c
> @@ -140,7 +140,7 @@ static int v9fs_dir_readdir(struct file *filp, vo=
id *dirent, filldir_t filldir)
> =A0 =A0 =A0 =A0int reclen =3D 0;
> =A0 =A0 =A0 =A0struct p9_rdir *rdir;
>
> - =A0 =A0 =A0 P9_DPRINTK(P9_DEBUG_VFS, "name %s\n", filp->f_path.dent=
ry->d_name.name);
> + =A0 =A0 =A0 p9_debug(P9_DEBUG_VFS, "name %s\n", filp->f_path.dentry=
->d_name.name);
> =A0 =A0 =A0 =A0fid =3D filp->private_data;
>
> =A0 =A0 =A0 =A0buflen =3D fid->clnt->msize - P9_IOHDRSZ;
> @@ -168,7 +168,7 @@ static int v9fs_dir_readdir(struct file *filp, vo=
id *dirent, filldir_t filldir)
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0err =3D p9stat_read(fi=
d->clnt, rdir->buf + rdir->head,
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0=
 =A0 =A0 =A0rdir->tail - rdir->head, &st);
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0if (err) {
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 P9_DPRI=
NTK(P9_DEBUG_VFS, "returned %d\n", err);
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 p9_debu=
g(P9_DEBUG_VFS, "returned %d\n", err);
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0err =3D=
 -EIO;
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0p9stat=
_free(&st);
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0goto u=
nlock_and_exit;
> @@ -213,7 +213,7 @@ static int v9fs_dir_readdir_dotl(struct file *fil=
p, void *dirent,
> =A0 =A0 =A0 =A0struct p9_dirent curdirent;
> =A0 =A0 =A0 =A0u64 oldoffset =3D 0;
>
> - =A0 =A0 =A0 P9_DPRINTK(P9_DEBUG_VFS, "name %s\n", filp->f_path.dent=
ry->d_name.name);
> + =A0 =A0 =A0 p9_debug(P9_DEBUG_VFS, "name %s\n", filp->f_path.dentry=
->d_name.name);
> =A0 =A0 =A0 =A0fid =3D filp->private_data;
>
> =A0 =A0 =A0 =A0buflen =3D fid->clnt->msize - P9_READDIRHDRSZ;
> @@ -244,7 +244,7 @@ static int v9fs_dir_readdir_dotl(struct file *fil=
p, void *dirent,
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0=
 =A0 =A0 =A0 =A0rdir->tail - rdir->head,
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0=
 =A0 =A0 =A0 =A0&curdirent);
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0if (err < 0) {
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 P9_DPRI=
NTK(P9_DEBUG_VFS, "returned %d\n", err);
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 p9_debu=
g(P9_DEBUG_VFS, "returned %d\n", err);
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0err =3D=
 -EIO;
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0goto u=
nlock_and_exit;
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0}
> @@ -290,9 +290,8 @@ int v9fs_dir_release(struct inode *inode, struct =
file *filp)
> =A0 =A0 =A0 =A0struct p9_fid *fid;
>
> =A0 =A0 =A0 =A0fid =3D filp->private_data;
> - =A0 =A0 =A0 P9_DPRINTK(P9_DEBUG_VFS,
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 "v9fs_dir_release: inod=
e: %p filp: %p fid: %d\n",
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 inode, filp, fid ? fid-=
>fid : -1);
> + =A0 =A0 =A0 p9_debug(P9_DEBUG_VFS, "inode: %p filp: %p fid: %d\n",
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0inode, filp, fid ? fid->fid : -1);
> =A0 =A0 =A0 =A0if (fid)
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0p9_client_clunk(fid);
> =A0 =A0 =A0 =A0return 0;
> diff --git a/fs/9p/vfs_file.c b/fs/9p/vfs_file.c
> index 62857a8..8947f9f 100644
> --- a/fs/9p/vfs_file.c
> +++ b/fs/9p/vfs_file.c
> @@ -61,7 +61,7 @@ int v9fs_file_open(struct inode *inode, struct file=
 *file)
> =A0 =A0 =A0 =A0struct p9_fid *fid;
> =A0 =A0 =A0 =A0int omode;
>
> - =A0 =A0 =A0 P9_DPRINTK(P9_DEBUG_VFS, "inode: %p file: %p\n", inode,=
 file);
> + =A0 =A0 =A0 p9_debug(P9_DEBUG_VFS, "inode: %p file: %p\n", inode, f=
ile);
> =A0 =A0 =A0 =A0v9inode =3D V9FS_I(inode);
> =A0 =A0 =A0 =A0v9ses =3D v9fs_inode2v9ses(inode);
> =A0 =A0 =A0 =A0if (v9fs_proto_dotl(v9ses))
> @@ -135,7 +135,7 @@ static int v9fs_file_lock(struct file *filp, int =
cmd, struct file_lock *fl)
> =A0 =A0 =A0 =A0int res =3D 0;
> =A0 =A0 =A0 =A0struct inode *inode =3D filp->f_path.dentry->d_inode;
>
> - =A0 =A0 =A0 P9_DPRINTK(P9_DEBUG_VFS, "filp: %p lock: %p\n", filp, f=
l);
> + =A0 =A0 =A0 p9_debug(P9_DEBUG_VFS, "filp: %p lock: %p\n", filp, fl)=
;
>
> =A0 =A0 =A0 =A0/* No mandatory locks */
> =A0 =A0 =A0 =A0if (__mandatory_lock(inode) && fl->fl_type !=3D F_UNLC=
K)
> @@ -304,8 +304,8 @@ static int v9fs_file_lock_dotl(struct file *filp,=
 int cmd, struct file_lock *fl)
> =A0 =A0 =A0 =A0struct inode *inode =3D filp->f_path.dentry->d_inode;
> =A0 =A0 =A0 =A0int ret =3D -ENOLCK;
>
> - =A0 =A0 =A0 P9_DPRINTK(P9_DEBUG_VFS, "filp: %p cmd:%d lock: %p name=
: %s\n", filp,
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 cmd, fl=
, filp->f_path.dentry->d_name.name);
> + =A0 =A0 =A0 p9_debug(P9_DEBUG_VFS, "filp: %p cmd:%d lock: %p name: =
%s\n",
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0filp, cmd, fl, filp->f_path.dentry->=
d_name.name);
>
> =A0 =A0 =A0 =A0/* No mandatory locks */
> =A0 =A0 =A0 =A0if (__mandatory_lock(inode) && fl->fl_type !=3D F_UNLC=
K)
> @@ -340,8 +340,8 @@ static int v9fs_file_flock_dotl(struct file *filp=
, int cmd,
> =A0 =A0 =A0 =A0struct inode *inode =3D filp->f_path.dentry->d_inode;
> =A0 =A0 =A0 =A0int ret =3D -ENOLCK;
>
> - =A0 =A0 =A0 P9_DPRINTK(P9_DEBUG_VFS, "filp: %p cmd:%d lock: %p name=
: %s\n", filp,
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 cmd, fl=
, filp->f_path.dentry->d_name.name);
> + =A0 =A0 =A0 p9_debug(P9_DEBUG_VFS, "filp: %p cmd:%d lock: %p name: =
%s\n",
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0filp, cmd, fl, filp->f_path.dentry->=
d_name.name);
>
> =A0 =A0 =A0 =A0/* No mandatory locks */
> =A0 =A0 =A0 =A0if (__mandatory_lock(inode) && fl->fl_type !=3D F_UNLC=
K)
> @@ -384,8 +384,8 @@ v9fs_fid_readn(struct p9_fid *fid, char *data, ch=
ar __user *udata, u32 count,
> =A0{
> =A0 =A0 =A0 =A0int n, total, size;
>
> - =A0 =A0 =A0 P9_DPRINTK(P9_DEBUG_VFS, "fid %d offset %llu count %d\n=
", fid->fid,
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0(long long unsigned) offset, cou=
nt);
> + =A0 =A0 =A0 p9_debug(P9_DEBUG_VFS, "fid %d offset %llu count %d\n",
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0fid->fid, (long long unsigned)offset=
, count);
> =A0 =A0 =A0 =A0n =3D 0;
> =A0 =A0 =A0 =A0total =3D 0;
> =A0 =A0 =A0 =A0size =3D fid->iounit ? fid->iounit : fid->clnt->msize =
- P9_IOHDRSZ;
> @@ -443,7 +443,7 @@ v9fs_file_read(struct file *filp, char __user *ud=
ata, size_t count,
> =A0 =A0 =A0 =A0struct p9_fid *fid;
> =A0 =A0 =A0 =A0size_t size;
>
> - =A0 =A0 =A0 P9_DPRINTK(P9_DEBUG_VFS, "count %zu offset %lld\n", cou=
nt, *offset);
> + =A0 =A0 =A0 p9_debug(P9_DEBUG_VFS, "count %zu offset %lld\n", count=
, *offset);
> =A0 =A0 =A0 =A0fid =3D filp->private_data;
>
> =A0 =A0 =A0 =A0size =3D fid->iounit ? fid->iounit : fid->clnt->msize =
- P9_IOHDRSZ;
> @@ -470,8 +470,8 @@ v9fs_file_write_internal(struct inode *inode, str=
uct p9_fid *fid,
> =A0 =A0 =A0 =A0loff_t origin =3D *offset;
> =A0 =A0 =A0 =A0unsigned long pg_start, pg_end;
>
> - =A0 =A0 =A0 P9_DPRINTK(P9_DEBUG_VFS, "data %p count %d offset %x\n"=
, data,
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 (int)count, (int)*offset);
> + =A0 =A0 =A0 p9_debug(P9_DEBUG_VFS, "data %p count %d offset %x\n",
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0data, (int)count, (int)*offset);
>
> =A0 =A0 =A0 =A0clnt =3D fid->clnt;
> =A0 =A0 =A0 =A0do {
> @@ -552,7 +552,7 @@ static int v9fs_file_fsync(struct file *filp, lof=
f_t start, loff_t end,
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0return retval;
>
> =A0 =A0 =A0 =A0mutex_lock(&inode->i_mutex);
> - =A0 =A0 =A0 P9_DPRINTK(P9_DEBUG_VFS, "filp %p datasync %x\n", filp,=
 datasync);
> + =A0 =A0 =A0 p9_debug(P9_DEBUG_VFS, "filp %p datasync %x\n", filp, d=
atasync);
>
> =A0 =A0 =A0 =A0fid =3D filp->private_data;
> =A0 =A0 =A0 =A0v9fs_blank_wstat(&wstat);
> @@ -575,8 +575,7 @@ int v9fs_file_fsync_dotl(struct file *filp, loff_=
t start, loff_t end,
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0return retval;
>
> =A0 =A0 =A0 =A0mutex_lock(&inode->i_mutex);
> - =A0 =A0 =A0 P9_DPRINTK(P9_DEBUG_VFS, "v9fs_file_fsync_dotl: filp %p=
 datasync %x\n",
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 filp, datasync);
> + =A0 =A0 =A0 p9_debug(P9_DEBUG_VFS, "filp %p datasync %x\n", filp, d=
atasync);
>
> =A0 =A0 =A0 =A0fid =3D filp->private_data;
>
> @@ -607,8 +606,8 @@ v9fs_vm_page_mkwrite(struct vm_area_struct *vma, =
struct vm_fault *vmf)
> =A0 =A0 =A0 =A0struct inode *inode =3D filp->f_path.dentry->d_inode;
>
>
> - =A0 =A0 =A0 P9_DPRINTK(P9_DEBUG_VFS, "page %p fid %lx\n",
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0page, (unsigned long)filp->priva=
te_data);
> + =A0 =A0 =A0 p9_debug(P9_DEBUG_VFS, "page %p fid %lx\n",
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0page, (unsigned long)filp->private_d=
ata);
>
> =A0 =A0 =A0 =A0v9inode =3D V9FS_I(inode);
> =A0 =A0 =A0 =A0/* make sure the cache has finished storing the page *=
/
> diff --git a/fs/9p/vfs_inode.c b/fs/9p/vfs_inode.c
> index 879ed88..85c2973 100644
> --- a/fs/9p/vfs_inode.c
> +++ b/fs/9p/vfs_inode.c
> @@ -23,6 +23,8 @@
> =A0*
> =A0*/
>
> +#define pr_fmt(fmt) KBUILD_MODNAME ": " fmt
> +
> =A0#include <linux/module.h>
> =A0#include <linux/errno.h>
> =A0#include <linux/fs.h>
> @@ -133,9 +135,8 @@ static int p9mode2unixmode(struct v9fs_session_in=
fo *v9ses,
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0res |=3D S_IFBLK;
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0break;
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0default:
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 P9_DPRINTK(P9_DEBUG_ERR=
OR,
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 "Unknow=
n special type %c %s\n", type,
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 stat->e=
xtension);
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 p9_debug(P9_DEBUG_ERROR=
, "Unknown special type %c %s\n",
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0type=
, stat->extension);
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0};
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0*rdev =3D MKDEV(major, minor);
> =A0 =A0 =A0 =A0} else
> @@ -281,8 +282,8 @@ int v9fs_init_inode(struct v9fs_session_info *v9s=
es,
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0} else if (v9fs_proto_dotu(v9ses)) {
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0inode->i_op =3D &v9fs_=
file_inode_operations;
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0} else {
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 P9_DPRINTK(P9_DEBUG_ERR=
OR,
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0=
"special files without extended mode\n");
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 p9_debug(P9_DEBUG_ERROR=
,
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0"spe=
cial files without extended mode\n");
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0err =3D -EINVAL;
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0goto error;
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0}
> @@ -307,8 +308,8 @@ int v9fs_init_inode(struct v9fs_session_info *v9s=
es,
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0break;
> =A0 =A0 =A0 =A0case S_IFLNK:
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0if (!v9fs_proto_dotu(v9ses) && !v9fs_p=
roto_dotl(v9ses)) {
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 P9_DPRINTK(P9_DEBUG_ERR=
OR, "extended modes used with "
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0=
 =A0 =A0 =A0 =A0 =A0 =A0 "legacy protocol.\n");
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 p9_debug(P9_DEBUG_ERROR=
,
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0"ext=
ended modes used with legacy protocol\n");
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0err =3D -EINVAL;
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0goto error;
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0}
> @@ -335,8 +336,8 @@ int v9fs_init_inode(struct v9fs_session_info *v9s=
es,
>
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0break;
> =A0 =A0 =A0 =A0default:
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 P9_DPRINTK(P9_DEBUG_ERROR, "BAD mode 0x=
%x S_IFMT 0x%x\n",
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0mode, mode & S_I=
=46MT);
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 p9_debug(P9_DEBUG_ERROR, "BAD mode 0x%x=
 S_IFMT 0x%x\n",
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0mode, mode & S_IFMT)=
;
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0err =3D -EINVAL;
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0goto error;
> =A0 =A0 =A0 =A0}
> @@ -358,11 +359,12 @@ struct inode *v9fs_get_inode(struct super_block=
 *sb, int mode, dev_t rdev)
> =A0 =A0 =A0 =A0struct inode *inode;
> =A0 =A0 =A0 =A0struct v9fs_session_info *v9ses =3D sb->s_fs_info;
>
> - =A0 =A0 =A0 P9_DPRINTK(P9_DEBUG_VFS, "super block: %p mode: %o\n", =
sb, mode);
> + =A0 =A0 =A0 p9_debug(P9_DEBUG_VFS, "super block: %p mode: %o\n", sb=
, mode);
>
> =A0 =A0 =A0 =A0inode =3D new_inode(sb);
> =A0 =A0 =A0 =A0if (!inode) {
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 P9_EPRINTK(KERN_WARNING, "Problem alloc=
ating inode\n");
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 pr_warn("%s (%d): Problem allocating in=
ode\n",
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 __func__, task_pid_nr(c=
urrent));
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0return ERR_PTR(-ENOMEM);
> =A0 =A0 =A0 =A0}
> =A0 =A0 =A0 =A0err =3D v9fs_init_inode(v9ses, inode, mode, rdev);
> @@ -578,15 +580,15 @@ static int v9fs_remove(struct inode *dir, struc=
t dentry *dentry, int flags)
> =A0 =A0 =A0 =A0struct p9_fid *v9fid, *dfid;
> =A0 =A0 =A0 =A0struct v9fs_session_info *v9ses;
>
> - =A0 =A0 =A0 P9_DPRINTK(P9_DEBUG_VFS, "inode: %p dentry: %p rmdir: %=
x\n",
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0dir, dentry, flags);
> + =A0 =A0 =A0 p9_debug(P9_DEBUG_VFS, "inode: %p dentry: %p rmdir: %x\=
n",
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0dir, dentry, flags);
>
> =A0 =A0 =A0 =A0v9ses =3D v9fs_inode2v9ses(dir);
> =A0 =A0 =A0 =A0inode =3D dentry->d_inode;
> =A0 =A0 =A0 =A0dfid =3D v9fs_fid_lookup(dentry->d_parent);
> =A0 =A0 =A0 =A0if (IS_ERR(dfid)) {
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0retval =3D PTR_ERR(dfid);
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 P9_DPRINTK(P9_DEBUG_VFS, "fid lookup fa=
iled %d\n", retval);
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 p9_debug(P9_DEBUG_VFS, "fid lookup fail=
ed %d\n", retval);
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0return retval;
> =A0 =A0 =A0 =A0}
> =A0 =A0 =A0 =A0if (v9fs_proto_dotl(v9ses))
> @@ -635,7 +637,7 @@ v9fs_create(struct v9fs_session_info *v9ses, stru=
ct inode *dir,
> =A0 =A0 =A0 =A0struct p9_fid *dfid, *ofid, *fid;
> =A0 =A0 =A0 =A0struct inode *inode;
>
> - =A0 =A0 =A0 P9_DPRINTK(P9_DEBUG_VFS, "name %s\n", dentry->d_name.na=
me);
> + =A0 =A0 =A0 p9_debug(P9_DEBUG_VFS, "name %s\n", dentry->d_name.name=
);
>
> =A0 =A0 =A0 =A0err =3D 0;
> =A0 =A0 =A0 =A0ofid =3D NULL;
> @@ -644,7 +646,7 @@ v9fs_create(struct v9fs_session_info *v9ses, stru=
ct inode *dir,
> =A0 =A0 =A0 =A0dfid =3D v9fs_fid_lookup(dentry->d_parent);
> =A0 =A0 =A0 =A0if (IS_ERR(dfid)) {
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0err =3D PTR_ERR(dfid);
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 P9_DPRINTK(P9_DEBUG_VFS, "fid lookup fa=
iled %d\n", err);
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 p9_debug(P9_DEBUG_VFS, "fid lookup fail=
ed %d\n", err);
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0return ERR_PTR(err);
> =A0 =A0 =A0 =A0}
>
> @@ -652,13 +654,13 @@ v9fs_create(struct v9fs_session_info *v9ses, st=
ruct inode *dir,
> =A0 =A0 =A0 =A0ofid =3D p9_client_walk(dfid, 0, NULL, 1);
> =A0 =A0 =A0 =A0if (IS_ERR(ofid)) {
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0err =3D PTR_ERR(ofid);
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 P9_DPRINTK(P9_DEBUG_VFS, "p9_client_wal=
k failed %d\n", err);
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 p9_debug(P9_DEBUG_VFS, "p9_client_walk =
failed %d\n", err);
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0return ERR_PTR(err);
> =A0 =A0 =A0 =A0}
>
> =A0 =A0 =A0 =A0err =3D p9_client_fcreate(ofid, name, perm, mode, exte=
nsion);
> =A0 =A0 =A0 =A0if (err < 0) {
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 P9_DPRINTK(P9_DEBUG_VFS, "p9_client_fcr=
eate failed %d\n", err);
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 p9_debug(P9_DEBUG_VFS, "p9_client_fcrea=
te failed %d\n", err);
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0goto error;
> =A0 =A0 =A0 =A0}
>
> @@ -666,7 +668,7 @@ v9fs_create(struct v9fs_session_info *v9ses, stru=
ct inode *dir,
> =A0 =A0 =A0 =A0fid =3D p9_client_walk(dfid, 1, &name, 1);
> =A0 =A0 =A0 =A0if (IS_ERR(fid)) {
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0err =3D PTR_ERR(fid);
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 P9_DPRINTK(P9_DEBUG_VFS, "p9_client_wal=
k failed %d\n", err);
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 p9_debug(P9_DEBUG_VFS, "p9_client_walk =
failed %d\n", err);
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0fid =3D NULL;
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0goto error;
> =A0 =A0 =A0 =A0}
> @@ -675,7 +677,7 @@ v9fs_create(struct v9fs_session_info *v9ses, stru=
ct inode *dir,
> =A0 =A0 =A0 =A0inode =3D v9fs_get_new_inode_from_fid(v9ses, fid, dir-=
>i_sb);
> =A0 =A0 =A0 =A0if (IS_ERR(inode)) {
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0err =3D PTR_ERR(inode);
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 P9_DPRINTK(P9_DEBUG_VFS, "inode creatio=
n failed %d\n", err);
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 p9_debug(P9_DEBUG_VFS, "inode creation =
failed %d\n", err);
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0goto error;
> =A0 =A0 =A0 =A0}
> =A0 =A0 =A0 =A0err =3D v9fs_fid_add(dentry, fid);
> @@ -793,7 +795,7 @@ static int v9fs_vfs_mkdir(struct inode *dir, stru=
ct dentry *dentry, int mode)
> =A0 =A0 =A0 =A0struct p9_fid *fid;
> =A0 =A0 =A0 =A0struct v9fs_session_info *v9ses;
>
> - =A0 =A0 =A0 P9_DPRINTK(P9_DEBUG_VFS, "name %s\n", dentry->d_name.na=
me);
> + =A0 =A0 =A0 p9_debug(P9_DEBUG_VFS, "name %s\n", dentry->d_name.name=
);
> =A0 =A0 =A0 =A0err =3D 0;
> =A0 =A0 =A0 =A0v9ses =3D v9fs_inode2v9ses(dir);
> =A0 =A0 =A0 =A0perm =3D unixmode2p9mode(v9ses, mode | S_IFDIR);
> @@ -831,8 +833,8 @@ struct dentry *v9fs_vfs_lookup(struct inode *dir,=
 struct dentry *dentry,
> =A0 =A0 =A0 =A0char *name;
> =A0 =A0 =A0 =A0int result =3D 0;
>
> - =A0 =A0 =A0 P9_DPRINTK(P9_DEBUG_VFS, "dir: %p dentry: (%s) %p namei=
data: %p\n",
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 dir, dentry->d_name.name, dentry, namei=
data);
> + =A0 =A0 =A0 p9_debug(P9_DEBUG_VFS, "dir: %p dentry: (%s) %p nameida=
ta: %p\n",
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0dir, dentry->d_name.name, dentry, na=
meidata);
>
> =A0 =A0 =A0 =A0if (dentry->d_name.len > NAME_MAX)
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0return ERR_PTR(-ENAMETOOLONG);
> @@ -938,7 +940,7 @@ v9fs_vfs_rename(struct inode *old_dir, struct den=
try *old_dentry,
> =A0 =A0 =A0 =A0struct p9_fid *newdirfid;
> =A0 =A0 =A0 =A0struct p9_wstat wstat;
>
> - =A0 =A0 =A0 P9_DPRINTK(P9_DEBUG_VFS, "\n");
> + =A0 =A0 =A0 p9_debug(P9_DEBUG_VFS, "\n");
> =A0 =A0 =A0 =A0retval =3D 0;
> =A0 =A0 =A0 =A0old_inode =3D old_dentry->d_inode;
> =A0 =A0 =A0 =A0new_inode =3D new_dentry->d_inode;
> @@ -974,8 +976,7 @@ v9fs_vfs_rename(struct inode *old_dir, struct den=
try *old_dentry,
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 * 9P .u can only handle file rename i=
n the same directory
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 */
>
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 P9_DPRINTK(P9_DEBUG_ERROR,
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 "old di=
r and new dir are different\n");
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 p9_debug(P9_DEBUG_ERROR, "old dir and n=
ew dir are different\n");
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0retval =3D -EXDEV;
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0goto clunk_newdir;
> =A0 =A0 =A0 =A0}
> @@ -1031,7 +1032,7 @@ v9fs_vfs_getattr(struct vfsmount *mnt, struct d=
entry *dentry,
> =A0 =A0 =A0 =A0struct p9_fid *fid;
> =A0 =A0 =A0 =A0struct p9_wstat *st;
>
> - =A0 =A0 =A0 P9_DPRINTK(P9_DEBUG_VFS, "dentry: %p\n", dentry);
> + =A0 =A0 =A0 p9_debug(P9_DEBUG_VFS, "dentry: %p\n", dentry);
> =A0 =A0 =A0 =A0err =3D -EPERM;
> =A0 =A0 =A0 =A0v9ses =3D v9fs_dentry2v9ses(dentry);
> =A0 =A0 =A0 =A0if (v9ses->cache =3D=3D CACHE_LOOSE || v9ses->cache =3D=
=3D CACHE_FSCACHE) {
> @@ -1068,7 +1069,7 @@ static int v9fs_vfs_setattr(struct dentry *dent=
ry, struct iattr *iattr)
> =A0 =A0 =A0 =A0struct p9_fid *fid;
> =A0 =A0 =A0 =A0struct p9_wstat wstat;
>
> - =A0 =A0 =A0 P9_DPRINTK(P9_DEBUG_VFS, "\n");
> + =A0 =A0 =A0 p9_debug(P9_DEBUG_VFS, "\n");
> =A0 =A0 =A0 =A0retval =3D inode_change_ok(dentry->d_inode, iattr);
> =A0 =A0 =A0 =A0if (retval)
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0return retval;
> @@ -1213,7 +1214,7 @@ static int v9fs_readlink(struct dentry *dentry,=
 char *buffer, int buflen)
> =A0 =A0 =A0 =A0struct p9_fid *fid;
> =A0 =A0 =A0 =A0struct p9_wstat *st;
>
> - =A0 =A0 =A0 P9_DPRINTK(P9_DEBUG_VFS, " %s\n", dentry->d_name.name);
> + =A0 =A0 =A0 p9_debug(P9_DEBUG_VFS, " %s\n", dentry->d_name.name);
> =A0 =A0 =A0 =A0retval =3D -EPERM;
> =A0 =A0 =A0 =A0v9ses =3D v9fs_dentry2v9ses(dentry);
> =A0 =A0 =A0 =A0fid =3D v9fs_fid_lookup(dentry);
> @@ -1235,8 +1236,8 @@ static int v9fs_readlink(struct dentry *dentry,=
 char *buffer, int buflen)
> =A0 =A0 =A0 =A0/* copy extension buffer into buffer */
> =A0 =A0 =A0 =A0strncpy(buffer, st->extension, buflen);
>
> - =A0 =A0 =A0 P9_DPRINTK(P9_DEBUG_VFS,
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 "%s -> %s (%s)\n", dentry->d_name.name,=
 st->extension, buffer);
> + =A0 =A0 =A0 p9_debug(P9_DEBUG_VFS, "%s -> %s (%s)\n",
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0dentry->d_name.name, st->extension, =
buffer);
>
> =A0 =A0 =A0 =A0retval =3D strnlen(buffer, buflen);
> =A0done:
> @@ -1257,7 +1258,7 @@ static void *v9fs_vfs_follow_link(struct dentry=
 *dentry, struct nameidata *nd)
> =A0 =A0 =A0 =A0int len =3D 0;
> =A0 =A0 =A0 =A0char *link =3D __getname();
>
> - =A0 =A0 =A0 P9_DPRINTK(P9_DEBUG_VFS, "%s n", dentry->d_name.name);
> + =A0 =A0 =A0 p9_debug(P9_DEBUG_VFS, "%s\n", dentry->d_name.name);
>
> =A0 =A0 =A0 =A0if (!link)
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0link =3D ERR_PTR(-ENOMEM);
> @@ -1288,8 +1289,8 @@ v9fs_vfs_put_link(struct dentry *dentry, struct=
 nameidata *nd, void *p)
> =A0{
> =A0 =A0 =A0 =A0char *s =3D nd_get_link(nd);
>
> - =A0 =A0 =A0 P9_DPRINTK(P9_DEBUG_VFS, " %s %s\n", dentry->d_name.nam=
e,
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 IS_ERR(s) ? "<error>" : s);
> + =A0 =A0 =A0 p9_debug(P9_DEBUG_VFS, " %s %s\n",
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0dentry->d_name.name, IS_ERR(s) ? "<e=
rror>" : s);
> =A0 =A0 =A0 =A0if (!IS_ERR(s))
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0__putname(s);
> =A0}
> @@ -1312,7 +1313,7 @@ static int v9fs_vfs_mkspecial(struct inode *dir=
, struct dentry *dentry,
>
> =A0 =A0 =A0 =A0v9ses =3D v9fs_inode2v9ses(dir);
> =A0 =A0 =A0 =A0if (!v9fs_proto_dotu(v9ses)) {
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 P9_DPRINTK(P9_DEBUG_ERROR, "not extende=
d\n");
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 p9_debug(P9_DEBUG_ERROR, "not extended\=
n");
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0return -EPERM;
> =A0 =A0 =A0 =A0}
>
> @@ -1340,8 +1341,8 @@ static int v9fs_vfs_mkspecial(struct inode *dir=
, struct dentry *dentry,
> =A0static int
> =A0v9fs_vfs_symlink(struct inode *dir, struct dentry *dentry, const c=
har *symname)
> =A0{
> - =A0 =A0 =A0 P9_DPRINTK(P9_DEBUG_VFS, " %lu,%s,%s\n", dir->i_ino,
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0=
 =A0 =A0 dentry->d_name.name, symname);
> + =A0 =A0 =A0 p9_debug(P9_DEBUG_VFS, " %lu,%s,%s\n",
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0dir->i_ino, dentry->d_name.name, sym=
name);
>
> =A0 =A0 =A0 =A0return v9fs_vfs_mkspecial(dir, dentry, S_IFLNK, symnam=
e);
> =A0}
> @@ -1362,9 +1363,8 @@ v9fs_vfs_link(struct dentry *old_dentry, struct=
 inode *dir,
> =A0 =A0 =A0 =A0char *name;
> =A0 =A0 =A0 =A0struct p9_fid *oldfid;
>
> - =A0 =A0 =A0 P9_DPRINTK(P9_DEBUG_VFS,
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 " %lu,%s,%s\n", dir->i_ino, dentry->d_n=
ame.name,
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 old_dentry->d_name.name);
> + =A0 =A0 =A0 p9_debug(P9_DEBUG_VFS, " %lu,%s,%s\n",
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0dir->i_ino, dentry->d_name.name, old=
_dentry->d_name.name);
>
> =A0 =A0 =A0 =A0oldfid =3D v9fs_fid_clone(old_dentry);
> =A0 =A0 =A0 =A0if (IS_ERR(oldfid))
> @@ -1403,9 +1403,9 @@ v9fs_vfs_mknod(struct inode *dir, struct dentry=
 *dentry, int mode, dev_t rdev)
> =A0 =A0 =A0 =A0int retval;
> =A0 =A0 =A0 =A0char *name;
>
> - =A0 =A0 =A0 P9_DPRINTK(P9_DEBUG_VFS,
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 " %lu,%s mode: %x MAJOR: %u MINOR: %u\n=
", dir->i_ino,
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 dentry->d_name.name, mode, MAJOR(rdev),=
 MINOR(rdev));
> + =A0 =A0 =A0 p9_debug(P9_DEBUG_VFS, " %lu,%s mode: %x MAJOR: %u MINO=
R: %u\n",
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0dir->i_ino, dentry->d_name.name, mod=
e,
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0MAJOR(rdev), MINOR(rdev));
>
> =A0 =A0 =A0 =A0if (!new_valid_dev(rdev))
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0return -EINVAL;
> diff --git a/fs/9p/vfs_inode_dotl.c b/fs/9p/vfs_inode_dotl.c
> index 0b5745e..73488fb 100644
> --- a/fs/9p/vfs_inode_dotl.c
> +++ b/fs/9p/vfs_inode_dotl.c
> @@ -283,13 +283,13 @@ v9fs_vfs_create_dotl(struct inode *dir, struct =
dentry *dentry, int omode,
> =A0 =A0 =A0 =A0}
>
> =A0 =A0 =A0 =A0name =3D (char *) dentry->d_name.name;
> - =A0 =A0 =A0 P9_DPRINTK(P9_DEBUG_VFS, "v9fs_vfs_create_dotl: name:%s=
 flags:0x%x "
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 "mode:0x%x\n", name, fl=
ags, omode);
> + =A0 =A0 =A0 p9_debug(P9_DEBUG_VFS, "name:%s flags:0x%x mode:0x%x\n"=
,
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0name, flags, omode);
>
> =A0 =A0 =A0 =A0dfid =3D v9fs_fid_lookup(dentry->d_parent);
> =A0 =A0 =A0 =A0if (IS_ERR(dfid)) {
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0err =3D PTR_ERR(dfid);
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 P9_DPRINTK(P9_DEBUG_VFS, "fid lookup fa=
iled %d\n", err);
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 p9_debug(P9_DEBUG_VFS, "fid lookup fail=
ed %d\n", err);
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0return err;
> =A0 =A0 =A0 =A0}
>
> @@ -297,7 +297,7 @@ v9fs_vfs_create_dotl(struct inode *dir, struct de=
ntry *dentry, int omode,
> =A0 =A0 =A0 =A0ofid =3D p9_client_walk(dfid, 0, NULL, 1);
> =A0 =A0 =A0 =A0if (IS_ERR(ofid)) {
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0err =3D PTR_ERR(ofid);
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 P9_DPRINTK(P9_DEBUG_VFS, "p9_client_wal=
k failed %d\n", err);
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 p9_debug(P9_DEBUG_VFS, "p9_client_walk =
failed %d\n", err);
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0return err;
> =A0 =A0 =A0 =A0}
>
> @@ -307,16 +307,15 @@ v9fs_vfs_create_dotl(struct inode *dir, struct =
dentry *dentry, int omode,
> =A0 =A0 =A0 =A0/* Update mode based on ACL value */
> =A0 =A0 =A0 =A0err =3D v9fs_acl_mode(dir, &mode, &dacl, &pacl);
> =A0 =A0 =A0 =A0if (err) {
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 P9_DPRINTK(P9_DEBUG_VFS,
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0"Failed to get a=
cl values in creat %d\n", err);
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 p9_debug(P9_DEBUG_VFS, "Failed to get a=
cl values in creat %d\n",
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0err);
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0goto error;
> =A0 =A0 =A0 =A0}
> =A0 =A0 =A0 =A0err =3D p9_client_create_dotl(ofid, name, v9fs_open_to=
_dotl_flags(flags),
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0=
mode, gid, &qid);
> =A0 =A0 =A0 =A0if (err < 0) {
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 P9_DPRINTK(P9_DEBUG_VFS,
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 "p9_cli=
ent_open_dotl failed in creat %d\n",
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 err);
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 p9_debug(P9_DEBUG_VFS, "p9_client_open_=
dotl failed in creat %d\n",
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0err);
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0goto error;
> =A0 =A0 =A0 =A0}
> =A0 =A0 =A0 =A0v9fs_invalidate_inode_attr(dir);
> @@ -325,14 +324,14 @@ v9fs_vfs_create_dotl(struct inode *dir, struct =
dentry *dentry, int omode,
> =A0 =A0 =A0 =A0fid =3D p9_client_walk(dfid, 1, &name, 1);
> =A0 =A0 =A0 =A0if (IS_ERR(fid)) {
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0err =3D PTR_ERR(fid);
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 P9_DPRINTK(P9_DEBUG_VFS, "p9_client_wal=
k failed %d\n", err);
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 p9_debug(P9_DEBUG_VFS, "p9_client_walk =
failed %d\n", err);
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0fid =3D NULL;
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0goto error;
> =A0 =A0 =A0 =A0}
> =A0 =A0 =A0 =A0inode =3D v9fs_get_new_inode_from_fid(v9ses, fid, dir-=
>i_sb);
> =A0 =A0 =A0 =A0if (IS_ERR(inode)) {
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0err =3D PTR_ERR(inode);
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 P9_DPRINTK(P9_DEBUG_VFS, "inode creatio=
n failed %d\n", err);
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 p9_debug(P9_DEBUG_VFS, "inode creation =
failed %d\n", err);
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0goto error;
> =A0 =A0 =A0 =A0}
> =A0 =A0 =A0 =A0err =3D v9fs_fid_add(dentry, fid);
> @@ -408,7 +407,7 @@ static int v9fs_vfs_mkdir_dotl(struct inode *dir,
> =A0 =A0 =A0 =A0struct dentry *dir_dentry;
> =A0 =A0 =A0 =A0struct posix_acl *dacl =3D NULL, *pacl =3D NULL;
>
> - =A0 =A0 =A0 P9_DPRINTK(P9_DEBUG_VFS, "name %s\n", dentry->d_name.na=
me);
> + =A0 =A0 =A0 p9_debug(P9_DEBUG_VFS, "name %s\n", dentry->d_name.name=
);
> =A0 =A0 =A0 =A0err =3D 0;
> =A0 =A0 =A0 =A0v9ses =3D v9fs_inode2v9ses(dir);
>
> @@ -420,7 +419,7 @@ static int v9fs_vfs_mkdir_dotl(struct inode *dir,
> =A0 =A0 =A0 =A0dfid =3D v9fs_fid_lookup(dir_dentry);
> =A0 =A0 =A0 =A0if (IS_ERR(dfid)) {
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0err =3D PTR_ERR(dfid);
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 P9_DPRINTK(P9_DEBUG_VFS, "fid lookup fa=
iled %d\n", err);
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 p9_debug(P9_DEBUG_VFS, "fid lookup fail=
ed %d\n", err);
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0dfid =3D NULL;
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0goto error;
> =A0 =A0 =A0 =A0}
> @@ -430,8 +429,8 @@ static int v9fs_vfs_mkdir_dotl(struct inode *dir,
> =A0 =A0 =A0 =A0/* Update mode based on ACL value */
> =A0 =A0 =A0 =A0err =3D v9fs_acl_mode(dir, &mode, &dacl, &pacl);
> =A0 =A0 =A0 =A0if (err) {
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 P9_DPRINTK(P9_DEBUG_VFS,
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0"Failed to get a=
cl values in mkdir %d\n", err);
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 p9_debug(P9_DEBUG_VFS, "Failed to get a=
cl values in mkdir %d\n",
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0err);
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0goto error;
> =A0 =A0 =A0 =A0}
> =A0 =A0 =A0 =A0name =3D (char *) dentry->d_name.name;
> @@ -444,8 +443,8 @@ static int v9fs_vfs_mkdir_dotl(struct inode *dir,
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0fid =3D p9_client_walk(dfid, 1, &name,=
 1);
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0if (IS_ERR(fid)) {
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0err =3D PTR_ERR(fid);
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 P9_DPRINTK(P9_DEBUG_VFS=
, "p9_client_walk failed %d\n",
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 err);
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 p9_debug(P9_DEBUG_VFS, =
"p9_client_walk failed %d\n",
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0err)=
;
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0fid =3D NULL;
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0goto error;
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0}
> @@ -453,8 +452,8 @@ static int v9fs_vfs_mkdir_dotl(struct inode *dir,
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0inode =3D v9fs_get_new_inode_from_fid(=
v9ses, fid, dir->i_sb);
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0if (IS_ERR(inode)) {
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0err =3D PTR_ERR(inode)=
;
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 P9_DPRINTK(P9_DEBUG_VFS=
, "inode creation failed %d\n",
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 err);
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 p9_debug(P9_DEBUG_VFS, =
"inode creation failed %d\n",
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0err)=
;
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0goto error;
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0}
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0err =3D v9fs_fid_add(dentry, fid);
> @@ -495,7 +494,7 @@ v9fs_vfs_getattr_dotl(struct vfsmount *mnt, struc=
t dentry *dentry,
> =A0 =A0 =A0 =A0struct p9_fid *fid;
> =A0 =A0 =A0 =A0struct p9_stat_dotl *st;
>
> - =A0 =A0 =A0 P9_DPRINTK(P9_DEBUG_VFS, "dentry: %p\n", dentry);
> + =A0 =A0 =A0 p9_debug(P9_DEBUG_VFS, "dentry: %p\n", dentry);
> =A0 =A0 =A0 =A0err =3D -EPERM;
> =A0 =A0 =A0 =A0v9ses =3D v9fs_dentry2v9ses(dentry);
> =A0 =A0 =A0 =A0if (v9ses->cache =3D=3D CACHE_LOOSE || v9ses->cache =3D=
=3D CACHE_FSCACHE) {
> @@ -537,7 +536,7 @@ int v9fs_vfs_setattr_dotl(struct dentry *dentry, =
struct iattr *iattr)
> =A0 =A0 =A0 =A0struct p9_fid *fid;
> =A0 =A0 =A0 =A0struct p9_iattr_dotl p9attr;
>
> - =A0 =A0 =A0 P9_DPRINTK(P9_DEBUG_VFS, "\n");
> + =A0 =A0 =A0 p9_debug(P9_DEBUG_VFS, "\n");
>
> =A0 =A0 =A0 =A0retval =3D inode_change_ok(dentry->d_inode, iattr);
> =A0 =A0 =A0 =A0if (retval)
> @@ -670,14 +669,13 @@ v9fs_vfs_symlink_dotl(struct inode *dir, struct=
 dentry *dentry,
> =A0 =A0 =A0 =A0struct v9fs_session_info *v9ses;
>
> =A0 =A0 =A0 =A0name =3D (char *) dentry->d_name.name;
> - =A0 =A0 =A0 P9_DPRINTK(P9_DEBUG_VFS, "v9fs_vfs_symlink_dotl : %lu,%=
s,%s\n",
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 dir->i_ino, name, symna=
me);
> + =A0 =A0 =A0 p9_debug(P9_DEBUG_VFS, "%lu,%s,%s\n", dir->i_ino, name,=
 symname);
> =A0 =A0 =A0 =A0v9ses =3D v9fs_inode2v9ses(dir);
>
> =A0 =A0 =A0 =A0dfid =3D v9fs_fid_lookup(dentry->d_parent);
> =A0 =A0 =A0 =A0if (IS_ERR(dfid)) {
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0err =3D PTR_ERR(dfid);
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 P9_DPRINTK(P9_DEBUG_VFS, "fid lookup fa=
iled %d\n", err);
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 p9_debug(P9_DEBUG_VFS, "fid lookup fail=
ed %d\n", err);
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0return err;
> =A0 =A0 =A0 =A0}
>
> @@ -687,7 +685,7 @@ v9fs_vfs_symlink_dotl(struct inode *dir, struct d=
entry *dentry,
> =A0 =A0 =A0 =A0err =3D p9_client_symlink(dfid, name, (char *)symname,=
 gid, &qid);
>
> =A0 =A0 =A0 =A0if (err < 0) {
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 P9_DPRINTK(P9_DEBUG_VFS, "p9_client_sym=
link failed %d\n", err);
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 p9_debug(P9_DEBUG_VFS, "p9_client_symli=
nk failed %d\n", err);
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0goto error;
> =A0 =A0 =A0 =A0}
>
> @@ -697,8 +695,8 @@ v9fs_vfs_symlink_dotl(struct inode *dir, struct d=
entry *dentry,
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0fid =3D p9_client_walk(dfid, 1, &name,=
 1);
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0if (IS_ERR(fid)) {
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0err =3D PTR_ERR(fid);
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 P9_DPRINTK(P9_DEBUG_VFS=
, "p9_client_walk failed %d\n",
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0=
 =A0 =A0 err);
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 p9_debug(P9_DEBUG_VFS, =
"p9_client_walk failed %d\n",
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0err)=
;
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0fid =3D NULL;
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0goto error;
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0}
> @@ -707,8 +705,8 @@ v9fs_vfs_symlink_dotl(struct inode *dir, struct d=
entry *dentry,
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0inode =3D v9fs_get_new_inode_from_fid(=
v9ses, fid, dir->i_sb);
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0if (IS_ERR(inode)) {
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0err =3D PTR_ERR(inode)=
;
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 P9_DPRINTK(P9_DEBUG_VFS=
, "inode creation failed %d\n",
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0=
 =A0 =A0 err);
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 p9_debug(P9_DEBUG_VFS, =
"inode creation failed %d\n",
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0err)=
;
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0goto error;
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0}
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0err =3D v9fs_fid_add(dentry, fid);
> @@ -751,9 +749,8 @@ v9fs_vfs_link_dotl(struct dentry *old_dentry, str=
uct inode *dir,
> =A0 =A0 =A0 =A0struct p9_fid *dfid, *oldfid;
> =A0 =A0 =A0 =A0struct v9fs_session_info *v9ses;
>
> - =A0 =A0 =A0 P9_DPRINTK(P9_DEBUG_VFS, "dir ino: %lu, old_name: %s, n=
ew_name: %s\n",
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 dir->i_ino, old_dentry-=
>d_name.name,
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 dentry->d_name.name);
> + =A0 =A0 =A0 p9_debug(P9_DEBUG_VFS, "dir ino: %lu, old_name: %s, new=
_name: %s\n",
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0dir->i_ino, old_dentry->d_name.name,=
 dentry->d_name.name);
>
> =A0 =A0 =A0 =A0v9ses =3D v9fs_inode2v9ses(dir);
> =A0 =A0 =A0 =A0dir_dentry =3D v9fs_dentry_from_dir_inode(dir);
> @@ -770,7 +767,7 @@ v9fs_vfs_link_dotl(struct dentry *old_dentry, str=
uct inode *dir,
> =A0 =A0 =A0 =A0err =3D p9_client_link(dfid, oldfid, (char *)dentry->d=
_name.name);
>
> =A0 =A0 =A0 =A0if (err < 0) {
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 P9_DPRINTK(P9_DEBUG_VFS, "p9_client_lin=
k failed %d\n", err);
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 p9_debug(P9_DEBUG_VFS, "p9_client_link =
failed %d\n", err);
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0return err;
> =A0 =A0 =A0 =A0}
>
> @@ -813,9 +810,9 @@ v9fs_vfs_mknod_dotl(struct inode *dir, struct den=
try *dentry, int omode,
> =A0 =A0 =A0 =A0struct dentry *dir_dentry;
> =A0 =A0 =A0 =A0struct posix_acl *dacl =3D NULL, *pacl =3D NULL;
>
> - =A0 =A0 =A0 P9_DPRINTK(P9_DEBUG_VFS,
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 " %lu,%s mode: %x MAJOR: %u MINOR: %u\n=
", dir->i_ino,
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 dentry->d_name.name, omode, MAJOR(rdev)=
, MINOR(rdev));
> + =A0 =A0 =A0 p9_debug(P9_DEBUG_VFS, " %lu,%s mode: %x MAJOR: %u MINO=
R: %u\n",
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0dir->i_ino, dentry->d_name.name, omo=
de,
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0MAJOR(rdev), MINOR(rdev));
>
> =A0 =A0 =A0 =A0if (!new_valid_dev(rdev))
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0return -EINVAL;
> @@ -825,7 +822,7 @@ v9fs_vfs_mknod_dotl(struct inode *dir, struct den=
try *dentry, int omode,
> =A0 =A0 =A0 =A0dfid =3D v9fs_fid_lookup(dir_dentry);
> =A0 =A0 =A0 =A0if (IS_ERR(dfid)) {
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0err =3D PTR_ERR(dfid);
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 P9_DPRINTK(P9_DEBUG_VFS, "fid lookup fa=
iled %d\n", err);
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 p9_debug(P9_DEBUG_VFS, "fid lookup fail=
ed %d\n", err);
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0dfid =3D NULL;
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0goto error;
> =A0 =A0 =A0 =A0}
> @@ -835,8 +832,8 @@ v9fs_vfs_mknod_dotl(struct inode *dir, struct den=
try *dentry, int omode,
> =A0 =A0 =A0 =A0/* Update mode based on ACL value */
> =A0 =A0 =A0 =A0err =3D v9fs_acl_mode(dir, &mode, &dacl, &pacl);
> =A0 =A0 =A0 =A0if (err) {
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 P9_DPRINTK(P9_DEBUG_VFS,
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0"Failed to get a=
cl values in mknod %d\n", err);
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 p9_debug(P9_DEBUG_VFS, "Failed to get a=
cl values in mknod %d\n",
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0err);
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0goto error;
> =A0 =A0 =A0 =A0}
> =A0 =A0 =A0 =A0name =3D (char *) dentry->d_name.name;
> @@ -851,8 +848,8 @@ v9fs_vfs_mknod_dotl(struct inode *dir, struct den=
try *dentry, int omode,
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0fid =3D p9_client_walk(dfid, 1, &name,=
 1);
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0if (IS_ERR(fid)) {
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0err =3D PTR_ERR(fid);
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 P9_DPRINTK(P9_DEBUG_VFS=
, "p9_client_walk failed %d\n",
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 err);
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 p9_debug(P9_DEBUG_VFS, =
"p9_client_walk failed %d\n",
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0err)=
;
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0fid =3D NULL;
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0goto error;
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0}
> @@ -860,8 +857,8 @@ v9fs_vfs_mknod_dotl(struct inode *dir, struct den=
try *dentry, int omode,
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0inode =3D v9fs_get_new_inode_from_fid(=
v9ses, fid, dir->i_sb);
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0if (IS_ERR(inode)) {
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0err =3D PTR_ERR(inode)=
;
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 P9_DPRINTK(P9_DEBUG_VFS=
, "inode creation failed %d\n",
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 err);
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 p9_debug(P9_DEBUG_VFS, =
"inode creation failed %d\n",
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0err)=
;
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0goto error;
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0}
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0err =3D v9fs_fid_add(dentry, fid);
> @@ -905,7 +902,7 @@ v9fs_vfs_follow_link_dotl(struct dentry *dentry, =
struct nameidata *nd)
> =A0 =A0 =A0 =A0char *link =3D __getname();
> =A0 =A0 =A0 =A0char *target;
>
> - =A0 =A0 =A0 P9_DPRINTK(P9_DEBUG_VFS, "%s\n", dentry->d_name.name);
> + =A0 =A0 =A0 p9_debug(P9_DEBUG_VFS, "%s\n", dentry->d_name.name);
>
> =A0 =A0 =A0 =A0if (!link) {
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0link =3D ERR_PTR(-ENOMEM);
> diff --git a/fs/9p/vfs_super.c b/fs/9p/vfs_super.c
> index c70251d..06d19735 100644
> --- a/fs/9p/vfs_super.c
> +++ b/fs/9p/vfs_super.c
> @@ -121,7 +121,7 @@ static struct dentry *v9fs_mount(struct file_syst=
em_type *fs_type, int flags,
> =A0 =A0 =A0 =A0struct p9_fid *fid;
> =A0 =A0 =A0 =A0int retval =3D 0;
>
> - =A0 =A0 =A0 P9_DPRINTK(P9_DEBUG_VFS, " \n");
> + =A0 =A0 =A0 p9_debug(P9_DEBUG_VFS, "\n");
>
> =A0 =A0 =A0 =A0v9ses =3D kzalloc(sizeof(struct v9fs_session_info), GF=
P_KERNEL);
> =A0 =A0 =A0 =A0if (!v9ses)
> @@ -191,7 +191,7 @@ static struct dentry *v9fs_mount(struct file_syst=
em_type *fs_type, int flags,
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0goto release_sb;
> =A0 =A0 =A0 =A0v9fs_fid_add(root, fid);
>
> - =A0 =A0 =A0 P9_DPRINTK(P9_DEBUG_VFS, " simple set mount, return 0\n=
");
> + =A0 =A0 =A0 p9_debug(P9_DEBUG_VFS, " simple set mount, return 0\n")=
;
> =A0 =A0 =A0 =A0return dget(sb->s_root);
>
> =A0clunk_fid:
> @@ -223,7 +223,7 @@ static void v9fs_kill_super(struct super_block *s=
)
> =A0{
> =A0 =A0 =A0 =A0struct v9fs_session_info *v9ses =3D s->s_fs_info;
>
> - =A0 =A0 =A0 P9_DPRINTK(P9_DEBUG_VFS, " %p\n", s);
> + =A0 =A0 =A0 p9_debug(P9_DEBUG_VFS, " %p\n", s);
>
> =A0 =A0 =A0 =A0kill_anon_super(s);
>
> @@ -231,7 +231,7 @@ static void v9fs_kill_super(struct super_block *s=
)
> =A0 =A0 =A0 =A0v9fs_session_close(v9ses);
> =A0 =A0 =A0 =A0kfree(v9ses);
> =A0 =A0 =A0 =A0s->s_fs_info =3D NULL;
> - =A0 =A0 =A0 P9_DPRINTK(P9_DEBUG_VFS, "exiting kill_super\n");
> + =A0 =A0 =A0 p9_debug(P9_DEBUG_VFS, "exiting kill_super\n");
> =A0}
>
> =A0static void
> @@ -303,7 +303,7 @@ static int v9fs_write_inode(struct inode *inode,
> =A0 =A0 =A0 =A0 * send an fsync request to server irrespective of
> =A0 =A0 =A0 =A0 * wbc->sync_mode.
> =A0 =A0 =A0 =A0 */
> - =A0 =A0 =A0 P9_DPRINTK(P9_DEBUG_VFS, "%s: inode %p\n", __func__, in=
ode);
> + =A0 =A0 =A0 p9_debug(P9_DEBUG_VFS, "%s: inode %p\n", __func__, inod=
e);
> =A0 =A0 =A0 =A0v9inode =3D V9FS_I(inode);
> =A0 =A0 =A0 =A0if (!v9inode->writeback_fid)
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0return 0;
> @@ -326,7 +326,7 @@ static int v9fs_write_inode_dotl(struct inode *in=
ode,
> =A0 =A0 =A0 =A0 * send an fsync request to server irrespective of
> =A0 =A0 =A0 =A0 * wbc->sync_mode.
> =A0 =A0 =A0 =A0 */
> - =A0 =A0 =A0 P9_DPRINTK(P9_DEBUG_VFS, "%s: inode %p\n", __func__, in=
ode);
> + =A0 =A0 =A0 p9_debug(P9_DEBUG_VFS, "%s: inode %p\n", __func__, inod=
e);
> =A0 =A0 =A0 =A0v9inode =3D V9FS_I(inode);
> =A0 =A0 =A0 =A0if (!v9inode->writeback_fid)
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0return 0;
> diff --git a/fs/9p/xattr.c b/fs/9p/xattr.c
> index d288773..29653b7 100644
> --- a/fs/9p/xattr.c
> +++ b/fs/9p/xattr.c
> @@ -32,8 +32,8 @@ ssize_t v9fs_fid_xattr_get(struct p9_fid *fid, cons=
t char *name,
> =A0 =A0 =A0 =A0attr_fid =3D p9_client_xattrwalk(fid, name, &attr_size=
);
> =A0 =A0 =A0 =A0if (IS_ERR(attr_fid)) {
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0retval =3D PTR_ERR(attr_fid);
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 P9_DPRINTK(P9_DEBUG_VFS,
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 "p9_client_attrwalk fai=
led %zd\n", retval);
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 p9_debug(P9_DEBUG_VFS, "p9_client_attrw=
alk failed %zd\n",
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0retval);
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0attr_fid =3D NULL;
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0goto error;
> =A0 =A0 =A0 =A0}
> @@ -87,8 +87,8 @@ ssize_t v9fs_xattr_get(struct dentry *dentry, const=
 char *name,
> =A0{
> =A0 =A0 =A0 =A0struct p9_fid *fid;
>
> - =A0 =A0 =A0 P9_DPRINTK(P9_DEBUG_VFS, "%s: name =3D %s value_len =3D=
 %zu\n",
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 __func__, name, buffer_size);
> + =A0 =A0 =A0 p9_debug(P9_DEBUG_VFS, "name =3D %s value_len =3D %zu\n=
",
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0name, buffer_size);
> =A0 =A0 =A0 =A0fid =3D v9fs_fid_lookup(dentry);
> =A0 =A0 =A0 =A0if (IS_ERR(fid))
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0return PTR_ERR(fid);
> @@ -115,8 +115,8 @@ int v9fs_xattr_set(struct dentry *dentry, const c=
har *name,
> =A0 =A0 =A0 =A0int retval, msize, write_count;
> =A0 =A0 =A0 =A0struct p9_fid *fid =3D NULL;
>
> - =A0 =A0 =A0 P9_DPRINTK(P9_DEBUG_VFS, "%s: name =3D %s value_len =3D=
 %zu flags =3D %d\n",
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 __func__, name, value_len, flags);
> + =A0 =A0 =A0 p9_debug(P9_DEBUG_VFS, "name =3D %s value_len =3D %zu f=
lags =3D %d\n",
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0name, value_len, flags);
>
> =A0 =A0 =A0 =A0fid =3D v9fs_fid_clone(dentry);
> =A0 =A0 =A0 =A0if (IS_ERR(fid)) {
> @@ -129,8 +129,8 @@ int v9fs_xattr_set(struct dentry *dentry, const c=
har *name,
> =A0 =A0 =A0 =A0 */
> =A0 =A0 =A0 =A0retval =3D p9_client_xattrcreate(fid, name, value_len,=
 flags);
> =A0 =A0 =A0 =A0if (retval < 0) {
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 P9_DPRINTK(P9_DEBUG_VFS,
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 "p9_client_xattrcreate =
failed %d\n", retval);
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 p9_debug(P9_DEBUG_VFS, "p9_client_xattr=
create failed %d\n",
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0retval);
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0goto error;
> =A0 =A0 =A0 =A0}
> =A0 =A0 =A0 =A0msize =3D fid->clnt->msize;
> diff --git a/include/net/9p/9p.h b/include/net/9p/9p.h
> index 2d70b95..7184853 100644
> --- a/include/net/9p/9p.h
> +++ b/include/net/9p/9p.h
> @@ -63,30 +63,16 @@ enum p9_debug_flags {
>
> =A0#ifdef CONFIG_NET_9P_DEBUG
> =A0extern unsigned int p9_debug_level;
> -
> -#define P9_DPRINTK(level, format, arg...) \
> -do { =A0\
> - =A0 =A0 =A0 if ((p9_debug_level & level) =3D=3D level) {\
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 if (level =3D=3D P9_DEBUG_9P) \
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 printk(KERN_NOTICE "(%8=
=2E8d) " \
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 format , task_pid_nr(cu=
rrent) , ## arg); \
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 else \
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 printk(KERN_NOTICE "-- =
%s (%d): " \
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 format , __func__, task=
_pid_nr(current) , ## arg); \
> - =A0 =A0 =A0 } \
> -} while (0)
> -
> +__printf(3, 4)
> +void _p9_debug(enum p9_debug_flags level, const char *func,
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0const char *fmt, ...);
> +#define p9_debug(level, fmt, ...) =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0=
 =A0 =A0\
> + =A0 =A0 =A0 _p9_debug(level, __func__, fmt, ##__VA_ARGS__)
> =A0#else
> -#define P9_DPRINTK(level, format, arg...) =A0do { } while (0)
> +#define p9_debug(level, fmt, ...) =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0=
 =A0 =A0\
> + =A0 =A0 =A0 no_printk(fmt, ##__VA_ARGS__)
> =A0#endif
>
> -
> -#define P9_EPRINTK(level, format, arg...) \
> -do { \
> - =A0 =A0 =A0 printk(level "9p: %s (%d): " \
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 format , __func__, task_pid_nr(current)=
, ## arg); \
> -} while (0)
> -
> =A0/**
> =A0* enum p9_msg_t - 9P message types
> =A0* @P9_TLERROR: not used
>
>
>
