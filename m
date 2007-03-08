From: Johannes Berg <johannes-cdvu00un1VgdHxzADdlk8Q@public.gmane.org>
Subject: Re: wireless extensions vs. 64-bit architectures
Date: Thu, 08 Mar 2007 18:37:07 +0100
Message-ID: <1173375427.3248.33.camel@johannes.berg>
References: <1173144447.15891.93.camel@johannes.berg>
	 <20070306171316.GA19669@bougret.hpl.hp.com>
	 <200703061943.07350.mb@bu3sch.de>
	 <20070307020310.GA20466@bougret.hpl.hp.com>
	 <1173364747.14001.7.camel@johannes.berg>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: Michael Buesch <mb-fseUSCV1ubazQB+pC5nmwQ@public.gmane.org>, linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	netdev <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, Jeff Garzik <jgarzik-e+AXbWqSrlAAvxtiuMwx3w@public.gmane.org>,
	Dan Williams <dcbw-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>,
	Jouni Malinen <jkm-r/za7OOdgF0ztatW0fm/fQ@public.gmane.org>
To: jt-sDzT885Ts8HQT0dZR+AlfA@public.gmane.org
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <1173364747.14001.7.camel-YfaajirXv214zXjbi5bjpg@public.gmane.org>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Thu, 2007-03-08 at 15:39 +0100, Johannes Berg wrote:

> Oh, btw, this also means that we have an information leak on 64-bit
> kernels. Those alignment bytes aren't ever cleared or anything, they
> come right from the stack since most users of this just use a struct
> iw_event on the stack which is then memcpy()ed right into the userspace
> buffer. For example those bytes 5 through 8 ("50:8A:35:E0") in the first
> buffer above. This is generally considered a security problem.

Patch below might fix it. If it does, please send it on to Linus (or
akpm), stable and whoever else might be interested in backporting it
(distros? or do they cherrypick from stable?)

I'm unable to test it as I'll be away from my only 64-bit machine for at
least until the 19th or 20th.

Yeah, I know sparse warns about this on 32-bit machines... But it seems
useless to try to fix that warning.

johannes

From: Johannes Berg <johannes-cdvu00un1VgdHxzADdlk8Q@public.gmane.org>
Subject: fix information leak in wireless extensions (on 64-bit architectures)

On 64-bit architectures wireless extensions leak information from the
kernel stack due to padding inside structs not being cleared before they
are copied to userspace.

This is available to unprivileged users since they can listen for
wireless events and obtain scan results.

This patch fixes it by explicitly clearing the padding.

Signed-off-by: Johannes Berg <johannes-cdvu00un1VgdHxzADdlk8Q@public.gmane.org>

---
 include/net/iw_handler.h |   20 ++++++++++++++++++++
 1 file changed, 20 insertions(+)

--- wireless-dev.orig/include/net/iw_handler.h	2007-03-08 18:17:43.384642258 +0100
+++ wireless-dev/include/net/iw_handler.h	2007-03-08 18:28:12.704642258 +0100
@@ -484,6 +484,9 @@ iwe_stream_add_event(char *	stream,		/* 
 		     struct iw_event *iwe,	/* Payload */
 		     int	event_len)	/* Real size of payload */
 {
+	/* clear padding */
+	memset((char*)iwe + 4, 0, IW_EV_LCP_LEN - 4);
+
 	/* Check if it's possible */
 	if(likely((stream + event_len) < ends)) {
 		iwe->len = event_len;
@@ -505,6 +508,10 @@ iwe_stream_add_point(char *	stream,		/* 
 		     char *	extra)		/* More payload */
 {
 	int	event_len = IW_EV_POINT_LEN + iwe->u.data.length;
+
+	/* clear padding */
+	memset((char*)iwe + 4, 0, IW_EV_LCP_LEN - 4);
+
 	/* Check if it's possible */
 	if(likely((stream + event_len) < ends)) {
 		iwe->len = event_len;
@@ -531,6 +538,9 @@ iwe_stream_add_value(char *	event,		/* E
 		     struct iw_event *iwe,	/* Payload */
 		     int	event_len)	/* Real size of payload */
 {
+	/* clear padding */
+	memset((char*)iwe + 4, 0, IW_EV_LCP_LEN - 4);
+
 	/* Don't duplicate LCP */
 	event_len -= IW_EV_LCP_LEN;
 
@@ -558,6 +568,9 @@ iwe_stream_check_add_event(char *	stream
 			   int		event_len,	/* Size of payload */
 			   int *	perr)		/* Error report */
 {
+	/* clear padding */
+	memset((char*)iwe + 4, 0, IW_EV_LCP_LEN - 4);
+
 	/* Check if it's possible, set error if not */
 	if(likely((stream + event_len) < ends)) {
 		iwe->len = event_len;
@@ -582,6 +595,10 @@ iwe_stream_check_add_point(char *	stream
 			   int *	perr)		/* Error report */
 {
 	int	event_len = IW_EV_POINT_LEN + iwe->u.data.length;
+
+	/* clear padding */
+	memset((char*)iwe + 4, 0, IW_EV_LCP_LEN - 4);
+
 	/* Check if it's possible */
 	if(likely((stream + event_len) < ends)) {
 		iwe->len = event_len;
@@ -611,6 +628,9 @@ iwe_stream_check_add_value(char *	event,
 			   int		event_len,	/* Size of payload */
 			   int *	perr)		/* Error report */
 {
+	/* clear padding */
+	memset((char*)iwe + 4, 0, IW_EV_LCP_LEN - 4);
+
 	/* Don't duplicate LCP */
 	event_len -= IW_EV_LCP_LEN;
 
