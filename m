From: Andy Lutomirski <luto@amacapital.net>
Subject: [PATCH 5/5] net: Block MSG_CMSG_COMPAT in send(m)msg and recv(m)msg
Date: Wed, 22 May 2013 14:07:44 -0700
Message-ID: <aa015609319786835bcab445d507faa75c11f111.1369177867.git.luto@amacapital.net>
References: <cover.1369177867.git.luto@amacapital.net>
Cc: x86@kernel.org, trinity@vger.kernel.org,
	Andy Lutomirski <luto@amacapital.net>, netdev@vger.kernel.org,
	"David S. Miller" <davem@davemloft.net>
To: linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <cover.1369177867.git.luto@amacapital.net>
In-Reply-To: <cover.1369177867.git.luto@amacapital.net>
References: <cover.1369177867.git.luto@amacapital.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

MSG_CMSG_COMPAT is (AFAIK) not intended to be part of the API --
it's a hack that steals a bit to indicate to other networking code
that a compat entry was used.  So don't allow it from a non-compat
syscall.

This prevents an oops when running this code:

int main()
{
	int s;
	struct sockaddr_in addr;
	struct msghdr *hdr;

	char *highpage = mmap((void*)(TASK_SIZE_MAX - 4096), 4096,
	                      PROT_READ | PROT_WRITE,
	                      MAP_PRIVATE | MAP_ANONYMOUS | MAP_FIXED, -1, 0);
	if (highpage == MAP_FAILED)
		err(1, "mmap");

	s = socket(AF_INET, SOCK_DGRAM, IPPROTO_UDP);
	if (s == -1)
		err(1, "socket");

        addr.sin_family = AF_INET;
        addr.sin_port = htons(1);
        addr.sin_addr.s_addr = htonl(INADDR_LOOPBACK);
	if (connect(s, (struct sockaddr*)&addr, sizeof(addr)) != 0)
		err(1, "connect");

	void *evil = highpage + 4096 - COMPAT_MSGHDR_SIZE;
	printf("Evil address is %p\n", evil);

	if (syscall(__NR_sendmmsg, s, evil, 1, MSG_CMSG_COMPAT) < 0)
		err(1, "sendmmsg");

	return 0;
}

Cc: David S. Miller <davem@davemloft.net>
Signed-off-by: Andy Lutomirski <luto@amacapital.net>
---
 net/socket.c | 33 +++++++++++++++++++++++++++++++--
 1 file changed, 31 insertions(+), 2 deletions(-)

diff --git a/net/socket.c b/net/socket.c
index 88f759a..0e16888 100644
--- a/net/socket.c
+++ b/net/socket.c
@@ -2097,8 +2097,12 @@ SYSCALL_DEFINE3(sendmsg, int, fd, struct msghdr __user *, msg, unsigned int, fla
 {
 	int fput_needed, err;
 	struct msghdr msg_sys;
-	struct socket *sock = sockfd_lookup_light(fd, &err, &fput_needed);
+	struct socket *sock;
+
+	if (flags & MSG_CMSG_COMPAT)
+		return -EINVAL;
 
+	sock = sockfd_lookup_light(fd, &err, &fput_needed);
 	if (!sock)
 		goto out;
 
@@ -2171,6 +2175,8 @@ int __sys_sendmmsg(int fd, struct mmsghdr __user *mmsg, unsigned int vlen,
 SYSCALL_DEFINE4(sendmmsg, int, fd, struct mmsghdr __user *, mmsg,
 		unsigned int, vlen, unsigned int, flags)
 {
+	if (flags & MSG_CMSG_COMPAT)
+		return -EINVAL;
 	return __sys_sendmmsg(fd, mmsg, vlen, flags);
 }
 
@@ -2271,8 +2277,12 @@ SYSCALL_DEFINE3(recvmsg, int, fd, struct msghdr __user *, msg,
 {
 	int fput_needed, err;
 	struct msghdr msg_sys;
-	struct socket *sock = sockfd_lookup_light(fd, &err, &fput_needed);
+	struct socket *sock;
+
+	if (flags & MSG_CMSG_COMPAT)
+		return -EINVAL;
 
+	sock = sockfd_lookup_light(fd, &err, &fput_needed);
 	if (!sock)
 		goto out;
 
@@ -2397,6 +2407,9 @@ SYSCALL_DEFINE5(recvmmsg, int, fd, struct mmsghdr __user *, mmsg,
 	int datagrams;
 	struct timespec timeout_sys;
 
+	if (flags & MSG_CMSG_COMPAT)
+		return -EINVAL;
+
 	if (!timeout)
 		return __sys_recvmmsg(fd, mmsg, vlen, flags, NULL);
 
@@ -2512,15 +2525,31 @@ SYSCALL_DEFINE2(socketcall, int, call, unsigned long __user *, args)
 				   (int __user *)a[4]);
 		break;
 	case SYS_SENDMSG:
+		if (a[2] & MSG_CMSG_COMPAT) {
+			err = -EINVAL;
+			break;
+		}
 		err = sys_sendmsg(a0, (struct msghdr __user *)a1, a[2]);
 		break;
 	case SYS_SENDMMSG:
+		if (a[3] & MSG_CMSG_COMPAT) {
+			err = -EINVAL;
+			break;
+		}
 		err = sys_sendmmsg(a0, (struct mmsghdr __user *)a1, a[2], a[3]);
 		break;
 	case SYS_RECVMSG:
+		if (a[2] & MSG_CMSG_COMPAT) {
+			err = -EINVAL;
+			break;
+		}
 		err = sys_recvmsg(a0, (struct msghdr __user *)a1, a[2]);
 		break;
 	case SYS_RECVMMSG:
+		if (a[3] & MSG_CMSG_COMPAT) {
+			err = -EINVAL;
+			break;
+		}
 		err = sys_recvmmsg(a0, (struct mmsghdr __user *)a1, a[2], a[3],
 				   (struct timespec __user *)a[4]);
 		break;
-- 
1.8.1.4
