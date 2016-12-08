From: Lino Sanfilippo <LinoSanfilippo@gmx.de>
Subject: Re: [PATCH 1/2] net: ethernet: sxgbe: remove private tx queue lock
Date: Thu, 8 Dec 2016 23:12:10 +0100
Message-ID: <9b55b51c-bbbf-7f80-fb67-9df88a288708@gmx.de>
References: <1481141138-19466-1-git-send-email-LinoSanfilippo@gmx.de>
 <1481141138-19466-2-git-send-email-LinoSanfilippo@gmx.de>
 <20161207231534.GB5889@electric-eye.fr.zoreil.com>
 <051e3043-8b58-0591-36e3-99e2267f67f4@gmx.de> <20161208215409.GA12472@amd>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Cc: Francois Romieu <romieu@fr.zoreil.com>, bh74.an@samsung.com,
        ks.giri@samsung.com, vipul.pandya@samsung.com,
        peppe.cavallaro@st.com, alexandre.torgue@st.com,
        davem@davemloft.net, linux-kernel@vger.kernel.org,
        netdev@vger.kernel.org
To: Pavel Machek <pavel@ucw.cz>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20161208215409.GA12472@amd>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi,

On 08.12.2016 22:54, Pavel Machek wrote:
> On Thu 2016-12-08 21:32:12, Lino Sanfilippo wrote:
>> Hi,
>> 
>> On 08.12.2016 00:15, Francois Romieu wrote:
>> > Lino Sanfilippo <LinoSanfilippo@gmx.de> :
>> >> The driver uses a private lock for synchronization between the xmit
>> >> function and the xmit completion handler, but since the NETIF_F_LLTX flag
>> >> is not set, the xmit function is also called with the xmit_lock held.
>> >> 
>> >> On the other hand the xmit completion handler first takes the private lock
>> >> and (in case that the tx queue has been stopped) the xmit_lock, leading
>> >> to a reverse locking order and the potential danger of a deadlock.
>> > 
>> > netif_tx_stop_queue is used by:
>> > 1. xmit function before releasing lock and returning.
>> > 2. sxgbe_restart_tx_queue()
>> >    <- sxgbe_tx_interrupt
>> >    <- sxgbe_reset_all_tx_queues()
>> >       <- sxgbe_tx_timeout()
>> > 
>> > Given xmit won't be called again until tx queue is enabled, it's not clear
>> > how a deadlock could happen due to #1.
>> > 
>> 
>> 
>> After spending more thoughts on this I tend to agree with you. Yes, we have the
>> different locking order for the xmit_lock and the private lock in two concurrent
>> threads. And one of the first things one learns about locking is that this is a
>> good way to create a deadlock sooner or later. But in our case the deadlock 
>> can only occur if the xmit function and the tx completion handler perceive different
>>  states for the tx queue, or to be more specific: 
>> the completion handler sees the tx queue in state "stopped" while the xmit handler 
>> sees it in state "running" at the same time. Only then both functions would try to
>> take both locks, which could lead to a deadlock.
>> 
>> OTOH Pavel said that he actually could produce a deadlock. Now I wonder if this is caused
>> by that locking scheme (in a way I have not figured out yet) or if it is a different issue.
> 
> Pavel has some problems, but that's on different hardware.. and it is
> possible that it is deadlock (or something else) somewhere else.
> 

Right, it is different hardware. But the locking situation in xmit function and tx completion handler
is very similar in both drivers. So if a deadlock is not possible in sxgbe it should 
also not be possible in stmmac (at least not due to the different locking order). 
So maybe there is no real issue that we could fix with removing the private lock and we should
keep it as it is.

Regards,
Lino
