From: Lucas Bates <lucasb@mojatatu.com>
Subject: [PATCH net-next 1/1] selftests: Introduce tc testsuite
Date: Fri, 16 Jun 2017 17:22:35 -0400
Message-ID: <1497648155-25521-2-git-send-email-lucasb@mojatatu.com>
References: <1497648155-25521-1-git-send-email-lucasb@mojatatu.com>
Cc: netdev@vger.kernel.org, stephen@networkplumber.org,
        jiri@resnulli.us, xiyou.wangcong@gmail.com, mrv@mojatatu.com,
        jhs@mojatatu.com, Lucas Bates <lucasb@mojatatu.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-it0-f48.google.com ([209.85.214.48]:33203 "EHLO
        mail-it0-f48.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750792AbdFPVXK (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 16 Jun 2017 17:23:10 -0400
Received: by mail-it0-f48.google.com with SMTP id g184so4794778ita.0
        for <netdev@vger.kernel.org>; Fri, 16 Jun 2017 14:23:10 -0700 (PDT)
In-Reply-To: <1497648155-25521-1-git-send-email-lucasb@mojatatu.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Add the beginnings of a testsuite for tc functionality in the kernel.
These are a series of unit tests that use the tc executable and verify
the success of those commands by checking both the exit codes and the
output from tc's 'show' operation.

To run the tests:
  # cd tools/testing/selftests/tc-testing
  # sudo ./tdc.py

You can specify the tc executable to use with the -p argument on the command
line or editing the 'TC' variable in tdc_config.py. Refer to the README for
full details on how to run.

The initial complement of test cases are limited mostly to tc actions. Test
cases are most welcome; see the creating-testcases subdirectory for help
in creating them.

Signed-off-by: Lucas Bates <lucasb@mojatatu.com>
Signed-off-by: Jamal Hadi Salim <jhs@mojatatu.com>
---
 tools/testing/selftests/tc-testing/.gitignore      |    1 +
 tools/testing/selftests/tc-testing/README          |  102 ++
 tools/testing/selftests/tc-testing/TODO.txt        |   10 +
 .../creating-testcases/AddingTestCases.txt         |   69 ++
 .../tc-testing/creating-testcases/template.json    |   40 +
 .../tc-testing/tc-tests/actions/tests.json         | 1115 ++++++++++++++++++++
 .../tc-testing/tc-tests/filters/tests.json         |   21 +
 tools/testing/selftests/tc-testing/tdc.py          |  413 ++++++++
 tools/testing/selftests/tc-testing/tdc_config.py   |   17 +
 tools/testing/selftests/tc-testing/tdc_helper.py   |   75 ++
 10 files changed, 1863 insertions(+)
 create mode 100644 tools/testing/selftests/tc-testing/.gitignore
 create mode 100644 tools/testing/selftests/tc-testing/README
 create mode 100644 tools/testing/selftests/tc-testing/TODO.txt
 create mode 100644 tools/testing/selftests/tc-testing/creating-testcases/AddingTestCases.txt
 create mode 100644 tools/testing/selftests/tc-testing/creating-testcases/template.json
 create mode 100644 tools/testing/selftests/tc-testing/tc-tests/actions/tests.json
 create mode 100644 tools/testing/selftests/tc-testing/tc-tests/filters/tests.json
 create mode 100755 tools/testing/selftests/tc-testing/tdc.py
 create mode 100644 tools/testing/selftests/tc-testing/tdc_config.py
 create mode 100644 tools/testing/selftests/tc-testing/tdc_helper.py

diff --git a/tools/testing/selftests/tc-testing/.gitignore b/tools/testing/selftests/tc-testing/.gitignore
new file mode 100644
index 0000000..c18dd8d
--- /dev/null
+++ b/tools/testing/selftests/tc-testing/.gitignore
@@ -0,0 +1 @@
+__pycache__/
diff --git a/tools/testing/selftests/tc-testing/README b/tools/testing/selftests/tc-testing/README
new file mode 100644
index 0000000..970ff29
--- /dev/null
+++ b/tools/testing/selftests/tc-testing/README
@@ -0,0 +1,102 @@
+tdc - Linux Traffic Control (tc) unit testing suite
+
+Author: Lucas Bates - lucasb@mojatatu.com
+
+tdc is a Python script to load tc unit tests from a separate JSON file and
+execute them inside a network namespace dedicated to the task.
+
+
+REQUIREMENTS
+------------
+
+*  Minimum Python version of 3.4. Earlier 3.X versions may work but are not
+   guaranteed.
+
+*  The kernel must have network namespace support
+
+*   The kernel must have veth support available, as a veth pair is created
+   prior to running the tests.
+
+*  All tc-related features must be built in or available as modules.
+   To check what is required in current setup run:
+   ./tdc.py -c
+
+   Note:
+   In the current release, tdc run will abort due to a failure in setup or
+   teardown commands - which includes not being able to run a test simply
+   because the kernel did not support a specific feature. (This will be
+   handled in a future version - the current workaround is to run the tests
+   on specific test categories that your kernel supports)
+
+
+BEFORE YOU RUN
+--------------
+
+The path to the tc executable that will be most commonly tested can be defined
+in the tdc_config.py file. Find the 'TC' entry in the NAMES dictionary and
+define the path.
+
+If you need to test a different tc executable on the fly, you can do so by
+using the -p option when running tdc:
+	./tdc.py -p /path/to/tc
+
+
+RUNNING TDC
+-----------
+
+To use tdc, root privileges are required. tdc will not run otherwise.
+
+All tests are executed inside a network namespace to prevent conflicts
+within the host.
+
+Running tdc without any arguments will run all tests. Refer to the section
+on command line arguments for more information, or run:
+	./tdc.py -h
+
+tdc will list the test names as they are being run, and print a summary in
+TAP (Test Anything Protocol) format when they are done. If tests fail,
+output captured from the failing test will be printed immediately following
+the failed test in the TAP output.
+
+
+USER-DEFINED CONSTANTS
+----------------------
+
+The tdc_config.py file contains multiple values that can be altered to suit
+your needs. Any value in the NAMES dictionary can be altered without affecting
+the tests to be run. These values are used in the tc commands that will be
+executed as part of the test. More will be added as test cases require.
+
+Example:
+	$TC qdisc add dev $DEV1 ingress
+
+
+COMMAND LINE ARGUMENTS
+----------------------
+
+Run tdc.py -h to see the full list of available arguments.
+
+-p PATH           Specify the tc executable located at PATH to be used on this
+                  test run
+-c                Show the available test case categories in this test file
+-c CATEGORY       Run only tests that belong to CATEGORY
+-f FILE           Read test cases from the JSON file named FILE
+-l [CATEGORY]     List all test cases in the JSON file. If CATEGORY is
+                  specified, list test cases matching that category.
+-s ID             Show the test case matching ID
+-e ID             Execute the test case identified by ID
+-i                Generate unique ID numbers for test cases with no existing
+                  ID number
+
+
+ACKNOWLEDGEMENTS
+----------------
+
+Thanks to:
+
+Jamal Hadi Salim, for providing valuable test cases
+Keara Leibovitz, who wrote the CLI test driver that I used as a base for the
+   first version of the tc testing suite. This work was presented at
+   Netdev 1.2 Tokyo in October 2016.
+Samir Hussain, for providing help while I dove into Python for the first time
+    and being a second eye for this code.
diff --git a/tools/testing/selftests/tc-testing/TODO.txt b/tools/testing/selftests/tc-testing/TODO.txt
new file mode 100644
index 0000000..6a266d8
--- /dev/null
+++ b/tools/testing/selftests/tc-testing/TODO.txt
@@ -0,0 +1,10 @@
+tc Testing Suite To-Do list:
+
+- Determine what tc features are supported in the kernel. If features are not
+  present, prevent the related categories from running.
+
+- Add support for multiple versions of tc to run successively
+
+- Improve error messages when tdc aborts its run
+
+- Allow tdc to write its results to file
diff --git a/tools/testing/selftests/tc-testing/creating-testcases/AddingTestCases.txt b/tools/testing/selftests/tc-testing/creating-testcases/AddingTestCases.txt
new file mode 100644
index 0000000..4e09257
--- /dev/null
+++ b/tools/testing/selftests/tc-testing/creating-testcases/AddingTestCases.txt
@@ -0,0 +1,69 @@
+tdc - Adding test cases for tdc
+
+Author: Lucas Bates - lucasb@mojatatu.com
+
+ADDING TEST CASES
+-----------------
+
+User-defined tests should be added by defining a separate JSON file.  This
+will help prevent conflicts when updating the repository. Refer to
+template.json for the required JSON format for test cases.
+
+Include the 'id' field, but do not assign a value. Running tdc with the -i
+option will generate a unique ID for that test case.
+
+tdc will recursively search the 'tc' subdirectory for .json files.  Any
+test case files you create in these directories will automatically be included.
+If you wish to store your custom test cases elsewhere, be sure to run tdc
+with the -f argument and the path to your file.
+
+Be aware of required escape characters in the JSON data - particularly when
+defining the match pattern. Refer to the tctests.json file for examples when
+in doubt.
+
+
+TEST CASE STRUCTURE
+-------------------
+
+Each test case has required data:
+
+id:           A unique alphanumeric value to identify a particular test case
+name:         Descriptive name that explains the command under test
+category:     A list of single-word descriptions covering what the command
+              under test is testing. Example: filter, actions, u32, gact, etc.
+setup:        The list of commands required to ensure the command under test
+              succeeds. For example: if testing a filter, the command to create
+              the qdisc would appear here.
+cmdUnderTest: The tc command being tested itself.
+expExitCode:  The code returned by the command under test upon its termination.
+              tdc will compare this value against the actual returned value.
+verifyCmd:    The tc command to be run to verify successful execution.
+              For example: if the command under test creates a gact action,
+              verifyCmd should be "$TC actions show action gact"
+matchPattern: A regular expression to be applied against the output of the
+              verifyCmd to prove the command under test succeeded. This pattern
+              should be as specific as possible so that a false positive is not
+              matched.
+matchCount:   How many times the regex in matchPattern should match. A value
+              of 0 is acceptable.
+teardown:     The list of commands to clean up after the test is completed.
+              The environment should be returned to the same state as when
+              this test was started: qdiscs deleted, actions flushed, etc.
+
+
+SETUP/TEARDOWN ERRORS
+---------------------
+
+If an error is detected during the setup/teardown process, execution of the
+tests will immediately stop with an error message and the namespace in which
+the tests are run will be destroyed. This is to prevent inaccurate results
+in the test cases.
+
+Repeated failures of the setup/teardown may indicate a problem with the test
+case, or possibly even a bug in one of the commands that are not being tested.
+
+It's possible to include acceptable exit codes with the setup/teardown command
+so that it doesn't halt the script for an error that doesn't matter. Turn the
+individual command into a list, with the command being first, followed by all
+acceptable exit codes for the command.
+
diff --git a/tools/testing/selftests/tc-testing/creating-testcases/template.json b/tools/testing/selftests/tc-testing/creating-testcases/template.json
new file mode 100644
index 0000000..8797174
--- /dev/null
+++ b/tools/testing/selftests/tc-testing/creating-testcases/template.json
@@ -0,0 +1,40 @@
+[
+    {
+        "id": "",
+        "name": "",
+        "category": [
+            "",
+            ""
+        ],
+        "setup": [
+            ""
+        ],
+        "cmdUnderTest": "",
+        "expExitCode": "",
+        "verifyCmd": "",
+        "matchPattern": "",
+        "matchCount": "",
+        "teardown": [
+            ""
+        ]
+    },
+    {
+        "id": "",
+        "name": "",
+        "category": [
+            "",
+            ""
+        ],
+        "setup": [
+            ""
+        ],
+        "cmdUnderTest": "",
+        "expExitCode": "",
+        "verifyCmd": "",
+        "matchPattern": "",
+        "matchCount": "",
+        "teardown": [
+            ""
+        ]
+    }
+]
diff --git a/tools/testing/selftests/tc-testing/tc-tests/actions/tests.json b/tools/testing/selftests/tc-testing/tc-tests/actions/tests.json
new file mode 100644
index 0000000..af519bc
--- /dev/null
+++ b/tools/testing/selftests/tc-testing/tc-tests/actions/tests.json
@@ -0,0 +1,1115 @@
+[
+    {
+        "id": "e89a",
+        "name": "Add valid pass action",
+        "category": [
+            "actions",
+            "gact"
+        ],
+        "setup": [
+            [
+                "$TC actions flush action gact",
+                0,
+                1,
+                255
+            ]
+        ],
+        "cmdUnderTest": "$TC actions add action pass index 8",
+        "expExitCode": "0",
+        "verifyCmd": "$TC actions list action gact",
+        "matchPattern": "action order [0-9]*: gact action pass.*index 8 ref",
+        "matchCount": "1",
+        "teardown": [
+            "$TC actions flush action gact"
+        ]
+    },
+    {
+        "id": "a02c",
+        "name": "Add valid pipe action",
+        "category": [
+            "actions",
+            "gact"
+        ],
+        "setup": [
+            [
+                "$TC actions flush action gact",
+                0,
+                1,
+                255
+            ]
+        ],
+        "cmdUnderTest": "$TC actions add action pipe index 6",
+        "expExitCode": "0",
+        "verifyCmd": "$TC actions list action gact",
+        "matchPattern": "action order [0-9]*: gact action pipe.*index 6 ref",
+        "matchCount": "1",
+        "teardown": [
+            "$TC actions flush action gact"
+        ]
+    },
+    {
+        "id": "feef",
+        "name": "Add valid reclassify action",
+        "category": [
+            "actions",
+            "gact"
+        ],
+        "setup": [
+            [
+                "$TC actions flush action gact",
+                0,
+                1,
+                255
+            ]
+        ],
+        "cmdUnderTest": "$TC actions add action reclassify index 5",
+        "expExitCode": "0",
+        "verifyCmd": "$TC actions list action gact",
+        "matchPattern": "action order [0-9]*: gact action reclassify.*index 5 ref",
+        "matchCount": "1",
+        "teardown": [
+            "$TC actions flush action gact"
+        ]
+    },
+    {
+        "id": "8a7a",
+        "name": "Add valid drop action",
+        "category": [
+            "actions",
+            "gact"
+        ],
+        "setup": [
+            [
+                "$TC actions flush action gact",
+                0,
+                1,
+                255
+            ]
+        ],
+        "cmdUnderTest": "$TC actions add action drop index 30",
+        "expExitCode": "0",
+        "verifyCmd": "$TC actions list action gact",
+        "matchPattern": "action order [0-9]*: gact action drop.*index 30 ref",
+        "matchCount": "1",
+        "teardown": [
+            "$TC actions flush action gact"
+        ]
+    },
+    {
+        "id": "9a52",
+        "name": "Add valid continue action",
+        "category": [
+            "actions",
+            "gact"
+        ],
+        "setup": [
+            [
+                "$TC actions flush action gact",
+                0,
+                1,
+                255
+            ]
+        ],
+        "cmdUnderTest": "$TC actions add action continue index 432",
+        "expExitCode": "0",
+        "verifyCmd": "$TC actions list action gact",
+        "matchPattern": "action order [0-9]*: gact action continue.*index 432 ref",
+        "matchCount": "1",
+        "teardown": [
+            "$TC actions flush action gact"
+        ]
+    },
+    {
+        "id": "d700",
+        "name": "Add invalid action",
+        "category": [
+            "actions",
+            "gact"
+        ],
+        "setup": [
+            [
+                "$TC actions flush action gact",
+                0,
+                1,
+                255
+            ]
+        ],
+        "cmdUnderTest": "$TC actions add action pump index 386",
+        "expExitCode": "255",
+        "verifyCmd": "$TC actions list action gact",
+        "matchPattern": "action order [0-9]*: gact action.*index 386 ref",
+        "matchCount": "0",
+        "teardown": [
+            "$TC actions flush action gact"
+        ]
+    },
+    {
+        "id": "9215",
+        "name": "Add action with duplicate index",
+        "category": [
+            "actions",
+            "gact"
+        ],
+        "setup": [
+            [
+                "$TC actions flush action gact",
+                0,
+                1,
+                255
+            ],
+            "$TC actions add action pipe index 15"
+        ],
+        "cmdUnderTest": "$TC actions add action drop index 15",
+        "expExitCode": "255",
+        "verifyCmd": "$TC actions list action gact",
+        "matchPattern": "action order [0-9]*: gact action drop.*index 15 ref",
+        "matchCount": "0",
+        "teardown": [
+            "$TC actions flush action gact"
+        ]
+    },
+    {
+        "id": "798e",
+        "name": "Add action with index exceeding 32-bit maximum",
+        "category": [
+            "actions",
+            "gact"
+        ],
+        "setup": [
+            [
+                "$TC actions flush action gact",
+                0,
+                1,
+                255
+            ]
+        ],
+        "cmdUnderTest": "$TC actions add action drop index 4294967296",
+        "expExitCode": "255",
+        "verifyCmd": "actions list action gact",
+        "matchPattern": "action order [0-9]*: gact action drop.*index 4294967296 ref",
+        "matchCount": "0",
+        "teardown": [
+            "$TC actions flush action gact"
+        ]
+    },
+    {
+        "id": "22be",
+        "name": "Add action with index at 32-bit maximum",
+        "category": [
+            "actions",
+            "gact"
+        ],
+        "setup": [
+            [
+                "$TC actions flush action gact",
+                0,
+                1,
+                255
+            ]
+        ],
+        "cmdUnderTest": "$TC actions add action drop index 4294967295",
+        "expExitCode": "0",
+        "verifyCmd": "$TC actions list action gact",
+        "matchPattern": "action order [0-9]*: gact action drop.*index 4294967295 ref",
+        "matchCount": "1",
+        "teardown": [
+            "$TC actions flush action gact"
+        ]
+    },
+    {
+        "id": "ac2a",
+        "name": "List actions",
+        "category": [
+            "actions",
+            "gact"
+        ],
+        "setup": [
+            [
+                "$TC actions flush action gact",
+                0,
+                1,
+                255
+            ],
+            "$TC actions add action reclassify index 101",
+            "$TC actions add action reclassify index 102",
+            "$TC actions add action reclassify index 103",
+            "$TC actions add action reclassify index 104",
+            "$TC actions add action reclassify index 105"
+        ],
+        "cmdUnderTest": "$TC actions list action gact",
+        "expExitCode": "0",
+        "verifyCmd": "$TC actions list action gact",
+        "matchPattern": "action order [0-9]*: gact action reclassify",
+        "matchCount": "5",
+        "teardown": [
+            "$TC actions flush action gact"
+        ]
+    },
+    {
+        "id": "63ec",
+        "name": "Delete pass action",
+        "category": [
+            "actions",
+            "gact"
+        ],
+        "setup": [
+            [
+                "$TC actions flush action gact",
+                0,
+                1,
+                255
+            ],
+            "$TC actions add action pass index 1"
+        ],
+        "cmdUnderTest": "$TC actions del action gact index 1",
+        "expExitCode": "0",
+        "verifyCmd": "$TC actions list action gact",
+        "matchPattern": "action order [0-9]*: gact action pass.*index 1 ref",
+        "matchCount": "0",
+        "teardown": [
+            "$TC actions flush action gact"
+        ]
+    },
+    {
+        "id": "46be",
+        "name": "Delete pipe action",
+        "category": [
+            "actions",
+            "gact"
+        ],
+        "setup": [
+            [
+                "$TC actions flush action gact",
+                0,
+                1,
+                255
+            ],
+            "$TC actions add action pipe index 9"
+        ],
+        "cmdUnderTest": "$TC actions del action gact index 9",
+        "expExitCode": "0",
+        "verifyCmd": "$TC actions list action gact",
+        "matchPattern": "action order [0-9]*: gact action pipe.*index 9 ref",
+        "matchCount": "0",
+        "teardown": [
+            "$TC actions flush action gact"
+        ]
+    },
+    {
+        "id": "2e08",
+        "name": "Delete reclassify action",
+        "category": [
+            "actions",
+            "gact"
+        ],
+        "setup": [
+            [
+                "$TC actions flush action gact",
+                0,
+                1,
+                255
+            ],
+            "$TC actions add action reclassify index 65536"
+        ],
+        "cmdUnderTest": "$TC actions del action gact index 65536",
+        "expExitCode": "0",
+        "verifyCmd": "$TC actions list action gact",
+        "matchPattern": "action order [0-9]*: gact action reclassify.*index 65536 ref",
+        "matchCount": "0",
+        "teardown": [
+            "$TC actions flush action gact"
+        ]
+    },
+    {
+        "id": "99c4",
+        "name": "Delete drop action",
+        "category": [
+            "actions",
+            "gact"
+        ],
+        "setup": [
+            [
+                "$TC actions flush action gact",
+                0,
+                1,
+                255
+            ],
+            "$TC actions add action drop index 16"
+        ],
+        "cmdUnderTest": "$TC actions del action gact index 16",
+        "expExitCode": "0",
+        "verifyCmd": "$TC actions list action gact",
+        "matchPattern": "action order [0-9]*: gact action drop.*index 16 ref",
+        "matchCount": "0",
+        "teardown": [
+            "$TC actions flush action gact"
+        ]
+    },
+    {
+        "id": "fb6b",
+        "name": "Delete continue action",
+        "category": [
+            "actions",
+            "gact"
+        ],
+        "setup": [
+            [
+                "$TC actions flush action gact",
+                0,
+                1,
+                255
+            ],
+            "$TC actions add action continue index 32"
+        ],
+        "cmdUnderTest": "$TC actions del action gact index 32",
+        "expExitCode": "0",
+        "verifyCmd": "actions list action gact",
+        "matchPattern": "action order [0-9]*: gact action continue.*index 32 ref",
+        "matchCount": "0",
+        "teardown": [
+            "$TC actions flush action gact"
+        ]
+    },
+    {
+        "id": "0eb3",
+        "name": "Delete non-existent action",
+        "category": [
+            "actions",
+            "gact"
+        ],
+        "setup": [
+            [
+                "$TC actions flush action gact",
+                0,
+                1,
+                255
+            ]
+        ],
+        "cmdUnderTest": "$TC actions del action gact index 2",
+        "expExitCode": "255",
+        "verifyCmd": "$TC actions list action gact",
+        "matchPattern": "action order [0-9]*: gact action",
+        "matchCount": "0",
+        "teardown": [
+            "$TC actions flush action gact"
+        ]
+    },
+    {
+        "id": "5124",
+        "name": "Add mirred mirror to egress action",
+        "category": [
+            "actions",
+            "mirred"
+        ],
+        "setup": [
+            [
+                "$TC actions flush action mirred",
+                0,
+                1,
+                255
+            ]
+        ],
+        "cmdUnderTest": "$TC actions add action mirred egress mirror index 1 dev lo",
+        "expExitCode": "0",
+        "verifyCmd": "$TC actions list action mirred",
+        "matchPattern": "action order [0-9]*: mirred \\(Egress Mirror to device lo\\).*index 1 ref",
+        "matchCount": "1",
+        "teardown": [
+            "$TC actions flush action mirred"
+        ]
+    },
+    {
+        "id": "6fb4",
+        "name": "Add mirred redirect to egress action",
+        "category": [
+            "actions",
+            "mirred"
+        ],
+        "setup": [
+            [
+                "$TC actions flush action mirred",
+                0,
+                1,
+                255
+            ]
+        ],
+        "cmdUnderTest": "$TC actions add action mirred egress redirect index 2 dev lo action pipe",
+        "expExitCode": "0",
+        "verifyCmd": "$TC actions list action mirred",
+        "matchPattern": "action order [0-9]*: mirred \\(Egress Redirect to device lo\\).*index 2 ref",
+        "matchCount": "1",
+        "teardown": [
+            "$TC actions flush action mirred"
+        ]
+    },
+    {
+        "id": "ba38",
+        "name": "Get mirred actions",
+        "category": [
+            "actions",
+            "mirred"
+        ],
+        "setup": [
+            [
+                "$TC actions flush action mirred",
+                0,
+                1,
+                255
+            ],
+            "$TC actions add action mirred egress mirror index 1 dev lo",
+            "$TC actions add action mirred egress redirect index 2 dev lo"
+        ],
+        "cmdUnderTest": "$TC actions show action mirred",
+        "expExitCode": "0",
+        "verifyCmd": "$TC actions list action mirred",
+        "matchPattern": "[Mirror|Redirect] to device lo",
+        "matchCount": "2",
+        "teardown": [
+            "$TC actions flush action mirred"
+        ]
+    },
+    {
+        "id": "d7c0",
+        "name": "Add invalid mirred direction",
+        "category": [
+            "actions",
+            "mirred"
+        ],
+        "setup": [
+            [
+                "$TC actions flush action mirred",
+                0,
+                1,
+                255
+            ]
+        ],
+        "cmdUnderTest": "$TC actions add action mirred inbound mirror index 20 dev lo",
+        "expExitCode": "255",
+        "verifyCmd": "$TC actions list action mirred",
+        "matchPattern": "action order [0-9]*: mirred \\(.*to device lo\\).*index 20 ref",
+        "matchCount": "0",
+        "teardown": [
+            "$TC actions flush action mirred"
+        ]
+    },
+    {
+        "id": "e213",
+        "name": "Add invalid mirred action",
+        "category": [
+            "actions",
+            "mirred"
+        ],
+        "setup": [
+            [
+                "$TC actions flush action mirred",
+                0,
+                1,
+                255
+            ]
+        ],
+        "cmdUnderTest": "$TC actions add action mirred egress remirror index 20 dev lo",
+        "expExitCode": "255",
+        "verifyCmd": "$TC actions list action mirred",
+        "matchPattern": "action order [0-9]*: mirred \\(Egress.*to device lo\\).*index 20 ref",
+        "matchCount": "0",
+        "teardown": [
+            "$TC actions flush action mirred"
+        ]
+    },
+    {
+        "id": "2d89",
+        "name": "Add mirred action with invalid device",
+        "category": [
+            "actions",
+            "mirred"
+        ],
+        "setup": [
+            [
+                "$TC actions flush action mirred",
+                0,
+                1,
+                255
+            ]
+        ],
+        "cmdUnderTest": "$TC actions add action mirred egress mirror index 20 dev eltoh",
+        "expExitCode": "255",
+        "verifyCmd": "$TC actions list action mirred",
+        "matchPattern": "action order [0-9]*: mirred \\(.*to device eltoh\\).*index 20 ref",
+        "matchCount": "0",
+        "teardown": [
+            "$TC actions flush action mirred"
+        ]
+    },
+    {
+        "id": "300b",
+        "name": "Add mirred action with duplicate index",
+        "category": [
+            "actions",
+            "mirred"
+        ],
+        "setup": [
+            [
+                "$TC actions flush action mirred",
+                0,
+                1,
+                255
+            ],
+            "$TC actions add action mirred egress redirect index 15 dev lo"
+        ],
+        "cmdUnderTest": "$TC actions add action mirred egress mirror index 15 dev lo",
+        "expExitCode": "255",
+        "verifyCmd": "$TC actions list action mirred",
+        "matchPattern": "action order [0-9]*: mirred \\(.*to device lo\\).*index 15 ref",
+        "matchCount": "1",
+        "teardown": [
+            "$TC actions flush action mirred"
+        ]
+    },
+    {
+        "id": "a70e",
+        "name": "Delete mirred mirror action",
+        "category": [
+            "actions",
+            "mirred"
+        ],
+        "setup": [
+            [
+                "$TC actions flush action mirred",
+                0,
+                1,
+                255
+            ],
+            "$TC actions add action mirred egress mirror index 5 dev lo"
+        ],
+        "cmdUnderTest": "$TC actions del action mirred index 5",
+        "expExitCode": "0",
+        "verifyCmd": "$TC actions list action mirred",
+        "matchPattern": "action order [0-9]*: mirred \\(Egress Mirror to device lo\\).*index 5 ref",
+        "matchCount": "0",
+        "teardown": [
+            "$TC actions flush action mirred"
+        ]
+    },
+    {
+        "id": "3fb3",
+        "name": "Delete mirred redirect action",
+        "category": [
+            "actions",
+            "mirred"
+        ],
+        "setup": [
+            [
+                "$TC actions flush action mirred",
+                0,
+                1,
+                255
+            ],
+            "$TC actions add action mirred egress redirect index 5 dev lo"
+        ],
+        "cmdUnderTest": "$TC actions del action mirred index 5",
+        "expExitCode": "0",
+        "verifyCmd": "$TC actions list action mirred",
+        "matchPattern": "action order [0-9]*: mirred \\(Egress Redirect to device lo\\).*index 5 ref",
+        "matchCount": "0",
+        "teardown": [
+            "$TC actions flush action mirred"
+        ]
+    },
+    {
+        "id": "b078",
+        "name": "Add simple action",
+        "category": [
+            "actions",
+            "simple"
+        ],
+        "setup": [
+            [
+                "$TC actions flush action simple",
+                0,
+                1,
+                255
+            ]
+        ],
+        "cmdUnderTest": "$TC actions add action simple sdata \"A triumph\" index 60",
+        "expExitCode": "0",
+        "verifyCmd": "$TC actions list action simple",
+        "matchPattern": "action order [0-9]*: Simple <A triumph>.*index 60 ref",
+        "matchCount": "1",
+        "teardown": [
+            "$TC actions flush action simple"
+        ]
+    },
+    {
+        "id": "6d4c",
+        "name": "Add simple action with duplicate index",
+        "category": [
+            "actions",
+            "simple"
+        ],
+        "setup": [
+            [
+                "$TC actions flush action simple",
+                0,
+                1,
+                255
+            ],
+            "$TC actions add action simple sdata \"Aruba\" index 4"
+        ],
+        "cmdUnderTest": "$TC actions add action simple sdata \"Jamaica\" index 4",
+        "expExitCode": "255",
+        "verifyCmd": "$TC actions list action simple",
+        "matchPattern": "action order [0-9]*: Simple <Jamaica>.*ref",
+        "matchCount": "0",
+        "teardown": [
+            "$TC actions flush action simple"
+        ]
+    },
+    {
+        "id": "2542",
+        "name": "List simple actions",
+        "category": [
+            "actions",
+            "simple"
+        ],
+        "setup": [
+            [
+                "$TC actions flush action simple",
+                0,
+                1,
+                255
+            ],
+            "$TC actions add action simple sdata \"Rock\"",
+            "$TC actions add action simple sdata \"Paper\"",
+            "$TC actions add action simple sdata \"Scissors\" index 98"
+        ],
+        "cmdUnderTest": "$TC actions list action simple",
+        "expExitCode": "0",
+        "verifyCmd": "$TC actions list action simple",
+        "matchPattern": "action order [0-9]*: Simple <[A-Z][a-z]*>",
+        "matchCount": "3",
+        "teardown": [
+            "$TC actions flush action simple"
+        ]
+    },
+    {
+        "id": "ea67",
+        "name": "Delete simple action",
+        "category": [
+            "actions",
+            "simple"
+        ],
+        "setup": [
+            [
+                "$TC actions flush action simple",
+                0,
+                1,
+                255
+            ],
+            "$TC actions add action simple sdata \"Blinkenlights\" index 1"
+        ],
+        "cmdUnderTest": "$TC actions delete action simple index 1",
+        "expExitCode": "0",
+        "verifyCmd": "$TC actions list action simple",
+        "matchPattern": "action order [0-9]*: Simple <Blinkenlights>.*index 1 ref",
+        "matchCount": "0",
+        "teardown": [
+            "$TC actions flush action simple"
+        ]
+    },
+    {
+        "id": "8ff1",
+        "name": "Flush simple actions",
+        "category": [
+            "actions",
+            "simple"
+        ],
+        "setup": [
+            [
+                "$TC actions flush action simple",
+                0,
+                1,
+                255
+            ],
+            "$TC actions add action simple sdata \"Kirk\"",
+            "$TC actions add action simple sdata \"Spock\" index 50",
+            "$TC actions add action simple sdata \"McCoy\" index 9"
+        ],
+        "cmdUnderTest": "$TC actions flush action simple",
+        "expExitCode": "0",
+        "verifyCmd": "$TC actions list action simple",
+        "matchPattern": "action order [0-9]*: Simple <[A-Z][a-z]*>",
+        "matchCount": "0",
+        "teardown": [
+            ""
+        ]
+    },
+    {
+        "id": "6236",
+        "name": "Add skbedit action with valid mark",
+        "category": [
+            "actions",
+            "skbedit"
+        ],
+        "setup": [
+            [
+                "$TC actions flush action skbedit",
+                0,
+                1,
+                255
+            ]
+        ],
+        "cmdUnderTest": "$TC actions add action skbedit mark 1",
+        "expExitCode": "0",
+        "verifyCmd": "$TC actions list action skbedit",
+        "matchPattern": "action order [0-9]*:  skbedit mark 1",
+        "matchCount": "1",
+        "teardown": [
+            "$TC actions flush action skbedit"
+        ]
+    },
+    {
+        "id": "407b",
+        "name": "Add skbedit action with invalid mark",
+        "category": [
+            "actions",
+            "skbedit"
+        ],
+        "setup": [
+            [
+                "$TC actions flush action skbedit",
+                0,
+                1,
+                255
+            ]
+        ],
+        "cmdUnderTest": "$TC actions add action skbedit mark 666777888999",
+        "expExitCode": "255",
+        "verifyCmd": "$TC actions list action skbedit",
+        "matchPattern": "action order [0-9]*:  skbedit mark",
+        "matchCount": "0",
+        "teardown": [
+            "$TC actions flush action skbedit"
+        ]
+    },
+    {
+        "id": "081d",
+        "name": "Add skbedit action with priority",
+        "category": [
+            "actions",
+            "skbedit"
+        ],
+        "setup": [
+            [
+                "$TC actions flush action skbedit",
+                0,
+                1,
+                255
+            ]
+        ],
+        "cmdUnderTest": "$TC actions add action skbedit prio 99",
+        "expExitCode": "0",
+        "verifyCmd": "$TC actions list action skbedit",
+        "matchPattern": "action order [0-9]*:  skbedit priority :99",
+        "matchCount": "1",
+        "teardown": [
+            "$TC actions flush action skbedit"
+        ]
+    },
+    {
+        "id": "cc37",
+        "name": "Add skbedit action with invalid priority",
+        "category": [
+            "actions",
+            "skbedit"
+        ],
+        "setup": [
+            [
+                "$TC actions flush action skbedit",
+                0,
+                1,
+                255
+            ]
+        ],
+        "cmdUnderTest": "$TC actions add action skbedit prio foo",
+        "expExitCode": "255",
+        "verifyCmd": "$TC actions list action skbedit",
+        "matchPattern": "action order [0-9]*:  skbedit priority",
+        "matchCount": "0",
+        "teardown": [
+            "$TC actions flush action skbedit"
+        ]
+    },
+    {
+        "id": "3c95",
+        "name": "Add skbedit action with queue_mapping",
+        "category": [
+            "actions",
+            "skbedit"
+        ],
+        "setup": [
+            [
+                "$TC actions flush action skbedit",
+                0,
+                1,
+                255
+            ]
+        ],
+        "cmdUnderTest": "$TC actions add action skbedit queue_mapping 909",
+        "expExitCode": "0",
+        "verifyCmd": "$TC actions list action skbedit",
+        "matchPattern": "action order [0-9]*:  skbedit queue_mapping 909",
+        "matchCount": "1",
+        "teardown": [
+            "$TC actions flush action skbedit"
+        ]
+    },
+    {
+        "id": "985c",
+        "name": "Add skbedit action with invalid queue_mapping",
+        "category": [
+            "actions",
+            "skbedit"
+        ],
+        "setup": [
+            [
+                "$TC actions flush action skbedit",
+                0,
+                1,
+                255
+            ]
+        ],
+        "cmdUnderTest": "$TC actions add action skbedit queue_mapping 67000",
+        "expExitCode": "255",
+        "verifyCmd": "$TC actions list action skbedit",
+        "matchPattern": "action order [0-9]*:  skbedit queue_mapping",
+        "matchCount": "0",
+        "teardown": [
+            "$TC actions flush action skbedit"
+        ]
+    },
+    {
+        "id": "224f",
+        "name": "Add skbedit action with ptype host",
+        "category": [
+            "actions",
+            "skbedit"
+        ],
+        "setup": [
+            [
+                "$TC actions flush action skbedit",
+                0,
+                1,
+                255
+            ]
+        ],
+        "cmdUnderTest": "$TC actions add action skbedit ptype host",
+        "expExitCode": "0",
+        "verifyCmd": "$TC actions list action skbedit",
+        "matchPattern": "action order [0-9]*:  skbedit ptype host",
+        "matchCount": "1",
+        "teardown": [
+            "$TC actions flush action skbedit"
+        ]
+    },
+    {
+        "id": "d1a3",
+        "name": "Add skbedit action with ptype otherhost",
+        "category": [
+            "actions",
+            "skbedit"
+        ],
+        "setup": [
+            [
+                "$TC actions flush action skbedit",
+                0,
+                1,
+                255
+            ]
+        ],
+        "cmdUnderTest": "$TC actions add action skbedit ptype otherhost",
+        "expExitCode": "0",
+        "verifyCmd": "$TC actions list action skbedit",
+        "matchPattern": "action order [0-9]*:  skbedit ptype otherhost",
+        "matchCount": "1",
+        "teardown": [
+            "$TC actions flush action skbedit"
+        ]
+    },
+    {
+        "id": "b9c6",
+        "name": "Add skbedit action with invalid ptype",
+        "category": [
+            "actions",
+            "skbedit"
+        ],
+        "setup": [
+            [
+                "$TC actions flush action skbedit",
+                0,
+                1,
+                255
+            ]
+        ],
+        "cmdUnderTest": "$TC actions add action skbedit ptype openair",
+        "expExitCode": "255",
+        "verifyCmd": "$TC actions list action skbedit",
+        "matchPattern": "action order [0-9]*:  skbedit ptype openair",
+        "matchCount": "0",
+        "teardown": [
+            "$TC actions flush action skbedit"
+        ]
+    },
+    {
+        "id": "5172",
+        "name": "List skbedit actions",
+        "category": [
+            "actions",
+            "skbedit"
+        ],
+        "setup": [
+            [
+                "$TC actions flush action skbedit",
+                0,
+                1,
+                255
+            ],
+            "$TC actions add action skbedit ptype otherhost",
+            "$TC actions add action skbedit ptype broadcast",
+            "$TC actions add action skbedit mark 59",
+            "$TC actions add action skbedit mark 409"
+        ],
+        "cmdUnderTest": "$TC actions list action skbedit",
+        "expExitCode": "0",
+        "verifyCmd": "$TC actions list action skbedit",
+        "matchPattern": "action order [0-9]*:  skbedit",
+        "matchCount": "4",
+        "teardown": [
+            "$TC actions flush action skbedit"
+        ]
+    },
+    {
+        "id": "a6d6",
+        "name": "Add skbedit action with index",
+        "category": [
+            "actions",
+            "skbedit"
+        ],
+        "setup": [
+            [
+                "$TC actions flush action skbedit",
+                0,
+                1,
+                255
+            ]
+        ],
+        "cmdUnderTest": "$TC actions add action skbedit mark 808 index 4040404040",
+        "expExitCode": "0",
+        "verifyCmd": "$TC actions list action skbedit",
+        "matchPattern": "index 4040404040",
+        "matchCount": "1",
+        "teardown": [
+            "$TC actions flush action skbedit"
+        ]
+    },
+    {
+        "id": "38f3",
+        "name": "Delete skbedit action",
+        "category": [
+            "actions",
+            "skbedit"
+        ],
+        "setup": [
+            [
+                "$TC actions flush action skbedit",
+                0,
+                1,
+                255
+            ],
+            "$TC actions add action skbedit mark 42 index 9009"
+        ],
+        "cmdUnderTest": "$TC actions del action skbedit index 9009",
+        "expExitCode": "0",
+        "verifyCmd": "$TC actions list action skbedit",
+        "matchPattern": "action order [0-9]*:  skbedit mark 42",
+        "matchCount": "0",
+        "teardown": [
+            "$TC actions flush action skbedit"
+        ]
+    },
+    {
+        "id": "ce97",
+        "name": "Flush skbedit actions",
+        "category": [
+            "actions",
+            "skbedit"
+        ],
+        "setup": [
+            "$TC actions add action skbedit mark 500",
+            "$TC actions add action skbedit mark 501",
+            "$TC actions add action skbedit mark 502",
+            "$TC actions add action skbedit mark 503",
+            "$TC actions add action skbedit mark 504",
+            "$TC actions add action skbedit mark 505",
+            "$TC actions add action skbedit mark 506"
+        ],
+        "cmdUnderTest": "$TC actions flush action skbedit",
+        "expExitCode": "0",
+        "verifyCmd": "$TC actions list action skbedit",
+        "matchPattern": "action order [0-9]*:  skbedit",
+        "matchCount": "0",
+        "teardown": [
+            "$TC actions flush action skbedit"
+        ]
+    },
+    {
+        "id": "f02c",
+        "name": "Replace gact action",
+        "category": [
+            "actions",
+            "gact"
+        ],
+        "setup": [
+            [
+                "$TC actions flush action gact",
+                0,
+                1,
+                255
+            ],
+            "$TC actions add action drop index 10",
+            "$TC actions add action drop index 12"
+        ],
+        "cmdUnderTest": "$TC actions replace action ok index 12",
+        "expExitCode": "0",
+        "verifyCmd": "$TC actions ls action gact",
+        "matchPattern": "action order [0-9]*: gact action pass",
+        "matchCount": "1",
+        "teardown": [
+            "$TC actions flush action gact"
+        ]
+    },
+    {
+        "id": "525f",
+        "name": "Get gact action by index",
+        "category": [
+            "actions",
+            "gact"
+        ],
+        "setup": [
+            [
+                "$TC actions flush action gact",
+                0,
+                1,
+                255
+            ],
+            "$TC actions add action drop index 3900800700"
+        ],
+        "cmdUnderTest": "$TC actions get action gact index 3900800700",
+        "expExitCode": "0",
+        "verifyCmd": "$TC actions get action gact index 3900800700",
+        "matchPattern": "index 3900800700",
+        "matchCount": "1",
+        "teardown": [
+            "$TC actions flush action gact"
+        ]
+    }
+]
\ No newline at end of file
diff --git a/tools/testing/selftests/tc-testing/tc-tests/filters/tests.json b/tools/testing/selftests/tc-testing/tc-tests/filters/tests.json
new file mode 100644
index 0000000..c727b96
--- /dev/null
+++ b/tools/testing/selftests/tc-testing/tc-tests/filters/tests.json
@@ -0,0 +1,21 @@
+[
+    {
+        "id": "e9a3",
+        "name": "Add u32 with source match",
+        "category": [
+            "filter",
+            "u32"
+        ],
+        "setup": [
+            "$TC qdisc add dev $DEV1 ingress"
+        ],
+        "cmdUnderTest": "$TC filter add dev $DEV1 parent ffff: protocol ip prio 1 u32 match ip src 127.0.0.1/32 flowid 1:1 action ok",
+        "expExitCode": "0",
+        "verifyCmd": "$TC filter show dev $DEV1 parent ffff:",
+        "matchPattern": "match 7f000002/ffffffff at 12",
+        "matchCount": "0",
+        "teardown": [
+            "$TC qdisc del dev $DEV1 ingress"
+        ]
+    }
+]
\ No newline at end of file
diff --git a/tools/testing/selftests/tc-testing/tdc.py b/tools/testing/selftests/tc-testing/tdc.py
new file mode 100755
index 0000000..cd61b78
--- /dev/null
+++ b/tools/testing/selftests/tc-testing/tdc.py
@@ -0,0 +1,413 @@
+#!/usr/bin/env python3
+
+"""
+tdc.py - Linux tc (Traffic Control) unit test driver
+
+Copyright (C) 2017 Lucas Bates <lucasb@mojatatu.com>
+"""
+
+import re
+import os
+import sys
+import argparse
+import json
+import subprocess
+from collections import OrderedDict
+from string import Template
+
+from tdc_config import *
+from tdc_helper import *
+
+
+USE_NS = True
+
+
+def replace_keywords(cmd):
+    """
+    For a given executable command, substitute any known
+    variables contained within NAMES with the correct values
+    """
+    tcmd = Template(cmd)
+    subcmd = tcmd.safe_substitute(NAMES)
+    return subcmd
+
+
+def exec_cmd(command, nsonly=True):
+    """
+    Perform any required modifications on an executable command, then run
+    it in a subprocess and return the results.
+    """
+    if (USE_NS and nsonly):
+        command = 'ip netns exec $NS ' + command
+
+    if '$' in command:
+        command = replace_keywords(command)
+
+    proc = subprocess.Popen(command,
+        shell=True,
+        stdout=subprocess.PIPE,
+        stderr=subprocess.PIPE)
+    (rawout, serr) = proc.communicate()
+
+    if proc.returncode != 0:
+        foutput = serr.decode("utf-8")
+    else:
+        foutput = rawout.decode("utf-8")
+
+    proc.stdout.close()
+    proc.stderr.close()
+    return proc, foutput
+
+
+def prepare_env(cmdlist):
+    """
+    Execute the setup/teardown commands for a test case. Optionally
+    terminate test execution if the command fails.
+    """
+    for cmdinfo in cmdlist:
+        if (type(cmdinfo) == list):
+            exit_codes = cmdinfo[1:]
+            cmd = cmdinfo[0]
+        else:
+            exit_codes = [0]
+            cmd = cmdinfo
+
+        if (len(cmd) == 0):
+            continue
+
+        (proc, foutput) = exec_cmd(cmd)
+
+        if proc.returncode not in exit_codes:
+            print
+            print("Could not execute:")
+            print(cmd)
+            print("\nError message:")
+            print(foutput)
+            print("\nAborting test run.")
+            ns_destroy()
+            exit(1)
+
+
+def test_runner(filtered_tests):
+    """
+    Driver function for the unit tests.
+
+    Prints information about the tests being run, executes the setup and
+    teardown commands and the command under test itself. Also determines
+    success/failure based on the information in the test case and generates
+    TAP output accordingly.
+    """
+    testlist = filtered_tests
+    tcount = len(testlist)
+    index = 1
+    tap = str(index) + ".." + str(tcount) + "\n"
+
+    for tidx in testlist:
+        result = True
+        tresult = ""
+        print("Test " + tidx["id"] + ": " + tidx["name"])
+        prepare_env(tidx["setup"])
+        (p, procout) = exec_cmd(tidx["cmdUnderTest"])
+        exit_code = p.returncode
+
+        if (exit_code != int(tidx["expExitCode"])):
+            result = False
+            print("exit:", exit_code, int(tidx["expExitCode"]))
+            print(procout)
+        else:
+            match_pattern = re.compile(str(tidx["matchPattern"]), re.DOTALL)
+            (p, procout) = exec_cmd(tidx["verifyCmd"])
+            match_index = re.findall(match_pattern, procout)
+            if len(match_index) != int(tidx["matchCount"]):
+                result = False
+
+        if result == True:
+            tresult += "ok "
+        else:
+            tresult += "not ok "
+        tap += tresult + str(index) + " " + tidx["id"] + " " + tidx["name"] + "\n"
+
+        if result == False:
+            tap += procout
+
+        prepare_env(tidx["teardown"])
+        index += 1
+
+    return tap
+
+
+def ns_create():
+    """
+    Create the network namespace in which the tests will be run and set up
+    the required network devices for it.
+    """
+    if (USE_NS):
+        cmd = 'ip netns add $NS'
+        exec_cmd(cmd, False)
+        cmd = 'ip link add $DEV0 type veth peer name $DEV1'
+        exec_cmd(cmd, False)
+        cmd = 'ip link set $DEV1 netns $NS'
+        exec_cmd(cmd, False)
+        cmd = 'ip link set $DEV0 up'
+        exec_cmd(cmd, False)
+        cmd = 'ip -s $NS link set $DEV1 up'
+        exec_cmd(cmd, False)
+
+
+def ns_destroy():
+    """
+    Destroy the network namespace for testing (and any associated network
+    devices as well)
+    """
+    if (USE_NS):
+        cmd = 'ip netns delete $NS'
+        exec_cmd(cmd, False)
+
+
+def has_blank_ids(idlist):
+    """
+    Search the list for empty ID fields and return true/false accordingly.
+    """
+    return not(all(k for k in idlist))
+
+
+def load_from_file(filename):
+    """
+    Open the JSON file containing the test cases and return them as an
+    ordered dictionary object.
+    """
+    with open(filename) as test_data:
+        testlist = json.load(test_data, object_pairs_hook=OrderedDict)
+    idlist = get_id_list(testlist)
+    if (has_blank_ids(idlist)):
+        for k in testlist:
+            k['filename'] = filename
+    return testlist
+
+
+def args_parse():
+    """
+    Create the argument parser.
+    """
+    parser = argparse.ArgumentParser(description='Linux TC unit tests')
+    return parser
+
+
+def set_args(parser):
+    """
+    Set the command line arguments for tdc.
+    """
+    parser.add_argument('-p', '--path', type=str,
+                        help='The full path to the tc executable to use')
+    parser.add_argument('-c', '--category', type=str, nargs='?', const='+c',
+                        help='Run tests only from the specified category, or if no category is specified, list known categories.')
+    parser.add_argument('-f', '--file', type=str,
+                        help='Run tests from the specified file')
+    parser.add_argument('-l', '--list', type=str, nargs='?', const="", metavar='CATEGORY',
+                        help='List all test cases, or those only within the specified category')
+    parser.add_argument('-s', '--show', type=str, nargs=1, metavar='ID', dest='showID',
+                        help='Display the test case with specified id')
+    parser.add_argument('-e', '--execute', type=str, nargs=1, metavar='ID',
+                        help='Execute the single test case with specified ID')
+    parser.add_argument('-i', '--id', action='store_true', dest='gen_id',
+                        help='Generate ID numbers for new test cases')
+    return parser
+    return parser
+
+
+def check_default_settings(args):
+    """
+    Process any arguments overriding the default settings, and ensure the
+    settings are correct.
+    """
+    # Allow for overriding specific settings
+    global NAMES
+
+    if args.path != None:
+         NAMES['TC'] = args.path
+    if not os.path.isfile(NAMES['TC']):
+        print("The specified tc path " + NAMES['TC'] + " does not exist.")
+        exit(1)
+
+
+def get_id_list(alltests):
+    """
+    Generate a list of all IDs in the test cases.
+    """
+    return [x["id"] for x in alltests]
+
+
+def check_case_id(alltests):
+    """
+    Check for duplicate test case IDs.
+    """
+    idl = get_id_list(alltests)
+    return [x for x in idl if idl.count(x) > 1]
+
+
+def does_id_exist(alltests, newid):
+    """
+    Check if a given ID already exists in the list of test cases.
+    """
+    idl = get_id_list(alltests)
+    return (any(newid == x for x in idl))
+
+
+def generate_case_ids(alltests):
+    """
+    If a test case has a blank ID field, generate a random hex ID for it
+    and then write the test cases back to disk.
+    """
+    import random
+    for c in alltests:
+        if (c["id"] == ""):
+            while True:
+                newid = str('%04x' % random.randrange(16**4))
+                if (does_id_exist(alltests, newid)):
+                    continue
+                else:
+                    c['id'] = newid
+                    break
+
+    ufilename = []
+    for c in alltests:
+        if ('filename' in c):
+            ufilename.append(c['filename'])
+    ufilename = get_unique_item(ufilename)
+    for f in ufilename:
+        testlist = []
+        for t in alltests:
+            if 'filename' in t:
+                if t['filename'] == f:
+                    del t['filename']
+                    testlist.append(t)
+        outfile = open(f, "w")
+        json.dump(testlist, outfile, indent=4)
+        outfile.close()
+
+
+def get_test_cases(args):
+    """
+    If a test case file is specified, retrieve tests from that file.
+    Otherwise, glob for all json files in subdirectories and load from
+    each one.
+    """
+    import fnmatch
+    if args.file != None:
+        if not os.path.isfile(args.file):
+            print("The specified test case file " + args.file + " does not exist.")
+            exit(1)
+        flist = [args.file]
+    else:
+        flist = []
+        for root, dirnames, filenames in os.walk('tc-tests'):
+            for filename in fnmatch.filter(filenames, '*.json'):
+                flist.append(os.path.join(root, filename))
+    alltests = list()
+    for casefile in flist:
+        alltests = alltests + (load_from_file(casefile))
+    return alltests
+
+
+def set_operation_mode(args):
+    """
+    Load the test case data and process remaining arguments to determine
+    what the script should do for this run, and call the appropriate
+    function.
+    """
+    alltests = get_test_cases(args)
+
+    if args.gen_id:
+        idlist = get_id_list(alltests)
+        if (has_blank_ids(idlist)):
+            alltests = generate_case_ids(alltests)
+        else:
+            print("No empty ID fields found in test files.")
+        exit(0)
+
+    duplicate_ids = check_case_id(alltests)
+    if (len(duplicate_ids) > 0):
+        print("The following test case IDs are not unique:")
+        print(str(set(duplicate_ids)))
+        print("Please correct them before continuing.")
+        exit(1)
+
+    ucat = get_test_categories(alltests)
+
+    if args.showID:
+        show_test_case_by_id(alltests, args.showID[0])
+        exit(0)
+
+    if args.execute:
+        target_id = args.execute[0]
+    else:
+        target_id = ""
+
+    if args.category:
+        if (args.category == '+c'):
+            print("Available categories:")
+            print_sll(ucat)
+            exit(0)
+        else:
+            target_category = args.category
+    else:
+        target_category = ""
+
+
+    testcases = get_categorized_testlist(alltests, ucat)
+
+    if args.list:
+        if (len(args.list) == 0):
+            list_test_cases(alltests)
+            exit(0)
+        elif(len(args.list > 0)):
+            if (args.list not in ucat):
+                print("Unknown category " + args.list)
+                print("Available categories:")
+                print_sll(ucat)
+                exit(1)
+            list_test_cases(testcases[args.list])
+            exit(0)
+
+    if (os.geteuid() != 0):
+        print("This script must be run with root privileges.\n")
+        exit(1)
+
+    ns_create()
+
+    if (len(target_category) == 0):
+        if (len(target_id) > 0):
+            alltests = list(filter(lambda x: target_id in x['id'], alltests))
+            if (len(alltests) == 0):
+                print("Cannot find a test case with ID matching " + target_id)
+                exit(1)
+        catresults = test_runner(alltests)
+        print("All test results: " + "\n\n" + catresults)
+    elif (len(target_category) > 0):
+        if (target_category not in ucat):
+            print("Specified category is not present in this file.")
+            exit(1)
+        else:
+            catresults = test_runner(testcases[target_category])
+            print("Category " + target_category + "\n\n" + catresults)
+
+    ns_destroy()
+
+
+def main():
+    """
+    Start of execution; set up argument parser and get the arguments,
+    and start operations.
+    """
+    parser = args_parse()
+    parser = set_args(parser)
+    (args, remaining) = parser.parse_known_args()
+    check_default_settings(args)
+
+    set_operation_mode(args)
+
+    exit(0)
+
+
+if __name__ == "__main__":
+    main()
diff --git a/tools/testing/selftests/tc-testing/tdc_config.py b/tools/testing/selftests/tc-testing/tdc_config.py
new file mode 100644
index 0000000..0108737
--- /dev/null
+++ b/tools/testing/selftests/tc-testing/tdc_config.py
@@ -0,0 +1,17 @@
+"""
+tdc_config.py - tdc user-specified values
+
+Copyright (C) 2017 Lucas Bates <lucasb@mojatatu.com>
+"""
+
+# Dictionary containing all values that can be substituted in executable
+# commands.
+NAMES = {
+          # Substitute your own tc path here
+          'TC': '/sbin/tc',
+          # Name of veth devices to be created for the namespace
+          'DEV0': 'v0p0',
+          'DEV1': 'v0p1',
+          # Name of the namespace to use
+          'NS': 'tcut'
+        }
diff --git a/tools/testing/selftests/tc-testing/tdc_helper.py b/tools/testing/selftests/tc-testing/tdc_helper.py
new file mode 100644
index 0000000..c3254f8
--- /dev/null
+++ b/tools/testing/selftests/tc-testing/tdc_helper.py
@@ -0,0 +1,75 @@
+"""
+tdc_helper.py - tdc helper functions
+
+Copyright (C) 2017 Lucas Bates <lucasb@mojatatu.com>
+"""
+
+def get_categorized_testlist(alltests, ucat):
+    """ Sort the master test list into categories. """
+    testcases = dict()
+
+    for category in ucat:
+        testcases[category] = list(filter(lambda x: category in x['category'], alltests))
+
+    return(testcases)
+
+
+def get_unique_item(lst):
+    """ For a list, return a set of the unique items in the list. """
+    return list(set(lst))
+
+
+def get_test_categories(alltests):
+    """ Discover all unique test categories present in the test case file. """
+    ucat = []
+    for t in alltests:
+        ucat.extend(get_unique_item(t['category']))
+        ucat = get_unique_item(ucat)
+    return ucat
+
+def list_test_cases(testlist):
+    """ Print IDs and names of all test cases. """
+    for curcase in testlist:
+        print(curcase['id'] + ': (' + ', '.join(curcase['category']) + ") " + curcase['name'])
+
+
+def list_categories(testlist):
+    """ Show all categories that are present in a test case file. """
+    categories = set(map(lambda x: x['category'], testlist))
+    print("Available categories:")
+    print(", ".join(str(s) for s in categories))
+    print("")
+
+
+def print_list(cmdlist):
+    """ Print a list of strings prepended with a tab. """
+    for l in cmdlist:
+        if (type(l) == list):
+            print("\t" + str(l[0]))
+        else:
+            print("\t" + str(l))
+
+
+def print_sll(items):
+    print("\n".join(str(s) for s in items))
+
+
+def print_test_case(tcase):
+    """ Pretty-printing of a given test case. """
+    for k in tcase.keys():
+        if (type(tcase[k]) == list):
+            print(k + ":")
+            print_list(tcase[k])
+        else:
+            print(k + ": " + tcase[k])
+
+
+def show_test_case_by_id(testlist, caseID):
+    """ Find the specified test case to pretty-print. """
+    if not any(d.get('id', None) == caseID for d in testlist):
+        print("That ID does not exist.")
+        exit(1)
+    else:
+        print_test_case(next((d for d in testlist if d['id'] == caseID)))
+
+
-- 
2.7.4
