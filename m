From: Roland Dreier <roland@topspin.com>
Subject: Re: [PATCH][v5][0/24] Latest IB patch queue
Date: Tue, 28 Dec 2004 11:48:13 -0800
Message-ID: <52pt0unr0i.fsf@topspin.com>
References: <200412272150.IBRnA4AvjendsF8x@topspin.com>
	<20041227225417.3ac7a0a6.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@oss.sgi.com, linux-kernel@vger.kernel.org,
	openib-general@openib.org
Return-path: <openib-general-bounces@openib.org>
To: "David S. Miller" <davem@davemloft.net>
In-Reply-To: <20041227225417.3ac7a0a6.davem@davemloft.net> (David S.
	Miller's message of "Mon, 27 Dec 2004 22:54:17 -0800")
List-Unsubscribe: <http://openib.org/mailman/listinfo/openib-general>,
	<mailto:openib-general-request@openib.org?subject=unsubscribe>
List-Archive: <http://openib.org/pipermail/openib-general>
List-Post: <mailto:openib-general@openib.org>
List-Help: <mailto:openib-general-request@openib.org?subject=help>
List-Subscribe: <http://openib.org/mailman/listinfo/openib-general>,
	<mailto:openib-general-request@openib.org?subject=subscribe>
Sender: openib-general-bounces@openib.org
Errors-To: openib-general-bounces@openib.org
List-Id: netdev.vger.kernel.org

    David> W00t :-) All applied, thanks Roland.

    David> I'll run it through some build tests then toss it upstream.

Very cool, thanks a lot.  Let me know if you see any build failures --
I test on about 6 or 7 different archs/configs but the bug gods always
seem to hide problems from me.

Speaking of build failures, one of my test builds is cross-compiling
for sparc64 with gcc 3.4.2, which adds __attribute__((warn_unused_result))
to copy_to_user() et al.  The -Werror in the arch/sparc64 means the
build fails with

    linux-2.6.10/arch/sparc64/kernel/sys_sparc32.c:1686: warning: ignoring return value of `copy_to_user', declared with attribute warn_unused_result

Of course binfmt_elf.c and compat_ioctl.c still have issues but those
probably get more visibility...

Thanks,
  Roland


Check copy_to_user() return value in sys_sparc32.c and sys_sunos32.c.

Signed-off-by: Roland Dreier <roland@topspin.com>

Index: linux-2.6.10/arch/sparc64/kernel/sys_sparc32.c
===================================================================
--- linux-2.6.10.orig/arch/sparc64/kernel/sys_sparc32.c	2004-12-24 13:35:00.000000000 -0800
+++ linux-2.6.10/arch/sparc64/kernel/sys_sparc32.c	2004-12-28 11:46:00.190457463 -0800
@@ -1683,7 +1683,8 @@
 			    put_user(oldlen, (u32 __user *)(unsigned long) tmp.oldlenp))
 				error = -EFAULT;
 		}
-		copy_to_user(args->__unused, tmp.__unused, sizeof(tmp.__unused));
+		if (copy_to_user(args->__unused, tmp.__unused, sizeof(tmp.__unused)))
+			error = -EFAULT;
 	}
 	return error;
 #endif
Index: linux-2.6.10/arch/sparc64/kernel/sys_sunos32.c
===================================================================
--- linux-2.6.10.orig/arch/sparc64/kernel/sys_sunos32.c	2004-12-24 13:35:00.000000000 -0800
+++ linux-2.6.10/arch/sparc64/kernel/sys_sunos32.c	2004-12-28 11:47:03.954923634 -0800
@@ -291,7 +291,8 @@
 	put_user(ino, &dirent->d_ino);
 	put_user(namlen, &dirent->d_namlen);
 	put_user(reclen, &dirent->d_reclen);
-	copy_to_user(dirent->d_name, name, namlen);
+	if (copy_to_user(dirent->d_name, name, namlen))
+		return -EFAULT;
 	put_user(0, dirent->d_name + namlen);
 	dirent = (void __user *) dirent + reclen;
 	buf->curr = dirent;
@@ -371,7 +372,8 @@
 	put_user(ino, &dirent->d_ino);
 	put_user(namlen, &dirent->d_namlen);
 	put_user(reclen, &dirent->d_reclen);
-	copy_to_user(dirent->d_name, name, namlen);
+	if (copy_to_user(dirent->d_name, name, namlen))
+		return -EFAULT;
 	put_user(0, dirent->d_name + namlen);
 	dirent = (void __user *) dirent + reclen;
 	buf->curr = dirent;
