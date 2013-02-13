From: Sedat Dilek <sedat.dilek@gmail.com>
Subject: Re: [PATCH -next 1/1] net: skbuff: fix compile error in skb_panic()
Date: Wed, 13 Feb 2013 13:41:21 +0100
Message-ID: <CA+icZUVB9QaZfnKGSz_Dr=EADBtYULOHqEHDDocdXO5-Dy=uYA@mail.gmail.com>
References: <1360754427-9051-1-git-send-email-james.hogan@imgtec.com>
Reply-To: sedat.dilek@gmail.com
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Jean Sacren <sakiwit@gmail.com>,
	"David S. Miller" <davem@davemloft.net>,
	linux-kernel@vger.kernel.org, linux-next@vger.kernel.org,
	Jiri Pirko <jiri@resnulli.us>, netdev@vger.kernel.org
To: James Hogan <james.hogan@imgtec.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f171.google.com ([209.85.212.171]:62390 "EHLO
	mail-wi0-f171.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S933983Ab3BMMl2 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 13 Feb 2013 07:41:28 -0500
In-Reply-To: <1360754427-9051-1-git-send-email-james.hogan@imgtec.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Feb 13, 2013 at 12:20 PM, James Hogan <james.hogan@imgtec.com> wrote:
> I get the following build error on next-20130213 due to the following
> commit:
>
> commit f05de73bf82fbbc00265c06d12efb7273f7dc54a ("skbuff: create
> skb_panic() function and its wrappers").
>
> It adds an argument called panic to a function that uses the BUG() macro
> which tries to call panic, but the argument masks the panic() function
> declaration, resulting in the following error (gcc 4.2.4):
>
> net/core/skbuff.c In function 'skb_panic':
> net/core/skbuff.c +126 : error: called object 'panic' is not a function
>

[ CC linux-netdev ]

Hmm, with gcc-4.6.3 on Ubuntu/precise I don't see this... compiler-specific?

$ grep skbuff build-log_3.8.0-rc7-next20130213-2-iniza-small.txt
  CC      net/core/skbuff.o

- Sedat -


> This is fixed by renaming the argument to msg.
>
> Signed-off-by: James Hogan <james.hogan@imgtec.com>
> Cc: Jean Sacren <sakiwit@gmail.com>
> Cc: Jiri Pirko <jiri@resnulli.us>
> Cc: David S. Miller <davem@davemloft.net>
> ---
>
> Feel free to rename panic to something else or squash this into the
> offending commit.
>
>  net/core/skbuff.c | 6 +++---
>  1 file changed, 3 insertions(+), 3 deletions(-)
>
> diff --git a/net/core/skbuff.c b/net/core/skbuff.c
> index 8731c39..21a22cc 100644
> --- a/net/core/skbuff.c
> +++ b/net/core/skbuff.c
> @@ -109,7 +109,7 @@ static const struct pipe_buf_operations sock_pipe_buf_ops = {
>   *     @skb:   buffer
>   *     @sz:    size
>   *     @addr:  address
> - *     @panic: skb_over_panic or skb_under_panic
> + *     @msg:   skb_over_panic or skb_under_panic
>   *
>   *     Out-of-line support for skb_put() and skb_push().
>   *     Called via the wrapper skb_over_panic() or skb_under_panic().
> @@ -117,10 +117,10 @@ static const struct pipe_buf_operations sock_pipe_buf_ops = {
>   *     __builtin_return_address is not used because it is not always reliable.
>   */
>  static void skb_panic(struct sk_buff *skb, unsigned int sz, void *addr,
> -                     const char panic[])
> +                     const char msg[])
>  {
>         pr_emerg("%s: text:%p len:%d put:%d head:%p data:%p tail:%#lx end:%#lx dev:%s\n",
> -                panic, addr, skb->len, sz, skb->head, skb->data,
> +                msg, addr, skb->len, sz, skb->head, skb->data,
>                  (unsigned long)skb->tail, (unsigned long)skb->end,
>                  skb->dev ? skb->dev->name : "<NULL>");
>         BUG();
> --
> 1.8.1.2
>
>
> --
> To unsubscribe from this list: send the line "unsubscribe linux-next" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
