From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: some TSO analysis
Date: Thu, 11 Nov 2004 18:20:22 +1100
Message-ID: <E1CS9Fm-0004hC-00@gondolin.me.apana.org.au>
References: <20041111050608.GG1922@krispykreme.ozlabs.ibm.com>
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: anton@samba.org (Anton Blanchard)
In-Reply-To: <20041111050608.GG1922@krispykreme.ozlabs.ibm.com>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Anton Blanchard <anton@samba.org> wrote:
> 
> Some web server benchmarking on recent 2.6 shows TSO not to be the gain
> it was in earlier kernels. I took a quick look at varying
> tcp_tso_win_divisor, below are the results. 

Thanks for doing the testing.  It's very interesting.
 
> I noticed a few things:
> 
> - In the normal copy case, it looks like we split the first page between
>  the skb->data and the first frag. eg:
> 
>  data: 1634 frags: 1408 4096 4096 4096 2108 4
> 
>  Is there a reason why the remaining 1408 bytes cant be stuffed into
>  skb->data? Or is that an issue with MTU sized buffers?

The reason is that the skb has to accomodate other things like
headers and skb_shared_info.  It seems to have added up to a
quite considerable value in your case.

Perhaps sendmsg should check whether the data can fit in the space
available in skb->data, and if not just go for a fragment right away.

> - TSO really doesnt come into play until we set tcp_tso_win_divisor to
>  2. BTW In this setup I am talking to a 2.4 machine on the same gigabit
>  switch. At 4 the normal copy case sees some gains, but interestingly
>  the zero copy does not.

This is understandable.  You really need to have a rcv window that's
much bigger than 64K to have any chance of filling up the TSO packet
with tcp_tso_win_divisor set to 8.

BTW, how did you measure the gains?

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
