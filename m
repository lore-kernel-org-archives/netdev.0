From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [RFC PATCH net-next] tcp: add CDG congestion control
Date: Sun, 17 May 2015 18:46:54 -0700
Message-ID: <1431913614.621.19.camel@edumazet-glaptop2.roam.corp.google.com>
References: <1431894670-12609-1-git-send-email-kennetkl@ifi.uio.no>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, David Hayes <davihay@ifi.uio.no>,
	Yuchung Cheng <ycheng@google.com>,
	Andreas Petlund <apetlund@simula.no>
To: Kenneth Klette Jonassen <kennetkl@ifi.uio.no>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ig0-f174.google.com ([209.85.213.174]:33048 "EHLO
	mail-ig0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751894AbbERBq5 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 17 May 2015 21:46:57 -0400
Received: by igbpi8 with SMTP id pi8so74270319igb.0
        for <netdev@vger.kernel.org>; Sun, 17 May 2015 18:46:56 -0700 (PDT)
In-Reply-To: <1431894670-12609-1-git-send-email-kennetkl@ifi.uio.no>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, 2015-05-17 at 22:31 +0200, Kenneth Klette Jonassen wrote:
> This is a request for comments.
> 

This looks awesome ;)

A few comments :

> +
> +static  int window __read_mostly = 8;

This is a (readonly) module parameter, but really is a constant (if you
ever try to change it dynamically, bad things will happen in current
code)

const int window = 8;



> +struct cdg {
> +	struct minmax rtt;
> +	struct minmax rtt_prev;
> +	struct minmax gsum;
> +	struct minmax *gradients;
> +	enum cdg_state state;
> +	u32 rtt_seq;
> +	u32 shadow_wnd;
> +	u32 loss_cwnd;

> +	uint tail;
> +	uint backoff_cnt;
> +	uint delack;

Please use 'u32' or 'unsigned int', not 'uint'

> +	bool ecn_ce;
> +};
> +
> +/**
> + * nexp_u32 - negative base-e exponential
> + * @ux: x in units of micro
> + *
> + * Returns exp(ux * -1e-6) * U32_MAX.
> + */
> +static u32 __pure nexp_u32(u32 ux)
> +{
> +	static const u16 v[] = {
> +		/* exp(-x)*65536-1 for x = 0, 0.000256, 0.000512, ... */
> +		65535,
> +		65518, 65501, 65468, 65401, 65267, 65001, 64470, 63422,
> +		61378, 57484, 50423, 38795, 22965, 8047,  987,   14,
> +	};
> +	u64 res;
> +	u32 msb = ux >> 8;
> +	int i;
> +
> +	/* Cut off when ux >= 2^24 (actual result is <= 222/U32_MAX). */
> +	if (msb > U16_MAX)
> +		return 0;
> +
> +	/* Scale first eight bits linearly: */
> +	res = U32_MAX - (ux & 0xff) * (U32_MAX / 1000000);
> +
> +	/* Obtain e^(x + y + ...) by computing e^x * e^y * ...: */
> +	for (i = 1; msb; i++, msb >>= 1) {
> +		u64 y = v[i & -(msb & 1)] + 1ULL;
> +

y does not need 64bit . 32bit is OK.

> +		res = (res * y) >> 16;

And probably res could be u32 as well, and then you could use :

res = ((u64)res * y) >> 16;

gcc will simply use a 32bit x 32bit multiply


> +	}
> +
> +	return (u32)res;

Otherwise an overflow here would be possible.

> +}
> +


> +
> +static void tcp_cdg_init(struct sock *sk)
> +{
> +	struct cdg *ca = inet_csk_ca(sk);
> +	struct tcp_sock *tp = tcp_sk(sk);
> +
> +	/* May fail. Not allocating from emergency pools. */
> +	ca->gradients = kcalloc(window, sizeof(ca->gradients[0]), GFP_NOWAIT);


Then maybe add __GFP_NOWARN if a failure is not a problem.

> +	ca->shadow_wnd = tp->snd_cwnd;
> +	ca->rtt_seq = tp->snd_nxt;
> +}


Thanks
