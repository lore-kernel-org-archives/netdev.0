From: Shaun Pereira <spereira@tusc.com.au>
Subject: [PATCH 2/6] x25: Allow 32 bit socket ioctl in 64 bit kernel
Date: Thu, 16 Feb 2006 09:36:28 +1100
Message-ID: <1140042989.8745.41.camel@spereira05.tusc.com.au>
Reply-To: spereira@tusc.com.au
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S932203AbWBOWiv@vger.kernel.org>
To: "David S. Miller" <davem@davemloft.net>,
	netdev <netdev@vger.kernel.org>,
	linux-kenel <linux-kernel@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

32 bit modular socket ioctl emulation for 64 bit kernel

This patch is the first step towards migration of the 'handler functions'
for 32-64 bit userspace-kernel conversion, away from the ioctl32_hash_table. 
It will be used by the x25 socket layer. 
  
Signed-off-by:Shaun Pereira <spereira@tusc.com.au>
Acked-by: Arnd Bergmann <arnd@arndb.de>

diff -uprN -X dontdiff linux-2.6.16-rc3-vanilla/include/net/compat.h linux-2.6.16-rc3/include/net/compat.h
--- linux-2.6.16-rc3-vanilla/include/net/compat.h	2006-02-15 10:58:03.000000000 +1100
+++ linux-2.6.16-rc3/include/net/compat.h	2006-02-15 11:09:00.000000000 +1100
@@ -23,6 +23,8 @@ struct compat_cmsghdr {
 	compat_int_t	cmsg_type;
 };
 
+extern int compat_sock_get_timestamp(struct sock *, struct timeval __user *);
+
 #else /* defined(CONFIG_COMPAT) */
 #define compat_msghdr	msghdr		/* to avoid compiler warnings */
 #endif /* defined(CONFIG_COMPAT) */
diff -uprN -X dontdiff linux-2.6.16-rc3-vanilla/net/compat.c linux-2.6.16-rc3/net/compat.c
--- linux-2.6.16-rc3-vanilla/net/compat.c	2006-02-15 10:58:03.000000000 +1100
+++ linux-2.6.16-rc3/net/compat.c	2006-02-15 11:09:00.000000000 +1100
@@ -503,6 +503,23 @@ static int do_get_sock_timeout(int fd, i
 	return err;
 }
 
+int compat_sock_get_timestamp(struct sock *sk, struct timeval __user *userstamp)
+{
+	struct compat_timeval __user *ctv
+		= (struct compat_timeval __user*) userstamp;
+	int err = -ENOENT;
+	if(!sock_flag(sk, SOCK_TIMESTAMP))
+		sock_enable_timestamp(sk);
+	if(sk->sk_stamp.tv_sec == -1)
+		return err;
+	if(sk->sk_stamp.tv_sec == 0)
+		do_gettimeofday(&sk->sk_stamp);
+	if (put_user(sk->sk_stamp.tv_sec, &ctv->tv_sec) |
+			put_user(sk->sk_stamp.tv_usec, &ctv->tv_usec))
+				err = -EFAULT;
+	return err;
+}
+
 asmlinkage long compat_sys_getsockopt(int fd, int level, int optname,
 				char __user *optval, int __user *optlen)
 {
@@ -602,3 +619,5 @@ asmlinkage long compat_sys_socketcall(in
 	}
 	return ret;
 }
+
+EXPORT_SYMBOL(compat_sock_get_timestamp);
