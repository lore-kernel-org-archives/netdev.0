From: Larry Finger <larry.finger-tQ5ms3gMjBLk1uMJSBkQmQ@public.gmane.org>
Subject: Re: net-2.6.24 - build failure
Date: Wed, 19 Sep 2007 19:11:19 -0500
Message-ID: <46F1BAA7.9080701@lwfinger.net>
References: <1190238802.26101.24.camel@localhost> <20070919.151712.66176476.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: joe-6d6DIl74uiNBDgjK7y7TUQ@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <20070919.151712.66176476.davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

David Miller wrote:
> From: Joe Perches <joe-6d6DIl74uiNBDgjK7y7TUQ@public.gmane.org>
> Date: Wed, 19 Sep 2007 14:53:22 -0700
> 
>> drivers/net/wireless/b43legacy/built-in.o: In function `tsf_read_file':
>> drivers/net/wireless/b43legacy/debugfs.c:80: multiple definition of `tsf_read_file'
> 
> Can one of the wireless folks fix b43legacy to not use the same
> global variable and function names as the b43 driver?
> 

David,

The patch below was sent to John Linville yesterday. Obviously, it didn't get included before he
pushed to you. With this patch, all the debugfs names become static, and avoid the namespace clash
with b43. In addition, Michael Buesch has a similar patch pending for b43.

Larry
========================================

There are additional sparse warnings in b43legacy. None of them result
in program errors, but are fixed for completeness.

Signed-off-by: Larry Finger <Larry.Finger-tQ5ms3gMjBLk1uMJSBkQmQ@public.gmane.org>
---

 drivers/net/wireless/b43legacy/debugfs.c |   14 +++++++-------
 drivers/net/wireless/b43legacy/pio.c     |    6 +++---
 2 files changed, 10 insertions(+), 10 deletions(-)

Index: wireless-dev/drivers/net/wireless/b43legacy/debugfs.c
===================================================================
--- wireless-dev.orig/drivers/net/wireless/b43legacy/debugfs.c
+++ wireless-dev/drivers/net/wireless/b43legacy/debugfs.c
@@ -39,7 +39,7 @@


 /* The root directory. */
-struct dentry *rootdir;
+static struct dentry *rootdir;

 struct b43legacy_debugfs_fops {
 	ssize_t (*read)(struct b43legacy_wldev *dev, char *buf, size_t bufsize);
@@ -76,7 +76,7 @@ struct b43legacy_dfs_file * fops_to_dfs_


 /* wl->irq_lock is locked */
-ssize_t tsf_read_file(struct b43legacy_wldev *dev, char *buf, size_t bufsize)
+static ssize_t tsf_read_file(struct b43legacy_wldev *dev, char *buf, size_t bufsize)
 {
 	ssize_t count = 0;
 	u64 tsf;
@@ -90,7 +90,7 @@ ssize_t tsf_read_file(struct b43legacy_w
 }

 /* wl->irq_lock is locked */
-int tsf_write_file(struct b43legacy_wldev *dev, const char *buf, size_t count)
+static int tsf_write_file(struct b43legacy_wldev *dev, const char *buf, size_t count)
 {
 	u64 tsf;

@@ -102,7 +102,7 @@ int tsf_write_file(struct b43legacy_wlde
 }

 /* wl->irq_lock is locked */
-ssize_t ucode_regs_read_file(struct b43legacy_wldev *dev, char *buf, size_t bufsize)
+static ssize_t ucode_regs_read_file(struct b43legacy_wldev *dev, char *buf, size_t bufsize)
 {
 	ssize_t count = 0;
 	int i;
@@ -116,7 +116,7 @@ ssize_t ucode_regs_read_file(struct b43l
 }

 /* wl->irq_lock is locked */
-ssize_t shm_read_file(struct b43legacy_wldev *dev, char *buf, size_t bufsize)
+static ssize_t shm_read_file(struct b43legacy_wldev *dev, char *buf, size_t bufsize)
 {
 	ssize_t count = 0;
 	int i;
@@ -135,7 +135,7 @@ ssize_t shm_read_file(struct b43legacy_w
 	return count;
 }

-ssize_t txstat_read_file(struct b43legacy_wldev *dev, char *buf, size_t bufsize)
+static ssize_t txstat_read_file(struct b43legacy_wldev *dev, char *buf, size_t bufsize)
 {
 	struct b43legacy_txstatus_log *log = &dev->dfsentry->txstatlog;
 	ssize_t count = 0;
@@ -183,7 +183,7 @@ out_unlock:
 }

 /* wl->irq_lock is locked */
-int restart_write_file(struct b43legacy_wldev *dev, const char *buf, size_t count)
+static int restart_write_file(struct b43legacy_wldev *dev, const char *buf, size_t count)
 {
 	int err = 0;

Index: wireless-dev/drivers/net/wireless/b43legacy/pio.c
===================================================================
--- wireless-dev.orig/drivers/net/wireless/b43legacy/pio.c
+++ wireless-dev/drivers/net/wireless/b43legacy/pio.c
@@ -66,7 +66,7 @@ static u16 tx_get_next_word(const u8 *tx
 		source = packet;
 		i -= txhdr_size;
 	}
-	ret = le16_to_cpu(*((u16 *)(source + i)));
+	ret = le16_to_cpu(*((__le16 *)(source + i)));
 	*pos += 2;

 	return ret;
@@ -539,7 +539,7 @@ static void pio_rx_error(struct b43legac

 void b43legacy_pio_rx(struct b43legacy_pioqueue *queue)
 {
-	u16 preamble[21] = { 0 };
+	__le16 preamble[21] = { 0 };
 	struct b43legacy_rxhdr_fw3 *rxhdr;
 	u16 tmp;
 	u16 len;
@@ -609,7 +609,7 @@ data_ready:
 	skb_put(skb, len);
 	for (i = 0; i < len - 1; i += 2) {
 		tmp = b43legacy_pio_read(queue, B43legacy_PIO_RXDATA);
-		*((u16 *)(skb->data + i)) = cpu_to_le16(tmp);
+		*((__le16 *)(skb->data + i)) = cpu_to_le16(tmp);
 	}
 	if (len % 2) {
 		tmp = b43legacy_pio_read(queue, B43legacy_PIO_RXDATA);

-------
