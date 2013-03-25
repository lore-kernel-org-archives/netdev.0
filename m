From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net-next] 802: fix a possible race condition
Date: Mon, 25 Mar 2013 07:08:47 -0700
Message-ID: <1364220527.29473.15.camel@edumazet-glaptop>
References: <1363938600-26129-1-git-send-email-amwang@redhat.com>
	 <1364015648-4195-1-git-send-email-amwang@redhat.com>
	 <1364015648-4195-2-git-send-email-amwang@redhat.com>
	 <20130324.172403.776354963637295731.davem@davemloft.net>
	 <1364218338.2532.15.camel@cr0>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
	david.ward@ll.mit.edu, jorge@dti2.net
To: Cong Wang <amwang@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f41.google.com ([209.85.220.41]:51954 "EHLO
	mail-pa0-f41.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758145Ab3CYOIu (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 25 Mar 2013 10:08:50 -0400
Received: by mail-pa0-f41.google.com with SMTP id kx1so597524pab.28
        for <netdev@vger.kernel.org>; Mon, 25 Mar 2013 07:08:49 -0700 (PDT)
In-Reply-To: <1364218338.2532.15.camel@cr0>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 2013-03-25 at 21:32 +0800, Cong Wang wrote:

> At least garp_join_timer() calls garp_pdu_queue() in a timer:
> 
> static void garp_join_timer(unsigned long data)
> {
>         struct garp_applicant *app = (struct garp_applicant *)data;
> 
>         spin_lock(&app->lock);
>         garp_gid_event(app, GARP_EVENT_TRANSMIT_PDU);
>         garp_pdu_queue(app);
>         spin_unlock(&app->lock);
> 
>         garp_queue_xmit(app);
>         garp_join_timer_arm(app);
> }
> 
> which I don't think can hold RTNL lock possibly.
> 

But timer wont possibly run because of the previous :

del_timer_sync(&app->join_timer);
