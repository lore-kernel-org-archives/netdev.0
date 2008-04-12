From: Krzysztof Halasa <khc@pm.waw.pl>
Subject: Re: [PATCH v2] Re: WAN: new PPP code for generic HDLC
Date: Sat, 12 Apr 2008 22:19:28 +0200
Message-ID: <m33apqomgf.fsf@maximus.localdomain>
References: <m3prtzsszg.fsf@maximus.localdomain>
	<m3tzj92xq6.fsf@maximus.localdomain>
	<m33aqedg0a.fsf@maximus.localdomain>
	<m37if4oz1g.fsf@maximus.localdomain>
	<20080411221448.22b69ff5.akpm@linux-foundation.org>
	<m3prsva3y7.fsf@maximus.localdomain> <20080412115950.1cbb9cfa@core>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Andrew Morton <akpm@linux-foundation.org>,
	Jeff Garzik <jeff@garzik.org>, <linux-kernel@vger.kernel.org>,
	<netdev@vger.kernel.org>
To: Alan Cox <alan@lxorguk.ukuu.org.uk>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1758201AbYDLUTq@vger.kernel.org>
In-Reply-To: <20080412115950.1cbb9cfa@core> (Alan Cox's message of "Sat\, 12 Apr 2008 11\:59\:50 +0100")
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Alan Cox <alan@lxorguk.ukuu.org.uk> writes:

>> PPP support in generic HDLC in Linux 2.6.25 is broken and will cause
>> a kernel panic when a device configured in PPP mode is activated.
>> 
>> It will be replaced by new PPP implementation after Linux 2.6.25 is
>> released.
>
> Thats a pretty bad regression. Surely the correct fix is to revert the
> change series that caused the breakage then re-merge that and fixes for
> HDLC PPP for 2.6.26, not just leave it broken ?

It's not that simple - it was broken between 2.6.22 and 2.6.23 (2.6.23
was already broken), I just haven't noticed (I don't use PPP myself,
except for tests).

author	Peter P Waskiewicz Jr <peter.p.waskiewicz.jr@intel.com>
	 Fri, 6 Jul 2007 20:36:20 +0000 (13:36 -0700)
commit	f25f4e44808f0f6c9875d94ef1c41ef86c288eb2

[CORE] Stack changes to add multiqueue hardware support API
Add the multiqueue hardware device support API to the core network
stack.  Allow drivers to allocate multiple queues and manage them at
the netdev level if they choose to do so.

Added a new field to sk_buff, namely queue_mapping, for drivers to
know which tx_ring to select based on OS classification of the flow.

And it included:
--- a/include/linux/netdevice.h
+++ b/include/linux/netdevice.h
@@ -565,9 +578,7 @@ struct net_device
 
 static inline void *netdev_priv(const struct net_device *dev)
 {
-       return (char *)dev + ((sizeof(struct net_device)
-                                       + NETDEV_ALIGN_CONST)
-                               & ~NETDEV_ALIGN_CONST);
+       return dev->priv;
 }
 
 #define SET_MODULE_OWNER(dev) do { } while (0)


HDLC PPP sits between hardware drivers and (in this case) syncppp.c,
and it (hdlc_ppp module) was using netdev_priv() as a pointer to the
memory allocated with (after) the netdev structure. dev->priv was used
by syncppp.c.

HDLC FR was also broken by this change but the fix was easy because
there is no external protocol module to interface to.

I didn't want to add to the HDLC PPP mess anymore and have rewritten
it instead (in process, it turned out syncppp alone, and syncppp +
HDLC have much more problems than I thought). Obviously I was way too
late for 2.6.25 (past 2.6.25-rc5 and the new code wasn't much tested).


Yes, I could add another dirty "interface fix" to the HDLC + syncppp
combo (hdlc_ppp), but I don't really see a sense, especially that I
have the new implementation ready and working (my time resources are
currently quite limited and if I have to choose between adding another
glue fix and writing a better PPP replacement I pick the latter).


My original post: http://lkml.org/lkml/2008/3/12/277
-- 
Krzysztof Halasa
