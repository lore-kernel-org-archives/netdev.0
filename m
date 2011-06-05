From: Al Viro <viro@ZenIV.linux.org.uk>
Subject: [PATCH] get_net_ns_by_fd() oopses if proc_ns_fget() returns an error
Date: Sun, 5 Jun 2011 11:37:35 +0100
Message-ID: <20110605103735.GB11521@ZenIV.linux.org.uk>
References: <20110604222531.GA11521@ZenIV.linux.org.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "Eric W. Biederman" <ebiederm@aristanetworks.com>,
	linux-fsdevel@vger.kernel.org,
	Linus Torvalds <torvalds@linux-foundation.org>
To: netdev@vger.kernel.org
Return-path: <linux-fsdevel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20110604222531.GA11521@ZenIV.linux.org.uk>
Sender: linux-fsdevel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

BTW, looking through the code related to struct net lifetime rules has
caught something else:

struct net *get_net_ns_by_fd(int fd)
{
        ...
        file = proc_ns_fget(fd);
        if (!file)
                goto out;

        ei = PROC_I(file->f_dentry->d_inode);

while in proc_ns_fget() we have two return ERR_PTR(...) and not a single
path that would return NULL.  The other caller of proc_ns_fget() treats
ERR_PTR() correctly...

Signed-off-by: Al Viro <viro@zeniv.linux.org.uk>
---
[I don't know which tree should that go through; I'm throwing that into vfs-2.6
#for-linus, but if networking folks prefer that to go through their tree...]
diff --git a/net/core/net_namespace.c b/net/core/net_namespace.c
index 6c6b86d..e41e511 100644
--- a/net/core/net_namespace.c
+++ b/net/core/net_namespace.c
@@ -310,19 +310,17 @@ struct net *get_net_ns_by_fd(int fd)
 	struct file *file;
 	struct net *net;
 
-	net = ERR_PTR(-EINVAL);
 	file = proc_ns_fget(fd);
-	if (!file)
-		goto out;
+	if (IS_ERR(file))
+		return ERR_CAST(file);
 
 	ei = PROC_I(file->f_dentry->d_inode);
-	if (ei->ns_ops != &netns_operations)
-		goto out;
+	if (ei->ns_ops == &netns_operations)
+		net = get_net(ei->ns);
+	else
+		net = ERR_PTR(-EINVAL);
 
-	net = get_net(ei->ns);
-out:
-	if (file)
-		fput(file);
+	fput(file);
 	return net;
 }
 
