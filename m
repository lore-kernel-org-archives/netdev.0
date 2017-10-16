From: Chris Mi <chrism@mellanox.com>
Subject: [patch net 4/4] selftests: Introduce a new test case to tc testsuite
Date: Mon, 16 Oct 2017 04:31:42 -0400
Message-ID: <1508142702-3312-5-git-send-email-chrism@mellanox.com>
References: <1508142702-3312-1-git-send-email-chrism@mellanox.com>
Cc: jhs@mojatatu.com, lucasb@mojatatu.com, xiyou.wangcong@gmail.com,
        jiri@resnulli.us, davem@davemloft.net
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-il-dmz.mellanox.com ([193.47.165.129]:50134 "EHLO
        mellanox.co.il" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
        with ESMTP id S1751891AbdJPIb6 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 16 Oct 2017 04:31:58 -0400
In-Reply-To: <1508142702-3312-1-git-send-email-chrism@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

In this patchset, we fixed a tc bug. This patch adds the test case
that reproduces the bug. To run this test case, user should specify
an existing NIC device:
  # sudo ./tdc.py -d enp4s0f0

This test case belongs to category "flower". If user doesn't specify
a NIC device, the test cases belong to "flower" will not be run.

In this test case, we create 1M filters and all filters share the same
action. When destroying all filters, kernel should not panic. It takes
about 18s to run it.

Signed-off-by: Chris Mi <chrism@mellanox.com>
---
 .../tc-testing/tc-tests/filters/tests.json         | 23 +++++++++++++++++++++-
 tools/testing/selftests/tc-testing/tdc.py          | 20 +++++++++++++++----
 tools/testing/selftests/tc-testing/tdc_config.py   |  2 ++
 3 files changed, 40 insertions(+), 5 deletions(-)

diff --git a/tools/testing/selftests/tc-testing/tc-tests/filters/tests.json b/tools/testing/selftests/tc-testing/tc-tests/filters/tests.json
index c727b96..5fa02d8 100644
--- a/tools/testing/selftests/tc-testing/tc-tests/filters/tests.json
+++ b/tools/testing/selftests/tc-testing/tc-tests/filters/tests.json
@@ -17,5 +17,26 @@
         "teardown": [
             "$TC qdisc del dev $DEV1 ingress"
         ]
+    },
+    {
+        "id": "d052",
+        "name": "Add 1M filters with the same action",
+        "category": [
+            "filter",
+            "flower"
+        ],
+        "setup": [
+            "$TC qdisc add dev $DEV2 ingress",
+            "./tdc_batch.py $DEV2 $BATCH_FILE --share_action -n 1000000"
+        ],
+        "cmdUnderTest": "$TC -b $BATCH_FILE",
+        "expExitCode": "0",
+        "verifyCmd": "$TC actions list action gact",
+        "matchPattern": "action order 0: gact action drop.*index 1 ref 1000000 bind 1000000",
+        "matchCount": "1",
+        "teardown": [
+            "$TC qdisc del dev $DEV2 ingress",
+            "/bin/rm $BATCH_FILE"
+        ]
     }
-]
\ No newline at end of file
+]
diff --git a/tools/testing/selftests/tc-testing/tdc.py b/tools/testing/selftests/tc-testing/tdc.py
index cd61b78..5f11f5d 100755
--- a/tools/testing/selftests/tc-testing/tdc.py
+++ b/tools/testing/selftests/tc-testing/tdc.py
@@ -88,7 +88,7 @@ def prepare_env(cmdlist):
             exit(1)
 
 
-def test_runner(filtered_tests):
+def test_runner(filtered_tests, args):
     """
     Driver function for the unit tests.
 
@@ -105,6 +105,8 @@ def test_runner(filtered_tests):
     for tidx in testlist:
         result = True
         tresult = ""
+        if "flower" in tidx["category"] and args.device == None:
+            continue
         print("Test " + tidx["id"] + ": " + tidx["name"])
         prepare_env(tidx["setup"])
         (p, procout) = exec_cmd(tidx["cmdUnderTest"])
@@ -152,6 +154,10 @@ def ns_create():
         exec_cmd(cmd, False)
         cmd = 'ip -s $NS link set $DEV1 up'
         exec_cmd(cmd, False)
+        cmd = 'ip link set $DEV2 netns $NS'
+        exec_cmd(cmd, False)
+        cmd = 'ip -s $NS link set $DEV2 up'
+        exec_cmd(cmd, False)
 
 
 def ns_destroy():
@@ -211,7 +217,8 @@ def set_args(parser):
                         help='Execute the single test case with specified ID')
     parser.add_argument('-i', '--id', action='store_true', dest='gen_id',
                         help='Generate ID numbers for new test cases')
-    return parser
+    parser.add_argument('-d', '--device',
+                        help='Execute the test case in flower category')
     return parser
 
 
@@ -225,6 +232,8 @@ def check_default_settings(args):
 
     if args.path != None:
          NAMES['TC'] = args.path
+    if args.device != None:
+         NAMES['DEV2'] = args.device
     if not os.path.isfile(NAMES['TC']):
         print("The specified tc path " + NAMES['TC'] + " does not exist.")
         exit(1)
@@ -381,14 +390,17 @@ def set_operation_mode(args):
             if (len(alltests) == 0):
                 print("Cannot find a test case with ID matching " + target_id)
                 exit(1)
-        catresults = test_runner(alltests)
+        catresults = test_runner(alltests, args)
         print("All test results: " + "\n\n" + catresults)
     elif (len(target_category) > 0):
+        if (target_category == "flower") and args.device == None:
+            print("Please specify a NIC device (-d) to run category flower")
+            exit(1)
         if (target_category not in ucat):
             print("Specified category is not present in this file.")
             exit(1)
         else:
-            catresults = test_runner(testcases[target_category])
+            catresults = test_runner(testcases[target_category], args)
             print("Category " + target_category + "\n\n" + catresults)
 
     ns_destroy()
diff --git a/tools/testing/selftests/tc-testing/tdc_config.py b/tools/testing/selftests/tc-testing/tdc_config.py
index 0108737..b635251 100644
--- a/tools/testing/selftests/tc-testing/tdc_config.py
+++ b/tools/testing/selftests/tc-testing/tdc_config.py
@@ -12,6 +12,8 @@ NAMES = {
           # Name of veth devices to be created for the namespace
           'DEV0': 'v0p0',
           'DEV1': 'v0p1',
+          'DEV2': '',
+          'BATCH_FILE': './batch.txt',
           # Name of the namespace to use
           'NS': 'tcut'
         }
-- 
1.8.3.1
