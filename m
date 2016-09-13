From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net-next 1/2] net: mvneta: add xmit_more support
Date: Tue, 13 Sep 2016 07:42:28 -0700
Message-ID: <1473777748.18970.120.camel@edumazet-glaptop3.roam.corp.google.com>
References: <1473750006-21199-1-git-send-email-mw@semihalf.com>
         <1473750006-21199-2-git-send-email-mw@semihalf.com>
         <1473777182.18970.118.camel@edumazet-glaptop3.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, linux-arm-kernel@lists.infradead.org,
        netdev@vger.kernel.org, davem@davemloft.net,
        linux@arm.linux.org.uk, sebastian.hesselbarth@gmail.com,
        andrew@lunn.ch, jason@lakedaemon.net,
        thomas.petazzoni@free-electrons.com,
        gregory.clement@free-electrons.com, nadavh@marvell.com,
        alior@marvell.com, simon.guinot@sequanux.org, nitroshift@yahoo.com,
        jaz@semihalf.com
To: Marcin Wojtas <mw@semihalf.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1473777182.18970.118.camel@edumazet-glaptop3.roam.corp.google.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, 2016-09-13 at 07:33 -0700, Eric Dumazet wrote:

> Hi Marcin
> 
> Well, given the above comment, and fact that MVNETA_MAX_TXD == 532, it
> looks like you might add a bug if more than 256 skb are given to your
> ndo_start_xmit() with skb->xmit_more = 1
> 
> I therefore suggest you make sure it does not happen.
> 
> txq->pending += frags;
> if (!skb->xmit_more ||
>     txq->pending > 256 - MVNETA_MAX_SKB_DESCS ||
>     netif_xmit_stopped(nq))
> 	mvneta_txq_pend_desc_add(pp, txq)
> 

Another solution would be to test the potential overflow in mvneta_tx()
and force a mvneta_txq_pend_desc_add(pp, txq) _before_ adding the desc
of the "about to be cooked" TSO packet.

(This is because MVNETA_MAX_SKB_DESCS is 217, so 255-217 leaves few room
for xmit_more to show its power)
