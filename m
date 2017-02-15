From: Or Gerlitz <gerlitz.or@gmail.com>
Subject: Re: [PATCH net-next V3 3/7] net/sched: Reflect HW offload status
Date: Wed, 15 Feb 2017 18:19:17 +0200
Message-ID: <CAJ3xEMg32qMp0Hh+BQbHdoMCKwX_ivvZVwo30njvXubR7ZQ8xA@mail.gmail.com>
References: <1487148757-24809-1-git-send-email-ogerlitz@mellanox.com> <1487148757-24809-4-git-send-email-ogerlitz@mellanox.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Jakub Kicinski <jakub.kicinski@netronome.com>,
        John Fastabend <john.r.fastabend@intel.com>,
        Roi Dayan <roid@mellanox.com>,
        Linux Netdev List <netdev@vger.kernel.org>,
        Hadar Hen Zion <hadarh@mellanox.com>,
        Amir Vadai <amir@vadai.me>, Ido Schimmel <idosch@mellanox.com>
To: David Miller <davem@davemloft.net>,
        Jamal Hadi Salim <jhs@mojatatu.com>,
        Jiri Pirko <jiri@mellanox.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ot0-f195.google.com ([74.125.82.195]:35518 "EHLO
        mail-ot0-f195.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751802AbdBOQTS (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 15 Feb 2017 11:19:18 -0500
Received: by mail-ot0-f195.google.com with SMTP id y13so1251327oty.2
        for <netdev@vger.kernel.org>; Wed, 15 Feb 2017 08:19:18 -0800 (PST)
In-Reply-To: <1487148757-24809-4-git-send-email-ogerlitz@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Feb 15, 2017 at 10:52 AM, Or Gerlitz <ogerlitz@mellanox.com> wrote:
> Currently there is no way of querying whether a filter is
> offloaded to HW or not when using "both" policy (where none
> of skip_sw or skip_hw flags are set by user-space).

> Add two new flags, "in hw" and "not in hw" such that user
> space can determine if a filter is actually offloaded to
> hw or not. The "in hw" UAPI semantics was chosen so it's
> similar to the "skip hw" flag logic.

To make things a bit more clear, the semantics of the "in hw"
thing relates to the time of dumping the rule.

Currently in all of the offloading drivers/cases, when the driver returns
success for the ndo_setup_tc call, the flow is offloaded to hw.

But moving fwd that might change, a flow might be not offloaded to HW
on some window of time.

The coming up example, is support for neigh updates w.r.t to IP tunnel
encapsulation offloads in mlx5 SRIOV switchdev mode.

Today we offload tunnel encap flow only if the kernel has valid neigh
to the tunnel destination. Under the works is a code to offload/un-offload
the flow to/from HW when the neigh becomes valid/invalid or goes through
hardware address change etc.

So what I basically suggest here is to enhance that future mlx5 series
with patches
under which the dump code of all the classifiers will invoke the
tc_setup_ndo with
a fourth sub command (today there are add/del/stats) which will return
the actual
"in hw" status.

This is aligned with the general architecture/approach in the kernel
for switchdev and other
offloads.

Note that this future change doesn't change the UAPI, it will still
have two values, "in hw"
and "not in hw". The values with this series are the actual values and
later with that change,
they will keep being the actual values, just the kernel method to
retrieve them will be different.


Or.

> If none of these two flags are set, this signals running
> over older kernel.

> Signed-off-by: Or Gerlitz <ogerlitz@mellanox.com>
> Reviewed-by: Amir Vadai <amir@vadai.me>
> Acked-by: Jiri Pirko <jiri@mellanox.com>
> ---
>  include/net/pkt_cls.h        | 5 +++++
>  include/uapi/linux/pkt_cls.h | 6 ++++--
>  2 files changed, 9 insertions(+), 2 deletions(-)
>
> diff --git a/include/net/pkt_cls.h b/include/net/pkt_cls.h
> index 71b266c..15cfe15 100644
> --- a/include/net/pkt_cls.h
> +++ b/include/net/pkt_cls.h
> @@ -475,6 +475,11 @@ static inline bool tc_flags_valid(u32 flags)
>         return true;
>  }
>
> +static inline bool tc_in_hw(u32 flags)
> +{
> +       return (flags & TCA_CLS_FLAGS_IN_HW) ? true : false;
> +}
> +
>  enum tc_fl_command {
>         TC_CLSFLOWER_REPLACE,
>         TC_CLSFLOWER_DESTROY,
> diff --git a/include/uapi/linux/pkt_cls.h b/include/uapi/linux/pkt_cls.h
> index 345551e..7a69f2a 100644
> --- a/include/uapi/linux/pkt_cls.h
> +++ b/include/uapi/linux/pkt_cls.h
> @@ -103,8 +103,10 @@ enum {
>  #define TCA_POLICE_MAX (__TCA_POLICE_MAX - 1)
>
>  /* tca flags definitions */
> -#define TCA_CLS_FLAGS_SKIP_HW  (1 << 0)
> -#define TCA_CLS_FLAGS_SKIP_SW  (1 << 1)
> +#define TCA_CLS_FLAGS_SKIP_HW  (1 << 0) /* don't offload filter to HW */
> +#define TCA_CLS_FLAGS_SKIP_SW  (1 << 1) /* don't use filter in SW */
> +#define TCA_CLS_FLAGS_IN_HW    (1 << 2) /* filter is offloaded to HW */
> +#define TCA_CLS_FLAGS_NOT_IN_HW (1 << 3) /* filter isn't offloaded to HW */
