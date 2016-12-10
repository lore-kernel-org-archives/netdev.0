From: Lino Sanfilippo <LinoSanfilippo@gmx.de>
Subject: Re: [PATCH 1/2] net: ethernet: sxgbe: remove private tx queue lock
Date: Sat, 10 Dec 2016 03:25:47 +0100
Message-ID: <c76124b9-6376-42b9-2821-b5a8185f5034@gmx.de>
References: <1481141138-19466-1-git-send-email-LinoSanfilippo@gmx.de>
 <1481141138-19466-2-git-send-email-LinoSanfilippo@gmx.de>
 <20161207231534.GB5889@electric-eye.fr.zoreil.com>
 <051e3043-8b58-0591-36e3-99e2267f67f4@gmx.de>
 <20161208231943.GA13102@electric-eye.fr.zoreil.com>
 <20161209112142.GA22710@amd>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Cc: bh74.an@samsung.com, ks.giri@samsung.com, vipul.pandya@samsung.com,
        peppe.cavallaro@st.com, alexandre.torgue@st.com,
        davem@davemloft.net, linux-kernel@vger.kernel.org,
        netdev@vger.kernel.org
To: Pavel Machek <pavel@ucw.cz>, Francois Romieu <romieu@fr.zoreil.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mout.gmx.net ([212.227.15.18]:54163 "EHLO mout.gmx.net"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751367AbcLJC0H (ORCPT <rfc822;netdev@vger.kernel.org>);
        Fri, 9 Dec 2016 21:26:07 -0500
In-Reply-To: <20161209112142.GA22710@amd>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,

On 09.12.2016 12:21, Pavel Machek wrote:
> On Fri 2016-12-09 00:19:43, Francois Romieu wrote:
>> Lino Sanfilippo <LinoSanfilippo@gmx.de> :
>> [...]
>> > OTOH Pavel said that he actually could produce a deadlock. Now I wonder if
>> > this is caused by that locking scheme (in a way I have not figured out yet)
>> > or if it is a different issue.
>> 
>> stmmac_tx_err races with stmmac_xmit.
> 
> Umm, yes, that looks real.
> 
> And that means that removing tx_lock will not be completely trivial
> :-(. Lino, any ideas there?
> 

Ok, the race is there but it looks like a problem that is not related to 
the use or removal of the private lock.
By a glimpse into other drivers (e.g sky2 or e1000), a possible way to handle a 
tx error is to start a separate task and restart the tx path in that task instead
the irq handler (or timer in case of the watchdog).

In that task we could do:
1. deactivate napi
2. deactivate irqs
3. wait for running napi/irqs do complete (_sync)
4. call stmmac_tx_err()
5. reenable napi
6. reenable irqs

We have to ensure that no xmit() is executing while stmmac_tx_err() does the cleanup,
so stmmac_tx_err() should IMO rather call netif_tx_disable() instead of netif_stop_queue()
(the former grabs the xmit lock before it sets __QUEUE_STATE_DRV_XOFF to disable
the queue).

Regards,
Lino
