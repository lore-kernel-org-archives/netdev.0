From: Tejun Heo <tj@kernel.org>
Subject: [PATCH 2/7] kernfs: implement kernfs_walk_and_get()
Date: Thu, 19 Nov 2015 13:52:46 -0500
Message-ID: <1447959171-20749-3-git-send-email-tj@kernel.org>
References: <1447959171-20749-1-git-send-email-tj@kernel.org>
Cc: netdev@vger.kernel.org, netfilter-devel@vger.kernel.org,
	coreteam@netfilter.org, cgroups@vger.kernel.org,
	linux-kernel@vger.kernel.org, kernel-team@fb.com,
	daniel@iogearbox.net, daniel.wagner@bmw-carit.de,
	nhorman@tuxdriver.com, Tejun Heo <tj@kernel.org>,
	Greg Kroah-Hartman <gregkh@linuxfoundation.org>
To: davem@davemloft.net, pablo@netfilter.org, kaber@trash.net,
	kadlec@blackhole.kfki.hu, lizefan@huawei.com, hannes@cmpxchg.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1447959171-20749-1-git-send-email-tj@kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Implement kernfs_walk_and_get() which is similar to
kernfs_find_and_get() but can walk a path instead of just a name.

v2: Use strlcpy() instead of strlen() + memcpy() as suggested by
    David.

Signed-off-by: Tejun Heo <tj@kernel.org>
Cc: Greg Kroah-Hartman <gregkh@linuxfoundation.org>
Cc: David Miller <davem@davemloft.net>
---
 fs/kernfs/dir.c        | 46 ++++++++++++++++++++++++++++++++++++++++++++++
 include/linux/kernfs.h | 12 ++++++++++++
 2 files changed, 58 insertions(+)

diff --git a/fs/kernfs/dir.c b/fs/kernfs/dir.c
index 91e0045..742bf4a 100644
--- a/fs/kernfs/dir.c
+++ b/fs/kernfs/dir.c
@@ -694,6 +694,29 @@ static struct kernfs_node *kernfs_find_ns(struct kernfs_node *parent,
 	return NULL;
 }
 
+static struct kernfs_node *kernfs_walk_ns(struct kernfs_node *parent,
+					  const unsigned char *path,
+					  const void *ns)
+{
+	static char path_buf[PATH_MAX];	/* protected by kernfs_mutex */
+	size_t len = strlcpy(path_buf, path, PATH_MAX);
+	char *p = path_buf;
+	char *name;
+
+	lockdep_assert_held(&kernfs_mutex);
+
+	if (len >= PATH_MAX)
+		return NULL;
+
+	while ((name = strsep(&p, "/")) && parent) {
+		if (*name == '\0')
+			continue;
+		parent = kernfs_find_ns(parent, name, ns);
+	}
+
+	return parent;
+}
+
 /**
  * kernfs_find_and_get_ns - find and get kernfs_node with the given name
  * @parent: kernfs_node to search under
@@ -719,6 +742,29 @@ struct kernfs_node *kernfs_find_and_get_ns(struct kernfs_node *parent,
 EXPORT_SYMBOL_GPL(kernfs_find_and_get_ns);
 
 /**
+ * kernfs_walk_and_get_ns - find and get kernfs_node with the given path
+ * @parent: kernfs_node to search under
+ * @path: path to look for
+ * @ns: the namespace tag to use
+ *
+ * Look for kernfs_node with path @path under @parent and get a reference
+ * if found.  This function may sleep and returns pointer to the found
+ * kernfs_node on success, %NULL on failure.
+ */
+struct kernfs_node *kernfs_walk_and_get_ns(struct kernfs_node *parent,
+					   const char *path, const void *ns)
+{
+	struct kernfs_node *kn;
+
+	mutex_lock(&kernfs_mutex);
+	kn = kernfs_walk_ns(parent, path, ns);
+	kernfs_get(kn);
+	mutex_unlock(&kernfs_mutex);
+
+	return kn;
+}
+
+/**
  * kernfs_create_root - create a new kernfs hierarchy
  * @scops: optional syscall operations for the hierarchy
  * @flags: KERNFS_ROOT_* flags
diff --git a/include/linux/kernfs.h b/include/linux/kernfs.h
index 5d4e9c4..af51df3 100644
--- a/include/linux/kernfs.h
+++ b/include/linux/kernfs.h
@@ -274,6 +274,8 @@ void pr_cont_kernfs_path(struct kernfs_node *kn);
 struct kernfs_node *kernfs_get_parent(struct kernfs_node *kn);
 struct kernfs_node *kernfs_find_and_get_ns(struct kernfs_node *parent,
 					   const char *name, const void *ns);
+struct kernfs_node *kernfs_walk_and_get_ns(struct kernfs_node *parent,
+					   const char *path, const void *ns);
 void kernfs_get(struct kernfs_node *kn);
 void kernfs_put(struct kernfs_node *kn);
 
@@ -350,6 +352,10 @@ static inline struct kernfs_node *
 kernfs_find_and_get_ns(struct kernfs_node *parent, const char *name,
 		       const void *ns)
 { return NULL; }
+static inline struct kernfs_node *
+kernfs_walk_and_get_ns(struct kernfs_node *parent, const char *path,
+		       const void *ns)
+{ return NULL; }
 
 static inline void kernfs_get(struct kernfs_node *kn) { }
 static inline void kernfs_put(struct kernfs_node *kn) { }
@@ -431,6 +437,12 @@ kernfs_find_and_get(struct kernfs_node *kn, const char *name)
 }
 
 static inline struct kernfs_node *
+kernfs_walk_and_get(struct kernfs_node *kn, const char *path)
+{
+	return kernfs_walk_and_get_ns(kn, path, NULL);
+}
+
+static inline struct kernfs_node *
 kernfs_create_dir(struct kernfs_node *parent, const char *name, umode_t mode,
 		  void *priv)
 {
-- 
2.5.0
