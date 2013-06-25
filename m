From: Jesse Gross <jesse@nicira.com>
Subject: Re: [ovs-dev] [PATCH] datapath: optimize flow compare and mask functions
Date: Mon, 24 Jun 2013 22:08:21 -0700
Message-ID: <CAEP_g=_a55zCfLtcnCo2wphJfUFhA9Eh0uAPcB441O_iEQgDMg@mail.gmail.com>
References: <1371904368-32642-1-git-send-email-azhou@nicira.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: "dev@openvswitch.com" <dev@openvswitch.com>,
	Peter Klausler <pmk@google.com>,
	Eric Dumazet <eric.dumazet@gmail.com>,
	netdev <netdev@vger.kernel.org>
To: Andy Zhou <azhou@nicira.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from na3sys009aog114.obsmtp.com ([74.125.149.211]:35143 "HELO
	na3sys009aog114.obsmtp.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with SMTP id S1750741Ab3FYFIo (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 25 Jun 2013 01:08:44 -0400
Received: by mail-la0-f50.google.com with SMTP id dy20so11369560lab.9
        for <netdev@vger.kernel.org>; Mon, 24 Jun 2013 22:08:42 -0700 (PDT)
In-Reply-To: <1371904368-32642-1-git-send-email-azhou@nicira.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Please CC the original author and people that participated in the discussion.

On Sat, Jun 22, 2013 at 5:32 AM, Andy Zhou <azhou@nicira.com> wrote:
> For architectures can load and store unaligned long efficiently, use 4
> or 8 bytes operations. This improves the efficiency compare to byte wise
> operations.
>
> This patch is uses ideas and code from a patch submitted by Peter Klausler
> titled "replace memcmp() with specialized comparator". The flow compare
> function is essentially his implementation.  The original patch
> mentioned 7X speed up with this optimization.
>
> Co-authored-by: Peter Klausler <pmk@google.com>
> Signed-off-by: Andy Zhou <azhou@nicira.com>
> ---
>  datapath/flow.c |   55 +++++++++++++++++++++++++++++++++++++++++++++----------
>  1 file changed, 45 insertions(+), 10 deletions(-)
>
> diff --git a/datapath/flow.c b/datapath/flow.c
> index 39de931..273cbea 100644
> --- a/datapath/flow.c
> +++ b/datapath/flow.c
> @@ -45,6 +45,13 @@
>
>  #include "vlan.h"
>
> +#ifdef CONFIG_HAVE_EFFICIENT_UNALIGNED_ACCESS
> +#define ADDR_IS_ALIGNED(addr)  1
> +#else
> +#define ADDR_IS_ALIGNED(addr)  \
> +           ((long) addr & (sizeof(long) - 1) == 0)
> +#endif
> +
>  static struct kmem_cache *flow_cache;
>
>  static void ovs_sw_flow_mask_set(struct sw_flow_mask *mask,
> @@ -343,16 +350,26 @@ static void flow_key_mask(struct sw_flow_key *dst,
>                           const struct sw_flow_key *src,
>                           const struct sw_flow_mask *mask)
>  {
> -       u8 *m = (u8 *)&mask->key + mask->range.start;
> -       u8 *s = (u8 *)src + mask->range.start;
> -       u8 *d = (u8 *)dst + mask->range.start;
> -       int i;
> +       const u8 *m = (u8 *)&mask->key;
> +       const u8 *s = (u8 *)src;
> +       u8 *d = (u8 *)dst;
> +       int len = sizeof(*dst);
>
> -       memset(dst, 0, sizeof(*dst));
> -       for (i = 0; i < ovs_sw_flow_mask_size_roundup(mask); i++) {
> -               *d = *s & *m;
> -               d++, s++, m++;
> +       if (ADDR_IS_ALIGNED((m | s | d))) {
> +               const long *ml = (const long *)m;
> +               const long *sl = (const long *)s;
> +               long *dl = (long *)d;
> +
> +               for (; len >= sizeof(long); len -= sizeof(long))
> +                       *dl++ = *sl++ & *ml++;
> +
> +               m = (const u8 *)ml;
> +               s = (const u8 *)sl;
> +               d = (u8 *)dl;
>         }
> +
> +       while (len-- > 0)
> +               *d++ = *s++ & *m++;
>  }
>
>  #define TCP_FLAGS_OFFSET 13
> @@ -984,8 +1001,26 @@ static int flow_key_start(const struct sw_flow_key *key)
>  static bool __cmp_key(const struct sw_flow_key *key1,
>                 const struct sw_flow_key *key2,  int key_start, int key_len)
>  {
> -       return !memcmp((u8 *)key1 + key_start,
> -                       (u8 *)key2 + key_start, (key_len - key_start));
> +       const u8 *cp1 = (u8 *)key1 + key_start;
> +       const u8 *cp2 = (u8 *)key2 + key_start;
> +       int len = key_len - key_start;
> +       long diffs = 0;
> +
> +       if (ADDR_IS_ALIGNED(cp1 | cp2)) {
> +               const long *lp1 = (const long *)cp1;
> +               const long *lp2 = (const long *)cp2;
> +
> +               for (; len >= sizeof(long); len -= sizeof(long))
> +                       diffs |= *lp1++ ^ *lp2++;
> +
> +               cp1 = (const u8 *)lp1;
> +               cp2 = (const u8 *)lp2;
> +       }
> +
> +       while (len-- > 0)
> +               diffs |= *cp1++ ^ *cp2++;
> +
> +       return diffs == 0;
>  }
>
>  static bool __flow_cmp_key(const struct sw_flow *flow,
> --
> 1.7.9.5
>
> _______________________________________________
> dev mailing list
> dev@openvswitch.org
> http://openvswitch.org/mailman/listinfo/dev
