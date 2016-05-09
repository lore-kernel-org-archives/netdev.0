From: Paul Moore <paul@paul-moore.com>
Subject: Re: [RFC PATCH v3 17/19] calipso: Add validation of CALIPSO option.
Date: Mon, 9 May 2016 11:30:16 -0400
Message-ID: <CAHC9VhSQaoC7UX5__LRsG4Jx43mjD9xMu2KTS16oG5M8GDx9bQ@mail.gmail.com>
References: <1455715329-9601-18-git-send-email-huw@codeweavers.com>
	<CAHC9VhTRp8bHgwxZ2YNj=pa2a4PtO=8jJT1siG99GiFYnwm53Q@mail.gmail.com>
	<20160509103918.GC20123@merlot.physics.ox.ac.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: linux-security-module@vger.kernel.org, selinux@tycho.nsa.gov,
	Paul Moore <pmoore@redhat.com>
To: Huw Davies <huw@codeweavers.com>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-oi0-f49.google.com ([209.85.218.49]:36845 "EHLO
	mail-oi0-f49.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752197AbcEIPaS (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 9 May 2016 11:30:18 -0400
Received: by mail-oi0-f49.google.com with SMTP id x201so214472347oif.3
        for <netdev@vger.kernel.org>; Mon, 09 May 2016 08:30:17 -0700 (PDT)
In-Reply-To: <20160509103918.GC20123@merlot.physics.ox.ac.uk>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, May 9, 2016 at 6:39 AM, Huw Davies <huw@codeweavers.com> wrote:
> On Fri, May 06, 2016 at 06:59:32PM -0400, Paul Moore wrote:
>> On Wed, Feb 17, 2016 at 8:22 AM, Huw Davies <huw@codeweavers.com> wrote:
>> > We check lengths, checksum and the DOI.  We leave checking of the
>> > level and categories for the socket layer.
>> >
>> > Signed-off-by: Huw Davies <huw@codeweavers.com>
>> > ---
>> >  include/net/calipso.h |  6 ++++++
>> >  net/ipv6/calipso.c    | 42 ++++++++++++++++++++++++++++++++++++++++++
>> >  net/ipv6/exthdrs.c    | 27 +++++++++++++++++++++++++++
>> >  3 files changed, 75 insertions(+)
>> >
>> > diff --git a/include/net/calipso.h b/include/net/calipso.h
>> > index 38dbb47..85404e2 100644
>> > --- a/include/net/calipso.h
>> > +++ b/include/net/calipso.h
>> > @@ -65,6 +65,7 @@ struct calipso_doi {
>> >  #ifdef CONFIG_NETLABEL
>> >  int __init calipso_init(void);
>> >  void calipso_exit(void);
>> > +bool calipso_validate(const struct sk_buff *skb, const unsigned char *option);
>> >  #else
>> >  static inline int __init calipso_init(void)
>> >  {
>> > @@ -74,6 +75,11 @@ static inline int __init calipso_init(void)
>> >  static inline void calipso_exit(void)
>> >  {
>> >  }
>> > +static inline bool calipso_validate(const struct sk_buff *skb,
>> > +                                   const unsigned char *option)
>> > +{
>> > +       return true;
>> > +}
>> >  #endif /* CONFIG_NETLABEL */
>> >
>> >  #endif /* _CALIPSO_H */
>> > diff --git a/net/ipv6/calipso.c b/net/ipv6/calipso.c
>> > index fa371a8..b8bcf9f 100644
>> > --- a/net/ipv6/calipso.c
>> > +++ b/net/ipv6/calipso.c
>> > @@ -321,6 +321,48 @@ doi_walk_return:
>> >  }
>> >
>> >  /**
>> > + * calipso_validate - Validate a CALIPSO option
>> > + * @skb: the packet
>> > + * @option: the start of the option
>> > + *
>> > + * Description:
>> > + * This routine is called to validate a CALIPSO option.
>> > + * If the option is valid then a zero value is returned.  If the
>> > + * option is invalid then a non-zero value is returned and
>> > + * representing the offset to the offending portion of the option.
>> > + *
>> > + * The caller should have already checked that the length of the
>> > + * option (including the TLV header) is >= 10 and that the catmap
>> > + * length is consistent with the option length.
>> > + *
>> > + * We leave checks on the level and categories to the socket layer.
>> > + */
>> > +bool calipso_validate(const struct sk_buff *skb, const unsigned char *option)
>> > +{
>> > +       struct calipso_doi *doi_def;
>> > +       int ret_val;
>> > +       u16 crc, len = option[1] + 2;
>> > +       static const u8 zero[2];
>> > +
>> > +       /* The original CRC runs over the option including the TLV header
>> > +        * with the CRC-16 field (at offset 8) zeroed out. */
>> > +       crc = crc_ccitt(0xffff, option, 8);
>> > +       crc = crc_ccitt(crc, zero, sizeof(zero));
>> > +       if (len > 10)
>> > +               crc = crc_ccitt(crc, option + 10, len - 10);
>> > +       crc = ~crc;
>>
>> I should have caught this in the v2 patchset when I mentioned it with
>> respect to the CRC generation, but why not simply do 'crc =
>> ~crc_cccitt(...);'?
>
> Simply because the final crc_ccitt() is inside an if statement.
> Since len is guaranteed to be >= 10, I could dispense with the if and
> have crc_ccitt() handle having its final argument equal to zero (which
> it does just fine).  Then I could do as you suggest.

Yes, I get that it is in an if-conditional; I probably should have
been more specific.  I was thinking of something more like this:

  if (len > 10)
    crc = ~crc(crc, option + 10, ...);
  else
    crc = ~crc;

... although now that I've typed it out, I'm not sure it's an
improvement.  I would just ignore me ;)

>> Also, while I'm looking at this, why not do the CRC verification in
>> ipv6_hop_calipso()?  The only thing we should need to do here is the
>> DOI lookup/verification so that we still work correctly when
>> CONFIG_NETLABEL=n; all the core protocol stuff, e.g. length and
>> checksum validation, should be done in the core stack functions, e.g.
>> ipv6_hop_calipso().
>
> The only reason was to not bring in CONFIG_CRC_CCITT if CONFIG_NETLABEL=n
> (this is currently selected in net/netlabel/Kconfig).
>
> If folks are happy for me to do so, I could change this to:
> select CONFIG_CRC_CCITT
> under menuconfig IPV6
>
> Then the crc check could move to exthdrs.c:ipv6_hop_calipso().  Would
> that be ok?

Thanks, that explains it.

I think there is value in verifying the checksum, but I completely
understand if the netdev folks don't want to pull in the CRC_CCITT
code, especially since currently only a few network drivers/protocols
pull it into the build.

DaveM, your thoughts?

-- 
paul moore
www.paul-moore.com
