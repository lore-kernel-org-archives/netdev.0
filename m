From: "Kok, Auke" <auke-jan.h.kok@intel.com>
Subject: Re: [PATCH] e1000: Don't enable polling in open() (was: e1000: assertion
 hit in e1000_clean(), kernel 2.6.21.1)
Date: Mon, 21 May 2007 17:58:27 -0700
Message-ID: <46524033.4030901@intel.com>
References: <20070521215134.14885.84952.stgit@localhost.localdomain> <20070521221635.GA16888@redhat.com> <20070522004921.GA8130@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: jeff@garzik.org, stable@vger.kernel.org, greg@suse.de,
	e1000-devel@lists.sourceforge.net, netdev@vger.kernel.org
To: Herbert Xu <herbert.xu@redhat.com>, Dave Jones <davej@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga01.intel.com ([192.55.52.88]:55110 "EHLO mga01.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757546AbXEVA6s (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 21 May 2007 20:58:48 -0400
In-Reply-To: <20070522004921.GA8130@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Herbert Xu wrote:
> On Mon, May 21, 2007 at 06:16:35PM -0400, Dave Jones wrote:
>> On Mon, May 21, 2007 at 02:51:35PM -0700, Auke Kok wrote:
>>  > Herbert Xu wrote:
>>  > "netif_poll_enable can only be called if you've previously called
>>  > netif_poll_disable.  Otherwise a poll might already be in action
>>  > and you may get a crash like this."
>>  > 
>>  > Removing the call to netif_poll_enable in e1000_open should fix this issue,
>>  > the only other call to netif_poll_enable is in e1000_up() which is only
>>  > reached after a device reset or resume.
>>  > 
>>  > Bugzilla: http://bugzilla.kernel.org/show_bug.cgi?id=8455
>>  > https://bugzilla.redhat.com/bugzilla/show_bug.cgi?id=240339
>>
>> This probably doesn't solve the latter bug.
>> The code you reference isn't there in the kernel tested in that bug
>> (2.6.21)   In 2.6.21, netif_poll_enable is only called from
>> e1000_up(), not e1000_open()
> 
> Yes we need a different fix for 2.6.21.  There e1000_open calls
> e1000_up which is why we still get the netif_poll_enable.

yes, basically they need the patch that introduced(exposed) the problem as well, 
but that is a rather significant change and kind of moves the whole 
netstack-init code in e1000 around. The size was the reason why that patch 
didn't go into 2.6.21 in the first place, but perhaps they can pull both patches 
into the FC tree.

For reference, this is the commit:

commit e0aac5a289b1dacbc94bd9ae8c449bcdf9ab508c
Author: Auke Kok <auke-jan.h.kok@intel.com>
Date:   Tue Mar 6 08:57:21 2007 -0800

     e1000: FIX: be ready for incoming irq at pci_request_irq

     DEBUG_SHIRQ code exposed that e1000 was not ready for incoming interrupts
     after having called pci_request_irq. This obviously requires us to finish
     our software setup which assigns the irq handler before we request the
     irq.

     Signed-off-by: Auke Kok <auke-jan.h.kok@intel.com>
     Signed-off-by: Jeff Garzik <jeff@garzik.org>

Dave, would that be an option for you?

Auke
