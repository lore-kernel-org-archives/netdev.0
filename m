From: kaber@trash.net
Subject: [PATCH 4/4] netfilter: ipt_CLUSTERIP: fix buffer overflow
Date: Sun, 20 Mar 2011 16:32:28 +0100
Message-ID: <1300635148-22648-5-git-send-email-kaber@trash.net>
References: <1300635148-22648-1-git-send-email-kaber@trash.net>
Cc: netfilter-devel@vger.kernel.org, netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <1300635148-22648-1-git-send-email-kaber@trash.net>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Vasiliy Kulikov <segoon@openwall.com>

'buffer' string is copied from userspace.  It is not checked whether it is
zero terminated.  This may lead to overflow inside of simple_strtoul().
Changli Gao suggested to copy not more than user supplied 'size' bytes.

It was introduced before the git epoch.  Files "ipt_CLUSTERIP/*" are
root writable only by default, however, on some setups permissions might be
relaxed to e.g. network admin user.

Signed-off-by: Vasiliy Kulikov <segoon@openwall.com>
Acked-by: Changli Gao <xiaosuo@gmail.com>
Signed-off-by: Patrick McHardy <kaber@trash.net>
---
 net/ipv4/netfilter/ipt_CLUSTERIP.c |    5 ++++-
 1 files changed, 4 insertions(+), 1 deletions(-)

diff --git a/net/ipv4/netfilter/ipt_CLUSTERIP.c b/net/ipv4/netfilter/ipt_CLUSTERIP.c
index 403ca57..d609ac3 100644
--- a/net/ipv4/netfilter/ipt_CLUSTERIP.c
+++ b/net/ipv4/netfilter/ipt_CLUSTERIP.c
@@ -664,8 +664,11 @@ static ssize_t clusterip_proc_write(struct file *file, const char __user *input,
 	char buffer[PROC_WRITELEN+1];
 	unsigned long nodenum;
 
-	if (copy_from_user(buffer, input, PROC_WRITELEN))
+	if (size > PROC_WRITELEN)
+		return -EIO;
+	if (copy_from_user(buffer, input, size))
 		return -EFAULT;
+	buffer[size] = 0;
 
 	if (*buffer == '+') {
 		nodenum = simple_strtoul(buffer+1, NULL, 10);
-- 
1.7.4

