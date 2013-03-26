From: Cong Wang <amwang@redhat.com>
Subject: Re: [PATCH net-next] 802: fix a possible race condition
Date: Tue, 26 Mar 2013 11:01:40 +0800
Message-ID: <1364266900.18439.4.camel@cr0>
References: <1363938600-26129-1-git-send-email-amwang@redhat.com>
	 <1364015648-4195-1-git-send-email-amwang@redhat.com>
	 <1364015648-4195-2-git-send-email-amwang@redhat.com>
	 <20130324.172403.776354963637295731.davem@davemloft.net>
	 <1364218338.2532.15.camel@cr0> <1364220527.29473.15.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
	david.ward@ll.mit.edu, jorge@dti2.net
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:60322 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1759212Ab3CZDCJ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 25 Mar 2013 23:02:09 -0400
In-Reply-To: <1364220527.29473.15.camel@edumazet-glaptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 2013-03-25 at 07:08 -0700, Eric Dumazet wrote:
> On Mon, 2013-03-25 at 21:32 +0800, Cong Wang wrote:
> 
> > At least garp_join_timer() calls garp_pdu_queue() in a timer:
> > 
> > static void garp_join_timer(unsigned long data)
> > {
> >         struct garp_applicant *app = (struct garp_applicant *)data;
> > 
> >         spin_lock(&app->lock);
> >         garp_gid_event(app, GARP_EVENT_TRANSMIT_PDU);
> >         garp_pdu_queue(app);
> >         spin_unlock(&app->lock);
> > 
> >         garp_queue_xmit(app);
> >         garp_join_timer_arm(app);
> > }
> > 
> > which I don't think can hold RTNL lock possibly.
> > 
> 
> But timer wont possibly run because of the previous :
> 
> del_timer_sync(&app->join_timer);

Yeah, but in the following callchain:

garp_pdu_rcv() -> garp_pdu_parse_msg() -> garp_pdu_parse_attr() ->
garp_gid_event()

the race can happen too as garp_pdu_rcv() is called in BH context.
