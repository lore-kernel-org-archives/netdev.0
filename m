From: Bruce Cole <bacole@gmail.com>
Subject: [RFT] r8169 changes against 2.6.23-rc3
Date: Tue, 21 Aug 2007 12:32:52 -0700
Message-ID: <46CB3DE4.4060107@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: bacole@gmail.com
To: Francois Romieu <romieu@fr.zoreil.com>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from ag-out-0708.google.com ([72.14.246.248]:2063 "EHLO
	ag-out-0708.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750819AbXHUTer (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 21 Aug 2007 15:34:47 -0400
Received: by ag-out-0708.google.com with SMTP id 35so560275aga
        for <netdev@vger.kernel.org>; Tue, 21 Aug 2007 12:34:46 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 8/20/07, Dirk wrote:
 >> So it seems that when the driver tries to queue a packet while the
 >> controller is busy processing the queue, the newly queued packet does
 >> not get noticed by the controller (until further packet activity 
occurs).
 >> Perhaps there is a problem with the memory barriers when adding to the
 >> TX queue, but I'm a newbie on linux kernel memory barriers.
 >
 >One thing I noticed a while ago (march) is that floodpinging (ping -f)
 >the r8169 host from an external system also increases performance
 >without changing code.
Yes, I just tried this and saw the same result.  Makes perfect sense - 
if the TX queue is normally getting stuck until TCP retransmits, then 
keeping the TX queue busy keeps the queue from remaining stuck.
I think this is a good demonstration that the underlying problem is a 
stuck TX queue as suggested.

 >I ended up (until now perhaps :-) with disabling the onboard nic and
 >adding an e1000 card.


Yes, ditching the realtek interface and going with an ad-on nic seems to 
be what everyone has been doing to get around this problem.  Perhaps 
you'd like to try the busy-wait workaround with ndelay(10)?  It has 
saved me from buying an e1000 card as well.

Speaking of the e1000, I notice that its TX queue processing code for 
that driver includes spin_lock_irqsave()/spin_unlock_irqrestore() 
protection on access to the queue.  The r8169 driver seems to be missing 
equivalent code.  Last time I dealt with kernel locking bugs was in the 
old days of splnet()/splx(), so I could use some help here, but I 
suspect this could be fixed with more careful locking.

