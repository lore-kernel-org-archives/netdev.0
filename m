From: Al Viro <viro-3bDd1+5oDREiFSDQTTA3OLVCufUGDwFn@public.gmane.org>
Subject: Re: 2.6.34-rc3-git6: Reported regressions from 2.6.33
Date: Wed, 7 Apr 2010 23:19:41 +0100
Message-ID: <20100407221941.GL30031@ZenIV.linux.org.uk>
References: <6Pphclm24fK.A.lSF.qsPvLB@chimera>
 <alpine.LFD.2.00.1004071444440.3586@i5.linux-foundation.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "Rafael J. Wysocki" <rjw-KKrjLPT3xs0@public.gmane.org>,
	Linux Kernel Mailing List <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	Maciej Rutecki <maciej.rutecki-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>,
	Andrew Morton <akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>,
	Kernel Testers List <kernel-testers-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	Network Development <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	Linux ACPI <linux-acpi-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	Linux PM List <linux-pm-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>,
	Linux SCSI List <linux-scsi-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	Linux Wireless List <linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	DRI <dri-devel-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org>
To: Linus Torvalds <torvalds-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>
Return-path: <kernel-testers-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <alpine.LFD.2.00.1004071444440.3586-GpypE611fyS63QaFMGN2QEqCLAeBNdoH@public.gmane.org>
Sender: kernel-testers-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Wed, Apr 07, 2010 at 03:04:46PM -0700, Linus Torvalds wrote:

> > Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=15674
> > Subject		: [2.6.34-rc2 NFS4 oops] open error path failure...
> > Submitter	: Daniel J Blueman <daniel.blueman-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
> > Date		: 2010-03-29 18:36 (10 days old)
> > Message-ID	: <6278d2221003291136p6481fe8emfb039403343c082-JsoAwUIsXosN+BqQ9rBEUg@public.gmane.org>
> > References	: http://marc.info/?l=linux-kernel&m=126988782722711&w=2
> 
> This smells like the same LOOKUP_DIRECTORY thing as the first entry, but.. 

No, it's not the same thing; the fix is to have nfs ->d_revalidate()
return an error on failing open attempt (in insane codepath that has
->d_revalidate() handling open()).  Confirmed to work by reporter...

diff --git a/fs/nfs/nfs4proc.c b/fs/nfs/nfs4proc.c
index d79a7b3..fe0cd9e 100644
--- a/fs/nfs/nfs4proc.c
+++ b/fs/nfs/nfs4proc.c
@@ -2068,8 +2068,7 @@ nfs4_open_revalidate(struct inode *dir, struct dentry *dentry, int openflags, st
 			case -EDQUOT:
 			case -ENOSPC:
 			case -EROFS:
-				lookup_instantiate_filp(nd, (struct dentry *)state, NULL);
-				return 1;
+				return PTR_ERR(state);
 			default:
 				goto out_drop;
 		}
