From: Jeff Garzik <jeff@garzik.org>
Subject: Re: [PATCH 2/3][NET_BATCH] net core use batching
Date: Mon, 08 Oct 2007 21:13:59 -0400
Message-ID: <470AD5D7.1070000@garzik.org>
References: <1191868010.4335.33.camel@localhost>	 <D5C1322C3E673F459512FB59E0DDC32903BC1234@orsmsx414.amr.corp.intel.com>	 <1191876530.4373.58.camel@localhost>	 <D5C1322C3E673F459512FB59E0DDC32903BC14AC@orsmsx414.amr.corp.intel.com> <1191886845.4373.138.camel@localhost>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: "Waskiewicz Jr, Peter P" <peter.p.waskiewicz.jr@intel.com>,
	David Miller <davem@davemloft.net>, krkumar2@in.ibm.com,
	johnpol@2ka.mipt.ru, herbert@gondor.apana.org.au, kaber@trash.net,
	shemminger@linux-foundation.org, jagana@us.ibm.com,
	Robert.Olsson@data.slu.se, rick.jones2@hp.com, xma@us.ibm.com,
	gaagaan@gmail.com, netdev@vger.kernel.org, rdreier@cisco.com,
	mcarlson@broadcom.com, mchan@broadcom.com,
	general@lists.openfabrics.org, tgraf@suug.ch,
	randy.dunlap@oracle.com, sri@us.ibm.com
To: hadi@cyberus.ca
Return-path: <netdev-owner@vger.kernel.org>
Received: from srv5.dvmed.net ([207.36.208.214]:53580 "EHLO mail.dvmed.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751336AbXJIBP1 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 8 Oct 2007 21:15:27 -0400
In-Reply-To: <1191886845.4373.138.camel@localhost>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

jamal wrote:
> Ok, so the "concurency" aspect is what worries me. What i am saying is
> that sooner or later you have to serialize (which is anti-concurency)
> For example, consider CPU0 running a high prio queue and CPU1 running
> the low prio queue of the same netdevice.
> Assume CPU0 is getting a lot of interupts or other work while CPU1
> doesnt (so as to create a condition that CPU1 is slower). Then as long
> as there packets and there is space on the drivers rings, CPU1 will send
> more packets per unit time than CPU0.
> This contradicts the strict prio scheduler which says higher priority
> packets ALWAYS go out first regardless of the presence of low prio
> packets.  I am not sure i made sense.

You made sense.  I think it is important to note simply that the packet 
scheduling algorithm itself will dictate the level of concurrency you 
can achieve.

Strict prio is fundamentally an interface to a big imaginary queue, with 
multiple packet insertion points (the individual bands/rings for each 
prio band).

If you assume a scheduler implementation where each prio band is mapped 
to a separate CPU, you can certainly see where some CPUs could be 
substantially idle while others are overloaded, largely depending on the 
data workload (and priority contained within).

Moreover, you increase L1/L2 cache traffic, not just because of locks, 
but because of data dependencies:

	user	prio	packet		NIC TX ring
	process	band	scheduler

	cpu7	1	cpu1		1
	cpu5	1	cpu1		1
	cpu2	0	cpu0		0

At that point, it is probably more cache- and lock-friendly to keep the 
current TX softirq scheme.

In contrast, a pure round-robin approach is more friendly to concurrency.

	Jeff


