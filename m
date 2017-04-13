From: Cong Wang <xiyou.wangcong@gmail.com>
Subject: Re: [PATCH linux 2/2] net sched actions: fix refcount decrement on error
Date: Wed, 12 Apr 2017 21:27:31 -0700
Message-ID: <CAM_iQpUxgF2X9z+mNhBUtPJsFPy8pyiDDhqz726Qt_aeEeLpeA@mail.gmail.com>
References: <20170412142140.26649-1-w.bumiller@proxmox.com> <20170412142140.26649-3-w.bumiller@proxmox.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Linux Kernel Network Developers <netdev@vger.kernel.org>,
        LKML <linux-kernel@vger.kernel.org>,
        Jamal Hadi Salim <jhs@mojatatu.com>,
        "David S. Miller" <davem@davemloft.net>
To: Wolfgang Bumiller <w.bumiller@proxmox.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20170412142140.26649-3-w.bumiller@proxmox.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, Apr 12, 2017 at 7:21 AM, Wolfgang Bumiller
<w.bumiller@proxmox.com> wrote:
> If memory allocation for nla_memdup_cookie() fails
> module_put has to be guarded by the same condition as it was
> before the TCA_ACT_COOKIE has been added as stated in the
> comment afterwards:
>
> /* module count goes up only when brand new policy is created
>  * if it exists and is only bound to in a_o->init() then
>  * ACT_P_CREATED is not returned (a zero is).
>  */

Yeah, this patch makes sense for me too. Just one comment below.

>
> Signed-off-by: Wolfgang Bumiller <w.bumiller@proxmox.com>
> ---
>
> Note that I'm unsure about this patch. The hangups weren't very reliable
> and I couldn't actually reproduce them when building from git/master (as
> I can only test a fraction of my usual workload with it as a lot of my
> data (VMs & containers utilizing veths and tap devices) is on ZFS...).
> In any case it can't harm to take another look at the error handling
> here.
>
>  net/sched/act_api.c | 12 ++++++++----
>  1 file changed, 8 insertions(+), 4 deletions(-)
>
> diff --git a/net/sched/act_api.c b/net/sched/act_api.c
> index 8cc883c063f0..795ac092b723 100644
> --- a/net/sched/act_api.c
> +++ b/net/sched/act_api.c
> @@ -608,15 +608,19 @@ struct tc_action *tcf_action_init_1(struct net *net, struct nlattr *nla,
>                 int cklen = nla_len(tb[TCA_ACT_COOKIE]);
>
>                 if (cklen > TC_COOKIE_MAX_SIZE) {
> -                       err = -EINVAL;
>                         tcf_hash_release(a, bind);
> -                       goto err_mod;
> +                       if (err != ACT_P_CREATED)
> +                               module_put(a_o->owner);
> +                       err = -EINVAL;
> +                       goto err_out;
>                 }
>
>                 if (nla_memdup_cookie(a, tb) < 0) {
> -                       err = -ENOMEM;
>                         tcf_hash_release(a, bind);
> -                       goto err_mod;
> +                       if (err != ACT_P_CREATED)
> +                               module_put(a_o->owner);
> +                       err = -ENOMEM;
> +                       goto err_out;

Instead of duplicating code, you can add the check
to the module_put() next to err_mod label? I mean:

@@ -630,7 +630,8 @@ struct tc_action *tcf_action_init_1(struct net
*net, struct nlattr *nla,
        return a;

 err_mod:
-       module_put(a_o->owner);
+       if (err != ACT_P_CREATED)
+               module_put(a_o->owner);
 err_out:
        return ERR_PTR(err);
 }
