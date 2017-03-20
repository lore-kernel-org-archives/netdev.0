From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net 1/1] net: tcp: Permit user set TCP_MAXSEG to default
 value
Date: Mon, 20 Mar 2017 15:45:47 -0700
Message-ID: <1490049947.16816.89.camel@edumazet-glaptop3.roam.corp.google.com>
References: <1490045417-32412-1-git-send-email-fgao@ikuai8.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, kuznet@ms2.inr.ac.ru, jmorris@namei.org,
        netdev@vger.kernel.org, gfree.wind@gmail.com
To: fgao@ikuai8.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f193.google.com ([209.85.192.193]:35902 "EHLO
        mail-pf0-f193.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1754058AbdCTWp7 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 20 Mar 2017 18:45:59 -0400
Received: by mail-pf0-f193.google.com with SMTP id r137so15468444pfr.3
        for <netdev@vger.kernel.org>; Mon, 20 Mar 2017 15:45:49 -0700 (PDT)
In-Reply-To: <1490045417-32412-1-git-send-email-fgao@ikuai8.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2017-03-21 at 05:30 +0800, fgao@ikuai8.com wrote:
> From: Gao Feng <fgao@ikuai8.com>
> 
> When user_mss is zero, it means use the default value. But the current
> codes don't permit user set TCP_MAXSEG to the default value.
> It would return the -EINVAL when val is zero.
> 
> Signed-off-by: Gao Feng <fgao@ikuai8.com>
> ---
>  net/ipv4/tcp.c | 3 ++-
>  1 file changed, 2 insertions(+), 1 deletion(-)
> 
> diff --git a/net/ipv4/tcp.c b/net/ipv4/tcp.c
> index 1e319a5..dd5e8e2 100644
> --- a/net/ipv4/tcp.c
> +++ b/net/ipv4/tcp.c
> @@ -2470,7 +2470,8 @@ static int do_tcp_setsockopt(struct sock *sk, int level,
>  		/* Values greater than interface MTU won't take effect. However
>  		 * at the point when this call is done we typically don't yet
>  		 * know which interface is going to be used */
> -		if (val < TCP_MIN_MSS || val > MAX_TCP_WINDOW) {
> +		if (val < 0 || (val > 0 && val < TCP_MIN_MSS) ||
> +		    val > MAX_TCP_WINDOW) {
>  			err = -EINVAL;
>  			break;
>  		}

This is a convoluted way to express that val == 0 is accepted ...

What about :

diff --git a/net/ipv4/tcp.c b/net/ipv4/tcp.c
index 1e319a525d51b0b603a5ccc5143381c752b9f2c7..7db78d72896ac7c4befba5966704ed18ecbac409 100644
--- a/net/ipv4/tcp.c
+++ b/net/ipv4/tcp.c
@@ -2469,8 +2469,9 @@ static int do_tcp_setsockopt(struct sock *sk, int level,
 	case TCP_MAXSEG:
 		/* Values greater than interface MTU won't take effect. However
 		 * at the point when this call is done we typically don't yet
-		 * know which interface is going to be used */
-		if (val < TCP_MIN_MSS || val > MAX_TCP_WINDOW) {
+		 * know which interface is going to be used.
+		 */
+		if (val && (val < TCP_MIN_MSS || val > MAX_TCP_WINDOW)) {
 			err = -EINVAL;
 			break;
 		}
