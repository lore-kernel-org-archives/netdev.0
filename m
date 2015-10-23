From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH RFC net-next 1/2] tcp: Add DPIFL thin stream detection
 mechanism
Date: Fri, 23 Oct 2015 14:44:14 -0700
Message-ID: <1445636654.22974.193.camel@edumazet-glaptop2.roam.corp.google.com>
References: <1445633413-3532-1-git-send-email-bro.devel+kernel@gmail.com>
	 <1445633413-3532-2-git-send-email-bro.devel+kernel@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: "David S. Miller" <davem@davemloft.net>,
	Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>,
	James Morris <jmorris@namei.org>,
	Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>,
	Patrick McHardy <kaber@trash.net>,
	Jonathan Corbet <corbet@lwn.net>,
	Eric Dumazet <edumazet@google.com>,
	Neal Cardwell <ncardwell@google.com>,
	Tom Herbert <tom@herbertland.com>,
	Yuchung Cheng <ycheng@google.com>,
	Paolo Abeni <pabeni@redhat.com>, Erik Kline <ek@google.com>,
	Hannes Frederic Sowa <hannes@stressinduktion.org>,
	Al Viro <viro@zeniv.linux.org.uk>,
	Jiri Pirko <jiri@resnulli.us>,
	Alexander Duyck <alexander.h.duyck@redhat.com>,
	Florian Westphal <fw@strlen.de>,
	Daniel Lee <Longinus00@gmail.com>,
	Marcelo Ricardo Leitner <mleitner@redhat.com>,
	Daniel Borkmann <daniel@iogearbox.net>,
	Willem de Bruijn <willemb@google.com>,
	Linus =?ISO-8859-1?Q?L=FCssing?= <linus.luessing@c0d3.blue>,
	linux-doc@vger.kerne
To: Bendik =?ISO-8859-1?Q?R=F8nning?= Opstad <bro.devel@gmail.com>
Return-path: <linux-doc-owner@vger.kernel.org>
In-Reply-To: <1445633413-3532-2-git-send-email-bro.devel+kernel@gmail.com>
Sender: linux-doc-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, 2015-10-23 at 22:50 +0200, Bendik R=C3=B8nning Opstad wrote:

> =20
> +/**
> + * tcp_stream_is_thin_dpifl() - Tests if the stream is thin based on=
 dynamic PIF
> + *                              limit
> + * @tp: the tcp_sock struct
> + *
> + * Return: true if current packets in flight (PIF) count is lower th=
an
> + *         the dynamic PIF limit, else false
> + */
> +static inline bool tcp_stream_is_thin_dpifl(const struct tcp_sock *t=
p)
> +{
> +	u64 dpif_lim =3D tp->srtt_us >> 3;
> +	/* Div by is_thin_min_itt_lim, the minimum allowed ITT
> +	 * (Inter-transmission time) in usecs.
> +	 */
> +	do_div(dpif_lim, tp->thin_dpifl_itt_lower_bound);
> +	return tcp_packets_in_flight(tp) < dpif_lim;
> +}
> +
This is very strange :

You are using a do_div() while both operands are 32bits.  A regular
divide would be ok :

u32 dpif_lim =3D (tp->srtt_us >> 3) / tp->thin_dpifl_itt_lower_bound;

But then, you can avoid the divide by using a multiply, less expensive =
:

return	(u64)tcp_packets_in_flight(tp) * tp->thin_dpifl_itt_lower_bound =
<
	(tp->srtt_us >> 3);


