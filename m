From: Catalin Marinas <catalin.marinas@arm.com>
Subject: [PATCH] net: compat: Ignore MSG_CMSG_COMPAT in compat_sys_{send,recv}msg
Date: Thu, 12 Feb 2015 12:28:07 +0000
Message-ID: <1423744087-21317-1-git-send-email-catalin.marinas@arm.com>
Cc: linux-kernel@vger.kernel.org, Will Deacon <will.deacon@arm.com>,
	Andy Lutomirski <luto@amacapital.net>,
	"David S. Miller" <davem@davemloft.net>
To: netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

With commit a7526eb5d06b (net: Unbreak compat_sys_{send,recv}msg), the
MSG_CMSG_COMPAT flag is blocked at the compat syscall entry points,
changing the kernel compat behaviour from the one before the commit it
was trying to fix (1be374a0518a, net: Block MSG_CMSG_COMPAT in
send(m)msg and recv(m)msg).

On 32-bit kernels (!CONFIG_COMPAT), MSG_CMSG_COMPAT is 0 and the native
32-bit sys_sendmsg() allows flag 0x80000000 to be set (it is ignored by
the kernel). However, on a 64-bit kernel, the compat ABI is different
with commit a7526eb5d06b.

This patch changes the compat_sys_{send,recv}msg behaviour to the one
prior to commit 1be374a0518a.

The problem was found running 32-bit LTP (sendmsg01) binary on an arm64
kernel. Arguably, LTP should not pass 0xffffffff as flags to sendmsg()
but the general rule is not to break user ABI (even when the user
behaviour is not entirely sane).

Fixes: a7526eb5d06b (net: Unbreak compat_sys_{send,recv}msg)
Cc: Andy Lutomirski <luto@amacapital.net>
Cc: David S. Miller <davem@davemloft.net>
Signed-off-by: Catalin Marinas <catalin.marinas@arm.com>
---
 net/compat.c | 9 ---------
 1 file changed, 9 deletions(-)

diff --git a/net/compat.c b/net/compat.c
index 3236b4167a32..94d3d5e97883 100644
--- a/net/compat.c
+++ b/net/compat.c
@@ -711,24 +711,18 @@ static unsigned char nas[21] = {
 
 COMPAT_SYSCALL_DEFINE3(sendmsg, int, fd, struct compat_msghdr __user *, msg, unsigned int, flags)
 {
-	if (flags & MSG_CMSG_COMPAT)
-		return -EINVAL;
 	return __sys_sendmsg(fd, (struct user_msghdr __user *)msg, flags | MSG_CMSG_COMPAT);
 }
 
 COMPAT_SYSCALL_DEFINE4(sendmmsg, int, fd, struct compat_mmsghdr __user *, mmsg,
 		       unsigned int, vlen, unsigned int, flags)
 {
-	if (flags & MSG_CMSG_COMPAT)
-		return -EINVAL;
 	return __sys_sendmmsg(fd, (struct mmsghdr __user *)mmsg, vlen,
 			      flags | MSG_CMSG_COMPAT);
 }
 
 COMPAT_SYSCALL_DEFINE3(recvmsg, int, fd, struct compat_msghdr __user *, msg, unsigned int, flags)
 {
-	if (flags & MSG_CMSG_COMPAT)
-		return -EINVAL;
 	return __sys_recvmsg(fd, (struct user_msghdr __user *)msg, flags | MSG_CMSG_COMPAT);
 }
 
@@ -751,9 +745,6 @@ COMPAT_SYSCALL_DEFINE5(recvmmsg, int, fd, struct compat_mmsghdr __user *, mmsg,
 	int datagrams;
 	struct timespec ktspec;
 
-	if (flags & MSG_CMSG_COMPAT)
-		return -EINVAL;
-
 	if (timeout == NULL)
 		return __sys_recvmmsg(fd, (struct mmsghdr __user *)mmsg, vlen,
 				      flags | MSG_CMSG_COMPAT, NULL);
