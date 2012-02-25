From: Paul Gortmaker <paul.gortmaker@windriver.com>
Subject: Re: RFC: memory leak in udp_table_init
Date: Fri, 24 Feb 2012 20:27:16 -0500
Message-ID: <CAP=VYLp7+Apubm=PHRLSw50V9zBKmV-xFRvcO4-qAogJVp7jcw@mail.gmail.com>
References: <4F48318E.8070902@am.sony.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Miller <davem@davemloft.net>, kuznet@ms2.inr.ac.ru,
	linux kernel <linux-kernel@vger.kernel.org>,
	netdev@vger.kernel.org, eric.dumazet@gmail.com
To: Tim Bird <tim.bird@am.sony.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <4F48318E.8070902@am.sony.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, Feb 24, 2012 at 7:55 PM, Tim Bird <tim.bird@am.sony.com> wrote:
> We've uncovered an obscure memory leak in the routine udp_table_init(=
),
> in the file: net/ipv4/udp.c

At a glance, I think what you are seeing is the same as this?

http://lists.openwall.net/netdev/2011/06/22/12

Paul.

>
> The allocation sequence is a bit weird, and I've got some questions
> about the best way to fix it.
>
> Here's the code:
>
> void __init udp_table_init(struct udp_table *table, const char *name)
> {
> =A0 =A0 =A0 =A0unsigned int i;
>
> =A0 =A0 =A0 =A0if (!CONFIG_BASE_SMALL)
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0table->hash =3D alloc_large_system_has=
h(name,
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A02 * sizeof(struct udp_=
hslot),
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0uhash_entries,
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A021, /* one slot per 2 =
MB */
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A00,
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0&table->log,
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0&table->mask,
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A064 * 1024);
> =A0 =A0 =A0 =A0/*
> =A0 =A0 =A0 =A0 * Make sure hash table has the minimum size
> =A0 =A0 =A0 =A0 */
> =A0 =A0 =A0 =A0if (CONFIG_BASE_SMALL || table->mask < UDP_HTABLE_SIZE=
_MIN - 1) {
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0table->hash =3D kmalloc(UDP_HTABLE_SIZ=
E_MIN *
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0=
 =A02 * sizeof(struct udp_hslot), GFP_KERNEL);
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0if (!table->hash)
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0panic(name);
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0table->log =3D ilog2(UDP_HTABLE_SIZE_M=
IN);
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0table->mask =3D UDP_HTABLE_SIZE_MIN - =
1;
> =A0 =A0 =A0 =A0}
> =A0 =A0 =A0 =A0...
>
> We've seen instances where the second allocation of table->hash
> is performed, wiping out the first hash table allocation, without a
> free. =A0This ends up leaking the previously allocated hash table.
>
> That is, if we are !CONFIG_BASE_SMALL and for some reason
> the alloc_large_system_hash() operation returns less than UDP_HTABLE_=
SIZE_MIN
> hash slots, then it will trigger this.
>
> There's no complementary "free_large_system_hash()" which can be used=
 to
> back out of the first allocation, that I can find.
>
> We are currently doing the following to avoid the memory leak, but th=
is
> seems like it defeats the purpose of checking for the minimum size
> (that is, if the first allocation was too small, we don't re-allocate=
).
>
> diff --git a/net/ipv4/udp.c b/net/ipv4/udp.c
> index 5d075b5..2524af4 100644
> --- a/net/ipv4/udp.c
> +++ b/net/ipv4/udp.c
> @@ -2194,7 +2194,8 @@ void __init udp_table_init(struct udp_table *ta=
ble, const char *name)
> =A0 =A0 =A0 =A0/*
> =A0 =A0 =A0 =A0 * Make sure hash table has the minimum size
> =A0 =A0 =A0 =A0 */
> - =A0 =A0 =A0 if (CONFIG_BASE_SMALL || table->mask < UDP_HTABLE_SIZE_=
MIN - 1) {
> + =A0 =A0 =A0 if ((CONFIG_BASE_SMALL || table->mask < UDP_HTABLE_SIZE=
_MIN - 1)
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 && !table->hash) {
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0table->hash =3D kmalloc(UDP_HTABLE_SIZ=
E_MIN *
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0=
 =A02 * sizeof(struct udp_hslot), GFP_KERNEL);
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0if (!table->hash)
>
> Any suggestions for a way to correct for a too-small first allocation=
, without
> a memory leak?
>
> Alternatively - how critical is this UDP_HTABLE_SIZE_MIN for correct =
operation
> of the stack?
>
> Thanks for any information you can provide.
>
> =A0-- Tim
>
> =3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D
> Tim Bird
> Architecture Group Chair, CE Workgroup of the Linux Foundation
> Senior Staff Engineer, Sony Network Entertainment
> =3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D
>
> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at =A0http://vger.kernel.org/majordomo-info.html
