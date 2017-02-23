From: Geert Uytterhoeven <geert@linux-m68k.org>
Subject: Re: netfilter: nft_ct: add zone id set support
Date: Thu, 23 Feb 2017 10:54:54 +0100
Message-ID: <CAMuHMdUJ=2+9ko0KEU7rX3rb7vghNj3Xc-HSLSK=-kqQ+CZM6w@mail.gmail.com>
References: <20170222190219.EC87B661B65@gitolite.kernel.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: quoted-printable
Cc: Jozsef Kadlecsik <kadlec@blackhole.kfki.hu>,
        "David S. Miller" <davem@davemloft.net>,
        netfilter-devel@vger.kernel.org, coreteam@netfilter.org,
        "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
        Linux Kernel Mailing List <linux-kernel@vger.kernel.org>
To: Florian Westphal <fw@strlen.de>,
        Pablo Neira Ayuso <pablo@netfilter.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20170222190219.EC87B661B65@gitolite.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi Florian,

On Wed, Feb 22, 2017 at 8:02 PM, Linux Kernel Mailing List
<linux-kernel@vger.kernel.org> wrote:
> Web:        https://git.kernel.org/torvalds/c/edee4f1e92458299505ff007733=
f676b00c516a1
> Commit:     edee4f1e92458299505ff007733f676b00c516a1
> Parent:     5c178d81b69f08ca3195427a6ea9a46d9af23127
> Refname:    refs/heads/master
> Author:     Florian Westphal <fw@strlen.de>
> AuthorDate: Fri Feb 3 13:35:50 2017 +0100
> Committer:  Pablo Neira Ayuso <pablo@netfilter.org>
> CommitDate: Wed Feb 8 14:16:23 2017 +0100
>
>     netfilter: nft_ct: add zone id set support
>
>     zones allow tracking multiple connections sharing identical tuples,
>     this is needed e.g. when tracking distinct vlans with overlapping ip
>     addresses (conntrack is l2 agnostic).
>
>     Thus the zone has to be set before the packet is picked up by the
>     connection tracker.  This is done by means of 'conntrack templates' w=
hich
>     are conntrack structures used solely to pass this info from one netfi=
lter
>     hook to the next.
>
>     The iptables CT target instantiates these connection tracking templat=
es
>     once per rule, i.e. the template is fixed/tied to particular zone, ca=
n
>     be read-only and therefore be re-used by as many skbs simultaneously =
as
>     needed.
>
>     We can't follow this model because we want to take the zone id from
>     an sreg at rule eval time so we could e.g. fill in the zone id from
>     the packets vlan id or a e.g. nftables key : value maps.
>
>     To avoid cost of per packet alloc/free of the template, use a percpu
>     template 'scratch' object and use the refcount to detect the (unlikel=
y)
>     case where the template is still attached to another skb (i.e., previ=
ous
>     skb was nfqueued ...).
>
>     Signed-off-by: Florian Westphal <fw@strlen.de>
>     Signed-off-by: Pablo Neira Ayuso <pablo@netfilter.org>

> --- a/net/netfilter/nft_ct.c
> +++ b/net/netfilter/nft_ct.c

> @@ -407,6 +503,7 @@ static int nft_ct_set_init(const struct nft_ctx *ctx,
>         unsigned int len;

With gcc-4.1.2 and -Os:

    net/netfilter/nft_ct.c: In function =E2=80=98nft_ct_set_init=E2=80=99:
    net/netfilter/nft_ct.c:503: warning: =E2=80=98len=E2=80=99 may be used
uninitialized in this function

>         int err;
>
> +       priv->dir =3D IP_CT_DIR_MAX;
>         priv->key =3D ntohl(nla_get_be32(tb[NFTA_CT_KEY]));
>         switch (priv->key) {
>  #ifdef CONFIG_NF_CONNTRACK_MARK
> @@ -426,10 +523,28 @@ static int nft_ct_set_init(const struct nft_ctx *ct=
x,
>                         return err;
>                 break;
>  #endif
> +#ifdef CONFIG_NF_CONNTRACK_ZONES
> +       case NFT_CT_ZONE:
> +               if (!nft_ct_tmpl_alloc_pcpu())
> +                       return -ENOMEM;
> +               nft_ct_pcpu_template_refcnt++;

Unlike for the other cases of the switch statement, "len" is not initialize=
d
here...

> +               break;
> +#endif
>         default:
>                 return -EOPNOTSUPP;
>         }
>
> +       if (tb[NFTA_CT_DIRECTION]) {
> +               priv->dir =3D nla_get_u8(tb[NFTA_CT_DIRECTION]);
> +               switch (priv->dir) {
> +               case IP_CT_DIR_ORIGINAL:
> +               case IP_CT_DIR_REPLY:
> +                       break;
> +               default:
> +                       return -EINVAL;
> +               }
> +       }
> +
>         priv->sreg =3D nft_parse_register(tb[NFTA_CT_SREG]);
>         err =3D nft_validate_register_load(priv->sreg, len);

... and used here, which may lead to spurious failures of
nft_validate_register_load().

Gr{oetje,eeting}s,

                        Geert

--
Geert Uytterhoeven -- There's lots of Linux beyond ia32 -- geert@linux-m68k=
.org

In personal conversations with technical people, I call myself a hacker. Bu=
t
when I'm talking to journalists I just say "programmer" or something like t=
hat.
                                -- Linus Torvalds
