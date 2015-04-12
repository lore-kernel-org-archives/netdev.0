From: Yuchung Cheng <ycheng@google.com>
Subject: Re: tcp: picking a less conservative SACK RTT for congestion control
Date: Sun, 12 Apr 2015 08:59:45 -0700
Message-ID: <CAK6E8=e0N40JZ8iHM55=s5Ddxjez8eJv2LoVRuiajKuCer7XJg@mail.gmail.com>
References: <CA++eYdt8YT+xp88N7KFX3OMoHO3sVS6yfnuPDHLrWpM2w3NzRw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: netdev <netdev@vger.kernel.org>,
	Eric Dumazet <edumazet@google.com>,
	Neal Cardwell <ncardwell@google.com>,
	=?UTF-8?Q?Ilpo_J=C3=A4rvinen?= <ilpo.jarvinen@helsinki.fi>,
	Stephen Hemminger <stephen@networkplumber.org>
To: Kenneth Klette Jonassen <kennetkl@ifi.uio.no>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ie0-f180.google.com ([209.85.223.180]:35230 "EHLO
	mail-ie0-f180.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751573AbbDLQA1 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 12 Apr 2015 12:00:27 -0400
Received: by iejt8 with SMTP id t8so48783158iej.2
        for <netdev@vger.kernel.org>; Sun, 12 Apr 2015 09:00:26 -0700 (PDT)
In-Reply-To: <CA++eYdt8YT+xp88N7KFX3OMoHO3sVS6yfnuPDHLrWpM2w3NzRw@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, Apr 11, 2015 at 12:50 PM, Kenneth Klette Jonassen
<kennetkl@ifi.uio.no> wrote:
> tcp_sacktag_one() currently picks the earliest sequence sacked for RTT. This
> makes sense when data is sacked due to reordering as described in commit
> 832d11c5 ("Try to restore large SKBs while SACK processing"). But it might
> not make sense for CC in cases where:
>
>  1. ACKs are lost, i.e. a SACK subsequent to a lost SACK covers both a new
>     and an old segment at the receiver. A concrete example follows below.
>  2. The receiver disregards the rfc5681 recommendation to immediately ack
>     out-of-order segments, perhaps due to a hardware offload mechanism.
>
> We have an implementation of the experimental congestion controller CDG [1]
> which can perform slightly better in environments with random loss. Unlike
> e.g. Vegas which resets all internal state when loss is detected, CDG is
> quite sensitive to recent RTT changes even during loss recovery.
>
> What would be the feasible approach to track the last segment sacked? I was
> thinking of keeping first/last skb_mstamp's in struct tcp_sacktag_state akin
> to the way it is done in tcp_clean_rtx_queue(). This would require passing
or use last sacked skb mstamp instead of first for sack_rtt? IMO it
won't matter that much for RTTM.

or a new ca_sack_rtt in tcp_sacktag_state and pass the state to
tcp_clean_rtx_queue as well. the latter is more generic and extendable?

> eight more bytes around on 64 bit. An alternative that is slightly obscure
> is to store the delta between the first and last sack in a 4 byte value.
> Since struct tcp_sacktag_state currently has 4 bytes padding, this does not
> require passing more data around -- just changing "long sack_rtt_us" to
> a pointer. It can have some microscale cache locality impacts though. I
seems too complicated

> envision that both approaches saves the call to skb_mstamp_get() in
> tcp_sacktag_one().
>
> 1. http://caia.swin.edu.au/cv/dahayes/content/networking2011-cdg-preprint.pdf
>
> PS: The pkts_acked CC hook is not currently called unless new data is acked
> sequentially. I have a simple patch that calls it for new SACK RTTs, but I
> am holding it off until my recent patch is reviewed (fix bogus RTT for CC).
>
> ---
>
> Concrete example. Path has 1% uniform loss, no reordering. Prints show delta
> timestamped packets separately captured at sender and receiver.
>
> Receiver sends two acks:
> 00:00:00.005018 IP 10.0.1.2.5001 > 10.0.0.2.48089: Flags [.], ack
> 3824632751, win 32746, options [nop,nop,TS val 1820536519 ecr
> 2169294,nop,nop,sack 1 {3824634199:3824651575}], length 0
> 00:00:00.004871 IP 10.0.1.2.5001 > 10.0.0.2.48089: Flags [.], ack
> 3824632751, win 32746, options [nop,nop,TS val 1820536524 ecr
> 2169294,nop,nop,sack 1 {3824634199:3824653023}], length 0
>
> One reaches the sender:
> 00:00:00.009842 IP 10.0.1.2.5001 > 10.0.0.2.48089: Flags [.], ack
> 3824632751, win 32746, options [nop,nop,TS val 1820536524 ecr
> 2169294,nop,nop,sack 1 {3824634199:3824653023}], length 0
>
> Trace output at sender:
> 8968.105153: tcp_sacktag_one: first sacked range 3824648679 -
> 3824651575 rtt 75129
> 8968.105157: tcp_sacktag_one: later sacked range 3824651575 -
> 3824653023 rtt 70224 (rtt not used)
