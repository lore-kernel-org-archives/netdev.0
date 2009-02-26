From: Michal Soltys <soltys@ziu.info>
Subject: [PATCH/RFC 2/2] Stab documentation + assorted changes
Date: Fri, 27 Feb 2009 00:01:32 +0100
Message-ID: <42942bc393c0bf4236ac62aca3af731b1a883452.1235685021.git.soltys@ziu.info>
References: <cover.1235685021.git.soltys@ziu.info>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from relay.ppgk.com.pl ([80.53.243.36]:13521 "EHLO relay.ppgk.com.pl"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755050AbZBZXWK (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 26 Feb 2009 18:22:10 -0500
Received: from localhost.ppgk.com.pl (localhost [127.0.0.1])
	by relay.ppgk.com.pl (Postfix) with ESMTP id D9E5C3761E
	for <netdev@vger.kernel.org>; Fri, 27 Feb 2009 00:13:40 +0100 (CET)
Received: from relay.ppgk.com.pl ([127.0.0.1])
	by localhost.ppgk.com.pl (relay.ppgk.com.pl [127.0.0.1]) (amavisd-new, port 10024)
	with LMTP id 66LfjS9fZyNM for <netdev@vger.kernel.org>;
	Fri, 27 Feb 2009 00:13:40 +0100 (CET)
Received: from localhost.localdomain (87-205-204-139.adsl.inetia.pl [87.205.204.139])
	(using TLSv1 with cipher DHE-RSA-AES256-SHA (256/256 bits))
	(Client did not present a certificate)
	by relay.ppgk.com.pl (Postfix) with ESMTPSA id 64EDE3761C
	for <netdev@vger.kernel.org>; Fri, 27 Feb 2009 00:13:39 +0100 (CET)
In-Reply-To: <cover.1235685021.git.soltys@ziu.info>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This adds generic explanation about size tables.

tc-stab(8): Commandline + details
One thing I'm not sure, is whenever any layer2 data is included in case
of shaping directly on ppp interface (see the bottom of the man page).

tc_stab.c: small fixes to commandline help

tc_core.c:
As kernel part of things relies on cell align which is always set to
-1, I also added it to userspace computation stage. This way if someone
specified e.g. 2048 and 512 for mtu and tsize respectively, one wouldn't
end with tsize supporting mtu 4096 suddenly, New default mtu is also set
to 2048 (disregarding weirdness of setting mtu to such values).

Unless I missed something, this is harmless and feels cleaner, but if it's
not allowed, documentation will have to be changed back to 2047 + extra
explanation as well.
---
 man/man8/tc-stab.8 |  156 ++++++++++++++++++++++++++++++++++++++++++++++++++++
 tc/tc_core.c       |    4 +-
 tc/tc_stab.c       |    9 ++-
 3 files changed, 163 insertions(+), 6 deletions(-)
 create mode 100644 man/man8/tc-stab.8

diff --git a/man/man8/tc-stab.8 b/man/man8/tc-stab.8
new file mode 100644
index 0000000..9e84f25
--- /dev/null
+++ b/man/man8/tc-stab.8
@@ -0,0 +1,156 @@
+.TH STAB 8 "25 February 2009" iproute2 Linux
+.
+.SH NAME
+tc\-stab \- Generic size table manipulations
+.
+.SH SYNOPSIS
+.nf
+tc qdisc add ... stab \\
+.RS 4
+[ \fBmtu\fR BYTES ] [ \fBtsize\fR SLOTS ] \\
+[ \fBmpu\fR BYTES ] [ \fBoverhead\fR BYTES ] [ \fBlinklayer\fR TYPE ] ...
+.RE
+
+TYPE := adsl | atm | ethernet
+.fi
+
+For the description of BYTES \- please refer to the \fBUNITS\fR
+section of \fBtc\fR(8).
+
+.IP \fBmtu\fR 4
+.br
+maximum packet size we create size table for, assumed 2048 if not specified explicitly
+.IP \fBtsize\fR
+.br
+required table size, assumed 512 if not specified explicitly
+.IP \fBmpu\fR
+.br
+minimum packet size used in computations
+.IP \fBoverhead\fR
+.br
+per\-packet size overhead (can be negative) used in computations
+.IP \fBlinklayer\fR
+.br
+required linklayer adaptation.
+.PP
+.
+.SH DESCRIPTION
+.
+Size tables allow manipulation of packet size, as seen by whole scheduler
+framework (of course, the actual packet size remains the same). Adjusted packet
+size is calculated only once \- when a qdisc enqueues the packet. Initial root
+enqueue initializes it to the real packet's size.
+
+Each qdisc can use different size table, but the adjusted size is stored in
+area shared by whole qdisc hierarchy attached to the interface (technically,
+it's stored in skb). The effect is, that if you have such setup, the last qdisc
+with a stab in a chain "wins". For example, consider HFSC with simple pfifo
+attached to one of its leaf classes. If that pfifo qdisc has stab defined, it
+will override lengths calculated during HFSC's enqueue, and in turn, whenever
+HFSC tries to dequeue a packet, it will use potentially invalid size in its
+calculations. Normal setups will usually include stab defined only on root
+qdisc, but further overriding gives extra flexibility for less usual setups.
+
+Initial size table is calculated by \fBtc\fR tool using \fBmtu\fR and
+\fBtsize\fR parameters. The algorithm sets each slot's size to the smallest
+power of 2 value, so the whole \fBmtu\fR is covered by the size table. Neither
+\fBtsize\fR, nor \fBmtu\fR have to be power of 2 value, so the size
+table will usually support more than is required by \fBmtu\fR.
+
+For example, with \fBmtu\fR\~=\~1500 and \fBtsize\fR\~=\~128, a table with 128
+slots will be created, where slot 0 will correspond to sizes 0\-16, slot 1 to
+17\~\-\~32, \&..., slot 127 to 2033\~\-\~2048. Note, that the sizes
+are shifted 1 byte (normally you would expect 0\~\-\~15, 16\~\-\~31, \&...,
+2032\~\-\~2047). Sizes assigned to each slot depend on \fBlinklayer\fR parameter.
+
+Stab calculation is also safe for an unusual case, when a size assigned to a
+slot would be larger than 2^16\-1 (you will lose the accuracy though).
+
+During kernel part of packet size adjustment, \fBoverhead\fR will be added to
+original size, and after subtracting 1 (to land in the proper slot \- see above
+about shifting by 1 byte) slot will be calculated. If the size would cause
+overflow, more than 1 slot will be used to get the final size. It of course will
+affect accuracy, but it's only a guard against unusual situations.
+
+Currently there're two methods of creating values stored in the size table \-
+ethernet and atm (adsl):
+
+.IP ethernet 4
+.br
+This is basically 1\-1 mapping, so following our example from above
+(disregarding \fBmpu\fR for a moment) slot 0 would have 8, slot 1 would have 16
+and so on, up to slot 127 with 2048. Note, that \fBmpu\fR\~>\~0 must be
+specified, and slots that would get less than specified by \fBmpu\fR, will get
+\fBmpu\fR instead. If you don't specify \fBmpu\fR, the size table will not be
+created at all, although any \fBoverhead\fR value will be respected during
+calculations.
+.IP "atm, adsl"
+.br
+ATM linklayer consists of 53 byte cells, where each of them provides 48 bytes
+for payload. Also all the cells must be fully utilized, thus the last one is
+padded if/as necessary.
+
+When size table is calculated, adjusted size that fits properly into lowest
+amount of cells is assigned to a slot. For example, a 100 byte long packet
+requires three 48\-byte payloads, so the final size would require 3 ATM cells
+\- 159 bytes.
+
+For ATM size tables, 16\~bytes sized slots are perfectly enough. The default
+values of \fBmtu\fR and \fBtsize\fR create 4\~bytes sized slots.
+.PP
+.
+.SH "TYPICAL OVERHEADS"
+The following values are typical for different adsl scenarios (based on
+\fB[1]\fR and \fB[2]\fR):
+
+.nf
+LLC based:
+.RS 4
+PPPoA \- 14 (PPP \- 2, ATM \- 12)
+PPPoE \- 40+ (PPPoE \- 8, ATM \- 18, ethernet 14, possibly FCS \- 4+padding)
+Bridged \- 32 (ATM \- 18, ethernet 14, possibly FCS \- 4+padding)
+IPoA \- 16 (ATM \- 16)
+.RE
+
+VC Mux based:
+.RS 4
+PPPoA \- 10 (PPP \- 2, ATM \- 8)
+PPPoE \- 32+ (PPPoE \- 8, ATM \- 10, ethernet 14, possibly FCS \- 4+padding)
+Bridged \- 24+ (ATM \- 10, ethernet 14, possibly FCS \- 4+padding)
+IPoA \- 8 (ATM \- 8)
+.RE
+.fi
+\p There're few important things regarding the above overheads:
+.
+.IP \(bu 4
+IPoA in LLC case requires SNAP, instead of LLC\-NLPID (see rfc2684) \- this is
+the reason, why it actually takes more space than PPPoA.
+.IP \(bu
+In rare cases, FCS might be preserved on protocols that include ethernet frame
+(Bridged and PPPoE).  In such situation, any ethernet specific padding
+guaranteeing 64 bytes long frame size has to be included as well (see rfc2684).
+In the other words, it also guarantees that any packet you send will take
+minimum 2 atm cells. You should set \fBmpu\fR accordingly for that.
+.IP \(bu
+When size table is consulted, and you're shaping traffic for the sake of
+another modem/router, ethernet header (without padding) will already be added
+to initial packet's length. You should compensate for that by subtracting 14
+from the above overheads in such case. If you're shaping directly on the router
+(for example, with speedtouch usb modem) using ppp daemon, layer2 header will
+not be added yet.
+
+For more thorough explanations, please see \fB[1]\fR and \fB[2]\fR.
+.
+.SH "SEE ALSO"
+.
+\fBtc\fR(8), \fBtc\-hfsc\fR(7), \fBtc\-hfsc\fR(8),
+.br
+\fB[1]\fR http://ace\-host.stuart.id.au/russell/files/tc/tc\-atm/
+.br
+\fB[2]\fR http://www.faqs.org/rfcs/rfc2684.html
+
+Please direct bugreports and patches to: <netdev@vger.kernel.org>
+.
+.SH "AUTHOR"
+.
+Manpage created by Michal Soltys (soltys@ziu.info)
diff --git a/tc/tc_core.c b/tc/tc_core.c
index 9a0ff39..ffaeb2d 100644
--- a/tc/tc_core.c
+++ b/tc/tc_core.c
@@ -155,12 +155,12 @@ int tc_calc_size_table(struct tc_sizespec *s, __u16 **stab)
 	}
 
 	if (s->mtu == 0)
-		s->mtu = 2047;
+		s->mtu = 2048;
 	if (s->tsize == 0)
 		s->tsize = 512;
 
 	s->cell_log = 0;
-	while ((s->mtu >> s->cell_log) > s->tsize - 1)
+	while ((s->mtu - 1 >> s->cell_log) > s->tsize - 1)
 		s->cell_log++;
 
 	*stab = malloc(s->tsize * sizeof(__u16));
diff --git a/tc/tc_stab.c b/tc/tc_stab.c
index 47b4e5e..e6b8770 100644
--- a/tc/tc_stab.c
+++ b/tc/tc_stab.c
@@ -32,11 +32,12 @@ static void stab_help(void)
 	fprintf(stderr,
 		"Usage: ... stab [ mtu BYTES ] [ tsize SLOTS ] [ mpu BYTES ] \n"
 		"                [ overhead BYTES ] [ linklayer TYPE ] ...\n"
-		"   mtu       : max packet size we create rate map for {2047}\n"
+		"TYPE := adsl | atm | ethernet\n"
+		"   mtu       : max packet size we create size table for {2048}\n"
 		"   tsize     : how many slots should size table have {512}\n"
-		"   mpu       : minimum packet size used in rate computations\n"
-		"   overhead  : per-packet size overhead used in rate computations\n"
-		"   linklayer : adapting to a linklayer e.g. atm\n"
+		"   mpu       : minimum packet size used in size table computations\n"
+		"   overhead  : per-packet size overhead used in size table computations\n"
+		"   linklayer : required linklayer adaptation, (adsl and atm are synonyms)\n"
 		"Example: ... stab overhead 20 linklayer atm\n");
 
 	return;
-- 
1.6.1

