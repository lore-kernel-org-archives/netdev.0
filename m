From: Sergei Shtylyov <sshtylyov@ru.mvista.com>
Subject: Re: [Kgdb-bugreport] [PATCH 2.6.20-rc7] 8139too KGDBoE fix
Date: Thu, 15 Mar 2007 00:40:10 +0300
Message-ID: <45F86BBA.4050700@ru.mvista.com>
References: <200701312144.56497.sshtylyov@ru.mvista.com> <45DDBD96.10000@ru.mvista.com> <45DDC7C0.8050100@ru.mvista.com> <200702231238.40474.amitkale@linsyssoft.com> <45F7FBC8.9050700@ru.mvista.com> <45F800F8.5020903@ru.mvista.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: "Amit S. Kale" <amitkale@linsyssoft.com>,
	Mithlesh Thukral <mithlesh@linsyssoft.com>,
	Vitaly Wool <vwool@ru.mvista.com>, Mark Huth <mhuth@mvista.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from gateway-1237.mvista.com ([63.81.120.155]:18976 "EHLO
	imap.sh.mvista.com" rhost-flags-OK-FAIL-OK-FAIL) by vger.kernel.org
	with ESMTP id S1422672AbXCNVka (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 14 Mar 2007 17:40:30 -0400
In-Reply-To: <45F800F8.5020903@ru.mvista.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hello, I wrote:

>>> This thread came up on kgdb-bugreport mailing list. Could you please 
>>> suggest us what's the correct way of fixing this problem?

>>> 1. When running a kgdb on RTL8139 ethernet interface: 8139too driver 
>>> prints too many "Out-of-sync dirty pointer" messages on console and 
>>> gdb can't connect to kgdb stub. These messages can be suppressed, 
>>> though it still results in connection failures frequently. 

>>> 2. Here is how kgdb uses polling mechanism for communication to gdb.  
>>> kgdb calls netpoll_set_trap(1) just before entering a loop where it 
>>> communicates to gdb. It calls netpoll_set_trap(0) after it is done 
>>> and wants to resume a kernel. The communication to gdb goes through 
>>> netpoll_poll (which calls kgdb rx_hook) and netpoll_send_udp functions.

>>> 3. A queue for an interface may have been stopped by it's driver by 
>>> calling netif_stop_queue. After this if kgdb attempts to enter 
>>> communication with gdb, it'll call netpoll_set_trap(1), after which 
>>> the queue can't be started again. This is a potential deadlock 
>>> situation. Is there a way out of this?

    No way but at least "emulate" the queue controls...

>>> 4. Is it necessary to call netpoll_set_trap(1) at all before entering 
>>> gdb communication loop? Even if a driver stops the queue in middle of 
>>> the communication netpoll_poll and netpoll_send_udp calls can recover 
>>> from that by calling driver's interrupt and poll routines. Is this a 
>>> valid statement?

    It seems that having queue control working as usual is dangerous in case 
of KGDB being active: this leads to wake_softirqd() being called, which seems 
undesirable (there has been report about the eventual lockup trying to get 
runqueue lock).

>>    I'd like to return to this again (having received no feedback)...
>>    The idea is to change how CONFIG_NETPOLL_TRAP is implemented: 
>> instead of
>> completely bypassing queue locking after netpoll_set_trap(1) has been 
>> called, how about we set and chack some other flag (internal to 
>> netpoll) telling it that the queue is frozen, i.e. watch the queue 
>> state using a separate mechanism when traffic trapping is engaged?  
>> This certainly 

>    Well, this certainly won't work, as the bit should be tied to struct 
> net_device.

    Well, I hadn't yet discovered npinfo member of net_device before saying 
that. :-)

>>> Thanks a lot.
>>> -Amit

WBR, Sergei
