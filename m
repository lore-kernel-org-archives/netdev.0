From: Daniel Borkmann <daniel@iogearbox.net>
Subject: Re: [PATCH] net-scm: Delete an unnecessary check before the function
 call "kfree"
Date: Tue, 17 Nov 2015 18:13:19 +0100
Message-ID: <564B602F.2020302@iogearbox.net>
References: <5307CAA2.8060406@users.sourceforge.net> <alpine.DEB.2.02.1402212321410.2043@localhost6.localdomain6> <530A086E.8010901@users.sourceforge.net> <alpine.DEB.2.02.1402231635510.1985@localhost6.localdomain6> <530A72AA.3000601@users.sourceforge.net> <alpine.DEB.2.02.1402240658210.2090@localhost6.localdomain6> <530B5FB6.6010207@users.sourceforge.net> <alpine.DEB.2.10.1402241710370.2074@hadrien> <530C5E18.1020800@users.sourceforge.net> <alpine.DEB.2.10.1402251014170.2080@hadrien> <530CD2C4.4050903@users.sourceforge.net> <alpine.DEB.2.10.1402251840450.7035@hadrien> <530CF8FF.8080600@users.sourceforge.net> <alpine.DEB.2.02.1402252117150.2047@localhost6.localdomain6> <530DD06F.4090703@users.sourceforge.net> <alpine.DEB.2.02.1402262129250.2221@localhost6.localdomain6> <5317A59D.4@users.so
 urceforge.net> <564B5937.1070707@users.sourceforge.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, kernel-janitors@vger.kernel.org,
	Julia Lawall <julia.lawall@lip6.fr>, eric.dumazet@gmail.com
To: SF Markus Elfring <elfring@users.sourceforge.net>,
	netdev@vger.kernel.org, "David S. Miller" <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <564B5937.1070707@users.sourceforge.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 11/17/2015 05:43 PM, SF Markus Elfring wrote:
> From: Markus Elfring <elfring@users.sourceforge.net>
> Date: Tue, 17 Nov 2015 17:37:22 +0100
>
> The kfree() function tests whether its argument is NULL and then
> returns immediately. Thus the test around the call is not needed.
>
> This issue was detected by using the Coccinelle software.
>
> Signed-off-by: Markus Elfring <elfring@users.sourceforge.net>
> ---
>   net/core/scm.c | 2 +-
>   1 file changed, 1 insertion(+), 1 deletion(-)
>
> diff --git a/net/core/scm.c b/net/core/scm.c
> index 3b6899b..4f64173 100644
> --- a/net/core/scm.c
> +++ b/net/core/scm.c
> @@ -193,7 +193,7 @@ int __scm_send(struct socket *sock, struct msghdr *msg, struct scm_cookie *p)
>   		}
>   	}
>
> -	if (p->fp && !p->fp->count)
> +	if (likely(!p->fp->count))
>   	{
>   		kfree(p->fp);
>   		p->fp = NULL;
>

Really, I don't like your blind, silly removals everywhere throughout
the kernel tree for these tests. Eric already mentioned that in some
situations where it's critical, it actually slows down the code, i.e.
you'll have an extra function call to get there and inside kfree() /
kfree_skb() / etc, the test is actually marked as unlikely().

Anyway, I think this one in particular could throw a NULL pointer deref.
You even say in your commit message "kfree() function tests whether its
argument [p->fp] is NULL" and yet if that is the case then, you already
deref'ed on the p->fp->count test ???
