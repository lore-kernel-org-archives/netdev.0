From: Linus Torvalds <torvalds@linux-foundation.org>
Subject: Re: [PATCH 04/21] fs: Replace CURRENT_TIME with current_fs_time() for
 inode timestamps
Date: Thu, 9 Jun 2016 14:02:03 -0700
Message-ID: <CA+55aFwcbsCfwDa8VSYQcL4ghq-8stiqUWJ0+xsSvxp1sASi5w@mail.gmail.com>
References: <1465448705-25055-1-git-send-email-deepa.kernel@gmail.com>
 <1465448705-25055-5-git-send-email-deepa.kernel@gmail.com>
 <CA+55aFzceGREzGEJda8qt6gv6=iE_yDbM+mO2dJJa0wbu-o-Ww@mail.gmail.com> <CABeXuvouhSSAd6nymV4hjq3U2QCO0d-ueeCOnzqrbpdWzjLwjA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: linux-fsdevel <linux-fsdevel@vger.kernel.org>,
	Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Arnd Bergmann <arnd@arndb.de>,
	Thomas Gleixner <tglx@linutronix.de>, Al Viro <viro@zeniv.linux.org.uk>, y2038@lists.linaro.org,
	Steve French <sfrench@samba.org>,
	"linux-cifs@vger.kernel.org" <linux-cifs@vger.kernel.org>, samba-technical@lists.samba.org,
	Joern Engel <joern@logfs.org>, Prasad Joshi <prasadjoshi.linux@gmail.com>, logfs@logfs.org,
	Andrew Morton <akpm@linux-foundation.org>, Julia Lawall <Julia.Lawall@lip6.fr>,
	David Howells <dhowells@redhat.com>, Firo Yang <firogm@gmail.com>, Jaegeuk Kim <jaegeuk@kernel.org>,
	Changman Lee <cm224.lee@samsung.com>, Chao Yu <chao2.yu@samsung.com>,
	"Linux F2FS DEV, Mailing List" <linux-f2fs-devel@lists.sourceforge.net>, Michal Hocko <mhocko@suse.com>,
	Konstantin Khlebnikov <koct9i@gmail.com>, Naoya Horiguchi <n-horiguch
To: Deepa Dinamani <deepa.kernel@gmail.com>
Return-path: <owner-linux-mm@kvack.org>
In-Reply-To: <CABeXuvouhSSAd6nymV4hjq3U2QCO0d-ueeCOnzqrbpdWzjLwjA@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-Id: netdev.vger.kernel.org

On Thu, Jun 9, 2016 at 1:38 PM, Deepa Dinamani <deepa.kernel@gmail.com> wrote:
>
> 1. There are a few link, rename functions which assign times like this:
>
> -       inode->i_ctime = dir->i_ctime = dir->i_mtime = CURRENT_TIME;
> +       inode->i_ctime = dir->i_ctime = dir->i_mtime =
> current_fs_time(dir->i_sb);

So I think you should just pass one any of the two inodes and just add
a comment.

Then, if we hit a filesystem that actually wants to have different
granularity for different inodes, we'll split it up, but even then
we'd be better off than with the superblock, since then we *could*
easily split this one case up into "get directory time" and "get inode
time".


> 2. Also, this means that we will make it an absolute policy that any filesystem
> timestamp that is not directly connected to an inode would have to use
> ktime_get_* apis.

The thing is, those kinds of things are all going to be inside the
filesystem itself.

At that point, the *filesystem* already knows what the timekeeping
rules for that filesystem is.

I think we should strive to design the "current_fs_time()" not for
internal filesystem use, but for actual generic use where we *don't*
know a priori what the rules are, and we have to go to this helper
function to figure it out.

Inside a filesystem, why *shouldn't* the low-level filesystem already
use the normal "get time" functions?

See what I'm saying? The primary value-add to "current_fs_time()" is
for layers like the VFS and security layer that don't know what the
filesystem itself does.

At the low-level filesystem layer, you may just know that "ok, I only
have 32-bit timestamps anyway, so I should just use a 32-bit time
function".

> 3. Even if the filesystem inode has extra timestamps and these are not
> part of vfs inode, we still use
> vfs inode to get the timestamps from current_fs_time(): Eg: ext4 create time

But those already have an inode.

In fact, ext4 is a particularly bad example, since it uses the
ext4_current_time() function to get the time. And that one gets an
inode pointer.

So at least one filesystem that already does this, already uses a
inode-based model.

Everything I see just says "times are about inodes". Anything else
almost has to be filesystem-internal anyway, since the only thing that
is ever visible outside the filesystem (time-wise) is the inode.

And as mentioned, once it's internal to the low-level filesystem, it's
not obvious at all that you'd have to use "currenf_fs_time()" anyway.
The internal filesystem code might very well decide to use other
timekeeping functions.

                 Linus

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
