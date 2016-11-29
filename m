From: Daniel Borkmann <daniel@iogearbox.net>
Subject: Re: [PATCH v2 net-next 10/11] qede: Add basic XDP support
Date: Tue, 29 Nov 2016 19:42:39 +0100
Message-ID: <583DCC1F.7020509@iogearbox.net>
References: <1480430830-17671-1-git-send-email-Yuval.Mintz@cavium.com>        <1480430830-17671-11-git-send-email-Yuval.Mintz@cavium.com>        <583DA362.7010702@iogearbox.net>,<20161129171020.6b8b552d@jkicinski-Precision-T1700> <BL2PR07MB23061A22119C747AA7E9A2FA8D8D0@BL2PR07MB2306.namprd07.prod.outlook.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: "davem@davemloft.net" <davem@davemloft.net>,
        "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
        "alexei.starovoitov@gmail.com" <alexei.starovoitov@gmail.com>
To: "Mintz, Yuval" <Yuval.Mintz@cavium.com>,
        Jakub Kicinski <kubakici@wp.pl>
Return-path: <netdev-owner@vger.kernel.org>
Received: from www62.your-server.de ([213.133.104.62]:51576 "EHLO
        www62.your-server.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S933462AbcK2Smu (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 29 Nov 2016 13:42:50 -0500
In-Reply-To: <BL2PR07MB23061A22119C747AA7E9A2FA8D8D0@BL2PR07MB2306.namprd07.prod.outlook.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 11/29/2016 06:51 PM, Mintz, Yuval wrote:
>>> You also need to wrap this under rcu_read_lock() (at least I haven't seen
>>> it in your patches) for same reasons as stated in 326fe02d1ed6 ("net/mlx4_en:
>>> protect ring->xdp_prog with rcu_read_lock"), as otherwise xdp_prog could
>>> disappear underneath you. mlx4 and nfp does it correctly, looks like mlx5
>>> doesn't.
>
>> My understanding was that Yuval is always doing full stop()/start() so
>> there should be no RX packets in flight while the XDP prog is being
>> changed.  But thinking about it again, perhaps is worth adding the
>> optimization to forego the full qede_reload() in qede_xdp_set() if there
>> is a program already loaded and just do the xchg()+put() (and add RCU
>> protection on the fast path)?
>
> Yeps. That the current state of the code.
> I'll surely pursue this later, but I don't think all this added complexity
> is required for the initial submission.
>
> BTW, one of the problems [or perhaps 'lack of motivation' is a better term]
> I had with the program switching scenario was that there was no sample
> application that did it.
> If it's really an interesting [basic] scenario, perhaps it's worthy to add
> a sample user app. that will repeatedly switch the attached eBPF?

Fwiw, I'm still waiting for Stephen to process his queue, and then I have
a patch for iproute2 to add a minimal initial front-end that can be useful
for experimenting/testing. The atomic switching scenario w/o stop()/start()
would definitely be useful when you need to fix an issue or modify behavior
in your currently loaded program on the fly when you cannot afford small
downtime.
