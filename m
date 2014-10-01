From: Jesper Dangaard Brouer <brouer@redhat.com>
Subject: Re: [net-next PATCH V5] qdisc: bulk dequeue support for qdiscs with
 TCQ_F_ONETXQUEUE
Date: Wed, 1 Oct 2014 19:28:40 +0200
Message-ID: <20141001192840.5679a671@redhat.com>
References: <20140930085114.24043.81310.stgit@dragon>
	<542A8EF9.10403@mojatatu.com>
	<20140930.142038.235338672810639160.davem@davemloft.net>
	<542BFEF3.7020302@mojatatu.com>
	<CA+mtBx8rVu9FXtnc18n22L9LP=t=3Pso7U2yvvLcnny57w8aXg@mail.gmail.com>
	<542C1F1F.90404@mojatatu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Tom Herbert <therbert@google.com>,
	David Miller <davem@davemloft.net>,
	Linux Netdev List <netdev@vger.kernel.org>,
	Eric Dumazet <eric.dumazet@gmail.com>,
	Hannes Frederic Sowa <hannes@stressinduktion.org>,
	Florian Westphal <fw@strlen.de>,
	Daniel Borkmann <dborkman@redhat.com>,
	Alexander Duyck <alexander.duyck@gmail.com>,
	John Fastabend <john.r.fastabend@intel.com>,
	Dave Taht <dave.taht@gmail.com>,
	Toke =?UTF-8?B?SMO4aWxhbmQtSsO4cmdlbnNl?= =?UTF-8?B?bg==?=
	<toke@toke.dk>, brouer@redhat.com
To: Jamal Hadi Salim <jhs@mojatatu.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:37266 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753232AbaJAR3D (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 1 Oct 2014 13:29:03 -0400
In-Reply-To: <542C1F1F.90404@mojatatu.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


On Wed, 01 Oct 2014 11:34:55 -0400 Jamal Hadi Salim <jhs@mojatatu.com> wrote:

> The issue is: if i am going to attempt to do a bulk transfer
> every single time (with new code) and for the common use case the
> result is "no need to do bulking" then you just added extra code that
> is unnecessary for that common case.
> Even a single extra if statement at high packet rate is still
> costly and would be easy to observe.
[...]
>
> That is if the added code ends up being hit
> meaningfully. Jesper said (and it was my experience as well)
> that it was _hard_ to achieve bulking in such a case.

Let me close this one...

The bulk dequeue code *is* being hit meaningfully.  It is _only_ going
to be activated when (q->qlen > 0) see __dev_xmit_skb() in dev.c.
When there is no queue pfifo_fast is allowed to directly call
sch_direct_xmit() without a enqueue/dequeue cycle.  Thus, this code
would not be hit for every packet.

Thus, code is activated only when q->qlen is >= 1. And I have already
shown that we see a win with just bulking 2 packets:
 "Subject: qdisc/UDP_STREAM: measuring effect of qdisc bulk dequeue"
 http://thread.gmane.org/gmane.linux.network/331152/focus=331154

I actually believe, that I have already measured and shown that going
though the bulk dequeue is a win, this should show direct_xmit vs.
bulking:
 "Subject: qdisc/trafgen: Measuring effect of qdisc bulk dequeue, with trafgen"
 http://thread.gmane.org/gmane.linux.network/331152

-- 
Best regards,
  Jesper Dangaard Brouer
  MSc.CS, Sr. Network Kernel Developer at Red Hat
  Author of http://www.iptv-analyzer.org
  LinkedIn: http://www.linkedin.com/in/brouer
