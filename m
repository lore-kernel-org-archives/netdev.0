From: David Decotigny <ddecotig@gmail.com>
Subject: Re: [ethtool PATCH v4 10/11] ethtool.c: add support for
 ETHTOOL_xLINKSETTINGS ioctls
Date: Tue, 15 Mar 2016 16:42:23 -0700
Message-ID: <CAG88wWZkeiR_X0rKR9WOVjDnz6t9jRZDF7QXmjcAfP+d60BXOw@mail.gmail.com>
References: <1457719104-39188-1-git-send-email-ddecotig@gmail.com>
 <1457719104-39188-11-git-send-email-ddecotig@gmail.com> <1457919156.3331.90.camel@decadent.org.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	Jeff Garzik <jgarzik@pobox.com>,
	David Miller <davem@redhat.com>,
	Vidya Sagar Ravipati <vidya@cumulusnetworks.com>,
	Joe Perches <joe@perches.com>
To: Ben Hutchings <ben@decadent.org.uk>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f54.google.com ([74.125.82.54]:33103 "EHLO
	mail-wm0-f54.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S966000AbcCOXmp (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 15 Mar 2016 19:42:45 -0400
Received: by mail-wm0-f54.google.com with SMTP id l68so166822144wml.0
        for <netdev@vger.kernel.org>; Tue, 15 Mar 2016 16:42:44 -0700 (PDT)
In-Reply-To: <1457919156.3331.90.camel@decadent.org.uk>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Just sent v5 of the series: now only this patch left. Applied all your
suggestions.

Many thanks for the 2 bugs you caught, path was not covered by my
tests. v5 was tested on a 10G nic with: ethtool -s eth1 msglvl 0x15
speed 10000 duplex full

On Sun, Mar 13, 2016 at 6:32 PM, Ben Hutchings <ben@decadent.org.uk> wrote:
> On Fri, 2016-03-11 at 09:58 -0800, David Decotigny wrote:
> [...]
>> +static int parse_hex_u32_bitmap(const char *s,
>> +                             unsigned int nbits, u32 *result)
>> +{
>> +     const unsigned nwords = __KERNEL_DIV_ROUND_UP(nbits, 32);
>> +     size_t slen = strlen(s);
>> +     size_t i;
>> +
>> +     /* ignore optional '0x' prefix */
>> +     if ((slen > 2) && (
>> +                 (0 == memcmp(s, "0x", 2)
>> +                  || (0 == memcmp(s, "0X", 2))))) {
>
> memcmp() is a really poor tool for comparing strings.  You should use
> strncasecmp() here.

done.

>
>> +             slen -= 2;
>> +             s += 2;
>> +     }
>> +
>> +     if (slen > 8*nwords)  /* up to 2 digits per byte */
>
> The '*' operator should have spaces around it.  Please run
> checkpatch.pl over your ethtool patches to catch style errors like this
> (there are many others in this one).

both done. a few new lines over 80 chars that I prefer to keep,
otherwise line break would make code harder to read imho.

>
> [...]
>> +static void dump_link_caps(const char *prefix, const char *an_prefix,
>> +                        const u32 *mask, int link_mode_only)
>>  {
>>       static const struct {
>>               int same_line; /* print on same line as previous */
>> -             u32 value;
>> +             unsigned bit_indice;
>
> bit_index

done.

>
> [...]
>> @@ -558,51 +655,57 @@ dump_link_caps(const char *prefix, const char *an_prefix, u32 mask,
>>               }
>>       }
>>       if (did1 == 0)
>> -              fprintf(stdout, "Not reported");
>> +             fprintf(stdout, "Not reported");
>
> Good catch, but whitespace fixes belong in another patch.

removed for now.

>
> [...]
>
>> @@ -2248,10 +2360,219 @@ static int do_sfeatures(struct cmd_context *ctx)
>>       return 0;
>>  }
>>
>> -static int do_gset(struct cmd_context *ctx)
>> +static struct ethtool_link_usettings *
>> +__do_ioctl_glinksettings(struct cmd_context * ctx)
>> +{
>> +     int err;
>> +     struct {
>> +             struct ethtool_link_settings req;
>> +             __u32 link_mode_data[3*__ETHTOOL_LINK_MODE_MASK_MAX_KERNEL_NU32];
>> +     } ecmd;
>> +     struct ethtool_link_usettings *link_usettings;
>> +     unsigned u32_offs;
>> +
>> +     /* handshake with kernel to determine number of words for link
>> +      * mode bitmaps */
>> +     memset(&ecmd, 0, sizeof(ecmd));
>> +     ecmd.req.cmd = ETHTOOL_GLINKSETTINGS;
>> +     err = send_ioctl(ctx, &ecmd);
>> +     if (err < 0)
>> +             return NULL;
>> +
>> +     if (ecmd.req.link_mode_masks_nwords >= 0 || ecmd.req.cmd)
>> +             return NULL;
>
> Oops, I missed the kernel side of this.  Clearing the cmd field is a
> very strange thing to do and inconsistent with every other ethtool
> command, so I've just sent a patch to change the kernel side of that.
> You'll need to change this to match.
>
> (I also think the negative size is a bit weird, but don't feel so
> strongly about it.)

updated based on your patch. sent a suggestion
http://marc.info/?l=linux-netdev&m=145806871332416 , looks like it was
not added properly to the thread, because I don't see it as a reply to
your patch in patchwork. sorry about this.

>
> [...]
>> +     link_usettings = malloc(sizeof(*link_usettings));
>> +     if (NULL == link_usettings)
>
> Comparison is the wrong way round.

done.

>
>> +             return NULL;
>> +
>> +     memset(link_usettings, 0, sizeof(*link_usettings));
>
> Could use calloc() instead of malloc() + memset().

done.

>
>> +     /* keep transceiver 0 */
>> +     memcpy(&link_usettings->base, &ecmd.req, sizeof(link_usettings->base));
>> +     /* remember that ETHTOOL_GLINKSETTINGS was used */
>> +     link_usettings->base.cmd = ETHTOOL_GLINKSETTINGS;
>
> This is redundant as we know that ecmd.req.cmd ==
> ETHTOOL_GLINKSETTINGS.

done.

>
> [...]
>> +static struct ethtool_link_usettings *
>> +__do_ioctl_gset(struct cmd_context * ctx)
>>  {
> [...]
>> +     link_usettings->base.link_mode_masks_nwords = 1;
>> +     link_usettings->link_modes.supported[0] = ecmd.supported;
>> +     link_usettings->link_modes.advertising[0] = ecmd.advertising;
>> +     link_usettings->link_modes.lp_advertising[0] = ecmd.lp_advertising;
>> +     link_usettings->base.speed = ethtool_cmd_speed(&ecmd);
>> +     link_usettings->base.duplex = ecmd.duplex;
>> +     link_usettings->base.port = ecmd.port;
>> +     link_usettings->base.phy_address = ecmd.phy_address;
>> +     link_usettings->deprecated.transceiver = ecmd.transceiver;
>> +     link_usettings->base.autoneg = ecmd.autoneg;
>> +     link_usettings->base.mdio_support = ecmd.mdio_support;
>> +     /* ignored (fully deprecated): maxrxpkt, maxtxpkt */
>> +     link_usettings->base.eth_tp_mdix = ecmd.eth_tp_mdix;
>> +     link_usettings->base.eth_tp_mdix_ctrl = ecmd.eth_tp_mdix_ctrl;
>> +     link_usettings->deprecated.transceiver = ecmd.transceiver;
>
> Duplicate assignment.

done.

>
>> +     return link_usettings;
>> +}
>> +
>> +static bool ethtool_link_mode_is_backward_compatible(
>> +     const u32 *mask)
>
> Don't wrap function parameter lists or statements that are already
> under 80 characters.

done.

>
> [...]
>> +static void
>> +__free_link_usettings(struct ethtool_link_usettings *link_usettings) {
>> +     free(link_usettings);
>> +}
>
> Is this function ever likely to do more than just free()?  If not,
> don't bother abstracting that.

free() is likely to stay good enough. updated.

>
> [...]
>> @@ -2469,75 +2799,88 @@ static int do_sset(struct cmd_context *ctx)
>>               }
>>       }
>>
>> -     if (full_advertising_wanted < 0) {
>> +     if (NULL == full_advertising_wanted) {
>>               /* User didn't supply a full advertisement bitfield:
>>                * construct one from the specified speed and duplex.
>>                */
>> +             int adv_bit = -1;
>> +
>>               if (speed_wanted == SPEED_10 && duplex_wanted == DUPLEX_HALF)
>> -                     advertising_wanted = ADVERTISED_10baseT_Half;
>> +                     adv_bit = ETHTOOL_LINK_MODE_10baseT_Half_BIT;
>>               else if (speed_wanted == SPEED_10 &&
>>                        duplex_wanted == DUPLEX_FULL)
>> -                     advertising_wanted = ADVERTISED_10baseT_Full;
>> +                     adv_bit = ETHTOOL_LINK_MODE_10baseT_Full_BIT;
>>               else if (speed_wanted == SPEED_100 &&
>>                        duplex_wanted == DUPLEX_HALF)
>> -                     advertising_wanted = ADVERTISED_100baseT_Half;
>> +                     adv_bit = ETHTOOL_LINK_MODE_100baseT_Half_BIT;
>>               else if (speed_wanted == SPEED_100 &&
>>                        duplex_wanted == DUPLEX_FULL)
>> -                     advertising_wanted = ADVERTISED_100baseT_Full;
>> +                     adv_bit = ETHTOOL_LINK_MODE_100baseT_Full_BIT;
>>               else if (speed_wanted == SPEED_1000 &&
>>                        duplex_wanted == DUPLEX_HALF)
>> -                     advertising_wanted = ADVERTISED_1000baseT_Half;
>> +                     adv_bit = ETHTOOL_LINK_MODE_1000baseT_Half_BIT;
>>               else if (speed_wanted == SPEED_1000 &&
>>                        duplex_wanted == DUPLEX_FULL)
>> -                     advertising_wanted = ADVERTISED_1000baseT_Full;
>> +                     adv_bit = ETHTOOL_LINK_MODE_1000baseT_Full_BIT;
>>               else if (speed_wanted == SPEED_2500 &&
>>                        duplex_wanted == DUPLEX_FULL)
>> -                     advertising_wanted = ADVERTISED_2500baseX_Full;
>> +                     adv_bit = ETHTOOL_LINK_MODE_2500baseX_Full_BIT;
>>               else if (speed_wanted == SPEED_10000 &&
>>                        duplex_wanted == DUPLEX_FULL)
>> -                     advertising_wanted = ADVERTISED_10000baseT_Full;
>> -             else
>> -                     /* auto negotiate without forcing,
>> -                      * all supported speed will be assigned below
>> -                      */
>> -                     advertising_wanted = 0;
>> +                     adv_bit = ETHTOOL_LINK_MODE_10000baseT_Full_BIT;
>> +
>> +             if (adv_bit >= 0) {
>> +                     advertising_wanted = _mask_advertising_wanted;
>
> If I'm not mistaken, _mask_advertising_wanted is uninitialised at this
> point so you need to clear it before setting the one bit.

great catch! thanks.

>
>> +                     ethtool_link_mode_set_bit(
>> +                             adv_bit, advertising_wanted);
> [...]
>> @@ -2549,37 +2892,56 @@ static int do_sset(struct cmd_context *ctx)
>>                               fprintf(stderr, "\n");
>>                       }
>>                       if (autoneg_wanted == AUTONEG_ENABLE &&
>> -                         advertising_wanted == 0) {
>> +                         NULL == advertising_wanted) {
>> +                             unsigned int i;
>> +
>>                               /* Auto negotiation enabled, but with
>>                                * unspecified speed and duplex: enable all
>>                                * supported speeds and duplexes.
>>                                */
>> -                             ecmd.advertising =
>> -                                     (ecmd.advertising &
>> -                                      ~ALL_ADVERTISED_MODES) |
>> -                                     (ALL_ADVERTISED_MODES & ecmd.supported);
>> +                             ethtool_link_mode_for_each_u32(i)
>> +                             {
>
> Brace belongs on the previous line (everywhere you use
> ethtool_link_mode_for_each_u32()).

done.

>
> [...]
>> -                     } else if (advertising_wanted > 0) {
>> +                     } else if (NULL != advertising_wanted) {
>> +                             unsigned int i;
>> +
>>                               /* Enable all requested modes */
>> -                             ecmd.advertising =
>> -                                     (ecmd.advertising &
>> -                                      ~ALL_ADVERTISED_MODES) |
>> -                                     advertising_wanted;
>> -                     } else if (full_advertising_wanted > 0) {
>> -                             ecmd.advertising = full_advertising_wanted;
>> +                             ethtool_link_mode_for_each_u32(i)
>> +                             {
>> +                                     u32 *adv = link_usettings->link_modes.advertising + i;
>> +                                     *adv = ((*adv & all_advertised_modes[i])
> [...]
>
> Should be ~all_advertised_modes[i] rather than all_advertised_modes[i].

aouch! thanks.

>
> Ben.
>
> --
> Ben Hutchings
> If at first you don't succeed, you're doing about average.
