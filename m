From: Cong Wang <xiyou.wangcong@gmail.com>
Subject: [Patch net 14/15] selftests: Introduce a new script to generate tc batch file
Date: Mon, 23 Oct 2017 15:03:03 -0700
Message-ID: <20171023220304.2268-15-xiyou.wangcong@gmail.com>
References: <20171023220304.2268-1-xiyou.wangcong@gmail.com>
Cc: paulmck@linux.vnet.ibm.com, jhs@mojatatu.com,
        john.fastabend@gmail.com, Chris Mi <chrism@mellanox.com>,
        Cong Wang <xiyou.wangcong@gmail.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f68.google.com ([74.125.83.68]:43515 "EHLO
        mail-pg0-f68.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751677AbdJWWDt (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 23 Oct 2017 18:03:49 -0400
Received: by mail-pg0-f68.google.com with SMTP id s75so12840605pgs.0
        for <netdev@vger.kernel.org>; Mon, 23 Oct 2017 15:03:49 -0700 (PDT)
In-Reply-To: <20171023220304.2268-1-xiyou.wangcong@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Chris Mi <chrism@mellanox.com>

From: Chris Mi <chrism@mellanox.com>

  # ./tdc_batch.py -h
  usage: tdc_batch.py [-h] [-n NUMBER] [-o] [-s] [-p] device file

  TC batch file generator

  positional arguments:
    device                device name
    file                  batch file name

  optional arguments:
    -h, --help            show this help message and exit
    -n NUMBER, --number NUMBER
                          how many lines in batch file
    -o, --skip_sw         skip_sw (offload), by default skip_hw
    -s, --share_action    all filters share the same action
    -p, --prio            all filters have different prio

Acked-by: Jamal Hadi Salim <jhs@mojatatu.com>
Acked-by: Lucas Bates <lucasb@mojatatu.com>
Signed-off-by: Chris Mi <chrism@mellanox.com>
Signed-off-by: Cong Wang <xiyou.wangcong@gmail.com>
---
 tools/testing/selftests/tc-testing/tdc_batch.py | 62 +++++++++++++++++++++++++
 1 file changed, 62 insertions(+)
 create mode 100644 tools/testing/selftests/tc-testing/tdc_batch.py

diff --git a/tools/testing/selftests/tc-testing/tdc_batch.py b/tools/testing/selftests/tc-testing/tdc_batch.py
new file mode 100644
index 000000000000..707c6bfef689
--- /dev/null
+++ b/tools/testing/selftests/tc-testing/tdc_batch.py
@@ -0,0 +1,62 @@
+#!/usr/bin/python3
+
+"""
+tdc_batch.py - a script to generate TC batch file
+
+Copyright (C) 2017 Chris Mi <chrism@mellanox.com>
+"""
+
+import argparse
+
+parser = argparse.ArgumentParser(description='TC batch file generator')
+parser.add_argument("device", help="device name")
+parser.add_argument("file", help="batch file name")
+parser.add_argument("-n", "--number", type=int,
+                    help="how many lines in batch file")
+parser.add_argument("-o", "--skip_sw",
+                    help="skip_sw (offload), by default skip_hw",
+                    action="store_true")
+parser.add_argument("-s", "--share_action",
+                    help="all filters share the same action",
+                    action="store_true")
+parser.add_argument("-p", "--prio",
+                    help="all filters have different prio",
+                    action="store_true")
+args = parser.parse_args()
+
+device = args.device
+file = open(args.file, 'w')
+
+number = 1
+if args.number:
+    number = args.number
+
+skip = "skip_hw"
+if args.skip_sw:
+    skip = "skip_sw"
+
+share_action = ""
+if args.share_action:
+    share_action = "index 1"
+
+prio = "prio 1"
+if args.prio:
+    prio = ""
+    if number > 0x4000:
+        number = 0x4000
+
+index = 0
+for i in range(0x100):
+    for j in range(0x100):
+        for k in range(0x100):
+            mac = ("%02x:%02x:%02x" % (i, j, k))
+            src_mac = "e4:11:00:" + mac
+            dst_mac = "e4:12:00:" + mac
+            cmd = ("filter add dev %s %s protocol ip parent ffff: flower %s "
+                   "src_mac %s dst_mac %s action drop %s" %
+                   (device, prio, skip, src_mac, dst_mac, share_action))
+            file.write("%s\n" % cmd)
+            index += 1
+            if index >= number:
+                file.close()
+                exit(0)
-- 
2.13.0
