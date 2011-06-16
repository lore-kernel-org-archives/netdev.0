From: Fernando Luis Vazquez Cao <fernando@oss.ntt.co.jp>
Subject: [PATCH] iptables: document IPv6 TOS mangling bug in old Linux
 kernels
Date: Thu, 16 Jun 2011 17:36:51 +0900
Message-ID: <1308213411.4062.22.camel@nausicaa>
References: <1307320871-31770-1-git-send-email-pablo@netfilter.org>
	 <1307320871-31770-2-git-send-email-pablo@netfilter.org>
	 <BANLkTikAs7fN2JQJTUwQHAYPPGMf8i9uEA@mail.gmail.com>
	 <alpine.LNX.2.01.1106061618370.17430@frira.zrqbmnf.qr>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Maciej <zenczykowski@gmail.com>, pablo@netfilter.org,
	netfilter-devel@vger.kernel.org, netdev@vger.kernel.org
To: Jan Engelhardt <jengelh@medozas.de>,
	Patrick McHardy <kaber@trash.net>
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <alpine.LNX.2.01.1106061618370.17430@frira.zrqbmnf.qr>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Jan, Patrick,

I would like to get this bug in old Linux kernels documented in the
iptables man page, since it is pretty serious. The fix made into 2.6.39
and I would like to have it backported to 2.6.32-longterm and
2.6.33-longterm. If you disagree with the backport to -longterm please
let me know, I would update the patch accordingly.

---

In Linux kernels up to and including 2.6.38, with the exception of longterm
releases 2.6.32.42 (or later) and 2.6.33.15 (or later), there is a bug (*) whereby
IPv6 TOS mangling does not behave as documented and differs from the IPv4
version. The TOS mask indicates the bits one wants to zero out, so it needs to
be inverted before applying it to the original TOS field. However, the
aformentioned kernels forgo the inversion which breaks --set-tos and its
mnemonics.

(*) Fixed by upstream commit:
    1ed2f73d90fb49bcf5704aee7e9084adb882bfc5 (netfilter: IPv6: fix DSCP mangle code)

Signed-off-by: Fernando Luis Vazquez Cao <fernando@oss.ntt.co.jp>
---

diff -urNp iptables-1.4.11.1-orig/extensions/libxt_TOS.man iptables-1.4.11.1/extensions/libxt_TOS.man
--- iptables-1.4.11.1-orig/extensions/libxt_TOS.man	2011-06-08 22:26:17.000000000 +0900
+++ iptables-1.4.11.1/extensions/libxt_TOS.man	2011-06-16 16:07:34.374062111 +0900
@@ -4,24 +4,26 @@ shares the same bits as DSCP and ECN. Th
 \fBmangle\fP table.
 .TP
 \fB\-\-set\-tos\fP \fIvalue\fP[\fB/\fP\fImask\fP]
-Zeroes out the bits given by \fImask\fP and XORs \fIvalue\fP into the
-TOS/Priority field. If \fImask\fP is omitted, 0xFF is assumed.
+Zeroes out the bits given by \fImask\fP (see \fBBUGS\fP below) and XORs
+\fIvalue\fP into the TOS/Priority field. If \fImask\fP is omitted, 0xFF is
+assumed.
 .TP
 \fB\-\-set\-tos\fP \fIsymbol\fP
 You can specify a symbolic name when using the TOS target for IPv4. It implies
-a mask of 0xFF. The list of recognized TOS names can be obtained by calling
-iptables with \fB\-j TOS \-h\fP.
+a mask of 0xFF (see \fBBUGS\fP below). The list of recognized TOS names can be
+obtained by calling iptables with \fB\-j TOS \-h\fP.
 .PP
 The following mnemonics are available:
 .TP
 \fB\-\-and\-tos\fP \fIbits\fP
 Binary AND the TOS value with \fIbits\fP. (Mnemonic for \fB\-\-set\-tos
-0/\fP\fIinvbits\fP, where \fIinvbits\fP is the binary negation of \fIbits\fP.)
+0/\fP\fIinvbits\fP, where \fIinvbits\fP is the binary negation of \fIbits\fP.
+See \fBBUGS\fP below.)
 .TP
 \fB\-\-or\-tos\fP \fIbits\fP
 Binary OR the TOS value with \fIbits\fP. (Mnemonic for \fB\-\-set\-tos\fP
-\fIbits\fP\fB/\fP\fIbits\fP.)
+\fIbits\fP\fB/\fP\fIbits\fP. See \fBBUGS\fP below.)
 .TP
 \fB\-\-xor\-tos\fP \fIbits\fP
 Binary XOR the TOS value with \fIbits\fP. (Mnemonic for \fB\-\-set\-tos\fP
-\fIbits\fP\fB/0\fP.)
+\fIbits\fP\fB/0\fP. See \fBBUGS\fP below.)
diff -urNp iptables-1.4.11.1-orig/iptables/ip6tables.8.in iptables-1.4.11.1/iptables/ip6tables.8.in
--- iptables-1.4.11.1-orig/iptables/ip6tables.8.in	2011-06-08 22:26:17.000000000 +0900
+++ iptables-1.4.11.1/iptables/ip6tables.8.in	2011-06-16 17:08:42.222014375 +0900
@@ -380,7 +380,18 @@ invalid or abused command line parameter
 other errors cause an exit code of 1.
 .SH BUGS
 Bugs?  What's this? ;-)
+.PP
 Well... the counters are not reliable on sparc64.
+.PP
+In Linux kernels up to and including 2.6.38, with the exception of longterm
+releases 2.6.32.42 (or later) and 2.6.33.15 (or later), there is a bug whereby
+IPv6 TOS mangling does not behave as documented and differs from the IPv4
+version. The TOS mask indicates the bits one wants to zero out, so it needs to
+be inverted before applying it to the original TOS field. However, the
+aformentioned kernels forgo the inversion which breaks --set-tos and its
+mnemonics.
+.PP
+You might also want to have a look at http://bugzilla.netfilter.org/
 .SH COMPATIBILITY WITH IPCHAINS
 This \fBip6tables\fP
 is very similar to ipchains by Rusty Russell.  The main difference is
diff -urNp iptables-1.4.11.1-orig/iptables/iptables.8.in iptables-1.4.11.1/iptables/iptables.8.in
--- iptables-1.4.11.1-orig/iptables/iptables.8.in	2011-06-08 22:26:17.000000000 +0900
+++ iptables-1.4.11.1/iptables/iptables.8.in	2011-06-16 17:08:10.933614702 +0900
@@ -379,7 +379,16 @@ invalid or abused command line parameter
 other errors cause an exit code of 1.
 .SH BUGS
 Bugs?  What's this? ;-)
-Well, you might want to have a look at http://bugzilla.netfilter.org/
+.PP
+In Linux kernels up to and including 2.6.38, with the exception of longterm
+releases 2.6.32.42 (or later) and 2.6.33.15 (or later), there is a bug whereby
+IPv6 TOS mangling does not behave as documented and differs from the IPv4
+version. The TOS mask indicates the bits one wants to zero out, so it needs to
+be inverted before applying it to the original TOS field. However, the
+aformentioned kernels forgo the inversion which breaks --set-tos and its
+mnemonics.
+.PP
+You might also want to have a look at http://bugzilla.netfilter.org/
 .SH COMPATIBILITY WITH IPCHAINS
 This \fBiptables\fP
 is very similar to ipchains by Rusty Russell.  The main difference is


