From: "Anton 'EvilMan' Danilov" <littlesmilingcloud@gmail.com>
Subject: [PATCH iproute2] pedit action: add mask for changing bits.
Date: Sat, 25 Feb 2012 22:01:54 +0400
Message-ID: <CAEzD07+0EA12igqAcwbM8VGKLR9Hp0GjJ7t_Jve=JXOrEKvu9w@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ww0-f44.google.com ([74.125.82.44]:47749 "EHLO
	mail-ww0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757233Ab2BYSBz (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 25 Feb 2012 13:01:55 -0500
Received: by wgbdr13 with SMTP id dr13so575712wgb.1
        for <netdev@vger.kernel.org>; Sat, 25 Feb 2012 10:01:54 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch adds the ability to set the mask for changing bits. The
mask parameter is optional.

Example of usage:
#rewrite vlan id. cos field in 802.1q header is unchanged.
ip link add link eth0 name eth0.99 type vlan id 99 reorder_hdr off
egress-qos-map 0:7
tc qdisc add dev eth0 root handle 1: prio bands 8
tc filter add dev eth0 parent 1: protocol all pref 1 u32
tc filter add dev eth0 parent 1: protocol all pref 1 handle ::1 u32 \
   match u16 0x8100 0xffff at -6 \
   match u16 0x0063 0x0fff at -4 \
   classid 1:5 \
   action pedit munge offset -4 u16 set 0x000d 0x0fff


diff --git a/tc/m_pedit.c b/tc/m_pedit.c
index 7499846..f081eff 100644
--- a/tc/m_pedit.c
+++ b/tc/m_pedit.c
@@ -44,7 +44,8 @@ explain(void)
		"\t\tNOTE: offval is byte offset, must be multiple of 4\n "
		"\t\tNOTE: maskval is a 32 bit hex number\n "
		"\t\tNOTE: shiftval is a is a shift value\n "
-		"\t\tCMD:= clear | invert | set <setval>| retain\n "
+		"\t\tCMD:= clear [<mask>] | invert [<mask>]\n"
+		" \t\t| set <setval> [<mask>] | retain [<mask>] \n "
		"\t<LAYERED>:= ip <ipdata> | ip6 <ip6data> \n "
		" \t\t| udp <udpdata> | tcp <tcpdata> | icmp <icmpdata> \n"
		"For Example usage look at the examples directory\n");
@@ -152,7 +153,7 @@ pack_key32(__u32 retain,struct tc_pedit_sel
*sel,struct tc_pedit_key *tkey)
	}

	tkey->val = htonl(tkey->val & retain);
-	tkey->mask = htonl(tkey->mask | ~retain);
+	tkey->mask = htonl(~tkey->mask | ~retain);
	/* jamal remove this - it is not necessary given the if check above */
	tkey->off &= ~3;
	return pack_key(sel,tkey);
@@ -186,12 +187,12 @@ pack_key16(__u32 retain,struct tc_pedit_sel
*sel,struct tc_pedit_key *tkey)

	stride = 8 * ind;
	tkey->val = htons(tkey->val);
+	tkey->mask = htons(tkey->mask);
	if (stride > 0) {
		tkey->val <<= stride;
-		tkey->mask <<= stride;
		retain <<= stride;
	}
-	tkey->mask = retain|m[ind];
+	tkey->mask = retain|m[ind]|~(tkey->mask << stride);

	tkey->off &= ~3;

@@ -216,16 +217,15 @@ pack_key8(__u32 retain,struct tc_pedit_sel
*sel,struct tc_pedit_key *tkey)
	}

	if (tkey->val > 0xFF || tkey->mask > 0xFF) {
-		fprintf(stderr, "pack_key8 bad value (val %x mask %x\n", tkey->val,
tkey->mask);
+		fprintf(stderr, "pack_key8 bad value (val %x mask %x)\n",
tkey->val, tkey->mask);
		return -1;
	}

	ind = tkey->off & 3;
	stride = 8 * ind;
	tkey->val <<= stride;
-	tkey->mask <<= stride;
	retain <<= stride;
-	tkey->mask = retain|m[ind];
+	tkey->mask = retain|m[ind]|~(tkey->mask << stride);
	tkey->off &= ~3;

	if (pedit_debug)
@@ -309,17 +309,26 @@ parse_cmd(int *argc_p, char ***argv_p, __u32
len, int type,__u32 retain,struct t
	tkey->val = val;

	if (len == 1) {
-		tkey->mask = 0xFF;
+		if (!get_u32(&tkey->mask, *argv, 0)) {
+			argc--; argv++;
+		} else
+			tkey->mask = 0xFF;
		res = pack_key8(retain,sel,tkey);
		goto done;
	}
	if (len == 2) {
-		tkey->mask = mask;
+		if (!get_u32(&tkey->mask, *argv, 0)) {
+			argc--; argv++;
+		} else
+			tkey->mask = 0xFFFF;
		res = pack_key16(retain,sel,tkey);
		goto done;
	}
	if (len == 4) {
-		tkey->mask = mask;
+		if (!get_u32(&tkey->mask, *argv, 0)) {
+			argc--; argv++;
+		} else
+			tkey->mask = 0xFFFFFFFF;
		res = pack_key32(retain,sel,tkey);
		goto done;
	}


-- 
Anton.
