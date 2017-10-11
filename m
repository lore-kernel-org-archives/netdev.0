From: Florian Westphal <fw@strlen.de>
Subject: Re: [PATCH v2 nf-next 1/2] netfilter: x_tables: make
 xt_replace_table wait until old rules are not used anymore
Date: Wed, 11 Oct 2017 15:45:30 +0200
Message-ID: <20171011134530.GA26835@breakpoint.cc>
References: <20171010213945.19074-1-fw@strlen.de>
 <20171010213945.19074-2-fw@strlen.de>
 <CANn89i+Y9CtNq6qTGAWi7fNfk9RRyxsuY1e2+SBCd1xRYx77zw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Florian Westphal <fw@strlen.de>, netdev <netdev@vger.kernel.org>,
        Dan Williams <dcbw@redhat.com>
To: Eric Dumazet <edumazet@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from Chamillionaire.breakpoint.cc ([146.0.238.67]:40570 "EHLO
        Chamillionaire.breakpoint.cc" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S1752050AbdJKNpi (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 11 Oct 2017 09:45:38 -0400
Content-Disposition: inline
In-Reply-To: <CANn89i+Y9CtNq6qTGAWi7fNfk9RRyxsuY1e2+SBCd1xRYx77zw@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Eric Dumazet <edumazet@google.com> wrote:
> > +       /* ... so wait for even xt_recseq on all cpus */
> > +       for_each_possible_cpu(cpu) {
> > +               seqcount_t *s = &per_cpu(xt_recseq, cpu);
> > +
> > +               while (raw_read_seqcount(s) & 1)
> > +                       cpu_relax();
> > +
> > +               cond_resched();
> > +       }
> 
> It seems that we could also check :
> 
> 1) If low order bit of sequence is 0
>
> Or
> 
> 2) the value has changed
>        for_each_possible_cpu(cpu) {
>                 seqcount_t *s = &per_cpu(xt_recseq, cpu);
>                  u32 seq = raw_read_seqcount(s) ;
> 
>                  if (seq & 1) {
>                         do {
>                             cpu_relax();
>                           } while (seq == raw_read_seqcount(s));
> 

Actually I first used

for_each_possible_cpu(cpu) {
  seqcount_t *s = &per_cpu(xt_recseq, cpu);

  (void)__read_seqcount_begin(s);
}

but it looked confusing (not paired with a _retry function).
I'll respin with a loop like your suggestion above.  Thanks!
