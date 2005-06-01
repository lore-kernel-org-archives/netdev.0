From: Stephen Hemminger <shemminger@osdl.org>
Subject: Re: RFC: PHY Abstraction Layer II
Date: Wed, 01 Jun 2005 14:19:15 -0700
Message-ID: <429E2653.6010101@osdl.org>
References: <1107b64b01fb8e9a6c84359bb56881a6@freescale.com>
	<20050531105939.7486e071@dxpl.pdx.osdl.net>
	<92F1428A-0B26-428B-8C06-35C7E5B9EEE3@freescale.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Netdev <netdev@oss.sgi.com>,
	Embedded PPC Linux list <linuxppc-embedded@ozlabs.org>
Return-path: <linuxppc-embedded-bounces@ozlabs.org>
To: Andy Fleming <afleming@freescale.com>
In-Reply-To: <92F1428A-0B26-428B-8C06-35C7E5B9EEE3@freescale.com>
List-Unsubscribe: <https://ozlabs.org/mailman/listinfo/linuxppc-embedded>,
	<mailto:linuxppc-embedded-request@ozlabs.org?subject=unsubscribe>
List-Archive: <http://ozlabs.org/pipermail/linuxppc-embedded>
List-Post: <mailto:linuxppc-embedded@ozlabs.org>
List-Help: <mailto:linuxppc-embedded-request@ozlabs.org?subject=help>
List-Subscribe: <https://ozlabs.org/mailman/listinfo/linuxppc-embedded>,
	<mailto:linuxppc-embedded-request@ozlabs.org?subject=subscribe>
Sender: linuxppc-embedded-bounces@ozlabs.org
Errors-To: linuxppc-embedded-bounces@ozlabs.org
List-Id: netdev.vger.kernel.org

Andy Fleming wrote:

>
> On May 31, 2005, at 12:59, Stephen Hemminger wrote:
>
>> Here are some patches:
>>     * allow phy's to be modules
>>     * use driver owner for ref count
>>     * make local functions static where ever possible
>
>
> I agree with all these.
>
>>     * get rid of bus read may sleep implication in comment.
>>       since you are holding phy spin lock it better not!!
>
>
> But not this one.  The phy_read and phy_write functions are reading  
> from and writing to a bus.  It is a reasonable implementation to have  
> the operation block in the bus driver, and be awoken when an  
> interrupt signals the operation is done.  All of the phydev spinlocks  
> have been arranged so as to prevent the lock being taken during  
> interrupt time.
>
> Unless I've misunderstood spinlocks (it wouldn't be the first time),  
> as long as the lock is never taken in interrupt time, it should be ok  
> to hold the lock, and wait for an interrupt before clearing the lock.


The problem is that sleeping is defined in the linux kernel as meaning 
waiting on a mutual exclusion
primitive (like semaphore) that puts the current thread to sleep. It is 
not legal to sleep with a spinlock held.
In the phy_read code you do:
   
   spin_lock_bh(&bus->mdio_lock);
    retval = bus->read(bus, phydev->addr, regnum);
    spin_unlock_bh(&bus->mdio_lock);

If the bus->read function were to do something like start a request and 
wait on a semaphore, then
you would be sleeping with a spin lock held.  So bus->read can not 
sleep! (as sleep is defined in the
linux kernel).
