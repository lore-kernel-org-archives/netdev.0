From: Devendra Naga <devendra.aaru@gmail.com>
Subject: [PATCH] bridge-utils: fix AF_LOCAL socket leaks
Date: Thu,  4 Apr 2013 17:06:26 +0530
Message-ID: <1365075386-2363-1-git-send-email-devendra.aaru@gmail.com>
Cc: Devendra Naga <devendra.aaru@gmail.com>
To: Stephen Hemminger <shemminger@vyatta.com>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pb0-f43.google.com ([209.85.160.43]:49579 "EHLO
	mail-pb0-f43.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758670Ab3DDLgh (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 4 Apr 2013 07:36:37 -0400
Received: by mail-pb0-f43.google.com with SMTP id md4so1399548pbc.16
        for <netdev@vger.kernel.org>; Thu, 04 Apr 2013 04:36:37 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

valgrind reported the following leak on fc18 system:

valgrind -v --leak-check=full --track-fds=yes ./brctl show

==27307==
==27307== FILE DESCRIPTORS: 4 open at exit.
==27307== Open AF_UNIX socket 3: <unknown>
==27307==    at 0x397B2F3617: socket (in /usr/lib64/libc-2.16.so)
==27307==    by 0x403CF7: br_init (libbridge_init.c:35)
==27307==    by 0x4010BF: main (brctl.c:63)

fix it by calling br_shutdown

Signed-off-by: Devendra Naga <devendra.aaru@gmail.com>
---
 brctl/brctl.c | 6 +++++-
 1 file changed, 5 insertions(+), 1 deletion(-)

diff --git a/brctl/brctl.c b/brctl/brctl.c
index 46ca352..16080a7 100644
--- a/brctl/brctl.c
+++ b/brctl/brctl.c
@@ -43,6 +43,7 @@ int main(int argc, char *const* argv)
 		{ .name = "version", .val = 'V' },
 		{ 0 }
 	};
+	int ret;
 
 	while ((f = getopt_long(argc, argv, "Vh", options, NULL)) != EOF) 
 		switch(f) {
@@ -79,7 +80,10 @@ int main(int argc, char *const* argv)
 		return 1;
 	}
 
-	return cmd->func(argc, argv);
+	ret = cmd->func(argc, argv);
+	br_shutdown();
+
+	return ret;
 
 help:
 	help();
-- 
1.8.1.4
