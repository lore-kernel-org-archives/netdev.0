From: Stephen Hemminger <shemminger@osdl.org>
Subject: Re: [PATCH] Too aggressive cwnd backoff
Date: Thu, 7 Apr 2005 10:16:53 -0700
Message-ID: <20050407101653.2cc68db1@dxpl.pdx.osdl.net>
References: <20050407164146.GA6479@ev-en.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@davemloft.net>, netdev@oss.sgi.com,
        Werner
 Almesberger <werner@almesberger.net>
Return-path: <netdev-bounce@oss.sgi.com>
To: Baruch Even <baruch@ev-en.org>
In-Reply-To: <20050407164146.GA6479@ev-en.org>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Thu, 7 Apr 2005 19:41:46 +0300
Baruch Even <baruch@ev-en.org> wrote:

> The cwnd backoff is down in two places and drops the cwnd to one quarter
> instead of to one half.
> 
> On congestion events we reset tp->ssthresh to the result of
> tcp_recalc_ssthresh. This cuts the cwnd by half for (New)Reno or to
> a convoluted calculation for BIC.
> 
> Later we will call tcp_cwnd_down for each ack and reduce the cwnd by one
> for every two acks.
> 
> However, in tcp_cwnd_down we will not stop reducing the cwnd until we
> get to limit which is set to tp->ssthresh/2.
> 
> The provided patch will set limit to tp->ssthresh. This was the original
> behaviour in some older version of Linux.
> 
> The patch is against 2.6.11
> 
> Signed-Off-By: Baruch Even <baruch@ev-en.org>

I think this is a real problem, and was observed by Werner with umlsim.
Don't know when it got introduced because it appears to pre-date the
'04 work in adding Westwood, BIC, Vegas. Perhaps Alexey can shed some
light on this.

Going back to the pre-westwood code in BK, the /2 is still there.

----------------
static void tcp_cwnd_down(struct tcp_opt *tp)
{
	int decr = tp->snd_cwnd_cnt + 1;

	tp->snd_cwnd_cnt = decr&1;
	decr >>= 1;

	if (decr && tp->snd_cwnd > tp->snd_ssthresh/2)
		tp->snd_cwnd -= decr;

	tp->snd_cwnd = min(tp->snd_cwnd, tcp_packets_in_flight(tp)+1);
	tp->snd_cwnd_stamp = tcp_time_stamp;
}
