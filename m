From: Paul Moore <paul@paul-moore.com>
Subject: Re: [RFC PATCH v3 17/19] calipso: Add validation of CALIPSO option.
Date: Fri, 6 May 2016 18:59:32 -0400
Message-ID: <CAHC9VhTRp8bHgwxZ2YNj=pa2a4PtO=8jJT1siG99GiFYnwm53Q@mail.gmail.com>
References: <1455715329-9601-18-git-send-email-huw@codeweavers.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: netdev@vger.kernel.org, linux-security-module@vger.kernel.org,
	selinux@tycho.nsa.gov, Paul Moore <pmoore@redhat.com>
To: Huw Davies <huw@codeweavers.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ob0-f180.google.com ([209.85.214.180]:34120 "EHLO
	mail-ob0-f180.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758643AbcEFW7d (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 6 May 2016 18:59:33 -0400
Received: by mail-ob0-f180.google.com with SMTP id dm5so58977355obc.1
        for <netdev@vger.kernel.org>; Fri, 06 May 2016 15:59:33 -0700 (PDT)
In-Reply-To: <1455715329-9601-18-git-send-email-huw@codeweavers.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Feb 17, 2016 at 8:22 AM, Huw Davies <huw@codeweavers.com> wrote:
> We check lengths, checksum and the DOI.  We leave checking of the
> level and categories for the socket layer.
>
> Signed-off-by: Huw Davies <huw@codeweavers.com>
> ---
>  include/net/calipso.h |  6 ++++++
>  net/ipv6/calipso.c    | 42 ++++++++++++++++++++++++++++++++++++++++++
>  net/ipv6/exthdrs.c    | 27 +++++++++++++++++++++++++++
>  3 files changed, 75 insertions(+)
>
> diff --git a/include/net/calipso.h b/include/net/calipso.h
> index 38dbb47..85404e2 100644
> --- a/include/net/calipso.h
> +++ b/include/net/calipso.h
> @@ -65,6 +65,7 @@ struct calipso_doi {
>  #ifdef CONFIG_NETLABEL
>  int __init calipso_init(void);
>  void calipso_exit(void);
> +bool calipso_validate(const struct sk_buff *skb, const unsigned char *option);
>  #else
>  static inline int __init calipso_init(void)
>  {
> @@ -74,6 +75,11 @@ static inline int __init calipso_init(void)
>  static inline void calipso_exit(void)
>  {
>  }
> +static inline bool calipso_validate(const struct sk_buff *skb,
> +                                   const unsigned char *option)
> +{
> +       return true;
> +}
>  #endif /* CONFIG_NETLABEL */
>
>  #endif /* _CALIPSO_H */
> diff --git a/net/ipv6/calipso.c b/net/ipv6/calipso.c
> index fa371a8..b8bcf9f 100644
> --- a/net/ipv6/calipso.c
> +++ b/net/ipv6/calipso.c
> @@ -321,6 +321,48 @@ doi_walk_return:
>  }
>
>  /**
> + * calipso_validate - Validate a CALIPSO option
> + * @skb: the packet
> + * @option: the start of the option
> + *
> + * Description:
> + * This routine is called to validate a CALIPSO option.
> + * If the option is valid then a zero value is returned.  If the
> + * option is invalid then a non-zero value is returned and
> + * representing the offset to the offending portion of the option.
> + *
> + * The caller should have already checked that the length of the
> + * option (including the TLV header) is >= 10 and that the catmap
> + * length is consistent with the option length.
> + *
> + * We leave checks on the level and categories to the socket layer.
> + */
> +bool calipso_validate(const struct sk_buff *skb, const unsigned char *option)
> +{
> +       struct calipso_doi *doi_def;
> +       int ret_val;
> +       u16 crc, len = option[1] + 2;
> +       static const u8 zero[2];
> +
> +       /* The original CRC runs over the option including the TLV header
> +        * with the CRC-16 field (at offset 8) zeroed out. */
> +       crc = crc_ccitt(0xffff, option, 8);
> +       crc = crc_ccitt(crc, zero, sizeof(zero));
> +       if (len > 10)
> +               crc = crc_ccitt(crc, option + 10, len - 10);
> +       crc = ~crc;

I should have caught this in the v2 patchset when I mentioned it with
respect to the CRC generation, but why not simply do 'crc =
~crc_cccitt(...);'?

Also, while I'm looking at this, why not do the CRC verification in
ipv6_hop_calipso()?  The only thing we should need to do here is the
DOI lookup/verification so that we still work correctly when
CONFIG_NETLABEL=n; all the core protocol stuff, e.g. length and
checksum validation, should be done in the core stack functions, e.g.
ipv6_hop_calipso().

> +       if (option[8] != (crc & 0xff) || option[9] != ((crc >> 8) & 0xff))
> +               return false;
> +
> +       rcu_read_lock();
> +       doi_def = calipso_doi_search(get_unaligned_be32(option + 2));
> +       ret_val = !!doi_def;
> +       rcu_read_unlock();
> +
> +       return ret_val;
> +}
> +
> +/**
>   * calipso_map_cat_hton - Perform a category mapping from host to network
>   * @doi_def: the DOI definition
>   * @secattr: the security attributes
> diff --git a/net/ipv6/exthdrs.c b/net/ipv6/exthdrs.c
> index d5fd3e7..0f69cab 100644
> --- a/net/ipv6/exthdrs.c
> +++ b/net/ipv6/exthdrs.c
> @@ -43,6 +43,7 @@
>  #include <net/ndisc.h>
>  #include <net/ip6_route.h>
>  #include <net/addrconf.h>
> +#include <net/calipso.h>
>  #if IS_ENABLED(CONFIG_IPV6_MIP6)
>  #include <net/xfrm.h>
>  #endif
> @@ -603,6 +604,28 @@ drop:
>         return false;
>  }
>
> +/* CALIPSO RFC 5570 */
> +
> +static bool ipv6_hop_calipso(struct sk_buff *skb, int optoff)
> +{
> +       const unsigned char *nh = skb_network_header(skb);
> +
> +       if (nh[optoff + 1] < 8)
> +               goto drop;
> +
> +       if (nh[optoff + 6] * 4 + 8 > nh[optoff + 1])
> +               goto drop;
> +
> +       if (!calipso_validate(skb, nh + optoff))
> +               goto drop;
> +
> +       return true;
> +
> +drop:
> +       kfree_skb(skb);
> +       return false;
> +}
> +
>  static const struct tlvtype_proc tlvprochopopt_lst[] = {
>         {
>                 .type   = IPV6_TLV_ROUTERALERT,
> @@ -612,6 +635,10 @@ static const struct tlvtype_proc tlvprochopopt_lst[] = {
>                 .type   = IPV6_TLV_JUMBO,
>                 .func   = ipv6_hop_jumbo,
>         },
> +       {
> +               .type   = IPV6_TLV_CALIPSO,
> +               .func   = ipv6_hop_calipso,
> +       },
>         { -1, }
>  };
>
> --
> 2.7.0
>
> --
> To unsubscribe from this list: send the line "unsubscribe linux-security-module" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html

-- 
paul moore
www.paul-moore.com
