From: Manfred Spraul <manfred@colorfullife.com>
Subject: Re: NAPI note
Date: Tue, 18 Feb 2003 17:31:20 +0100
Sender: netdev-bounce@oss.sgi.com
Message-ID: <3E525FD8.1060009@colorfullife.com>
References: <3E4D66DF.3040800@colorfullife.com>	<3E4D8295.2050400@pobox.com> <20030217.185719.28797590.davem@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: jgarzik@pobox.com, zaitcev@redhat.com, jbourne@mtroyal.ab.ca,
   netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: "David S. Miller" <davem@redhat.com>
In-Reply-To: <20030217.185719.28797590.davem@redhat.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

David S. Miller wrote:

>   From: Jeff Garzik <jgarzik@pobox.com>
>   Date: Fri, 14 Feb 2003 18:58:13 -0500
>
>   Manfred Spraul wrote:
>   > It seems to be a generic NAPI restriction:
>   > The caller of netif_receive_skb() must not own a spinlock that is 
>   > acquired from an interrupt handler.
>   
>   Thanks much for noticing this, Manfred.
>
>I think this logic is buggy.
>
>In the example I've seen posted, only a NAPI implementation bug
>could cause the situation to occur.
>
>If cpu1 is in ->poll() for the driver, then by definition the
>device shall not cause interrupts.  The device's interrupts
>are disabled before we enter the ->poll() handler, and as such
>the "cpu2 take device interrupt and takes driver->lock" cannot
>occur.
>  
>
No. I think the rule is that drivers that use the NAPI interface must 
not cause interrupts for packet receive and out-of-rx-buffers conditions.
But what about media error interrupts, or tx interrupts? Or MIB counter 
overflow, etc. What about shared pci interrupts?
All of them could occur, and if they take a spinlock that is held across 
netif_receive_skb(), then it can deadlock.

OTHO if it's guaranteed that no interrupt occurs, then the nic should 
not take a spinlock at all and rely on the synchronization provided by 
NAPI. (->poll is single-threaded).

--
    Manfred
