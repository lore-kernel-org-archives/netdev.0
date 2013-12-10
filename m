From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: RE: NAPI rescheduling and the delay caused by it
Date: Mon, 09 Dec 2013 17:14:25 -0800
Message-ID: <1386638065.30495.338.camel@edumazet-glaptop2.roam.corp.google.com>
References: <529F7A87.5080303@citrix.com>
	 <1386189718.30495.131.camel@edumazet-glaptop2.roam.corp.google.com>
	 <529F9D4B.1020208@citrix.com>
	 <1386199931.30495.139.camel@edumazet-glaptop2.roam.corp.google.com>
	 <6F39C955CEA9D14BAA91CC78568B93012D5039@AMSPEX01CL02.citrite.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"xen-devel@lists.xenproject.org" <xen-devel@lists.xenproject.org>,
	Malcolm Crossley <malcolm.crossley@citrix.com>,
	Jonathan Davies <Jonathan.Davies@citrix.com>,
	Paul Durrant <Paul.Durrant@citrix.com>,
	Wei Liu <wei.liu2@citrix.com>,
	Ian Campbell <Ian.Campbell@citrix.com>
To: Zoltan Kiss <zoltan.kiss@citrix.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-yh0-f47.google.com ([209.85.213.47]:58559 "EHLO
	mail-yh0-f47.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750881Ab3LJBO2 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 9 Dec 2013 20:14:28 -0500
Received: by mail-yh0-f47.google.com with SMTP id 29so3406421yhl.34
        for <netdev@vger.kernel.org>; Mon, 09 Dec 2013 17:14:28 -0800 (PST)
In-Reply-To: <6F39C955CEA9D14BAA91CC78568B93012D5039@AMSPEX01CL02.citrite.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 2013-12-09 at 23:39 +0000, Zoltan Kiss wrote:
> Hi,
> 
> I tried that, it didn't help in my case. I think
> xenvif_notify_tx_completion is only a shortcut to wake the queue
> earlier. Otherwise we should wait for the interrupt from the guest to
> arrive (see rx_interrupt), however we know it can be done. Or does
> this call from the kernel thread makes things worse than a later call
> from the interrupt context?

Well, the call through ksoftirqd only adds some latency, and extra
context switch. This is delayed by the time your current process exits
the kernel (or you need CONFIG_PREEMPT)

> I found another suspect however: my grant mapping patches do the
> unmapping from the NAPI instance where otherwise we receive the
> packets from the guest. But this means we call napi_schedule from the
> zerocopy callback, which can be run by anyone who free up that skb,
> including an another VIF's RX thread (which actually does the transmit
> TO the guest). I guess that might be bad.

Same problem : napi_schedule() is meant to be used from interrupt
context.
