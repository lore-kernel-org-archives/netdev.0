From: Alexander Duyck <alexander.duyck@gmail.com>
Subject: Re: [PATCH v3] net:Add sysctl_max_skb_frags
Date: Wed, 3 Feb 2016 07:58:01 -0800
Message-ID: <CAKgT0UftR3pTOGO91GaUijPCTq8POQcNChRqyy1b1TYsM3n4Uw@mail.gmail.com>
References: <568F87AC.60405@oracle.com>
	<1454488017-8822-1-git-send-email-hans.westgaard.ry@oracle.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: "David S. Miller" <davem@davemloft.net>,
	Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>,
	James Morris <jmorris@namei.org>,
	Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>,
	Patrick McHardy <kaber@trash.net>,
	Tom Herbert <tom@herbertland.com>,
	Pablo Neira Ayuso <pablo@netfilter.org>,
	Eric Dumazet <edumazet@google.com>,
	Florian Westphal <fw@strlen.de>, Jiri Pirko <jiri@resnulli.us>,
	Alexander Duyck <alexander.h.duyck@redhat.com>,
	Michal Hocko <mhocko@suse.com>,
	=?UTF-8?Q?Linus_L=C3=BCssing?= <linus.luessing@c0d3.blue>,
	Hannes Frederic Sowa <hannes@stressinduktion.org>,
	Herbert Xu <herbert@gondor.apana.org.au>,
	Tejun Heo <tj@kernel.org>,
	Andrew Morton <akpm@linux-foundation.org>,
	Alexey Kodanev <alexey.kodanev@oracle.com>,
	=?UTF-8?B?SMOla29uIEJ1Z2dl?= <haakon.bugge@oracle.com>,
	open list <linux-kernel@vger.kernel.org>,
	"open list:NETWORKING [GENERAL]" <netdev@vger.kernel.org>
To: Hans Westgaard Ry <hans.westgaard.ry@oracle.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1454488017-8822-1-git-send-email-hans.westgaard.ry@oracle.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, Feb 3, 2016 at 12:26 AM, Hans Westgaard Ry
<hans.westgaard.ry@oracle.com> wrote:
> Devices may have limits on the number of fragments in an skb they sup=
port.
> Current codebase uses a constant as maximum for number of fragments o=
ne
> skb can hold and use.
> When enabling scatter/gather and running traffic with many small mess=
ages
> the codebase uses the maximum number of fragments and may thereby vio=
late
> the max for certain devices.
> The patch introduces a global variable as max number of fragments.
>
> Signed-off-by: Hans Westgaard Ry <hans.westgaard.ry@oracle.com>
> Reviewed-by: H=C3=A5kon Bugge <haakon.bugge@oracle.com>
>
> ---
>  include/linux/skbuff.h     |  1 +
>  net/core/skbuff.c          |  2 ++
>  net/core/sysctl_net_core.c | 10 ++++++++++
>  net/ipv4/tcp.c             |  4 ++--
>  4 files changed, 15 insertions(+), 2 deletions(-)
>
> diff --git a/include/linux/skbuff.h b/include/linux/skbuff.h
> index 4355129..fe47ad3 100644
> --- a/include/linux/skbuff.h
> +++ b/include/linux/skbuff.h
> @@ -219,6 +219,7 @@ struct sk_buff;
>  #else
>  #define MAX_SKB_FRAGS (65536/PAGE_SIZE + 1)
>  #endif
> +extern int sysctl_max_skb_frags;
>
>  typedef struct skb_frag_struct skb_frag_t;
>
> diff --git a/net/core/skbuff.c b/net/core/skbuff.c
> index 152b9c7..c336b97 100644
> --- a/net/core/skbuff.c
> +++ b/net/core/skbuff.c
> @@ -79,6 +79,8 @@
>
>  struct kmem_cache *skbuff_head_cache __read_mostly;
>  static struct kmem_cache *skbuff_fclone_cache __read_mostly;
> +int sysctl_max_skb_frags __read_mostly =3D MAX_SKB_FRAGS;
> +EXPORT_SYMBOL(sysctl_max_skb_frags);
>
>  /**
>   *     skb_panic - private function for out-of-line support
> diff --git a/net/core/sysctl_net_core.c b/net/core/sysctl_net_core.c
> index 95b6139..a6beb7b 100644
> --- a/net/core/sysctl_net_core.c
> +++ b/net/core/sysctl_net_core.c

I really don't think these changes belong in the core. Below you only
modify the TCP code path so this more likely belongs in the TCP path
unless you are going to guarantee that all other code paths obey the
sysctl.  It probably belongs in net/ipv4/sysctl_net_ipv4.c

> @@ -26,6 +26,7 @@ static int zero =3D 0;
>  static int one =3D 1;
>  static int min_sndbuf =3D SOCK_MIN_SNDBUF;
>  static int min_rcvbuf =3D SOCK_MIN_RCVBUF;
> +static int max_skb_frags =3D MAX_SKB_FRAGS;
>
>  static int net_msg_warn;       /* Unused, but still a sysctl */
>
> @@ -392,6 +393,15 @@ static struct ctl_table net_core_table[] =3D {
>                 .mode           =3D 0644,
>                 .proc_handler   =3D proc_dointvec
>         },
> +       {
> +               .procname       =3D "max_skb_frags",
> +               .data           =3D &sysctl_max_skb_frags,
> +               .maxlen         =3D sizeof(int),
> +               .mode           =3D 0644,
> +               .proc_handler   =3D proc_dointvec_minmax,
> +               .extra1         =3D &one,
> +               .extra2         =3D &max_skb_frags,
> +       },
>         { }
>  };

I'm not really a fan of this name either.  Maybe it should be
something like tcp_max_gso_frags.

> diff --git a/net/ipv4/tcp.c b/net/ipv4/tcp.c
> index c82cca1..3dc7a2fd 100644
> --- a/net/ipv4/tcp.c
> +++ b/net/ipv4/tcp.c
> @@ -938,7 +938,7 @@ new_segment:
>
>                 i =3D skb_shinfo(skb)->nr_frags;
>                 can_coalesce =3D skb_can_coalesce(skb, i, page, offse=
t);
> -               if (!can_coalesce && i >=3D MAX_SKB_FRAGS) {
> +               if (!can_coalesce && i >=3D sysctl_max_skb_frags) {
>                         tcp_mark_push(tp, skb);
>                         goto new_segment;
>                 }
> @@ -1211,7 +1211,7 @@ new_segment:
>
>                         if (!skb_can_coalesce(skb, i, pfrag->page,
>                                               pfrag->offset)) {
> -                               if (i =3D=3D MAX_SKB_FRAGS || !sg) {
> +                               if (i =3D=3D sysctl_max_skb_frags || =
!sg) {
>                                         tcp_mark_push(tp, skb);
>                                         goto new_segment;
>                                 }

This bit looks good.

I was wondering.  Have you considered looking at something like what
was done with gso_max_size?  It seems like it is meant to address a
problem similar to what you have described where the NICs only support
a certain layout for the GSO frame.  Though now that I look over the
code it seems like it might be flawed in that I don't see bridges or
tunnels really respecting the value so it seems like they could cause
issues.

- Alex
