From: Jamal Hadi Salim <jhs@mojatatu.com>
Subject: [PATCH iproute2 9/9] man pages: add man page for skbmod action
Date: Sat,  1 Oct 2016 16:48:37 -0400
Message-ID: <1475354917-7912-10-git-send-email-jhs@emojatatu.com>
References: <1475354917-7912-1-git-send-email-jhs@emojatatu.com>
Cc: netdev@vger.kernel.org, Lucas Bates <lucasb@mojatatu.com>,
        Jamal Hadi Salim <jhs@mojatatu.com>
To: stephen@networkplumber.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f68.google.com ([209.85.220.68]:36758 "EHLO
        mail-pa0-f68.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752060AbcJAUtQ (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sat, 1 Oct 2016 16:49:16 -0400
Received: by mail-pa0-f68.google.com with SMTP id cd13so4517384pac.3
        for <netdev@vger.kernel.org>; Sat, 01 Oct 2016 13:49:02 -0700 (PDT)
In-Reply-To: <1475354917-7912-1-git-send-email-jhs@emojatatu.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Lucas Bates <lucasb@mojatatu.com>

Signed-off-by: Lucas Bates <lucasb@mojatatu.com>
Signed-off-by: Jamal Hadi Salim <jhs@mojatatu.com>
---
 man/man8/Makefile    |   2 +-
 man/man8/tc-skbmod.8 | 137 +++++++++++++++++++++++++++++++++++++++++++++++++++
 2 files changed, 138 insertions(+), 1 deletion(-)
 create mode 100644 man/man8/tc-skbmod.8

diff --git a/man/man8/Makefile b/man/man8/Makefile
index 4ad96ce..de6f249 100644
--- a/man/man8/Makefile
+++ b/man/man8/Makefile
@@ -16,7 +16,7 @@ MAN8PAGES = $(TARGETS) ip.8 arpd.8 lnstat.8 routel.8 rtacct.8 rtmon.8 rtpr.8 ss.
 	tc-basic.8 tc-cgroup.8 tc-flow.8 tc-flower.8 tc-fw.8 tc-route.8 \
 	tc-tcindex.8 tc-u32.8 tc-matchall.8 \
 	tc-connmark.8 tc-csum.8 tc-mirred.8 tc-nat.8 tc-pedit.8 tc-police.8 \
-	tc-simple.8 tc-skbedit.8 tc-vlan.8 tc-xt.8  tc-ife.8 \
+	tc-simple.8 tc-skbedit.8 tc-vlan.8 tc-xt.8  tc-ife.8 tc-skbmod.8 \
 	devlink.8 devlink-dev.8 devlink-monitor.8 devlink-port.8 devlink-sb.8
 
 all: $(TARGETS)
diff --git a/man/man8/tc-skbmod.8 b/man/man8/tc-skbmod.8
new file mode 100644
index 0000000..6efe9b6
--- /dev/null
+++ b/man/man8/tc-skbmod.8
@@ -0,0 +1,137 @@
+.TH "skbmod action in tc" 8 "21 Sep 2016" "iproute2" "Linux"
+
+.SH NAME
+skbmod - user-friendly packet editor action
+.SH SYNOPSIS
+.in +8
+.ti -8
+.BR tc " ... " "action skbmod " "{ [ " "set "
+.IR SETTABLE " ] [ "
+.BI swap " SWAPPABLE"
+.RI " ] [ " CONTROL " ] [ "
+.BI index " INDEX "
+] }
+
+.ti -8
+.IR SETTABLE " := "
+.RB " [ " dmac
+.IR DMAC " ] "
+.RB " [ " smac
+.IR SMAC " ] "
+.RB " [ " etype
+.IR ETYPE " ] "
+
+.ti -8
+.IR SWAPPABLE " := "
+.B mac
+.ti -8                                                                          
+.IR CONTROL " := {"                                                             
+.BR reclassify " | " pipe " | " drop " | " shot " | " continue " | " pass " }"
+.SH DESCRIPTION
+The
+.B skbmod
+action is intended as a usability upgrade to the existing
+.B pedit
+action. Instead of having to manually edit 8-, 16-, or 32-bit chunks of an
+ethernet header, 
+.B skbmod
+allows complete substitution of supported elements.
+.SH OPTIONS
+.TP
+.BI dmac " DMAC"
+Change the destination mac to the specified address.
+.TP
+.BI smac " SMAC"
+Change the source mac to the specified address.
+.TP
+.BI etype " ETYPE"
+Change the ethertype to the specified value.
+.TP
+.BI mac
+Used to swap mac addresses. The 
+.B swap mac
+directive is performed
+after any outstanding D/SMAC changes.
+.TP                                                                             
+.I CONTROL                                                                      
+The following keywords allow to control how the tree of qdisc, classes,         
+filters and actions is further traversed after this action.                     
+.RS                                                                             
+.TP                                                                             
+.B reclassify                                                                   
+Restart with the first filter in the current list.                              
+.TP                                                                             
+.B pipe                                                                         
+Continue with the next action attached to the same filter.                      
+.TP                                                                             
+.B drop                                                                         
+.TQ                                                                             
+.B shot                                                                         
+Drop the packet.                                                                
+.TP                                                                             
+.B continue                                                                     
+Continue classification with the next filter in line.                           
+.TP
+.B pass                                                                         
+Finish classification process and return to calling qdisc for further packet    
+processing. This is the default.
+.SH EXAMPLES
+To start, observe the following filter with a pedit action:
+
+.RS
+.EX
+tc filter add dev eth1 parent 1: protocol ip prio 10 \\
+	u32 match ip protocol 1 0xff flowid 1:2 \\
+	action pedit munge offset -14 u8 set 0x02 \\
+	munge offset -13 u8 set 0x15 \\
+	munge offset -12 u8 set 0x15 \\
+	munge offset -11 u8 set 0x15 \\
+	munge offset -10 u16 set 0x1515 \\
+	pipe
+.EE
+.RE
+
+Using the skbmod action, this command can be simplified to:
+
+.RS
+.EX
+tc filter add dev eth1 parent 1: protocol ip prio 10 \\
+	u32 match ip protocol 1 0xff flowid 1:2 \\
+	action skbmod set dmac 02:15:15:15:15:15 \\
+	pipe
+.EE
+.RE
+
+Complexity will increase if source mac and ethertype are also being edited
+as part of the action. If all three fields are to be changed with skbmod:
+
+.RS
+.EX
+tc filter add dev eth5 parent 1: protocol ip prio 10 \\
+	u32 match ip protocol 1 0xff flowid 1:2 \\
+	action skbmod \\
+	set etype 0xBEEF \\
+	set dmac 02:12:13:14:15:16 \\
+	set smac 02:22:23:24:25:26
+.EE
+.RE
+
+Finally, swap the destination and source mac addresses in the header:
+
+.RS
+.EX
+tc filter add dev eth3 parent 1: protocol ip prio 10 \\
+	u32 match ip protocol 1 0xff flowid 1:2 \\
+	action skbmod \\
+	swap mac
+.EE
+.RE
+
+As mentioned above, the swap action will occur after any
+.B " smac/dmac "
+substitutions are executed, if they are present.
+
+.SH SEE ALSO
+.BR tc (8),
+.BR tc-u32 (8),
+.BR tc-pedit (8)
-- 
1.9.1
