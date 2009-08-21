From: Ron Mercer <ron.mercer@qlogic.com>
Subject: Re: [net-next PATCH 1/3] qlge: Move TX completion processing to
	send path.
Date: Fri, 21 Aug 2009 10:23:01 -0700
Message-ID: <20090821172301.GB12770@linux-ox1b.qlogic.org>
References: <1250725991-7155-1-git-send-email-ron.mercer@qlogic.com> <1250725991-7155-2-git-send-email-ron.mercer@qlogic.com> <20090820.021854.254431313.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	shashank.pandhare@qlogic.com, jagannatha.narayanaswami@qlogic.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from avexch1.qlogic.com ([198.70.193.115]:28985 "EHLO
	avexch1.qlogic.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932813AbZHUR2j (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 21 Aug 2009 13:28:39 -0400
Content-Disposition: inline
In-Reply-To: <20090820.021854.254431313.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Aug 20, 2009 at 02:18:54AM -0700, David Miller wrote:
> From: Ron Mercer <ron.mercer@qlogic.com>
> Date: Wed, 19 Aug 2009 16:53:09 -0700
> 
> > @@ -1205,6 +1205,7 @@ struct bq_desc {
> >  };
> >  
> >  #define QL_TXQ_IDX(qdev, skb) (smp_processor_id()%(qdev->tx_ring_count))
> > +#define TXQ_CLEAN_TIME (HZ/4)
> >  
> >  struct tx_ring {
> >  	/*
> 
> Running this every 1/4 of a second, even when no TX activity is
> happening, is very bad for power management.
> 
> And starting the timer in response to whether there are TX queue
> entries active or not will add overhead and races.
> 
> This really isn't workable.
> 
> I really and truly believe that the best place for this is in NAPI
> context.  So bring back the MSI-X vector for TX completions, and
> make it schedule a NAPI poll.

I can see your point about not wanting all the drivers popping a timer
for each TX queue.  Though I don't see the race condition since the
handler would be protected by netdev_queue->_xmit_lock.

I'll move TX completions into NAPI as you indicated.  I still need to
dedicate the MSIX vectors to RSS, but I will give each vector a number
of TX rings to service in NAPI as well.
Our card is a 4 function card and on
powerpc there are only 8 vectors per device which get divided up among the
functions, netting us 2 vectors total. That is what precipitated moving
the TX completion handling to send path and timer.


