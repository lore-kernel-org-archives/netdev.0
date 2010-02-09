From: Andreas Petlund <apetlund@simula.no>
Subject: Re: [net-next PATCH v2 2/3] net: TCP thin linear timeouts
Date: Tue, 09 Feb 2010 17:40:20 +0100
Message-ID: <4B718FF4.6040906@simula.no>
References: <4B701EE2.1000006@simula.no> <4B707901.50905@tvk.rwth-aachen.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	=?ISO-8859-1?Q?Ilpo_J=E4rvinen?= <ilpo.jarvinen@helsinki.fi>,
	Eric Dumazet <eric.dumazet@gmail.com>,
	Arnd Hannemann <hannemann@nets.rwth-aachen.de>,
	LKML <linux-kernel@vger.kernel.org>, shemminger@vyatta.com,
	David Miller <davem@davemloft.net>,
	william.allen.simpson@gmail.com
To: Damian Lukowski <damian@tvk.rwth-aachen.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-forward2.uio.no ([129.240.10.71]:47195 "EHLO
	mail-forward2.uio.no" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754950Ab0BIQjy (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 9 Feb 2010 11:39:54 -0500
Received: from exim by mail-out2.uio.no with local-bsmtp (Exim 4.69)
	(envelope-from <apetlund@simula.no>)
	id 1Net7w-0006RT-TN
	for netdev@vger.kernel.org; Tue, 09 Feb 2010 17:39:52 +0100
In-Reply-To: <4B707901.50905@tvk.rwth-aachen.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 02/08/2010 09:50 PM, Damian Lukowski wrote:
>>  out_reset_timer:
>> -	icsk->icsk_rto = min(icsk->icsk_rto << 1, TCP_RTO_MAX);
>> +	/* If stream is thin, use linear timeouts. Since 'icsk_backoff' is
>> +	 * used to reset timer, set to 0. Recalculate 'icsk_rto' as this
>> +	 * might be increased if the stream oscillates between thin and thick,
>> +	 * thus the old value might already be too high compared to the value
>> +	 * set by 'tcp_set_rto' in tcp_input.c which resets the rto without
>> +	 * backoff. Limit to TCP_THIN_LT_RETRIES before initiating exponential
>> +	 * backoff behaviour to avoid continue hammering linear-timeout 
>> +	 * retransmissions into a black hole*/
>> +	if ((tp->thin_lt || sysctl_tcp_force_thin_linear_timeouts) &&
>> +	    tcp_stream_is_thin(sk) && sk->sk_state == TCP_ESTABLISHED &&
>> +	    icsk->icsk_retransmits <= TCP_THIN_LT_RETRIES) {
>> +		icsk->icsk_backoff = 0;
> 
> Hi,
> I think, this value should be at least 1, as icsk_backoff
> might be decreased to -1 and used for bit-shifting in tcp_v4_err().
> A lower boundary check might be even better.

Hi

Thanks for the feedback.

As far as I can see, the check a couple of lines above the decrementation
stops the icsk->icsk_backoff from being decremented if already zero.
Beyond that I cannot find any more places where this situation may arise.
Please correct me if I'm wrong and a boundary check is indeed warranted.


Excerpt from tcp_ipv4.c
------------------
                if (seq != tp->snd_una  || !icsk->icsk_retransmits ||
                    !icsk->icsk_backoff)
                        break;

                icsk->icsk_backoff--;
                inet_csk(sk)->icsk_rto = __tcp_set_rto(tp) <<
                                         icsk->icsk_backoff;
------------------

Best regards,
Andreas
