From: "Brenda J. Butler" <bjb@mojatatu.com>
Subject: [PATCH net-next] tc-testing: better test case file error reporting
Date: Tue, 31 Oct 2017 14:29:03 -0400
Message-ID: <20171031182903.9885-1-bjb@mojatatu.com>
Cc: jhs@mojatatu.com, xiyou.wangcong@gmail.com, jiri@resnulli.us,
        chrism@mellanox.com, lucasb@mojatatu.com, aring@mojatatu.com,
        mrv@mojatatu.com, netdev@vger.kernel.org,
        "Brenda J. Butler" <bjb@mojatatu.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-io0-f176.google.com ([209.85.223.176]:46972 "EHLO
        mail-io0-f176.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S932652AbdJaS3J (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 31 Oct 2017 14:29:09 -0400
Received: by mail-io0-f176.google.com with SMTP id 101so862385ioj.3
        for <netdev@vger.kernel.org>; Tue, 31 Oct 2017 11:29:09 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

tdc.py reads a bunch of test cases in json files.  When a json file
cannot be parsed, tdc just exits and does not run any tests.

This patch will cause tdc to print a message with the file name and
line number, then that file will be ignored and the rest of the tests
will be processed.

Signed-off-by: Brenda J. Butler <bjb@mojatatu.com>
---
 tools/testing/selftests/tc-testing/tdc.py | 23 ++++++++++++++---------
 1 file changed, 14 insertions(+), 9 deletions(-)

diff --git a/tools/testing/selftests/tc-testing/tdc.py b/tools/testing/selftests/tc-testing/tdc.py
index 5508730ee1ea..a674fe9a7f1e 100755
--- a/tools/testing/selftests/tc-testing/tdc.py
+++ b/tools/testing/selftests/tc-testing/tdc.py
@@ -179,15 +179,20 @@ def has_blank_ids(idlist):
 
 def load_from_file(filename):
     """
-    Open the JSON file containing the test cases and return them as an
-    ordered dictionary object.
-    """
-    with open(filename) as test_data:
-        testlist = json.load(test_data, object_pairs_hook=OrderedDict)
-    idlist = get_id_list(testlist)
-    if (has_blank_ids(idlist)):
-        for k in testlist:
-            k['filename'] = filename
+    Open the JSON file containing the test cases and return them
+    as list of ordered dictionary objects.
+    """
+    try:
+        with open(filename) as test_data:
+            testlist = json.load(test_data, object_pairs_hook=OrderedDict)
+    except json.JSONDecodeError as jde:
+        print('IGNORING test case file {}\n\tBECAUSE:  {}'.format(filename, jde))
+        testlist = list()
+    else:
+        idlist = get_id_list(testlist)
+        if (has_blank_ids(idlist)):
+            for k in testlist:
+                k['filename'] = filename
     return testlist
 
 
-- 
2.15.0.rc0
