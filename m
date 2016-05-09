From: Huw Davies <huw-PJ7GQ4yptbsswetKESUqMA@public.gmane.org>
Subject: Re: [RFC PATCH v3 17/19] calipso: Add validation of CALIPSO option.
Date: Mon, 9 May 2016 11:39:18 +0100
Message-ID: <20160509103918.GC20123@merlot.physics.ox.ac.uk>
References: <1455715329-9601-18-git-send-email-huw@codeweavers.com>
 <CAHC9VhTRp8bHgwxZ2YNj=pa2a4PtO=8jJT1siG99GiFYnwm53Q@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-security-module-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
        selinux-+05T5uksL2qpZYMLLGbcSA@public.gmane.org
To: Paul Moore <paul-r2n+y4ga6xFZroRs9YW3xA@public.gmane.org>
Return-path: <selinux-bounces-+05T5uksL2qpZYMLLGbcSA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <CAHC9VhTRp8bHgwxZ2YNj=pa2a4PtO=8jJT1siG99GiFYnwm53Q-JsoAwUIsXosN+BqQ9rBEUg@public.gmane.org>
List-Post: <mailto:selinux-+05T5uksL2qpZYMLLGbcSA@public.gmane.org>
List-Help: <mailto:selinux-request-+05T5uksL2qpZYMLLGbcSA@public.gmane.org?subject=help>
Errors-To: selinux-bounces-+05T5uksL2qpZYMLLGbcSA@public.gmane.org
Sender: "Selinux" <selinux-bounces-+05T5uksL2qpZYMLLGbcSA@public.gmane.org>
List-Id: netdev.vger.kernel.org

