From: David Miller <davem@davemloft.net>
Subject: Re: [ofa-general] Re: [PATCH 2/3][NET_BATCH] net core use batching
Date: Wed, 10 Oct 2007 02:25:50 -0700 (PDT)
Message-ID: <20071010.022550.21928751.davem@davemloft.net>
References: <20071010003716.GB552@one.firstfloor.org>
	<20071009.175025.59469417.davem@davemloft.net>
	<20071010091644.GA9807@one.firstfloor.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: hadi@cyberus.ca, shemminger@linux-foundation.org, jeff@garzik.org,
	johnpol@2ka.mipt.ru, herbert@gondor.apana.org.au,
	gaagaan@gmail.com, Robert.Olsson@data.slu.se,
	netdev@vger.kernel.org, rdreier@cisco.com,
	peter.p.waskiewicz.jr@intel.com, mcarlson@broadcom.com,
	jagana@us.ibm.com, general@lists.openfabrics.org,
	mchan@broadcom.com, tgraf@suug.ch, randy.dunlap@oracle.com,
	sri@us.ibm.com, kaber@trash.net
To: andi@firstfloor.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:49052
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1752137AbXJJJZs (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 10 Oct 2007 05:25:48 -0400
In-Reply-To: <20071010091644.GA9807@one.firstfloor.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Andi Kleen <andi@firstfloor.org>
Date: Wed, 10 Oct 2007 11:16:44 +0200

> > A 256 entry TX hw queue fills up trivially on 1GB and 10GB, but if you
> 
> With TSO really? 

Yes.

> > increase the size much more performance starts to go down due to L2
> > cache thrashing.
> 
> Another possibility would be to consider using cache avoidance
> instructions while updating the TX ring (e.g. write combining 
> on x86) 

The chip I was working with at the time (UltraSPARC-IIi) compressed
all the linear stores into 64-byte full cacheline transactions via
the store buffer.

It's true that it would allocate in the L2 cache on a miss, which
is different from your suggestion.

In fact, such a thing might not pan out well, because most of the time
you write a single descriptor or two, and that isn't a full cacheline,
which means a read/modify/write is the only coherent way to make such
a write to RAM.

Sure you could batch, but I'd rather give the chip work to do unless
I unequivocably knew I'd have enough pending to fill a cacheline's
worth of descriptors.  And since you suggest we shouldn't queue in
software... :-)
