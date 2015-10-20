From: Andrew Shewmaker <agshew@gmail.com>
Subject: Re: [PATCH] allow dctcp alpha to drop to zero
Date: Tue, 20 Oct 2015 15:30:14 -0600
Message-ID: <CAF-E8XHhCMF7cCX=iYqT=OJqTOYsA-umXzy6NBM4PnenhBxm_A@mail.gmail.com>
References: <20151019045908.GB11368@mininet-vm> <20151019140135.GF4386@breakpoint.cc>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"David S. Miller" <davem@davemloft.net>,
	Glenn Judd <glenn.judd@morganstanley.com>,
	Daniel Borkmann <borkmann@iogearbox.net>
To: Florian Westphal <fw@strlen.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ob0-f172.google.com ([209.85.214.172]:33853 "EHLO
	mail-ob0-f172.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750966AbbJTVae (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 20 Oct 2015 17:30:34 -0400
Received: by obbda8 with SMTP id da8so25395801obb.1
        for <netdev@vger.kernel.org>; Tue, 20 Oct 2015 14:30:33 -0700 (PDT)
In-Reply-To: <20151019140135.GF4386@breakpoint.cc>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Oct 19, 2015 at 8:01 AM, Florian Westphal <fw@strlen.de> wrote:
> Andrew Shewmaker <agshew@gmail.com> wrote:
>> If alpha is strictly reduced by alpha >> dctcp_shift_g and if alpha is less
>> than 1 << dctcp_shift_g, then alpha may never reach zero. For example,
>> given shift_g=4 and alpha=15, alpha >> dctcp_shift_g yields 0 and alpha
>> remains 15. The effect isn't noticeable in this case below cwnd=137, but
>> could gradually drive uncongested flows with leftover alpha down to
>> cwnd=137. A larger dctcp_shift_g would have a greater effect.
>>
>> This change causes alpha=15 to drop to 0 instead of being decrementing by 1
>> as it would when alpha=16. However, it requires one less conditional to
>> implement since it doesn't have to guard against subtracting 1 from 0U. A
>> decay of 15 is not unreasonable since an equal or greater amount occurs at
>> alpha >= 240.
>>
>> Signed-off-by: Andrew G. Shewmaker <agshew@gmail.com>
>
> Acked-by: Florian Westphal <fw@strlen.de>
>
> [ cwnd=137 is quite large so I don't think its important enough for
> -stable ].

If my math is correct (please double check it), then my patch will
make a difference in scenarios such as:

data center: ~20+ Gbps and 500 microsecond RTT
137 * 9000 * 8 / (500 * pow(10, -6)) / pow(10, 9) = 19.728 Gbps
[pkt / W] * [bits / pkt] * [W / sec]

regional: ~33+ Mbps and 50 millisecond RTT
137 * 1500 * 8 / (50 * pow(10, -3)) / pow(10, 6) = 32.88 Mbps

international: ~11+ Mbps and 150 millisecond RTT
137 * 1500 * 8 / (150 * pow(10, -3)) / pow(10, 6) = 10.96 Mbps


Even if the broader internet does not ever configure ECN appropriately
for use with DCTCP, I care about the latter two cases because I'm
using an RTT-based congestion ratio in the same way as DCTCP uses its
ECN-based congestion ratio. A tech report describing use of RTTs in
this way, with some preliminary Mininet results, is available:

https://www.soe.ucsc.edu/research/technical-reports/UCSC-SOE-15-20

I plan on submitting some RFC patches to DCTCP based on my prototype soon.

-- 
Andrew Shewmaker
