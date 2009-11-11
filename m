From: Dominik Brodowski <linux@dominikbrodowski.net>
Subject: [PATCH 08/13] pcmcia: Change window_handle_t logic to unsigned long
Date: Wed, 11 Nov 2009 21:38:14 +0100
Message-ID: <1257971899-9274-8-git-send-email-linux@dominikbrodowski.net>
References: <20091111203303.GA7939@comet.dominikbrodowski.net>
Cc: Magnus Damm <damm@opensource.se>, netdev@vger.kernel.org,
	Dominik Brodowski <linux@dominikbrodowski.net>
To: <linux-pcmcia@lists.infradead.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from isilmar.linta.de ([213.133.102.198]:47662 "EHLO linta.de"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1758877AbZKKUjB (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 11 Nov 2009 15:39:01 -0500
In-Reply-To: <20091111203303.GA7939@comet.dominikbrodowski.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Magnus Damm <damm@opensource.se>

Logic changes based on top of the other patches:

This set of patches changed window_handle_t from being a pointer to an
unsigned long. The unsigned long is now a simple index into socket->win[].
Going from a pointer to unsigned long should leave the user space interface
unchanged unless I'm mistaken.

This change results in code that is less error prone and a user space
interface which is much cleaner and safer. A nice side effect is that we
are also are able to remove all members except one from window_t.

[ linux@dominikbrodowski.net:
	Update to 2.6.31. Also, a plain "index" to socket->win[] does not
	work, as several codepaths rely on "window_handle_t" being
	non-zero if used. Therefore, set the window_handle_t to the
	socket->win[] index + 1. ]

CC: netdev@vger.kernel.org
Signed-off-by: Magnus Damm <damm@opensource.se>
Signed-off-by: Dominik Brodowski <linux@dominikbrodowski.net>
---
 drivers/net/pcmcia/pcnet_cs.c    |    2 +-
 drivers/pcmcia/cs_internal.h     |    4 +-
 drivers/pcmcia/pcmcia_ioctl.c    |    4 +-
 drivers/pcmcia/pcmcia_resource.c |   59 +++++++++++++++++++------------------
 include/pcmcia/cs_types.h        |    3 +-
 include/pcmcia/ss.h              |    5 ---
 6 files changed, 36 insertions(+), 41 deletions(-)

diff --git a/drivers/net/pcmcia/pcnet_cs.c b/drivers/net/pcmcia/pcnet_cs.c
index 75e6894..518b094 100644
--- a/drivers/net/pcmcia/pcnet_cs.c
+++ b/drivers/net/pcmcia/pcnet_cs.c
@@ -1514,7 +1514,7 @@ static int setup_shmem_window(struct pcmcia_device *link, int start_pg,
     if (i != (TX_PAGES<<8)) {
 	iounmap(info->base);
 	pcmcia_release_window(link, link->win);
-	info->base = NULL; link->win = NULL;
+	info->base = NULL; link->win = 0;
 	goto failed;
     }
 
diff --git a/drivers/pcmcia/cs_internal.h b/drivers/pcmcia/cs_internal.h
index 8e09a49..6df41de 100644
--- a/drivers/pcmcia/cs_internal.h
+++ b/drivers/pcmcia/cs_internal.h
@@ -149,8 +149,8 @@ extern struct list_head pcmcia_socket_list;
 extern struct class pcmcia_socket_class;
 
 int pcmcia_get_window(struct pcmcia_socket *s,
-		      window_handle_t *handle,
-		      int idx,
+		      window_handle_t *wh_out,
+		      window_handle_t wh,
 		      win_req_t *req);
 int pccard_register_pcmcia(struct pcmcia_socket *s, struct pcmcia_callback *c);
 struct pcmcia_socket *pcmcia_get_socket_by_nr(unsigned int nr);
diff --git a/drivers/pcmcia/pcmcia_ioctl.c b/drivers/pcmcia/pcmcia_ioctl.c
index c829ead..6245fde 100644
--- a/drivers/pcmcia/pcmcia_ioctl.c
+++ b/drivers/pcmcia/pcmcia_ioctl.c
@@ -916,12 +916,12 @@ static int ds_ioctl(struct inode * inode, struct file * file,
 	goto free_out;
 	break;
     case DS_GET_FIRST_WINDOW:
-	ret = pcmcia_get_window(s, &buf->win_info.handle, 0,
+	ret = pcmcia_get_window(s, &buf->win_info.handle, 1,
 			&buf->win_info.window);
 	break;
     case DS_GET_NEXT_WINDOW:
 	ret = pcmcia_get_window(s, &buf->win_info.handle,
-			buf->win_info.handle->index + 1, &buf->win_info.window);
+			buf->win_info.handle + 1, &buf->win_info.window);
 	break;
     case DS_GET_MEM_PAGE:
 	ret = pcmcia_get_mem_page(s, buf->win_info.handle,
diff --git a/drivers/pcmcia/pcmcia_resource.c b/drivers/pcmcia/pcmcia_resource.c
index a092749..25783d1 100644
--- a/drivers/pcmcia/pcmcia_resource.c
+++ b/drivers/pcmcia/pcmcia_resource.c
@@ -187,15 +187,19 @@ EXPORT_SYMBOL(pcmcia_access_configuration_register);
 
 /** pcmcia_get_window
  */
-int pcmcia_get_window(struct pcmcia_socket *s, window_handle_t *handle,
-		      int idx, win_req_t *req)
+int pcmcia_get_window(struct pcmcia_socket *s, window_handle_t *wh_out,
+		window_handle_t wh, win_req_t *req)
 {
 	window_t *win;
-	int w;
+	window_handle_t w;
 
 	if (!s || !(s->state & SOCKET_PRESENT))
 		return -ENODEV;
-	for (w = idx; w < MAX_WIN; w++)
+
+	wh--;
+	if (wh >= MAX_WIN)
+		return -EINVAL;
+	for (w = wh; w < MAX_WIN; w++)
 		if (s->state & SOCKET_WIN_REQ(w))
 			break;
 	if (w == MAX_WIN)
@@ -213,7 +217,8 @@ int pcmcia_get_window(struct pcmcia_socket *s, window_handle_t *handle,
 		req->Attributes |= WIN_DATA_WIDTH_16;
 	if (win->ctl.flags & MAP_USE_WAIT)
 		req->Attributes |= WIN_USE_WAIT;
-	*handle = win;
+
+	*wh_out = w++;
 	return 0;
 } /* pcmcia_get_window */
 EXPORT_SYMBOL(pcmcia_get_window);
@@ -226,12 +231,12 @@ EXPORT_SYMBOL(pcmcia_get_window);
 int pcmcia_get_mem_page(struct pcmcia_socket *skt, window_handle_t wh,
 			memreq_t *req)
 {
-	window_handle_t win = wh;
-
-	if ((win == NULL) || (win->magic != WINDOW_MAGIC))
+	wh--;
+	if (wh >= MAX_WIN)
 		return -EINVAL;
+
 	req->Page = 0;
-	req->CardOffset = win->ctl.card_start;
+	req->CardOffset = skt->win[wh].ctl.card_start;
 	return 0;
 } /* pcmcia_get_mem_page */
 EXPORT_SYMBOL(pcmcia_get_mem_page);
@@ -240,18 +245,17 @@ EXPORT_SYMBOL(pcmcia_get_mem_page);
 int pcmcia_map_mem_page(struct pcmcia_device *p_dev, window_handle_t wh,
 			memreq_t *req)
 {
-	struct pcmcia_socket *s;
-	window_handle_t win = wh;
+	struct pcmcia_socket *s = p_dev->socket;
 
-	if ((win == NULL) || (win->magic != WINDOW_MAGIC))
+	wh--;
+	if (wh >= MAX_WIN)
 		return -EINVAL;
-	s = win->sock;
 	if (req->Page != 0) {
 		dev_dbg(&s->dev, "failure: requested page is zero\n");
 		return -EINVAL;
 	}
-	win->ctl.card_start = req->CardOffset;
-	if (s->ops->set_mem_map(s, &win->ctl) != 0) {
+	s->win[wh].ctl.card_start = req->CardOffset;
+	if (s->ops->set_mem_map(s, &s->win[wh].ctl) != 0) {
 		dev_dbg(&s->dev, "failed to set_mem_map\n");
 		return -EIO;
 	}
@@ -450,13 +454,16 @@ static int pcmcia_release_irq(struct pcmcia_device *p_dev, irq_req_t *req)
 
 int pcmcia_release_window(struct pcmcia_device *p_dev, window_handle_t wh)
 {
-	struct pcmcia_socket *s;
-	window_handle_t win = wh;
+	struct pcmcia_socket *s = p_dev->socket;
+	window_t *win;
 
-	if ((win == NULL) || (win->magic != WINDOW_MAGIC))
+	wh--;
+	if (wh >= MAX_WIN)
 		return -EINVAL;
-	s = win->sock;
-	if (!(win->handle->_win & CLIENT_WIN_REQ(win->index))) {
+
+	win = &s->win[wh];
+
+	if (!(p_dev->_win & CLIENT_WIN_REQ(wh))) {
 		dev_dbg(&s->dev, "not releasing unknown window\n");
 		return -EINVAL;
 	}
@@ -464,7 +471,7 @@ int pcmcia_release_window(struct pcmcia_device *p_dev, window_handle_t wh)
 	/* Shut down memory window */
 	win->ctl.flags &= ~MAP_ACTIVE;
 	s->ops->set_mem_map(s, &win->ctl);
-	s->state &= ~SOCKET_WIN_REQ(win->index);
+	s->state &= ~SOCKET_WIN_REQ(wh);
 
 	/* Release system memory */
 	if (win->ctl.res) {
@@ -472,9 +479,7 @@ int pcmcia_release_window(struct pcmcia_device *p_dev, window_handle_t wh)
 		kfree(win->ctl.res);
 		win->ctl.res = NULL;
 	}
-	win->handle->_win &= ~CLIENT_WIN_REQ(win->index);
-
-	win->magic = 0;
+	p_dev->_win &= ~CLIENT_WIN_REQ(wh);
 
 	return 0;
 } /* pcmcia_release_window */
@@ -847,10 +852,6 @@ int pcmcia_request_window(struct pcmcia_device **p_dev, win_req_t *req, window_h
 	}
 
 	win = &s->win[w];
-	win->magic = WINDOW_MAGIC;
-	win->index = w;
-	win->handle = *p_dev;
-	win->sock = s;
 
 	if (!(s->features & SS_CAP_STATIC_MAP)) {
 		win->ctl.res = pcmcia_find_mem_region(req->Base, req->Size, align,
@@ -887,7 +888,7 @@ int pcmcia_request_window(struct pcmcia_device **p_dev, win_req_t *req, window_h
 	} else {
 		req->Base = win->ctl.res->start;
 	}
-	*wh = win;
+	*wh = w++;
 
 	return 0;
 } /* pcmcia_request_window */
diff --git a/include/pcmcia/cs_types.h b/include/pcmcia/cs_types.h
index 315965a..f5e3b83 100644
--- a/include/pcmcia/cs_types.h
+++ b/include/pcmcia/cs_types.h
@@ -26,8 +26,7 @@ typedef u_int	event_t;
 typedef u_char	cisdata_t;
 typedef u_short	page_t;
 
-struct window_t;
-typedef struct window_t *window_handle_t;
+typedef unsigned long window_handle_t;
 
 struct region_t;
 typedef struct region_t *memory_handle_t;
diff --git a/include/pcmcia/ss.h b/include/pcmcia/ss.h
index 753da9b..6301c3f 100644
--- a/include/pcmcia/ss.h
+++ b/include/pcmcia/ss.h
@@ -107,12 +107,7 @@ typedef struct io_window_t {
 	struct resource		*res;
 } io_window_t;
 
-#define WINDOW_MAGIC	0xB35C
 typedef struct window_t {
-	u_short			magic;
-	u_short			index;
-	struct pcmcia_device	*handle;
-	struct pcmcia_socket 	*sock;
 	pccard_mem_map		ctl;
 } window_t;
 
-- 
1.6.0.4

