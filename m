From: Ilja <ilja@netric.org>
Subject: Re: [PATCH net-2.6] L2TP: Fix potential memory corruption in pppol2tp_recvmsg()
Date: Sun, 8 Jun 2008 16:08:00 +0200
Message-ID: <b849cb206c5e15963ceadaba327a8abd@81.240.198.135>
Reply-To: Ilja <ilja@netric.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7BIT
Cc: ilja@netric.org
To: James Chapman <james@quickie.katalix.com>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from [85.255.209.50] ([85.255.209.50]:50002 "EHLO mx1.xentra-is.nl"
	rhost-flags-FAIL-FAIL-OK-FAIL) by vger.kernel.org with ESMTP
	id S1753861AbYFHOax (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 8 Jun 2008 10:30:53 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

It would probably be a good idea to make skb_len an unsigned int iso signed
int. I don't think that it matters in this case, but better to be safe than
sorry. 

Regards,
Ilja van Sprundel.

--------- Oorspronkelijk bericht --------
Van: James Chapman <james@quickie.katalix.com>
Naar: netdev@vger.kernel.org <netdev@vger.kernel.org>
Cc: ilja@netric.org
Onderwerp: [PATCH net-2.6] L2TP: Fix potential memory corruption in
pppol2tp_recvmsg()
Datum: 08/06/08 18:01

> 
> This patch fixes a potential memory corruption in
> pppol2tp_recvmsg(). If skb-&gt;len is bigger than the caller's buffer
> length, memcpy_toiovec() will go into unintialized data on the kernel
> heap, interpret it as an iovec and start modifying memory.
> 
> The fix is to change the memcpy_toiovec() call to
> skb_copy_datagram_iovec() so that paged packets (rare for PPPOL2TP)
> are handled properly. Also check that the caller's buffer is big
> enough for the data and drop it if it isn't so.
> 
> Reported-by: Ilja &lt;ilja@netric.org&gt;
> Signed-off-by: James Chapman &lt;jchapman@katalix.com&gt;
> 
> --
> 
> A candidate for -stable?
> 
> Index: net-2.6/drivers/net/pppol2tp.c
> ===================================================================
> --- net-2.6.orig/drivers/net/pppol2tp.c
> +++ net-2.6/drivers/net/pppol2tp.c
> @@ -773,6 +773,7 @@ static int pppol2tp_recvmsg(struct kiocb
>  	int err;
>  	struct sk_buff *skb;
>  	struct sock *sk = sock-&gt;sk;
> +	int skb_len;
>  
>  	err = -EIO;
>  	if (sk-&gt;sk_state &amp; PPPOX_BOUND)
> @@ -783,14 +784,25 @@ static int pppol2tp_recvmsg(struct kiocb
>  	err = 0;
>  	skb = skb_recv_datagram(sk, flags &amp; ~MSG_DONTWAIT,
>  				flags &amp; MSG_DONTWAIT, &amp;err);
> -	if (skb) {
> -		err = memcpy_toiovec(msg-&gt;msg_iov, (unsigned char *) skb-&gt;data,
> -				     skb-&gt;len);
> -		if (err &lt; 0)
> -			goto do_skb_free;
> -		err = skb-&gt;len;
> -	}
> -do_skb_free:
> +	if (!skb)
> +		goto end;
> +
> +	skb_len = skb-&gt;len;
> +
> +	/* If caller did not provide a buffer big enough, drop the
> +	 * frame.  This path is used only for receiving PPP control
> +	 * frames (not user data) so PPP daemons should always use a
> +	 * buffer big enough for the largest expected control frame.
> +	 */
> +	err = -EMSGSIZE;
> +	if (unlikely(skb_len &gt; len))
> +		goto err_drop;
> +
> +	err = skb_copy_datagram_iovec(skb, 0, msg-&gt;msg_iov, skb_len);
> +	if (likely(err == 0))
> +		err = skb_len;
> +
> +err_drop:
>  	kfree_skb(skb);
>  end:
>  	return err;
> 


