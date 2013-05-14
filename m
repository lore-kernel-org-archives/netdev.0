From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: RE: [PATCH v2 net 2/2] tg3: Fix data corruption on 5725 with TSO
Date: Tue, 14 May 2013 09:46:10 -0700
Message-ID: <1368549970.4519.16.camel@edumazet-glaptop>
References: <1368479056-11780-1-git-send-email-nsujir@broadcom.com>
	 <1368479056-11780-3-git-send-email-nsujir@broadcom.com>
	 <1368479644.13473.121.camel@edumazet-glaptop>
	 <51915C7D.2000407@broadcom.com>
	 <1368481224.13473.124.camel@edumazet-glaptop>
	 <51915F77.5000405@broadcom.com>
	 <AE90C24D6B3A694183C094C60CF0A2F6026B7236@saturn3.aculab.com>
	 <1368543869.12268.49.camel@LTIRV-MCHAN1.corp.ad.broadcom.com>
	 <AE90C24D6B3A694183C094C60CF0A2F6026B7237@saturn3.aculab.com>
	 <1368548345.12268.76.camel@LTIRV-MCHAN1.corp.ad.broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: David Laight <David.Laight@ACULAB.COM>,
	Nithin Nayak Sujir <nsujir@broadcom.com>,
	davem@davemloft.net, netdev@vger.kernel.org, stable@vger.kernel.org
To: Michael Chan <mchan@broadcom.com>
Return-path: <stable-owner@vger.kernel.org>
In-Reply-To: <1368548345.12268.76.camel@LTIRV-MCHAN1.corp.ad.broadcom.com>
Sender: stable-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, 2013-05-14 at 09:19 -0700, Michael Chan wrote:

> We relocate once and then drop the packet if we encounter additional
> errors, including OOM, DMA mapping error, 4G boundary, etc.  The new
> linear skb should not hit the 4G boundary again.  The room between the
> end of this current buffer and 4G isn't big enough for the new linear
> skb.

This remind me an issue on bnx2x :

bnx2x FW has a limitation on GSO packets :
    
A single mss can not span more than 10 fragments.

After "net: use a per task frag allocator" patch, its possible
for an application interleaving small write() on several sockets
to build pathological skbs using 16 fragments (aka MAX_SKB_FRAGS)
but small amount of payload.
    
Fast path should build skbs with 2 or 3 fragments, as fragments
can be order-3 pages.
    
bnx2x driver performs an expensive skb_linearize() call and
this can fail if memory is fragmented : skb->len can be around 64K,
and including the skb_shared_info overhead, we might need order-5
pages.
