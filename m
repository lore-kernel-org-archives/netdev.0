From: Yotam Gigi <yotamg@mellanox.com>
Subject: [PATCH net-next/iproute 2/5] tc: bash-completion: Prepare action autocomplete to support several actions
Date: Mon,  6 Feb 2017 15:19:21 +0200
Message-ID: <1486387164-40404-3-git-send-email-yotamg@mellanox.com>
References: <1486387164-40404-1-git-send-email-yotamg@mellanox.com>
Cc: Yotam Gigi <yotamg@mellanox.com>
To: netdev@vger.kernel.org, stephen@networkplumber.org,
        eladr@mellanox.com, idosch@mellanox.com, jiri@mellanox.com,
        jhs@mojatatu.com, mrv@mojatatu.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-il-dmz.mellanox.com ([193.47.165.129]:51772 "EHLO
        mellanox.co.il" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
        with ESMTP id S1751360AbdBFNQu (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 6 Feb 2017 08:16:50 -0500
In-Reply-To: <1486387164-40404-1-git-send-email-yotamg@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The action autocomplete routine (_tc_action_options) currently does not
support several actions statements in one tc command line as it uses the
_tc_once_attr and _tc_one_from_list.

For example, in that case:

$ tc filter add dev eth0 handle ffff: u32 [...]  \
	   action sample group 5 rate 12 	 \
	   action sample <TAB>

the _tc_once_attr function, when invoked with "group rate" will not
suggest those as they already exist on the command line.

Fix the function to use the _from variant, thus allowing each action
autocomplete start from the action keyword, and not from the beginning of
the command line.

Signed-off-by: Yotam Gigi <yotamg@mellanox.com>
---
 bash-completion/tc | 23 ++++++++++++-----------
 1 file changed, 12 insertions(+), 11 deletions(-)

diff --git a/bash-completion/tc b/bash-completion/tc
index 04f969e..c854dc0 100644
--- a/bash-completion/tc
+++ b/bash-completion/tc
@@ -454,26 +454,28 @@ _tc_filter_options()
 # Returns 0 is completion should stop after running this function, 1 otherwise.
 _tc_action_options()
 {
-    case $1 in
+    local from=$1
+    local action=${words[from]}
+    case $action in
         bpf)
             _tc_bpf_options
             return 0
             ;;
         mirred)
-            _tc_one_of_list 'ingress egress'
-            _tc_one_of_list 'mirror redirect'
-            _tc_once_attr 'index dev'
+            _tc_one_of_list_from $from 'ingress egress'
+            _tc_one_of_list_from $from 'mirror redirect'
+            _tc_once_attr_from $from 'index dev'
             return 0
             ;;
         sample)
-            _tc_once_attr 'rate'
-            _tc_once_attr 'trunc'
-            _tc_once_attr 'group'
+            _tc_once_attr_from $from 'rate'
+            _tc_once_attr_from $from 'trunc'
+            _tc_once_attr_from $from 'group'
             return 0
             ;;
         gact)
-            _tc_one_of_list 'reclassify drop continue pass'
-            _tc_once_attr 'random'
+            _tc_one_of_list_from $from 'reclassify drop continue pass'
+            _tc_once_attr_from $from 'random'
             return 0
             ;;
     esac
@@ -715,8 +717,7 @@ _tc()
                     local action acwd ACTION_KIND=' gact mirred bpf sample '
                     for ((acwd=$subcword; acwd < ${#words[@]}-1; acwd++)); do
                         if [[ $ACTION_KIND =~ ' '${words[acwd]}' ' ]]; then
-                            action=${words[acwd]}
-                            _tc_action_options $action && return 0
+                            _tc_action_options $acwd && return 0
                         fi
                     done
                     _tc_one_of_list $ACTION_KIND
-- 
2.4.11
