From: Krzysztof Halasa <khc@pm.waw.pl>
Subject: Re: Strange network timeouts w/ 2.6.30.5
Date: Thu, 20 Aug 2009 11:03:09 +0200
Message-ID: <m3my5ueu2a.fsf@intrepid.localdomain>
References: <1762204735.01250727555803.JavaMail.root@mail.holmansrus.com>
	<2087985663.21250727676944.JavaMail.root@mail.holmansrus.com>
	<20090819.211736.222582824.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org
To: walt@holmansrus.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from khc.piap.pl ([195.187.100.11]:53249 "EHLO khc.piap.pl"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752809AbZHTJDK (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 20 Aug 2009 05:03:10 -0400
In-Reply-To: <20090819.211736.222582824.davem@davemloft.net> (David Miller's message of "Wed\, 19 Aug 2009 21\:17\:36 -0700 \(PDT\)")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> Since patching to 2.6.30.5 I'm experiencing periodic timeouts on my
> e100 which is used as my WAN interface on a server/router box. Nothing
> is reported in any logs and eventually the traffic resumes. It seems
> to happen at fairly regular intervals, although I've not timed them.
> The timeouts last for approx. 60-120 seconds and then traffic resumes
> normally with no hint of what happened.

x86-64, intel P965...

Can you provide "dmesg" output, please?

I wonder what additional side effect did the patch cause. Streaming
allocs on such x86 should already be coherent, no?

Perhaps you have more than 2 GB RAM (or so) and swiotlb has to provide
buffering? I think of something like:

- the driver does "sync for CPU" and examines status
- the descriptor is tested to be still empty
- meanwhile e100 chip changes the status in the descriptor
- the driver does "sync for device" (it's what the patch added)
- at this point swiotlb doesn't know the descriptor is clean and writes
  it out, thus dropping the change done by the e100 chip.

Does the above seem plausible? I admit I'm not swiotlb expert, it's
a pure guess that it simply and blindly moves data in and out.

If that's the case, I don't really know how could it work without the
patch in question. Perhaps the timings were just right?

What can we do with it? Rewriting to use consistent allocs, of course.
Temporarily adding #ifdef CONFIG_ARM around the
pci_dma_sync_single_for_device()? Not sure if other archs were affected.

The root problem is that the driver shouldn't use streaming allocations
for its descriptors (they are written from both sides simultaneously).
Only skb->data can be streaming.
-- 
Krzysztof Halasa
