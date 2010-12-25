From: Akinobu Mita <akinobu.mita-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Subject: [PATCH] airo: use simple_write_to_buffer
Date: Sat, 25 Dec 2010 15:03:58 +0900
Message-ID: <1293257039-2580-3-git-send-email-akinobu.mita@gmail.com>
References: <n>
Cc: Akinobu Mita <akinobu.mita-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>,
	"John W. Linville" <linville-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org>,
	linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <n>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

Simplify write file operation for /proc files by using
simple_write_to_buffer().

Signed-off-by: Akinobu Mita <akinobu.mita-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Cc: "John W. Linville" <linville-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org>
Cc: linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
Cc: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
---
 drivers/net/wireless/airo.c |   20 +++++++-------------
 1 files changed, 7 insertions(+), 13 deletions(-)

diff --git a/drivers/net/wireless/airo.c b/drivers/net/wireless/airo.c
index a36e787..57a79b0 100644
--- a/drivers/net/wireless/airo.c
+++ b/drivers/net/wireless/airo.c
@@ -4652,24 +4652,18 @@ static ssize_t proc_write( struct file *file,
 			   size_t len,
 			   loff_t *offset )
 {
-	loff_t pos = *offset;
+	ssize_t ret;
 	struct proc_data *priv = file->private_data;
 
 	if (!priv->wbuffer)
 		return -EINVAL;
 
-	if (pos < 0)
-		return -EINVAL;
-	if (pos >= priv->maxwritelen)
-		return 0;
-	if (len > priv->maxwritelen - pos)
-		len = priv->maxwritelen - pos;
-	if (copy_from_user(priv->wbuffer + pos, buffer, len))
-		return -EFAULT;
-	if ( pos + len > priv->writelen )
-		priv->writelen = len + file->f_pos;
-	*offset = pos + len;
-	return len;
+	ret = simple_write_to_buffer(priv->wbuffer, priv->maxwritelen, offset,
+					buffer, len);
+	if (ret > 0)
+		priv->writelen = max_t(int, priv->writelen, *offset);
+
+	return ret;
 }
 
 static int proc_status_open(struct inode *inode, struct file *file)
-- 
1.7.3.4

--
To unsubscribe from this list: send the line "unsubscribe linux-wireless" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
