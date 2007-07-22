From: Patrick McHardy <kaber@trash.net>
Subject: Re: [ofa-general] Re: [PATCH 05/10] sch_generic.c changes.
Date: Sun, 22 Jul 2007 19:03:01 +0200
Message-ID: <46A38DC5.4040800@trash.net>
References: <OF206CB1B7.31D1C39B-ON6525731F.00254E4C-6525731F.00261F1A@in.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15
Content-Transfer-Encoding: 7bit
Cc: jagana@us.ibm.com, johnpol@2ka.mipt.ru,
	herbert@gondor.apana.org.au, gaagaan@gmail.com,
	Robert.Olsson@data.slu.se, kumarkr@linux.ibm.com,
	rdreier@cisco.com, peter.p.waskiewicz.jr@intel.com,
	hadi@cyberus.ca, mcarlson@broadcom.com, jeff@garzik.org,
	general@lists.openfabrics.org, mchan@broadcom.com, tgraf@suug.ch,
	netdev@vger.kernel.org, davem@davemloft.net, sri@us.ibm.com
To: Krishna Kumar2 <krkumar2@in.ibm.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:43965 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753957AbXGVRFM (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 22 Jul 2007 13:05:12 -0400
In-Reply-To: <OF206CB1B7.31D1C39B-ON6525731F.00254E4C-6525731F.00261F1A@in.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Krishna Kumar2 wrote:
> Patrick McHardy <kaber@trash.net> wrote on 07/20/2007 11:46:36 PM:
> 
>>The check for tx_queue_len is wrong though,
>>its only a default which can be overriden and some qdiscs don't
>>care for it at all.
> 
> 
> I think it should not matter whether qdiscs use this or not, or even if it
> is modified (unless it is made zero in which case this breaks). The
> intention behind this check is to make sure that not more than tx_queue_len
> skbs are in all queues put together (q->qdisc + dev->skb_blist), otherwise
> the blist can become too large and breaks the idea of tx_queue_len. Is that
> a good justification ?


Its a good justification, but on second thought the entire idea of
a single queue after qdiscs that is refilled independantly of
transmissions times etc. make be worry a bit. By changing the
timing you're effectively changing the qdiscs behaviour, at least
in some cases. SFQ is a good example, but I believe it affects most
work-conserving qdiscs. Think of this situation:

100 packets of flow 1 arrive
50 packets of flow 1 are sent
100 packets for flow 2 arrive
remaining packets are sent

On the wire you'll first see 50 packets of flow 1, than 100 packets
alternate of flow 1 and 2, then 50 packets flow 2.

With your additional queue all packets of flow 1 are pulled out of
the qdisc immediately and put in the fifo. When the 100 packets of
the second flow arrive they will also get pulled out immediately
and are put in the fifo behind the remaining 50 packets of flow 1.
So what you get on the wire is:

100 packets of flow 1
100 packets of flow 1

So SFQ is without any effect. This is not completely avoidable of
course, but you can and should limit the damage by only pulling
out as much packets as the driver can take and have the driver
stop the queue afterwards.

