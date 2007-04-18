From: Jarek Poplawski <jarkao2@o2.pl>
Subject: Re: kernel BUG at net/core/skbuff.c in linux-2.6.21-rc6
Date: Wed, 18 Apr 2007 14:42:33 +0200
Message-ID: <20070418124233.GA2218@ff.dom.local>
References: <17953.30429.220756.818283@cargo.ozlabs.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>, kaber@trash.net,
	poemann@gmail.com, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org
To: Paul Mackerras <paulus@samba.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx2.go2.pl ([193.17.41.42]:56379 "EHLO poczta.o2.pl"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1422897AbXDRMhB (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 18 Apr 2007 08:37:01 -0400
Content-Disposition: inline
In-Reply-To: <17953.30429.220756.818283@cargo.ozlabs.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi,

I didn't analyse this bug report but probably it
is nearly connected with one of the bugs visible in
a log from this submit:

http://bugzilla.kernel.org/show_bug.cgi?id=8132

On 15-04-2007 02:50, Paul Mackerras wrote:
> David Miller writes:
> 
>> Here is Patrick McHardy's patch:
> 
> So this doesn't change process_input_packet(), which treats the case
> where the first byte is 0xff (PPP_ALLSTATIONS) but the second byte is
> 0x03 (PPP_UI) as indicating a packet with a PPP protocol number of
> 0xff.  Arguably that's wrong since PPP protocol 0xff is reserved, and
> the RFC does envision the possibility of receiving frames where the
> control field has values other than 0x03.
> 
> Therefore I think this patch is probably better.  Could people try it
> out and let me know if it fixes the problem?
> 
> Paul.
> 
> diff --git a/drivers/net/ppp_async.c b/drivers/net/ppp_async.c
> index 933e2f3..caabbc4 100644
> --- a/drivers/net/ppp_async.c
> +++ b/drivers/net/ppp_async.c
> @@ -802,9 +802,9 @@ process_input_packet(struct asyncppp *ap)
>  
>  	/* check for address/control and protocol compression */
>  	p = skb->data;
> -	if (p[0] == PPP_ALLSTATIONS && p[1] == PPP_UI) {
> +	if (p[0] == PPP_ALLSTATIONS) {
>  		/* chop off address/control */
> -		if (skb->len < 3)
> +		if (p[1] != PPP_UI || skb->len < 3)
>  			goto err;
>  		p = skb_pull(skb, 2);
>  	}

Let's look farther:

>        proto = p[0];
>        if (proto & 1) {
>                /* protocol is compressed */
>                skb_push(skb, 1)[0] = 0;

BTW - about Patrick's patch:

skb_push seems to be dependent here on the 1-st char of
skb->data, if above (p[0] != PPP_ALLSTATIONS), but on the
3-rd char otherwise (after skb_pull). But, Patrick's patch
reserves the place for this, looking always at 1-st char
(buf[0]) independently of PPP_ALLSTATIONS char presence,
or otherwise - always treating this char as protocol char.
It looks safe because of PPP_ALLSTATION current value,
but isn't too understandable.

On the other hand, without any reservation in the
ppp_async_input for the (buf[0] == PPP_ALLSTATIONS) case,
probably 4-byte alignement isn't achieved as planned. 

>        } else {
>                if (skb->len < 2)
>                        goto err;
>                proto = (proto << 8) + p[1];
>                if (proto == PPP_LCP)
>                        async_lcp_peek(ap, p, skb->len, 1);
>        }
>
>        /* queue the frame to be processed */
>        skb->cb[0] = ap->state;
>        skb_queue_tail(&ap->rqueue, skb);
>        ap->rpkt = NULL;
>        ap->state = 0;
>        return;
>
> err:
>        /* frame had an error, remember that, reset SC_TOSS & SC_ESCAPE */
>        ap->state = SC_PREV_ERROR;
>        if (skb) {
>                /* make skb appear as freshly allocated */

Probably this isn't always true and here the problem
started...

>                skb_trim(skb, 0);
>                skb_reserve(skb, - skb_headroom(skb));

Isn't here lost e.g. NET_SKB_PAD probably reserved by
dev_alloc_skb?

On the other hand - this kind of pad can very good hide
similar reservation problems in many other places - maybe
it should be omitted or somehow counted in WARNs when some
debugging options are active?

Regards,
Jarek P.
