From: Jason Wang <jasowang@redhat.com>
Subject: Re: [PATCH net 2/2] net: core: explicitly select a
 txq before doing l2 forwarding
Date: Wed, 08 Jan 2014 11:21:21 +0800
Message-ID: <52CCC431.3060403@redhat.com>
References: <1388978467-2075-1-git-send-email-jasowang@redhat.com>
	<1388978467-2075-2-git-send-email-jasowang@redhat.com>
	<20140106124248.GB24280@hmsreliant.think-freely.org>
	<52CB77A0.3030106@redhat.com>
	<20140107131730.GA12366@hmsreliant.think-freely.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: mst@redhat.com, e1000-devel@lists.sourceforge.net, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org,
	John Fastabend <john.r.fastabend@intel.com>, davem@davemloft.net
To: Neil Horman <nhorman@tuxdriver.com>
Return-path: <e1000-devel-bounces@lists.sourceforge.net>
In-Reply-To: <20140107131730.GA12366@hmsreliant.think-freely.org>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/e1000-devel>,
	<mailto:e1000-devel-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum_name=e1000-devel>
List-Post: <mailto:e1000-devel@lists.sourceforge.net>
List-Help: <mailto:e1000-devel-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/e1000-devel>,
	<mailto:e1000-devel-request@lists.sourceforge.net?subject=subscribe>
Errors-To: e1000-devel-bounces@lists.sourceforge.net
List-Id: netdev.vger.kernel.org

