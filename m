From: Yotam Gigi <yotamg@mellanox.com>
Subject: [PATCH net-next/iproute 4/5] tc: bash-completion: Add support for filter actions
Date: Mon,  6 Feb 2017 15:19:23 +0200
Message-ID: <1486387164-40404-5-git-send-email-yotamg@mellanox.com>
References: <1486387164-40404-1-git-send-email-yotamg@mellanox.com>
Cc: Yotam Gigi <yotamg@mellanox.com>
To: netdev@vger.kernel.org, stephen@networkplumber.org,
        eladr@mellanox.com, idosch@mellanox.com, jiri@mellanox.com,
        jhs@mojatatu.com, mrv@mojatatu.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-il-dmz.mellanox.com ([193.47.165.129]:51771 "EHLO
        mellanox.co.il" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
        with ESMTP id S1750980AbdBFNQu (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 6 Feb 2017 08:16:50 -0500
In-Reply-To: <1486387164-40404-1-git-send-email-yotamg@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Previously, the autocomplete routine did not complete actions after a
filter keyword, for example:

$ tc filter add dev eth0 u32 [...] action <TAB>

did not suggest the actions list, and:

$ tc filter add dev eth0 u32 [...] action mirred <TAB>

did not suggest the specific mirred parameters. Add the support for this
kind of completion by adding the _tc_filter_action_options routine and
invoking it from inside _tc_filter_options.

Signed-off-by: Yotam Gigi <yotamg@mellanox.com>
---
 bash-completion/tc | 38 +++++++++++++++++++++++++++++++++++---
 1 file changed, 35 insertions(+), 3 deletions(-)

diff --git a/bash-completion/tc b/bash-completion/tc
index e23f69c..e4c6804 100644
--- a/bash-completion/tc
+++ b/bash-completion/tc
@@ -386,11 +386,44 @@ _tc_bpf_options()
     return 0
 }
 
+# Complete with options names for filter actions.
+# This function is recursive, thus allowing multiple actions statement to be
+# parsed.
+# Returns 0 is completion should stop after running this function, 1 otherwise.
+_tc_filter_action_options()
+{
+    for ((acwd=$1; acwd < ${#words[@]}-1; acwd++));
+    do
+        if [[ action == ${words[acwd]} ]]; then
+            _tc_filter_action_options $((acwd+1)) && return 0
+        fi
+    done
+
+    local action acwd
+    for ((acwd=$1; acwd < ${#words[@]}-1; acwd++)); do
+        if [[ $ACTION_KIND =~ ' '${words[acwd]}' ' ]]; then
+            _tc_one_of_list_from $acwd action
+            _tc_action_options $acwd && return 0
+        fi
+    done
+    _tc_one_of_list_from $acwd $ACTION_KIND
+    return 0
+}
+
 # Complete with options names for filters.
 # Returns 0 is completion should stop after running this function, 1 otherwise.
 _tc_filter_options()
 {
-    case $1 in
+
+    for ((acwd=$1; acwd < ${#words[@]}-1; acwd++));
+    do
+        if [[ action == ${words[acwd]} ]]; then
+            _tc_filter_action_options $((acwd+1)) && return 0
+        fi
+    done
+
+    filter=${words[$1]}
+    case $filter in
         basic)
             _tc_once_attr 'match action classid'
             return 0
@@ -685,8 +718,7 @@ _tc()
                     for ((fltwd=$subcword; fltwd < ${#words[@]}-1; fltwd++));
                     do
                         if [[ $FILTER_KIND =~ ' '${words[fltwd]}' ' ]]; then
-                            filter=${words[fltwd]}
-                            _tc_filter_options $filter && return 0
+                            _tc_filter_options $fltwd && return 0
                         fi
                     done
                     _tc_one_of_list $FILTER_KIND
-- 
2.4.11
