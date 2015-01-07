From: Alexei Starovoitov <alexei.starovoitov@gmail.com>
Subject: Re: [PATCH 2/6] vxlan: Group Policy extension
Date: Wed, 7 Jan 2015 15:39:42 -0800
Message-ID: <CAADnVQLKFFP4605fuirsU7KUf6te7U2_0-WcMj8ijwmfJ7oGog@mail.gmail.com>
References: <CAADnVQJErdNJrXOOSqEqkbC8524VCH2E9vYL-WdTb_6SGsTwvw@mail.gmail.com>
 <20150107232740.GE21149@casper.infradead.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: "David S. Miller" <davem@davemloft.net>,
	Jesse Gross <jesse@nicira.com>,
	Stephen Hemminger <stephen@networkplumber.org>,
	Pravin Shelar <pshelar@nicira.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"dev@openvswitch.org" <dev@openvswitch.org>
To: Thomas Graf <tgraf@suug.ch>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qa0-f51.google.com ([209.85.216.51]:37330 "EHLO
	mail-qa0-f51.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755166AbbAGXkD (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 7 Jan 2015 18:40:03 -0500
Received: by mail-qa0-f51.google.com with SMTP id i13so5046376qae.10
        for <netdev@vger.kernel.org>; Wed, 07 Jan 2015 15:40:02 -0800 (PST)
In-Reply-To: <20150107232740.GE21149@casper.infradead.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Jan 7, 2015 at 3:27 PM, Thomas Graf <tgraf@suug.ch> wrote:
>
> Would you like something like this?

yes. imo this version is much easier to read
and reason about different bits in protocol.

May be even use a flag mask on '__be32 vx_flags'
instead of calling out 'gbp_present' as explicit bitfield.
Then different vxlan extensions proposals don't
have to fight over positions in the first byte of
single 'struct vxlanhdr'...
but to me the below two structs look good as-is.

>  struct vxlanhdr_gbp {
>         __u8 vx_flags;
> +#ifdef __LITTLE_ENDIAN_BITFIELD
> +       __u8    reserved_flags1:3,
> +               policy_applied:1,
> +               reserved_flags2:2,
> +               dont_learn:1,
> +               reserved_flags3:1;
> +#elif defined(__BIG_ENDIAN_BITFIELD)
> +       __u8    reserved_flags1:1,
> +               dont_learn:1,
> +               reserved_flags2:2,
> +               policy_applied:1,
> +               reserved_flags3:3;
> +#else
> +#error "Please fix <asm/byteorder.h>"
> +#endif
> +       __be16 policy_id;
> +       __be32  vx_vni;
>  };
>
>  struct vxlanhdr {
> +       union {
> +               struct {
> +#ifdef __LITTLE_ENDIAN_BITFIELD
> +                       __u8    reserved_flags1:3,
> +                               vni_present:1,
> +                               reserved_flags2:3,
> +                               gbp_present:1;
> +#elif defined(__BIG_ENDIAN_BITFIELD)
> +                       __u8    gbp_present:1,
> +                               reserved_flags2:3,
> +                               vni_present:1,
> +                               reserved_flags1:3;
> +#else
> +#error "Please fix <asm/byteorder.h>"
> +#endif
> +                       __u8    vx_reserved1;
> +                       __be16  vx_reserved2;
> +               };
> +               __be32 vx_flags;
> +       };
> +       __be32  vx_vni;
>  };
>
