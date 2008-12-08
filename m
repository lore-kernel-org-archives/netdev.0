From: Inaky Perez-Gonzalez <inaky@linux.intel.com>
Subject: [PATCH 08/29] debugfs: add helpers for exporting a size_t simple
	value
Date: Mon,  8 Dec 2008 11:09:23 -0800
Message-ID: <38f0ccafc0c94786ed10b0247322b47b26c61d03.1228759689.git.inaky@linux.intel.com>
References: <cover.1228759689.git.inaky@linux.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 8bit
Cc: greg@kroah.com, wimax@linuxwimax.org
To: netdev@vger.kernel.org
Return-path: <wimax-bounces@linuxwimax.org>
In-Reply-To: <cover.1228759689.git.inaky@linux.intel.com>
List-Unsubscribe: <http://www.linuxwimax.org/mailman/listinfo/wimax>,
	<mailto:wimax-request@linuxwimax.org?subject=unsubscribe>
List-Archive: <http://lists.moblin.org/pipermail/wimax>
List-Post: <mailto:wimax@linuxwimax.org>
List-Help: <mailto:wimax-request@linuxwimax.org?subject=help>
List-Subscribe: <http://www.linuxwimax.org/mailman/listinfo/wimax>,
	<mailto:wimax-request@linuxwimax.org?subject=subscribe>
Sender: wimax-bounces@linuxwimax.org
Errors-To: wimax-bounces@linuxwimax.org
List-Id: netdev.vger.kernel.org

In the same spirit as debugfs_create_*(), introduce helpers for
exporting size_t values over debugfs.

The only trick done is that the format verifier is kept at %llu
instead of %zu; otherwise type warnings would pop up:

format ‘%zu’ expects type ‘size_t’, but argument 2 has type ‘long long unsigned int’

There is no real way to fix this one--however, we can consider %llu
and %zu to be compatible if we consider that we are using the same for
validating in debugfs_create_{x,u}{8,16,32}().

Signed-off-by: Inaky Perez-Gonzalez <inaky@linux.intel.com>
Cc: Greg KH <greg@kroah.com>
---
 fs/debugfs/file.c       |   32 ++++++++++++++++++++++++++++++++
 include/linux/debugfs.h |    2 ++
 2 files changed, 34 insertions(+), 0 deletions(-)

diff --git a/fs/debugfs/file.c b/fs/debugfs/file.c
index 159a5ef..33a9012 100644
--- a/fs/debugfs/file.c
+++ b/fs/debugfs/file.c
@@ -294,6 +294,38 @@ struct dentry *debugfs_create_x32(const char *name, mode_t mode,
 }
 EXPORT_SYMBOL_GPL(debugfs_create_x32);
 
+
+static int debugfs_size_t_set(void *data, u64 val)
+{
+	*(size_t *)data = val;
+	return 0;
+}
+static int debugfs_size_t_get(void *data, u64 *val)
+{
+	*val = *(size_t *)data;
+	return 0;
+}
+DEFINE_SIMPLE_ATTRIBUTE(fops_size_t, debugfs_size_t_get, debugfs_size_t_set,
+			"%llu\n");	/* %llu and %zu are more or less the same */
+
+/**
+ * debugfs_create_size_t - create a debugfs file that is used to read and write an size_t value
+ * @name: a pointer to a string containing the name of the file to create.
+ * @mode: the permission that the file should have
+ * @parent: a pointer to the parent dentry for this file.  This should be a
+ *          directory dentry if set.  If this parameter is %NULL, then the
+ *          file will be created in the root of the debugfs filesystem.
+ * @value: a pointer to the variable that the file should read to and write
+ *         from.
+ */
+struct dentry *debugfs_create_size_t(const char *name, mode_t mode,
+				     struct dentry *parent, size_t *value)
+{
+	return debugfs_create_file(name, mode, parent, value, &fops_size_t);
+}
+EXPORT_SYMBOL_GPL(debugfs_create_size_t);
+
+
 static ssize_t read_file_bool(struct file *file, char __user *user_buf,
 			      size_t count, loff_t *ppos)
 {
diff --git a/include/linux/debugfs.h b/include/linux/debugfs.h
index e1a6c04..23936b1 100644
--- a/include/linux/debugfs.h
+++ b/include/linux/debugfs.h
@@ -63,6 +63,8 @@ struct dentry *debugfs_create_x16(const char *name, mode_t mode,
 				  struct dentry *parent, u16 *value);
 struct dentry *debugfs_create_x32(const char *name, mode_t mode,
 				  struct dentry *parent, u32 *value);
+struct dentry *debugfs_create_size_t(const char *name, mode_t mode,
+				     struct dentry *parent, size_t *value);
 struct dentry *debugfs_create_bool(const char *name, mode_t mode,
 				  struct dentry *parent, u32 *value);
 
-- 
1.5.6.5
