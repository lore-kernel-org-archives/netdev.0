From: Ben Hutchings <bhutchings@solarflare.com>
Subject: Re: [RFC net-next 00/14] default maximal number of RSS queues in mq
 drivers
Date: Wed, 20 Jun 2012 21:43:35 +0100
Message-ID: <1340225015.2576.27.camel@bwh-desktop.uk.solarflarecom.com>
References: <1340118848-30978-1-git-send-email-yuvalmin@broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: <netdev@vger.kernel.org>, <davem@davemloft.net>,
	<eilong@broadcom.com>, Divy Le Ray <divy@chelsio.com>,
	Or Gerlitz <ogerlitz@mellanox.com>,
	Jon Mason <jdmason@kudzu.us>,
	Anirban Chakraborty <anirban.chakraborty@qlogic.com>,
	Jitendra Kalsaria <jitendra.kalsaria@qlogic.com>,
	Ron Mercer <ron.mercer@qlogic.com>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>,
	Jon Mason <mason@myri.com>,
	Andrew Gallatin <gallatin@myri.com>,
	Sathya Perla <sathya.perla@emulex.com>,
	Subbu Seetharaman <subbu.seetharaman@emulex.com>,
	Ajit Khaparde <ajit.khaparde@emulex.com>,
	Matt Carlson <mcarlson@broadcom.com>,
	Michael Chan <mchan@broadcom.com>
To: Yuval Mintz <yuvalmin@broadcom.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from webmail.solarflare.com ([12.187.104.25]:46581 "EHLO
	ocex02.SolarFlarecom.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1751684Ab2FTUnl (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 20 Jun 2012 16:43:41 -0400
In-Reply-To: <1340118848-30978-1-git-send-email-yuvalmin@broadcom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2012-06-19 at 18:13 +0300, Yuval Mintz wrote:
> Different vendors support different number of RSS queues by default. Today,
> there exists an ethtool API through which users can change the number of
> channels their driver supports; This enables us to pursue the goal of using
> a default number of RSS queues in various multi-queue drivers.
> 
> This RFC intendeds to achieve the above default, by upper-limiting the number
> of interrupts multi-queue drivers request (by default, not via the new API) 
> with correlation to the number of cpus on the machine.
> 
> After examining multi-queue drivers that call alloc_etherdev_mq[s],
> it became evident that most drivers allocate their devices using hard-coded
> values. Changing those defaults directly will most likely cause a regression. 
> 
> However, (most) multi-queue driver look at the number of online cpus when 
> requesting for interrupts. We assume that the number of interrupts the
> driver manages to request is propagated across the driver, and the number
> of RSS queues it configures is based upon it. 
> 
> This RFC modifies said logic - if the number of cpus is large enough, use
> a smaller default value instead. This serves 2 main purposes: 
>  1. A step forward unity in the number of RSS queues of various drivers.
>  2. It prevents wasteful requests for interrupts on machines with many cpus.
[...]
> Driver identified as multi-queue, no reference to number of online cpus found,
> and thus unhandled in this RFC:
[...]
> * sfc       efx
[...]

In sfc we currently look at the CPU topology to count cores instead of
threads.  The result is the same unless the system has hyperthreading
(or other SMT) enabled.

I've seen many diagnostic reports from customer support tickets where
there were 32 queue-sets and MSI-X vectors in use (the maximum currently
supported by the driver), but very few had a problem with that.

I would be interested in a scheme to use fewer queues for RSS but more
for flow steering (accelerated RFS, XPS and ethtool NFC).  We had some
discussion of this at last year's netconf but sadly I've not yet found
time to work on it.

Ben.

-- 
Ben Hutchings, Staff Engineer, Solarflare
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.
