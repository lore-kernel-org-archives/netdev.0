From: Alexei Starovoitov <ast@plumgrid.com>
Subject: Re: [PATCH net-next] bpf: fix cb access in socket filter programs
Date: Wed, 7 Oct 2015 09:53:57 -0700
Message-ID: <56154E25.3050309@plumgrid.com>
References: <1444184292-17500-1-git-send-email-ast@plumgrid.com>
 <5614E84E.2010806@iogearbox.net> <56151977.10302@iogearbox.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Andy Lutomirski <luto@amacapital.net>,
	Ingo Molnar <mingo@kernel.org>,
	Hannes Frederic Sowa <hannes@stressinduktion.org>,
	Eric Dumazet <edumazet@google.com>,
	Kees Cook <keescook@chromium.org>, netdev@vger.kernel.org
To: Daniel Borkmann <daniel@iogearbox.net>,
	"David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f50.google.com ([209.85.220.50]:35527 "EHLO
	mail-pa0-f50.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754179AbbJGQyH (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 7 Oct 2015 12:54:07 -0400
Received: by pacfv12 with SMTP id fv12so26897056pac.2
        for <netdev@vger.kernel.org>; Wed, 07 Oct 2015 09:53:56 -0700 (PDT)
In-Reply-To: <56151977.10302@iogearbox.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 10/7/15 6:09 AM, Daniel Borkmann wrote:
>> bpf_prog_run_clear_cb() wouldn't work on dev_forward_skb() as
>> skb->pkt_type is then being scrubbed to PACKET_HOST, so on the
>> receive path, AF_PACKET might not always see clean skbs->cb[]
>> as assumed ... I think that the skb->pkt_type part needs to be
>> dropped, no?

right. will respin.

> Thinking a bit more about this part, which only accounts for
> fanout_demux_bpf() and run_filter(), so AF_PACKET only, this
> logic still needs to be slightly different:
>
> You currently can have eBPF on packet fanout as a demux and behind
> that eBPF on the actual packet socket. So, for some reason, fanout
> could transfer some state to the socket along the way, which could
> break when cleared as-is via bpf_prog_run_clear_cb().
>
> So we need to make sure to only clear this once, either in front
> of fanout, or when not present, in front of the socket filter.

no. that would be anti-feature. user space shouldn't rely on such
things. If somebody wants to pass data between two disjoint
programs (not called via tail_call), they should be using maps or
some future per-cpu scratch area that will guarantee such semantics.
cb as part of skb is not suitable for that, since it will limit
what kernel can do in-between.
