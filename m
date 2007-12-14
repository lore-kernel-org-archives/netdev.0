From: Arnauld Michelizza <am@zehc.net>
Subject: [patch] authorize some users to bind on specifics priv ports
Date: Fri, 14 Dec 2007 11:38:09 +0100 (CET)
Message-ID: <Pine.LNX.4.64.0712141116340.21142@atlantis>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII; format=flowed
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from laz-bur.libertysurf.net ([213.36.82.161]:56322 "EHLO atlantis"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1756978AbXLNLLd (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 14 Dec 2007 06:11:33 -0500
Received: from localhost ([127.0.0.1])
	by atlantis with esmtp (Exim 4.67)
	(envelope-from <am@zehc.net>)
	id 1J37vl-0005bY-5C
	for netdev@vger.kernel.org; Fri, 14 Dec 2007 11:38:09 +0100
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


Really simpler and usable than POSIX/capabilities and I think it 
covers basics needs for sysadmins... at least, it covers mine :-)

   www-data$ nc -l -p 80 -v
   Can't grab 0.0.0.0:80 with bind : Permission denied

   root# id -u www-data
   33
   root# port_acl_set +80 www-data
   root# cat /proc/net/port_acl
   80: 33

   www-data$ nc -l -p 80 -v
   listening on [any] 80 ...



diff -r --unidirectional-new-file -u linux-2.6.23/arch/i386/kernel/syscall_table.S linux-2.6.23-patched/arch/i386/kernel/syscall_table.S
--- linux-2.6.23/arch/i386/kernel/syscall_table.S	2007-10-09 22:31:38.000000000 +0200
+++ linux-2.6.23-patched/arch/i386/kernel/syscall_table.S	2007-12-13 14:29:40.000000000 +0100
@@ -324,3 +324,4 @@
  	.long sys_timerfd
  	.long sys_eventfd
  	.long sys_fallocate
+	.long sys_port_acl_set		/* 325 */
diff -r --unidirectional-new-file -u linux-2.6.23/include/asm-i386/unistd.h linux-2.6.23-patched/include/asm-i386/unistd.h
--- linux-2.6.23/include/asm-i386/unistd.h	2007-10-09 22:31:38.000000000 +0200
+++ linux-2.6.23-patched/include/asm-i386/unistd.h	2007-12-13 14:29:40.000000000 +0100
@@ -330,10 +330,11 @@
  #define __NR_timerfd		322
  #define __NR_eventfd		323
  #define __NR_fallocate		324
+#define __NR_port_acl_set	325

  #ifdef __KERNEL__

-#define NR_syscalls 325
+#define NR_syscalls 326

  #define __ARCH_WANT_IPC_PARSE_VERSION
  #define __ARCH_WANT_OLD_READDIR
diff -r --unidirectional-new-file -u linux-2.6.23/include/net/port_acl.h linux-2.6.23-patched/include/net/port_acl.h
--- linux-2.6.23/include/net/port_acl.h	1970-01-01 01:00:00.000000000 +0100
+++ linux-2.6.23-patched/include/net/port_acl.h	2007-12-13 15:17:40.000000000 +0100
@@ -0,0 +1,15 @@
+#include <linux/types.h>
+
+struct port_acl {
+       uid_t           uid;
+       struct port_acl *next;
+};
+
+#ifdef __PORT_ACL__
+       struct port_acl *port_acl_list[1024];
+#else
+       extern struct port_acl *port_acl_list[1024];
+#endif
+
+extern int port_acl(short int);
+extern int port_acl_get_info(char *, char **, off_t, int); 
diff -r --unidirectional-new-file -u linux-2.6.23/kernel/sys.c linux-2.6.23-patched/kernel/sys.c
--- linux-2.6.23/kernel/sys.c	2007-10-09 22:31:38.000000000 +0200
+++ linux-2.6.23-patched/kernel/sys.c	2007-12-13 16:01:24.000000000 +0100
@@ -43,6 +43,9 @@
  #include <asm/io.h>
  #include <asm/unistd.h>

+#define __PORT_ACL__
+#include <net/port_acl.h>
+
  #ifndef SET_UNALIGN_CTL
  # define SET_UNALIGN_CTL(a,b)	(-EINVAL)
  #endif
@@ -2356,4 +2359,89 @@

  	return ret;
  }
