From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net v6 4/4] tg3: Fix tx_pending checks for tg3_tso_bug
Date: Fri, 05 Sep 2014 17:03:30 -0700
Message-ID: <1409961810.26422.149.camel@edumazet-glaptop2.roam.corp.google.com>
References: <1409880647-14887-1-git-send-email-bpoirier@suse.de>
	 <1409880647-14887-5-git-send-email-bpoirier@suse.de>
	 <1409960135.18724.33.camel@prashant>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Benjamin Poirier <bpoirier@suse.de>,
	Michael Chan <mchan@broadcom.com>, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: Prashant Sreedharan <prashant@broadcom.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1409960135.18724.33.camel@prashant>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, 2014-09-05 at 16:35 -0700, Prashant Sreedharan wrote:

> fyi.. Initially the driver was doing a skb_copy()
> (tigon3_dma_hwbug_workaround()) for LSO skb that met HW bug conditions
> but users started reporting page allocation failures due to copying of
> large LSO skbs. To avoid this Commit 4caab52eb102f1 (tg3: Prevent page
> allocation failure during TSO workaround) changed the driver logic to do
> skb_gso_segment() for LSO skbs that met the HW bug conditions. With
> skb_linearize() we might end up again with memory allocation failures
> for large LSO skbs though at a much less frequent level (ie when TX
> queue is almost full). 

Note that TCP stack has one skb collapse feature, currently limited in
allocation of linear skbs fitting a whole page.

Instead of this private helper (and pretty limited one btw), we could
add a core function, that would build skbs with order-0 fragments.

Instead of skb_linearize(), I guess many call sites could instead use
this new helper.

Because as you said, skb_linearize() of one 64KB GSO packet can ask
order-5 allocations, and this generally does not work reliably.
