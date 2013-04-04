From: Devendra Naga <devendra.aaru@gmail.com>
Subject: [PATCH V2] bridge-utils: fix AF_LOCAL socket leaks
Date: Thu,  4 Apr 2013 17:14:19 +0530
Message-ID: <1365075859-8767-1-git-send-email-devendra.aaru@gmail.com>
Cc: Devendra Naga <devendra.aaru@gmail.com>
To: Stephen Hemminger <shemminger@vyatta.com>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f180.google.com ([209.85.192.180]:53777 "EHLO
	mail-pd0-f180.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758321Ab3DDLo3 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 4 Apr 2013 07:44:29 -0400
Received: by mail-pd0-f180.google.com with SMTP id q11so1388834pdj.11
        for <netdev@vger.kernel.org>; Thu, 04 Apr 2013 04:44:29 -0700 (PDT)
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

the same leak may occur if the command is ./brctl addbr or ./brctl delbr
because the goto directly goes to help() rather closing it.

Signed-off-by: Devendra Naga <devendra.aaru@gmail.com>
---
 brctl/brctl.c | 7 ++++++-
 1 file changed, 6 insertions(+), 1 deletion(-)

diff --git a/brctl/brctl.c b/brctl/brctl.c
index 46ca352..84b7536 100644
--- a/brctl/brctl.c
+++ b/brctl/brctl.c
@@ -43,6 +43,7 @@ int main(int argc, char *const* argv)
 		{ .name = "version", .val = 'V' },
 		{ 0 }
 	};
+	int ret;
 
 	while ((f = getopt_long(argc, argv, "Vh", options, NULL)) != EOF) 
 		switch(f) {
@@ -79,9 +80,13 @@ int main(int argc, char *const* argv)
 		return 1;
 	}
 
-	return cmd->func(argc, argv);
+	ret = cmd->func(argc, argv);
+	br_shutdown();
+
+	return ret;
 
 help:
+	br_shutdown();
 	help();
 	return 1;
 }
-- 
1.8.1.4
