From: "Robert Iakobashvili" <coroberti@gmail.com>
Subject: Re: Network card IRQ balancing with Intel 5000 series chipsets
Date: Mon, 25 Dec 2006 13:26:17 +0200
Message-ID: <7e63f56c0612250326td172f28n532435b23d18b69f@mail.gmail.com>
References: <7e63f56c0612240134s452f6510h8483fb31e5efe799@mail.gmail.com>
	 <1167039303.3281.1574.camel@laptopd505.fenrus.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from nf-out-0910.google.com ([64.233.182.190]:44198 "EHLO
	nf-out-0910.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754450AbWLYL0T (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 25 Dec 2006 06:26:19 -0500
Received: by nf-out-0910.google.com with SMTP id o25so4449526nfa
        for <netdev@vger.kernel.org>; Mon, 25 Dec 2006 03:26:17 -0800 (PST)
To: "Arjan van de Ven" <arjan@infradead.org>
In-Reply-To: <1167039303.3281.1574.camel@laptopd505.fenrus.org>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi Arjan,

On 12/25/06, Arjan van de Ven <arjan@infradead.org> wrote:
> On Sun, 2006-12-24 at 11:34 +0200, Robert Iakobashvili wrote:
> > Sorry for repeating, now in text mode.
> >
> > Is there a way to balance IRQs from a network card among Intel CPU cores
> > with Intel 5000 series chipset?
> >
> > We tried the Broadcom network card (lspci is below) both in MSI and
> > io-apic mode, but found that the card interrupt may be moved to
> > another logical CPU, but not balanced among CPUs/cores.
> >
> > Is that a policy of Intel chipset, that linux cannot overwrite? Can it
> > be configured
> > somewhere and by which tools?
>
> first of all please don't use the in-kernel irqbalancer, use the
> userspace one from www.irqbalance.org instead...

Thanks, it was also attempted, but the result is not much different,
because, the problem seems to be in the chipset.

Kernel explicitly disables interrupt affinity for such Intel chipsets in
drivers/pci/quirk.c, unless BIOS enables such feature.
The question is not very much in linux, but rather in HW-area,
namely, Intel 5000 series chipset tuning for networking.


> Am I understanding you correctly that you want to spread the load of the
> networking IRQ roughly equally over 2 cpus (or cores or ..)?

Yes, 4 cores.

> If so, that is very very suboptimal, especially for networking (since
> suddenly a lot of packet processing gets to deal with out of order
> receives and cross-cpu reassembly).

Agree. Unfortunately, we have a flow of small RTP packets with heavy
processing and both Rx and Tx component on a single network card.
The application is not too much sensitive to the out of order, etc.
Thus, there 3 cores are actually doing nothing, whereas the CPU0
is overloaded, preventing system CPU scaling.

>
> As for the chipset capability; the behavior of the chipset you have is
> to prefer the first cpu of the programmed affinity mask. There are some
> ways to play with that but doing it on the granularity you seem to want
> is both not practical and too expensive anyway....

Agree. Particularly, for AMD NUMA I have used cpu affinity of a single card
to a single CPU. Unfortunately, our case now is the only network card with a
huge load of small RTP packets with both Rx and Tx.

Agree, that providing CPU affinity for a network interrupt is a rather
reasonable default.
However, should a chipset manufacture take from us the very freedom of
tuning, freedom of choice?

Referring to the paper below, it should be some option to balance CPU among
several CPU, which I fail to find.
http://download.intel.com/design/chipsets/applnots/31433702.pdf

> if you want to mail me at work (you don't), use arjan (at) linux.intel.com
> Test the interaction between Linux and your BIOS via http://www.linuxfirmwarekit.org

Thanks. I will look into this site.


-- 
Sincerely,
Robert Iakobashvili,
coroberti %x40 gmail %x2e com
...................................................................
Navigare necesse est, vivere non est necesse
...................................................................
http://sourceforge.net/projects/curl-loader
A powerful open-source HTTP/S, FTP/S traffic
generating, loading and testing tool.
