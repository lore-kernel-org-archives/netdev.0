From: Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>
Subject: Re: [Xen-devel] [PATCH net-next v3] xen-netback: Adding debugfs
 "io_ring_qX" files
Date: Tue, 8 Jul 2014 14:49:59 -0400
Message-ID: <20140708184959.GC15548@laptop.dumpdata.com>
References: <1404837194-16726-1-git-send-email-zoltan.kiss@citrix.com>
 <20140708173934.GA6597@laptop.dumpdata.com>
 <53BC3BC4.5010504@citrix.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Wei Liu <wei.liu2@citrix.com>,
	Ian Campbell <Ian.Campbell@citrix.com>, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, xen-devel@lists.xenproject.org
To: Zoltan Kiss <zoltan.kiss@citrix.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <53BC3BC4.5010504@citrix.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, Jul 08, 2014 at 07:43:16PM +0100, Zoltan Kiss wrote:
> On 08/07/14 18:39, Konrad Rzeszutek Wilk wrote:
> 
> >
> >
> >>+	return count;
> >>+}
> >>+
> >>+static int xenvif_dump_open(struct inode *inode, struct file *filp)
> >>+{
> >>+	int ret;
> >>+	void *queue = NULL;
> >>+
> >>+	if (inode->i_private)
> >>+		queue = inode->i_private;
> >>+	ret = single_open(filp, xenvif_read_io_ring, queue);
> >>+	filp->f_mode |= FMODE_PWRITE;
> >>+	return ret;
> >>+}
> >>+
> >>+static const struct file_operations xenvif_dbg_io_ring_ops_fops = {
> >>+	.owner = THIS_MODULE,
> >>+	.open = xenvif_dump_open,
> >>+	.read = seq_read,
> >>+	.llseek = seq_lseek,
> >>+	.release = single_release,
> >>+	.write = xenvif_write_io_ring,
> >>+};
> >>+
> >>+static void xenvif_debugfs_addif(struct xenvif_queue *queue)
> >>+{
> >>+	struct dentry *pfile;
> >>+	struct xenvif *vif = queue->vif;
> >>+	int i;
> >>+
> >>+	if (!IS_ERR_OR_NULL(xen_netback_dbg_root))
> >>+		return;
> >
> >I am curious to how you tested this patch, as my reading of
> >the code above would imply that when xen_netback_dbg_root is
> >initialized - we won't continue within this function?
> Indeed, I've just copy-pasted that snippet you wrote in your prev mail and I
> haven't tried it out, as it was a very small change. I'll fix it.
> 
> >>+
> >>  static int netback_remove(struct xenbus_device *dev)
> >>  {
> >>  	struct backend_info *be = dev_get_drvdata(&dev->dev);
> >>@@ -246,8 +413,12 @@ static void backend_create_xenvif(struct backend_info *be)
> >>
> >>  static void backend_disconnect(struct backend_info *be)
> >>  {
> >>-	if (be->vif)
> >>+	if (be->vif) {
> >>+#ifdef CONFIG_DEBUG_FS
> >>+		xenvif_debugfs_delif(be->vif);
> >>+#endif /* CONFIG_DEBUG_FS */
> >
> >Why don't you just leave it as it (without the #ifdef) and add an
> >empty function for the #else CONFIG_DEBUG_FS like:
> >
> >#else
> >static inline void xenvif_debugfs_addif(struct xenvif_queue *queue) {}
> >static inline void xenvif_debugfs_delif(struct xenvif *vif) {}
> >#endif
> It wouldn't change the end result, but from the code reader's point of view
> the current way is a little bit better, as (s)he doesn't need to check the
> declaration to realize it has effect only if that config option is enabled.

I disagree (and the Linux kernel has numerous example for this - thought
most of this is hidden in the headers so that the .C code has the 
minimum amount of #ifdef) - however ultimately it is Ian C decision on which
way this should go.

> 
