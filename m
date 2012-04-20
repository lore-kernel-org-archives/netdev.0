From: John Fastabend <john.r.fastabend@intel.com>
Subject: Re: e1000e tx queue timeout in 3.3.0 (bisected to BQL support for
 e1000e)
Date: Fri, 20 Apr 2012 12:44:02 -0700
Message-ID: <4F91BC82.2000804@intel.com>
References: <4F909F4B.1010707@candelatech.com> <CA+mtBx9ZjfC692g1EwNsw=37ijWcGBOUaENCogVS=Bi9rfz0sg@mail.gmail.com> <4F91B250.8090509@candelatech.com> <CA+mtBx9s70wawA4E3+LyOQhJXRr1y-0j_Pzno5bBSz8TS3SUOA@mail.gmail.com> <4F91B554.9060902@candelatech.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: Ben Greear <greearb@candelatech.com>,
	netdev <netdev@vger.kernel.org>,
	e1000-devel list <e1000-devel@lists.sourceforge.net>,
	Eric Dumazet <eric.dumazet@gmail.com>
To: Tom Herbert <therbert@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga03.intel.com ([143.182.124.21]:50630 "EHLO mga03.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753512Ab2DTToE (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 20 Apr 2012 15:44:04 -0400
In-Reply-To: <4F91B554.9060902@candelatech.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 4/20/2012 12:13 PM, Ben Greear wrote:
> On 04/20/2012 12:05 PM, Tom Herbert wrote:
>>> I am seeing something similar with the 'igb' driver, though this
>>> NIC also involves a side-driver that does bypass.  When I enable/disable
>>> bypass, the links bounce (as expected), and igb reports the same
>>> timeout that I was seeing with e1000e.
>>>
>>


[...]

>>>>>
>>>>> 3f0cfa3bc11e7f00c9994e0f469cbc0e7da7b00c is the first bad commit
>>>>> commit 3f0cfa3bc11e7f00c9994e0f469cbc0e7da7b00c
>>>>> Author: Tom Herbert<therbert@google.com>
>>>>> Date:   Mon Nov 28 16:33:16 2011 +0000
>>>>>
>>>>>     e1000e: Support for byte queue limits
>>>>>
>>>>>     Changes to e1000e to use byte queue limits.
>>>>>
>>>>>     Signed-off-by: Tom Herbert<therbert@google.com>
>>>>>     Acked-by: Eric Dumazet<eric.dumazet@gmail.com>
>>>>>     Signed-off-by: David S. Miller<davem@davemloft.net>
>>>>>
>>>>> :040000 040000 bf3e2ec64fd74253563e1ab39797b27a5f2df3fe
>>>>> 51914e221547b95a989b5c7e9b037c9370fd734e M      drivers
>>>>>
>>>>>
>>>>> Thanks,
>>>>> Ben
>>>>>


Tom, did you see these two patches? Maybe this is resolved by
the second patch.

We needed these to fixup ixgbe and igb (i didn't test e1000e)
looks like we might want to push these at stable. I don't
believe they are in 3.3.

commit b37c0fbe3f6dfba1f8ad2aed47fb40578a254635
Author: Alexander Duyck <alexander.h.duyck@intel.com>
Date:   Tue Feb 7 02:29:06 2012 +0000

    net: Add memory barriers to prevent possible race in byte queue limits

    This change adds a memory barrier to the byte queue limit code to address a
    possible race as has been seen in the past with the
    netif_stop_queue/netif_wake_queue logic.

    Signed-off-by: Alexander Duyck <alexander.h.duyck@intel.com>
    Tested-by: Stephen Ko <stephen.s.ko@intel.com>
    Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>


http://git.kernel.org/?p=linux/kernel/git/torvalds/linux-2.6.git;a=commit;h=b37c0fbe3f6dfba1f8ad2aed47fb40578a254635


commit 5c4903549c05bbb373479e0ce2992573c120654a
Author: Alexander Duyck <alexander.h.duyck@intel.com>
Date:   Tue Feb 7 02:29:01 2012 +0000

    net: Fix issue with netdev_tx_reset_queue not resetting queue from XOFF state

    We are seeing dev_watchdog hangs on several drivers.  I suspect this is due
    to the __QUEUE_STATE_STACK_XOFF bit being set prior to a reset for link
    change, and then not being cleared by netdev_tx_reset_queue.  This change
    corrects that.

    In addition we were seeing dev_watchdog hangs on igb after running the
    ethtool tests.  We found this to be due to the fact that the ethtool test
    runs the same logic as ndo_start_xmit, but we were never clearing the XOFF
    flag since the loopback test in ethtool does not do byte queue accounting.

    Signed-off-by: Alexander Duyck <alexander.h.duyck@intel.com>
    Tested-by: Stephen Ko <stephen.s.ko@intel.com>
    Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>

http://git.kernel.org/?p=linux/kernel/git/torvalds/linux-2.6.git;a=commit;h=5c4903549c05bbb373479e0ce2992573c120654a
