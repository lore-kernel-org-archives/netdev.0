From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: Throughput regression with `tcp: refine TSO autosizing`
Date: Mon, 09 Feb 2015 07:11:30 -0800
Message-ID: <1423494690.31870.189.camel@edumazet-glaptop2.roam.corp.google.com>
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
	 <CA+BoTQ=WaKLV=r6qWaWAEfyDr2pqMWpm4NDmnek92TEVndnxRQ@mail.gmail.com>
	 <1423230001.31870.128.camel@edumazet-glaptop2.roam.corp.google.com>
	 <1423230785.31870.131.camel@edumazet-glaptop2.roam.corp.google.com>
	 <CA+BoTQkazCOin7VWLfrHUjtgKDPV6T+sFsk5FPS7D-morr4FZQ@mail.gmail.com>
	 <CA+BoTQn3KRym0qCJ+fLav5LQgjfiN_-Eqz0xPSc2eXJ-ijNjQw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Neal Cardwell <ncardwell@google.com>,
	linux-wireless <linux-wireless@vger.kernel.org>,
	Network Development <netdev@vger.kernel.org>,
	Eyal Perry <eyalpe@dev.mellanox.co.il>
To: Michal Kazior <michal.kazior@tieto.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f172.google.com ([209.85.192.172]:44665 "EHLO
	mail-pd0-f172.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1759789AbbBIPLd (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 9 Feb 2015 10:11:33 -0500
In-Reply-To: <CA+BoTQn3KRym0qCJ+fLav5LQgjfiN_-Eqz0xPSc2eXJ-ijNjQw@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 2015-02-09 at 14:47 +0100, Michal Kazior wrote:

> diff --git a/net/ipv4/tcp_output.c b/net/ipv4/tcp_output.c
> index 65caf8b..5e249bf 100644
> --- a/net/ipv4/tcp_output.c
> +++ b/net/ipv4/tcp_output.c
> @@ -1996,6 +1996,7 @@ static bool tcp_write_xmit(struct sock *sk,
> unsigned int mss_now, int nonagle,
>         max_segs = tcp_tso_autosize(sk, mss_now);
>         while ((skb = tcp_send_head(sk))) {
>                 unsigned int limit;
> +               unsigned int amount;
> 
>                 tso_segs = tcp_init_tso_segs(sk, skb, mss_now);
>                 BUG_ON(!tso_segs);
> @@ -2053,7 +2054,9 @@ static bool tcp_write_xmit(struct sock *sk,
> unsigned int mss_now, int nonagle,
>                  * of queued bytes to ensure line rate.
>                  * One example is wifi aggregation (802.11 AMPDU)
>                  */
> -               limit = max(2 * skb->truesize, sk->sk_pacing_rate >> 10);
> +               amount = sk->sk_tx_completion_delay_us *
> +                        (sk->sk_pacing_rate >> 10);
> +               limit = max(2 * skb->truesize, amount >> 10);
>                 limit = min_t(u32, limit, sysctl_tcp_limit_output_bytes);
> 
>                 if (atomic_read(&sk->sk_wmem_alloc) > limit) {

This is not what I suggested.

If you test this on any other network device, you'll have
sk->sk_tx_completion_delay_us == 0

amount = 0 * (sk->sk_pacing_rate >> 10); --> 0
limit = max(2 * skb->truesize, amount >> 10); --> 2 * skb->truesize

So non TSO/GSO NIC will not be able to queue more than 2 MSS (one MSS
per skb)

Then if you store only the last tx completion, you have the possibility
of having a last packet of a train (say a retransmit) to make it very
low.

Ideally the formula would be in TCP something very fast to compute :

amount = (sk->sk_pacing_rate >> 10) + sk->tx_completion_delay_cushion;
limit = max(2 * skb->truesize, amount);
limit = min_t(u32, limit, sysctl_tcp_limit_output_bytes);

So a 'problematic' driver would have to do the math (64 bit maths) like
this :


sk->tx_completion_delay_cushion = ewma_tx_delay * sk->sk_pacing_rate;
