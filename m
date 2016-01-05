From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net-next] soreuseport: change consume_skb to kfree_skb
 in error case
Date: Tue, 05 Jan 2016 09:38:36 -0800
Message-ID: <1452015516.8255.106.camel@edumazet-glaptop2.roam.corp.google.com>
References: <1452009433-22171-1-git-send-email-kraigatgoog@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, David Miller <davem@davemloft.net>
To: Craig Gallek <kraigatgoog@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f176.google.com ([209.85.192.176]:35341 "EHLO
	mail-pf0-f176.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751792AbcAERij (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 5 Jan 2016 12:38:39 -0500
Received: by mail-pf0-f176.google.com with SMTP id 78so226148198pfw.2
        for <netdev@vger.kernel.org>; Tue, 05 Jan 2016 09:38:39 -0800 (PST)
In-Reply-To: <1452009433-22171-1-git-send-email-kraigatgoog@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2016-01-05 at 10:57 -0500, Craig Gallek wrote:
> From: Craig Gallek <kraig@google.com>
> 
> Fixes: 538950a1b752 ("soreuseport: setsockopt SO_ATTACH_REUSEPORT_[CE]BPF")
> Suggested-by: Daniel Borkmann <daniel@iogearbox.net>
> Signed-off-by: Craig Gallek <kraig@google.com>
> ---
>  net/core/sock_reuseport.c | 2 +-
>  1 file changed, 1 insertion(+), 1 deletion(-)
> 
> diff --git a/net/core/sock_reuseport.c b/net/core/sock_reuseport.c
> index ae0969c0fc2e..1df98c557440 100644
> --- a/net/core/sock_reuseport.c
> +++ b/net/core/sock_reuseport.c
> @@ -173,7 +173,7 @@ static struct sock *run_bpf(struct sock_reuseport *reuse, u16 socks,
>  
>  	/* temporarily advance data past protocol header */
>  	if (!pskb_pull(skb, hdr_len)) {
> -		consume_skb(nskb);
> +		kfree_skb(nskb);
>  		return NULL;
>  	}
>  	index = bpf_prog_run_save_cb(prog, skb);

Note that we always call reuseport_select_sock() after pulling the
headers in skb->head anyway, so the pskb_pull() can never fail.

It really could be __skb_pull()

BTW, why UDP calls reuseport_select_sock() with hdr_len == 0 sometimes ?

I believe the following patch is needed.

diff --git a/net/ipv4/udp.c b/net/ipv4/udp.c
index 835378365f25..52387096dbba 100644
--- a/net/ipv4/udp.c
+++ b/net/ipv4/udp.c
@@ -514,7 +514,8 @@ begin:
 				struct sock *sk2;
 				hash = udp_ehashfn(net, daddr, hnum,
 						   saddr, sport);
-				sk2 = reuseport_select_sock(sk, hash, NULL, 0);
+				sk2 = reuseport_select_sock(sk, hash, NULL,
+							    sizeof(struct udphdr));
 				if (sk2) {
 					result = sk2;
 					goto found;
diff --git a/net/ipv6/udp.c b/net/ipv6/udp.c
index 56fcb55fda31..da0a5fa02b0f 100644
--- a/net/ipv6/udp.c
+++ b/net/ipv6/udp.c
@@ -272,7 +272,8 @@ begin:
 				struct sock *sk2;
 				hash = udp6_ehashfn(net, daddr, hnum,
 						    saddr, sport);
-				sk2 = reuseport_select_sock(sk, hash, NULL, 0);
+				sk2 = reuseport_select_sock(sk, hash, NULL,
+							    sizeof(struct udphdr));
 				if (sk2) {
 					result = sk2;
 					goto found;
