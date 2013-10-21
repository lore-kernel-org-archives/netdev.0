From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH RFC 5/5] net:stmmac: asynchronous tx_clean
Date: Mon, 21 Oct 2013 09:30:05 -0700
Message-ID: <1382373005.3284.61.camel@edumazet-glaptop.roam.corp.google.com>
References: <1381937052-8999-1-git-send-email-jimmy.perchet@parrot.com>
	 <1381937052-8999-6-git-send-email-jimmy.perchet@parrot.com>
	 <5265318C.5050307@st.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Jimmy Perchet <jimmy.perchet@parrot.com>, netdev@vger.kernel.org
To: Giuseppe CAVALLARO <peppe.cavallaro@st.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f44.google.com ([209.85.220.44]:56433 "EHLO
	mail-pa0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751305Ab3JUQaH (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 21 Oct 2013 12:30:07 -0400
Received: by mail-pa0-f44.google.com with SMTP id fb1so5302002pad.31
        for <netdev@vger.kernel.org>; Mon, 21 Oct 2013 09:30:07 -0700 (PDT)
In-Reply-To: <5265318C.5050307@st.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 2013-10-21 at 15:52 +0200, Giuseppe CAVALLARO wrote:
> Hello Jimmy
> 
> On 10/16/2013 5:24 PM, Jimmy Perchet wrote:
> > Tx descriptor's cleanup and preparation are serialized, which is not necessary
> > and decrease performance.
> > In addition TX descriptor's cleanup is performed on NET_RX softirq, this is
> > confusing.
> 
> hmm, here you are changing the logic behind the tx/rx processes.
> 
> As done in many drivers, the stmmac cleans the tx resources in
> NAPI context and this is not a confuse approach ;-).
> 
> It gave me some performance improvements especially on TCP benchmarks.
> 
> > This patch unserialize tx descriptor's cleanup and preparation
> > and defer cleanup in workqueue.
> 
> So you decide to use workqueue and I kindly ask you to give me more
> details about the performance improvements (UDP/TCP) and cpu usage.
> 
> I can try to do some tests on my side too. This could take a while
> unfortunately.

Anyway this patch is buggy.

1) Removing tx_lock spinlock in TX completion adds a race in
stmmac_xmit()

2) Generally speaking, we should not rely on a work queue to perform TX
completions.

Think about being flooded by incoming frames.

Work queue could never be scheduled.
