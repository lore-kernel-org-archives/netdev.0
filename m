From: Gautam Kachroo <gk@aristanetworks.com>
Subject: [PATCH] iproute2 flush: handle larger tables and deleted entries
Date: Mon, 13 Jul 2009 09:39:56 -0700
Message-ID: <4e0db5bc0907130939k48b16256j8f60c786a7e5e44c@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from wf-out-1314.google.com ([209.85.200.169]:60407 "EHLO
	wf-out-1314.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752249AbZGMQj5 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 13 Jul 2009 12:39:57 -0400
Received: by wf-out-1314.google.com with SMTP id 26so798243wfd.4
        for <netdev@vger.kernel.org>; Mon, 13 Jul 2009 09:39:56 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

use a new netlink socket when sending flush messages to avoid reading
any pending data on the existing netlink socket.

read all of the response from the netlink request -- this response can
be split over multiple recv calls, pretty much one per netlink request
message. ENOENT errors, which correspond to attempts to delete an
already deleted entry, are ignored. Other errors are not ignored.

Signed-off-by: Gautam Kachroo <gk@aristanetworks.com>
---

resending in plain text format

rtnl_send_check calls recv after sending the delete messages. It does
this to catch errors, e.g. user doesn't have permissions to send
netlink messages. It treats *any* response as an error, even if the
message is not an NLMSG_ERROR. However, this doesn't work if the dump
is in the middle of being processed. recv will return the next chunk
of the dump. This was causing the flush operation to bail early, e.g.
when there is a large arp cache.

Ignoring ENOENT lets flush succeed even if entries have been deleted
from underneath the flush.


--- a/lib/libnetlink.c
+++ b/lib/libnetlink.c
@@ -111,7 +111,10 @@ int rtnl_send(struct rtnl_handle *rth, const char
*buf, int len)
        return send(rth->fd, buf, len, 0);
 }

-int rtnl_send_check(struct rtnl_handle *rth, const char *buf, int len)
+/* send the message in buf using the socket in rth and check for errors
+   (ignoring ENOENT errors)
+*/
+int rtnl_send_check_impl(struct rtnl_handle *rth, const char *buf, int len)
 {
        struct nlmsghdr *h;
        int status;
@@ -122,28 +125,51 @@ int rtnl_send_check(struct rtnl_handle *rth,
const char *buf, int len)
                return status;

        /* Check for errors */
-       status = recv(rth->fd, resp, sizeof(resp), MSG_DONTWAIT);
-       if (status < 0) {
-               if (errno == EAGAIN)
-                       return 0;
-               return -1;
-       }
+       for (;;) {
+               status = recv(rth->fd, resp, sizeof(resp), MSG_DONTWAIT);
+               if (status < 0) {
+                       if (errno == EAGAIN)
+                               return 0;
+                       return -1;
+               }

-       for (h = (struct nlmsghdr *)resp; NLMSG_OK(h, status);
-            h = NLMSG_NEXT(h, status)) {
-               if (h->nlmsg_type == NLMSG_ERROR) {
-                       struct nlmsgerr *err = (struct nlmsgerr*)NLMSG_DATA(h);
-                       if (h->nlmsg_len < NLMSG_LENGTH(sizeof(struct
nlmsgerr)))
-                               fprintf(stderr, "ERROR truncated\n");
-                       else
-                               errno = -err->error;
+               for (h = (struct nlmsghdr *)resp; NLMSG_OK(h, status);
+                    h = NLMSG_NEXT(h, status)) {
+                       if (h->nlmsg_type == NLMSG_ERROR) {
+                               struct nlmsgerr *err = (struct
nlmsgerr*)NLMSG_DATA(h);
+                               if (h->nlmsg_len <
NLMSG_LENGTH(sizeof(struct nlmsgerr))) {
+                                       fprintf(stderr, "ERROR truncated\n");
+                                       return -1;
+                               }
+                               else {
+                                       if (err->error != -ENOENT) {
+                                               errno = -err->error;
+                                               return -1;
+                                       }
+                               }
+                       }
                }
-               return -1;
        }

        return 0;
 }

+/* creates a netlink socket and passes it to rtnl_send_check_impl to send the
+   message in buf
+*/
+int rtnl_send_check(struct rtnl_handle *unused, const char *buf, int len)
+{
+       struct rtnl_handle rth = { .fd = -1 };
+       int ret;
+       if (rtnl_open(&rth, 0) < 0) {
+               fprintf(stderr, "Cannot open rtnetlink\n");
+               return -1;
+       }
+       ret = rtnl_send_check_impl(&rth, buf, len);
+       rtnl_close(&rth);
+       return ret;
+}
+
 int rtnl_dump_request(struct rtnl_handle *rth, int type, void *req, int len)
 {
        struct nlmsghdr nlh;
