From: Arjan van de Ven <arjan@linux.intel.com>
Subject: Re: [patch] work around/fix deadlock in the bcm43xx driver by making
 netlink irq safe
Date: Fri, 30 Jun 2006 16:45:44 +0200
Message-ID: <44A53918.2020700@linux.intel.com>
References: <1151677494.11434.47.camel@laptopd505.fenrus.org> <44A536BE.6020209@gentoo.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from fmr17.intel.com ([134.134.136.16]:6343 "EHLO
	orsfmr002.jf.intel.com") by vger.kernel.org with ESMTP
	id S1751268AbWF3OqL (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 30 Jun 2006 10:46:11 -0400
To: Joseph Jezak <josejx@gentoo.org>
In-Reply-To: <44A536BE.6020209@gentoo.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Joseph Jezak wrote:
> Can you provide the details to the list?  I'll look into getting
> SoftMAC fixed if you do.
> 

sure
the basic issue is that bcm43xx does it's rx processing in a softirq, and 
holds the bcm->irq_lock during that time. The rx processing calls into the 
softmac layer, which in turn calls into netlink.

With this you can get a deadlock that looks like this
  cpu 0: user context                           |cpu1: softirq context
     netlink_table_grab takes nl_table_lock as  |take bcm->irq_lock in
     write_lock_bh, but leaves irqs enabled     |bcm43xx_interrupt_tasklet()
                                                |which then in a few steps
                                                |leads to a call to
                                                |bcm43xx_rx


     hardirq comes in and the isr tries to take |in bcm43xx_rx, call
     bcm->irq_lock but has to wait on cpu 1     |ieee80211_rx_mgt which
                                                |leads to a call to
                                                |wireless_send_event which
                                                |tries to take nl_table_lock
                                                |for read but has to wait
                                                |for cpu0

according to Michael Buesch, the softmac layer should queue the packet 
internally for another softirq, similar to what DeviceScape does, so that 
the rx softirq can just drop all packets quickly and drop its locks.
