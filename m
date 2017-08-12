From: Phil Sutter <phil@nwl.cc>
Subject: [iproute PATCH 47/51] examples: Some shell fixes to cbq.init
Date: Sat, 12 Aug 2017 14:05:06 +0200
Message-ID: <20170812120510.28750-48-phil@nwl.cc>
References: <20170812120510.28750-1-phil@nwl.cc>
Cc: netdev@vger.kernel.org
To: Stephen Hemminger <stephen@networkplumber.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from orbyte.nwl.cc ([151.80.46.58]:58479 "EHLO mail.nwl.cc"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751567AbdHLMH2 (ORCPT <rfc822;netdev@vger.kernel.org>);
        Sat, 12 Aug 2017 08:07:28 -0400
In-Reply-To: <20170812120510.28750-1-phil@nwl.cc>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This addresses the following issues:

- $@ is an array, so don't use it in quoted strings - use $* instead.

- Add missing quotes to components of [ ] expressions. These are not
  strictly necessary since the output of 'wc -l' should be a single word
  only, but in case of errors, bash prints "integer expression expected"
  instead of "too many arguments".

- Use -print0/-0 when piping from find to xargs to allow for filenames
  which contain whitespace.

- Quote arguments to 'eval' to prevent word-splitting.

Signed-off-by: Phil Sutter <phil@nwl.cc>
---
 examples/cbq.init-v0.7.3 | 24 ++++++++++++------------
 1 file changed, 12 insertions(+), 12 deletions(-)

diff --git a/examples/cbq.init-v0.7.3 b/examples/cbq.init-v0.7.3
index 1bc0d446f8983..66448d88f0053 100644
--- a/examples/cbq.init-v0.7.3
+++ b/examples/cbq.init-v0.7.3
@@ -532,7 +532,7 @@ cbq_off () {
 
 ### Prefixed message
 cbq_message () {
-	echo -e "**CBQ: $@"
+	echo -e "**CBQ: $*"
 } # cbq_message
 
 ### Failure message
@@ -560,15 +560,15 @@ cbq_time2abs () {
 ### Display CBQ setup
 cbq_show () {
 	for dev in `cbq_device_list`; do
-		[ `tc qdisc show dev $dev| wc -l` -eq 0 ] && continue
+		[ "`tc qdisc show dev $dev| wc -l`" -eq 0 ] && continue
 		echo -e "### $dev: queueing disciplines\n"
 		tc $1 qdisc show dev $dev; echo
 
-		[ `tc class show dev $dev| wc -l` -eq 0 ] && continue
+		[ "`tc class show dev $dev| wc -l`" -eq 0 ] && continue
 		echo -e "### $dev: traffic classes\n"
 		tc $1 class show dev $dev; echo
 
-		[ `tc filter show dev $dev| wc -l` -eq 0 ] && continue
+		[ "`tc filter show dev $dev| wc -l`" -eq 0 ] && continue
 		echo -e "### $dev: filtering rules\n"
 		tc $1 filter show dev $dev; echo
 	done
@@ -585,7 +585,7 @@ cbq_init () {
 
 	### Gather all DEVICE fields from $1/cbq-*
 	DEVFIELDS=`find $1 -maxdepth 1 \( -type f -or -type l \) -name 'cbq-*' \
-		  -not -name '*~' | xargs sed -n 's/#.*//; \
+		  -not -name '*~' -print0 | xargs -0 sed -n 's/#.*//; \
 		  s/[[:space:]]//g; /^DEVICE=[^,]*,[^,]*\(,[^,]*\)\?/ \
 		  { s/.*=//; p; }'| sort -u`
 	[ -z "$DEVFIELDS" ] &&
@@ -593,7 +593,7 @@ cbq_init () {
 
 	### Check for different DEVICE fields for the same device
 	DEVICES=`echo "$DEVFIELDS"| sed 's/,.*//'| sort -u`
-	[ `echo "$DEVICES"| wc -l` -ne `echo "$DEVFIELDS"| wc -l` ] &&
+	[ "`echo "$DEVICES"| wc -l`" -ne "`echo "$DEVFIELDS"| wc -l`" ] &&
 		cbq_failure "different DEVICE fields for single device!\n$DEVFIELDS"
 } # cbq_init
 
@@ -618,7 +618,7 @@ cbq_load_class () {
 	PRIO_MARK=$PRIO_MARK_DEFAULT
 	PRIO_REALM=$PRIO_REALM_DEFAULT
 
-	eval `echo "$CFILE"| grep -E "^($CBQ_WORDS)="`
+	eval "`echo "$CFILE"| grep -E "^($CBQ_WORDS)="`"
 
 	### Require RATE/WEIGHT
 	[ -z "$RATE" -o -z "$WEIGHT" ] &&
@@ -661,7 +661,7 @@ if [ "$1" = "compile" ]; then
 
 	### echo-only version of "tc" command
 	tc () {
-		echo "$TC $@"
+		echo "$TC $*"
 	} # tc
 
 elif [ -n "$CBQ_DEBUG" ]; then
@@ -669,13 +669,13 @@ elif [ -n "$CBQ_DEBUG" ]; then
 
 	### Logging version of "ip" command
 	ip () {
-		echo -e "\n# ip $@" >> $CBQ_DEBUG
+		echo -e "\n# ip $*" >> $CBQ_DEBUG
 		$IP "$@" 2>&1 | tee -a $CBQ_DEBUG
 	} # ip
 
 	### Logging version of "tc" command
 	tc () {
-		echo -e "\n# tc $@" >> $CBQ_DEBUG
+		echo -e "\n# tc $*" >> $CBQ_DEBUG
 		$TC "$@" 2>&1 | tee -a $CBQ_DEBUG
 	} # tc
 else
@@ -711,8 +711,8 @@ if [ "$1" != "compile" -a "$2" != "nocache" -a -z "$CBQ_DEBUG" ]; then
 	### validate the cache
 	[ "$2" = "invalidate" -o ! -f $CBQ_CACHE ] && VALID=0
 	if [ $VALID -eq 1 ]; then
-		[ `find $CBQ_PATH -maxdepth 1 -newer $CBQ_CACHE| \
-		  wc -l` -gt 0 ] && VALID=0
+		[ "`find $CBQ_PATH -maxdepth 1 -newer $CBQ_CACHE| \
+		  wc -l`" -gt 0 ] && VALID=0
 	fi
 
 	### compile the config if the cache is invalid
-- 
2.13.1
