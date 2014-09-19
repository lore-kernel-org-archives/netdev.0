From: Jamal Hadi Salim <jhs@mojatatu.com>
Subject: Re: qdisc/trafgen: Measuring effect of qdisc bulk dequeue, with trafgen
Date: Fri, 19 Sep 2014 07:57:37 -0400
Message-ID: <541C1A31.3000401@mojatatu.com>
References: <20140919123536.636fa226@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@davemloft.net>,
	Tom Herbert <therbert@google.com>,
	Hannes Frederic Sowa <hannes@stressinduktion.org>,
	Florian Westphal <fw@strlen.de>,
	Daniel Borkmann <dborkman@redhat.com>,
	Alexander Duyck <alexander.duyck@gmail.com>,
	John Fastabend <john.r.fastabend@intel.com>
To: Jesper Dangaard Brouer <jbrouer@redhat.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ie0-f169.google.com ([209.85.223.169]:57833 "EHLO
	mail-ie0-f169.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753558AbaISL5l (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 19 Sep 2014 07:57:41 -0400
Received: by mail-ie0-f169.google.com with SMTP id rp18so1277601iec.0
        for <netdev@vger.kernel.org>; Fri, 19 Sep 2014 04:57:40 -0700 (PDT)
In-Reply-To: <20140919123536.636fa226@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 09/19/14 06:35, Jesper Dangaard Brouer wrote:
>
> This experiment were about finding the tipping-point, when bulking
> from the qdisc kicks in.  This is an artificial benchmark.
>
> This testing relates to my qdisc bulk dequeue patches:
>   http://thread.gmane.org/gmane.linux.network/328829/focus=328951
>
> My point have always been, we should only start bulking packets when
> really needed, I dislike attempts to delay TX in antisipation of
> packets arriving shortly (due to the added latency).  IMHO the qdisc
> layer seems the right place "see" when bulking makes sense.
>
> The reason behind this test is, there is two code paths in the qdisc
> layer.  1) when qdisc is empty we allow packet to directly call
> sch_direct_xmit(), 2) when qdisc contains packet we go through a more
> expensive process of enqueue, dequeue and possibly rescheduling a
> softirq.
>
> Thus, the cost when the qdisc kicks-in should be slightly higher.  My
> qdisc bulk dequeue patch, should help us actually getting faster in
> this case.  Below results (with dequeue bulking max 4 packets) show
> that, this was true, as expected the locking cost were reduced, giving
> us an actual speedup.
>
>
> Testing this tipping point is hard, but found an trafgen setup, that
> were just balancing on this tipping point, single CPU 1Gbit/s setup
> driver igb.
>

The feedback system is clearly very well oiled. Or is it now? ;->
Jesper, maybe you need to poke at system level as opposed to
microscopic lock level. The transmit path is essentially kicked by
tx softirq which is driven by rx path etc. And those guys work like
a clock pendulum.
To busy that sucker, You may be able to get more luck with
forwarding kind of traffic.
Funnel traffic from many nic ports tied to different CPUs to one egress
port.
Some coffee helped me remember i actually surrendered that it can be
done at all in netconf 2011[1] but please let me not poison your
thinking - you may find otherwise.

cheers,
jamal

http://vger.kernel.org/netconf2011_slides/jamal_netconf2011.pdf slide 12
