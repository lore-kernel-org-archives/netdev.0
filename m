From: "=?ISO-8859-15?Q?Ilpo_J=E4rvinen?=" <ilpo.jarvinen@helsinki.fi>
Subject: Re: [PATCH] [RFC] IPv4 TCP fails to send window scale option when
 window scale is zero
Date: Wed, 30 Sep 2009 14:42:50 +0300 (EEST)
Message-ID: <alpine.DEB.2.00.0909301428140.13543@wel-95.cs.helsinki.fi>
References: <4AC22250.7060301@codefidence.com> <4AC241BA.8040608@gmail.com> <4AC2FA7C.6030901@codefidence.com> <4AC305BF.6080306@gmail.com>
Mime-Version: 1.0
Content-Type: MULTIPART/MIXED; BOUNDARY="8323329-939190077-1254310971=:13543"
Cc: Gilad Ben-Yossef <gilad@codefidence.com>,
	Netdev <netdev@vger.kernel.org>, Ori Finkalman <ori@comsleep.com>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from courier.cs.helsinki.fi ([128.214.9.1]:43874 "EHLO
	mail.cs.helsinki.fi" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753925AbZI3Lms (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 30 Sep 2009 07:42:48 -0400
In-Reply-To: <4AC305BF.6080306@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

  This message is in MIME format.  The first part should be readable text,
  while the remaining parts are likely unreadable without MIME-aware tools.

--8323329-939190077-1254310971=:13543
Content-Type: TEXT/PLAIN; charset=iso-8859-1
Content-Transfer-Encoding: 8BIT

On Wed, 30 Sep 2009, Eric Dumazet wrote:

> Gilad Ben-Yossef a écrit :
> >
> > Eric Dumazet wrote:
> > 
> >> Gilad Ben-Yossef a écrit :
> >>  
> >>> From: Ori Finkalman <ori@comsleep.com>
> >>>
> >>>
> >>> Acknowledge TCP window scale support by inserting the proper option in
> >>> SYN/ACK header
> >>> even if our window scale is zero.
> >>>
> >>>
> >>> This fixes the following observed behavior:
> >>>
> >>>
> >>> 1. Client sends a SYN with TCP window scaling option and non zero window
> >>> scale value to a Linux box.
> >>>
> >>> 2. Linux box notes large receive window from client.
> >>>
> >>> 3. Linux decides on a zero value of window scale for its part.
> >>>
> >>> 4. Due to compare against requested window scale size option, Linux does
> >>> not to send windows scale
> >>>
> >>> TCP option header on SYN/ACK at all.
> >>>
> >>>
> >>> Result:
> >>>
> >>>
> >>> Client box thinks TCP window scaling is not supported, since SYN/ACK had
> >>> no TCP window scale option,
> >>> while Linux thinks that TCP window scaling is supported (and scale might
> >>> be non zero), since SYN had
> >>>
> >>> TCP window scale option and we have a mismatched idea between the client
> >>> and server regarding window sizes.
> >>>
> >>>
> >>> Please comment and/or apply.
> >>> ...
> >>>
> >>>
> >>> Signed-off-by: Gilad Ben-Yossef <gilad@codefidence.com>
> >>> Signed-off-by: Ori Finkelman <ori@comsleep.com>
> >>>
> >>>
> >>> Index: net/ipv4/tcp_output.c
> >>> ===================================================================
> >>> --- net/ipv4/tcp_output.c    (revision 46)
> >>> +++ net/ipv4/tcp_output.c    (revision 210)
> >>> @@ -353,6 +353,7 @@ static void tcp_init_nondata_skb(struct
> >>> #define OPTION_SACK_ADVERTISE    (1 << 0)
> >>> #define OPTION_TS        (1 << 1)
> >>> #define OPTION_MD5        (1 << 2)
> >>> +#define OPTION_WSCALE        (1 << 3)
> >>>
> >>> struct tcp_out_options {
> >>>     u8 options;        /* bit field of OPTION_* */
> >>> @@ -417,7 +418,7 @@ static void tcp_options_write(__be32 *pt
> >>>                    TCPOLEN_SACK_PERM);
> >>>     }
> >>>
> >>> -    if (unlikely(opts->ws)) {
> >>> +    if (unlikely(OPTION_WSCALE & opts->options)) {
> >>>         *ptr++ = htonl((TCPOPT_NOP << 24) |
> >>>                    (TCPOPT_WINDOW << 16) |
> >>>                    (TCPOLEN_WINDOW << 8) |
> >>> @@ -530,8 +531,8 @@ static unsigned tcp_synack_options(struc
> >>>
> >>>     if (likely(ireq->wscale_ok)) {
> >>>         opts->ws = ireq->rcv_wscale;
> >>> -        if(likely(opts->ws))
> >>> -            size += TCPOLEN_WSCALE_ALIGNED;
> >>> +        opts->options |= OPTION_WSCALE;
> >>> +        size += TCPOLEN_WSCALE_ALIGNED;
> >>>     }
> >>>     if (likely(doing_ts)) {
> >>>         opts->options |= OPTION_TS;
> >>>
> >>>
> >>>
> >>>     
> >>
> >> Seems not the more logical places to put this logic...
> >>
> >> How about this instead ?
> >>
> >> diff --git a/net/ipv4/tcp_output.c b/net/ipv4/tcp_output.c
> >> index 5200aab..b78c084 100644
> >> --- a/net/ipv4/tcp_output.c
> >> +++ b/net/ipv4/tcp_output.c
> >> @@ -216,6 +216,11 @@ void tcp_select_initial_window(int __space, __u32
> >> mss,
> >>              space >>= 1;
> >>              (*rcv_wscale)++;
> >>          }
> >> +        /*
> >> +         * Set a minimum wscale of 1
> >> +         */
> >> +        if (*rcv_wscale == 0)
> >> +            *rcv_wscale = 1;
> >>         }
> >>
> >>         /* Set initial window to value enough for senders,
> >>
> >>   
> > 
> > Thank you for the patch review. The suggested replacement patch
> > certainly is shorter, code wise, which is an advantage.
> > 
> > I cant help but feel though, that it is less readable - a window scale
> > of zero is a perfectly legit value. Adding special logic to rule it out
> > just because we chose to overload this setting for something else
> > (whether window scaling is supported or not) seems like an invitation
> > for someone to get it wrong again down the line, in my opinion.
> 
> As a matter of fact I didnot test your patch.
> 
> My reaction was driven by :
> 
> Your version slows down the tcp_options_write() function, once per tx packet.

Are you serious that anding would cost that much? :-/

> tcp_options_write() should not change socket state,

I fail to see how his patch was changing socket state in anyway in 
anywhere?

> while
> tcp_select_initial_window() is the exact place where we are supposed to
> compute wscale. 

And it calculated yielding to result of 0, which is perfectly valid. The 
problem is that tcp_write_options thinks that 0 is indication of no window 
scaling, instead of the correct interpretation of zero window scaling 
which makes the huge difference for the opposite direction traffic as 
these guys have noted. Not that I find your approach that bad either as 
we only lose 1-bit accuracy for the window which is rather insignificant 
as 1-byte window increments do not really make that much sense anyway 
(and we have to specifically code against doing them anyway so the 
effective granularity is much higher).

> Also how is managed tcp_syn_options() case (for outgoing connections ?)
> 
>         if (likely(sysctl_tcp_window_scaling)) {
>                 opts->ws = tp->rx_opt.rcv_wscale;
>                 if (likely(opts->ws))
>                         size += TCPOLEN_WSCALE_ALIGNED;
>         }
> 
> Dont you need to patch it as well ?

One certainly should change that too if that patch is the way to go 
forward.

-- 
 i.
--8323329-939190077-1254310971=:13543--
