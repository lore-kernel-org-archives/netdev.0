From: Tejun Heo <tj@kernel.org>
Subject: [PATCH] kernfs: make kernfs_walk_ns() use kernfs_pr_cont_buf[]
Date: Fri, 15 Jan 2016 12:30:14 -0500
Message-ID: <20160115173014.GI3520@mtj.duckdns.org>
References: <1449527935-27056-1-git-send-email-tj@kernel.org>
 <1449527935-27056-3-git-send-email-tj@kernel.org>
 <CAMuHMdXT63aJ2hXJg9mtMv-PZYT7CEw+ab-j42_VoFB-ib+ghg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "David S. Miller" <davem@davemloft.net>, pablo@netfilter.org,
	Patrick McHardy <kaber@trash.net>, kadlec@blackhole.kfki.hu,
	Daniel Borkmann <daniel@iogearbox.net>,
	daniel.wagner@bmw-carit.de, nhorman@tuxdriver.com,
	Zefan Li <lizefan@huawei.com>,
	Johannes Weiner <hannes@cmpxchg.org>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	netfilter-devel@vger.kernel.org, coreteam@netfilter.org,
	cgroups@vger.kernel.org,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	kernel-team@fb.com, ninasc@fb.com,
	Josh Triplett <josh@joshtriplett.org>
To: Greg Kroah-Hartman <gregkh@linuxfoundation.org>,
	Geert Uytterhoeven <geert@linux-m68k.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <CAMuHMdXT63aJ2hXJg9mtMv-PZYT7CEw+ab-j42_VoFB-ib+ghg@mail.gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

kernfs_walk_ns() uses a static path_buf[PATH_MAX] to separate out path
components.  Keeping around the 4k buffer just for kernfs_walk_ns() is
wasteful.  This patch makes it piggyback on kernfs_pr_cont_buf[]
instead.  This requires kernfs_walk_ns() to hold kernfs_rename_lock.

Signed-off-by: Tejun Heo <tj@kernel.org>
Reported-by: Geert Uytterhoeven <geert@linux-m68k.org>
---
Hello,

Greg, can you please route this one?

Thanks.

 fs/kernfs/dir.c |   19 ++++++++++++++-----
 1 file changed, 14 insertions(+), 5 deletions(-)

--- a/fs/kernfs/dir.c
+++ b/fs/kernfs/dir.c
@@ -698,15 +698,22 @@ static struct kernfs_node *kernfs_walk_n
 					  const unsigned char *path,
 					  const void *ns)
 {
-	static char path_buf[PATH_MAX];	/* protected by kernfs_mutex */
-	size_t len = strlcpy(path_buf, path, PATH_MAX);
-	char *p = path_buf;
-	char *name;
+	size_t len;
+	char *p, *name;
 
 	lockdep_assert_held(&kernfs_mutex);
 
-	if (len >= PATH_MAX)
+	/* grab kernfs_rename_lock to piggy back on kernfs_pr_cont_buf */
+	spin_lock_irq(&kernfs_rename_lock);
+
+	len = strlcpy(kernfs_pr_cont_buf, path, sizeof(kernfs_pr_cont_buf));
+
+	if (len >= sizeof(kernfs_pr_cont_buf)) {
+		spin_unlock_irq(&kernfs_rename_lock);
 		return NULL;
+	}
+
+	p = kernfs_pr_cont_buf;
 
 	while ((name = strsep(&p, "/")) && parent) {
 		if (*name == '\0')
@@ -714,6 +721,8 @@ static struct kernfs_node *kernfs_walk_n
 		parent = kernfs_find_ns(parent, name, ns);
 	}
 
+	spin_unlock_irq(&kernfs_rename_lock);
+
 	return parent;
 }
 
