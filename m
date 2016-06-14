From: Vidya Chowdary <vidya.chowdary@gmail.com>
Subject: Re: [ethtool PATCH v7 1/2] ethtool.c: add support for
 ETHTOOL_xLINKSETTINGS ioctls
Date: Mon, 13 Jun 2016 20:40:26 -0700
Message-ID: <CACd6PL3aKJpRWKvkwsSQafPBmcT9S-TN=hHSfKSV2_+EjumH4w@mail.gmail.com>
References: <1465520144-132788-1-git-send-email-ddecotig@gmail.com> <1465520144-132788-2-git-send-email-ddecotig@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: netdev@vger.kernel.org, Jeff Garzik <jgarzik@pobox.com>,
	Ben Hutchings <ben@decadent.org.uk>,
	David Miller <davem@redhat.com>,
	Vidya Sagar Ravipati <vidya@cumulusnetworks.com>,
	Joe Perches <joe@perches.com>,
	David Decotigny <decot@googlers.com>
To: David Decotigny <ddecotig@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-vk0-f68.google.com ([209.85.213.68]:36533 "EHLO
	mail-vk0-f68.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932797AbcFNDk3 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 13 Jun 2016 23:40:29 -0400
Received: by mail-vk0-f68.google.com with SMTP id v188so13964706vkf.3
        for <netdev@vger.kernel.org>; Mon, 13 Jun 2016 20:40:28 -0700 (PDT)
In-Reply-To: <1465520144-132788-2-git-send-email-ddecotig@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Acked-by:Vidya Sagar Ravipati <vidya@cumulusnetworks.com>

Validated this patch with various modules.

On Thu, Jun 9, 2016 at 5:55 PM, David Decotigny <ddecotig@gmail.com> wrote:
> From: David Decotigny <decot@googlers.com>
>
> More info with kernel commit 8d3f2806f8fb ("Merge branch
> 'ethtool-ksettings'").
>
> Note: The new features implemented in this patch depend on kernel
> commit 793cf87de9d1 ("Set cmd field in ETHTOOL_GLINKSETTINGS response to
> wrong nwords").
>
>
> Signed-off-by: David Decotigny <decot@googlers.com>
> ---
>  ethtool.c      | 681 ++++++++++++++++++++++++++++++++++++++++++++-------------
>  internal.h     |  67 ++++++
>  test-cmdline.c |  13 ++
>  3 files changed, 603 insertions(+), 158 deletions(-)
>
> diff --git a/ethtool.c b/ethtool.c
> index 0cd0d4f..cb3d971 100644
> --- a/ethtool.c
> +++ b/ethtool.c
> @@ -47,42 +47,6 @@
>  #define MAX_ADDR_LEN   32
>  #endif
>
> -#define ALL_ADVERTISED_MODES                   \
> -       (ADVERTISED_10baseT_Half |              \
> -        ADVERTISED_10baseT_Full |              \
> -        ADVERTISED_100baseT_Half |             \
> -        ADVERTISED_100baseT_Full |             \
> -        ADVERTISED_1000baseT_Half |            \
> -        ADVERTISED_1000baseT_Full |            \
> -        ADVERTISED_1000baseKX_Full|            \
> -        ADVERTISED_2500baseX_Full |            \
> -        ADVERTISED_10000baseT_Full |           \
> -        ADVERTISED_10000baseKX4_Full |         \
> -        ADVERTISED_10000baseKR_Full |          \
> -        ADVERTISED_10000baseR_FEC |            \
> -        ADVERTISED_20000baseMLD2_Full |        \
> -        ADVERTISED_20000baseKR2_Full |         \
> -        ADVERTISED_40000baseKR4_Full |         \
> -        ADVERTISED_40000baseCR4_Full |         \
> -        ADVERTISED_40000baseSR4_Full |         \
> -        ADVERTISED_40000baseLR4_Full |         \
> -        ADVERTISED_56000baseKR4_Full |         \
> -        ADVERTISED_56000baseCR4_Full |         \
> -        ADVERTISED_56000baseSR4_Full |         \
> -        ADVERTISED_56000baseLR4_Full)
> -
> -#define ALL_ADVERTISED_FLAGS                   \
> -       (ADVERTISED_Autoneg |                   \
> -        ADVERTISED_TP |                        \
> -        ADVERTISED_AUI |                       \
> -        ADVERTISED_MII |                       \
> -        ADVERTISED_FIBRE |                     \
> -        ADVERTISED_BNC |                       \
> -        ADVERTISED_Pause |                     \
> -        ADVERTISED_Asym_Pause |                \
> -        ADVERTISED_Backplane |                 \
> -        ALL_ADVERTISED_MODES)
> -
>  #ifndef HAVE_NETIF_MSG
>  enum {
>         NETIF_MSG_DRV           = 0x0001,
> @@ -293,6 +257,43 @@ static void get_mac_addr(char *src, unsigned char *dest)
>         }
>  }
>
> +static int parse_hex_u32_bitmap(const char *s,
> +                               unsigned int nbits, u32 *result)
> +{
> +       const unsigned int nwords = __KERNEL_DIV_ROUND_UP(nbits, 32);
> +       size_t slen = strlen(s);
> +       size_t i;
> +
> +       /* ignore optional '0x' prefix */
> +       if ((slen > 2) && (strncasecmp(s, "0x", 2) == 0)) {
> +               slen -= 2;
> +               s += 2;
> +       }
> +
> +       if (slen > 8 * nwords)  /* up to 2 digits per byte */
> +               return -1;
> +
> +       memset(result, 0, 4 * nwords);
> +       for (i = 0 ; i < slen ; ++i) {
> +               const unsigned int shift = (slen - 1 - i) * 4;
> +               u32 *dest = &result[shift / 32];
> +               u32 nibble;
> +
> +               if ('a' <= s[i] && s[i] <= 'f')
> +                       nibble = 0xa + (s[i] - 'a');
> +               else if ('A' <= s[i] && s[i] <= 'F')
> +                       nibble = 0xa + (s[i] - 'A');
> +               else if ('0' <= s[i] && s[i] <= '9')
> +                       nibble = (s[i] - '0');
> +               else
> +                       return -1;
> +
> +               *dest |= (nibble << (shift % 32));
> +       }
> +
> +       return 0;
> +}
> +
>  static void parse_generic_cmdline(struct cmd_context *ctx,
>                                   int *changed,
>                                   struct cmdline_info *info,
> @@ -472,64 +473,157 @@ static int do_version(struct cmd_context *ctx)
>         return 0;
>  }
>
> -static void dump_link_caps(const char *prefix, const char *an_prefix, u32 mask,
> -                          int link_mode_only);
> +/* link mode routines */
>
> -static void dump_supported(struct ethtool_cmd *ep)
> +static __ETHTOOL_DECLARE_LINK_MODE_MASK(all_advertised_modes);
> +static __ETHTOOL_DECLARE_LINK_MODE_MASK(all_advertised_flags);
> +
> +static void init_global_link_mode_masks(void)
>  {
> -       u32 mask = ep->supported;
> +       static const enum ethtool_link_mode_bit_indices
> +               all_advertised_modes_bits[] = {
> +               ETHTOOL_LINK_MODE_10baseT_Half_BIT,
> +               ETHTOOL_LINK_MODE_10baseT_Full_BIT,
> +               ETHTOOL_LINK_MODE_100baseT_Half_BIT,
> +               ETHTOOL_LINK_MODE_100baseT_Full_BIT,
> +               ETHTOOL_LINK_MODE_1000baseT_Half_BIT,
> +               ETHTOOL_LINK_MODE_1000baseT_Full_BIT,
> +               ETHTOOL_LINK_MODE_1000baseKX_Full_BIT,
> +               ETHTOOL_LINK_MODE_2500baseX_Full_BIT,
> +               ETHTOOL_LINK_MODE_10000baseT_Full_BIT,
> +               ETHTOOL_LINK_MODE_10000baseKX4_Full_BIT,
> +               ETHTOOL_LINK_MODE_10000baseKR_Full_BIT,
> +               ETHTOOL_LINK_MODE_10000baseR_FEC_BIT,
> +               ETHTOOL_LINK_MODE_20000baseMLD2_Full_BIT,
> +               ETHTOOL_LINK_MODE_20000baseKR2_Full_BIT,
> +               ETHTOOL_LINK_MODE_40000baseKR4_Full_BIT,
> +               ETHTOOL_LINK_MODE_40000baseCR4_Full_BIT,
> +               ETHTOOL_LINK_MODE_40000baseSR4_Full_BIT,
> +               ETHTOOL_LINK_MODE_40000baseLR4_Full_BIT,
> +               ETHTOOL_LINK_MODE_56000baseKR4_Full_BIT,
> +               ETHTOOL_LINK_MODE_56000baseCR4_Full_BIT,
> +               ETHTOOL_LINK_MODE_56000baseSR4_Full_BIT,
> +               ETHTOOL_LINK_MODE_56000baseLR4_Full_BIT,
> +       };
> +       static const enum ethtool_link_mode_bit_indices
> +               additional_advertised_flags_bits[] = {
> +               ETHTOOL_LINK_MODE_Autoneg_BIT,
> +               ETHTOOL_LINK_MODE_TP_BIT,
> +               ETHTOOL_LINK_MODE_AUI_BIT,
> +               ETHTOOL_LINK_MODE_MII_BIT,
> +               ETHTOOL_LINK_MODE_FIBRE_BIT,
> +               ETHTOOL_LINK_MODE_BNC_BIT,
> +               ETHTOOL_LINK_MODE_Pause_BIT,
> +               ETHTOOL_LINK_MODE_Asym_Pause_BIT,
> +               ETHTOOL_LINK_MODE_Backplane_BIT,
> +       };
> +       unsigned int i;
>
> +       ethtool_link_mode_zero(all_advertised_modes);
> +       ethtool_link_mode_zero(all_advertised_flags);
> +       for (i = 0 ; i < ARRAY_SIZE(all_advertised_modes_bits) ; ++i) {
> +               ethtool_link_mode_set_bit(all_advertised_modes_bits[i],
> +                                         all_advertised_modes);
> +               ethtool_link_mode_set_bit(all_advertised_modes_bits[i],
> +                                         all_advertised_flags);
> +       }
> +
> +       for (i = 0 ; i < ARRAY_SIZE(additional_advertised_flags_bits) ; ++i) {
> +               ethtool_link_mode_set_bit(
> +                       additional_advertised_flags_bits[i],
> +                       all_advertised_flags);
> +       }
> +}
> +
> +static void dump_link_caps(const char *prefix, const char *an_prefix,
> +                          const u32 *mask, int link_mode_only);
> +
> +static void dump_supported(const struct ethtool_link_usettings *link_usettings)
> +{
>         fprintf(stdout, "       Supported ports: [ ");
> -       if (mask & SUPPORTED_TP)
> +       if (ethtool_link_mode_test_bit(
> +                   ETHTOOL_LINK_MODE_TP_BIT,
> +                   link_usettings->link_modes.supported))
>                 fprintf(stdout, "TP ");
> -       if (mask & SUPPORTED_AUI)
> +       if (ethtool_link_mode_test_bit(
> +                   ETHTOOL_LINK_MODE_AUI_BIT,
> +                   link_usettings->link_modes.supported))
>                 fprintf(stdout, "AUI ");
> -       if (mask & SUPPORTED_BNC)
> +       if (ethtool_link_mode_test_bit(
> +                   ETHTOOL_LINK_MODE_BNC_BIT,
> +                   link_usettings->link_modes.supported))
>                 fprintf(stdout, "BNC ");
> -       if (mask & SUPPORTED_MII)
> +       if (ethtool_link_mode_test_bit(
> +                   ETHTOOL_LINK_MODE_MII_BIT,
> +                   link_usettings->link_modes.supported))
>                 fprintf(stdout, "MII ");
> -       if (mask & SUPPORTED_FIBRE)
> +       if (ethtool_link_mode_test_bit(
> +                   ETHTOOL_LINK_MODE_FIBRE_BIT,
> +                   link_usettings->link_modes.supported))
>                 fprintf(stdout, "FIBRE ");
> -       if (mask & SUPPORTED_Backplane)
> +       if (ethtool_link_mode_test_bit(
> +                   ETHTOOL_LINK_MODE_Backplane_BIT,
> +                   link_usettings->link_modes.supported))
>                 fprintf(stdout, "Backplane ");
>         fprintf(stdout, "]\n");
>
> -       dump_link_caps("Supported", "Supports", mask, 0);
> +       dump_link_caps("Supported", "Supports",
> +                      link_usettings->link_modes.supported, 0);
>  }
>
>  /* Print link capability flags (supported, advertised or lp_advertised).
>   * Assumes that the corresponding SUPPORTED and ADVERTISED flags are equal.
>   */
> -static void
> -dump_link_caps(const char *prefix, const char *an_prefix, u32 mask,
> -              int link_mode_only)
> +static void dump_link_caps(const char *prefix, const char *an_prefix,
> +                          const u32 *mask, int link_mode_only)
>  {
>         static const struct {
>                 int same_line; /* print on same line as previous */
> -               u32 value;
> +               unsigned int bit_index;
>                 const char *name;
>         } mode_defs[] = {
> -               { 0, ADVERTISED_10baseT_Half,       "10baseT/Half" },
> -               { 1, ADVERTISED_10baseT_Full,       "10baseT/Full" },
> -               { 0, ADVERTISED_100baseT_Half,      "100baseT/Half" },
> -               { 1, ADVERTISED_100baseT_Full,      "100baseT/Full" },
> -               { 0, ADVERTISED_1000baseT_Half,     "1000baseT/Half" },
> -               { 1, ADVERTISED_1000baseT_Full,     "1000baseT/Full" },
> -               { 0, ADVERTISED_1000baseKX_Full,    "1000baseKX/Full" },
> -               { 0, ADVERTISED_2500baseX_Full,     "2500baseX/Full" },
> -               { 0, ADVERTISED_10000baseT_Full,    "10000baseT/Full" },
> -               { 0, ADVERTISED_10000baseKX4_Full,  "10000baseKX4/Full" },
> -               { 0, ADVERTISED_10000baseKR_Full,   "10000baseKR/Full" },
> -               { 0, ADVERTISED_20000baseMLD2_Full, "20000baseMLD2/Full" },
> -               { 0, ADVERTISED_20000baseKR2_Full,  "20000baseKR2/Full" },
> -               { 0, ADVERTISED_40000baseKR4_Full,  "40000baseKR4/Full" },
> -               { 0, ADVERTISED_40000baseCR4_Full,  "40000baseCR4/Full" },
> -               { 0, ADVERTISED_40000baseSR4_Full,  "40000baseSR4/Full" },
> -               { 0, ADVERTISED_40000baseLR4_Full,  "40000baseLR4/Full" },
> -               { 0, ADVERTISED_56000baseKR4_Full,  "56000baseKR4/Full" },
> -               { 0, ADVERTISED_56000baseCR4_Full,  "56000baseCR4/Full" },
> -               { 0, ADVERTISED_56000baseSR4_Full,  "56000baseSR4/Full" },
> -               { 0, ADVERTISED_56000baseLR4_Full,  "56000baseLR4/Full" },
> +               { 0, ETHTOOL_LINK_MODE_10baseT_Half_BIT,
> +                 "10baseT/Half" },
> +               { 1, ETHTOOL_LINK_MODE_10baseT_Full_BIT,
> +                 "10baseT/Full" },
> +               { 0, ETHTOOL_LINK_MODE_100baseT_Half_BIT,
> +                 "100baseT/Half" },
> +               { 1, ETHTOOL_LINK_MODE_100baseT_Full_BIT,
> +                 "100baseT/Full" },
> +               { 0, ETHTOOL_LINK_MODE_1000baseT_Half_BIT,
> +                 "1000baseT/Half" },
> +               { 1, ETHTOOL_LINK_MODE_1000baseT_Full_BIT,
> +                 "1000baseT/Full" },
> +               { 0, ETHTOOL_LINK_MODE_1000baseKX_Full_BIT,
> +                 "1000baseKX/Full" },
> +               { 0, ETHTOOL_LINK_MODE_2500baseX_Full_BIT,
> +                 "2500baseX/Full" },
> +               { 0, ETHTOOL_LINK_MODE_10000baseT_Full_BIT,
> +                 "10000baseT/Full" },
> +               { 0, ETHTOOL_LINK_MODE_10000baseKX4_Full_BIT,
> +                 "10000baseKX4/Full" },
> +               { 0, ETHTOOL_LINK_MODE_10000baseKR_Full_BIT,
> +                 "10000baseKR/Full" },
> +               { 0, ETHTOOL_LINK_MODE_20000baseMLD2_Full_BIT,
> +                 "20000baseMLD2/Full" },
> +               { 0, ETHTOOL_LINK_MODE_20000baseKR2_Full_BIT,
> +                 "20000baseKR2/Full" },
> +               { 0, ETHTOOL_LINK_MODE_40000baseKR4_Full_BIT,
> +                 "40000baseKR4/Full" },
> +               { 0, ETHTOOL_LINK_MODE_40000baseCR4_Full_BIT,
> +                 "40000baseCR4/Full" },
> +               { 0, ETHTOOL_LINK_MODE_40000baseSR4_Full_BIT,
> +                 "40000baseSR4/Full" },
> +               { 0, ETHTOOL_LINK_MODE_40000baseLR4_Full_BIT,
> +                 "40000baseLR4/Full" },
> +               { 0, ETHTOOL_LINK_MODE_56000baseKR4_Full_BIT,
> +                 "56000baseKR4/Full" },
> +               { 0, ETHTOOL_LINK_MODE_56000baseCR4_Full_BIT,
> +                 "56000baseCR4/Full" },
> +               { 0, ETHTOOL_LINK_MODE_56000baseSR4_Full_BIT,
> +                 "56000baseSR4/Full" },
> +               { 0, ETHTOOL_LINK_MODE_56000baseLR4_Full_BIT,
> +                 "56000baseLR4/Full" },
>         };
>         int indent;
>         int did1, new_line_pend, i;
> @@ -546,7 +640,8 @@ dump_link_caps(const char *prefix, const char *an_prefix, u32 mask,
>         for (i = 0; i < ARRAY_SIZE(mode_defs); i++) {
>                 if (did1 && !mode_defs[i].same_line)
>                         new_line_pend = 1;
> -               if (mask & mode_defs[i].value) {
> +               if (ethtool_link_mode_test_bit(mode_defs[i].bit_index,
> +                                              mask)) {
>                         if (new_line_pend) {
>                                 fprintf(stdout, "\n");
>                                 fprintf(stdout, "       %*s", indent, "");
> @@ -562,46 +657,52 @@ dump_link_caps(const char *prefix, const char *an_prefix, u32 mask,
>
>         if (!link_mode_only) {
>                 fprintf(stdout, "       %s pause frame use: ", prefix);
> -               if (mask & ADVERTISED_Pause) {
> +               if (ethtool_link_mode_test_bit(
> +                           ETHTOOL_LINK_MODE_Pause_BIT, mask)) {
>                         fprintf(stdout, "Symmetric");
> -                       if (mask & ADVERTISED_Asym_Pause)
> +                       if (ethtool_link_mode_test_bit(
> +                                   ETHTOOL_LINK_MODE_Asym_Pause_BIT, mask))
>                                 fprintf(stdout, " Receive-only");
>                         fprintf(stdout, "\n");
>                 } else {
> -                       if (mask & ADVERTISED_Asym_Pause)
> +                       if (ethtool_link_mode_test_bit(
> +                                   ETHTOOL_LINK_MODE_Asym_Pause_BIT, mask))
>                                 fprintf(stdout, "Transmit-only\n");
>                         else
>                                 fprintf(stdout, "No\n");
>                 }
>
>                 fprintf(stdout, "       %s auto-negotiation: ", an_prefix);
> -               if (mask & ADVERTISED_Autoneg)
> +               if (ethtool_link_mode_test_bit(
> +                           ETHTOOL_LINK_MODE_Autoneg_BIT, mask))
>                         fprintf(stdout, "Yes\n");
>                 else
>                         fprintf(stdout, "No\n");
>         }
>  }
>
> -static int dump_ecmd(struct ethtool_cmd *ep)
> +static int
> +dump_link_usettings(const struct ethtool_link_usettings *link_usettings)
>  {
> -       u32 speed;
> -
> -       dump_supported(ep);
> -       dump_link_caps("Advertised", "Advertised", ep->advertising, 0);
> -       if (ep->lp_advertising)
> +       dump_supported(link_usettings);
> +       dump_link_caps("Advertised", "Advertised",
> +                      link_usettings->link_modes.advertising, 0);
> +       if (!ethtool_link_mode_is_empty(
> +                   link_usettings->link_modes.lp_advertising))
>                 dump_link_caps("Link partner advertised",
> -                              "Link partner advertised", ep->lp_advertising,
> -                              0);
> +                              "Link partner advertised",
> +                              link_usettings->link_modes.lp_advertising, 0);
>
>         fprintf(stdout, "       Speed: ");
> -       speed = ethtool_cmd_speed(ep);
> -       if (speed == 0 || speed == (u16)(-1) || speed == (u32)(-1))
> +       if (link_usettings->base.speed == 0
> +           || link_usettings->base.speed == (u16)(-1)
> +           || link_usettings->base.speed == (u32)(-1))
>                 fprintf(stdout, "Unknown!\n");
>         else
> -               fprintf(stdout, "%uMb/s\n", speed);
> +               fprintf(stdout, "%uMb/s\n", link_usettings->base.speed);
>
>         fprintf(stdout, "       Duplex: ");
> -       switch (ep->duplex) {
> +       switch (link_usettings->base.duplex) {
>         case DUPLEX_HALF:
>                 fprintf(stdout, "Half\n");
>                 break;
> @@ -609,12 +710,12 @@ static int dump_ecmd(struct ethtool_cmd *ep)
>                 fprintf(stdout, "Full\n");
>                 break;
>         default:
> -               fprintf(stdout, "Unknown! (%i)\n", ep->duplex);
> +               fprintf(stdout, "Unknown! (%i)\n", link_usettings->base.duplex);
>                 break;
>         };
>
>         fprintf(stdout, "       Port: ");
> -       switch (ep->port) {
> +       switch (link_usettings->base.port) {
>         case PORT_TP:
>                 fprintf(stdout, "Twisted Pair\n");
>                 break;
> @@ -640,13 +741,13 @@ static int dump_ecmd(struct ethtool_cmd *ep)
>                 fprintf(stdout, "Other\n");
>                 break;
>         default:
> -               fprintf(stdout, "Unknown! (%i)\n", ep->port);
> +               fprintf(stdout, "Unknown! (%i)\n", link_usettings->base.port);
>                 break;
>         };
>
> -       fprintf(stdout, "       PHYAD: %d\n", ep->phy_address);
> +       fprintf(stdout, "       PHYAD: %d\n", link_usettings->base.phy_address);
>         fprintf(stdout, "       Transceiver: ");
> -       switch (ep->transceiver) {
> +       switch (link_usettings->deprecated.transceiver) {
>         case XCVR_INTERNAL:
>                 fprintf(stdout, "internal\n");
>                 break;
> @@ -659,17 +760,18 @@ static int dump_ecmd(struct ethtool_cmd *ep)
>         };
>
>         fprintf(stdout, "       Auto-negotiation: %s\n",
> -               (ep->autoneg == AUTONEG_DISABLE) ?
> +               (link_usettings->base.autoneg == AUTONEG_DISABLE) ?
>                 "off" : "on");
>
> -       if (ep->port == PORT_TP) {
> +       if (link_usettings->base.port == PORT_TP) {
>                 fprintf(stdout, "       MDI-X: ");
> -               if (ep->eth_tp_mdix_ctrl == ETH_TP_MDI) {
> +               if (link_usettings->base.eth_tp_mdix_ctrl == ETH_TP_MDI) {
>                         fprintf(stdout, "off (forced)\n");
> -               } else if (ep->eth_tp_mdix_ctrl == ETH_TP_MDI_X) {
> +               } else if (link_usettings->base.eth_tp_mdix_ctrl
> +                          == ETH_TP_MDI_X) {
>                         fprintf(stdout, "on (forced)\n");
>                 } else {
> -                       switch (ep->eth_tp_mdix) {
> +                       switch (link_usettings->base.eth_tp_mdix) {
>                         case ETH_TP_MDI:
>                                 fprintf(stdout, "off");
>                                 break;
> @@ -680,7 +782,8 @@ static int dump_ecmd(struct ethtool_cmd *ep)
>                                 fprintf(stdout, "Unknown");
>                                 break;
>                         }
> -                       if (ep->eth_tp_mdix_ctrl == ETH_TP_MDI_AUTO)
> +                       if (link_usettings->base.eth_tp_mdix_ctrl
> +                           == ETH_TP_MDI_AUTO)
>                                 fprintf(stdout, " (auto)");
>                         fprintf(stdout, "\n");
>                 }
> @@ -1368,6 +1471,7 @@ static int dump_rxfhash(int fhash, u64 val)
>
>  static void dump_eeecmd(struct ethtool_eee *ep)
>  {
> +       __ETHTOOL_DECLARE_LINK_MODE_MASK(link_mode);
>
>         fprintf(stdout, "       EEE status: ");
>         if (!ep->supported) {
> @@ -1389,9 +1493,16 @@ static void dump_eeecmd(struct ethtool_eee *ep)
>         else
>                 fprintf(stdout, " disabled\n");
>
> -       dump_link_caps("Supported EEE", "", ep->supported, 1);
> -       dump_link_caps("Advertised EEE", "", ep->advertised, 1);
> -       dump_link_caps("Link partner advertised EEE", "", ep->lp_advertised, 1);
> +       ethtool_link_mode_zero(link_mode);
> +
> +       link_mode[0] = ep->supported;
> +       dump_link_caps("Supported EEE", "", link_mode, 1);
> +
> +       link_mode[0] = ep->advertised;
> +       dump_link_caps("Advertised EEE", "", link_mode, 1);
> +
> +       link_mode[0] = ep->lp_advertised;
> +       dump_link_caps("Link partner advertised EEE", "", link_mode, 1);
>  }
>
>  #define N_SOTS 7
> @@ -2247,10 +2358,220 @@ static int do_sfeatures(struct cmd_context *ctx)
>         return 0;
>  }
>
> -static int do_gset(struct cmd_context *ctx)
> +static struct ethtool_link_usettings *
> +__do_ioctl_glinksettings(struct cmd_context *ctx)
> +{
> +       int err;
> +       struct {
> +               struct ethtool_link_settings req;
> +               __u32 link_mode_data[3*__ETHTOOL_LINK_MODE_MASK_MAX_KERNEL_NU32];
> +       } ecmd;
> +       struct ethtool_link_usettings *link_usettings;
> +       unsigned int u32_offs;
> +
> +       /* Handshake with kernel to determine number of words for link
> +        * mode bitmaps. When requested number of bitmap words is not
> +        * the one expected by kernel, the latter returns the integer
> +        * opposite of what it is expecting. We request length 0 below
> +        * (aka. invalid bitmap length) to get this info.
> +        */
> +       memset(&ecmd, 0, sizeof(ecmd));
> +       ecmd.req.cmd = ETHTOOL_GLINKSETTINGS;
> +       err = send_ioctl(ctx, &ecmd);
> +       if (err < 0)
> +               return NULL;
> +
> +       /* see above: we expect a strictly negative value from kernel.
> +        */
> +       if (ecmd.req.link_mode_masks_nwords >= 0
> +           || ecmd.req.cmd != ETHTOOL_GLINKSETTINGS)
> +               return NULL;
> +
> +       /* got the real ecmd.req.link_mode_masks_nwords,
> +        * now send the real request
> +        */
> +       ecmd.req.cmd = ETHTOOL_GLINKSETTINGS;
> +       ecmd.req.link_mode_masks_nwords = -ecmd.req.link_mode_masks_nwords;
> +       err = send_ioctl(ctx, &ecmd);
> +       if (err < 0)
> +               return NULL;
> +
> +       if (ecmd.req.link_mode_masks_nwords <= 0
> +           || ecmd.req.cmd != ETHTOOL_GLINKSETTINGS)
> +               return NULL;
> +
> +       /* Convert to usettings struct */
> +       link_usettings = calloc(1, sizeof(*link_usettings));
> +       if (link_usettings == NULL)
> +               return NULL;
> +
> +       /* keep transceiver 0 */
> +       memcpy(&link_usettings->base, &ecmd.req, sizeof(link_usettings->base));
> +
> +       /* copy link mode bitmaps */
> +       u32_offs = 0;
> +       memcpy(link_usettings->link_modes.supported,
> +              &ecmd.link_mode_data[u32_offs],
> +              4*ecmd.req.link_mode_masks_nwords);
> +
> +       u32_offs += ecmd.req.link_mode_masks_nwords;
> +       memcpy(link_usettings->link_modes.advertising,
> +              &ecmd.link_mode_data[u32_offs],
> +              4*ecmd.req.link_mode_masks_nwords);
> +
> +       u32_offs += ecmd.req.link_mode_masks_nwords;
> +       memcpy(link_usettings->link_modes.lp_advertising,
> +              &ecmd.link_mode_data[u32_offs],
> +              4*ecmd.req.link_mode_masks_nwords);
> +
> +       return link_usettings;
> +}
> +
> +static int
> +__do_ioctl_slinksettings(struct cmd_context *ctx,
> +                        const struct ethtool_link_usettings *link_usettings)
> +{
> +       struct {
> +               struct ethtool_link_settings req;
> +               __u32 link_mode_data[3*__ETHTOOL_LINK_MODE_MASK_MAX_KERNEL_NU32];
> +       } ecmd;
> +       unsigned int u32_offs;
> +
> +       /* refuse to send ETHTOOL_SLINKSETTINGS ioctl if
> +        * link_usettings was retrieved with ETHTOOL_GSET
> +        */
> +       if (link_usettings->base.cmd != ETHTOOL_GLINKSETTINGS)
> +               return -1;
> +
> +       /* refuse to send ETHTOOL_SLINKSETTINGS ioctl if deprecated fields
> +        * were set
> +        */
> +       if (link_usettings->deprecated.transceiver)
> +               return -1;
> +
> +       if (link_usettings->base.link_mode_masks_nwords <= 0)
> +               return -1;
> +
> +       memcpy(&ecmd.req, &link_usettings->base, sizeof(ecmd.req));
> +       ecmd.req.cmd = ETHTOOL_SLINKSETTINGS;
> +
> +       /* copy link mode bitmaps */
> +       u32_offs = 0;
> +       memcpy(&ecmd.link_mode_data[u32_offs],
> +              link_usettings->link_modes.supported,
> +              4*ecmd.req.link_mode_masks_nwords);
> +
> +       u32_offs += ecmd.req.link_mode_masks_nwords;
> +       memcpy(&ecmd.link_mode_data[u32_offs],
> +              link_usettings->link_modes.advertising,
> +              4*ecmd.req.link_mode_masks_nwords);
> +
> +       u32_offs += ecmd.req.link_mode_masks_nwords;
> +       memcpy(&ecmd.link_mode_data[u32_offs],
> +              link_usettings->link_modes.lp_advertising,
> +              4*ecmd.req.link_mode_masks_nwords);
> +
> +       return send_ioctl(ctx, &ecmd);
> +}
> +
> +static struct ethtool_link_usettings *
> +__do_ioctl_gset(struct cmd_context *ctx)
>  {
>         int err;
>         struct ethtool_cmd ecmd;
> +       struct ethtool_link_usettings *link_usettings;
> +
> +       memset(&ecmd, 0, sizeof(ecmd));
> +       ecmd.cmd = ETHTOOL_GSET;
> +       err = send_ioctl(ctx, &ecmd);
> +       if (err < 0)
> +               return NULL;
> +
> +       link_usettings = calloc(1, sizeof(*link_usettings));
> +       if (link_usettings == NULL)
> +               return NULL;
> +
> +       /* remember that ETHTOOL_GSET was used */
> +       link_usettings->base.cmd = ETHTOOL_GSET;
> +
> +       link_usettings->base.link_mode_masks_nwords = 1;
> +       link_usettings->link_modes.supported[0] = ecmd.supported;
> +       link_usettings->link_modes.advertising[0] = ecmd.advertising;
> +       link_usettings->link_modes.lp_advertising[0] = ecmd.lp_advertising;
> +       link_usettings->base.speed = ethtool_cmd_speed(&ecmd);
> +       link_usettings->base.duplex = ecmd.duplex;
> +       link_usettings->base.port = ecmd.port;
> +       link_usettings->base.phy_address = ecmd.phy_address;
> +       link_usettings->deprecated.transceiver = ecmd.transceiver;
> +       link_usettings->base.autoneg = ecmd.autoneg;
> +       link_usettings->base.mdio_support = ecmd.mdio_support;
> +       /* ignored (fully deprecated): maxrxpkt, maxtxpkt */
> +       link_usettings->base.eth_tp_mdix = ecmd.eth_tp_mdix;
> +       link_usettings->base.eth_tp_mdix_ctrl = ecmd.eth_tp_mdix_ctrl;
> +
> +       return link_usettings;
> +}
> +
> +static bool ethtool_link_mode_is_backward_compatible(const u32 *mask)
> +{
> +       unsigned int i;
> +
> +       for (i = 1 ; i < __ETHTOOL_LINK_MODE_MASK_MAX_KERNEL_NU32 ; ++i)
> +               if (mask[i])
> +                       return false;
> +
> +       return true;
> +}
> +
> +static int
> +__do_ioctl_sset(struct cmd_context *ctx,
> +               const struct ethtool_link_usettings *link_usettings)
> +{
> +       struct ethtool_cmd ecmd;
> +
> +       /* refuse to send ETHTOOL_SSET ioctl if link_usettings was
> +        * retrieved with ETHTOOL_GLINKSETTINGS
> +        */
> +       if (link_usettings->base.cmd != ETHTOOL_GSET)
> +               return -1;
> +
> +       if (link_usettings->base.link_mode_masks_nwords <= 0)
> +               return -1;
> +
> +       /* refuse to sset if any bit > 31 is set */
> +       if (!ethtool_link_mode_is_backward_compatible(
> +                   link_usettings->link_modes.supported))
> +               return -1;
> +       if (!ethtool_link_mode_is_backward_compatible(
> +                   link_usettings->link_modes.advertising))
> +               return -1;
> +       if (!ethtool_link_mode_is_backward_compatible(
> +                   link_usettings->link_modes.lp_advertising))
> +               return -1;
> +
> +       memset(&ecmd, 0, sizeof(ecmd));
> +       ecmd.cmd = ETHTOOL_SSET;
> +
> +       ecmd.supported = link_usettings->link_modes.supported[0];
> +       ecmd.advertising = link_usettings->link_modes.advertising[0];
> +       ecmd.lp_advertising = link_usettings->link_modes.lp_advertising[0];
> +       ethtool_cmd_speed_set(&ecmd, link_usettings->base.speed);
> +       ecmd.duplex = link_usettings->base.duplex;
> +       ecmd.port = link_usettings->base.port;
> +       ecmd.phy_address = link_usettings->base.phy_address;
> +       ecmd.transceiver = link_usettings->deprecated.transceiver;
> +       ecmd.autoneg = link_usettings->base.autoneg;
> +       ecmd.mdio_support = link_usettings->base.mdio_support;
> +       /* ignored (fully deprecated): maxrxpkt, maxtxpkt */
> +       ecmd.eth_tp_mdix = link_usettings->base.eth_tp_mdix;
> +       ecmd.eth_tp_mdix_ctrl = link_usettings->base.eth_tp_mdix_ctrl;
> +       return send_ioctl(ctx, &ecmd);
> +}
> +
> +static int do_gset(struct cmd_context *ctx)
> +{
> +       int err;
> +       struct ethtool_link_usettings *link_usettings;
>         struct ethtool_wolinfo wolinfo;
>         struct ethtool_value edata;
>         int allfail = 1;
> @@ -2260,10 +2581,12 @@ static int do_gset(struct cmd_context *ctx)
>
>         fprintf(stdout, "Settings for %s:\n", ctx->devname);
>
> -       ecmd.cmd = ETHTOOL_GSET;
> -       err = send_ioctl(ctx, &ecmd);
> -       if (err == 0) {
> -               err = dump_ecmd(&ecmd);
> +       link_usettings = __do_ioctl_glinksettings(ctx);
> +       if (link_usettings == NULL)
> +               link_usettings = __do_ioctl_gset(ctx);
> +       if (link_usettings != NULL) {
> +               err = dump_link_usettings(link_usettings);
> +               free(link_usettings);
>                 if (err)
>                         return err;
>                 allfail = 0;
> @@ -2322,8 +2645,10 @@ static int do_sset(struct cmd_context *ctx)
>         int autoneg_wanted = -1;
>         int phyad_wanted = -1;
>         int xcvr_wanted = -1;
> -       int full_advertising_wanted = -1;
> -       int advertising_wanted = -1;
> +       u32 *full_advertising_wanted = NULL;
> +       u32 *advertising_wanted = NULL;
> +       __ETHTOOL_DECLARE_LINK_MODE_MASK(_mask_full_advertising_wanted);
> +       __ETHTOOL_DECLARE_LINK_MODE_MASK(_mask_advertising_wanted);
>         int gset_changed = 0; /* did anything in GSET change? */
>         u32 wol_wanted = 0;
>         int wol_change = 0;
> @@ -2337,7 +2662,7 @@ static int do_sset(struct cmd_context *ctx)
>         int argc = ctx->argc;
>         char **argp = ctx->argp;
>         int i;
> -       int err;
> +       int err = 0;
>
>         for (i = 0; i < ARRAY_SIZE(flags_msglvl); i++)
>                 flag_to_cmdline_info(flags_msglvl[i].name,
> @@ -2411,7 +2736,12 @@ static int do_sset(struct cmd_context *ctx)
>                         i += 1;
>                         if (i >= argc)
>                                 exit_bad_args();
> -                       full_advertising_wanted = get_int(argp[i], 16);
> +                       if (parse_hex_u32_bitmap(
> +                                   argp[i],
> +                                   __ETHTOOL_LINK_MODE_MASK_MAX_KERNEL_NBITS,
> +                                   _mask_full_advertising_wanted))
> +                               exit_bad_args();
> +                       full_advertising_wanted = _mask_full_advertising_wanted;
>                 } else if (!strcmp(argp[i], "phyad")) {
>                         gset_changed = 1;
>                         i += 1;
> @@ -2468,75 +2798,89 @@ static int do_sset(struct cmd_context *ctx)
>                 }
>         }
>
> -       if (full_advertising_wanted < 0) {
> +       if (full_advertising_wanted == NULL) {
>                 /* User didn't supply a full advertisement bitfield:
>                  * construct one from the specified speed and duplex.
>                  */
> +               int adv_bit = -1;
> +
>                 if (speed_wanted == SPEED_10 && duplex_wanted == DUPLEX_HALF)
> -                       advertising_wanted = ADVERTISED_10baseT_Half;
> +                       adv_bit = ETHTOOL_LINK_MODE_10baseT_Half_BIT;
>                 else if (speed_wanted == SPEED_10 &&
>                          duplex_wanted == DUPLEX_FULL)
> -                       advertising_wanted = ADVERTISED_10baseT_Full;
> +                       adv_bit = ETHTOOL_LINK_MODE_10baseT_Full_BIT;
>                 else if (speed_wanted == SPEED_100 &&
>                          duplex_wanted == DUPLEX_HALF)
> -                       advertising_wanted = ADVERTISED_100baseT_Half;
> +                       adv_bit = ETHTOOL_LINK_MODE_100baseT_Half_BIT;
>                 else if (speed_wanted == SPEED_100 &&
>                          duplex_wanted == DUPLEX_FULL)
> -                       advertising_wanted = ADVERTISED_100baseT_Full;
> +                       adv_bit = ETHTOOL_LINK_MODE_100baseT_Full_BIT;
>                 else if (speed_wanted == SPEED_1000 &&
>                          duplex_wanted == DUPLEX_HALF)
> -                       advertising_wanted = ADVERTISED_1000baseT_Half;
> +                       adv_bit = ETHTOOL_LINK_MODE_1000baseT_Half_BIT;
>                 else if (speed_wanted == SPEED_1000 &&
>                          duplex_wanted == DUPLEX_FULL)
> -                       advertising_wanted = ADVERTISED_1000baseT_Full;
> +                       adv_bit = ETHTOOL_LINK_MODE_1000baseT_Full_BIT;
>                 else if (speed_wanted == SPEED_2500 &&
>                          duplex_wanted == DUPLEX_FULL)
> -                       advertising_wanted = ADVERTISED_2500baseX_Full;
> +                       adv_bit = ETHTOOL_LINK_MODE_2500baseX_Full_BIT;
>                 else if (speed_wanted == SPEED_10000 &&
>                          duplex_wanted == DUPLEX_FULL)
> -                       advertising_wanted = ADVERTISED_10000baseT_Full;
> -               else
> -                       /* auto negotiate without forcing,
> -                        * all supported speed will be assigned below
> -                        */
> -                       advertising_wanted = 0;
> +                       adv_bit = ETHTOOL_LINK_MODE_10000baseT_Full_BIT;
> +
> +               if (adv_bit >= 0) {
> +                       advertising_wanted = _mask_advertising_wanted;
> +                       ethtool_link_mode_zero(advertising_wanted);
> +                       ethtool_link_mode_set_bit(
> +                               adv_bit, advertising_wanted);
> +               }
> +               /* otherwise: auto negotiate without forcing,
> +                * all supported speed will be assigned below
> +                */
>         }
>
>         if (gset_changed) {
> -               struct ethtool_cmd ecmd;
> +               struct ethtool_link_usettings *link_usettings;
>
> -               ecmd.cmd = ETHTOOL_GSET;
> -               err = send_ioctl(ctx, &ecmd);
> -               if (err < 0) {
> +               link_usettings = __do_ioctl_glinksettings(ctx);
> +               if (link_usettings == NULL)
> +                       link_usettings = __do_ioctl_gset(ctx);
> +               if (link_usettings == NULL) {
>                         perror("Cannot get current device settings");
> +                       err = -1;
>                 } else {
>                         /* Change everything the user specified. */
>                         if (speed_wanted != -1)
> -                               ethtool_cmd_speed_set(&ecmd, speed_wanted);
> +                               link_usettings->base.speed = speed_wanted;
>                         if (duplex_wanted != -1)
> -                               ecmd.duplex = duplex_wanted;
> +                               link_usettings->base.duplex = duplex_wanted;
>                         if (port_wanted != -1)
> -                               ecmd.port = port_wanted;
> +                               link_usettings->base.port = port_wanted;
>                         if (mdix_wanted != -1) {
>                                 /* check driver supports MDI-X */
> -                               if (ecmd.eth_tp_mdix_ctrl != ETH_TP_MDI_INVALID)
> -                                       ecmd.eth_tp_mdix_ctrl = mdix_wanted;
> +                               if (link_usettings->base.eth_tp_mdix_ctrl
> +                                   != ETH_TP_MDI_INVALID)
> +                                       link_usettings->base.eth_tp_mdix_ctrl
> +                                               = mdix_wanted;
>                                 else
> -                                       fprintf(stderr, "setting MDI not supported\n");
> +                                       fprintf(stderr,
> +                                               "setting MDI not supported\n");
>                         }
>                         if (autoneg_wanted != -1)
> -                               ecmd.autoneg = autoneg_wanted;
> +                               link_usettings->base.autoneg = autoneg_wanted;
>                         if (phyad_wanted != -1)
> -                               ecmd.phy_address = phyad_wanted;
> +                               link_usettings->base.phy_address = phyad_wanted;
>                         if (xcvr_wanted != -1)
> -                               ecmd.transceiver = xcvr_wanted;
> +                               link_usettings->deprecated.transceiver
> +                                       = xcvr_wanted;
>                         /* XXX If the user specified speed or duplex
>                          * then we should mask the advertised modes
>                          * accordingly.  For now, warn that we aren't
>                          * doing that.
>                          */
>                         if ((speed_wanted != -1 || duplex_wanted != -1) &&
> -                           ecmd.autoneg && advertising_wanted == 0) {
> +                           link_usettings->base.autoneg &&
> +                           advertising_wanted == NULL) {
>                                 fprintf(stderr, "Cannot advertise");
>                                 if (speed_wanted >= 0)
>                                         fprintf(stderr, " speed %d",
> @@ -2548,37 +2892,56 @@ static int do_sset(struct cmd_context *ctx)
>                                 fprintf(stderr, "\n");
>                         }
>                         if (autoneg_wanted == AUTONEG_ENABLE &&
> -                           advertising_wanted == 0) {
> +                           advertising_wanted == NULL) {
> +                               unsigned int i;
> +
>                                 /* Auto negotiation enabled, but with
>                                  * unspecified speed and duplex: enable all
>                                  * supported speeds and duplexes.
>                                  */
> -                               ecmd.advertising =
> -                                       (ecmd.advertising &
> -                                        ~ALL_ADVERTISED_MODES) |
> -                                       (ALL_ADVERTISED_MODES & ecmd.supported);
> +                               ethtool_link_mode_for_each_u32(i) {
> +                                       u32 sup = link_usettings->link_modes.supported[i];
> +                                       u32 *adv = link_usettings->link_modes.advertising + i;
> +
> +                                       *adv = ((*adv & ~all_advertised_modes[i])
> +                                               | (sup & all_advertised_modes[i]));
> +                               }
>
>                                 /* If driver supports unknown flags, we cannot
>                                  * be sure that we enable all link modes.
>                                  */
> -                               if ((ecmd.supported & ALL_ADVERTISED_FLAGS) !=
> -                                   ecmd.supported) {
> -                                       fprintf(stderr, "Driver supports one "
> -                                               "or more unknown flags\n");
> +                               ethtool_link_mode_for_each_u32(i) {
> +                                       u32 sup = link_usettings->link_modes.supported[i];
> +
> +                                       if ((sup & all_advertised_flags[i]) != sup) {
> +                                               fprintf(stderr, "Driver supports one or more unknown flags\n");
> +                                               break;
> +                                       }
>                                 }
> -                       } else if (advertising_wanted > 0) {
> +                       } else if (advertising_wanted != NULL) {
> +                               unsigned int i;
> +
>                                 /* Enable all requested modes */
> -                               ecmd.advertising =
> -                                       (ecmd.advertising &
> -                                        ~ALL_ADVERTISED_MODES) |
> -                                       advertising_wanted;
> -                       } else if (full_advertising_wanted > 0) {
> -                               ecmd.advertising = full_advertising_wanted;
> +                               ethtool_link_mode_for_each_u32(i) {
> +                                       u32 *adv = link_usettings->link_modes.advertising + i;
> +
> +                                       *adv = ((*adv & ~all_advertised_modes[i])
> +                                               | advertising_wanted[i]);
> +                               }
> +                       } else if (full_advertising_wanted != NULL) {
> +                               ethtool_link_mode_copy(
> +                                       link_usettings->link_modes.advertising,
> +                                       full_advertising_wanted);
>                         }
>
>                         /* Try to perform the update. */
> -                       ecmd.cmd = ETHTOOL_SSET;
> -                       err = send_ioctl(ctx, &ecmd);
> +                       if (link_usettings->base.cmd == ETHTOOL_GLINKSETTINGS)
> +                               err = __do_ioctl_slinksettings(ctx,
> +                                                              link_usettings);
> +                       else
> +                               err = __do_ioctl_sset(ctx,
> +                                                     link_usettings);
> +                       free(link_usettings);
>                         if (err < 0)
>                                 perror("Cannot set new settings");
>                 }
> @@ -4230,6 +4593,8 @@ int main(int argc, char **argp)
>         struct cmd_context ctx;
>         int k;
>
> +       init_global_link_mode_masks();
> +
>         /* Skip command name */
>         argp++;
>         argc--;
> diff --git a/internal.h b/internal.h
> index e98f532..5e78b5c 100644
> --- a/internal.h
> +++ b/internal.h
> @@ -12,6 +12,7 @@
>  #ifdef HAVE_CONFIG_H
>  #include "ethtool-config.h"
>  #endif
> +#include <stdbool.h>
>  #include <stdio.h>
>  #include <stdint.h>
>  #include <stdlib.h>
> @@ -122,6 +123,72 @@ static inline int test_bit(unsigned int nr, const unsigned long *addr)
>                                  ETH_FLAG_TXVLAN | ETH_FLAG_NTUPLE |    \
>                                  ETH_FLAG_RXHASH)
>
> +/* internal API for link mode bitmap interaction with kernel. */
> +
> +#define __ETHTOOL_LINK_MODE_MASK_MAX_KERNEL_NU32       \
> +       (SCHAR_MAX)
> +#define __ETHTOOL_LINK_MODE_MASK_MAX_KERNEL_NBITS      \
> +       (32*__ETHTOOL_LINK_MODE_MASK_MAX_KERNEL_NU32)
> +#define __ETHTOOL_LINK_MODE_MASK_MAX_KERNEL_NBYTES     \
> +       (4*__ETHTOOL_LINK_MODE_MASK_MAX_KERNEL_NU32)
> +#define __ETHTOOL_DECLARE_LINK_MODE_MASK(name)                 \
> +       u32 name[__ETHTOOL_LINK_MODE_MASK_MAX_KERNEL_NU32]
> +
> +struct ethtool_link_usettings {
> +       struct {
> +               __u8 transceiver;
> +       } deprecated;
> +       struct ethtool_link_settings base;
> +       struct {
> +               __ETHTOOL_DECLARE_LINK_MODE_MASK(supported);
> +               __ETHTOOL_DECLARE_LINK_MODE_MASK(advertising);
> +               __ETHTOOL_DECLARE_LINK_MODE_MASK(lp_advertising);
> +       } link_modes;
> +};
> +
> +#define ethtool_link_mode_for_each_u32(index)                          \
> +       for ((index) = 0 ;                                              \
> +            (index) < __ETHTOOL_LINK_MODE_MASK_MAX_KERNEL_NU32 ;       \
> +            ++(index))
> +
> +static inline void ethtool_link_mode_zero(u32 *dst)
> +{
> +       memset(dst, 0, __ETHTOOL_LINK_MODE_MASK_MAX_KERNEL_NBYTES);
> +}
> +
> +static inline bool ethtool_link_mode_is_empty(const u32 *mask)
> +{
> +       unsigned int i;
> +
> +       ethtool_link_mode_for_each_u32(i)
> +       {
> +               if (mask[i] != 0)
> +                       return false;
> +       }
> +
> +       return true;
> +}
> +
> +static inline void ethtool_link_mode_copy(u32 *dst, const u32 *src)
> +{
> +       memcpy(dst, src, __ETHTOOL_LINK_MODE_MASK_MAX_KERNEL_NBYTES);
> +}
> +
> +static inline int ethtool_link_mode_test_bit(unsigned int nr, const u32 *mask)
> +{
> +       if (nr >= __ETHTOOL_LINK_MODE_MASK_MAX_KERNEL_NBITS)
> +               return !!0;
> +       return !!(mask[nr / 32] & (1 << (nr % 32)));
> +}
> +
> +static inline int ethtool_link_mode_set_bit(unsigned int nr, u32 *mask)
> +{
> +       if (nr >= __ETHTOOL_LINK_MODE_MASK_MAX_KERNEL_NBITS)
> +               return -1;
> +       mask[nr / 32] |= (1 << (nr % 32));
> +       return 0;
> +}
> +
>  /* Context for sub-commands */
>  struct cmd_context {
>         const char *devname;    /* net device name */
> diff --git a/test-cmdline.c b/test-cmdline.c
> index 2fd7cbb..a94edea 100644
> --- a/test-cmdline.c
> +++ b/test-cmdline.c
> @@ -37,7 +37,20 @@ static struct test_case {
>         { 1, "--change devname autoneg foo" },
>         { 1, "-s devname autoneg" },
>         { 0, "--change devname advertise 0x1" },
> +       { 0, "--change devname advertise 0xf" },
> +       { 0, "--change devname advertise 0Xf" },
> +       { 0, "--change devname advertise 1" },
> +       { 0, "--change devname advertise f" },
> +       { 0, "--change devname advertise 01" },
> +       { 0, "--change devname advertise 0f" },
> +       { 0, "--change devname advertise 0xfffffffffffffffffffffffffffffffff" },
> +       { 0, "--change devname advertise fffffffffffffffffffffffffffffffff" },
> +       { 0, "--change devname advertise 0x0000fffffffffffffffffffffffffffff" },
> +       { 0, "--change devname advertise 0000fffffffffffffffffffffffffffff" },
> +       { 1, "-s devname advertise" },
> +       { 1, "-s devname advertise 0x" },
>         { 1, "-s devname advertise foo" },
> +       { 1, "-s devname advertise 0xfoo" },
>         { 1, "--change devname advertise" },
>         { 0, "-s devname phyad 1" },
>         { 1, "--change devname phyad foo" },
> --
> 2.8.0.rc3.226.g39d4020
>
