From: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>
Subject: [PATCH] gaiconf: /etc/gai.conf configuration helper.
Date: Tue, 9 Mar 2010 12:12:53 +0900
Message-ID: <201003090312.o293Crf2004455@94.43.138.210.xn.2iij.net>
Cc: yoshfuji@linux-ipv6.org
To: stephen.hemminger@vyatta.com, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 94.43.138.210.xn.2iij.net ([210.138.43.94]:36538 "EHLO
	94.43.138.210.xn.2iij.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756626Ab0CIDM4 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 8 Mar 2010 22:12:56 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This tool reads /etc/gai.conf, configuration for getaddrinfo(3), and
set up kernel parameter.

Signed-off-by: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>
---
 examples/gaiconf |  134 ++++++++++++++++++++++++++++++++++++++++++++++++++++++
 1 files changed, 134 insertions(+), 0 deletions(-)
 create mode 100644 examples/gaiconf

diff --git a/examples/gaiconf b/examples/gaiconf
new file mode 100644
index 0000000..d75292b
--- /dev/null
+++ b/examples/gaiconf
@@ -0,0 +1,134 @@
+#!/bin/sh
+
+#
+# Setup address label from /etc/gai.conf
+#
+# Written by YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>, 2010.
+#
+
+IP=ip
+DEFAULT_GAICONF=/etc/gai.conf
+verbose=
+debug=
+
+function run ()
+{
+	if [ x"$verbose" != x"" ]; then
+		echo "$@"
+	fi
+	if [ x"$debug" = x"" ]; then
+		"$@"
+	fi
+}
+
+function do_load_config ()
+{
+	file=$1; shift
+	flush=1
+	cat $file | while read command prefix label; do
+		if [ x"$command" = x"#label" ]; then
+			if [ ${flush} = 1 ]; then
+				run ${IP} -6 addrlabel flush
+				flush=0
+			fi
+			run ${IP} -6 addrlabel add prefix $prefix label $label
+		fi
+	done
+}
+
+function do_list_config ()
+{
+	${IP} -6 addrlabel list | while read p pfx l lbl; do
+		echo label ${pfx} ${lbl}
+	done
+}
+
+function help ()
+{
+	echo "Usage: $0 [-v] {--list | --config [ ${DEFAULT_GAICONF} ] | --default}"
+	exit 1
+}
+
+TEMP=`getopt -o c::dlv -l config::,default,list,verbose -n gaiconf -- "$@"`
+
+if [ $? != 0 ]; then
+	echo "Terminating..." >&2
+	exit 1
+fi
+
+TEMPFILE=`mktemp`
+
+eval set -- "$TEMP"
+
+while true ; do
+	case "$1" in
+		-c|--config)
+			if [ x"$cmd" != x"" ]; then
+				help
+			fi
+			case "$2" in
+			"")	gai_conf="${DEFAULT_GAICONF}"
+				shift 2
+				;;
+			*)	gai_conf="$2"
+				shift 2
+			esac
+			cmd=config
+			;;
+		-d|--default)
+			if [ x"$cmd" != x"" ]; then
+				help
+			fi
+			gai_conf=${TEMPFILE}
+			cmd=config
+			;;
+		-l|--list)
+			if [ x"$cmd" != x"" ]; then
+				help
+			fi
+			cmd=list
+			shift
+			;;
+		-v)
+			verbose=1
+			shift
+			;;
+		--)
+			shift;
+			break
+			;;
+		*)
+			echo "Internal error!" >&2
+			exit 1
+			;;
+	esac
+done
+
+case "$cmd" in
+	config)
+		if [ x"$gai_conf" = x"${TEMPFILE}" ]; then
+			sed -e 's/^[[:space:]]*//' <<END_OF_DEFAULT >${TEMPFILE}
+				label ::1/128       0
+				label ::/0          1
+				label 2002::/16     2
+				label ::/96         3
+				label ::ffff:0:0/96 4
+				label fec0::/10     5
+				label fc00::/7      6
+				label 2001:0::/32   7
+END_OF_DEFAULT
+		fi
+		do_load_config "$gai_conf"
+		;;
+	list)
+		do_list_config
+		;;
+	*)
+		help
+		;;
+esac
+
+rm -f "${TEMPFILE}"
+
+exit 0
+
-- 
1.5.6.5

