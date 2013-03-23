From: Pravin Shelar <pshelar@nicira.com>
Subject: Re: [PATCH net-next] ip_gre: increase inner ip header ID only for IPv4
Date: Sat, 23 Mar 2013 16:36:09 -0700
Message-ID: <CALnjE+qJ-BaGYEohfWB3-ZWaa9LwhFi5maR=yjP5_TD5N_jtog@mail.gmail.com>
References: <1364016584-7189-1-git-send-email-amwang@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: netdev@vger.kernel.org, Eric Dumazet <edumazet@google.com>,
	"David S. Miller" <davem@davemloft.net>
To: Cong Wang <amwang@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from na3sys009aog124.obsmtp.com ([74.125.149.151]:43958 "HELO
	na3sys009aog124.obsmtp.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with SMTP id S1752634Ab3CWXgL (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 23 Mar 2013 19:36:11 -0400
Received: by mail-qc0-f200.google.com with SMTP id j34so5775478qco.11
        for <netdev@vger.kernel.org>; Sat, 23 Mar 2013 16:36:09 -0700 (PDT)
In-Reply-To: <1364016584-7189-1-git-send-email-amwang@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Mar 22, 2013 at 10:29 PM, Cong Wang <amwang@redhat.com> wrote:
> From: Cong Wang <amwang@redhat.com>
>
> Pravin pointed out the inner network header of a GRE tunnel packet
> could be IPv6, where there is no ID. So we should check the version.
>

inet_gso_segment() already increment ip-header identification. What is
problem with that?


> Cc: Pravin B Shelar <pshelar@nicira.com>
> Cc: Eric Dumazet <edumazet@google.com>
> Cc: "David S. Miller" <davem@davemloft.net>
> Signed-off-by: Cong Wang <amwang@redhat.com>
>
> ---
> diff --git a/net/ipv4/gre.c b/net/ipv4/gre.c
> index e20631c..a2516f5 100644
> --- a/net/ipv4/gre.c
> +++ b/net/ipv4/gre.c
> @@ -128,7 +128,7 @@ static struct sk_buff *gre_gso_segment(struct sk_buff *skb,
>         struct iphdr *iph;
>         int mac_len = skb->mac_len;
>         int tnl_hlen, id;
> -       bool csum;
> +       bool csum, ipv4;
>
>         if (unlikely(skb_shinfo(skb)->gso_type &
>                                 ~(SKB_GSO_TCPV4 |
> @@ -172,7 +172,12 @@ static struct sk_buff *gre_gso_segment(struct sk_buff *skb,
>         skb->mac_len = skb_inner_network_offset(skb);
>
>         iph = ip_hdr(skb);
> -       id = ntohs(iph->id);
> +       if (iph->version == 4) {
> +               ipv4 = true;
> +               id = ntohs(iph->id);
> +       } else
> +               ipv4 = false;
> +
>         /* segment inner packet. */
>         enc_features = skb->dev->hw_enc_features & netif_skb_features(skb);
>         segs = skb_mac_gso_segment(skb, enc_features);
> @@ -182,8 +187,10 @@ static struct sk_buff *gre_gso_segment(struct sk_buff *skb,
>         skb = segs;
>         tnl_hlen = skb_tnl_header_len(skb);
>         do {
> -               iph = (struct iphdr *)skb->data;
> -               iph->id = htons(id++);
> +               if (ipv4) {
> +                       iph = (struct iphdr *)skb->data;
> +                       iph->id = htons(id++);
> +               }
>                 __skb_push(skb, ghl);
>                 if (csum) {
>                         __be32 *pcsum;
