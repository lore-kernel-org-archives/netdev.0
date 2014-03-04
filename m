From: Rick Jones <rick.jones2@hp.com>
Subject: Re: TCP being hoodwinked into spurious retransmissions by lack of
 timestamps?
Date: Tue, 04 Mar 2014 15:14:10 -0800
Message-ID: <53165E42.8070904@hp.com>
References: <53151E55.9000503@hp.com> <CABrhC0=hHpZSdE5-dLqysuFn_d_VK7r1jKb0kGZF9hn1+UHjDw@mail.gmail.com> <53162093.1040208@hp.com> <CABrhC0k5-x=qJgH4izXtRR=9+cLJh_emAy9Yt=+xrY6K5982Fg@mail.gmail.com> <53162A6E.2010907@hp.com> <CADVnQyn7qqAZn5ZF8wQP_Hn-9s84uc4DUC6r8_ne7bY5Kexycg@mail.gmail.com> <CAK6E8=eBUUx4v11VTVQMKHWZdbCsut4zzr-LXJWd=fJTYsb39A@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: John Heffner <johnwheffner@gmail.com>,
	Netdev <netdev@vger.kernel.org>
To: Yuchung Cheng <ycheng@google.com>,
	Neal Cardwell <ncardwell@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from g4t3426.houston.hp.com ([15.201.208.54]:50002 "EHLO
	g4t3426.houston.hp.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755209AbaCDXOM (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 4 Mar 2014 18:14:12 -0500
In-Reply-To: <CAK6E8=eBUUx4v11VTVQMKHWZdbCsut4zzr-LXJWd=fJTYsb39A@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 03/04/2014 02:23 PM, Yuchung Cheng wrote:
> On Tue, Mar 4, 2014 at 12:35 PM, Neal Cardwell <ncardwell@google.com> wrote:
>> What's the receiver OS in this trace? It's reneging on SACKs. :-) Take
>> a look at this ACK:
>>
>> 18:20:46.800063 IP 75.236.145.7.443 > 91.216.86.7.56064: .
>> 4262:4262(0) ack 3171368 win 32716 <nop,nop,sack 1 {3171368:3177208}>
>>
>> Note that it's ACKing 3171368 and SACKing the adjacent sequence range:
>> {3171368:3177208}. That's not cool.
>>
>> I think that's causing the Linux sender to enter the
>> tcp_check_sack_reneging() code path, which calls tcp_enter_loss().
>>
>> It seems that the Linux sender did not enable FRTO for that
>> tcp_enter_loss() invocation. Maybe there is some way we can revise the
>> logic to enable FRTO in cases like this, so we can detect that the
>> retransmission was not needed, and abort the stream of spurious
>> retransmissions...
> Sure we can try:
>
> diff --git a/net/ipv4/tcp_input.c b/net/ipv4/tcp_input.c
> index 6e48093..735ece6 100644
> --- a/net/ipv4/tcp_input.c
> +++ b/net/ipv4/tcp_input.c
> @@ -1972,7 +1972,7 @@ void tcp_enter_loss(struct sock *sk, int how)
>           * the same SND.UNA (sec 3.2). Disable F-RTO on path MTU probing
>           */
>          tp->frto = sysctl_tcp_frto &&
> -                  (new_recovery || icsk->icsk_retransmits) &&
> +                  (new_recovery || icsk->icsk_retransmits || how) &&
>                     !inet_csk(sk)->icsk_mtup.probe_size;
>   }
>
>
> However that only works if we got new data to send. For a better
> solution, with the lack of TS option or DSACK support, we can
> 1) use Neal's neat idea to send a different size packet on the first
> retransmission after timeout, and use that to distinguish if the ACK
> is for the original or retry.

What would one do if the ACK arriving after the short retransmission was 
farther to the right than the end of the original packet?  Won't that be 
ambiguous?

> 2) Do not blindly marked any packet unsacked lost in tcp_enter_loss;
> My idea would be to do that only if the packet was sent min_rtt ago;
>
> I can try to implement these ideas if people are interested.

If these near-heroics are unnecessary if timestamps are present, I'm not 
sure I'd push too hard.  Unless you think that timestamps not being 
present is sufficiently common.

rick
