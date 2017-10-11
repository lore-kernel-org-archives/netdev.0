From: Eric Dumazet <edumazet@google.com>
Subject: Re: [PATCH v2 nf-next 1/2] netfilter: x_tables: make xt_replace_table
 wait until old rules are not used anymore
Date: Wed, 11 Oct 2017 06:23:03 -0700
Message-ID: <CANn89i+Y9CtNq6qTGAWi7fNfk9RRyxsuY1e2+SBCd1xRYx77zw@mail.gmail.com>
References: <20171010213945.19074-1-fw@strlen.de> <20171010213945.19074-2-fw@strlen.de>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Cc: netdev <netdev@vger.kernel.org>, Dan Williams <dcbw@redhat.com>
To: Florian Westphal <fw@strlen.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ua0-f181.google.com ([209.85.217.181]:50626 "EHLO
        mail-ua0-f181.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752006AbdJKNXF (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 11 Oct 2017 09:23:05 -0400
Received: by mail-ua0-f181.google.com with SMTP id v27so1059175uav.7
        for <netdev@vger.kernel.org>; Wed, 11 Oct 2017 06:23:05 -0700 (PDT)
In-Reply-To: <20171010213945.19074-2-fw@strlen.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Oct 10, 2017 at 2:39 PM, Florian Westphal <fw@strlen.de> wrote:
> xt_replace_table relies on table replacement counter retrieval (which
> uses xt_recseq to synchronize pcpu counters).
>
> This is fine, however with large rule set get_counters() can take
> a very long time -- it needs to synchronize all counters because
> it has to assume concurrent modifications can occur.
>
> Make xt_replace_table synchronize by itself by waiting until all cpus
> had an even seqcount.
>
> This allows a followup patch to copy the counters of the old ruleset
> without any synchonization after xt_replace_table has completed.
>
> Cc: Dan Williams <dcbw@redhat.com>
> Cc: Eric Dumazet <edumazet@google.com>
> Signed-off-by: Florian Westphal <fw@strlen.de>
> ---
>  v2: fix Erics email address
>
>  net/netfilter/x_tables.c | 15 ++++++++++++---
>  1 file changed, 12 insertions(+), 3 deletions(-)
>
> diff --git a/net/netfilter/x_tables.c b/net/netfilter/x_tables.c
> index c83a3b5e1c6c..f2d4a365768f 100644
> --- a/net/netfilter/x_tables.c
> +++ b/net/netfilter/x_tables.c
> @@ -1153,6 +1153,7 @@ xt_replace_table(struct xt_table *table,
>               int *error)
>  {
>         struct xt_table_info *private;
> +       unsigned int cpu;
>         int ret;
>
>         ret = xt_jumpstack_alloc(newinfo);
> @@ -1184,12 +1185,20 @@ xt_replace_table(struct xt_table *table,
>
>         /*
>          * Even though table entries have now been swapped, other CPU's
> -        * may still be using the old entries. This is okay, because
> -        * resynchronization happens because of the locking done
> -        * during the get_counters() routine.
> +        * may still be using the old entries...
>          */
>         local_bh_enable();
>
> +       /* ... so wait for even xt_recseq on all cpus */
> +       for_each_possible_cpu(cpu) {
> +               seqcount_t *s = &per_cpu(xt_recseq, cpu);
> +
> +               while (raw_read_seqcount(s) & 1)
> +                       cpu_relax();
> +
> +               cond_resched();
> +       }

It seems that we could also check :

1) If low order bit of sequence is 0

Or

2) the value has changed

       for_each_possible_cpu(cpu) {
                seqcount_t *s = &per_cpu(xt_recseq, cpu);
                 u32 seq = raw_read_seqcount(s) ;

                 if (seq & 1) {
                        do {
                            cpu_relax();
                          } while (seq == raw_read_seqcount(s));

Thanks !
