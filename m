From: Geert Uytterhoeven <geert@linux-m68k.org>
Subject: Division by zero on UP (was: Re: netfilter: nat: use keyed locks)
Date: Sun, 10 Sep 2017 13:08:43 +0200
Message-ID: <CAMuHMdVwp1njkMYo-y8FZHWNWW6wtN2LYVC=9-mbcF-omDaztw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
        "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
        "David S. Miller" <davem@davemloft.net>,
        Arnd Bergmann <arnd@arndb.de>
To: Florian Westphal <fw@strlen.de>,
        Pablo Neira Ayuso <pablo@netfilter.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f194.google.com ([209.85.192.194]:36441 "EHLO
        mail-pf0-f194.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750810AbdIJLIo (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sun, 10 Sep 2017 07:08:44 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Florian, Pablo,

On Sat, Sep 9, 2017 at 9:21 PM, Linux Kernel Mailing List
<linux-kernel@vger.kernel.org> wrote:
> Web:        https://git.kernel.org/torvalds/c/8073e960a03bf7b5d5ebfc5ff18=
ac475e1688f46
> Commit:     8073e960a03bf7b5d5ebfc5ff18ac475e1688f46
> Parent:     e1bf1687740ce1a3598a1c5e452b852ff2190682
> Refname:    refs/heads/master
> Author:     Florian Westphal <fw@strlen.de>
> AuthorDate: Wed Sep 6 14:39:52 2017 +0200
> Committer:  Pablo Neira Ayuso <pablo@netfilter.org>
> CommitDate: Fri Sep 8 18:55:52 2017 +0200
>
>     netfilter: nat: use keyed locks
>
>     no need to serialize on a single lock, we can partition the table and
>     add/delete in parallel to different slots.
>     This restores one of the advantages that got lost with the rhlist
>     revert.
>
>     Cc: Ivan Babrou <ibobrik@gmail.com>
>     Signed-off-by: Florian Westphal <fw@strlen.de>
>     Signed-off-by: Pablo Neira Ayuso <pablo@netfilter.org>
> ---
>  net/netfilter/nf_nat_core.c | 36 ++++++++++++++++++++++++------------
>  1 file changed, 24 insertions(+), 12 deletions(-)
>
> diff --git a/net/netfilter/nf_nat_core.c b/net/netfilter/nf_nat_core.c
> index f090419f5f97..f393a7086025 100644
> --- a/net/netfilter/nf_nat_core.c
> +++ b/net/netfilter/nf_nat_core.c
> @@ -30,7 +30,7 @@
>  #include <net/netfilter/nf_conntrack_zones.h>
>  #include <linux/netfilter/nf_nat.h>
>
> -static DEFINE_SPINLOCK(nf_nat_lock);
> +static spinlock_t nf_nat_locks[CONNTRACK_LOCKS];
>
>  static DEFINE_MUTEX(nf_nat_proto_mutex);
>  static const struct nf_nat_l3proto __rcu *nf_nat_l3protos[NFPROTO_NUMPRO=
TO]
> @@ -425,13 +425,15 @@ nf_nat_setup_info(struct nf_conn *ct,
>
>         if (maniptype =3D=3D NF_NAT_MANIP_SRC) {
>                 unsigned int srchash;
> +               spinlock_t *lock;
>
>                 srchash =3D hash_by_src(net,
>                                       &ct->tuplehash[IP_CT_DIR_ORIGINAL].=
tuple);
> -               spin_lock_bh(&nf_nat_lock);
> +               lock =3D &nf_nat_locks[srchash % ARRAY_SIZE(nf_nat_locks)=
];
> +               spin_lock_bh(lock);

If no spinlock debugging options (CONFIG_GENERIC_LOCKBREAK,
CONFIG_DEBUG_SPINLOCK, CONFIG_DEBUG_LOCK_ALLOC) are enabled on a UP platfor=
m
(e.g. m68k defconfig), arch_spinlock_t is an empty struct, and thus
ARRAY_SIZE(nf_nat_locks)] is zero, leading to:

    net/netfilter/nf_nat_core.c: In function =E2=80=98nf_nat_setup_info=E2=
=80=99:
    net/netfilter/nf_nat_core.c:432: warning: division by zero
    net/netfilter/nf_nat_core.c: In function =E2=80=98__nf_nat_cleanup_conn=
track=E2=80=99:
    net/netfilter/nf_nat_core.c:535: warning: division by zero
    net/netfilter/nf_nat_core.c:537: warning: division by zero
    net/netfilter/nf_nat_core.c: In function =E2=80=98nf_nat_init=E2=80=99:
    net/netfilter/nf_nat_core.c:810: warning: division by zero
    net/netfilter/nf_nat_core.c:811: warning: division by zero
    net/netfilter/nf_nat_core.c:824: warning: division by zero

Gr{oetje,eeting}s,

                        Geert
