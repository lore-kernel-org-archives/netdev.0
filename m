From: Jeff Garzik <jgarzik@pobox.com>
Subject: Re: e100 "Ferguson" release
Date: Tue, 05 Aug 2003 01:29:41 -0400
Sender: netdev-bounce@oss.sgi.com
Message-ID: <3F2F40C5.9070601@pobox.com>
References: <C6F5CF431189FA4CBAEC9E7DD5441E010222929E@orsmsx402.jf.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: "Feldman, Scott" <scott.feldman@intel.com>
In-Reply-To: <C6F5CF431189FA4CBAEC9E7DD5441E010222929E@orsmsx402.jf.intel.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Feldman, Scott wrote:
>>* (API) Does the out-of-tx-resources condition in 
>>e100_xmit_frame ever really happen?  I am under the
>>impression that returning non-zero in ->hard_start_xmit
>>results in the packet sometimes being requeued and
>>sometimes dropped.  I prefer to guarantee a more-steady 
>>state, by simply dropping the packet unconditionally,
>>when this uncommon condition occurs.  So, I would
>>a) mark the failure condition with unlikely(), and
>>b) if the condition occurs, simply drop the packet 
>>(tx_dropped++, kfree 
>>skb), and return zero.
> 
> 
> Stop the queue also?
> 
> if(unlikely(e100_exec_cb(nic, skb, e100_xmit_prepare) == -ENOMEM)) {
>         netif_stop_queue(netdev);
>         nic->net_stats.tx_dropped++;
>         dev_kfree_skb(skb);
>         return 0;
> }

Yes.  I would also printk(KERN_ERR "we have a bug!") or somesuch, like 
several other drivers do, too.


>>* IIRC Donald's MII phy scanning code scans MII phy ids like this: 
>>1..31,0.  Or maybe 1..31, and then 0 iff no MII phys were found.  In 
>>general I would prefer to follow his eepro100.c probe order.  
>>Some phys need this because they will report on both phy id #0 (which 
>>is magical) and phy id #(non-zero).  Donald would know more than me,
> 
> here.
> 
> [kernel] eepro100 gets the ID from the eeprom, so no scanning there.
> Current e100 goes 1, 0..31, which is what we've always done, IIRC.

hmmm.  I prefer the phy scanning to checking eeprom, since it reduces 
the chance of eeprom screwups.  However, I still think there's some 
issue related to phy id #0.  Oh well, fine for now, I guess.


>>* do we care about spinlocks around the update_stats and 
>>get_stats code?
> 
> 
> Not sure.  update_stats runs in a timer callback.  Can get_stats jump
> in?

Well, the ->get_stats only returns a pointer to the stats, which are 
then accessed in an unlocked manner.  Since the net stats are unsigned 
longs, asynchronously reading and updating them isn't a big deal in 
practice.


>>* (minor) use a netif_msg_xxx wrapper/constant in 
>>e100_init_module test?
> 
> 
> Can't - don't have nic->msg_enable allocated yet.  :(

You could always use "(1 << debug) - 1"... :)  I dunno if it's worth 
worrying about.

	Jeff
