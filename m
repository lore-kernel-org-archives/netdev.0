From: Andi Kleen <ak@muc.de>
Subject: Re: [PATCH] Super TSO
Date: Wed, 18 May 2005 15:43:21 +0200
Message-ID: <m1fywk645i.fsf@muc.de>
References: <20050517.192416.108741581.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: "David S. Miller" <davem@davemloft.net>
In-Reply-To: <20050517.192416.108741581.davem@davemloft.net> (David S.
 Miller's message of "Tue, 17 May 2005 19:24:16 -0700 (PDT)")
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

"David S. Miller" <davem@davemloft.net> writes:

> I did some cross-continent (San Francisco --> east coast of US)
> transfers to make sure TSO stays on when packet drops occur and that
> performance doesn't suffer compared to TSO being off.  It all looks
> fine so far.

It would be interesting to see what happens with moderate packet loss
(= e.g. conditions handled by fast retransmit). That would
lead to occasional "bubbles" in the pipeline. How long would
your algorithm need to refill it then? I suppose this is a common
case on internet servers.

>
> There were many bugs discovered along the way.  For example, the

> I moved all of the "should we send" logic privately into the file
> net/ipv4/tcp_output.c, and I am sure there are many simplifications

Thanks that was long overdue, thanks. tcp.h still has too much
inline code though :/

And congratulations for getting rid of the "if() from hell"
in the send check.

> possible.  There are several spurious tcp_current_mss() calls scattered

It does far too much work for the common cases too. Similar 
is true for the ACK logic in the input path. I think quite
a few cycles could be saved here (although it probably doesn't matter
much anymore on modern boxes because they don't result in cache misses,
so any improvements might end up in the noise)

> @@ -674,59 +653,274 @@ unsigned int tcp_sync_mss(struct sock *s
>   * cannot be large. However, taking into account rare use of URG, this
>   * is not a big flaw.
>   */
> +static inline u32 compute_xmit_cache(u32 mss, int sacks, int tso_enabled)
> +{
> +	u32 ret = (mss << 16) | sacks;

16bit MSS? How does that deal with jumbopackets on IPv6?
While the MSS option is also 16bit it is legal to construct bigger
datagrams when no MSS option was exchanged.

-Andi
