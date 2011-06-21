From: Joe Perches <joe@perches.com>
Subject: Re: [PATCH] gianfar v5: implement nfc
Date: Tue, 21 Jun 2011 10:44:13 -0700
Message-ID: <1308678253.3338.13.camel@Joe-Laptop>
References: <1308562782.12794.6.camel@DENEC1DT0191>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Linux Netdev <netdev@vger.kernel.org>,
	Sebastian =?ISO-8859-1?Q?P=F6hn?= <sebastian.poehn@belden.com>
To: Sebastian =?ISO-8859-1?Q?P=F6hn?=
	<sebastian.belden@googlemail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.perches.com ([173.55.12.10]:3106 "EHLO mail.perches.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756977Ab1FURoO (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 21 Jun 2011 13:44:14 -0400
In-Reply-To: <1308562782.12794.6.camel@DENEC1DT0191>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 2011-06-20 at 11:39 +0200, Sebastian P=C3=B6hn wrote:
> This patch adds all missing functionalities for nfc except GRXFH. The=
re is so much code because hardware has not a TCAM.
> Further hardware rule space is very limited. So I had to extensively =
use
> optimization features. Both reasons lead to the necessity to hold all
> online flows in a linked-list.
> Signed-off-by: Sebastian Poehn <sebastian.poehn@belden.com>

Just a bit more trivia...

[]

> +/* Swaps the 0xFF80 masked bits of a1<>a2 and b1<>b2 */
> +static void gfar_swap_ff80_bits(struct gfar_filer_entry *a1,
> +		struct gfar_filer_entry *a2, struct gfar_filer_entry *b1,
> +		struct gfar_filer_entry *b2)
> +{
> +	u32 temp[4];
> +	temp[0] =3D a1->ctrl & 0xFF80;
> +	temp[1] =3D a2->ctrl & 0xFF80;
> +	temp[2] =3D b1->ctrl & 0xFF80;
> +	temp[3] =3D b2->ctrl & 0xFF80;
> +
> +	a1->ctrl &=3D ~0xFF80;
> +	a2->ctrl &=3D ~0xFF80;
> +	b1->ctrl &=3D ~0xFF80;
> +	b2->ctrl &=3D ~0xFF80;
> +
> +	a1->ctrl |=3D temp[1];
> +	a2->ctrl |=3D temp[0];
> +	b1->ctrl |=3D temp[3];
> +	b2->ctrl |=3D temp[2];
> +}

maybe add a macro similar to swap:

#define swap_bits(a, b, bits)			\
do {						\
	typeof(a) _bits =3D bits;			\
	typeof(a) _a_bits =3D (a) & _bits;	\
	typeof(a) _b_bits =3D (b) & _bits;	\
						\
	(a) &=3D ~_bits;				\
	(b) &=3D ~_bits;				\
						\
	(a) |=3D _b_bits;				\
	(b) |=3D _a_bits;				\
} while (0)

and use this macro directly in gfar_sort_mask_table?

	swap_bits(temp_table->fe[new_first],
		  temp_table->fe[old_first], 0xff80);
	swap_bits(temp_table->fe[new_last],
		  temp_table->fe[old_last], 0xff80);

And maybe 0xff80 should be a #define?


