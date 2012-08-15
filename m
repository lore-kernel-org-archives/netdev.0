From: Mathias Krause <minipli@googlemail.com>
Subject: [PATCH 14/14] net: fix info leak in compat dev_ifconf()
Date: Wed, 15 Aug 2012 23:31:57 +0200
Message-ID: <1345066317-22512-15-git-send-email-minipli@googlemail.com>
References: <1345066317-22512-1-git-send-email-minipli@googlemail.com>
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	Mathias Krause <minipli@googlemail.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1345066317-22512-1-git-send-email-minipli@googlemail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

The implementation of dev_ifconf() for the compat ioctl interface uses
an intermediate ifc structure allocated in userland for the duration of
the syscall. Though, it fails to initialize the padding bytes inserted
for alignment and that for leaks four bytes of kernel stack. Add an
explicit memset(0) before filling the structure to avoid the info leak.

Signed-off-by: Mathias Krause <minipli@googlemail.com>
---
 net/socket.c |    1 +
 1 file changed, 1 insertion(+)

diff --git a/net/socket.c b/net/socket.c
index dfe5b66..a5471f8 100644
--- a/net/socket.c
+++ b/net/socket.c
@@ -2657,6 +2657,7 @@ static int dev_ifconf(struct net *net, struct compat_ifconf __user *uifc32)
 	if (copy_from_user(&ifc32, uifc32, sizeof(struct compat_ifconf)))
 		return -EFAULT;
 
+	memset(&ifc, 0, sizeof(ifc));
 	if (ifc32.ifcbuf == 0) {
 		ifc32.ifc_len = 0;
 		ifc.ifc_len = 0;
-- 
1.7.10.4