On 01/07/2014 09:17 PM, Neil Horman wrote:
> On Tue, Jan 07, 2014 at 11:42:24AM +0800, Jason Wang wrote:
>> On 01/06/2014 08:42 PM, Neil Horman wrote:
>>> On Mon, Jan 06, 2014 at 11:21:07AM +0800, Jason Wang wrote:
>>>> Currently, the tx queue were selected implicitly in ndo_dfwd_start_xmit(). The
>>>> will cause several issues:
>>>>
>>>> - NETIF_F_LLTX was forced for macvlan device in this case which lead extra lock
>>>>   contention.
>>>> - dev_hard_start_xmit() was called with NULL txq which bypasses the net device
>>>>   watchdog
>>>> - dev_hard_start_xmit() does not check txq everywhere which will lead a crash
>>>>   when tso is disabled for lower device.
>>>>
>>>> Fix this by explicitly introducing a select queue method just for l2 forwarding
>>>> offload (ndo_dfwd_select_queue), and introducing dfwd_direct_xmit() to do the
>>>> queue selecting and transmitting for l2 forwarding.
>>>>
>>>> With this fixes, NETIF_F_LLTX could be preserved for macvlan and there's no need
>>>> to check txq against NULL in dev_hard_start_xmit().
>>>>
>>>> In the future, it was also required for macvtap l2 forwarding support since it
>>>> provides a necessary synchronization method.
>>>>
>>>> Cc: John Fastabend <john.r.fastabend@intel.com>
>>>> Cc: Neil Horman <nhorman@tuxdriver.com>
>>>> Cc: e1000-devel@lists.sourceforge.net
>>>> Signed-off-by: Jason Wang <jasowang@redhat.com>
>>> Instead of creating another operation here to do special queue selection, why
>>> not just have ndo_dfwd_start_xmit include a pointer to a pointer in its argument
>>> list, so it can pass the txq it used back to the caller (dev_hard_start_xmit)?
>>> ndo_dfwd_start_xmit already knows which queue set to pick from (since their
>>> reserved for the device doing the transmitting).  It seems more clear to me than
>>> creating a new netdevice operation.  
>> See commit 8ffab51b3dfc54876f145f15b351c41f3f703195 ("macvlan: lockless
>> tx path"). The point is keep the tx path lockless to be efficient and
>> simplicity for management. And macvtap multiqueue was also implemented
>> with this assumption. The real contention should be done in the txq of
>> lower device instead of macvlan itself. This is also needed for
>> multiqueue macvtap.
> Ok, I see how you're preserving LLTX here, and thats great, but it doesn't
> really buy us anything that I can see.  If a macvlan is using hardware
> acceleration, it needs to arbitrate access to that hardware.  Weather thats done
> by locking the lowerdev's tx queue lock or by enforcing locking on the macvlan
> itself is equivalent.  The decision to use dfwd hardware acceleration is made on
> open, so its not like theres any traffic that can avoid the lock, as it all goes
> through the hardware.  All I see that this has bought us is an extra net_device
> method (which isn't a big deal, but not necessecary as I see it).

As I replied to patch 1/2, looking at the code itself again. The locking
on the lowerdev's tx queue is really need since we need synchronize with
other control path. Two examples are dev watchdog and ixgbe_down() both
of which will try to hold tx lock to synchronize the with transmission.
Without holding the lowerdev tx lock, we may have more serious issues.
Also, it's a little strange for a net device has two modes. Future
developers need to care about two different tx lock paths which is sub
optimal.

For the issue of an extra net_device method,  if you don't like we can
reuse the ndo_select_queue by also passing the accel_priv to that method.
>
> It seems like the right solution here is to use ethtool to disable the dfwd
> acceleration feature on the hardware if you don't want to incur the additional
> locking.
>
>>> As for the crash issue, I'm not sure what you mean.  Where in
>>> dev_hard_start_xmit would we need to check txq that we're not currently, and
>>> what crash results?
>> Well, see current dev_hard_start_xmit(), if lower device does not
>> support tso or tso is disabled, in gso path:
>>
>> gso:
>> ...
>>         txq_trans_update(txq);
>>         if (unlikely(netif_xmit_stopped(txq) && skb->next))
>>
>> There's an obvious NULL pointer dereference.
> Yeah, I saw that after I wrote my note, sorry about that.  However, it doesn't
> change what I said above.  i don't think theres a need to add an additional
> select_queue method here, just add a pointer to a pointer arg to the dfwd xmit
> routine to fill in the queue that was selected on transmit.  That should resolve
> all the potential NULL pointers without the need to ad additional methods to
> net_device_ops.
>
>>> Also, can you elaborate on what you mean by additional lock contention? 
>> If the lower device has NETIF_F_LLTX, then both macvlan txq lock and the
>> lock of device itself must be held before doing transmission. In the
>> case, the macvlan txq lock contention is obvious unnecessary.
> Not in its current implementation.  The lowerdevice's NETIF_F_LLTX are ignored
> during transmit because we're using a privately allocated set of queues assigned
> to the transmitting macvlan (i.e. there is not contention on the lowerdevice for
> any single given macvlan).  Thats why we have to clear the NETIF_F_LLTX field on
> the macvlan itself.  using dfwd acceleration is effectively giving a macvlan its
> own hardware, that needs arbitration between every context thats trying to
> transmit over it.
>
>
> That said, I did just notice that if the macvlan has multiple queues we will
> still use a single tx queue on transmit, we should map those queues to multiple
> hardware queues.  I'll fix that shortly.
>
>>>  What
>>> contention do you see that goes above and beyond the normal locking required by
>>> txq access?  
>> As I said above, the point is keeping the lockess tx path and make the
>> contention of txq for real device instead of macvlan itself.
> But you've not done that.  You've just moved the locking down to the lowerdev,
> which is fine I suppose, but doesn't actually improve anything, since we will
> still lock exactly as many time as if we do the locking in the macvlan.
>
> Regards
> Neil
>
>>> I suppose its extra locking above and beyond in the macvtap case,
>>> where you would otherwise never hit hardware, but that not the only use case,
>>> and I think the solution there is likely to add some code in the macvlan feature
>>> set handler so that NETIF_F_LLTX is cleared if you disable the hardware
>>> forwarding acceleration via ethtool.
>>>
>>> Regards
>>> Neil
>>>
>>
> --
> To unsubscribe from this list: send the line "unsubscribe linux-kernel" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
> Please read the FAQ at  http://www.tux.org/lkml/


------------------------------------------------------------------------------
Rapidly troubleshoot problems before they affect your business. Most IT 
organizations don't have a clear picture of how application performance 
affects their revenue. With AppDynamics, you get 100% visibility into your 
Java,.NET, & PHP application. Start your 15-day FREE TRIAL of AppDynamics Pro!
http://pubads.g.doubleclick.net/gampad/clk?id=84349831&iu=/4140/ostg.clktrk
_______________________________________________
E1000-devel mailing list
E1000-devel@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/e1000-devel
To learn more about Intel&#174; Ethernet, visit http://communities.intel.com/community/wired