On Fri, May 06, 2016 at 06:59:32PM -0400, Paul Moore wrote:
> On Wed, Feb 17, 2016 at 8:22 AM, Huw Davies <huw-PJ7GQ4yptbsswetKESUqMA@public.gmane.org> wrote:
> > We check lengths, checksum and the DOI.  We leave checking of the
> > level and categories for the socket layer.
> >
> > Signed-off-by: Huw Davies <huw-PJ7GQ4yptbsswetKESUqMA@public.gmane.org>
> > ---
> >  include/net/calipso.h |  6 ++++++
> >  net/ipv6/calipso.c    | 42 ++++++++++++++++++++++++++++++++++++++++++
> >  net/ipv6/exthdrs.c    | 27 +++++++++++++++++++++++++++
> >  3 files changed, 75 insertions(+)
> >
> > diff --git a/include/net/calipso.h b/include/net/calipso.h
> > index 38dbb47..85404e2 100644
> > --- a/include/net/calipso.h
> > +++ b/include/net/calipso.h
> > @@ -65,6 +65,7 @@ struct calipso_doi {
> >  #ifdef CONFIG_NETLABEL
> >  int __init calipso_init(void);
> >  void calipso_exit(void);
> > +bool calipso_validate(const struct sk_buff *skb, const unsigned char *option);
> >  #else
> >  static inline int __init calipso_init(void)
> >  {
> > @@ -74,6 +75,11 @@ static inline int __init calipso_init(void)
> >  static inline void calipso_exit(void)
> >  {
> >  }
> > +static inline bool calipso_validate(const struct sk_buff *skb,
> > +                                   const unsigned char *option)
> > +{
> > +       return true;
> > +}
> >  #endif /* CONFIG_NETLABEL */
> >
> >  #endif /* _CALIPSO_H */
> > diff --git a/net/ipv6/calipso.c b/net/ipv6/calipso.c
> > index fa371a8..b8bcf9f 100644
> > --- a/net/ipv6/calipso.c
> > +++ b/net/ipv6/calipso.c
> > @@ -321,6 +321,48 @@ doi_walk_return:
> >  }
> >
> >  /**
> > + * calipso_validate - Validate a CALIPSO option
> > + * @skb: the packet
> > + * @option: the start of the option
> > + *
> > + * Description:
> > + * This routine is called to validate a CALIPSO option.
> > + * If the option is valid then a zero value is returned.  If the
> > + * option is invalid then a non-zero value is returned and
> > + * representing the offset to the offending portion of the option.
> > + *
> > + * The caller should have already checked that the length of the
> > + * option (including the TLV header) is >= 10 and that the catmap
> > + * length is consistent with the option length.
> > + *
> > + * We leave checks on the level and categories to the socket layer.
> > + */
> > +bool calipso_validate(const struct sk_buff *skb, const unsigned char *option)
> > +{
> > +       struct calipso_doi *doi_def;
> > +       int ret_val;
> > +       u16 crc, len = option[1] + 2;
> > +       static const u8 zero[2];
> > +
> > +       /* The original CRC runs over the option including the TLV header
> > +        * with the CRC-16 field (at offset 8) zeroed out. */
> > +       crc = crc_ccitt(0xffff, option, 8);
> > +       crc = crc_ccitt(crc, zero, sizeof(zero));
> > +       if (len > 10)
> > +               crc = crc_ccitt(crc, option + 10, len - 10);
> > +       crc = ~crc;
> 
> I should have caught this in the v2 patchset when I mentioned it with
> respect to the CRC generation, but why not simply do 'crc =
> ~crc_cccitt(...);'?

Simply because the final crc_ccitt() is inside an if statement.
Since len is guaranteed to be >= 10, I could dispense with the if and
have crc_ccitt() handle having its final argument equal to zero (which
it does just fine).  Then I could do as you suggest.

> Also, while I'm looking at this, why not do the CRC verification in
> ipv6_hop_calipso()?  The only thing we should need to do here is the
> DOI lookup/verification so that we still work correctly when
> CONFIG_NETLABEL=n; all the core protocol stuff, e.g. length and
> checksum validation, should be done in the core stack functions, e.g.
> ipv6_hop_calipso().

The only reason was to not bring in CONFIG_CRC_CCITT if CONFIG_NETLABEL=n
(this is currently selected in net/netlabel/Kconfig).

If folks are happy for me to do so, I could change this to:
select CONFIG_CRC_CCITT
under menuconfig IPV6

Then the crc check could move to exthdrs.c:ipv6_hop_calipso().  Would
that be ok?

Thanks,
Huw.

> > +       if (option[8] != (crc & 0xff) || option[9] != ((crc >> 8) & 0xff))
> > +               return false;
> > +
> > +       rcu_read_lock();
> > +       doi_def = calipso_doi_search(get_unaligned_be32(option + 2));
> > +       ret_val = !!doi_def;
> > +       rcu_read_unlock();
> > +
> > +       return ret_val;
> > +}
> > +
> > +/**
> >   * calipso_map_cat_hton - Perform a category mapping from host to network
> >   * @doi_def: the DOI definition
> >   * @secattr: the security attributes
> > diff --git a/net/ipv6/exthdrs.c b/net/ipv6/exthdrs.c
> > index d5fd3e7..0f69cab 100644
> > --- a/net/ipv6/exthdrs.c
> > +++ b/net/ipv6/exthdrs.c
> > @@ -43,6 +43,7 @@
> >  #include <net/ndisc.h>
> >  #include <net/ip6_route.h>
> >  #include <net/addrconf.h>
> > +#include <net/calipso.h>
> >  #if IS_ENABLED(CONFIG_IPV6_MIP6)
> >  #include <net/xfrm.h>
> >  #endif
> > @@ -603,6 +604,28 @@ drop:
> >         return false;
> >  }
> >
> > +/* CALIPSO RFC 5570 */
> > +
> > +static bool ipv6_hop_calipso(struct sk_buff *skb, int optoff)
> > +{
> > +       const unsigned char *nh = skb_network_header(skb);
> > +
> > +       if (nh[optoff + 1] < 8)
> > +               goto drop;
> > +
> > +       if (nh[optoff + 6] * 4 + 8 > nh[optoff + 1])
> > +               goto drop;
> > +
> > +       if (!calipso_validate(skb, nh + optoff))
> > +               goto drop;
> > +
> > +       return true;
> > +
> > +drop:
> > +       kfree_skb(skb);
> > +       return false;
> > +}
> > +
> >  static const struct tlvtype_proc tlvprochopopt_lst[] = {
> >         {
> >                 .type   = IPV6_TLV_ROUTERALERT,
> > @@ -612,6 +635,10 @@ static const struct tlvtype_proc tlvprochopopt_lst[] = {
> >                 .type   = IPV6_TLV_JUMBO,
> >                 .func   = ipv6_hop_jumbo,
> >         },
> > +       {
> > +               .type   = IPV6_TLV_CALIPSO,
> > +               .func   = ipv6_hop_calipso,
> > +       },
> >         { -1, }
> >  };
> >
> > --
> > 2.7.0
> >
> > --
> > To unsubscribe from this list: send the line "unsubscribe linux-security-module" in
> > the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
> > More majordomo info at  http://vger.kernel.org/majordomo-info.html
> 
> -- 
> paul moore
> www.paul-moore.com
_______________________________________________
Selinux mailing list
Selinux-+05T5uksL2qpZYMLLGbcSA@public.gmane.org
To unsubscribe, send email to Selinux-leave-+05T5uksL2pAGbPMOrvdOA@public.gmane.org
To get help, send an email containing "help" to Selinux-request-+05T5uksL2pAGbPMOrvdOA@public.gmane.org
