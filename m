From: Kenneth Klette Jonassen <kennetkl@ifi.uio.no>
Subject: Re: tcp: picking a less conservative SACK RTT for congestion control
Date: Sun, 12 Apr 2015 19:53:37 +0200
Message-ID: <CA++eYdtaP8eycpOMWNsPS5npQYjf7nXUfZJSAoXGEnSkVmHQ6A@mail.gmail.com>
References: <CA++eYdt8YT+xp88N7KFX3OMoHO3sVS6yfnuPDHLrWpM2w3NzRw@mail.gmail.com>
	<CAK6E8=e0N40JZ8iHM55=s5Ddxjez8eJv2LoVRuiajKuCer7XJg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: netdev <netdev@vger.kernel.org>,
	Eric Dumazet <edumazet@google.com>,
	Neal Cardwell <ncardwell@google.com>,
	=?UTF-8?Q?Ilpo_J=C3=A4rvinen?= <ilpo.jarvinen@helsinki.fi>,
	Stephen Hemminger <stephen@networkplumber.org>
To: Yuchung Cheng <ycheng@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f173.google.com ([209.85.212.173]:34667 "EHLO
	mail-wi0-f173.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751678AbbDLRxj (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 12 Apr 2015 13:53:39 -0400
Received: by widjs5 with SMTP id js5so48985630wid.1
        for <netdev@vger.kernel.org>; Sun, 12 Apr 2015 10:53:37 -0700 (PDT)
In-Reply-To: <CAK6E8=e0N40JZ8iHM55=s5Ddxjez8eJv2LoVRuiajKuCer7XJg@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

>> What would be the feasible approach to track the last segment sacked? I was
>> thinking of keeping first/last skb_mstamp's in struct tcp_sacktag_state akin
>> to the way it is done in tcp_clean_rtx_queue(). This would require passing
> or use last sacked skb mstamp instead of first for sack_rtt? IMO it
> won't matter that much for RTTM.
>
> or a new ca_sack_rtt in tcp_sacktag_state and pass the state to
> tcp_clean_rtx_queue as well. the latter is more generic and extendable?
That is a likely solution. Although, intuitively, I am not really
happy about having two different skb_mstamp_get()'s in the ACK code
path for RTT since it might contribute to the variance between RTTMs.

>> eight more bytes around on 64 bit. An alternative that is slightly obscure
>> is to store the delta between the first and last sack in a 4 byte value.
>> Since struct tcp_sacktag_state currently has 4 bytes padding, this does not
>> require passing more data around -- just changing "long sack_rtt_us" to
>> a pointer. It can have some microscale cache locality impacts though. I
> seems too complicated
Maybe. I thought so too at first. But then again, this stuff is
somewhat complicated either way. I took a swing at it today, submitted
as RFC just now:
http://patchwork.ozlabs.org/patch/460536/
(Only CC'd Yuchung on it to keep email volume down.)
