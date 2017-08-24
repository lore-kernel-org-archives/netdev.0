From: Jesper Dangaard Brouer <brouer@redhat.com>
Subject: Re: Question about ip_defrag
Date: Thu, 24 Aug 2017 20:59:26 +0200
Message-ID: <20170824205926.2c45e3a1@redhat.com>
References: <4F88C5DDA1E80143B232E89585ACE27D018F07E2@DGGEMA502-MBX.china.huawei.com>
        <20170824155300.1e577dae@redhat.com>
        <4F88C5DDA1E80143B232E89585ACE27D018F0AE1@DGGEMA502-MBX.china.huawei.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 8BIT
Cc: "davem@davemloft.net" <davem@davemloft.net>,
        "kuznet@ms2.inr.ac.ru" <kuznet@ms2.inr.ac.ru>,
        "yoshfuji@linux-ipv6.org" <yoshfuji@linux-ipv6.org>,
        "elena.reshetova@intel.com" <elena.reshetova@intel.com>,
        "edumazet@google.com" <edumazet@google.com>,
        "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
        brouer@redhat.com
To: "liujian (CE)" <liujian56@huawei.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:33256 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1753025AbdHXS7i (ORCPT <rfc822;netdev@vger.kernel.org>);
        Thu, 24 Aug 2017 14:59:38 -0400
In-Reply-To: <4F88C5DDA1E80143B232E89585ACE27D018F0AE1@DGGEMA502-MBX.china.huawei.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


On Thu, 24 Aug 2017 16:04:41 +0000 "liujian (CE)" <liujian56@huawei.com> wrote:

> >What kernel version have you seen this issue with?  
>
> 3.10，with some backport.
>
>  >As far as I remember, this issue have been fixed before...  
>
> which one patch? I didnot find out the patch:(

AFAIK it was some bugs in the percpu_counter code.  If you need to
backport look at the git commits:

 git log lib/percpu_counter.c include/linux/percpu_counter.h

Are you maintaining your own 3.10 kernel?

I know that for RHEL7 (also kernel 3.10) we backported the
percpu_counter fixes...

--Jesper


> 发件人： Jesper Dangaard Brouer
> 收件人： liujian (CE)<liujian56@huawei.com<mailto:liujian56@huawei.com>>
> 抄送： davem@davemloft.net<mailto:davem@davemloft.net>;kuznet@ms2.inr.ac.ru<mailto:kuznet@ms2.inr.ac.ru>;yoshfuji@linux-ipv6.org<mailto:yoshfuji@linux-ipv6.org>;elena.reshetova@intel.com<mailto:elena.reshetova@intel.com>;edumazet@google.com<mailto:edumazet@google.com>;netdev@vger.kernel.org<mailto:netdev@vger.kernel.org>;brouer@redhat.com<mailto:brouer@redhat.com>
> 主题： Re: Question about ip_defrag
> 时间： 2017-08-24 21:53:17
> 
> 
> On Thu, 24 Aug 2017 13:15:33 +0000 "liujian (CE)" <liujian56@huawei.com> wrote:
> > Hello,
> >
> > With below patch we met one issue.
> > https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/commit/?h=v4.13-rc6&id=6d7b857d541e
> >
> > the issue:
> > Ip_defrag fail caused by frag_mem_limit reached 4M(frags.high_thresh).
> > At this moment,sum_frag_mem_limit is about 10K.
> > and my test machine's cpu num is 64.
> >
> > Can i only change frag_mem_limit to sum_ frag_mem_limit?
> >
> >
> > diff --git a/net/ipv4/inet_fragment.c b/net/ipv4/inet_fragment.c
> > index 96e95e8..f09c00b 100644
> > --- a/net/ipv4/inet_fragment.c
> > +++ b/net/ipv4/inet_fragment.c
> > @@ -120,7 +120,7 @@ static void inet_frag_secret_rebuild(struct inet_frags *f)
> >  static bool inet_fragq_should_evict(const struct inet_frag_queue *q)
> >  {
> >         return q->net->low_thresh == 0 ||
> > -              frag_mem_limit(q->net) >= q->net->low_thresh;
> > +              sum_frag_mem_limit(q->net) >= q->net->low_thresh;
> >  }
> >
> >  static unsigned int
> > @@ -355,7 +355,7 @@ static struct inet_frag_queue *inet_frag_alloc(struct netns_frags *nf,
> >  {
> >         struct inet_frag_queue *q;
> >
> > -       if (!nf->high_thresh || frag_mem_limit(nf) > nf->high_thresh) {
> > +       if (!nf->high_thresh || sum_frag_mem_limit(nf) > nf->high_thresh) {
> >                 inet_frag_schedule_worker(f);
> >                 return NULL;
> >         }
> > @@ -396,7 +396,7 @@ struct inet_frag_queue *inet_frag_find(struct netns_frags *nf,
> >         struct inet_frag_queue *q;
> >         int depth = 0;
> >
> > -       if (frag_mem_limit(nf) > nf->low_thresh)
> > +       if (sum_frag_mem_limit(nf) > nf->low_thresh)
> >                 inet_frag_schedule_worker(f);
> >
> >         hash &= (INETFRAGS_HASHSZ - 1);
> > --
> >
> > Thank you for your time.  
> 
> What kernel version have you seen this issue with?
> 
> As far as I remember, this issue have been fixed before...
> 
> --
> Best regards,
>   Jesper Dangaard Brouer
>   MSc.CS, Principal Kernel Engineer at Red Hat
>   LinkedIn: http://www.linkedin.com/in/brouer



-- 
Best regards,
  Jesper Dangaard Brouer
  MSc.CS, Principal Kernel Engineer at Red Hat
  LinkedIn: http://www.linkedin.com/in/brouer
