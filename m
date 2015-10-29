From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [Bug 106241] New: shutdown(3)/close(3) behaviour is incorrect
 for sockets in accept(3)
Date: Thu, 29 Oct 2015 06:48:46 -0700
Message-ID: <1446126526.7476.145.camel@edumazet-glaptop2.roam.corp.google.com>
References: <1445991236.7476.59.camel@edumazet-glaptop2.roam.corp.google.com>
	 <20151028123543.GB22011@ZenIV.linux.org.uk>
	 <1446038672.7476.65.camel@edumazet-glaptop2.roam.corp.google.com>
	 <1446043677.7476.68.camel@edumazet-glaptop2.roam.corp.google.com>
	 <20151028211347.GC22011@ZenIV.linux.org.uk>
	 <1446068668.7476.89.camel@edumazet-glaptop2.roam.corp.google.com>
	 <20151028223330.GD22011@ZenIV.linux.org.uk>
	 <1446073709.7476.93.camel@edumazet-glaptop2.roam.corp.google.com>
	 <20151029001532.GE22011@ZenIV.linux.org.uk>
	 <1446089381.7476.114.camel@edumazet-glaptop2.roam.corp.google.com>
	 <20151029041611.GF22011@ZenIV.linux.org.uk>
	 <1446122119.7476.138.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, stephen@networkplumber.org,
	netdev@vger.kernel.org,
	Linus Torvalds <torvalds@linux-foundation.org>,
	dhowells@redhat.com, linux-fsdevel@vger.kernel.org
