From: Nick Desaulniers <ndesaulniers@google.com>
Subject: Re: [PATCH] netfilter: nf_nat_h323: fix logical-not-parentheses warning
Date: Tue, 8 Aug 2017 16:28:57 -0700
Message-ID: <CAKwvOdmPVViB=c6rqk7ZYoij9g9Tf=Y1y_Wbom42118AVfsgiQ@mail.gmail.com>
References: <20170731183949.73763-1-ndesaulniers@google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Cc: Matthias Kaehlcke <mka@chromium.org>,
        Lorenzo Colitti <lorenzo@google.com>,
        Pablo Neira Ayuso <pablo@netfilter.org>,
        Jozsef Kadlecsik <kadlec@blackhole.kfki.hu>,
        Florian Westphal <fw@strlen.de>,
        "David S. Miller" <davem@davemloft.net>,
        Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>,
        Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>,
        netfilter-devel@vger.kernel.org, coreteam@netfilter.org,
        netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: Nick Desaulniers <ndesaulniers@google.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20170731183949.73763-1-ndesaulniers@google.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

bumping for review

On Mon, Jul 31, 2017 at 11:39 AM, Nick Desaulniers
<ndesaulniers@google.com> wrote:
> Clang produces the following warning:
>
> net/ipv4/netfilter/nf_nat_h323.c:553:6: error:
> logical not is only applied to the left hand side of this comparison
>   [-Werror,-Wlogical-not-parentheses]
> if (!set_h225_addr(skb, protoff, data, dataoff, taddr,
>     ^
> add parentheses after the '!' to evaluate the comparison first
> add parentheses around left hand side expression to silence this warning
>
> There's not necessarily a bug here, but it's cleaner to use the form:
>
> if (x != 0)
>
> rather than:
>
> if (!x == 0)
>
> Signed-off-by: Nick Desaulniers <ndesaulniers@google.com>
> ---
> Also, it's even cleaner to use the form:
>
> if (x)
>
> but then if the return codes change from treating 0 as success (unlikely),
> then all call sites must be updated.
>
> I'm happy to send v2 that changes to that form, and updates the other call
> sites to be:
>
> if (set_h225_addr())
>   handle_failures()
> else
>   handle_success()
>
>  net/ipv4/netfilter/nf_nat_h323.c | 6 +++---
>  1 file changed, 3 insertions(+), 3 deletions(-)
>
> diff --git a/net/ipv4/netfilter/nf_nat_h323.c b/net/ipv4/netfilter/nf_nat_h323.c
> index 574f7ebba0b6..d8fb251fa6e3 100644
> --- a/net/ipv4/netfilter/nf_nat_h323.c
> +++ b/net/ipv4/netfilter/nf_nat_h323.c
> @@ -550,9 +550,9 @@ static int nat_callforwarding(struct sk_buff *skb, struct nf_conn *ct,
>         }
>
>         /* Modify signal */
> -       if (!set_h225_addr(skb, protoff, data, dataoff, taddr,
> -                          &ct->tuplehash[!dir].tuple.dst.u3,
> -                          htons(nated_port)) == 0) {
> +       if (set_h225_addr(skb, protoff, data, dataoff, taddr,
> +                         &ct->tuplehash[!dir].tuple.dst.u3,
> +                         htons(nated_port)) != 0) {
>                 nf_ct_unexpect_related(exp);
>                 return -1;
>         }
> --
> 2.14.0.rc0.400.g1c36432dff-goog
>



-- 
Thanks,
~Nick Desaulniers
