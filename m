From: "Michael Chan" <mchan@broadcom.com>
Subject: Re: [PATCH] [e1000]: Remove unnecessary tx_lock
Date: Thu, 3 Aug 2006 21:06:30 -0700
Message-ID: <1551EAE59135BE47B544934E30FC4FC093FA12@NT-IRVA-0751.brcm.ad.broadcom.com>
References: <1154654164.5187.28.camel@jzny2>
Mime-Version: 1.0
Content-Type: text/plain;
 charset=us-ascii
Content-Transfer-Encoding: 8BIT
Cc: "Brandeburg, Jesse" <jesse.brandeburg@intel.com>,
	"Herbert Xu" <herbert@gondor.apana.org.au>,
	auke-jan.h.kok@intel.com, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms1.broadcom.com ([216.31.210.17]:61710 "EHLO
	mms1.broadcom.com") by vger.kernel.org with ESMTP id S1751421AbWHDEHs convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 4 Aug 2006 00:07:48 -0400
Content-class: urn:content-classes:message
In-Reply-To: <1154654164.5187.28.camel@jzny2>
To: hadi@cyberus.ca
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Jamal wrote:

>     tg3_start_xmit():
>     
>       prepare skb                       
>       grab ring tx lock irq safe
>       put skb on ring
>       if (full-ring)
>           stop
>       release ring tx lock and restore flags blah 


The whole point of doing things the way it is done in tg3
is to avoid taking the lock unless there is a need to stop
the queue or wake the queue.

With a 511 entry send ring in tg3, filling the entire tx
ring should not happen all the time.  Even if we fill the
tx ring constantly, the hysteresis effect of waking the
queue only after the tx ring is 3/4 empty will make it
uncommon to do stop_queue and wake_queue.  So it is the
right thing to do to optimize for the case where the
ring is not full.  The penalty is that we need some extra
checking after stopping the queue which should be the
uncommon case.

