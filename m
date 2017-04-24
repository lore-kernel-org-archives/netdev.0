From: Andrey Konovalov <andreyknvl@google.com>
Subject: Re: net: cleanup_net is slow
Date: Mon, 24 Apr 2017 13:58:20 +0200
Message-ID: <CAAeHK+zwsdzVrgwLccbXs7QUEsFkeTL13_AfNKMD1G2BkOr0eg@mail.gmail.com>
References: <CAAeHK+yJXMo8kr_p8iM_dicVGQCtwQhdk=rdE+9dNbsoghAb6Q@mail.gmail.com>
 <CANn89i+iYtPLGDZpt3qk_cA-dq+004B=1qjP0ZygY3oREskQYA@mail.gmail.com>
 <20170421192729.GA8853@breakpoint.cc> <20170421194515.GB8853@breakpoint.cc>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Eric Dumazet <edumazet@google.com>,
        Cong Wang <xiyou.wangcong@gmail.com>,
        netdev <netdev@vger.kernel.org>,
        LKML <linux-kernel@vger.kernel.org>,
        Dmitry Vyukov <dvyukov@google.com>,
        Kostya Serebryany <kcc@google.com>,
        syzkaller <syzkaller@googlegroups.com>
To: Florian Westphal <fw@strlen.de>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20170421194515.GB8853@breakpoint.cc>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, Apr 21, 2017 at 9:45 PM, Florian Westphal <fw@strlen.de> wrote:
> Florian Westphal <fw@strlen.de> wrote:
>> Indeed.  Setting net.netfilter.nf_conntrack_default_on=0 cuts time
>> cleanup time by 2/3 ...
>>
>> nf unregister is way too happy to issue synchronize_net(), I'll work on
>> a fix.
>
> I'll test this patch as a start.  Maybe we can also leverage exit_batch
> more on netfilter side.

Hi Florian,

Your patch improves fuzzing speed at least twice, which is a great start!

Thanks!

>
> diff --git a/net/netfilter/core.c b/net/netfilter/core.c
> index a87a6f8a74d8..08fe1f526265 100644
> --- a/net/netfilter/core.c
> +++ b/net/netfilter/core.c
> @@ -126,14 +126,15 @@ int nf_register_net_hook(struct net *net, const struct nf_hook_ops *reg)
>  }
>  EXPORT_SYMBOL(nf_register_net_hook);
>
> -void nf_unregister_net_hook(struct net *net, const struct nf_hook_ops *reg)
> +static struct nf_hook_entry *
> +__nf_unregister_net_hook(struct net *net, const struct nf_hook_ops *reg)
>  {
>         struct nf_hook_entry __rcu **pp;
>         struct nf_hook_entry *p;
>
>         pp = nf_hook_entry_head(net, reg);
>         if (WARN_ON_ONCE(!pp))
> -               return;
> +               return NULL;
>
>         mutex_lock(&nf_hook_mutex);
>         for (; (p = nf_entry_dereference(*pp)) != NULL; pp = &p->next) {
> @@ -145,7 +146,7 @@ void nf_unregister_net_hook(struct net *net, const struct nf_hook_ops *reg)
>         mutex_unlock(&nf_hook_mutex);
>         if (!p) {
>                 WARN(1, "nf_unregister_net_hook: hook not found!\n");
> -               return;
> +               return NULL;
>         }
>  #ifdef CONFIG_NETFILTER_INGRESS
>         if (reg->pf == NFPROTO_NETDEV && reg->hooknum == NF_NETDEV_INGRESS)
> @@ -154,6 +155,17 @@ void nf_unregister_net_hook(struct net *net, const struct nf_hook_ops *reg)
>  #ifdef HAVE_JUMP_LABEL
>         static_key_slow_dec(&nf_hooks_needed[reg->pf][reg->hooknum]);
>  #endif
> +
> +       return p;
> +}
> +
> +void nf_unregister_net_hook(struct net *net, const struct nf_hook_ops *reg)
> +{
> +       struct nf_hook_entry *p = __nf_unregister_net_hook(net, reg);
> +
> +       if (!p)
> +               return;
> +
>         synchronize_net();
>         nf_queue_nf_hook_drop(net, p);
>         /* other cpu might still process nfqueue verdict that used reg */
> @@ -183,10 +195,36 @@ int nf_register_net_hooks(struct net *net, const struct nf_hook_ops *reg,
>  EXPORT_SYMBOL(nf_register_net_hooks);
>
>  void nf_unregister_net_hooks(struct net *net, const struct nf_hook_ops *reg,
> -                            unsigned int n)
> +                            unsigned int hookcount)
>  {
> -       while (n-- > 0)
> -               nf_unregister_net_hook(net, &reg[n]);
> +       struct nf_hook_entry *to_free[16];
> +       unsigned int i, n;
> +
> +       WARN_ON_ONCE(hookcount > ARRAY_SIZE(to_free));
> +
> + next_round:
> +       n = min_t(unsigned int, hookcount, ARRAY_SIZE(to_free));
> +
> +       for (i = 0; i < n; i++)
> +               to_free[i] = __nf_unregister_net_hook(net, &reg[i]);
> +
> +       synchronize_net();
> +
> +       for (i = 0; i < n; i++) {
> +               if (to_free[i])
> +                       nf_queue_nf_hook_drop(net, to_free[i]);
> +       }
> +
> +       synchronize_net();
> +
> +       for (i = 0; i < n; i++)
> +               kfree(to_free[i]);
> +
> +       if (n < hookcount) {
> +               hookcount -= n;
> +               reg += n;
> +               goto next_round;
> +       }
>  }
>  EXPORT_SYMBOL(nf_unregister_net_hooks);
>
