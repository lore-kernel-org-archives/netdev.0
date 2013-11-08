From: Alexei Starovoitov <ast@plumgrid.com>
Subject: Re: [PATCH net-next] inet: fix a UFO regression
Date: Thu, 7 Nov 2013 17:39:38 -0800
Message-ID: <CAMEtUuynjTj_eteupaSx1hbZs4OyVtc=fDZAwAFSL24qK8tFLA@mail.gmail.com>
References: <CAMEtUuzswOVA6UkPRjS-O=gOe9BLLJ5qaAG_eAd_fTqDJo8ofA@mail.gmail.com>
	<1382674000.7572.75.camel@edumazet-glaptop.roam.corp.google.com>
	<1382692140.7572.79.camel@edumazet-glaptop.roam.corp.google.com>
	<20131025.181809.348808013109842304.davem@davemloft.net>
	<CAMEtUuxwi05oX0TqNdMbjy04MT=ZLemLXJQTTcAMrnWuhXLKdQ@mail.gmail.com>
	<1382923096.13037.10.camel@edumazet-glaptop.roam.corp.google.com>
	<1383863586.9412.101.camel@edumazet-glaptop2.roam.corp.google.com>
	<CAMEtUuwqmUhTgeKyodGKmOxhxe23=umnfc7nouhdVrqVNnk6zQ@mail.gmail.com>
	<1383871465.9412.118.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
	Hannes Frederic Sowa <hannes@stressinduktion.org>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f173.google.com ([209.85.212.173]:62889 "EHLO
	mail-wi0-f173.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753320Ab3KHBjj (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 7 Nov 2013 20:39:39 -0500
Received: by mail-wi0-f173.google.com with SMTP id ey11so1504434wid.12
        for <netdev@vger.kernel.org>; Thu, 07 Nov 2013 17:39:38 -0800 (PST)
In-Reply-To: <1383871465.9412.118.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Nov 7, 2013 at 4:44 PM, Eric Dumazet <eric.dumazet@gmail.com> wrote:
> From: Eric Dumazet <edumazet@google.com>
>
> While testing virtio_net and skb_segment() changes, Hannes reported
> that UFO was sending wrong frames.
>
> It appears this was introduced by a recent commit :
> 8c3a897bfab1 ("inet: restore gso for vxlan")
>
> The old condition to perform IP frag was :
>
> tunnel = !!skb->encapsulation;
> ...
>         if (!tunnel && proto == IPPROTO_UDP) {
>
> So the new one should be :
>
> udpfrag = !skb->encapsulation && proto == IPPROTO_UDP;
> ...
>         if (udpfrag) {
>
> With help from Alexei Starovoitov
>
> Reported-by: Hannes Frederic Sowa <hannes@stressinduktion.org>
> Signed-off-by: Eric Dumazet <edumazet@google.com>
> Cc: Alexei Starovoitov <ast@plumgrid.com>
> ---
>  net/ipv4/af_inet.c |    2 +-
>  1 file changed, 1 insertion(+), 1 deletion(-)
>
> diff --git a/net/ipv4/af_inet.c b/net/ipv4/af_inet.c
> index 09d78d4a3cff..f17941486ab9 100644
> --- a/net/ipv4/af_inet.c
> +++ b/net/ipv4/af_inet.c
> @@ -1306,7 +1306,7 @@ static struct sk_buff *inet_gso_segment(struct sk_buff *skb,
>         if (IS_ERR_OR_NULL(segs))
>                 goto out;
>
> -       udpfrag = !!skb->encapsulation && proto == IPPROTO_UDP;
> +       udpfrag = !skb->encapsulation && proto == IPPROTO_UDP;

as we discussed this will break vxlan :)
Please move udpfrag assignment before line:
                segs = ops->callbacks.gso_segment(skb, features);
since skb_udp_tunnel_segment() does skb->encapsulation = 0
then both ufo and vxlan should be fine

Thanks
Alexei
