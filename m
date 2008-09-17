From: "Alexander Duyck" <alexander.duyck@gmail.com>
Subject: Re: [PATCH take 2] pkt_sched: Fix qdisc_watchdog() vs. dev_deactivate() race
Date: Tue, 16 Sep 2008 19:31:31 -0700
Message-ID: <5f2db9d90809161931n57b41e68j492b58de6bc5c6b9@mail.gmail.com>
References: <20080913205408.GA2545@ami.dom.local>
	 <5f2db9d90809140331k434b9944mf5edf16e3094f12c@mail.gmail.com>
	 <20080914214331.GB2540@ami.dom.local>
	 <20080914221341.GA1684@gondor.apana.org.au>
	 <20080915060758.GA4112@ff.dom.local>
	 <20080915061922.GA7262@gondor.apana.org.au>
	 <20080915072008.GB4112@ff.dom.local>
	 <20080915074536.GD4112@ff.dom.local>
	 <80769D7B14936844A23C0C43D9FBCF0F157D357E@orsmsx501.amr.corp.intel.com>
	 <20080916104756.GA10965@ff.dom.local>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: "Duyck, Alexander H" <alexander.h.duyck@intel.com>,
	"Herbert Xu" <herbert@gondor.apana.org.au>,
	"David Miller" <davem@davemloft.net>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"kaber@trash.net" <kaber@trash.net>
To: "Jarek Poplawski" <jarkao2@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from wf-out-1314.google.com ([209.85.200.169]:39146 "EHLO
	wf-out-1314.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752500AbYIQCbb (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 16 Sep 2008 22:31:31 -0400
Received: by wf-out-1314.google.com with SMTP id 27so2814518wfd.4
        for <netdev@vger.kernel.org>; Tue, 16 Sep 2008 19:31:31 -0700 (PDT)
In-Reply-To: <20080916104756.GA10965@ff.dom.local>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Sep 16, 2008 at 3:47 AM, Jarek Poplawski <jarkao2@gmail.com> wrote:
> On Mon, Sep 15, 2008 at 04:44:08PM -0700, Duyck, Alexander H wrote:
> ...
>> The only thing I really prefer about my solution as opposed to the solution
>> Dave implemented was that it would mean only one dequeue instead of a peek
>> followed by a dequeue.  I figure the important thing is to push the
>> discovery of us being stopped to as soon as possible in the process.
>>
>> It will probably be a few days before I have a patch with my approach ready.
>> I didn't realize how complex it would be to resolve this issue for CBQ, HTB,
>> HFSC, etc.  Also it is starting to look like I will probably need to implement
>> another function to support this since it seems like the dequeue operations
>> would need to be split into a multiqueue safe version, and a standard version
>> to support some workarounds like those found in qdisc_peek_len() for HFSC.
>
> Actually, looking at this HFSC now I start to doubt we need to
> complicate these things so much. If HFSC is OK with its simple
> hfsc_requeue() I doubt other qdiscs need much more, and we should
> reconsider David's idea to do the same on top, in dev_requeue_skb().
> Qdiscs like multiq would probably never use this, and these above
> mentioned (not mq-optimized) qdiscs could be used with multiq if
> needed. Then, it seems, it would be enough to improve multiq as a
> "leaf" adding these dedicated operations and/or flags.
>
> Thanks,
> Jarek P.
>

I am just not convinced that the requeue approach will work very well.  I am
just starting to test my patch today and the cpu savings were pretty significant
against the current configuration when using just the standard prio qdisc on a
multiqueue device.

I setup a simple test running a neterf UDP_STREAM test from my test system to
one of my clients sending 1460 byte UDP messages at line rate on an 82575
with 4 tx queues enabled.  The current dequeue/requeue approach used 2.5% cpu
whenever the test was run through queue 0, but if I ended up with packets going
out one of the other queues the cpu utilization would jump to ~12.5%.  The same
test done using my patch showed ~2.5% for every queue I tested.

I will hopefully have the patch ready to submit for comments tomorrow.  I just
need to run a few tests with the patch on versus the patch off to
verify that I didn't
break any of the qdiscs and that there isn't any negative performance impact.

Thanks,

Alex
