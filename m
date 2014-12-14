From: Vadim Kochan <vadim4j@gmail.com>
Subject: [PATCH iproute2 REGRESSION] ss: Dont show netlink and packet sockets by default
Date: Sun, 14 Dec 2014 11:36:05 +0200
Message-ID: <1418549765-9466-1-git-send-email-vadim4j@gmail.com>
Cc: Vadim Kochan <vadim4j@gmail.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-la0-f44.google.com ([209.85.215.44]:44557 "EHLO
	mail-la0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751103AbaLNJqB (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 14 Dec 2014 04:46:01 -0500
Received: by mail-la0-f44.google.com with SMTP id gd6so8190443lab.3
        for <netdev@vger.kernel.org>; Sun, 14 Dec 2014 01:45:59 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Vadim Kochan <vadim4j@gmail.com>

Checking by SS_CLOSE state was remowed in:

    (45a4770bc0) ss: Remove checking SS_CLOSE state for packet and netlink

which is not really correct because now by default all sockets are seen
when do 'ss'.

Here is most correct fix which considers specified family.

To see netlink sockets:
    ss -A netlink

To see packet sockets:
    ss -A packet

And ss by default will show only connected/established sockets as it
was before all the time.

Signed-off-by: Vadim Kochan <vadim4j@gmail.com>
---
 misc/ss.c | 6 ++++++
 1 file changed, 6 insertions(+)

diff --git a/misc/ss.c b/misc/ss.c
index e9927a5..6050ab6 100644
--- a/misc/ss.c
+++ b/misc/ss.c
@@ -2801,6 +2801,9 @@ static int packet_show(struct filter *f)
 	int ino;
 	unsigned long long sk;
 
+	if (preferred_family != AF_PACKET && !(f->states & (1<<SS_CLOSE)))
+		return 0;
+
 	if (packet_show_netlink(f, NULL) == 0)
 		return 0;
 
@@ -3028,6 +3031,9 @@ static int netlink_show(struct filter *f)
 	int rq, wq, rc;
 	unsigned long long sk, cb;
 
+	if (preferred_family != AF_NETLINK && !(f->states & (1<<SS_CLOSE)))
+		return 0;
+
 	if (!getenv("PROC_NET_NETLINK") && !getenv("PROC_ROOT") &&
 		netlink_show_netlink(f, NULL) == 0)
 		return 0;
-- 
2.1.3
