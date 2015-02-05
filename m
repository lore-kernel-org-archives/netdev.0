From: Michal Kazior <michal.kazior@tieto.com>
Subject: Re: Throughput regression with `tcp: refine TSO autosizing`
Date: Thu, 5 Feb 2015 09:38:23 +0100
Message-ID: <CA+BoTQnnwrv0nrKyGyQNvosz_E4e5fBa9iN8fpeqcd-iRfi17g@mail.gmail.com>
References: <CA+BoTQkVu23P3EOmY_Q3E1GJnWsyF==Pawz4iPOS_Bq5dvfO5Q@mail.gmail.com>
	<1422537297.21689.15.camel@edumazet-glaptop2.roam.corp.google.com>
	<CA+BoTQk2xT-8DqPuiiKG+kHAjLPrj8F9dLTb-rcGhvMq0u_2Qw@mail.gmail.com>
	<1422628835.21689.95.camel@edumazet-glaptop2.roam.corp.google.com>
	<CA+BoTQkV+mOZfe_Niz5101sMQeaV6muKCsShptjGQ1AgOHqqoQ@mail.gmail.com>
	<1422903136.21689.114.camel@edumazet-glaptop2.roam.corp.google.com>
	<1422926330.21689.138.camel@edumazet-glaptop2.roam.corp.google.com>
	<CA+BoTQkMikA8wxm1ce2DkKhPB0HiKeAqT7f+sQ=91W40z=X0Rg@mail.gmail.com>
	<1422973660.907.10.camel@edumazet-glaptop2.roam.corp.google.com>
	<CA+BoTQmvUuFdfYF=wVMYxrf_nQZB5GCV=LvDZVvfs-3hAE4WKw@mail.gmail.com>
	<1423051045.907.108.camel@edumazet-glaptop2.roam.corp.google.com>
	<CA+BoTQ=BDcQ779uKCuX+f40=4npXVF4MTQnpjKimNYAxPsxBoQ@mail.gmail.com>
	<1423053531.907.115.camel@edumazet-glaptop2.roam.corp.google.com>
	<CA+BoTQ=qmCZz4CmSOvCOzMLowrDEG12XBffkTcYxjGqVD9604g@mail.gmail.com>
	<1423055810.907.125.camel@edumazet-glaptop2.roam.corp.google.com>
	<1423056591.907.130.camel@edumazet-glaptop2.roam.corp.google.com>
	<1423084303.31870.15.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Neal Cardwell <ncardwell@google.com>,
	linux-wireless <linux-wireless@vger.kernel.org>,
	Network Development <netdev@vger.kernel.org>,
	eyalpe@dev.mellanox.co.il
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-we0-f179.google.com ([74.125.82.179]:63545 "EHLO
	mail-we0-f179.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755960AbbBEIiZ convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 5 Feb 2015 03:38:25 -0500
Received: by mail-we0-f179.google.com with SMTP id u56so750839wes.10
        for <netdev@vger.kernel.org>; Thu, 05 Feb 2015 00:38:24 -0800 (PST)
In-Reply-To: <1423084303.31870.15.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 4 February 2015 at 22:11, Eric Dumazet <eric.dumazet@gmail.com> wrot=
e:
> I do not see how a TSO patch could hurt a flow not using TSO/GSO.
>
> This makes no sense.

Hmm..

@@ -2018,8 +2053,8 @@ static bool tcp_write_xmit(struct sock *sk,
unsigned int mss_now, int nonagle,
                 * of queued bytes to ensure line rate.
                 * One example is wifi aggregation (802.11 AMPDU)
                 */
-               limit =3D max_t(unsigned int, sysctl_tcp_limit_output_b=
ytes,
-                             sk->sk_pacing_rate >> 10);
+               limit =3D max(2 * skb->truesize, sk->sk_pacing_rate >> =
10);
+               limit =3D min_t(u32, limit, sysctl_tcp_limit_output_byt=
es);

                if (atomic_read(&sk->sk_wmem_alloc) > limit) {
                        set_bit(TSQ_THROTTLED, &tp->tsq_flags);

Doesn't this effectively invert how tcp_limit_output_bytes is used?
This would explain why raising the limit wasn't changing anything
anymore when you asked me do so. Only decreasing it yielded any
change.

I've added a printk to show up the new and old values. Excerpt from log=
s:

[  114.782740] (4608 39126 131072 =3D 39126) vs (131072 39126 =3D 13107=
2)

(2*truesize, pacing_rate, tcp_limit =3D limit) vs (tcp_limit, pacing_ra=
te =3D limit)

Reverting this patch hunk alone fixes my TCP problem. Not that I'm
saying the old logic was correct (it seems it wasn't, a limit should
be applied as min(value, max_value), right?).

Anyway the change doesn't seem to be TSO-only oriented so it would
explain the "makes no sense".


Micha=C5=82
