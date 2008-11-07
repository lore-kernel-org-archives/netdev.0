From: Thomas Graf <tgraf@suug.ch>
Subject: Re: [RESEND] pkt_sched: Control group classifier
Date: Fri, 7 Nov 2008 18:08:50 +0100
Message-ID: <20081107170850.GO20815@postel.suug.ch>
References: <20081106161330.GN20815@postel.suug.ch> <166fe7950811070751j475c9aa6n861bc43a97d1aec5@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: Ranjit Manomohan <ranjitm@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from postel.suug.ch ([194.88.212.233]:53537 "EHLO postel.suug.ch"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750953AbYKGRIc (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 7 Nov 2008 12:08:32 -0500
Content-Disposition: inline
In-Reply-To: <166fe7950811070751j475c9aa6n861bc43a97d1aec5@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

* Ranjit Manomohan <ranjitm@google.com> 2008-11-07 07:51
> > +static int cls_cgroup_classify(struct sk_buff *skb, struct tcf_proto *tp,
> > +                              struct tcf_result *res)
> > +{
> > +       struct cls_cgroup_head *head = tp->root;
> > +       struct cgroup_cls_state *cs;
> > +       int ret = 0;
> > +
> > +       /*
> > +        * Due to the nature of the classifier it is required to ignore all
> > +        * packets originating from softirq context as accessing `current'
> > +        * would lead to false results.
> > +        *
> > +        * This test assumes that all callers of dev_queue_xmit() explicitely
> > +        * disable bh. Knowing this, it is possible to detect softirq based
> > +        * calls by looking at the number of nested bh disable calls because
> > +        * softirqs always disables bh.
> > +        */
> > +       if (softirq_count() != SOFTIRQ_OFFSET)
> > +               return -1;
> > +
> 
>     How about caching the cs->classid in the socket here at this point
> (if there is a mismatch from the current cgroup value)  if we are in
> process context and using that value if we are in interrupt context.
> That should help account for the packets in interrupt context and work
> seamlessly if the task got moved between cgroups or if the cgroup
> identifier was changed.

I like the idea, the overhead is relatively small and the sk_buff struct
does not get polluted. There will still be cases where the skb has been
orphaned and is no longer connected to a socket but that case is pretty
rare.

Will you work on a follow-up patch?
