From: David Miller <davem@davemloft.net>
Subject: Re: tbench regression in 2.6.25-rc1
Date: Fri, 15 Feb 2008 15:22:00 -0800 (PST)
Message-ID: <20080215.152200.145584182.davem@davemloft.net>
References: <47B52B95.3070607@cosmosbay.com>
	<1203057044.3027.134.camel@ymzhang>
	<47B59FFC.4030603@cosmosbay.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: yanmin_zhang@linux.intel.com, herbert@gondor.apana.org.au,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org
To: dada1@cosmosbay.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:59391
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1752725AbYBOXV1 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 15 Feb 2008 18:21:27 -0500
In-Reply-To: <47B59FFC.4030603@cosmosbay.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <dada1@cosmosbay.com>
Date: Fri, 15 Feb 2008 15:21:48 +0100

> On linux-2.6.25-rc1 x86_64 :
> 
> offsetof(struct dst_entry, lastuse)=0xb0
> offsetof(struct dst_entry, __refcnt)=0xb8
> offsetof(struct dst_entry, __use)=0xbc
> offsetof(struct dst_entry, next)=0xc0
> 
> So it should be optimal... I dont know why tbench prefers __refcnt being 
> on 0xc0, since in this case lastuse will be on a different cache line...
> 
> Each incoming IP packet will need to change lastuse, __refcnt and __use, 
> so keeping them in the same cache line is a win.
> 
> I suspect then that even this patch could help tbench, since it avoids 
> writing lastuse...

I think your suspicions are right, and even moreso
it helps to keep __refcnt out of the same cache line
as input/output/ops which are read-almost-entirely :-)

I haven't done an exhaustive analysis, but it seems that
the write traffic to lastuse and __refcnt are about the
same.  However if we find that __refcnt gets hit more
than lastuse in this workload, it explains the regression.


