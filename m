From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 0/9 Rev3] Implement batching skb API and support in
 IPoIB
Date: Sun, 26 Aug 2007 19:04:20 -0700 (PDT)
Message-ID: <20070826.190420.41652839.davem@davemloft.net>
References: <46CF7B13.3020701@psc.edu>
	<20070826044134.eabd18cf.billfink@mindspring.com>
	<46D229AA.6020900@psc.edu>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: billfink@mindspring.com, rick.jones2@hp.com, hadi@cyberus.ca,
	krkumar2@in.ibm.com, gaagaan@gmail.com,
	general@lists.openfabrics.org, herbert@gondor.apana.org.au,
	jagana@us.ibm.com, jeff@garzik.org, johnpol@2ka.mipt.ru,
	kaber@trash.net, mcarlson@broadcom.com, mchan@broadcom.com,
	netdev@vger.kernel.org, peter.p.waskiewicz.jr@intel.com,
	rdreier@cisco.com, Robert.Olsson@data.slu.se,
	shemminger@linux-foundation.org, sri@us.ibm.com, tgraf@suug.ch,
	xma@us.ibm.com
To: jheffner@psc.edu
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:43733
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1754015AbXH0CEW (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 26 Aug 2007 22:04:22 -0400
In-Reply-To: <46D229AA.6020900@psc.edu>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: John Heffner <jheffner@psc.edu>
Date: Sun, 26 Aug 2007 21:32:26 -0400

> There are a few interesting things here.  For one, the bursts caused by 
> TSO seem to be causing the receiver to do stretch acks.  This may have a 
> negative impact on flow performance, but it's hard to say for sure how 
> much.  Interestingly, it will even further reduce the CPU load on the 
> sender, since it has to process fewer acks.
> 
> As I suspected, in the non-TSO case the receiver gets lots of packets 
> directly queued to user.  This should result in somewhat lower CPU 
> utilization on the receiver.  I don't know if it can account for all the 
> difference you see.

I had completely forgotten these stretch ACK and ucopy issues.

When the receiver gets inundated with a backlog of receive
queue packets, it just spins there copying into userspace
_every_ _single_ packet in that queue, then spits out one ACK.

Meanwhile the sender has to pause long enough for the pipe to empty
slightly.

The transfer is much better behaved if we ACK every two full sized
frames we copy into the receiver, and therefore don't stretch ACK, but
at the cost of cpu utilization.

These effects are particularly pronounced on systems where the
bus bandwidth is also one of the limiting factors.
