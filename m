From: Andrew Morton <akpm@osdl.org>
Subject: Re: 2.6.10-rc3-mm1 FIONREAD breakge
Date: Fri, 17 Dec 2004 13:26:48 -0800
Message-ID: <20041217132648.41f3c97b.akpm@osdl.org>
References: <20041217130716.1464a068@dxpl.pdx.osdl.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: akpm@digeo.com, cliffw@osdl.org, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Stephen Hemminger <shemminger@osdl.org>
In-Reply-To: <20041217130716.1464a068@dxpl.pdx.osdl.net>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Stephen Hemminger <shemminger@osdl.org> wrote:
>
>  Latest -mm kernel broke FIONREAD on UDP sockets.

yup, you'll need this:

--- 25/fs/ioctl.c~ioctl-cleanups-broke-fionread-et-al	2004-12-13 11:12:37.687951760 -0800
+++ 25-akpm/fs/ioctl.c	2004-12-13 11:12:37.690951304 -0800
@@ -91,10 +91,8 @@ asmlinkage long sys_ioctl(unsigned int f
 			int block;
 			int res;
 
-			if (!S_ISREG(inode->i_mode)) {
-				error = -ENOTTY;
-				goto done;
-			}
+			if (!S_ISREG(inode->i_mode))
+				break;
 			/* do we support this mess? */
 			if (!mapping->a_ops->bmap) {
 				error = -EINVAL;
@@ -112,19 +110,15 @@ asmlinkage long sys_ioctl(unsigned int f
 			goto done;
 		}
 	case FIGETBSZ:
-		if (!S_ISREG(inode->i_mode)) {
-			error = -ENOTTY;
-			goto done;
-		}
+		if (!S_ISREG(inode->i_mode))
+			break;
 		error = -EBADF;
 		if (inode->i_sb)
 			error = put_user(inode->i_sb->s_blocksize, p);
 		goto done;
 	case FIONREAD:
-		if (!S_ISREG(inode->i_mode)) {
-			error = -ENOTTY;
-			goto done;
-		}
+		if (!S_ISREG(inode->i_mode))
+			break;
 		error = put_user(i_size_read(inode) - filp->f_pos, p);
 		goto done;
 	}
_
