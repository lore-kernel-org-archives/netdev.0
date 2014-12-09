From: Al Viro <viro@ZenIV.linux.org.uk>
Subject: Re: [RFC][PATCHES] iov_iter.c rewrite
Date: Tue, 9 Dec 2014 01:56:51 +0000
Message-ID: <20141209015651.GI22149@ZenIV.linux.org.uk>
References: <20141204202011.GO29748@ZenIV.linux.org.uk>
 <20141208164650.GB29028@node.dhcp.inet.fi>
 <20141208175805.GB22149@ZenIV.linux.org.uk>
 <20141208180824.GC22149@ZenIV.linux.org.uk>
 <CA+55aFxwrH4vsyw2ix=HqDK9Z=fw98xtOL8=57prm8qgVmAFfA@mail.gmail.com>
 <20141208182012.GE22149@ZenIV.linux.org.uk>
 <CA+55aFxrrTV-xBbvEzVKsXRVKyvZhQZj-6BNDpTsG4J5k6CJEg@mail.gmail.com>
 <20141208184632.GG22149@ZenIV.linux.org.uk>
 <CA+55aFyh0cV+ztK47mu1QN6aF4VvPE1V5zF7_X2TdYxZ38zZRA@mail.gmail.com>
 <20141208192816.GH22149@ZenIV.linux.org.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "Kirill A. Shutemov" <kirill@shutemov.name>,
	Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
	linux-fsdevel <linux-fsdevel@vger.kernel.org>,
	Network Development <netdev@vger.kernel.org>
To: Linus Torvalds <torvalds@linux-foundation.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20141208192816.GH22149@ZenIV.linux.org.uk>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, Dec 08, 2014 at 07:28:17PM +0000, Al Viro wrote:
> On Mon, Dec 08, 2014 at 10:57:31AM -0800, Linus Torvalds wrote:
> > So the whole "get_page()" thing is broken. Iterating over pages in a
> > KVEC is simply wrong, wrong, wrong. It needs to fail.
> 
> Well, _that_ is easy to do, of course...  E.g. by replacing that thing in
> iov_iter_get_pages()/iov_iter_get_pages_alloc() with ({ return -EFAULT; })
> will do it.

OK, folded and pushed (i.e. in vfs.git#iov_iter and vfs.git#for-next).
Matches earlier behaviour; oops reproducer is easy -

dd if=/dev/zero of=foo.ko bs=4096 count=1
cat >a.c <<'EOF'
#define _GNU_SOURCE
#include <unistd.h>
#include <fcntl.h>
#include <sys/stat.h>
#include <sys/syscall.h>
main()
{
        int fd = open("foo.ko", 00040000);
        syscall(__NR_finit_module, fd, "", 0);
}
EOF
gcc a.c
strace ./a.out

Correct behaviour (both the mainline and this series with fixes folded):
open("foo.ko", O_RDONLY|O_DIRECT)       = 3
finit_module(3, "", 0)                  = -1 EFAULT (Bad address)
Incorrect one:
open("foo.ko", O_RDONLY|O_DIRECT)       = 3
finit_module(3, "", 0 <unfinished ...>
+++ killed by SIGKILL +++
Killed

with that oops reproduced.  Not sure if it's a proper LTP or xfstests fodder,
but anyway, here it is.

Incremental from previous for-next is
diff --git a/mm/iov_iter.c b/mm/iov_iter.c
index e0605c1..a1599ca 100644
--- a/mm/iov_iter.c
+++ b/mm/iov_iter.c
@@ -560,15 +560,7 @@ ssize_t iov_iter_get_pages(struct iov_iter *i,
 		get_page(*pages = v.bv_page);
 		return v.bv_len;
 	}),({
-		unsigned long addr = (unsigned long)v.iov_base, end;
-		size_t len = v.iov_len + (*start = addr & (PAGE_SIZE - 1));
-
-		if (len > maxpages * PAGE_SIZE)
-			len = maxpages * PAGE_SIZE;
-		addr &= ~(PAGE_SIZE - 1);
-		for (end = addr + len; addr < end; addr += PAGE_SIZE)
-			get_page(*pages++ = virt_to_page(addr));
-		return len - *start;
+		return -EFAULT;
 	})
 	)
 	return 0;
@@ -622,18 +614,7 @@ ssize_t iov_iter_get_pages_alloc(struct iov_iter *i,
 		get_page(*p = v.bv_page);
 		return v.bv_len;
 	}),({
-		unsigned long addr = (unsigned long)v.iov_base, end;
-		size_t len = v.iov_len + (*start = addr & (PAGE_SIZE - 1));
-		int n;
-
-		addr &= ~(PAGE_SIZE - 1);
-		n = DIV_ROUND_UP(len, PAGE_SIZE);
-		*pages = p = get_pages_array(n);
-		if (!p)
-			return -ENOMEM;
-		for (end = addr + len; addr < end; addr += PAGE_SIZE)
-			get_page(*p++ = virt_to_page(addr));
-		return len - *start;
+		return -EFAULT;
 	})
 	)
 	return 0;
