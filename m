From: Cong Wang <amwang@redhat.com>
Subject: Re: [PATCH net-next] 802: fix a possible race condition
Date: Mon, 25 Mar 2013 21:32:18 +0800
Message-ID: <1364218338.2532.15.camel@cr0>
References: <1363938600-26129-1-git-send-email-amwang@redhat.com>
	 <1364015648-4195-1-git-send-email-amwang@redhat.com>
	 <1364015648-4195-2-git-send-email-amwang@redhat.com>
	 <20130324.172403.776354963637295731.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, david.ward@ll.mit.edu, jorge@dti2.net
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:56926 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757941Ab3CYNce (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 25 Mar 2013 09:32:34 -0400
In-Reply-To: <20130324.172403.776354963637295731.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, 2013-03-24 at 17:24 -0400, David Miller wrote:
> From: Cong Wang <amwang@redhat.com>
> Date: Sat, 23 Mar 2013 13:14:08 +0800
> 
> > From: Cong Wang <amwang@redhat.com>
> > 
> > garp_pdu_queue() should ways be called with this spin lock.
> > garp_uninit_applicant() only holds rtnl lock which is not
> > enough here.
> > 
> > Found by code inspection.
> > 
> > Cc: "David S. Miller" <davem@davemloft.net>
> > Cc: David Ward <david.ward@ll.mit.edu>
> > Cc: "Jorge Boncompte [DTI2]" <jorge@dti2.net>
> > Signed-off-by: Cong Wang <amwang@redhat.com>
> 
> Under what conditions can entries be removed or added to
> these RB-trees without the RTNL being held?

At least garp_join_timer() calls garp_pdu_queue() in a timer:

static void garp_join_timer(unsigned long data)
{
        struct garp_applicant *app = (struct garp_applicant *)data;

        spin_lock(&app->lock);
        garp_gid_event(app, GARP_EVENT_TRANSMIT_PDU);
        garp_pdu_queue(app);
        spin_unlock(&app->lock);

        garp_queue_xmit(app);
        garp_join_timer_arm(app);
}

which I don't think can hold RTNL lock possibly.

> 
> If such events cannot happen, then no locking is needed.
> 
> Even if your change is correct and necessary, the answer to my
> needs to be added to your commit message.

Ok, I will.

Thanks.
