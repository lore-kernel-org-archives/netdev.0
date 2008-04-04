From: "Lachlan Andrew" <lachlan.andrew@gmail.com>
Subject: Re: Why is tcp_reno_min_cwnd() ssthresh/2?
Date: Fri, 4 Apr 2008 11:27:35 -0800
Message-ID: <aa7d2c6d0804041227s70dc664an7bf6fedafd36fbea@mail.gmail.com>
References: <aa7d2c6d0804031800r7d796b40oc011e684bcd2f0c0@mail.gmail.com>
	 <7335583a0804031935g49a843dbq8b8c132411501a8b@mail.gmail.com>
	 <1e41a3230804040924q34d009c9w97dded92f13392dc@mail.gmail.com>
	 <20080404113114.2181a146@extreme>
Mime-Version: 1.0
Content-Type: multipart/mixed;
	boundary="----=_Part_2016_9446056.1207337255859"
To: Netdev <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from wx-out-0506.google.com ([66.249.82.239]:37550 "EHLO
	wx-out-0506.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757708AbYDDT1j (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 4 Apr 2008 15:27:39 -0400
Received: by wx-out-0506.google.com with SMTP id h31so201370wxd.4
        for <netdev@vger.kernel.org>; Fri, 04 Apr 2008 12:27:36 -0700 (PDT)
In-Reply-To: <20080404113114.2181a146@extreme>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

------=_Part_2016_9446056.1207337255859
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

Thanks Stephen and all,

I still don't understand why  tcp_cwnd_min()  doesn't default to  Reno
 behaviour.  (The only algorithms this currently affects are BIC and
CUBIC, but since CUBIC is the default, that is important.)

John is right that it would be great to have this documented in the
code.  FWIW, the attached patch points to the mailing list post, and
also makes  tcp_cwnd_min  default to Reno behaviour.  (The inline
patch below is probably mangled by my mail client.)  This patch
changes the behaviour of CUBIC.

Cheers,
Lachlan

diff -ruNp linux-2.6.25-rc7/include/net/tcp.h
linux-2.6.25-rc7-comments/include/net/tcp.h
--- linux-2.6.25-rc7/include/net/tcp.h	2008-03-27 18:25:07.000000000 -0800
+++ linux-2.6.25-rc7-comments/include/net/tcp.h	2008-04-04
11:05:39.000000000 -0800
@@ -645,7 +645,7 @@ struct tcp_congestion_ops {

 	/* return slow start threshold (required) */
 	u32 (*ssthresh)(struct sock *sk);
-	/* lower bound for congestion window (optional) */
+	/* lower bound for congestion window during rate halving (optional) */
 	u32 (*min_cwnd)(const struct sock *sk);
 	/* do new cwnd calculation (required) */
 	void (*cong_avoid)(struct sock *sk, u32 ack, u32 in_flight);
diff -ruNp linux-2.6.25-rc7/net/ipv4/tcp_cong.c
linux-2.6.25-rc7-comments/net/ipv4/tcp_cong.c
--- linux-2.6.25-rc7/net/ipv4/tcp_cong.c	2008-03-27 18:25:07.000000000 -0800
+++ linux-2.6.25-rc7-comments/net/ipv4/tcp_cong.c	2008-04-04
11:05:00.000000000 -0800
@@ -387,6 +387,8 @@ u32 tcp_reno_ssthresh(struct sock *sk)
 EXPORT_SYMBOL_GPL(tcp_reno_ssthresh);

 /* Lower bound on congestion window with halving. */
+/* Allows snd_cwnd to reduce to prev_cwnd/4  */
+/*   -- see http://oss.sgi.com/archives/netdev/2003-01/msg00114.html */
 u32 tcp_reno_min_cwnd(const struct sock *sk)
 {
 	const struct tcp_sock *tp = tcp_sk(sk);
diff -ruNp linux-2.6.25-rc7/net/ipv4/tcp_input.c
linux-2.6.25-rc7-comments/net/ipv4/tcp_input.c
--- linux-2.6.25-rc7/net/ipv4/tcp_input.c	2008-03-27 18:25:07.000000000 -0800
+++ linux-2.6.25-rc7-comments/net/ipv4/tcp_input.c	2008-04-04
11:07:43.000000000 -0800
@@ -2233,14 +2233,15 @@ static inline void tcp_moderate_cwnd(str
 	tp->snd_cwnd_stamp = tcp_time_stamp;
 }

-/* Lower bound on congestion window is slow start threshold
+/* Lower bound on congestion window during rate halving is *half* of
+ * slow start threshold (see net/ipv4/tcp_cong.c:tcp_reno_min_cwnd() )
  * unless congestion avoidance choice decides to overide it.
  */
 static inline u32 tcp_cwnd_min(const struct sock *sk)
 {
 	const struct tcp_congestion_ops *ca_ops = inet_csk(sk)->icsk_ca_ops;

-	return ca_ops->min_cwnd ? ca_ops->min_cwnd(sk) : tcp_sk(sk)->snd_ssthresh;
+	return ca_ops->min_cwnd ? ca_ops->min_cwnd(sk) : tcp_sk(sk)->snd_ssthresh / 2;
 }

 /* Decrease cwnd each second ack. */


On 04/04/2008, Stephen Hemminger <shemminger@vyatta.com> wrote:
>
> First sighed 5 years ago, and every times it comes up, the original
>  behaviour is retained.
>
>  http://oss.sgi.com/archives/netdev/2003-01/msg00114.html


-- 
Lachlan Andrew  Dept of Computer Science, Caltech
1200 E California Blvd, Mail Code 256-80, Pasadena CA 91125, USA
Ph: +1 (626) 395-8820    Fax: +1 (626) 568-3603
http://netlab.caltech.edu/lachlan

------=_Part_2016_9446056.1207337255859
Content-Type: text/x-patch; name=min_cwnd.patch
Content-Transfer-Encoding: base64
X-Attachment-Id: f_fen52kk2
Content-Disposition: attachment; filename=min_cwnd.patch

ZGlmZiAtcnVOcCBsaW51eC0yLjYuMjUtcmM3L2luY2x1ZGUvbmV0L3RjcC5oIGxpbnV4LTIuNi4y
NS1yYzctY29tbWVudHMvaW5jbHVkZS9uZXQvdGNwLmgKLS0tIGxpbnV4LTIuNi4yNS1yYzcvaW5j
bHVkZS9uZXQvdGNwLmgJMjAwOC0wMy0yNyAxODoyNTowNy4wMDAwMDAwMDAgLTA4MDAKKysrIGxp
bnV4LTIuNi4yNS1yYzctY29tbWVudHMvaW5jbHVkZS9uZXQvdGNwLmgJMjAwOC0wNC0wNCAxMTow
NTozOS4wMDAwMDAwMDAgLTA4MDAKQEAgLTY0NSw3ICs2NDUsNyBAQCBzdHJ1Y3QgdGNwX2Nvbmdl
c3Rpb25fb3BzIHsKIAogCS8qIHJldHVybiBzbG93IHN0YXJ0IHRocmVzaG9sZCAocmVxdWlyZWQp
ICovCiAJdTMyICgqc3N0aHJlc2gpKHN0cnVjdCBzb2NrICpzayk7Ci0JLyogbG93ZXIgYm91bmQg
Zm9yIGNvbmdlc3Rpb24gd2luZG93IChvcHRpb25hbCkgKi8KKwkvKiBsb3dlciBib3VuZCBmb3Ig
Y29uZ2VzdGlvbiB3aW5kb3cgZHVyaW5nIHJhdGUgaGFsdmluZyAob3B0aW9uYWwpICovCiAJdTMy
ICgqbWluX2N3bmQpKGNvbnN0IHN0cnVjdCBzb2NrICpzayk7CiAJLyogZG8gbmV3IGN3bmQgY2Fs
Y3VsYXRpb24gKHJlcXVpcmVkKSAqLwogCXZvaWQgKCpjb25nX2F2b2lkKShzdHJ1Y3Qgc29jayAq
c2ssIHUzMiBhY2ssIHUzMiBpbl9mbGlnaHQpOwpkaWZmIC1ydU5wIGxpbnV4LTIuNi4yNS1yYzcv
bmV0L2lwdjQvdGNwX2NvbmcuYyBsaW51eC0yLjYuMjUtcmM3LWNvbW1lbnRzL25ldC9pcHY0L3Rj
cF9jb25nLmMKLS0tIGxpbnV4LTIuNi4yNS1yYzcvbmV0L2lwdjQvdGNwX2NvbmcuYwkyMDA4LTAz
LTI3IDE4OjI1OjA3LjAwMDAwMDAwMCAtMDgwMAorKysgbGludXgtMi42LjI1LXJjNy1jb21tZW50
cy9uZXQvaXB2NC90Y3BfY29uZy5jCTIwMDgtMDQtMDQgMTE6MDU6MDAuMDAwMDAwMDAwIC0wODAw
CkBAIC0zODcsNiArMzg3LDggQEAgdTMyIHRjcF9yZW5vX3NzdGhyZXNoKHN0cnVjdCBzb2NrICpz
aykKIEVYUE9SVF9TWU1CT0xfR1BMKHRjcF9yZW5vX3NzdGhyZXNoKTsKIAogLyogTG93ZXIgYm91
bmQgb24gY29uZ2VzdGlvbiB3aW5kb3cgd2l0aCBoYWx2aW5nLiAqLworLyogQWxsb3dzIHNuZF9j
d25kIHRvIHJlZHVjZSB0byBwcmV2X2N3bmQvNCAgKi8KKy8qICAgLS0gc2VlIGh0dHA6Ly9vc3Mu
c2dpLmNvbS9hcmNoaXZlcy9uZXRkZXYvMjAwMy0wMS9tc2cwMDExNC5odG1sICovCiB1MzIgdGNw
X3Jlbm9fbWluX2N3bmQoY29uc3Qgc3RydWN0IHNvY2sgKnNrKQogewogCWNvbnN0IHN0cnVjdCB0
Y3Bfc29jayAqdHAgPSB0Y3Bfc2soc2spOwpkaWZmIC1ydU5wIGxpbnV4LTIuNi4yNS1yYzcvbmV0
L2lwdjQvdGNwX2lucHV0LmMgbGludXgtMi42LjI1LXJjNy1jb21tZW50cy9uZXQvaXB2NC90Y3Bf
aW5wdXQuYwotLS0gbGludXgtMi42LjI1LXJjNy9uZXQvaXB2NC90Y3BfaW5wdXQuYwkyMDA4LTAz
LTI3IDE4OjI1OjA3LjAwMDAwMDAwMCAtMDgwMAorKysgbGludXgtMi42LjI1LXJjNy1jb21tZW50
cy9uZXQvaXB2NC90Y3BfaW5wdXQuYwkyMDA4LTA0LTA0IDExOjA3OjQzLjAwMDAwMDAwMCAtMDgw
MApAQCAtMjIzMywxNCArMjIzMywxNSBAQCBzdGF0aWMgaW5saW5lIHZvaWQgdGNwX21vZGVyYXRl
X2N3bmQoc3RyCiAJdHAtPnNuZF9jd25kX3N0YW1wID0gdGNwX3RpbWVfc3RhbXA7CiB9CiAKLS8q
IExvd2VyIGJvdW5kIG9uIGNvbmdlc3Rpb24gd2luZG93IGlzIHNsb3cgc3RhcnQgdGhyZXNob2xk
CisvKiBMb3dlciBib3VuZCBvbiBjb25nZXN0aW9uIHdpbmRvdyBkdXJpbmcgcmF0ZSBoYWx2aW5n
IGlzICpoYWxmKiBvZgorICogc2xvdyBzdGFydCB0aHJlc2hvbGQgKHNlZSBuZXQvaXB2NC90Y3Bf
Y29uZy5jOnRjcF9yZW5vX21pbl9jd25kKCkgKQogICogdW5sZXNzIGNvbmdlc3Rpb24gYXZvaWRh
bmNlIGNob2ljZSBkZWNpZGVzIHRvIG92ZXJpZGUgaXQuCiAgKi8KIHN0YXRpYyBpbmxpbmUgdTMy
IHRjcF9jd25kX21pbihjb25zdCBzdHJ1Y3Qgc29jayAqc2spCiB7CiAJY29uc3Qgc3RydWN0IHRj
cF9jb25nZXN0aW9uX29wcyAqY2Ffb3BzID0gaW5ldF9jc2soc2spLT5pY3NrX2NhX29wczsKIAot
CXJldHVybiBjYV9vcHMtPm1pbl9jd25kID8gY2Ffb3BzLT5taW5fY3duZChzaykgOiB0Y3Bfc2so
c2spLT5zbmRfc3N0aHJlc2g7CisJcmV0dXJuIGNhX29wcy0+bWluX2N3bmQgPyBjYV9vcHMtPm1p
bl9jd25kKHNrKSA6IHRjcF9zayhzayktPnNuZF9zc3RocmVzaCAvIDI7CiB9CiAKIC8qIERlY3Jl
YXNlIGN3bmQgZWFjaCBzZWNvbmQgYWNrLiAqLwo=
------=_Part_2016_9446056.1207337255859--
