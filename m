From: Jesper Dangaard Brouer <brouer@redhat.com>
Subject: [net-next PATCH 06/10] pktgen: new pktgen helper functions for
	samples scripts
Date: Tue, 19 May 2015 23:36:08 +0200
Message-ID: <20150519213608.9070.31995.stgit@ivy>
References: <20150519213326.9070.18264.stgit@ivy>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: Jesper Dangaard Brouer <brouer@redhat.com>,
	Daniel Borkmann <borkmann@iogearbox.net>,
	Alexei Starovoitov <ast@plumgrid.com>,
	Robert Olsson <robert@herjulf.se>,
	Ben Greear <greearb@candelatech.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:34311 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751789AbbESVgh (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 19 May 2015 17:36:37 -0400
In-Reply-To: <20150519213326.9070.18264.stgit@ivy>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Preparing for removing existing samples/pktgen/ scripts, and
replacing these with easier to use samples.

This commit provides two helper shell files, that can
be "included" by shell source'ing. Namely "functions.sh"
and "parameters.sh".

The parameters.sh file support easy and consistant parameter
parsing across the sample scripts.  Usage example is printed on
errors.

The functions.sh file provides, three new shell functions for
configuring the different components of pktgen: pg_ctrl(),
pg_thread() and pg_set().  A slightly improved version of the old
pgset() function is also provided for backwards compat.

The new functions correspond to pktgens different components.
 * pg_ctrl()   control "pgctrl" (/proc/net/pktgen/pgctrl)
 * pg_thread() control the kernel threads and binding to devices
 * pg_set()    control setup of individual devices

These changes are borrowed from:
 https://github.com/netoptimizer/network-testing/tree/master/pktgen

Signed-off-by: Jesper Dangaard Brouer <brouer@redhat.com>
---

 samples/pktgen/README.rst    |   43 +++++++++++++++
 samples/pktgen/functions.sh  |  120 ++++++++++++++++++++++++++++++++++++++++++
 samples/pktgen/parameters.sh |   97 ++++++++++++++++++++++++++++++++++
 3 files changed, 260 insertions(+), 0 deletions(-)
 create mode 100644 samples/pktgen/README.rst
 create mode 100644 samples/pktgen/functions.sh
 create mode 100644 samples/pktgen/parameters.sh

diff --git a/samples/pktgen/README.rst b/samples/pktgen/README.rst
new file mode 100644
index 0000000..8365c4e
--- /dev/null
+++ b/samples/pktgen/README.rst
@@ -0,0 +1,43 @@
+Sample and benchmark scripts for pktgen (packet generator)
+==========================================================
+This directory contains some pktgen sample and benchmark scripts, that
+can easily be copied and adjusted for your own use-case.
+
+General doc is located in kernel: Documentation/networking/pktgen.txt
+
+Helper include files
+====================
+This directory contains two helper shell files, that can be "included"
+by shell source'ing.  Namely "functions.sh" and "parameters.sh".
+
+Common parameters
+-----------------
+The parameters.sh file support easy and consistant parameter parsing
+across the sample scripts.  Usage example is printed on errors::
+
+ Usage: ./pktgen_sample01_simple.sh [-vx] -i ethX
+  -i : ($DEV)       output interface/device (required)
+  -s : ($PKT_SIZE)  packet size
+  -d : ($DEST_IP)   destination IP
+  -m : ($DST_MAC)   destination MAC-addr
+  -t : ($THREADS)   threads to start
+  -c : ($SKB_CLONE) SKB clones send before alloc new SKB
+  -b : ($BURST)     HW level bursting of SKBs
+  -v : ($VERBOSE)   verbose
+  -x : ($DEBUG)     debug
+
+The global variable being set is also listed.  E.g. the required
+interface/device parameter "-i" sets variable $DEV.
+
+Common functions
+----------------
+The functions.sh file provides; Three different shell functions for
+configuring the different components of pktgen: pg_ctrl(), pg_thread()
+and pg_set().
+
+These functions correspond to pktgens different components.
+ * pg_ctrl()   control "pgctrl" (/proc/net/pktgen/pgctrl)
+ * pg_thread() control the kernel threads and binding to devices
+ * pg_set()    control setup of individual devices
+
+See sample scripts for usage examples.
diff --git a/samples/pktgen/functions.sh b/samples/pktgen/functions.sh
new file mode 100644
index 0000000..8bbe1c1
--- /dev/null
+++ b/samples/pktgen/functions.sh
@@ -0,0 +1,120 @@
+#
+# Common functions used by pktgen scripts
+#  - Depending on bash 3 (or higher) syntax
+#
+# Author: Jesper Dangaaard Brouer
+# License: GPL
+
+## -- General shell logging cmds --
+function err() {
+    local exitcode=$1
+    shift
+    echo "ERROR: $@" >&2
+    exit $exitcode
+}
+
+function warn() {
+    echo "WARN : $@" >&2
+}
+
+function info() {
+    if [[ -n "$VERBOSE" ]]; then
+	echo "INFO : $@" >&2
+    fi
+}
+
+## -- Pktgen proc config commands -- ##
+export PROC_DIR=/proc/net/pktgen
+#
+# Three different shell functions for configuring the different
+# components of pktgen:
+#   pg_ctrl(), pg_thread() and pg_set().
+#
+# These functions correspond to pktgens different components.
+# * pg_ctrl()   control "pgctrl" (/proc/net/pktgen/pgctrl)
+# * pg_thread() control the kernel threads and binding to devices
+# * pg_set()    control setup of individual devices
+function pg_ctrl() {
+    local proc_file="pgctrl"
+    proc_cmd ${proc_file} "$@"
+}
+
+function pg_thread() {
+    local thread=$1
+    local proc_file="kpktgend_${thread}"
+    shift
+    proc_cmd ${proc_file} "$@"
+}
+
+function pg_set() {
+    local dev=$1
+    local proc_file="$dev"
+    shift
+    proc_cmd ${proc_file} "$@"
+}
+
+# More generic replacement for pgset(), that does not depend on global
+# variable for proc file.
+function proc_cmd() {
+    local result
+    local proc_file=$1
+    # after shift, the remaining args are contained in $@
+    shift
+    local proc_ctrl=${PROC_DIR}/$proc_file
+    if [[ ! -e "$proc_ctrl" ]]; then
+	err 3 "proc file:$proc_ctrl does not exists (dev added to thread?)"
+    else
+	if [[ ! -w "$proc_ctrl" ]]; then
+	    err 4 "proc file:$proc_ctrl not writable, not root?!"
+	fi
+    fi
+
+    if [[ "$DEBUG" == "yes" ]]; then
+	echo "cmd: $@ > $proc_ctrl"
+    fi
+    # Quoting of "$@" is important for space expansion
+    echo "$@" > "$proc_ctrl"
+    local status=$?
+
+    result=`cat $proc_ctrl | fgrep "Result: OK:"`
+    if [[ "$result" == "" ]]; then
+	cat $proc_ctrl | fgrep Result: >&2
+    fi
+    if (( $status != 0 )); then
+	err 5 "Write error($status) occured cmd: \"$@ > $proc_ctrl\""
+    fi
+}
+
+# Old obsolete "pgset" function, with slightly improved err handling
+function pgset() {
+    local result
+
+    if [[ "$DEBUG" == "yes" ]]; then
+	echo "cmd: $1 > $PGDEV"
+    fi
+    echo $1 > $PGDEV
+    local status=$?
+
+    result=`cat $PGDEV | fgrep "Result: OK:"`
+    if [[ "$result" == "" ]]; then
+         cat $PGDEV | fgrep Result:
+    fi
+    if (( $status != 0 )); then
+	err 5 "Write error($status) occurred cmd: \"$1 > $PGDEV\""
+    fi
+}
+
+## -- General shell tricks --
+
+function root_check_run_with_sudo() {
+    # Trick so, program can be run as normal user, will just use "sudo"
+    #  call as root_check_run_as_sudo "$@"
+    if [ "$EUID" -ne 0 ]; then
+	if [ -x $0 ]; then # Directly executable use sudo
+	    info "Not root, running with sudo"
+            sudo "$0" "$@"
+            exit $?
+	fi
+	err 4 "cannot perform sudo run of $0"
+    fi
+}
diff --git a/samples/pktgen/parameters.sh b/samples/pktgen/parameters.sh
new file mode 100644
index 0000000..33b70fd
--- /dev/null
+++ b/samples/pktgen/parameters.sh
@@ -0,0 +1,97 @@
+#
+# Common parameter parsing for pktgen scripts
+#
+
+function usage() {
+    echo ""
+    echo "Usage: $0 [-vx] -i ethX"
+    echo "  -i : (\$DEV)       output interface/device (required)"
+    echo "  -s : (\$PKT_SIZE)  packet size"
+    echo "  -d : (\$DEST_IP)   destination IP"
+    echo "  -m : (\$DST_MAC)   destination MAC-addr"
+    echo "  -t : (\$THREADS)   threads to start"
+    echo "  -c : (\$SKB_CLONE) SKB clones send before alloc new SKB"
+    echo "  -b : (\$BURST)     HW level bursting of SKBs"
+    echo "  -v : (\$VERBOSE)   verbose"
+    echo "  -x : (\$DEBUG)     debug"
+    echo ""
+}
+
+##  --- Parse command line arguments / parameters ---
+## echo "Commandline options:"
+while getopts "s:i:d:m:t:c:b:vxh" option; do
+    case $option in
+        i) # interface
+          export DEV=$OPTARG
+	  info "Output device set to: DEV=$DEV"
+          ;;
+        s)
+          export PKT_SIZE=$OPTARG
+	  info "Packet size set to: PKT_SIZE=$PKT_SIZE bytes"
+          ;;
+        d) # destination IP
+          export DEST_IP=$OPTARG
+	  info "Destination IP set to: DEST_IP=$DEST_IP"
+          ;;
+        m) # MAC
+          export DST_MAC=$OPTARG
+	  info "Destination MAC set to: DST_MAC=$DST_MAC"
+          ;;
+        t)
+	  export THREADS=$OPTARG
+          export CPU_THREADS=$OPTARG
+	  let "CPU_THREADS -= 1"
+	  info "Number of threads to start: $THREADS (0 to $CPU_THREADS)"
+          ;;
+        c)
+	  export CLONE_SKB=$OPTARG
+	  info "CLONE_SKB=$CLONE_SKB"
+          ;;
+        b)
+	  export BURST=$OPTARG
+	  info "SKB bursting: BURST=$BURST"
+          ;;
+        v)
+          export VERBOSE=yes
+          info "Verbose mode: VERBOSE=$VERBOSE"
+          ;;
+        x)
+          export DEBUG=yes
+          info "Debug mode: DEBUG=$DEBUG"
+          ;;
+        h|?|*)
+          usage;
+          err 2 "[ERROR] Unknown parameters!!!"
+    esac
+done
+shift $(( $OPTIND - 1 ))
+
+if [ -z "$PKT_SIZE" ]; then
+    # NIC adds 4 bytes CRC
+    export PKT_SIZE=60
+    info "Default packet size set to: set to: $PKT_SIZE bytes"
+fi
+
+if [ -z "$THREADS" ]; then
+    # Zero CPU threads means one thread, because CPU numbers are zero indexed
+    export CPU_THREADS=0
+    export THREADS=1
+fi
+
+if [ -z "$DEV" ]; then
+    usage
+    err 2 "Please specify output device"
+fi
+
+if [ -z "$DST_MAC" ]; then
+    warn "Missing destination MAC address"
+fi
+
+if [ -z "$DEST_IP" ]; then
+    warn "Missing destination IP address"
+fi
+
+if [ ! -d /proc/net/pktgen ]; then
+    info "Loading kernel module: pktgen"
+    modprobe pktgen
+fi
