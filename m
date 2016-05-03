From: Tom Herbert <tom@herbertland.com>
Subject: Re: [PATCH net-next] gre: change gre_parse_header to return the
 header length
Date: Tue, 3 May 2016 08:18:38 -0700
Message-ID: <CALx6S35Du_8Eyau2+TrQ4z_+vngwwa6YGamxMJ=M0jqv5wpdbw@mail.gmail.com>
References: <3627136025fbd767d70e2ce563aa5e37373c880a.1462280197.git.jbenc@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Linux Kernel Network Developers <netdev@vger.kernel.org>,
	David Miller <davem@davemloft.net>
To: Jiri Benc <jbenc@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ig0-f170.google.com ([209.85.213.170]:34170 "EHLO
	mail-ig0-f170.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S933686AbcECPSo (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 3 May 2016 11:18:44 -0400
Received: by mail-ig0-f170.google.com with SMTP id u5so21625165igk.1
        for <netdev@vger.kernel.org>; Tue, 03 May 2016 08:18:39 -0700 (PDT)
In-Reply-To: <3627136025fbd767d70e2ce563aa5e37373c880a.1462280197.git.jbenc@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, May 3, 2016 at 6:00 AM, Jiri Benc <jbenc@redhat.com> wrote:
> It's easier for gre_parse_header to return the header length instead of
> filing it into a parameter. That way, the callers that don't care about the
> header length can just check whether the returned value is lower than zero.
>
> In gre_err, the tunnel header must not be pulled. See commit b7f8fe251e46
> ("gre: do not pull header in ICMP error processing") for details.
>
> This patch reduces the conflict between the mentioned commit and commit
> 95f5c64c3c13 ("gre: Move utility functions to common headers").
>
> Signed-off-by: Jiri Benc <jbenc@redhat.com>
> ---
> To resolve the conflict between net and net-next, please apply this patch to
> net-next and then pull net into net-next. At the conflicting places, take
> the hunks from net-next (including the large code removal at the beginning
> of ip_gre.c).
>
> The only exception is a call to gre_build_header/build_header in
> gre_fb_xmit; in there, also take the hunk from net-next but change
> "htons(ETH_P_TEB)" to "proto".
>
> Alternatively, this patch can be used during merge for the conflict
> resolution instead of committing it on its own.
> ---
>  include/net/gre.h    | 2 +-
>  net/ipv4/gre_demux.c | 6 +++---
>  net/ipv4/ip_gre.c    | 9 +++------
>  net/ipv6/ip6_gre.c   | 3 ++-
>  4 files changed, 9 insertions(+), 11 deletions(-)
>
> diff --git a/include/net/gre.h b/include/net/gre.h
> index 29e37322c06e..a14093c70eab 100644
> --- a/include/net/gre.h
> +++ b/include/net/gre.h
> @@ -26,7 +26,7 @@ int gre_del_protocol(const struct gre_protocol *proto, u8 version);
>  struct net_device *gretap_fb_dev_create(struct net *net, const char *name,
>                                        u8 name_assign_type);
>  int gre_parse_header(struct sk_buff *skb, struct tnl_ptk_info *tpi,
> -                    bool *csum_err, int *hdr_len);
> +                    bool *csum_err);
>
>  static inline int gre_calc_hlen(__be16 o_flags)
>  {
> diff --git a/net/ipv4/gre_demux.c b/net/ipv4/gre_demux.c
> index 371674801e84..a41e73ab1369 100644
> --- a/net/ipv4/gre_demux.c
> +++ b/net/ipv4/gre_demux.c
> @@ -60,8 +60,9 @@ int gre_del_protocol(const struct gre_protocol *proto, u8 version)
>  }
>  EXPORT_SYMBOL_GPL(gre_del_protocol);
>
> +/* Fills in tpi and returns header length to be pulled. */
>  int gre_parse_header(struct sk_buff *skb, struct tnl_ptk_info *tpi,
> -                    bool *csum_err, int *ret_hdr_len)
> +                    bool *csum_err)
>  {
>         const struct gre_base_hdr *greh;
>         __be32 *options;
> @@ -119,8 +120,7 @@ int gre_parse_header(struct sk_buff *skb, struct tnl_ptk_info *tpi,
>                                 return -EINVAL;
>                 }
>         }
> -       *ret_hdr_len = hdr_len;
> -       return 0;
> +       return hdr_len;
>  }
>  EXPORT_SYMBOL(gre_parse_header);
>
> diff --git a/net/ipv4/ip_gre.c b/net/ipv4/ip_gre.c
> index 2480d79b0e37..d4ee229880bf 100644
> --- a/net/ipv4/ip_gre.c
> +++ b/net/ipv4/ip_gre.c
> @@ -221,16 +221,12 @@ static void gre_err(struct sk_buff *skb, u32 info)
>         const int code = icmp_hdr(skb)->code;
>         struct tnl_ptk_info tpi;
>         bool csum_err = false;
> -       int hdr_len;
>
> -       if (gre_parse_header(skb, &tpi, &csum_err, &hdr_len)) {
> +       if (gre_parse_header(skb, &tpi, &csum_err) < 0) {
>                 if (!csum_err)          /* ignore csum errors. */
>                         return;
>         }
>
> -       if (iptunnel_pull_header(skb, hdr_len, tpi.proto, false))
> -               return;
> -
>         if (type == ICMP_DEST_UNREACH && code == ICMP_FRAG_NEEDED) {
>                 ipv4_update_pmtu(skb, dev_net(skb->dev), info,
>                                  skb->dev->ifindex, 0, IPPROTO_GRE, 0);
> @@ -314,7 +310,8 @@ static int gre_rcv(struct sk_buff *skb)
>         }
>  #endif
>
> -       if (gre_parse_header(skb, &tpi, &csum_err, &hdr_len) < 0)
> +       hdr_len = gre_parse_header(skb, &tpi, &csum_err);
> +       if (hdr_len < 0)
>                 goto drop;
>
>         if (iptunnel_pull_header(skb, hdr_len, tpi.proto, false))
> diff --git a/net/ipv6/ip6_gre.c b/net/ipv6/ip6_gre.c
> index 10127741a60d..47b671a46dc4 100644
> --- a/net/ipv6/ip6_gre.c
> +++ b/net/ipv6/ip6_gre.c
> @@ -468,7 +468,8 @@ static int gre_rcv(struct sk_buff *skb)
>         bool csum_err = false;
>         int hdr_len;
>
> -       if (gre_parse_header(skb, &tpi, &csum_err, &hdr_len) < 0)
> +       hdr_len = gre_parse_header(skb, &tpi, &csum_err);
> +       if (hdr_len < 0)
>                 goto drop;
>
>         if (iptunnel_pull_header(skb, hdr_len, tpi.proto, false))
> --
> 1.8.3.1
>
Acked-by: Tom Herbert <tom@herbertland.com>
