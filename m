From: Al Viro <viro@ZenIV.linux.org.uk>
Subject: Re: Recent Linus' tree, kernel BUG at fs/inode.c:1436!
Date: Fri, 19 Dec 2014 12:01:29 +0000
Message-ID: <20141219120129.GX22149@ZenIV.linux.org.uk>
References: <54940D28.8050901@parallels.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Linux Netdev List <netdev@vger.kernel.org>,
	linux-fsdevel <linux-fsdevel@vger.kernel.org>
To: Pavel Emelyanov <xemul@parallels.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from zeniv.linux.org.uk ([195.92.253.2]:58669 "EHLO
	ZenIV.linux.org.uk" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751797AbaLSMBb (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 19 Dec 2014 07:01:31 -0500
Content-Disposition: inline
In-Reply-To: <54940D28.8050901@parallels.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Dec 19, 2014 at 02:34:00PM +0300, Pavel Emelyanov wrote:
> Hi,
> 
> It looks like there's a strange refcount underflow in VFS/socket code.
> The proggie [1] crashes the recent Linus' tree (d790be38 Merge tag
> 'modules-next-for-linus' of git://git.kernel.org/pub/scm/linux/kernel/git/rusty/linux) 
> with the calltrace [2].
> 
> If in the proggie the psk is replaced with non-socket descriptor the
> issue doesn't appear.

Gyah... mismerge on cherry-pick.  My fault - ->i_fop assignment should've
been removed from sock_alloc_file() in bd9b51.  Could you verify that the
following recovers the things?

diff --git a/net/socket.c b/net/socket.c
index 70bbde6..a2c33a4 100644
--- a/net/socket.c
+++ b/net/socket.c
@@ -372,7 +372,6 @@ struct file *sock_alloc_file(struct socket *sock, int flags, const char *dname)
 	path.mnt = mntget(sock_mnt);
 
 	d_instantiate(path.dentry, SOCK_INODE(sock));
-	SOCK_INODE(sock)->i_fop = &socket_file_ops;
 
 	file = alloc_file(&path, FMODE_READ | FMODE_WRITE,
 		  &socket_file_ops);
