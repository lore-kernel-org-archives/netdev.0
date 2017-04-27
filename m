From: Michal Kubecek <mkubecek@suse.cz>
Subject: [PATCH iproute2] routel: fix infinite loop in line parser
Date: Thu, 27 Apr 2017 11:43:47 +0200 (CEST)
Message-ID: <20170427094347.3EB63A0F1C@unicorn.suse.cz>
Cc: netdev@vger.kernel.org
To: Stephen Hemminger <stephen@networkplumber.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx2.suse.de ([195.135.220.15]:37579 "EHLO mx1.suse.de"
        rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
        id S932592AbdD0Jnt (ORCPT <rfc822;netdev@vger.kernel.org>);
        Thu, 27 Apr 2017 05:43:49 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

As noticed by one of the few users of routel script, it ends up in an
infinite loop when they pull out the cable from the NIC used for some
route. This is caused by its parser expecting the line of "ip route show"
output consists of "key value" pairs (except for the initial target range),
together with an old trap of Bourne style shells that "shift 2" does
nothing if there is only one argument left. Some keywords, e.g. "linkdown",
are not followed by a value.

Improve the parser to

  (1) only set variables for keywords we care about
  (2) recognize (currently) known keywords without value

This is still far from perfect (and certainly not future proof) but to
fully fix the script, one would probably have to rewrite the logic
completely (and I'm not sure it's worth the effort).

Signed-off-by: Michal Kubecek <mkubecek@suse.cz>
---
 ip/routel | 20 ++++++++++++++++----
 1 file changed, 16 insertions(+), 4 deletions(-)

diff --git a/ip/routel b/ip/routel
index 8d1d352abdff..9a30462aa6b2 100644
--- a/ip/routel
+++ b/ip/routel
@@ -32,10 +32,22 @@ ip route list table "$@" |
     esac
     while test $# != 0
     do
-       key=$1
-       val=$2
-       eval "$key=$val"
-       shift 2
+       case "$1" in
+          proto|via|dev|scope|src|table)
+             key=$1
+             val=$2
+             eval "$key='$val'"
+             shift 2
+             ;;
+          dead|onlink|pervasive|offload|notify|linkdown|unresolved)
+             shift
+             ;;
+          *)
+             # avoid infinite loop on unknown keyword without value at line end
+             shift
+             shift
+             ;;
+       esac
     done
     echo "$network	$via	$src	$proto	$scope	$dev	$table"
  done | awk -F '	' '
-- 
2.12.2
