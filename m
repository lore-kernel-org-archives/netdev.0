From: Wei Wang <weiwan@google.com>
Subject: Re: [PATCH net-next] ipv6: do lazy dst->__use update when per cpu dst
 is available
Date: Wed, 27 Sep 2017 10:44:35 -0700
Message-ID: <CAEA6p_DZxGesjymubWoWx7hQjaZ7Vdchh=cdOW9tAr4F7QvzXg@mail.gmail.com>
References: <9d32116e61596b0de6a584b6cf05cae3ce7abb56.1506532145.git.pabeni@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Cc: Linux Kernel Network Developers <netdev@vger.kernel.org>,
        "David S. Miller" <davem@davemloft.net>,
        Hannes Frederic Sowa <hannes@stressinduktion.org>
To: Paolo Abeni <pabeni@redhat.com>,
        Eric Dumazet <edumazet@google.com>,
        Martin KaFai Lau <kafai@fb.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-vk0-f47.google.com ([209.85.213.47]:46558 "EHLO
        mail-vk0-f47.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751408AbdI0Roi (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 27 Sep 2017 13:44:38 -0400
Received: by mail-vk0-f47.google.com with SMTP id 78so7468301vkc.3
        for <netdev@vger.kernel.org>; Wed, 27 Sep 2017 10:44:37 -0700 (PDT)
In-Reply-To: <9d32116e61596b0de6a584b6cf05cae3ce7abb56.1506532145.git.pabeni@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Sep 27, 2017 at 10:14 AM, Paolo Abeni <pabeni@redhat.com> wrote:
> When a host is under high ipv6 load, the updates of the ingress
> route '__use' field are a source of relevant contention: such
> field is updated for each packet and several cores can access
> concurrently the dst, even if percpu dst entries are available
> and used.
>
> The __use value is just a rough indication of the dst usage: is
> already updated concurrently from multiple CPUs without any lock,
> so we can decrease the contention leveraging the percpu dst to perform
> __use bulk updates: if a per cpu dst entry is found, we account on
> such entry and we flush the percpu counter once per jiffy.
>
> Performace gain under UDP flood is as follows:
>
> nr RX queues    before          after           delta
>                 kpps            kpps            (%)
> 2               2316            2688            16
> 3               3033            3605            18
> 4               3963            4328            9
> 5               4379            5253            19
> 6               5137            6000            16
>
> Performance gain under TCP syn flood should be measurable as well.
>
> Signed-off-by: Paolo Abeni <pabeni@redhat.com>
> ---
>  net/ipv6/route.c | 18 ++++++++++++++++--
>  1 file changed, 16 insertions(+), 2 deletions(-)
>
> diff --git a/net/ipv6/route.c b/net/ipv6/route.c
> index 26cc9f483b6d..e69f304de950 100644
> --- a/net/ipv6/route.c
> +++ b/net/ipv6/route.c
> @@ -1170,12 +1170,24 @@ struct rt6_info *ip6_pol_route(struct net *net, struct fib6_table *table,
>
>                 struct rt6_info *pcpu_rt;
>
> -               rt->dst.lastuse = jiffies;
> -               rt->dst.__use++;
>                 pcpu_rt = rt6_get_pcpu_route(rt);
>
>                 if (pcpu_rt) {
> +                       unsigned long ts;
> +
>                         read_unlock_bh(&table->tb6_lock);
> +
> +                       /* do lazy updates of rt->dst->__use, at most once
> +                        * per jiffy, to avoid contention on such cacheline.
> +                        */
> +                       ts = jiffies;
> +                       pcpu_rt->dst.__use++;
> +                       if (pcpu_rt->dst.lastuse != ts) {
> +                               rt->dst.__use += pcpu_rt->dst.__use;
> +                               rt->dst.lastuse = ts;
> +                               pcpu_rt->dst.__use = 0;
> +                               pcpu_rt->dst.lastuse = ts;
> +                       }
>                 } else {
>                         /* We have to do the read_unlock first
>                          * because rt6_make_pcpu_route() may trigger
> @@ -1185,6 +1197,8 @@ struct rt6_info *ip6_pol_route(struct net *net, struct fib6_table *table,
>                         read_unlock_bh(&table->tb6_lock);
>                         pcpu_rt = rt6_make_pcpu_route(rt);
>                         dst_release(&rt->dst);
> +                       rt->dst.lastuse = jiffies;
> +                       rt->dst.__use++;
>                 }
>
>                 trace_fib6_table_lookup(net, pcpu_rt, table->tb6_id, fl6);
> --
> 2.13.5
>

Hi Paolo,

Eric and I discussed about this issue recently as well :).

What about the following change:

diff --git a/include/net/dst.h b/include/net/dst.h
index 93568bd0a352..33e1d86bcef6 100644
--- a/include/net/dst.h
+++ b/include/net/dst.h
@@ -258,14 +258,18 @@ static inline void dst_hold(struct dst_entry *dst)
 static inline void dst_use(struct dst_entry *dst, unsigned long time)
 {
        dst_hold(dst);
-       dst->__use++;
-       dst->lastuse = time;
+       if (dst->lastuse != time) {
+               dst->__use++;
+               dst->lastuse = time;
+       }
 }

 static inline void dst_use_noref(struct dst_entry *dst, unsigned long time)
 {
-       dst->__use++;
-       dst->lastuse = time;
+       if (dst->lastuse != time) {
+               dst->__use++;
+               dst->lastuse = time;
+       }
 }

 static inline struct dst_entry *dst_clone(struct dst_entry *dst)
diff --git a/net/ipv6/route.c b/net/ipv6/route.c
index 26cc9f483b6d..e195f093add3 100644
--- a/net/ipv6/route.c
+++ b/net/ipv6/route.c
@@ -1170,8 +1170,7 @@ struct rt6_info *ip6_pol_route(struct net *net,
struct fib6_table *table,

                struct rt6_info *pcpu_rt;

-               rt->dst.lastuse = jiffies;
-               rt->dst.__use++;
+               dst_use_noref(rt, jiffies);
                pcpu_rt = rt6_get_pcpu_route(rt);

                if (pcpu_rt) {


This way we always only update dst->__use and dst->lastuse at most
once per jiffy. And we don't really need to update pcpu and then do
the copy over from pcpu_rt to rt operation.

Another thing is that I don't really see any places making use of
dst->__use. So maybe we can also get rid of this dst->__use field?

Thanks.
Wei
