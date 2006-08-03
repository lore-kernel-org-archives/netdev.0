From: "Michael Chan" <mchan@broadcom.com>
Subject: Re: [PATCH] [e1000]: Remove unnecessary tx_lock
Date: Thu, 03 Aug 2006 11:05:02 -0700
Message-ID: <1154628302.3117.15.camel@rh4>
References: <E1G8dmn-0001hH-00@gondolin.me.apana.org.au>
 <Pine.WNT.4.63.0608030925100.3396@jbrandeb-desk.amr.corp.intel.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: "Herbert Xu" <herbert@gondor.apana.org.au>, hadi@cyberus.ca,
	auke-jan.h.kok@intel.com, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms2.broadcom.com ([216.31.210.18]:27145 "EHLO
	mms2.broadcom.com") by vger.kernel.org with ESMTP id S1751290AbWHCSDU
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 3 Aug 2006 14:03:20 -0400
To: "Brandeburg, Jesse" <jesse.brandeburg@intel.com>
In-Reply-To: <Pine.WNT.4.63.0608030925100.3396@jbrandeb-desk.amr.corp.intel.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, 2006-08-03 at 09:36 -0700, Brandeburg, Jesse wrote:

> I followed the example of tg3 when attempting to optimize this code.  For 
> the normal case we remove a lock acquisition.  Jamals case is not normal. 
> :-)
> 
> we specifically added this lock originally to fix a problem we saw where 
> the netif_stop and netif_start would race, and we would end up with a 
> queue that was stopped, and no way to restart it because we didn't have 
> any more TX packets to clean up (even if we DID get an interrupt from a 
> receive)
> 
Yep, I agree that the lock is necessary.  The reason is that
hard_start_xmit and xmit_completion can be running concurrently and they
can miss each other and cause the tx ring to be stopped forever.

In the case of tg3's hard_start_xmit, after stopping the queue, we need
to check if we should wake the queue right away in case xmit_completion
just finished cleaning the tx ring and just missed the queue_stopped
condition.  Because the netif_wake_queue can be called in 2 places, you
need the lock.  Without the lock, the queue can be waken up at the wrong
time and may cause hard_start_xmit to be called with an empty tx ring.

