From: Arnd Bergmann <arnd@arndb.de>
Subject: Re: linux-next: manual merge of the bkl-llseek tree with the wireless tree
Date: Sat, 23 Oct 2010 11:27:35 +0200
Message-ID: <201010231127.35785.arnd@arndb.de>
References: <20101018173543.c33530e9.sfr@canb.auug.org.au> <20101023142312.533f6a42.sfr@canb.auug.org.au>
Mime-Version: 1.0
Content-Type: Text/Plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: "John W. Linville" <linville@tuxdriver.com>,
	David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
	linux-next@vger.kernel.org, linux-kernel@vger.kernel.org,
	Felix Fietkau <nbd@openwrt.org>,
	Linus <torvalds@linux-foundation.org>,
	Christoph Hellwig <hch@infradead.org>
To: Stephen Rothwell <sfr@canb.auug.org.au>
Return-path: <linux-next-owner@vger.kernel.org>
In-Reply-To: <20101023142312.533f6a42.sfr@canb.auug.org.au>
Sender: linux-next-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Saturday 23 October 2010, Stephen Rothwell wrote:
> Hi John, Dave,
> 
> On Mon, 18 Oct 2010 17:35:43 +1100 Stephen Rothwell <sfr@canb.auug.org.au> wrote:
> >
> > Today's linux-next merge of the bkl-llseek tree got a conflict in
> > drivers/net/wireless/ath/ath9k/debug.c between commit
> > 772d5515635fef5bc7a9d0efee785b58b0181ee5 ("ath9k: make rate control
> > debugfs stats per station") from the wireless tree and commit
> > 6038f373a3dc1f1c26496e60b6c40b164716f07e ("llseek: automatically
> > add .llseek fop") from the bkl-llseek tree.
> > 
> > The former moved some of the code modified by the latter to another file.
> > 
> > I added this merge fix patch:
> 
> This patch (reproduced below) will now be needed if the wireless or net
> tree is merged with Linus' tree.  I also think I have missed a similar
> needed fix in drivers/net/wireless/ath/ath5k/debug.c ...

There are also new drivers for speakup, intel_sst and yurex that introduce
additional file_operations in next, the patch below is what I had planned
to submit once everything is in. I also expect the occasional driver that
did not see linux-next, so I'll rerun my scripts after -rc1 to see what
we got.

As Christoph mentioned, we probably shouldn't make new drivers use
noop_llssek if possible nor add an explicit no_llseek and we can just
leave those with the implicit no_llseek.

Once open question is what pread/pwrite should do if there is no
llseek function. Right now they are both possible, but it would also
be logical to turn this into an implicit nonseekable_open, which forbids
pread/pwrite as well.

	Arnd

diff --git a/drivers/net/wireless/ath/ath5k/debug.c b/drivers/net/wireless/ath/ath5k/debug.c
index e157646..b203034 100644
--- a/drivers/net/wireless/ath/ath5k/debug.c
+++ b/drivers/net/wireless/ath/ath5k/debug.c
@@ -537,6 +537,7 @@ static ssize_t read_file_misc(struct file *file, char __user *user_buf,
 static const struct file_operations fops_misc = {
 	.read = read_file_misc,
 	.open = ath5k_debugfs_open,
+	.llseek = default_llseek,
 	.owner = THIS_MODULE,
 };
 
diff --git a/drivers/staging/intel_sst/intel_sst.c b/drivers/staging/intel_sst/intel_sst.c
index 24d3928..d9c4ae5 100644
--- a/drivers/staging/intel_sst/intel_sst.c
+++ b/drivers/staging/intel_sst/intel_sst.c
@@ -64,6 +64,7 @@ static const struct file_operations intel_sst_fops = {
 	.mmap = intel_sst_mmap,
 	.aio_read = intel_sst_aio_read,
 	.aio_write = intel_sst_aio_write,
+	.llseek = nonseekable_open,
 };
 static const struct file_operations intel_sst_fops_cntrl = {
 	.owner = THIS_MODULE,
diff --git a/drivers/staging/intel_sst/intel_sst_app_interface.c b/drivers/staging/intel_sst/intel_sst_app_interface.c
index 82768fa..931c4ba 100644
--- a/drivers/staging/intel_sst/intel_sst_app_interface.c
+++ b/drivers/staging/intel_sst/intel_sst_app_interface.c
@@ -121,6 +121,7 @@ int intel_sst_open(struct inode *i_node, struct file *file_ptr)
 		retval = -EUSERS;
 		mutex_unlock(&sst_drv_ctx->stream_lock);
 	}
+	nonseekable_open(i_node, file_ptr);
 	return retval;
 }
 
@@ -151,6 +152,7 @@ int intel_sst_open_cntrl(struct inode *i_node, struct file *file_ptr)
 		retval = -EACCES;
 
 	mutex_unlock(&sst_drv_ctx->stream_lock);
+	nonseekable_open(i_node, file_ptr);
 	return retval;
 }
 
diff --git a/drivers/staging/speakup/devsynth.c b/drivers/staging/speakup/devsynth.c
index 39dc586..5fc63fc 100644
--- a/drivers/staging/speakup/devsynth.c
+++ b/drivers/staging/speakup/devsynth.c
@@ -48,6 +48,8 @@ static int speakup_file_open(struct inode *ip, struct file *fp)
 		return -ENODEV;
 	if (xchg(&dev_opened, 1))
 		return -EBUSY;
+
+	nonseekable_open(ip, fp);
 	return 0;
 }
 
@@ -62,6 +64,7 @@ static const struct file_operations synth_fops = {
 	.write = speakup_file_write,
 	.open = speakup_file_open,
 	.release = speakup_file_release,
+	.llseek = no_llseek,
 };
 
 static struct miscdevice synth_device = {
diff --git a/drivers/staging/speakup/speakup_soft.c b/drivers/staging/speakup/speakup_soft.c
index 2c85773..05c8006 100644
--- a/drivers/staging/speakup/speakup_soft.c
+++ b/drivers/staging/speakup/speakup_soft.c
@@ -305,6 +305,7 @@ static struct file_operations softsynth_fops = {
 	.read = softsynth_read,
 	.write = softsynth_write,
 	.open = softsynth_open,
+	.llseek = default_llseek,
 	.release = softsynth_close,
 };
 
diff --git a/drivers/usb/misc/yurex.c b/drivers/usb/misc/yurex.c
index 719c618..ac5bfd6 100644
--- a/drivers/usb/misc/yurex.c
+++ b/drivers/usb/misc/yurex.c
@@ -536,6 +536,7 @@ static const struct file_operations yurex_fops = {
 	.open =		yurex_open,
 	.release =	yurex_release,
 	.fasync	=	yurex_fasync,
+	.llseek =	default_llseek,
 };
 
 
