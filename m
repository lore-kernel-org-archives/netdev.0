From: "Eric Paris" <eparis@parisplace.org>
Subject: Re: Audit vs netlink interaction problem
Date: Mon, 17 Mar 2008 15:41:05 -0400
Message-ID: <7e0fb38c0803171241w6bfe5080l1b1b6d3ba8c93e8f@mail.gmail.com>
References: <47DAA660.90401@openvz.org> <20080314163929.GP20815@postel.suug.ch>
	 <47DAB065.6060804@openvz.org> <20080314182927.GQ20815@postel.suug.ch>
	 <20080314184052.GR20815@postel.suug.ch> <47DE254A.5070608@openvz.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: "Thomas Graf" <tgraf@suug.ch>,
	"David Woodhouse" <dwmw2@infradead.org>,
	"Linux Kernel Mailing List" <linux-kernel@vger.kernel.org>,
	"Linux Netdev List" <netdev@vger.kernel.org>,
	linux-audit@redhat.com
To: "Pavel Emelyanov" <xemul@openvz.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from wf-out-1314.google.com ([209.85.200.173]:1889 "EHLO
	wf-out-1314.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753203AbYCQTlI (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 17 Mar 2008 15:41:08 -0400
Received: by wf-out-1314.google.com with SMTP id 28so5587823wff.4
        for <netdev@vger.kernel.org>; Mon, 17 Mar 2008 12:41:05 -0700 (PDT)
In-Reply-To: <47DE254A.5070608@openvz.org>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

It looks reasonable to me.  If you can send a tested patch with a good
description to linux-audit@redhat.com I can work it into mainline.

-Eric

On 3/17/08, Pavel Emelyanov <xemul@openvz.org> wrote:
> Thomas Graf wrote:
>  > * Thomas Graf <tgraf@suug.ch> 2008-03-14 19:29
>  >> * Pavel Emelyanov <xemul@openvz.org> 2008-03-14 20:05
>  >>> Hmmm... I'm afraid, that this can break the audit filtering and signal
>  >>> auditing. I haven't yet looked deep into it, but it compares the
>  >>> task->tgid with this audit_pid for different purposes. If audit_pid
>  >>> changes this code will be broken.
>  >> OK, then both pids have to be stored. audit_pid remains as-is but is
>  >> no longer used as destination netlink pid. A second pid is stored and
>  >> updated whenever a netlink message is received from userspace.
>  >
>  > The following patch represents what I mean. Untested!
>
>
> Looks great, all the more so I created very similar patch.
>  David, can we have this in mainline some day?
>
>  Thanks,
>  Pavel
>
>
>  > Index: net-2.6.26/kernel/audit.c
>  > ===================================================================
>  > --- net-2.6.26.orig/kernel/audit.c    2008-03-14 19:31:53.000000000 +0100
>  > +++ net-2.6.26/kernel/audit.c 2008-03-14 19:38:35.000000000 +0100
>  > @@ -82,6 +82,9 @@
>  >   * contains the (non-zero) pid. */
>  >  int          audit_pid;
>  >
>  > +/* Actual netlink pid of the userspace process */
>  > +static int   audit_nlk_pid;
>  > +
>  >  /* If audit_rate_limit is non-zero, limit the rate of sending audit records
>  >   * to that number per second.  This prevents DoS attacks, but results in
>  >   * audit records being dropped. */
>  > @@ -347,12 +350,12 @@
>  >               skb = skb_dequeue(&audit_skb_queue);
>  >               wake_up(&audit_backlog_wait);
>  >               if (skb) {
>  > -                     if (audit_pid) {
>  > -                             int err = netlink_unicast(audit_sock, skb, audit_pid, 0);
>  > +                     if (audit_nlk_pid) {
>  > +                             int err = netlink_unicast(audit_sock, skb, audit_nlk_pid, 0);
>  >                               if (err < 0) {
>  >                                       BUG_ON(err != -ECONNREFUSED); /* Shoudn't happen */
>  > -                                     printk(KERN_ERR "audit: *NO* daemon at audit_pid=%d\n", audit_pid);
>  > -                                     audit_pid = 0;
>  > +                                     printk(KERN_ERR "audit: *NO* daemon at audit_nlk_pid=%d\n", audit_nlk_pid);
>  > +                                     audit_nlk_pid = 0;
>  >                               }
>  >                       } else {
>  >                               if (printk_ratelimit())
>  > @@ -623,6 +626,12 @@
>  >                                                       sid, 1);
>  >
>  >                       audit_pid = new_pid;
>  > +
>  > +                     /*
>  > +                      * Netlink pid is only updated here to avoid overwrites
>  > +                      * from potential processes only querying the interface.
>  > +                      */
>  > +                     audit_nlk_pid = NETLINK_CB(skb).pid;
>  >               }
>  >               if (status_get->mask & AUDIT_STATUS_RATE_LIMIT)
>  >                       err = audit_set_rate_limit(status_get->rate_limit,
>  > @@ -1350,7 +1359,7 @@
>  >       if (!audit_rate_check()) {
>  >               audit_log_lost("rate limit exceeded");
>  >       } else {
>  > -             if (audit_pid) {
>  > +             if (audit_nlk_pid) {
>  >                       struct nlmsghdr *nlh = nlmsg_hdr(ab->skb);
>  >                       nlh->nlmsg_len = ab->skb->len - NLMSG_SPACE(0);
>  >                       skb_queue_tail(&audit_skb_queue, ab->skb);
>  >
>
>  --
>
> To unsubscribe from this list: send the line "unsubscribe netdev" in
>
> the body of a message to majordomo@vger.kernel.org
>  More majordomo info at  http://vger.kernel.org/majordomo-info.html
>
