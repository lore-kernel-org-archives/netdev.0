From: "Randy.Dunlap" <rdunlap@xenotime.net>
Subject: [PATCH] compat. ifconf: fix limits
Date: Wed, 8 Mar 2006 09:16:08 -0800
Message-ID: <20060308091608.c56360dd.rdunlap@xenotime.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Alexandra.Kossovsky@oktetlabs.ru, ak@suse.de, akpm@osdl.org,
	torvalds@osdl.org
Return-path: <linux-fsdevel-owner@vger.kernel.org>
To: netdev@vger.kernel.org, linux-fsdevel@vger.kernel.org
Sender: linux-fsdevel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Randy Dunlap <rdunlap@xenotime.net>

A recent change to compat. dev_ifconf() in fs/compat_ioctl.c
causes ifconf data to be truncated 1 entry too early when copying it
to userspace.  The correct amount of data (length) is returned,
but the final entry is empty (zero, not filled in).
The for-loop 'i' check should use <= to allow the final struct
ifreq32 to be copied.  I also used the ifconf-corruption program
in kernel bugzilla #4746 to make sure that this change does not
re-introduce the corruption.

Signed-off-by: Randy Dunlap <rdunlap@xenotime.net>
---
 fs/compat_ioctl.c |    2 +-
 1 files changed, 1 insertion(+), 1 deletion(-)

--- linux-2616-rc5.orig/fs/compat_ioctl.c
+++ linux-2616-rc5/fs/compat_ioctl.c
@@ -446,7 +446,7 @@ static int dev_ifconf(unsigned int fd, u
 	ifr = ifc.ifc_req;
 	ifr32 = compat_ptr(ifc32.ifcbuf);
 	for (i = 0, j = 0;
-             i + sizeof (struct ifreq32) < ifc32.ifc_len && j < ifc.ifc_len;
+             i + sizeof (struct ifreq32) <= ifc32.ifc_len && j < ifc.ifc_len;
 	     i += sizeof (struct ifreq32), j += sizeof (struct ifreq)) {
 		if (copy_in_user(ifr32, ifr, sizeof (struct ifreq32)))
 			return -EFAULT;


---
