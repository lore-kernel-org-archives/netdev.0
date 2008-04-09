From: "Lachlan Andrew" <lachlan.andrew@gmail.com>
Subject: Overflow bug in Vegas
Date: Wed, 9 Apr 2008 13:57:23 -0700
Message-ID: <aa7d2c6d0804091357i10aa16f8sf8d99dbaaa7f0542@mail.gmail.com>
Mime-Version: 1.0
Content-Type: multipart/mixed;
	boundary="----=_Part_6419_10924981.1207774643693"
To: Netdev <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from py-out-1112.google.com ([64.233.166.181]:53260 "EHLO
	py-out-1112.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752469AbYDIU5Y (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 9 Apr 2008 16:57:24 -0400
Received: by py-out-1112.google.com with SMTP id u52so4082607pyb.10
        for <netdev@vger.kernel.org>; Wed, 09 Apr 2008 13:57:23 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

------=_Part_6419_10924981.1207774643693
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

Greetings all,

There is an overflow bug in  net/ipv4/tcp_vegas.c  for large BDPs
(e.g. 400Mbit/s, 400ms).
The multiplication  (old_wnd * vegas->baseRTT) << V_PARAM_SHIFT
overflows a  u32.

The attached patch relative to 2.6.25-rc7 fixes that.

(No-one would ever use Vegas on a path like that, but it will affect
algorithms derived from the Vegas code.  I found the bug while testing
the Linux port of Microsoft's Compound TCP, from
<http://netlab.caltech.edu/lachlan/ctcp/>.  That patch is derived from
Angelo Castellani's which used the Vegas code.)

Cheers,
Lachlan


--- linux-2.6.25-rc7/net/ipv4/tcp_vegas.c	2008-03-27 18:25:07.000000000 -0800
+++ linux-2.6.25-rc7/net/ipv4/tcp_vegas.c-new	2008-04-09
13:14:43.000000000 -0700
@@ -229,7 +229,8 @@ static void tcp_vegas_cong_avoid(struct
 			 */
 			tcp_reno_cong_avoid(sk, ack, in_flight);
 		} else {
-			u32 rtt, target_cwnd, diff;
+			u32 rtt, diff;
+			u64 target_cwnd;

 			/* We have enough RTT samples, so, using the Vegas
 			 * algorithm, we determine if we should increase or
@@ -252,8 +253,9 @@ static void tcp_vegas_cong_avoid(struct
 			 * We keep it as a fixed point number with
 			 * V_PARAM_SHIFT bits to the right of the binary point.
 			 */
-			target_cwnd = ((old_wnd * vegas->baseRTT)
-				       << V_PARAM_SHIFT) / rtt;
+			target_cwnd = ((u64)old_wnd * vegas->baseRTT);
+			target_cwnd <<= V_PARAM_SHIFT;
+			do_div(target_cwnd, rtt);

 			/* Calculate the difference between the window we had,
 			 * and the window we would like to have. This quantity
@@ -279,7 +281,7 @@ static void tcp_vegas_cong_avoid(struct
 				 * utilization.
 				 */
 				tp->snd_cwnd = min(tp->snd_cwnd,
-						   (target_cwnd >>
+						   ((u32)target_cwnd >>
 						    V_PARAM_SHIFT)+1);

 			} else if (tp->snd_cwnd <= tp->snd_ssthresh) {

-- 
Lachlan Andrew  Dept of Computer Science, Caltech
1200 E California Blvd, Mail Code 256-80, Pasadena CA 91125, USA
Ph: +1 (626) 395-8820    Fax: +1 (626) 568-3603
http://netlab.caltech.edu/lachlan

------=_Part_6419_10924981.1207774643693
Content-Type: application/octet-stream; name=Vegas-patch
Content-Transfer-Encoding: base64
X-Attachment-Id: f_feudkfyj
Content-Disposition: attachment; filename=Vegas-patch

LS0tIGxpbnV4LTIuNi4yNS1yYzcvbmV0L2lwdjQvdGNwX3ZlZ2FzLmMJMjAwOC0wMy0yNyAxODoy
NTowNy4wMDAwMDAwMDAgLTA4MDAKKysrIGxpbnV4LTIuNi4yNS1yYzcvbmV0L2lwdjQvdGNwX3Zl
Z2FzLmMtbmV3CTIwMDgtMDQtMDkgMTM6MTQ6NDMuMDAwMDAwMDAwIC0wNzAwCkBAIC0yMjksNyAr
MjI5LDggQEAgc3RhdGljIHZvaWQgdGNwX3ZlZ2FzX2NvbmdfYXZvaWQoc3RydWN0IAogCQkJICov
CiAJCQl0Y3BfcmVub19jb25nX2F2b2lkKHNrLCBhY2ssIGluX2ZsaWdodCk7CiAJCX0gZWxzZSB7
Ci0JCQl1MzIgcnR0LCB0YXJnZXRfY3duZCwgZGlmZjsKKwkJCXUzMiBydHQsIGRpZmY7CisJCQl1
NjQgdGFyZ2V0X2N3bmQ7CiAKIAkJCS8qIFdlIGhhdmUgZW5vdWdoIFJUVCBzYW1wbGVzLCBzbywg
dXNpbmcgdGhlIFZlZ2FzCiAJCQkgKiBhbGdvcml0aG0sIHdlIGRldGVybWluZSBpZiB3ZSBzaG91
bGQgaW5jcmVhc2Ugb3IKQEAgLTI1Miw4ICsyNTMsOSBAQCBzdGF0aWMgdm9pZCB0Y3BfdmVnYXNf
Y29uZ19hdm9pZChzdHJ1Y3QgCiAJCQkgKiBXZSBrZWVwIGl0IGFzIGEgZml4ZWQgcG9pbnQgbnVt
YmVyIHdpdGgKIAkJCSAqIFZfUEFSQU1fU0hJRlQgYml0cyB0byB0aGUgcmlnaHQgb2YgdGhlIGJp
bmFyeSBwb2ludC4KIAkJCSAqLwotCQkJdGFyZ2V0X2N3bmQgPSAoKG9sZF93bmQgKiB2ZWdhcy0+
YmFzZVJUVCkKLQkJCQkgICAgICAgPDwgVl9QQVJBTV9TSElGVCkgLyBydHQ7CisJCQl0YXJnZXRf
Y3duZCA9ICgodTY0KW9sZF93bmQgKiB2ZWdhcy0+YmFzZVJUVCk7CisJCQl0YXJnZXRfY3duZCA8
PD0gVl9QQVJBTV9TSElGVDsKKwkJCWRvX2Rpdih0YXJnZXRfY3duZCwgcnR0KTsKIAogCQkJLyog
Q2FsY3VsYXRlIHRoZSBkaWZmZXJlbmNlIGJldHdlZW4gdGhlIHdpbmRvdyB3ZSBoYWQsCiAJCQkg
KiBhbmQgdGhlIHdpbmRvdyB3ZSB3b3VsZCBsaWtlIHRvIGhhdmUuIFRoaXMgcXVhbnRpdHkKQEAg
LTI3OSw3ICsyODEsNyBAQCBzdGF0aWMgdm9pZCB0Y3BfdmVnYXNfY29uZ19hdm9pZChzdHJ1Y3Qg
CiAJCQkJICogdXRpbGl6YXRpb24uCiAJCQkJICovCiAJCQkJdHAtPnNuZF9jd25kID0gbWluKHRw
LT5zbmRfY3duZCwKLQkJCQkJCSAgICh0YXJnZXRfY3duZCA+PgorCQkJCQkJICAgKCh1MzIpdGFy
Z2V0X2N3bmQgPj4KIAkJCQkJCSAgICBWX1BBUkFNX1NISUZUKSsxKTsKIAogCQkJfSBlbHNlIGlm
ICh0cC0+c25kX2N3bmQgPD0gdHAtPnNuZF9zc3RocmVzaCkgewo=
------=_Part_6419_10924981.1207774643693--