To: Al Viro <viro@ZenIV.linux.org.uk>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f51.google.com ([209.85.220.51]:33685 "EHLO
	mail-pa0-f51.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932088AbbJ2Nst (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 29 Oct 2015 09:48:49 -0400
In-Reply-To: <1446122119.7476.138.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2015-10-29 at 05:35 -0700, Eric Dumazet wrote:

> Current kernel :
> 
>     64.98%  [kernel]          [k] queued_spin_lock_slowpath    
>     14.88%  opensock          [.] memset    // this part simulates user land actual work ;)                   
>     11.15%  [kernel]          [k] _find_next_bit.part.0        
>      0.69%  [kernel]          [k] _raw_spin_lock               
>      0.46%  [kernel]          [k] memset_erms                  
>      0.38%  [kernel]          [k] sk_alloc                     
>      0.37%  [kernel]          [k] kmem_cache_alloc             
>      0.33%  [kernel]          [k] get_empty_filp               
>      0.31%  [kernel]          [k] kmem_cache_free              
>      0.26%  [kernel]          [k] __alloc_fd                   
>      0.26%  opensock          [.] child_function               
>      0.18%  [kernel]          [k] inode_init_always            
>      0.17%  opensock          [.] __random_r                   

With attached prototype patch we get this profile instead :

You can see we no longer hit the spinlock issue and cache waste
in find_next_bit.

Userland can really progress _much_ faster.

    76.86%  opensock          [.] memset                        
     1.31%  [kernel]          [k] _raw_spin_lock                
     1.15%  assd              [.] 0x000000000056f32c            
     1.08%  [kernel]          [k] kmem_cache_free               
     0.97%  [kernel]          [k] kmem_cache_alloc              
     0.83%  [kernel]          [k] sk_alloc                      
     0.72%  [kernel]          [k] memset_erms                   
     0.70%  opensock          [.] child_function                
     0.67%  [kernel]          [k] get_empty_filp                
     0.65%  [kernel]          [k] __alloc_fd                    
     0.58%  [kernel]          [k] __close_fd                    
     0.49%  [kernel]          [k] queued_spin_lock_slowpath     

diff --git a/fs/file.c b/fs/file.c
index 6c672ad329e9..eabb9a626259 100644
--- a/fs/file.c
+++ b/fs/file.c
@@ -22,6 +22,7 @@
 #include <linux/spinlock.h>
 #include <linux/rcupdate.h>
 #include <linux/workqueue.h>
+#include <linux/random.h>
 
 int sysctl_nr_open __read_mostly = 1024*1024;
 int sysctl_nr_open_min = BITS_PER_LONG;
@@ -471,6 +472,19 @@ int __alloc_fd(struct files_struct *files,
 	spin_lock(&files->file_lock);
 repeat:
 	fdt = files_fdtable(files);
+
+	if (unlikely(flags & O_FD_FASTALLOC)) {
+		u32 rnd, limit = min(end, fdt->max_fds);
+
+		/*
+		 * Note: do not bother with files->next_fd,
+		 * this is for POSIX lovers...
+		 */
+		rnd = ((u64)prandom_u32() * limit) >> 32;
+		fd = find_next_zero_bit(fdt->open_fds, limit, rnd);
+		if (fd < limit)
+			goto ok;
+	}
 	fd = start;
 	if (fd < files->next_fd)
 		fd = files->next_fd;
@@ -499,7 +513,7 @@ repeat:
 
 	if (start <= files->next_fd)
 		files->next_fd = fd + 1;
-
+ok:
 	__set_open_fd(fd, fdt);
 	if (flags & O_CLOEXEC)
 		__set_close_on_exec(fd, fdt);
diff --git a/include/linux/net.h b/include/linux/net.h
index 70ac5e28e6b7..3823d082af4c 100644
--- a/include/linux/net.h
+++ b/include/linux/net.h
@@ -76,6 +76,7 @@ enum sock_type {
 #ifndef SOCK_NONBLOCK
 #define SOCK_NONBLOCK	O_NONBLOCK
 #endif
+#define SOCK_FD_FASTALLOC O_FD_FASTALLOC
 
 #endif /* ARCH_HAS_SOCKET_TYPES */
 
diff --git a/include/uapi/asm-generic/fcntl.h b/include/uapi/asm-generic/fcntl.h
index e063effe0cc1..badd421dd9f4 100644
--- a/include/uapi/asm-generic/fcntl.h
+++ b/include/uapi/asm-generic/fcntl.h
@@ -88,6 +88,10 @@
 #define __O_TMPFILE	020000000
 #endif
 
+#ifndef O_FD_FASTALLOC
+#define O_FD_FASTALLOC 0x40000000
+#endif
+
 /* a horrid kludge trying to make sure that this will fail on old kernels */
 #define O_TMPFILE (__O_TMPFILE | O_DIRECTORY)
 #define O_TMPFILE_MASK (__O_TMPFILE | O_DIRECTORY | O_CREAT)      
diff --git a/net/socket.c b/net/socket.c
index 9963a0b53a64..6dde02b2eaf9 100644
--- a/net/socket.c
+++ b/net/socket.c
@@ -1227,9 +1227,10 @@ SYSCALL_DEFINE3(socket, int, family, int, type, int, protocol)
 	BUILD_BUG_ON((SOCK_MAX | SOCK_TYPE_MASK) != SOCK_TYPE_MASK);
 	BUILD_BUG_ON(SOCK_CLOEXEC & SOCK_TYPE_MASK);
 	BUILD_BUG_ON(SOCK_NONBLOCK & SOCK_TYPE_MASK);
+	BUILD_BUG_ON(SOCK_FD_FASTALLOC & SOCK_TYPE_MASK);
 
 	flags = type & ~SOCK_TYPE_MASK;
-	if (flags & ~(SOCK_CLOEXEC | SOCK_NONBLOCK))
+	if (flags & ~(SOCK_CLOEXEC | SOCK_NONBLOCK | SOCK_FD_FASTALLOC))
 		return -EINVAL;
 	type &= SOCK_TYPE_MASK;
 
@@ -1240,7 +1241,7 @@ SYSCALL_DEFINE3(socket, int, family, int, type, int, protocol)
 	if (retval < 0)
 		goto out;
 
-	retval = sock_map_fd(sock, flags & (O_CLOEXEC | O_NONBLOCK));
+	retval = sock_map_fd(sock, flags & (O_CLOEXEC | O_NONBLOCK | O_FD_FASTALLOC));
 	if (retval < 0)
 		goto out_release;
 
@@ -1266,7 +1267,7 @@ SYSCALL_DEFINE4(socketpair, int, family, int, type, int, protocol,
 	int flags;
 
 	flags = type & ~SOCK_TYPE_MASK;
-	if (flags & ~(SOCK_CLOEXEC | SOCK_NONBLOCK))
+	if (flags & ~(SOCK_CLOEXEC | SOCK_NONBLOCK | SOCK_FD_FASTALLOC))
 		return -EINVAL;
 	type &= SOCK_TYPE_MASK;
 
@@ -1436,7 +1437,7 @@ SYSCALL_DEFINE4(accept4, int, fd, struct sockaddr __user *, upeer_sockaddr,
 	int err, len, newfd, fput_needed;
 	struct sockaddr_storage address;
 
-	if (flags & ~(SOCK_CLOEXEC | SOCK_NONBLOCK))
+	if (flags & ~(SOCK_CLOEXEC | SOCK_NONBLOCK | SOCK_FD_FASTALLOC))
 		return -EINVAL;
 
 	if (SOCK_NONBLOCK != O_NONBLOCK && (flags & SOCK_NONBLOCK))
