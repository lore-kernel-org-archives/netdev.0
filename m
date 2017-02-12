From: Or Gerlitz <gerlitz.or@gmail.com>
Subject: Re: [PATCH net-next 4/4] net/sched: cls_bpf: Use skip flags to
 reflect HW offload status
Date: Sun, 12 Feb 2017 12:01:52 +0200
Message-ID: <CAJ3xEMhJbk9HH8epN6e=5MAxNjPrp1ik+mNEH9RHA1qF3+YRrA@mail.gmail.com>
References: <1486649888-2786-1-git-send-email-ogerlitz@mellanox.com>
 <1486649888-2786-5-git-send-email-ogerlitz@mellanox.com> <20170210141933.6e51418e@cakuba.netronome.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Or Gerlitz <ogerlitz@mellanox.com>,
        "David S. Miller" <davem@davemloft.net>,
        Daniel Borkmann <daniel@iogearbox.net>,
        John Fastabend <john.r.fastabend@intel.com>,
        Linux Netdev List <netdev@vger.kernel.org>
To: Jakub Kicinski <jakub.kicinski@netronome.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-oi0-f68.google.com ([209.85.218.68]:33481 "EHLO
        mail-oi0-f68.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751120AbdBLKBy (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sun, 12 Feb 2017 05:01:54 -0500
Received: by mail-oi0-f68.google.com with SMTP id j15so5199208oih.0
        for <netdev@vger.kernel.org>; Sun, 12 Feb 2017 02:01:53 -0800 (PST)
In-Reply-To: <20170210141933.6e51418e@cakuba.netronome.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, Feb 11, 2017 at 12:19 AM, Jakub Kicinski
<jakub.kicinski@netronome.com> wrote:

> FWIW I tested this one and it works.  I also tested this version which
> would take advantage of @offloaded:

I assume that if we go on the existing suggestion, the below is what
you prefer,
so I will pick it up, let know if you think otherwise.


> diff --git a/net/sched/cls_bpf.c b/net/sched/cls_bpf.c
> index d9c97018317d..51d464f991ff 100644
> --- a/net/sched/cls_bpf.c
> +++ b/net/sched/cls_bpf.c
> @@ -568,8 +568,8 @@ static int cls_bpf_dump(struct net *net, struct tcf_proto *tp, unsigned long fh,
>                         struct sk_buff *skb, struct tcmsg *tm)
>  {
>         struct cls_bpf_prog *prog = (struct cls_bpf_prog *) fh;
> +       u32 gen_flags, bpf_flags = 0;
>         struct nlattr *nest;
> -       u32 bpf_flags = 0;
>         int ret;
>
>         if (prog == NULL)
> @@ -601,8 +601,11 @@ static int cls_bpf_dump(struct net *net, struct tcf_proto *tp, unsigned long fh,
>                 bpf_flags |= TCA_BPF_FLAG_ACT_DIRECT;
>         if (bpf_flags && nla_put_u32(skb, TCA_BPF_FLAGS, bpf_flags))
>                 goto nla_put_failure;
> -       if (prog->gen_flags &&
> -           nla_put_u32(skb, TCA_BPF_FLAGS_GEN, prog->gen_flags))
> +
> +       gen_flags = prog->gen_flags;
> +       if (!prog->offloaded)
> +               gen_flags |= TCA_CLS_FLAGS_SKIP_HW;
> +       if (gen_flags && nla_put_u32(skb, TCA_BPF_FLAGS_GEN, gen_flags))
>                 goto nla_put_failure;
>
>         nla_nest_end(skb, nest);
