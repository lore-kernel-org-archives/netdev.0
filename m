From: William Allen Simpson <william.allen.simpson@gmail.com>
Subject: Re: [PATCH] tcp: harmonize tcp_vx_rcv header length assumptions
Date: Tue, 12 Jan 2010 12:14:17 -0500
Message-ID: <4B4CADE9.3090302@gmail.com>
References: <4B49D001.4000302@gmail.com> <4B4C4962.8040207@gmail.com> <4B4C52EA.6070705@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Linux Kernel Developers <linux-kernel@vger.kernel.org>,
	Linux Kernel Network Developers <netdev@vger.kernel.org>,
	=?ISO-8859-1?Q?Ilpo_J=E4rvinen?= <ilpo.jarvinen@helsinki.fi>,
	Andi Kleen <andi@firstfloor.org>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1754214Ab0ALROY@vger.kernel.org>
In-Reply-To: <4B4C52EA.6070705@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Eric Dumazet wrote:
> 2) This part :
> 
> -	th = tcp_hdr(skb);
> -
> -	if (th->doff < sizeof(struct tcphdr)/4)
> +	/* Check bad doff, compare doff directly to constant value */
> +	tcp_header_len = tcp_hdr(skb)->doff;
> +	if (tcp_header_len < (sizeof(struct tcphdr) / 4))
>  		goto bad_packet;
> -	if (!pskb_may_pull(skb, th->doff*4))
> +
> +	/* Check too short header and options */
> +	tcp_header_len *= 4;
> +	if (!pskb_may_pull(skb, tcp_header_len))
>  		goto discard_it;
> 
> 
> could be :  (no need for 4 multiplies/divides)
> 
> 	tcp_header_len = tcp_header_len_th(tcp_hdr(skb));
> 	if (tcp_header_len < sizeof(struct tcphdr))
> 		goto bad_packet;
> 	/* Check too short header and options */
> 	if (!pskb_may_pull(skb, tcp_header_len))
> 		goto discard_it;
> 
Actually, tcp_header_len_th() has a multiply by 4 in it, too.

My code exactly parallels the existing code.  That is slightly faster
for bad packets, as it does the raw comparison first, saving the
multiply by 4 until it has passed that test.

My change just saves a store (and maybe a register load) over the
existing code.  This is supposed to be "fast path" after all....

Also adds comments that explain what we're doing.  As I mentioned
earlier in the thread:

                  ... back on Nov 10th, Ilpo brought to my attention --
   *hidden* inside the pskb_may_pull() -- the tcp header length is range
   checked for being too short (skb->len < th->doff * 4).

Anytime I find the code isn't obvious to me, I figure the next person
will benefit from some more comments....

(Of course, this patch also fixes existing comments that are not true!)
