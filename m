From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] ircomm: release tty before sleeping potentially
 indefintely
Date: Sun, 03 Mar 2013 19:31:27 -0500 (EST)
Message-ID: <20130303.193127.656411242317130530.davem@davemloft.net>
References: <1362350153-26225-1-git-send-email-sasha.levin@oracle.com>
	<20130303.174739.1195645942179862011.davem@davemloft.net>
	<5133DA12.8020907@oracle.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: samuel@sortiz.org, gregkh@linuxfoundation.org, jslaby@suse.cz,
	peter@hurleysoftware.com, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: sasha.levin@oracle.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <5133DA12.8020907@oracle.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Sasha Levin <sasha.levin@oracle.com>
Date: Sun, 03 Mar 2013 18:17:38 -0500

> On 03/03/2013 05:47 PM, David Miller wrote:
>> From: Sasha Levin <sasha.levin@oracle.com>
>> Date: Sun,  3 Mar 2013 17:35:53 -0500
>> 
>>> ircomm_tty_block_til_ready would hold tty lock while blocking. Since the sleep
>>> might take a long time we can prevent other processes from accessing the tty,
>>> causing hung tasks and a dead tty.
>>>
>>> Diagnosed-by: Peter Hurley <peter@hurleysoftware.com>
>>> Signed-off-by: Sasha Levin <sasha.levin@oracle.com>
>> 
>> But then you invalidate all of the tty state tests made under
>> the lock at the beginning of this function, before enterring
>> the loop.  If you drop the lock, those pieces of state could
>> change.
>> 
>> I'm not applying this.
> 
> I'm unsure. A similar patch was applied back in 2010 that does the same thing
> to a bunch of drivers, including the core tty code (e142a31da "tty: release
> BTM while sleeping in block_til_ready").
> 
> This IR code looks very much like tty_port_block_til_ready() where it was
> okay to do that change, so I should be the same with ircomm_tty_block_til_ready.

That assumes that the other changes don't have the same bug.

Releasing locks are dangerous, because it invalidates the context in
which all previous tests of state have been performed.  Anything can
happen to the TTY once you drop that lock.