+
+/*
+ * The following lines were added to implement port_acl secured
+ * mecanism :
+ * port_acl_add - add to a user the authorisation to acces a particular port
+ * port_acl_remove - remove to a user that authorisation
+ * sys_port_acl_set - front end for port_acl_add and port_acl_remove
+ */
+long port_acl_add(short int snum, uid_t uid)
+{
+       struct port_acl *ptr, *new;
+
+       /* we verify if the permition is already set for that user */
+       ptr = port_acl_list[snum];
+
+       while (ptr != NULL) {
+               if (ptr->uid == uid)
+                       return -EBUSY;
+               if (ptr->next == NULL)
+                       break;
+               ptr = ptr->next;
+       }
+
+       /* ok, we haven't found the user and ptr is a pointer on the
+       last structure */
+       new = kmalloc( sizeof(struct port_acl), GFP_KERNEL); 
+       new->next = NULL;
+       new->uid = uid;
+
+       if(ptr == NULL)
+               port_acl_list[snum] = new;
+       else
+               ptr->next = new;
+
+       return 0;
+}
+
+long port_acl_remove(short int snum, uid_t uid)
+{
+       struct port_acl *ptr, *prev = 0;
+
+       /* we verify if the permition is already set for that user */
+       ptr = port_acl_list[snum];
+
+       while (ptr != NULL) {
+               /* we found the user */
+               if (ptr->uid == uid) {
+                       if (ptr == port_acl_list[snum]) {
+                               port_acl_list[snum] = ptr->next;
+                       }
+                       else {
+                               prev->next = ptr->next;
+                       } 
+                       kfree(ptr);
+                       return 0;
+               }
+               prev = ptr;
+               ptr = ptr->next;
+       }
+
+       return -ENODATA;
+}
+
+asmlinkage long sys_port_acl_set(short int snum, uid_t uid, int act)
+{
+       /* the owner of the process must be root */
+       if (current->uid != 0)
+               return -EACCES;
+
+       /* we verify that the port is valid */
+       if (snum<0 || snum>1023)
+               return -EINVAL;
+
+       if (uid<1 || uid>65534)
+               return -EINVAL;
+
+       if (act == 0)
+               return port_acl_remove(snum, uid);
+       else if (act == 1)
+               return port_acl_add(snum, uid);
+       else
+               return -EPERM;
+}
+
+
  EXPORT_SYMBOL_GPL(orderly_poweroff);
diff -r --unidirectional-new-file -u linux-2.6.23/net/ipv4/af_inet.c linux-2.6.23-patched/net/ipv4/af_inet.c
--- linux-2.6.23/net/ipv4/af_inet.c	2007-10-09 22:31:38.000000000 +0200
+++ linux-2.6.23-patched/net/ipv4/af_inet.c	2007-12-13 15:58:55.000000000 +0100
@@ -112,6 +112,7 @@
  #include <net/ipip.h>
  #include <net/inet_common.h>
  #include <net/xfrm.h>
+#include <net/port_acl.h>
  #ifdef CONFIG_IP_MROUTE
  #include <linux/mroute.h>
  #endif
@@ -457,7 +458,7 @@

  	snum = ntohs(addr->sin_port);
  	err = -EACCES;
-	if (snum && snum < PROT_SOCK && !capable(CAP_NET_BIND_SERVICE))
+	if (snum && snum < PROT_SOCK && !capable(CAP_NET_BIND_SERVICE) && !port_acl(snum))
  		goto out;

  	/*      We keep a pair of addresses. rcv_saddr is the one
@@ -1456,6 +1457,8 @@
  {
  	int rc = 0;

+	proc_net_create ("port_acl", 0, port_acl_get_info); 
+
  	if (raw_proc_init())
  		goto out_raw;
  	if (tcp4_proc_init())
@@ -1466,6 +1469,7 @@
  		goto out_fib;
  	if (ip_misc_proc_init())
  		goto out_misc;
+
  out:
  	return rc;
  out_misc:
@@ -1486,6 +1490,7 @@
  {
  	return 0;
  }
+
  #endif /* CONFIG_PROC_FS */

  MODULE_ALIAS_NETPROTO(PF_INET);
