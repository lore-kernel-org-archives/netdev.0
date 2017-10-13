From: Lucas Bates <lucasb@mojatatu.com>
Subject: [PATCH net-next v2 3/4] tc-testing: Add test cases for police and skbmod
Date: Fri, 13 Oct 2017 17:51:24 -0400
Message-ID: <1507931485-1814-4-git-send-email-lucasb@mojatatu.com>
References: <1507931485-1814-1-git-send-email-lucasb@mojatatu.com>
Cc: netdev@vger.kernel.org, xiyou.wangcong@gmail.com, jiri@resnulli.us,
        jhs@mojatatu.com, aring@mojatatu.com, mrv@mojatatu.com,
        Lucas Bates <lucasb@mojatatu.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-it0-f66.google.com ([209.85.214.66]:49551 "EHLO
        mail-it0-f66.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752606AbdJMVvo (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 13 Oct 2017 17:51:44 -0400
Received: by mail-it0-f66.google.com with SMTP id y15so12908046ita.4
        for <netdev@vger.kernel.org>; Fri, 13 Oct 2017 14:51:43 -0700 (PDT)
In-Reply-To: <1507931485-1814-1-git-send-email-lucasb@mojatatu.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Add basic unit tests for police and skbmod actions in tc.

Signed-off-by: Lucas Bates <lucasb@mojatatu.com>
Acked-by: Jamal Hadi Salim <jhs@mojatatu.com>
---
 .../tc-testing/tc-tests/actions/police.json        | 527 +++++++++++++++++++++
 .../tc-testing/tc-tests/actions/skbmod.json        | 372 +++++++++++++++
 2 files changed, 899 insertions(+)
 create mode 100644 tools/testing/selftests/tc-testing/tc-tests/actions/police.json
 create mode 100644 tools/testing/selftests/tc-testing/tc-tests/actions/skbmod.json

diff --git a/tools/testing/selftests/tc-testing/tc-tests/actions/police.json b/tools/testing/selftests/tc-testing/tc-tests/actions/police.json
new file mode 100644
index 0000000..0e602a3
--- /dev/null
+++ b/tools/testing/selftests/tc-testing/tc-tests/actions/police.json
@@ -0,0 +1,527 @@
+[
+    {
+        "id": "49aa",
+        "name": "Add valid basic police action",
+        "category": [
+            "actions",
+            "police"
+        ],
+        "setup": [
+            [
+                "$TC actions flush action police",
+                0,
+                1,
+                255
+            ]
+        ],
+        "cmdUnderTest": "$TC actions add action police rate 1kbit burst 10k index 1",
+        "expExitCode": "0",
+        "verifyCmd": "$TC actions ls action police",
+        "matchPattern": "action order [0-9]*:  police 0x1 rate 1Kbit burst 10Kb",
+        "matchCount": "1",
+        "teardown": [
+            "$TC actions flush action police"
+        ]
+    },
+    {
+        "id": "3abe",
+        "name": "Add police action with duplicate index",
+        "category": [
+            "actions",
+            "police"
+        ],
+        "setup": [
+            [
+                "$TC actions flush action police",
+                0,
+                1,
+                255
+            ],
+            "$TC actions add action police rate 4Mbit burst 120k index 9"
+        ],
+        "cmdUnderTest": "$TC actions add action police rate 8kbit burst 24k index 9",
+        "expExitCode": "255",
+        "verifyCmd": "$TC actions ls action police",
+        "matchPattern": "action order [0-9]*:  police 0x9",
+        "matchCount": "1",
+        "teardown": [
+            "$TC actions flush action police"
+        ]
+    },
+    {
+        "id": "49fa",
+        "name": "Add valid police action with mtu",
+        "category": [
+            "actions",
+            "police"
+        ],
+        "setup": [
+            [
+                "$TC actions flush action police",
+                0,
+                1,
+                255
+            ]
+        ],
+        "cmdUnderTest": "$TC actions add action police rate 90kbit burst 10k mtu 1k index 98",
+        "expExitCode": "0",
+        "verifyCmd": "$TC actions get action police index 98",
+        "matchPattern": "action order [0-9]*:  police 0x62 rate 90Kbit burst 10Kb mtu 1Kb",
+        "matchCount": "1",
+        "teardown": [
+            "$TC actions flush action police"
+        ]
+    },
+    {
+        "id": "7943",
+        "name": "Add valid police action with peakrate",
+        "category": [
+            "actions",
+            "police"
+        ],
+        "setup": [
+            [
+                "$TC actions flush action police",
+                0,
+                1,
+                255
+            ]
+        ],
+        "cmdUnderTest": "$TC actions add action police rate 90kbit burst 10k mtu 2kb peakrate 100kbit index 3",
+        "expExitCode": "0",
+        "verifyCmd": "$TC actions ls action police",
+        "matchPattern": "action order [0-9]*:  police 0x3 rate 90Kbit burst 10Kb mtu 2Kb peakrate 100Kbit",
+        "matchCount": "1",
+        "teardown": [
+            "$TC actions flush action police"
+        ]
+    },
+    {
+        "id": "055e",
+        "name": "Add police action with peakrate and no mtu",
+        "category": [
+            "actions",
+            "police"
+        ],
+        "setup": [
+            [
+                "$TC actions flush action police",
+                0,
+                1,
+                255
+            ]
+        ],
+        "cmdUnderTest": "$TC actions add action police rate 5kbit burst 6kb peakrate 10kbit index 9",
+        "expExitCode": "255",
+        "verifyCmd": "$TC actions ls action police",
+        "matchPattern": "action order [0-9]*:  police 0x9 rate 5Kb burst 10Kb",
+        "matchCount": "0",
+        "teardown": [
+            "$TC actions flush action police"
+        ]
+    },
+    {
+        "id": "f057",
+        "name": "Add police action with valid overhead",
+        "category": [
+            "actions",
+            "police"
+        ],
+        "setup": [
+            [
+                "$TC actions flush action police",
+                0,
+                1,
+                255
+            ]
+        ],
+        "cmdUnderTest": "$TC actions add action police rate 1mbit burst 100k overhead 64 index 64",
+        "expExitCode": "0",
+        "verifyCmd": "$TC actions get action police index 64",
+        "matchPattern": "action order [0-9]*:  police 0x40 rate 1Mbit burst 100Kb mtu 2Kb action reclassify overhead 64b",
+        "matchCount": "1",
+        "teardown": [
+            "$TC actions flush action police"
+        ]
+    },
+    {
+        "id": "7ffb",
+        "name": "Add police action with ethernet linklayer type",
+        "category": [
+            "actions",
+            "police"
+        ],
+        "setup": [
+            [
+                "$TC actions flush action police",
+                0,
+                1,
+                255
+            ]
+        ],
+        "cmdUnderTest": "$TC actions add action police rate 2mbit burst 200k linklayer ethernet index 8",
+        "expExitCode": "0",
+        "verifyCmd": "$TC actions show action police",
+        "matchPattern": "action order [0-9]*:  police 0x8 rate 2Mbit burst 200Kb mtu 2Kb action reclassify overhead 0b",
+        "matchCount": "1",
+        "teardown": [
+            "$TC actions flush action police"
+        ]
+    },
+    {
+        "id": "3dda",
+        "name": "Add police action with atm linklayer type",
+        "category": [
+            "actions",
+            "police"
+        ],
+        "setup": [
+            [
+                "$TC actions flush action police",
+                0,
+                1,
+                255
+            ]
+        ],
+        "cmdUnderTest": "$TC actions add action police rate 2mbit burst 200k linklayer atm index 8",
+        "expExitCode": "0",
+        "verifyCmd": "$TC actions show action police",
+        "matchPattern": "action order [0-9]*:  police 0x8 rate 2Mbit burst 200Kb mtu 2Kb action reclassify overhead 0b linklayer atm",
+        "matchCount": "1",
+        "teardown": [
+            "$TC actions flush action police"
+        ]
+    },
+    {
+        "id": "551b",
+        "name": "Add police actions with conform-exceed control continue/drop",
+        "category": [
+            "actions",
+            "police"
+        ],
+        "setup": [
+            [
+                "$TC actions flush action police",
+                0,
+                1,
+                255
+            ]
+        ],
+        "cmdUnderTest": "$TC actions add action police rate 3mbit burst 250k conform-exceed continue/drop index 1",
+        "expExitCode": "0",
+        "verifyCmd": "$TC actions get action police index 1",
+        "matchPattern": "action order [0-9]*:  police 0x1 rate 3Mbit burst 250Kb mtu 2Kb action continue/drop",
+        "matchCount": "1",
+        "teardown": [
+            "$TC actions flush action police"
+        ]
+    },
+    {
+        "id": "0c70",
+        "name": "Add police actions with conform-exceed control pass/reclassify",
+        "category": [
+            "actions",
+            "police"
+        ],
+        "setup": [
+            [
+                "$TC actions flush action police",
+                0,
+                1,
+                255
+            ]
+        ],
+        "cmdUnderTest": "$TC actions add action police rate 3mbit burst 250k conform-exceed pass/reclassify index 4",
+        "expExitCode": "0",
+        "verifyCmd": "$TC actions ls action police",
+        "matchPattern": "action order [0-9]*:  police 0x4 rate 3Mbit burst 250Kb mtu 2Kb action pass/reclassify",
+        "matchCount": "1",
+        "teardown": [
+            "$TC actions flush action police"
+        ]
+    },
+    {
+        "id": "d946",
+        "name": "Add police actions with conform-exceed control pass/pipe",
+        "category": [
+            "actions",
+            "police"
+        ],
+        "setup": [
+            [
+                "$TC actions flush action police",
+                0,
+                1,
+                255
+            ]
+        ],
+        "cmdUnderTest": "$TC actions add action police rate 3mbit burst 250k conform-exceed pass/pipe index 5",
+        "expExitCode": "0",
+        "verifyCmd": "$TC actions ls action police",
+        "matchPattern": "action order [0-9]*:  police 0x5 rate 3Mbit burst 250Kb mtu 2Kb action pass/pipe",
+        "matchCount": "1",
+        "teardown": [
+            "$TC actions flush action police"
+        ]
+    },
+    {
+        "id": "336e",
+        "name": "Delete police action",
+        "category": [
+            "actions",
+            "police"
+        ],
+        "setup": [
+            [
+                "$TC actions flush action police",
+                0,
+                1,
+                255
+            ],
+            "$TC actions add action police rate 5mbit burst 2m index 12"
+        ],
+        "cmdUnderTest": "$TC actions delete action police index 12",
+        "expExitCode": "0",
+        "verifyCmd": "$TC actions ls action police",
+        "matchPattern": "action order [0-9]*:  police 0xc rate 5Mb burst 2Mb",
+        "matchCount": "0",
+        "teardown": [
+            "$TC actions flush action police"
+        ]
+    },
+    {
+        "id": "77fa",
+        "name": "Get single police action from many actions",
+        "category": [
+            "actions",
+            "police"
+        ],
+        "setup": [
+            [
+                "$TC actions flush action police",
+                0,
+                1,
+                255
+            ],
+            "$TC actions add action police rate 1mbit burst 100k index 1",
+            "$TC actions add action police rate 2mbit burst 200k index 2",
+            "$TC actions add action police rate 3mbit burst 300k index 3",
+            "$TC actions add action police rate 4mbit burst 400k index 4",
+            "$TC actions add action police rate 5mbit burst 500k index 5",
+            "$TC actions add action police rate 6mbit burst 600k index 6",
+            "$TC actions add action police rate 7mbit burst 700k index 7",
+            "$TC actions add action police rate 8mbit burst 800k index 8"
+        ],
+        "cmdUnderTest": "$TC actions get action police index 4",
+        "expExitCode": "0",
+        "verifyCmd": "$TC actions get action police index 4",
+        "matchPattern": "action order [0-9]*:  police 0x4 rate 4Mbit burst 400Kb",
+        "matchCount": "1",
+        "teardown": [
+            "$TC actions flush action police"
+        ]
+    },
+    {
+        "id": "aa43",
+        "name": "Get single police action without specifying index",
+        "category": [
+            "actions",
+            "police"
+        ],
+        "setup": [
+            [
+                "$TC actions flush action police",
+                0,
+                1,
+                255
+            ],
+            "$TC actions add action police rate 1mbit burst 100k index 1"
+        ],
+        "cmdUnderTest": "$TC actions get action police",
+        "expExitCode": "255",
+        "verifyCmd": "$TC actions get action police",
+        "matchPattern": "action order [0-9]*:  police",
+        "matchCount": "0",
+        "teardown": [
+            "$TC actions flush action police"
+        ]
+    },
+    {
+        "id": "858b",
+        "name": "List police actions",
+        "category": [
+            "actions",
+            "police"
+        ],
+        "setup": [
+            [
+                "$TC actions flush action police",
+                0,
+                1,
+                255
+            ],
+            "$TC actions add action police rate 1mbit burst 100k index 1",
+            "$TC actions add action police rate 2mbit burst 200k index 2",
+            "$TC actions add action police rate 3mbit burst 300k index 3",
+            "$TC actions add action police rate 4mbit burst 400k index 4",
+            "$TC actions add action police rate 5mbit burst 500k index 5",
+            "$TC actions add action police rate 6mbit burst 600k index 6",
+            "$TC actions add action police rate 7mbit burst 700k index 7",
+            "$TC actions add action police rate 8mbit burst 800k index 8"
+        ],
+        "cmdUnderTest": "$TC actions list action police",
+        "expExitCode": "0",
+        "verifyCmd": "$TC actions ls action police",
+        "matchPattern": "action order [0-9]*:  police 0x[1-8] rate [1-8]Mbit burst [1-8]00Kb",
+        "matchCount": "8",
+        "teardown": [
+            "$TC actions flush action police"
+        ]
+    },
+    {
+        "id": "1c3a",
+        "name": "Flush police actions",
+        "category": [
+            "actions",
+            "police"
+        ],
+        "setup": [
+            "$TC actions add action police rate 1mbit burst 100k index 1",
+            "$TC actions add action police rate 2mbit burst 200k index 2",
+            "$TC actions add action police rate 3mbit burst 300k index 3",
+            "$TC actions add action police rate 4mbit burst 400k index 4",
+            "$TC actions add action police rate 5mbit burst 500k index 5",
+            "$TC actions add action police rate 6mbit burst 600k index 6",
+            "$TC actions add action police rate 7mbit burst 700k index 7",
+            "$TC actions add action police rate 8mbit burst 800k index 8"
+        ],
+        "cmdUnderTest": "$TC actions flush action police",
+        "expExitCode": "0",
+        "verifyCmd": "$TC actions ls action police",
+        "matchPattern": "action order [0-9]*:  police",
+        "matchCount": "0",
+        "teardown": [
+            ""
+        ]
+    },
+    {
+        "id": "7326",
+        "name": "Add police action with control continue",
+        "category": [
+            "actions",
+            "police"
+        ],
+        "setup": [
+            [
+                "$TC actions flush action police",
+                0,
+                1,
+                255
+            ]
+        ],
+        "cmdUnderTest": "$TC actions add action police rate 7mbit burst 1m continue index 1",
+        "expExitCode": "0",
+        "verifyCmd": "$TC actions get action police index 1",
+        "matchPattern": "action order [0-9]*:  police 0x1 rate 7Mbit burst 1024Kb mtu 2Kb action continue",
+        "matchCount": "1",
+        "teardown": [
+            "$TC actions flush action police"
+        ]
+    },
+    {
+        "id": "34fa",
+        "name": "Add police action with control drop",
+        "category": [
+            "actions",
+            "police"
+        ],
+        "setup": [
+            [
+                "$TC actions flush action police",
+                0,
+                1,
+                255
+            ]
+        ],
+        "cmdUnderTest": "$TC actions add action police rate 7mbit burst 1m drop index 1",
+        "expExitCode": "0",
+        "verifyCmd": "$TC actions ls action police",
+        "matchPattern": "action order [0-9]*:  police 0x1 rate 7Mbit burst 1024Kb mtu 2Kb action drop",
+        "matchCount": "1",
+        "teardown": [
+            "$TC actions flush action police"
+        ]
+    },
+    {
+        "id": "8dd5",
+        "name": "Add police action with control ok",
+        "category": [
+            "actions",
+            "police"
+        ],
+        "setup": [
+            [
+                "$TC actions flush action police",
+                0,
+                1,
+                255
+            ]
+        ],
+        "cmdUnderTest": "$TC actions add action police rate 7mbit burst 1m ok index 1",
+        "expExitCode": "0",
+        "verifyCmd": "$TC actions ls action police",
+        "matchPattern": "action order [0-9]*:  police 0x1 rate 7Mbit burst 1024Kb mtu 2Kb action pass",
+        "matchCount": "1",
+        "teardown": [
+            "$TC actions flush action police"
+        ]
+    },
+    {
+        "id": "b9d1",
+        "name": "Add police action with control reclassify",
+        "category": [
+            "actions",
+            "police"
+        ],
+        "setup": [
+            [
+                "$TC actions flush action police",
+                0,
+                1,
+                255
+            ]
+        ],
+        "cmdUnderTest": "$TC actions add action police rate 7mbit burst 1m reclassify index 1",
+        "expExitCode": "0",
+        "verifyCmd": "$TC actions get action police index 1",
+        "matchPattern": "action order [0-9]*:  police 0x1 rate 7Mbit burst 1024Kb mtu 2Kb action reclassify",
+        "matchCount": "1",
+        "teardown": [
+            "$TC actions flush action police"
+        ]
+    },
+    {
+        "id": "c534",
+        "name": "Add police action with control pipe",
+        "category": [
+            "actions",
+            "police"
+        ],
+        "setup": [
+            [
+                "$TC actions flush action police",
+                0,
+                1,
+                255
+            ]
+        ],
+        "cmdUnderTest": "$TC actions add action police rate 7mbit burst 1m pipe index 1",
+        "expExitCode": "0",
+        "verifyCmd": "$TC actions ls action police",
+        "matchPattern": "action order [0-9]*:  police 0x1 rate 7Mbit burst 1024Kb mtu 2Kb action pipe",
+        "matchCount": "1",
+        "teardown": [
+            "$TC actions flush action police"
+        ]
+    }
+]
diff --git a/tools/testing/selftests/tc-testing/tc-tests/actions/skbmod.json b/tools/testing/selftests/tc-testing/tc-tests/actions/skbmod.json
new file mode 100644
index 0000000..e3407505
--- /dev/null
+++ b/tools/testing/selftests/tc-testing/tc-tests/actions/skbmod.json
@@ -0,0 +1,372 @@
+[
+    {
+        "id": "7d50",
+        "name": "Add skbmod action to set destination mac",
+        "category": [
+            "actions",
+            "skbmod"
+        ],
+        "setup": [
+            [
+                "$TC actions flush action skbmod",
+                0,
+                1,
+                255
+            ]
+        ],
+        "cmdUnderTest": "$TC actions add action skbmod set dmac 11:22:33:44:55:66 index 5",
+        "expExitCode": "0",
+        "verifyCmd": "$TC actions ls action skbmod",
+        "matchPattern": "action order [0-9]*: skbmod pipe set dmac 11:22:33:44:55:66\\s+index 5",
+        "matchCount": "1",
+        "teardown": [
+            "$TC actions flush action skbmod"
+        ]
+    },
+    {
+        "id": "9b29",
+        "name": "Add skbmod action to set source mac",
+        "category": [
+            "actions",
+            "skbmod"
+        ],
+        "setup": [
+            [
+                "$TC actions flush action skbmod",
+                0,
+                1,
+                255
+            ]
+        ],
+        "cmdUnderTest": "$TC actions add action skbmod set smac 77:88:99:AA:BB:CC index 7",
+        "expExitCode": "0",
+        "verifyCmd": "$TC actions get action skbmod index 7",
+        "matchPattern": "action order [0-9]*: skbmod pipe set smac 77:88:99:aa:bb:cc\\s+index 7",
+        "matchCount": "1",
+        "teardown": [
+            "$TC actions flush action skbmod"
+        ]
+    },
+    {
+        "id": "1724",
+        "name": "Add skbmod action with invalid mac",
+        "category": [
+            "actions",
+            "skbmod"
+        ],
+        "setup": [
+            [
+                "$TC actions flush action skbmod",
+                0,
+                1,
+                255
+            ]
+        ],
+        "cmdUnderTest": "$TC actions add action skbmod set smac 00:44:55:44:55",
+        "expExitCode": "255",
+        "verifyCmd": "$TC actions ls action skbmod",
+        "matchPattern": "action order [0-9]*: skbmod pipe set smac 00:44:55:44:55",
+        "matchCount": "0",
+        "teardown": [
+            "$TC actions flush action skbmod"
+        ]
+    },
+    {
+        "id": "3cf1",
+        "name": "Add skbmod action with valid etype",
+        "category": [
+            "actions",
+            "skbmod"
+        ],
+        "setup": [
+            [
+                "$TC actions flush action skbmod",
+                0,
+                1,
+                255
+            ]
+        ],
+        "cmdUnderTest": "$TC actions add action skbmod set etype 0xfefe",
+        "expExitCode": "0",
+        "verifyCmd": "$TC actions ls action skbmod",
+        "matchPattern": "action order [0-9]*: skbmod pipe set etype 0xFEFE",
+        "matchCount": "1",
+        "teardown": [
+            "$TC actions flush action skbmod"
+        ]
+    },
+    {
+        "id": "a749",
+        "name": "Add skbmod action with invalid etype",
+        "category": [
+            "actions",
+            "skbmod"
+        ],
+        "setup": [
+            [
+                "$TC actions flush action skbmod",
+                0,
+                1,
+                255
+            ]
+        ],
+        "cmdUnderTest": "$TC actions add action skbmod set etype 0xfefef",
+        "expExitCode": "255",
+        "verifyCmd": "$TC actions ls action skbmod",
+        "matchPattern": "action order [0-9]*: skbmod pipe set etype 0xFEFEF",
+        "matchCount": "0",
+        "teardown": [
+            "$TC actions flush action skbmod"
+        ]
+    },
+    {
+        "id": "bfe6",
+        "name": "Add skbmod action to swap mac",
+        "category": [
+            "actions",
+            "skbmod"
+        ],
+        "setup": [
+            [
+                "$TC actions flush action skbmod",
+                0,
+                1,
+                255
+            ]
+        ],
+        "cmdUnderTest": "$TC actions add action skbmod swap mac",
+        "expExitCode": "0",
+        "verifyCmd": "$TC actions get action skbmod index 1",
+        "matchPattern": "action order [0-9]*: skbmod pipe swap mac",
+        "matchCount": "1",
+        "teardown": [
+            "$TC actions flush action skbmod"
+        ]
+    },
+    {
+        "id": "839b",
+        "name": "Add skbmod action with control pipe",
+        "category": [
+            "actions",
+            "skbmod"
+        ],
+        "setup": [
+            [
+                "$TC actions flush action skbmod",
+                0,
+                1,
+                255
+            ]
+        ],
+        "cmdUnderTest": "$TC actions add action skbmod swap mac pipe",
+        "expExitCode": "0",
+        "verifyCmd": "$TC actions ls action skbmod",
+        "matchPattern": "action order [0-9]*: skbmod pipe swap mac",
+        "matchCount": "1",
+        "teardown": [
+            "$TC actions flush action skbmod"
+        ]
+    },
+    {
+        "id": "c167",
+        "name": "Add skbmod action with control reclassify",
+        "category": [
+            "actions",
+            "skbmod"
+        ],
+        "setup": [
+            [
+                "$TC actions flush action skbmod",
+                0,
+                1,
+                255
+            ]
+        ],
+        "cmdUnderTest": "$TC actions add action skbmod set etype 0xbeef reclassify",
+        "expExitCode": "0",
+        "verifyCmd": "$TC actions ls action skbmod",
+        "matchPattern": "action order [0-9]*: skbmod reclassify set etype 0xBEEF",
+        "matchCount": "1",
+        "teardown": [
+            "$TC actions flush action skbmod"
+        ]
+    },
+    {
+        "id": "0c2f",
+        "name": "Add skbmod action with control drop",
+        "category": [
+            "actions",
+            "skbmod"
+        ],
+        "setup": [
+            [
+                "$TC actions flush action skbmod",
+                0,
+                1,
+                255
+            ]
+        ],
+        "cmdUnderTest": "$TC actions add action skbmod set etype 0x0001 drop",
+        "expExitCode": "0",
+        "verifyCmd": "$TC actions get action skbmod index 1",
+        "matchPattern": "action order [0-9]*: skbmod drop set etype 0x1",
+        "matchCount": "1",
+        "teardown": [
+            "$TC actions flush action skbmod"
+        ]
+    },
+    {
+        "id": "d113",
+        "name": "Add skbmod action with control continue",
+        "category": [
+            "actions",
+            "skbmod"
+        ],
+        "setup": [
+            [
+                "$TC actions flush action skbmod",
+                0,
+                1,
+                255
+            ]
+        ],
+        "cmdUnderTest": "$TC actions add action skbmod set etype 0x1 continue",
+        "expExitCode": "0",
+        "verifyCmd": "$TC actions ls action skbmod",
+        "matchPattern": "action order [0-9]*: skbmod continue set etype 0x1",
+        "matchCount": "1",
+        "teardown": [
+            "$TC actions flush action skbmod"
+        ]
+    },
+    {
+        "id": "7242",
+        "name": "Add skbmod action with control pass",
+        "category": [
+            "actions",
+            "skbmod"
+        ],
+        "setup": [
+            [
+                "$TC actions flush action skbmod",
+                0,
+                1,
+                255
+            ]
+        ],
+        "cmdUnderTest": "$TC actions add action skbmod set smac 00:00:00:00:00:01 pass",
+        "expExitCode": "0",
+        "verifyCmd": "$TC actions ls action skbmod",
+        "matchPattern": "action order [0-9]*: skbmod pass set smac 00:00:00:00:00:01",
+        "matchCount": "1",
+        "teardown": [
+            "$TC actions flush action skbmod"
+        ]
+    },
+    {
+        "id": "58cb",
+        "name": "List skbmod actions",
+        "category": [
+            "actions",
+            "skbmod"
+        ],
+        "setup": [
+            [
+                "$TC actions flush action skbmod",
+                0,
+                1,
+                255
+            ],
+            "$TC actions add action skbmod set etype 0x0001",
+            "$TC actions add action skbmod set etype 0x0011",
+            "$TC actions add action skbmod set etype 0x0021",
+            "$TC actions add action skbmod set etype 0x0031",
+            "$TC actions add action skbmod set etype 0x0041"
+        ],
+        "cmdUnderTest": "$TC actions ls action skbmod",
+        "expExitCode": "0",
+        "verifyCmd": "$TC actions ls action skbmod",
+        "matchPattern": "action order [0-9]*: skbmod",
+        "matchCount": "5",
+        "teardown": [
+            "$TC actions flush action skbmod"
+        ]
+    },
+    {
+        "id": "9aa8",
+        "name": "Get a single skbmod action from a list",
+        "category": [
+            "actions",
+            "skbmod"
+        ],
+        "setup": [
+            [
+                "$TC actions flush action skbmod",
+                0,
+                1,
+                255
+            ],
+            "$TC actions add action skbmod set etype 0x0001",
+            "$TC actions add action skbmod set etype 0x0011",
+            "$TC actions add action skbmod set etype 0x0021",
+            "$TC actions add action skbmod set etype 0x0031",
+            "$TC actions add action skbmod set etype 0x0041"
+        ],
+        "cmdUnderTest": "$TC actions ls action skbmod",
+        "expExitCode": "0",
+        "verifyCmd": "$TC actions get action skbmod index 4",
+        "matchPattern": "action order [0-9]*: skbmod pipe set etype 0x0031",
+        "matchCount": "1",
+        "teardown": [
+            "$TC actions flush action skbmod"
+        ]
+    },
+    {
+        "id": "e93a",
+        "name": "Delete an skbmod action",
+        "category": [
+            "actions",
+            "skbmod"
+        ],
+        "setup": [
+            [
+                "$TC actions flush action skbmod",
+                0,
+                1,
+                255
+            ],
+            "$TC actions add action skbmod set etype 0x1111 index 909"
+        ],
+        "cmdUnderTest": "$TC actions del action skbmod index 909",
+        "expExitCode": "0",
+        "verifyCmd": "$TC actions ls action skbmod",
+        "matchPattern": "action order [0-9]*: skbmod pipe set etype 0x1111\\s+index 909",
+        "matchCount": "0",
+        "teardown": [
+            "$TC actions flush action skbmod"
+        ]
+    },
+    {
+        "id": "40c2",
+        "name": "Flush skbmod actions",
+        "category": [
+            "actions",
+            "skbmod"
+        ],
+        "setup": [
+            "$TC actions add action skbmod set etype 0x0001",
+            "$TC actions add action skbmod set etype 0x0011",
+            "$TC actions add action skbmod set etype 0x0021",
+            "$TC actions add action skbmod set etype 0x0031",
+            "$TC actions add action skbmod set etype 0x0041"
+        ],
+        "cmdUnderTest": "$TC actions flush action skbmod",
+        "expExitCode": "0",
+        "verifyCmd": "$TC actions ls action skbmod",
+        "matchPattern": "action order [0-9]*: skbmod",
+        "matchCount": "0",
+        "teardown": [
+            "$TC actions flush action skbmod"
+        ]
+    }
+]
