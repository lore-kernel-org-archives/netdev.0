From: "Anton 'EvilMan' Danilov" <littlesmilingcloud@gmail.com>
Subject: [PATCH iproute] tc pedit action: fix parsing offset options.
Date: Wed, 29 Feb 2012 19:34:28 +0300
Message-ID: <CAEzD07+xdGxMh9-RHvF0RJZsCvj0Dj=VEY=0csPrSbTED4Hb6g@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ww0-f44.google.com ([74.125.82.44]:57864 "EHLO
	mail-ww0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756670Ab2B2Qe3 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 29 Feb 2012 11:34:29 -0500
Received: by wgbdr13 with SMTP id dr13so3917147wgb.1
        for <netdev@vger.kernel.org>; Wed, 29 Feb 2012 08:34:28 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch fix parsing offset option with "at" parameter.
Tc returns error If keywords "offmask" and "shift" are presented.

Example of wrong parsing:

~$ tc f add dev eth0 parent 1: protocol ip pref 10 \
u32 match u32 0 0 \
action pedit help
Usage: ... pedit munge <MUNGE>
Where: MUNGE := <RAW>|<LAYERED>
        <RAW>:= <OFFSETC>[ATC]<CMD>
                OFFSETC:= offset <offval> <u8|u16|u32>
                ATC:= at <atval> offmask <maskval> shift <shiftval>
                NOTE: offval is byte offset, must be multiple of 4
                NOTE: maskval is a 32 bit hex number
                NOTE: shiftval is a is a shift value
                CMD:= clear | invert | set <setval>| retain
        <LAYERED>:= ip <ipdata> | ip6 <ip6data>
                | udp <udpdata> | tcp <tcpdata> | icmp <icmpdata>
For Example usage look at the examples directory

#try to add filter with pedit action using "at" option
~$ tc f add dev eth0 parent 1: pref 10 protocol all handle ::10 \
u32 match ip protocol 6 0xff \
match ip src 10.10.20.119/32 \
match ip dst 10.10.20.254/32 \
action pedit munge offset 2 u16 at 0 offmask 0f0000000 shift 22 set 11500
Illegal pedit construct (2)
...
bad action parsing
parse_action: bad value (19:pedit)!
Illegal "action"

~$ tc f add dev eth0 parent 1: pref 10 protocol all handle ::10 \
u32 match ip protocol 6 0xff \
match ip src 10.10.20.119/32 \
match ip dst 10.10.20.254/32 \
action pedit munge offset 2 u16 at 0 0f0000000 22 set 11500
parse_cmd argc 8 set offset 2 length 2
pack_key16: Final val ec2c0000 mask 0000ffff
parse_cmd done argc 6 pipe offset 0 length 2


diff --git a/tc/m_pedit.c b/tc/m_pedit.c
index 7499846..fa56234 100644
--- a/tc/m_pedit.c
+++ b/tc/m_pedit.c
@@ -390,16 +390,24 @@ done:
		tkey->at = atv;

		NEXT_ARG();
-
-		if (get_u32(&offmask, *argv, 16))
+		if (matches(*argv, "offmask") == 0) {
+			NEXT_ARG();
+			if (get_u32(&offmask, *argv, 16))
+				return -1;
+			tkey->offmask = htonl(offmask);
+		} else {
			return -1;
-		tkey->offmask = offmask;
+		}

		NEXT_ARG();
-
-		if (get_u32(&shift, *argv, 0))
+		if (matches(*argv, "shift") == 0) {
+			NEXT_ARG();
+			if (get_u32(&shift, *argv, 0))
+				return -1;
+			tkey->shift = shift;
+		} else {
			return -1;
-		tkey->shift = shift;
+		}

		NEXT_ARG();
-
-		if (get_u32(&shift, *argv, 0))
+		if (matches(*argv, "shift") == 0) {
+			NEXT_ARG();
+			if (get_u32(&shift, *argv, 0))
+				return -1;
+			tkey->shift = shift;
+		} else {
			return -1;
-		tkey->shift = shift;
+		}

		NEXT_ARG();
	}

-- 
Anton.