diff -r --unidirectional-new-file -u linux-2.6.23/net/ipv4/Makefile linux-2.6.23-patched/net/ipv4/Makefile
--- linux-2.6.23/net/ipv4/Makefile	2007-10-09 22:31:38.000000000 +0200
+++ linux-2.6.23-patched/net/ipv4/Makefile	2007-12-13 14:29:40.000000000 +0100
@@ -10,7 +10,7 @@
  	     tcp_minisocks.o tcp_cong.o \
  	     datagram.o raw.o udp.o udplite.o \
  	     arp.o icmp.o devinet.o af_inet.o  igmp.o \
-	     sysctl_net_ipv4.o fib_frontend.o fib_semantics.o
+	     sysctl_net_ipv4.o fib_frontend.o fib_semantics.o port_acl.o

  obj-$(CONFIG_IP_FIB_HASH) += fib_hash.o
  obj-$(CONFIG_IP_FIB_TRIE) += fib_trie.o
diff -r --unidirectional-new-file -u linux-2.6.23/net/ipv4/port_acl.c linux-2.6.23-patched/net/ipv4/port_acl.c
--- linux-2.6.23/net/ipv4/port_acl.c	1970-01-01 01:00:00.000000000 +0100
+++ linux-2.6.23-patched/net/ipv4/port_acl.c	2007-12-13 16:01:12.000000000 +0100
@@ -0,0 +1,54 @@
+/*
+ * This is an implementation of acces list applied
+ * to privileged ports.
+ */
+#include <linux/sched.h>
+#include <linux/stddef.h>
+#include <linux/types.h>
+#include <net/port_acl.h>
+
+/*
+ * yields 1 if the owner of the current process is authorized to
+ * bind the port given in argument
+ */
+int port_acl(short int snum)
+{
+       struct port_acl *ptr;
+       ptr = port_acl_list[snum]; 
+
+       while (ptr != NULL) {
+               if (ptr->uid == current->uid)
+                       return 1;
+               ptr = ptr->next; 
+       }
+
+       return 0;
+}
+
+
+/*
+ *     Report privileged port authorization
+ */
+int port_acl_get_info(char *buffer, char **start, off_t offset, int length)
+{
+       int p;
+       int len = 0;
+       int limit = length - 80;
+       struct port_acl *ptr;
+
+       /* for every port below 1024, we search privileged uid */
+       for (p=0;p<1024;p++) {
+               ptr = port_acl_list[p];
+               if (ptr != NULL) {
+                       len += sprintf(buffer+len,"%d:", p);
+                       do {
+                               len += sprintf(buffer+len," %d", ptr->uid);
+                               ptr = ptr->next;
+                       } while (ptr != NULL && len < limit);
+                       len += sprintf(buffer+len,"\n");
+               }
+       }
+ 
+       return len;
+}




port_acl_set.c
---
/*
  *	Add or remove to a user the authorisation to acces
  *	a particular port via the following system call :
  *		int sys_port_acl_set(short int snum, uid_t uid, int act)
  */

#include <syscall.h>
#include <linux/unistd.h>
#include <pwd.h>
#include <stdio.h>
#include <stdlib.h>
#include <sys/types.h>


int main(int argc, char **argv)
{
   int ret;
   int pnum, action;
   struct passwd *user;

   /* parse args */
   if (argc<3) {
     fprintf(stderr, "usage : %s <+->service login\n", argv[0]);
     exit(1);
   }

   switch (*argv[1]) {
   case '+' :
     action = 1 ; break;
   case '-' :
     action = 0 ; break;
   default :
     fprintf(stderr,"action '%c' is not valid\n", *argv[1]);
     exit(1);
   }

   pnum = atoi(argv[1]+1);

   user = getpwnam(argv[2]);
   if (!user) {
     fprintf(stderr,"%s is not a valid user\n", argv[2]);
     exit(1);
   }

   /* display a nice message */
   if (action == 1) {
     printf("add access on port %d to user: %s(%d)\n", pnum, argv[2], user->pw_uid);
   }
   else {
     printf("remove access on port %d to user: %s(%d)\n", pnum, argv[2], user->pw_uid);
   }

   ret = syscall(__NR_port_acl_set, pnum, user->pw_uid, action);

   if (ret!=0) {
     perror("");
     exit(2);
   }
   return 0;
}

