From: Andi Kleen <andi@firstfloor.org>
Subject: Re: [PATCH v4 4/7] tcp: input header length, prediction, and timestamp bugs
Date: Mon, 15 Feb 2010 16:10:55 +0100
Message-ID: <20100215151055.GG21783@one.firstfloor.org>
References: <4B793CAA.2030902@gmail.com> <4B793E8F.30208@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Linux Kernel Developers <linux-kernel@vger.kernel.org>,
	Linux Kernel Network Developers <netdev@vger.kernel.org>,
	Andrew Morton <akpm@linux-foundation.org>,
	David Miller <davem@davemloft.net>,
	Andi Kleen <andi@firstfloor.org>
To: William Allen Simpson <william.allen.simpson@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from one.firstfloor.org ([213.235.205.2]:46308 "EHLO
	one.firstfloor.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755414Ab0BOPLA (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 15 Feb 2010 10:11:00 -0500
Content-Disposition: inline
In-Reply-To: <4B793E8F.30208@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Feb 15, 2010 at 07:31:11AM -0500, William Allen Simpson wrote:
> Fix incorrect header prediction flags documentation.
> 
> Relieve register pressure in (the i386) fast path by accessing skb->len
> directly, instead of carrying a rarely used len parameter.
> 
> Eliminate unused len parameters in two other functions.
> 
> Don't use output calculated tp->tcp_header_len for input decisions.
> While the output header is usually the same as the input (same options
> in both directions), that's a poor assumption. In particular, Sack will
> be different. Newer options are not guaranteed.

Is this a bug fix? 

tcp_ack() is so bloated these days that I sometimes wonder
if the fast path still makes sense. It would be probably
an interesting study to actually count cycles for
the common cases.

On the other hand CPU cycles on modern systems are so cheap
that it might be simpler to simply ignore them and only
optimize for cache misses. I suppose a cache optimized
tcp_rcv_establish() would look quite different.

Anyways that's not directly related to the patch.

> There's no need to test buffer length against header length, already
> checked by tcp_v[4,6]_rcv(). Straighten code for minor efficiency gain.
> 
> Stand-alone patch, originally developed for TCPCT.

Normally it would be better to split this into smaller patches
that do one thing at a time (typically this requires getting
used to patch stack tools like "quilt")

But it's not too bad here.

>  static inline void __tcp_fast_path_on(struct tcp_sock *tp, u32 snd_wnd)
>  {
> -	tp->pred_flags = htonl((tp->tcp_header_len << 26) |
> +	tp->pred_flags = htonl((__tcp_fast_path_header_length(tp) << (28 - 2)) |

It would be better to use defines or sizeof for the magic numbers.

> -	tp->rx_opt.saw_tstamp = 0;
> -
> -	/*	pred_flags is 0xS?10 << 16 + snd_wnd
> -	 *	if header_prediction is to be made
> -	 *	'S' will always be tp->tcp_header_len >> 2
> -	 *	'?' will be 0 for the fast path, otherwise pred_flags is 0 to
> -	 *  turn it off	(when there are holes in the receive
> -	 *	 space for instance)
> -	 *	PSH flag is ignored.
> -	 */

I liked the comment at this place.


I did a quick review of the rest and it seems ok to me.

-Andi

-- 
ak@linux.intel.com -- Speaking for myself only.
