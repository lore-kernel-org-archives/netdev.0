From: Michal Kazior <michal.kazior@tieto.com>
Subject: Re: Throughput regression with `tcp: refine TSO autosizing`
Date: Fri, 6 Feb 2015 10:42:32 +0100
Message-ID: <CA+BoTQ=WaKLV=r6qWaWAEfyDr2pqMWpm4NDmnek92TEVndnxRQ@mail.gmail.com>
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
	<1423156205.31870.86.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Neal Cardwell <ncardwell@google.com>,
	linux-wireless <linux-wireless@vger.kernel.org>,
	Network Development <netdev@vger.kernel.org>,
	eyalpe@dev.mellanox.co.il
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-we0-f170.google.com ([74.125.82.170]:43483 "EHLO
	mail-we0-f170.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754067AbbBFJmd convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 6 Feb 2015 04:42:33 -0500
Received: by mail-we0-f170.google.com with SMTP id q59so3708609wes.1
        for <netdev@vger.kernel.org>; Fri, 06 Feb 2015 01:42:32 -0800 (PST)
In-Reply-To: <1423156205.31870.86.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 5 February 2015 at 18:10, Eric Dumazet <eric.dumazet@gmail.com> wrot=
e:
> On Thu, 2015-02-05 at 06:41 -0800, Eric Dumazet wrote:
>
>> Not at all. This basically removes backpressure.
>>
>> A single UDP socket can now blast packets regardless of SO_SNDBUF
>> limits.
>>
>> This basically remove years of work trying to fix bufferbloat.
>>
>> I still do not understand why increasing tcp_limit_output_bytes is n=
ot
>> working for you.
>
> Oh well, tcp_limit_output_bytes might be ok.
>
> In fact, the problem comes from GSO assumption. Maybe Herbert was rig=
ht,
> when he suggested TCP would be simpler if we enforced GSO...
>
> When GSO is used, the thing works because 2*skb->truesize is roughly =
2
> ms worth of traffic.
>
> Because you do not use GSO, and tx completions are slow, we need this=
 :
>
> diff --git a/net/ipv4/tcp_output.c b/net/ipv4/tcp_output.c
> index 65caf8b95e17..ac01b4cd0035 100644
> --- a/net/ipv4/tcp_output.c
> +++ b/net/ipv4/tcp_output.c
> @@ -2044,7 +2044,8 @@ static bool tcp_write_xmit(struct sock *sk, uns=
igned int mss_now, int nonagle,
>                         break;
>
>                 /* TCP Small Queues :
> -                * Control number of packets in qdisc/devices to two =
packets / or ~1 ms.
> +                * Control number of packets in qdisc/devices to two =
packets /
> +                * or ~2 ms (sk->sk_pacing_rate >> 9) in case GSO is =
off.
>                  * This allows for :
>                  *  - better RTT estimation and ACK scheduling
>                  *  - faster recovery
> @@ -2053,7 +2054,7 @@ static bool tcp_write_xmit(struct sock *sk, uns=
igned int mss_now, int nonagle,
>                  * of queued bytes to ensure line rate.
>                  * One example is wifi aggregation (802.11 AMPDU)
>                  */
> -               limit =3D max(2 * skb->truesize, sk->sk_pacing_rate >=
> 10);
> +               limit =3D max(2 * skb->truesize, sk->sk_pacing_rate >=
> 9);
>                 limit =3D min_t(u32, limit, sysctl_tcp_limit_output_b=
ytes);
>
>                 if (atomic_read(&sk->sk_wmem_alloc) > limit) {
>

The above brings back previous behaviour, i.e. I can get 600mbps TCP
on 5 flows again. Single flow is still (as it was before TSO
autosizing) limited to roughly ~280mbps.

I never really bothered before to understand why I need to push a few
flows through ath10k to max it out, i.e. if I run a single UDP flow I
get ~300mbps while with, e.g. 5 I get 670mbps easily.

I guess it was the tx completion latency all along.

I just put an extra debug to ath10k to see the latency between
submission and completion. Here's a log
(http://www.filedropper.com/complete-log) of 2s run of UDP iperf
trying to push 1gbps but managing only 300mbps.

I've made sure to not hold any locks nor introduce internal to ath10k
delays. Frames get completed between 2-4ms in avarage during load.

When I tried using different ath10k hw&fw I got between 1-2ms of
latency for tx completionsyielding ~430mbps while max should be around
670mbps.


Micha=C5=82
