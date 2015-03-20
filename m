From: Catalin Marinas <catalin.marinas@arm.com>
Subject: [PATCH] net: compat: Update get_compat_msghdr() to match copy_msghdr_from_user() behaviour
Date: Fri, 20 Mar 2015 16:48:13 +0000
Message-ID: <1426870093-7616-1-git-send-email-catalin.marinas@arm.com>
Cc: linux-kernel@vger.kernel.org, Will Deacon <will.deacon@arm.com>,
	"David S. Miller" <davem@davemloft.net>,
	Dan Carpenter <dan.carpenter@oracle.com>
To: netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Commit db31c55a6fb2 (net: clamp ->msg_namelen instead of returning an
error) introduced the clamping of msg_namelen when the unsigned value
was larger than sizeof(struct sockaddr_storage). This caused a
msg_namelen of -1 to be valid. The native code was subsequently fixed by
commit dbb490b96584 (net: socket: error on a negative msg_namelen).

In addition, the native code sets msg_namelen to 0 when msg_name is
NULL. This was done in commit (6a2a2b3ae075 net:socket: set msg_namelen
to 0 if msg_name is passed as NULL in msghdr struct from userland) and
subsequently updated by 08adb7dabd48 (fold verify_iovec() into
copy_msghdr_from_user()).

This patch brings the get_compat_msghdr() in line with
copy_msghdr_from_user().

Fixes: db31c55a6fb2 (net: clamp ->msg_namelen instead of returning an error)
Cc: David S. Miller <davem@davemloft.net>
Cc: Dan Carpenter <dan.carpenter@oracle.com>
Signed-off-by: Catalin Marinas <catalin.marinas@arm.com>
---
 net/compat.c | 7 +++++++
 1 file changed, 7 insertions(+)

diff --git a/net/compat.c b/net/compat.c
index 94d3d5e97883..f7bd286a8280 100644
--- a/net/compat.c
+++ b/net/compat.c
@@ -49,6 +49,13 @@ ssize_t get_compat_msghdr(struct msghdr *kmsg,
 	    __get_user(kmsg->msg_controllen, &umsg->msg_controllen) ||
 	    __get_user(kmsg->msg_flags, &umsg->msg_flags))
 		return -EFAULT;
+
+	if (!uaddr)
+		kmsg->msg_namelen = 0;
+
+	if (kmsg->msg_namelen < 0)
+		return -EINVAL;
+
 	if (kmsg->msg_namelen > sizeof(struct sockaddr_storage))
 		kmsg->msg_namelen = sizeof(struct sockaddr_storage);
 	kmsg->msg_control = compat_ptr(tmp3);
