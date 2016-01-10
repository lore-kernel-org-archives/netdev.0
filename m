From: Neal Cardwell <ncardwell@google.com>
Subject: Re: [REGRESSION] tcp/ipv4: kernel panic because of (possible)
 division by zero
Date: Sun, 10 Jan 2016 12:29:17 -0500
Message-ID: <CADVnQykPOVf7PoK8-6Mvbmbcpe1eYY=cfKHgiNGDNSFfCDPb-A@mail.gmail.com>
References: <26396443.iDTTxgChSj@spock>
	<8830013.bJO8vnIv9N@spock>
	<CADVnQy=S62KoQL7thY73Kb=1Qd60drvOHJhE8UwH9qzPFOadEg@mail.gmail.com>
	<1562805.Wa36G0OKaZ@spock>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Yuchung Cheng <ycheng@google.com>, netdev <netdev@vger.kernel.org>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	Patrick McHardy <kaber@trash.net>,
	Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>,
	James Morris <jmorris@namei.org>,
	Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>,
	"David S. Miller" <davem@davemloft.net>
To: Oleksandr Natalenko <oleksandr@natalenko.name>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1562805.Wa36G0OKaZ@spock>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Sun, Jan 10, 2016 at 9:57 AM, Oleksandr Natalenko
<oleksandr@natalenko.name> wrote:
> I use YeAH. But YeAH code wasn't touched between 4.2 and 4.3.

Oh, interesting. Looks like tcp_yeah_ssthresh() has a bug where its
intended reduction can be bigger than tp->snd_cwnd, leading to it
return a zero ssthresh (or even an ssthresh that underflows to ~4
billion). If tcp_yeah_ssthresh() returns an ssthresh of 0 then PRR
will try to pull the cwnd down to 0.

Can you please leave ECN and Yeah enabled and run something like the
following patch, to verify this conjecture? If the conjecture is
right, then the tcp_yeah warning should fire but not the new
tcp_cwnd_reduction() warning:

-----------
diff --git a/net/ipv4/tcp_yeah.c b/net/ipv4/tcp_yeah.c
index 17d3566..ef60cba 100644
--- a/net/ipv4/tcp_yeah.c
+++ b/net/ipv4/tcp_yeah.c
@@ -206,6 +206,7 @@ static u32 tcp_yeah_ssthresh(struct sock *sk)
        const struct tcp_sock *tp = tcp_sk(sk);
        struct yeah *yeah = inet_csk_ca(sk);
        u32 reduction;
+       s32 ssthresh;

        if (yeah->doing_reno_now < TCP_YEAH_RHO) {
                reduction = yeah->lastQ;
@@ -219,7 +220,9 @@ static u32 tcp_yeah_ssthresh(struct sock *sk)
        yeah->fast_count = 0;
        yeah->reno_count = max(yeah->reno_count>>1, 2U);

-       return tp->snd_cwnd - reduction;
+       ssthresh = tp->snd_cwnd - reduction;
+       if (WARN_ON_ONCE(ssthresh <= 0))
+               ssthresh = 1;
 }

 static struct tcp_congestion_ops tcp_yeah __read_mostly = {
-----------

If that works, then we may just want a version of this patch without
the warning.

Thanks!
neal
