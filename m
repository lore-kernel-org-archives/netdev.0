From: "Duyck, Alexander H" <alexander.h.duyck@intel.com>
Subject: RE: [PATCH take 2] pkt_sched: Fix qdisc_watchdog() vs.
	dev_deactivate() race
Date: Mon, 15 Sep 2008 16:44:08 -0700
Message-ID: <80769D7B14936844A23C0C43D9FBCF0F157D357E@orsmsx501.amr.corp.intel.com>
References: <20080912.184008.74354363.davem@davemloft.net>
 <20080913014800.GA10611@gondor.apana.org.au>
 <20080913205408.GA2545@ami.dom.local>
 <20080914061610.GA20571@gondor.apana.org.au>
 <5f2db9d90809140331k434b9944mf5edf16e3094f12c@mail.gmail.com>
 <20080914214331.GB2540@ami.dom.local>
 <20080914221341.GA1684@gondor.apana.org.au>
 <20080915060758.GA4112@ff.dom.local>
 <20080915061922.GA7262@gondor.apana.org.au>
 <20080915072008.GB4112@ff.dom.local> <20080915074536.GD4112@ff.dom.local>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: Alexander Duyck <alexander.duyck@gmail.com>,
	David Miller <davem@davemloft.net>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"kaber@trash.net" <kaber@trash.net>
To: Jarek Poplawski <jarkao2@gmail.com>,
	Herbert Xu <herbert@gondor.apana.org.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga02.intel.com ([134.134.136.20]:37484 "EHLO mga02.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753444AbYIOXoW convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 15 Sep 2008 19:44:22 -0400
In-Reply-To: <20080915074536.GD4112@ff.dom.local>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Jarek Poplawski wrote:
> On Mon, Sep 15, 2008 at 07:20:08AM +0000, Jarek Poplawski wrote:
> ...
>> Of course preserving a flow consistency is must-be here, but I think
>> there are rehashing algorithms used in similar cases (sch_sfq) which
>> take care for this. As a matter of fact, I've thought of requeuing as
>> a best place to detect possible problems, but now I see that
>> Alexander's proposal let's to do this simply by observing this
>> TCQ_F_STOPPED flag [...]
>
> Hmm... or maybe it doesn't? Since this is qdisc flag we don't know at
> the top which tx_queue is a problem at the bottom...
>
The problem is with the nature of a qdisc.  For example let's say we have a
prio qdisc with a packet in lowest priority that fails to be transmitted due
to a stopped subqueue.  If we add an skb for a non-stopped queue to a higher
prio then the qdisc should be no longer stopped since we can dequeue from the
ring and transmit.  Thus, keeping a memory of which queue is stopped may not be
useful in a situation such as this.

The only thing I really prefer about my solution as opposed to the solution
Dave implemented was that it would mean only one dequeue instead of a peek
followed by a dequeue.  I figure the important thing is to push the
discovery of us being stopped to as soon as possible in the process.

It will probably be a few days before I have a patch with my approach ready.
I didn't realize how complex it would be to resolve this issue for CBQ, HTB,
HFSC, etc.  Also it is starting to look like I will probably need to implement
another function to support this since it seems like the dequeue operations
would need to be split into a multiqueue safe version, and a standard version
to support some workarounds like those found in qdisc_peek_len() for HFSC.

Thanks,

Alex

