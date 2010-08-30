From: Elmar Stellnberger <estellnb@gmail.com>
Subject: Re: block network access for certain users/groups
Date: Mon, 30 Aug 2010 13:36:23 +0200
Message-ID: <AANLkTi=HpQNM_FeHDdejnh-q-RhLMFVK3-O5JgWKejA0@mail.gmail.com>
References: <AANLkTin8w74SAe67ZPqPE0Q=0fPpZOHnTCnjAT+AduCY@mail.gmail.com>
	<AANLkTikru-pmMAnS-dqjYT7xJC_X21rVNBpjg_2LDmWB@mail.gmail.com>
	<201008252058.DDE12933.FOLOHQSJFFOMtV@I-love.SAKURA.ne.jp>
	<201008262128.DCG04175.JFQFLFVOMHOtSO@I-love.SAKURA.ne.jp>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: netdev@vger.kernel.org, netfilter-devel@vger.kernel.org
To: Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-iw0-f174.google.com ([209.85.214.174]:39787 "EHLO
	mail-iw0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755375Ab0H3LhV (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 30 Aug 2010 07:37:21 -0400
In-Reply-To: <201008262128.DCG04175.JFQFLFVOMHOtSO@I-love.SAKURA.ne.jp>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Many Thnaks.
This is exactly what I have been looking for!
However if I compile the kernel module and try to load it that results
in a kernel hang that I can only escape by Alt-PrnScr-S-U-B, no matter
whether the module is loaded on boot time or in rl5. I have checked
all required kernel options and built it like the following (using
openSUSE 11.3):

make -C /lib/modules/`uname -r`/build SUBDIRS=~+/ modules || exit $?
install -m 644 nwusrblock-module /lib/modules/`uname
-r`/kernel/drivers/nwusrblock-module
/sbin/depmod -a
modprobe nwusrblock-modul



2010/8/26, Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp>:
> Tetsuo Handa wrote:
>> Elmar Stellnberger wrote:
>> > I need to block network access for certain users/groups, fully:
> Oh, I thought you want to partially block communication by specific user.
>
> You want to entirely block communication by specific user? Then, it is easy.
> You can block all socket syscalls by that user using LSM.
> I made an example LSM module which can be added as a loadable kernel module
> ( http://www.youtube.com/watch?v=wG8BTLMu5wo ). You can modify it as you
> like.
>
> You can compile and load below module provided that your kernel config has
> CONFIG_SECURITY_NETWORK=y .
>
> Did this module answer your question?
>
> Thanks.
> ----------------------------------------
> /*
>  * Uid-NoSock Linux Security Module
>  *
>  * Author: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
>  *
>  * This module blocks socket syscalls by specific UID. Use at your own risk.
>  *
>  * This program is free software; you can redistribute it and/or modify
>  * it under the terms of the GNU General Public License version 2, as
>  * published by the Free Software Foundation.
>  */
> /*
>  * Place this file (uid_nosock.c) in some directory and create Makefile
>  * containing a line
>  *
>  *  obj-m += uid_nosock.o
>  *
>  * and run
>  *
>  *   make SUBDIRS=directory_containing_this_file/ modules modules_install
>  *
>  */
> #include <linux/security.h>
> #ifndef CONFIG_SECURITY_NETWORK
> #error This module depends on CONFIG_SECURITY_NETWORK=y
> #endif
> #ifndef CONFIG_SECURITY
> #error This module depends on CONFIG_SECURITY=y
> #endif
> #ifndef CONFIG_KALLSYMS
> #error This module depends on CONFIG_KALLSYMS=y
> #endif
> #ifndef CONFIG_MODULES
> #error This module depends on CONFIG_MODULES=y
> #endif
> #include <linux/module.h>
> #include <linux/pid_namespace.h>
> #include <linux/mount.h>
> #include <linux/fs_struct.h>
> static struct security_operations original_security_ops;
>
> /* UID to block socket syscalls. */
> #define UID_NOSOCK_REJECT_UID 500
>
> static bool uid_nosock_deny(void)
> {
> 	return current_uid() == UID_NOSOCK_REJECT_UID;
> }
>
> static int uid_nosock_socket_create(int family, int type, int protocol,
> 				    int kern)
> {
> 	if (uid_nosock_deny())
> 		return -EPERM;
> 	return original_security_ops.socket_create(family, type, protocol,
> 						   kern);
> }
>
> static int uid_nosock_socket_bind(struct socket *sock,
> 				  struct sockaddr *address, int addrlen)
> {
> 	if (uid_nosock_deny())
> 		return -EPERM;
> 	return original_security_ops.socket_bind(sock, address, addrlen);
> }
>
> static int uid_nosock_socket_connect(struct socket *sock,
> 				     struct sockaddr *address, int addrlen)
> {
> 	if (uid_nosock_deny())
> 		return -EPERM;
> 	return original_security_ops.socket_connect(sock, address, addrlen);
> }
>
> static int uid_nosock_socket_listen(struct socket *sock, int backlog)
> {
> 	if (uid_nosock_deny())
> 		return -EPERM;
> 	return original_security_ops.socket_listen(sock, backlog);
> }
>
> static int uid_nosock_socket_accept(struct socket *sock,
> 				    struct socket *newsock)
> {
> 	if (uid_nosock_deny())
> 		return -EPERM;
> 	return original_security_ops.socket_accept(sock, newsock);
> }
>
> static int uid_nosock_socket_sendmsg(struct socket *sock, struct msghdr
> *msg,
> 				     int size)
> {
> 	if (uid_nosock_deny())
> 		return -EPERM;
> 	return original_security_ops.socket_sendmsg(sock, msg, size);
> }
>
> static int uid_nosock_socket_recvmsg(struct socket *sock, struct msghdr
> *msg,
> 				     int size, int flags)
> {
> 	if (uid_nosock_deny())
> 		return -EPERM;
> 	return original_security_ops.socket_recvmsg(sock, msg, size, flags);
> }
>
> static int uid_nosock_socket_getsockname(struct socket *sock)
> {
> 	if (uid_nosock_deny())
> 		return -EPERM;
> 	return original_security_ops.socket_getsockname(sock);
> }
>
> static int uid_nosock_socket_getpeername(struct socket *sock)
> {
> 	if (uid_nosock_deny())
> 		return -EPERM;
> 	return original_security_ops.socket_getpeername(sock);
> }
>
> static int uid_nosock_socket_getsockopt(struct socket *sock, int level,
> 					int optname)
> {
> 	if (uid_nosock_deny())
> 		return -EPERM;
> 	return original_security_ops.socket_getsockopt(sock, level, optname);
> }
>
> static int uid_nosock_socket_setsockopt(struct socket *sock, int level,
> 					int optname)
> {
> 	if (uid_nosock_deny())
> 		return -EPERM;
> 	return original_security_ops.socket_setsockopt(sock, level, optname);
> }
>
> /* Find symbols from /proc/kallsyms . */
> static void *__init uid_nosock_find_symbol(const char *keyline)
> {
> 	struct file *file;
> 	char *buf;
> 	unsigned long entry = 0;
> 	{
> 		struct fs_struct *fs = current->fs;
> 		struct vfsmount *mnt = current->nsproxy->pid_ns->proc_mnt;
> 		struct path old_path;
> 		struct path new_path = { mnt, mnt->mnt_root };
> 		spin_lock(&fs->lock); /* was write_lock() till 2.6.35. */
> 		old_path = fs->pwd;
> 		fs->pwd = new_path;
> 		spin_unlock(&fs->lock);
> 		file = filp_open("kallsyms", O_RDONLY, 0);
> 		spin_lock(&fs->lock);
> 		fs->pwd = old_path;
> 		spin_unlock(&fs->lock);
> 	}
> 	if (IS_ERR(file))
> 		goto out;
> 	buf = kmalloc(PAGE_SIZE, GFP_KERNEL);
> 	if (buf) {
> 		int len;
> 		int offset = 0;
> 		while ((len = kernel_read(file, offset, buf,
> 					  PAGE_SIZE - 1)) > 0) {
> 			char *cp;
> 			buf[len] = '\0';
> 			cp = strrchr(buf, '\n');
> 			if (!cp)
> 				break;
> 			*(cp + 1) = '\0';
> 			offset += strlen(buf);
> 			cp = strstr(buf, keyline);
> 			if (!cp)
> 				continue;
> 			*cp = '\0';
> 			while (cp > buf && *(cp - 1) != '\n')
> 				cp--;
> 			entry = simple_strtoul(cp, NULL, 16);
> 			break;
> 		}
> 		kfree(buf);
> 	}
> 	filp_close(file, NULL);
> out:
> 	return (void *) entry;
> }
>
> /* Never mark this variable as __initdata . */
> static struct security_operations *uid_nosock_security_ops;
>
> /* Never mark this function as __init . */
> static int uid_nosock_addr_calculator(struct file *file)
> {
> 	return uid_nosock_security_ops->file_alloc_security(file);
> }
>
> static int __init uid_nosock_init(void)
> {
> 	struct security_operations **ptr;
> 	struct security_operations *ops;
> 	int i;
> 	const u8 *cp;
> 	/*
> 	 * Guess "struct security_operations *security_ops;".
> 	 * This trick depends on below assumptions.
> 	 *
> 	 * (1) Compiler generates identical code for security_file_alloc() and
> 	 *     uid_nosock_addr_calculator().
> 	 * (2) uid_nosock_security_ops is found within 128 bytes from
> 	 *     uid_nosock_addr_calculator, even if additional code (e.g. debug
> 	 *     symbols) is added.
> 	 * (3) It is safe to read 128 bytes from uid_nosock_addr_calculator.
> 	 * (4) uid_nosock_security_ops != Byte code except
> 	 *     uid_nosock_security_ops.
> 	 */
> 	cp = (const u8 *) uid_nosock_addr_calculator;
> 	for (i = 0; i < 128; i++) {
> 		if (sizeof(uid_nosock_security_ops) == sizeof(u32)) {
> 			if (*(u32 *) cp == (u32) &uid_nosock_security_ops)
> 				break;
> 		} else if (sizeof(uid_nosock_security_ops) == sizeof(u64)) {
> 			if (*(u64 *) cp == (u64) &uid_nosock_security_ops)
> 				break;
> 		}
> 		cp++;
> 	}
> 	if (i == 128) {
> 		printk(KERN_ERR
> 		       "Can't resolve uid_nosock_security_ops structure.\n");
> 		return -EINVAL;
> 	}
> 	cp = (const u8 *) uid_nosock_find_symbol(" security_file_alloc\n");
> 	if (!cp) {
> 		printk(KERN_ERR "Can't resolve security_file_alloc().\n");
> 		return -EINVAL;
> 	}
> 	/* This should be "struct security_operations *security_ops;". */
> 	ptr = *(struct security_operations ***) (cp + i);
> 	if (!ptr) {
> 		printk(KERN_ERR "Can't resolve security_ops structure.\n");
> 		return -EINVAL;
> 	}
> 	ops = *ptr;
> 	if (!ops) {
> 		printk(KERN_ERR "No security_operations registered.\n");
> 		return -EINVAL;
> 	}
> 	memmove(&original_security_ops, ops, sizeof(original_security_ops));
> 	smp_mb();
> 	BUG_ON(ops->socket_create == uid_nosock_socket_create ||
> 	       ops->socket_bind == uid_nosock_socket_bind ||
> 	       ops->socket_connect == uid_nosock_socket_connect ||
> 	       ops->socket_listen == uid_nosock_socket_listen ||
> 	       ops->socket_accept == uid_nosock_socket_accept ||
> 	       ops->socket_sendmsg == uid_nosock_socket_sendmsg ||
> 	       ops->socket_recvmsg == uid_nosock_socket_recvmsg ||
> 	       ops->socket_getsockname == uid_nosock_socket_getsockname ||
> 	       ops->socket_getpeername == uid_nosock_socket_getpeername ||
> 	       ops->socket_getsockopt == uid_nosock_socket_getsockopt ||
> 	       ops->socket_setsockopt == uid_nosock_socket_setsockopt);
> 	ops->socket_create = uid_nosock_socket_create;
> 	ops->socket_bind = uid_nosock_socket_bind;
> 	ops->socket_connect = uid_nosock_socket_connect;
> 	ops->socket_listen = uid_nosock_socket_listen;
> 	ops->socket_accept = uid_nosock_socket_accept;
> 	ops->socket_sendmsg = uid_nosock_socket_sendmsg;
> 	ops->socket_recvmsg = uid_nosock_socket_recvmsg;
> 	ops->socket_getsockname = uid_nosock_socket_getsockname;
> 	ops->socket_getpeername = uid_nosock_socket_getpeername;
> 	ops->socket_getsockopt = uid_nosock_socket_getsockopt;
> 	ops->socket_setsockopt = uid_nosock_socket_setsockopt;
> 	printk(KERN_INFO "Uid-Nosock: Blocking socket syscalls by uid=%u.\n",
> 	       UID_NOSOCK_REJECT_UID);
> 	return 0;
> }
>
> module_init(uid_nosock_init);
> MODULE_LICENSE("GPL");
>
