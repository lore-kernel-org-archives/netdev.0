From: Avi Kivity <avi@qumranet.com>
Subject: Re: [kvm-devel] QEMU PIC indirection patch for in-kernel APIC work
Date: Mon, 16 Apr 2007 08:13:28 +0300
Message-ID: <462305F8.3040202@qumranet.com>
References: <4613B438.60107@codemonkey.ws> <4613BC6B.1070708@codemonkey.ws>
 <4613BF07.50606@qumranet.com> <4613C993.9020405@codemonkey.ws>
 <4613CC01.1090500@qumranet.com> <4613CDB2.4000903@codemonkey.ws>
 <4613D001.3040606@qumranet.com> <20070404200112.GA6070@elte.hu>
 <4614098F.2030307@us.ibm.com> <20070404212103.GA19026@elte.hu>
 <1175728768.12230.593.camel@localhost.localdomain>
 <4614A294.3000607@qumranet.com>
 <1175821357.12230.642.camel@localhost.localdomain>
 <46187F4E.1080807@qumranet.com>
 <1176087018.11664.65.camel@localhost.localdomain>
 <4619E6DC.3010804@qumranet.com>
 <1176111984.11664.90.camel@localhost.localdomain>
 <461A41CA.9080201@qumranet.com>
 <1176263593.26372.84.camel@localhost.localdomain>
 <461C6360.1060908@qumranet.com>
 <1176297794.14322.72.camel@localhost.localdomain>
 <461CF098.3090003@qumranet.com>
 <1176334200.14322.133.camel@localhost.localdomain>
 <461DA849.50406@qumranet.com>
 <1176682966.14322.193.camel@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7BIT
Cc: Ingo Molnar <mingo@elte.hu>, kvm-devel@lists.sourceforge.net,
	netdev <netdev@vger.kernel.org>
To: Rusty Russell <rusty@rustcorp.com.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mtaout2.012.net.il ([84.95.2.4]:25460 "EHLO mtaout2.012.net.il"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753665AbXDPFNf (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 16 Apr 2007 01:13:35 -0400
Received: from firebolt.argo.co.il ([80.178.163.133])
 by i_mtaout2.012.net.il (HyperSendmail v2004.12)
 with ESMTP id <0JGK006BDS8RE2I0@i_mtaout2.012.net.il> for
 netdev@vger.kernel.org; Mon, 16 Apr 2007 08:22:08 +0300 (IDT)
In-reply-to: <1176682966.14322.193.camel@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Rusty Russell wrote:
> On Thu, 2007-04-12 at 06:32 +0300, Avi Kivity wrote:
>   
>> I hadn't considered an always-blocking (or unbuffered) networking API. 
>> It's very counter to current APIs, but does make sense with things like
>> syslets.  Without syslets, I don't think it's very useful as you need
>> some artificial threads to keep things humming along.
>>
>> (How would userspace specify it? O_DIRECT when opening the tap?)
>>     
>
> TBH, I hadn't thought that far.  Tap already has those IFF_NO_PI etc
> flags, but it might make sense to just be the default.  From userspace's
> POV it's not a semantic change.
>
> OK, just tested: I can get 230,000 packets (28 byte UDP) through the tun
> device in a second (130,000 actually out the 100-base-T NIC, 100,000
> dropped).  If the tun driver's write() blocks until the skb is
> destroyed, it's 4,000 packets.
>
> So your intuition was right: skb_free latency on xmit (at least for this
> e1000) is far too large for anything but an async solution.
>
> Will ponder further.
>   

I think aio_write (but done copyless-lessly) is the way to go.  Not only
is the infrastructure there, but the API already allows for multiple
packet submission and for batching completions.  Fitting into that
framework ought to be easier than starting yet another one.

It still misses scatter/gather and integration with fd-based
notification, but there are patches around for that.

-- 
Do not meddle in the internals of kernels, for they are subtle and quick to panic.

