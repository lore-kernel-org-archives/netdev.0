From: Milton Miller <miltonm@bga.com>
Subject: Re: potential null pointer dereference in drivers/isdn/hisax/isdnl2.c
Date: Tue, 15 Feb 2011 14:09:16 -0600
Message-ID: <1297800556_10580@mail4.comsite.net>
References: <20110213.165309.123985803.davem@davemloft.net>
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	tj@kernel.org, isdn@linux-pingi.de, jj@chaosbits.net
To: David Miller <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20110213.165309.123985803.davem@davemloft.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, 14 Feb 2011 00:53:09 -0000, Dave Miler wrote:
> From: Jesper Juhl <jj@chaosbits.net>
> 
> > In drivers/isdn/hisax/isdnl2.c:l2_pull_iqueue() we have this:
> > 
> > 	...
> > 		skb = alloc_skb(oskb->len + i, GFP_ATOMIC);
> > 		memcpy(skb_put(skb, i), header, i);
> > 	...
> > 
> > If alloc_skb() fails and returns NULL then the second line will cause a 
> > NULL pointer dereference - skb_put() gives the pointer to 
> > skb_tail_pointer() which dereferences it.
> > 
> > I'm not quite sure how this should be dealt with, so I'll just report it 
> > rather than submit a patch. Happy bug fixing :-)
> 
> Thanks Jesper, I'll fix this like so:
> 
> --------------------
> hisax: Fix unchecked alloc_skb() return.
> 
> Jesper Juhl noticed that l2_pull_iqueue() does not
> check to see if alloc_skb() fails.
> 
> Fix this by first trying to reallocate the headroom
> if necessary, rather than later after we've made hard
> to undo state changes.
> 
> Reported-by: Jesper Juhl <jj@chaosbits.net>
> Signed-off-by: David S. Miller <davem@davemloft.net>
> 
> ---
> drivers/isdn/hisax/isdnl2.c |   35 ++++++++++++++++++++---------------
>  1 files changed, 20 insertions(+), 15 deletions(-)
> 
> diff --git a/drivers/isdn/hisax/isdnl2.c b/drivers/isdn/hisax/isdnl2.c
> index 0858791..98ac835 100644
> --- a/drivers/isdn/hisax/isdnl2.c
> +++ b/drivers/isdn/hisax/isdnl2.c
> @@ -1243,14 +1243,21 @@ l2_st7_tout_203(struct FsmInst *fi, int event, void *arg)
>  	st->l2.rc = 0;
>  }
>  
> +static int l2_hdr_space_needed(struct Layer2 *l2)
> +{
> +	int len = test_bit(FLG_LAPD, &l2->flag) ? 2 : 1;
> +
> +	return len + (test_bit(FLG_LAPD, &l2->flag) ? 2 : 1);
> +}
> +

That struck me as an funny way to write 2 * len, so I finally looked
at the code.  I think one of those should be FLG_MOD128, but then
at that point why not use the existing l2headersize(l2, ui) with
ui = 0?

I see this is in linux-next of Feb 15, 2011.

milton
