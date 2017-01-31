From: Andy Zhou <azhou@ovn.org>
Subject: [userspace meter v3 1/5] netdev-dummy: Add --len option for netdev-dummy/receive command
Date: Mon, 30 Jan 2017 22:39:56 -0800
Message-ID: <1485844800-2873-2-git-send-email-azhou@ovn.org>
References: <1485844800-2873-1-git-send-email-azhou@ovn.org>
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 8bit
Cc: netdev@vger.kernel.org, Andy Zhou <azhou@ovn.org>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f193.google.com ([209.85.192.193]:33063 "EHLO
        mail-pf0-f193.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751027AbdAaHBk (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 31 Jan 2017 02:01:40 -0500
Received: by mail-pf0-f193.google.com with SMTP id e4so26265902pfg.0
        for <netdev@vger.kernel.org>; Mon, 30 Jan 2017 23:01:40 -0800 (PST)
In-Reply-To: <1485844800-2873-1-git-send-email-azhou@ovn.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Currently, there is no way to specify the packet size when injecting
a packet via "netdev-dummy/receive" with a flow specification. Thus
far, packet size is not important for testing OVS features, but it
becomes useful in writing unit tests for the meter implementation
in a later patch.

Signed-off-by: Andy Zhou <azhou@ovn.org>
---
 lib/netdev-dummy.c | 38 ++++++++++++++++++++++++++++----------
 1 file changed, 28 insertions(+), 10 deletions(-)

diff --git a/lib/netdev-dummy.c b/lib/netdev-dummy.c
index e6e36cd..10df0a7 100644
--- a/lib/netdev-dummy.c
+++ b/lib/netdev-dummy.c
@@ -1,5 +1,5 @@
 /*
- * Copyright (c) 2010, 2011, 2012, 2013, 2015, 2016 Nicira, Inc.
+ * Copyright (c) 2010, 2011, 2012, 2013, 2015, 2016, 2017 Nicira, Inc.
  *
  * Licensed under the Apache License, Version 2.0 (the "License");
  * you may not use this file except in compliance with the License.
@@ -1433,7 +1433,15 @@ pkt_list_delete(struct ovs_list *l)
 }
 
 static struct dp_packet *
-eth_from_packet_or_flow(const char *s)
+eth_from_packet(const char *s)
+{
+    struct dp_packet *packet;
+    eth_from_hex(s, &packet);
+    return packet;
+}
+
+static struct dp_packet *
+eth_from_flow(const char *s)
 {
     enum odp_key_fitness fitness;
     struct dp_packet *packet;
@@ -1441,10 +1449,6 @@ eth_from_packet_or_flow(const char *s)
     struct flow flow;
     int error;
 
-    if (!eth_from_hex(s, &packet)) {
-        return packet;
-    }
-
     /* Convert string to datapath key.
      *
      * It would actually be nicer to parse an OpenFlow-like flow key here, but
@@ -1540,10 +1544,24 @@ netdev_dummy_receive(struct unixctl_conn *conn,
     for (i = k; i < argc; i++) {
         struct dp_packet *packet;
 
-        packet = eth_from_packet_or_flow(argv[i]);
+        /* Try to parse 'argv[i]' as packet in hex. */
+        packet = eth_from_packet(argv[i]);
+
         if (!packet) {
-            unixctl_command_reply_error(conn, "bad packet syntax");
-            goto exit;
+            /* Try parse 'argv[i]' as odp flow. */
+            packet = eth_from_flow(argv[i]);
+
+            if (!packet) {
+                unixctl_command_reply_error(conn, "bad packet or flow syntax");
+                goto exit;
+            }
+
+            /* Parse optional --len argument immediately follow a 'flow'.  */
+            if (argc >= i + 2 && !strcmp(argv[i + 1], "--len")) {
+                int packet_size = strtol(argv[i + 2], NULL, 10);
+                dp_packet_set_size(packet, packet_size);
+                i+=2;
+            }
         }
 
         netdev_dummy_queue_packet(dummy_dev, packet, rx_qid);
@@ -1757,7 +1775,7 @@ void
 netdev_dummy_register(enum dummy_level level)
 {
     unixctl_command_register("netdev-dummy/receive",
-                             "name [--qid queue_id] packet|flow...",
+                             "name [--qid queue_id] packet|flow [--len packet len]..",
                              2, INT_MAX, netdev_dummy_receive, NULL);
     unixctl_command_register("netdev-dummy/set-admin-state",
                              "[netdev] up|down", 1, 2,
-- 
1.9.1
