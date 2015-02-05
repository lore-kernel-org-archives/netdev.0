From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: Throughput regression with `tcp: refine TSO autosizing`
Date: Thu, 05 Feb 2015 09:10:05 -0800
Message-ID: <1423156205.31870.86.camel@edumazet-glaptop2.roam.corp.google.com>
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
	 <CA+BoTQnnwrv0nrKyGyQNvosz_E4e5fBa9iN8fpeqcd-iRfi17g@mail.gmail.com>
	 <1423141038.31870.38.camel@edumazet-glaptop2.roam.corp.google.com>
	 <1423142342.31870.49.camel@edumazet-glaptop2.roam.corp.google.com>
	 <CA+BoTQmcShK0U_cXvEOLY_8y7LH8x3taTgjcyMzv0MLVn4UtCA@mail.gmail.com>
	 <1423147286.31870.59.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Neal Cardwell <ncardwell@google.com>,
	linux-wireless <linux-wireless@vger.kernel.org>,
	Network Development <netdev@vger.kernel.org>,
	eyalpe@dev.mellanox.co.il
To: Michal Kazior <michal.kazior@tieto.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ig0-f181.google.com ([209.85.213.181]:62516 "EHLO
	mail-ig0-f181.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754169AbbBERKQ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 5 Feb 2015 12:10:16 -0500
In-Reply-To: <1423147286.31870.59.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2015-02-05 at 06:41 -0800, Eric Dumazet wrote:

> Not at all. This basically removes backpressure.
> 
> A single UDP socket can now blast packets regardless of SO_SNDBUF
> limits.
> 
> This basically remove years of work trying to fix bufferbloat.
> 
> I still do not understand why increasing tcp_limit_output_bytes is not
> working for you.

Oh well, tcp_limit_output_bytes might be ok.

In fact, the problem comes from GSO assumption. Maybe Herbert was right,
when he suggested TCP would be simpler if we enforced GSO...

When GSO is used, the thing works because 2*skb->truesize is roughly 2
ms worth of traffic.

Because you do not use GSO, and tx completions are slow, we need this :

diff --git a/net/ipv4/tcp_output.c b/net/ipv4/tcp_output.c
index 65caf8b95e17..ac01b4cd0035 100644
--- a/net/ipv4/tcp_output.c
+++ b/net/ipv4/tcp_output.c
@@ -2044,7 +2044,8 @@ static bool tcp_write_xmit(struct sock *sk, unsigned int mss_now, int nonagle,
 			break;
 
 		/* TCP Small Queues :
-		 * Control number of packets in qdisc/devices to two packets / or ~1 ms.
+		 * Control number of packets in qdisc/devices to two packets /
+		 * or ~2 ms (sk->sk_pacing_rate >> 9) in case GSO is off.
 		 * This allows for :
 		 *  - better RTT estimation and ACK scheduling
 		 *  - faster recovery
@@ -2053,7 +2054,7 @@ static bool tcp_write_xmit(struct sock *sk, unsigned int mss_now, int nonagle,
 		 * of queued bytes to ensure line rate.
 		 * One example is wifi aggregation (802.11 AMPDU)
 		 */
-		limit = max(2 * skb->truesize, sk->sk_pacing_rate >> 10);
+		limit = max(2 * skb->truesize, sk->sk_pacing_rate >> 9);
 		limit = min_t(u32, limit, sysctl_tcp_limit_output_bytes);
 
 		if (atomic_read(&sk->sk_wmem_alloc) > limit) {
