From: Linus Torvalds <torvalds@linux-foundation.org>
Subject: Re: [PATCH 04/21] fs: Replace CURRENT_TIME with current_fs_time() for
 inode timestamps
Date: Thu, 9 Jun 2016 12:08:04 -0700
Message-ID: <CA+55aFzceGREzGEJda8qt6gv6=iE_yDbM+mO2dJJa0wbu-o-Ww@mail.gmail.com>
References: <1465448705-25055-1-git-send-email-deepa.kernel@gmail.com> <1465448705-25055-5-git-send-email-deepa.kernel@gmail.com>
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
In-Reply-To: <1465448705-25055-5-git-send-email-deepa.kernel@gmail.com>
Sender: owner-linux-mm@kvack.org
List-Id: netdev.vger.kernel.org

On Wed, Jun 8, 2016 at 10:04 PM, Deepa Dinamani <deepa.kernel@gmail.com> wrote:
> CURRENT_TIME macro is not appropriate for filesystems as it
> doesn't use the right granularity for filesystem timestamps.
> Use current_fs_time() instead.

Again - using the inode instead fo the syuperblock in tghis patch
would have made the patch much more obvious (it could have been 99%
generated with the sed-script I sent out a week or two ago), and it
would have made it unnecessary to add these kinds of things:

> diff --git a/drivers/usb/core/devio.c b/drivers/usb/core/devio.c
> index e9f5043..85c12f0 100644
> --- a/drivers/usb/core/devio.c
> +++ b/drivers/usb/core/devio.c
> @@ -2359,6 +2359,7 @@ static long usbdev_do_ioctl(struct file *file, unsigned int cmd,
>  {
>         struct usb_dev_state *ps = file->private_data;
>         struct inode *inode = file_inode(file);
> +       struct super_block *sb = inode->i_sb;
>         struct usb_device *dev = ps->dev;
>         int ret = -ENOTTY;

where we add a new variable just because the calling convention was wrong.

It's not even 100% obvious that a filesystem has to have one single
time representation, so making the time function about the entity
whose time is set is also conceptually a much better model, never mind
that it is just what every single user seems to want anyway.

So I'd *much* rather see

+       inode->i_atime = inode->i_mtime = inode->i_ctime =
current_fs_time(inode);

over seeing either of these two variants::

+       inode->i_atime = inode->i_mtime = inode->i_ctime =
current_fs_time(inode->i_sb);
+       ret->i_atime = ret->i_mtime = ret->i_ctime = current_fs_time(sb);

because the first of those variants (grep for current_fs_time() in the
current git tree, and notice that it's the common one) we have the
pointless "let's chase a pointer in every caller"

And while it's true that the second variant is natural for *some*
situations, I've yet to find one where it wasn't equally sane to just
pass in the inode instead.

                     Linus

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
