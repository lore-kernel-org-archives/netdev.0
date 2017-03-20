From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [net-next PATCH 1/2] net: Busy polling should ignore sender CPUs
Date: Mon, 20 Mar 2017 15:16:11 -0700
Message-ID: <1490048171.16816.85.camel@edumazet-glaptop3.roam.corp.google.com>
References: <20170320214643.13922.51284.stgit@localhost.localdomain>
         <20170320214848.13922.79201.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
        sridhar.samudrala@intel.com, edumazet@google.com,
        davem@davemloft.net
To: Alexander Duyck <alexander.duyck@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20170320214848.13922.79201.stgit@localhost.localdomain>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, 2017-03-20 at 14:48 -0700, Alexander Duyck wrote:
> From: Alexander Duyck <alexander.h.duyck@intel.com>
> 
> This patch is a cleanup/fix for NAPI IDs following the changes that made it
> so that sender_cpu and napi_id were doing a better job of sharing the same
> location in the sk_buff.
> 
> One issue I found is that we weren't validating the napi_id as being valid
> before we started trying to setup the busy polling.  This change corrects
> that by using the MIN_NAPI_ID value that is now used in both allocating the
> NAPI IDs, as well as validating them.
> 
> Fixes: 52bd2d62ce675 ("net: better skb->sender_cpu and skb->napi_id cohabitation")
> Signed-off-by: Alexander Duyck <alexander.h.duyck@intel.com>
> ---

This Fixes: tag seems not really needed here.

If really busy polling is attempted to a socket with a <wrong> napi id,
nothing bad happens. This fits the advisory model of busy polling...

Otherwise, your patch would be a candidate for net tree.

Also note that as soon as sk_can_busy_loop(sk) returns some status,
another cpu might already have changed sk->sk_napi_id to something else,
possibly with a <wrong> napi id again.

If your upcoming code depends on sk->sk_napi_id being verified, then
you need to read it once.
