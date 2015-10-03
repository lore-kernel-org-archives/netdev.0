From: Christoph Hellwig <hch@lst.de>
Subject: [PATCH 08/23] usb-gadget/f_midi: use per-attribute show and store methods
Date: Sat,  3 Oct 2015 15:32:44 +0200
Message-ID: <1443879179-22280-9-git-send-email-hch@lst.de>
References: <1443879179-22280-1-git-send-email-hch@lst.de>
Cc: Felipe Balbi <balbi@ti.com>,
	Andrzej Pietrasiewicz <andrzej.p@samsung.com>,
	Tejun Heo <tj@kernel.org>,
	Pratyush Anand <pratyush.anand@gmail.com>,
	Pantelis Antoniou <pantelis.antoniou@konsulko.com>,
	target-devel@vger.kernel.org, cluster-devel@redhat.com,
	ocfs2-devel@oss.oracle.com, linux-usb@vger.kernel.org,
	netdev@vger.kernel.org
To: Joel Becker <jlbec@evilplan.org>,
	Andrew Morton <akpm@linux-foundation.org>,
	Nicholas Bellinger <nab@linux-iscsi.org>
Return-path: <target-devel-owner@vger.kernel.org>
In-Reply-To: <1443879179-22280-1-git-send-email-hch@lst.de>
Sender: target-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

To simplify the configfs interface and remove boilerplate code that also
causes binary bloat.

Signed-off-by: Christoph Hellwig <hch@lst.de>
Reviewed-by: Andrzej Pietrasiewicz <andrzej.p@samsung.com>
---
 drivers/usb/gadget/function/f_midi.c | 37 ++++++++++++++++--------------------
 1 file changed, 16 insertions(+), 21 deletions(-)

diff --git a/drivers/usb/gadget/function/f_midi.c b/drivers/usb/gadget/function/f_midi.c
index a287a48..0e2b8ed 100644
--- a/drivers/usb/gadget/function/f_midi.c
+++ b/drivers/usb/gadget/function/f_midi.c
@@ -906,9 +906,6 @@ static inline struct f_midi_opts *to_f_midi_opts(struct config_item *item)
 			    func_inst.group);
 }
 
-CONFIGFS_ATTR_STRUCT(f_midi_opts);
-CONFIGFS_ATTR_OPS(f_midi_opts);
-
 static void midi_attr_release(struct config_item *item)
 {
 	struct f_midi_opts *opts = to_f_midi_opts(item);
@@ -918,13 +915,12 @@ static void midi_attr_release(struct config_item *item)
 
 static struct configfs_item_operations midi_item_ops = {
 	.release	= midi_attr_release,
-	.show_attribute	= f_midi_opts_attr_show,
-	.store_attribute = f_midi_opts_attr_store,
 };
 
 #define F_MIDI_OPT(name, test_limit, limit)				\
-static ssize_t f_midi_opts_##name##_show(struct f_midi_opts *opts, char *page) \
+static ssize_t f_midi_opts_##name##_show(struct config_item *item, char *page) \
 {									\
+	struct f_midi_opts *opts = to_f_midi_opts(item);		\
 	int result;							\
 									\
 	mutex_lock(&opts->lock);					\
@@ -934,9 +930,10 @@ static ssize_t f_midi_opts_##name##_show(struct f_midi_opts *opts, char *page) \
 	return result;							\
 }									\
 									\
-static ssize_t f_midi_opts_##name##_store(struct f_midi_opts *opts,	\
+static ssize_t f_midi_opts_##name##_store(struct config_item *item,	\
 					 const char *page, size_t len)	\
 {									\
+	struct f_midi_opts *opts = to_f_midi_opts(item);		\
 	int ret;							\
 	u32 num;							\
 									\
@@ -962,9 +959,7 @@ end:									\
 	return ret;							\
 }									\
 									\
-static struct f_midi_opts_attribute f_midi_opts_##name =		\
-	__CONFIGFS_ATTR(name, S_IRUGO | S_IWUSR, f_midi_opts_##name##_show, \
-			f_midi_opts_##name##_store)
+CONFIGFS_ATTR(f_midi_opts_, name);
 
 F_MIDI_OPT(index, true, SNDRV_CARDS);
 F_MIDI_OPT(buflen, false, 0);
@@ -972,8 +967,9 @@ F_MIDI_OPT(qlen, false, 0);
 F_MIDI_OPT(in_ports, true, MAX_PORTS);
 F_MIDI_OPT(out_ports, true, MAX_PORTS);
 
-static ssize_t f_midi_opts_id_show(struct f_midi_opts *opts, char *page)
+static ssize_t f_midi_opts_id_show(struct config_item *item, char *page)
 {
+	struct f_midi_opts *opts = to_f_midi_opts(item);
 	int result;
 
 	mutex_lock(&opts->lock);
@@ -989,9 +985,10 @@ static ssize_t f_midi_opts_id_show(struct f_midi_opts *opts, char *page)
 	return result;
 }
 
-static ssize_t f_midi_opts_id_store(struct f_midi_opts *opts,
+static ssize_t f_midi_opts_id_store(struct config_item *item,
 				    const char *page, size_t len)
 {
+	struct f_midi_opts *opts = to_f_midi_opts(item);
 	int ret;
 	char *c;
 
@@ -1016,17 +1013,15 @@ end:
 	return ret;
 }
 
-static struct f_midi_opts_attribute f_midi_opts_id =
-	__CONFIGFS_ATTR(id, S_IRUGO | S_IWUSR, f_midi_opts_id_show,
-			f_midi_opts_id_store);
+CONFIGFS_ATTR(f_midi_opts_, id);
 
 static struct configfs_attribute *midi_attrs[] = {
-	&f_midi_opts_index.attr,
-	&f_midi_opts_buflen.attr,
-	&f_midi_opts_qlen.attr,
-	&f_midi_opts_in_ports.attr,
-	&f_midi_opts_out_ports.attr,
-	&f_midi_opts_id.attr,
+	&f_midi_opts_attr_index,
+	&f_midi_opts_attr_buflen,
+	&f_midi_opts_attr_qlen,
+	&f_midi_opts_attr_in_ports,
+	&f_midi_opts_attr_out_ports,
+	&f_midi_opts_attr_id,
 	NULL,
 };
 
-- 
1.9.1
