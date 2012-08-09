From: Florian Westphal <fw@strlen.de>
Subject: [iproute2][PATCH 2/2] add ematch man page
Date: Thu,  9 Aug 2012 21:18:51 +0200
Message-ID: <1344539931-2653-2-git-send-email-fw@strlen.de>
References: <1344539931-2653-1-git-send-email-fw@strlen.de>
Cc: Florian Westphal <fw@strlen.de>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from Chamillionaire.breakpoint.cc ([80.244.247.6]:39850 "EHLO
	Chamillionaire.breakpoint.cc" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751185Ab2HITVW (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 9 Aug 2012 15:21:22 -0400
In-Reply-To: <1344539931-2653-1-git-send-email-fw@strlen.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

---
 could need more work, but a terse one is better than none.

 man/man8/tc-ematch.8 |  152 ++++++++++++++++++++++++++++++++++++++++++++++++++
 man/man8/tc.8        |    1 +
 2 files changed, 153 insertions(+), 0 deletions(-)
 create mode 100644 man/man8/tc-ematch.8

diff --git a/man/man8/tc-ematch.8 b/man/man8/tc-ematch.8
new file mode 100644
index 0000000..53ae161
--- /dev/null
+++ b/man/man8/tc-ematch.8
@@ -0,0 +1,152 @@
+.TH filter ematch "6 August 2012" iproute2 Linux
+.
+.SH NAME
+ematch \- extended matches for use with "basic" or "flow" filters
+.
+.SH SYNOPSIS
+.sp
+.ad l
+.in +8
+.ti -8
+.B "tc filter add .. basic match"
+.RI EXPR
+.B .. flowid ..
+.sp
+
+.ti -8
+.IR EXPR " := " TERM " [ { "
+.B and | or
+}
+.IR EXPR
+]
+
+.ti -8
+.IR TERM " := [ " not " ] { " MATCH " | '(' " EXPR " ')' } "
+
+.ti -8
+.IR MATCH " := " module " '(' " ARGS " ')' "
+
+.ti -8
+.IR ARGS " := " ARG1 " " ARG2 " ..
+
+.SH MATCHES
+
+.SS cmp
+Simple comparison ematch: arithmetic compare of packet data to a given value.
+.ti
+.IR cmp "( " ALIGN " at " OFFSET " [ " ATTRS " ]  { " eq " | " lt " | " gt "  } " VALUE " )
+
+.ti
+.IR ALIGN " := { " u8 " | " u16 " | " u32 " } "
+
+.ti
+.IR ATTRS " := [  layer " LAYER " ] [ mask " MASK " ] [ " trans " ] "
+
+.ti
+.IR ALIGN " := { " u8 " | " u16 " | " u32 } "
+
+.ti
+.IR LAYER " := { " link " | " network " | " transport " | " 0..%d " }
+
+.SS meta
+Metadata ematch
+.ti
+.IR meta "( " OBJECT " { " eq " | " lt "  |" gt " } " OBJECT " )
+
+.ti
+.IR OBJECT " := { " META_ID " |  " VALUE " }
+
+.ti
+.IR META_ID " := id " [ shift " SHIFT " ] [ mask " MASK " ]
+
+.TP
+meta attributes:
+
+\fBrandom\fP 32 bit random value
+
+\fBloadavg_1\fP Load average in last 5 minutes
+
+\fBnf_mark\fP Netfilter mark
+
+\fBvlan\fP Vlan tag
+
+\fBsk_rcvbuf\fP Receive buffer size
+
+\fBsk_snd_queue\fP Send queue length
+
+.PP
+A full list of meta attributes can be obtained via
+
+# tc filter add dev eth1 basic match 'meta(list)'
+
+.SS nbyte
+match packet data byte sequence
+.ti
+.IR nbyte "( " NEEDLE  " at " OFFSET " [ layer " LAYER " ] )
+
+.ti
+.IR NEEDLE  " := { " string " | " c-escape-sequence "  } "
+
+.ti
+.IR OFFSET  " := " int
+
+.ti
+.IR LAYER " := { " link " | " network " | " transport " | " 0..%d " }
+
+.SS u32
+u32 ematch
+.ti
+.IR u32 "( " ALIGN VALUE MASK " at " [ nexthdr+ ] " OFFSET " )
+
+.ti
+.IR ALIGN " := " { " u8 " | " u16 " | " u32 " }
+
+.SS ipset
+test packet agains ipset membership
+.ti
+.IR ipset "( " SETNAME FLAGS )
+
+.ti
+.IR SETNAME " := " string
+
+.ti
+.IR FLAGS " := " { " FLAG " [, " FLAGS "] }
+
+The flag options are the same as those used by the iptables "set" match.
+
+When using the ipset ematch with the "ip_set_hash:net,iface" set type,
+the interface can be queried using "src,dst (source ip address, outgoing interface) or
+"src,src" (source ip address, incoming interface) syntax.
+
+.SH CAVEATS
+
+The ematch syntax uses '(' and ')' to group expressions. All braces need to be
+escaped properly to prevent shell commandline from interpreting these directly.
+
+When using the ipset ematch with the "ifb" device, the outgoing device will be the
+ifb device itself, e.g. "ifb0".
+The original interface (i.e. the device the packet arrived on) is treated as the incoming interface.
+
+.SH EXAMPLE & USAGE
+
+# tc filter add .. basic match ...
+
+# 'cmp(u16 at 3 layer 2 mask 0xff00 gt 20)'
+
+# 'meta(nfmark gt 24)' and 'meta(tcindex mask 0xf0 eq 0xf0)'
+
+# 'nbyte("ababa" at 12 layer 1)'
+
+# 'u32(u16 0x1122 0xffff at nexthdr+4)'
+
+Check if packet source ip address is member of set named \fBbulk\fP:
+
+# 'ipset(bulk src)'
+
+Check if packet source ip and the interface the packet arrived on is member of "hash:net,iface" set named \fBinteractive\fP:
+
+# 'ipset(interactive src,src)'
+
+.SH "AUTHOR"
+
+The extended match infrastructure was added by Thomas Graf.
diff --git a/man/man8/tc.8 b/man/man8/tc.8
index 95571a3..a285c49 100644
--- a/man/man8/tc.8
+++ b/man/man8/tc.8
@@ -374,6 +374,7 @@ was written by Alexey N. Kuznetsov and added in Linux 2.2.
 .BR tc-choke (8),
 .BR tc-codel (8),
 .BR tc-drr (8),
+.BR tc-ematch (8),
 .BR tc-fq_codel (8),
 .BR tc-hfsc (7),
 .BR tc-hfsc (8),
-- 
1.7.3.4
