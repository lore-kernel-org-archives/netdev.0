From: Timur Tabi <timur@freescale.com>
Subject: Re: [PATCH] netdev/phy: Use mdiobus_read() so that proper locks are
 taken.
Date: Mon, 14 Nov 2011 11:10:42 -0600
Message-ID: <4EC14B92.70607@freescale.com>
References: <1317419482-25655-1-git-send-email-david.daney@cavium.com>	<CAOZdJXXA6nBv8Gaqu=qcL2DxjNB-ENrxameVQTep9FEbZ1jtGQ@mail.gmail.com>	<4EBC70EB.7080002@cavium.com> <CAKWjMd4WjDNHH8dOr9GPxQTC69SGgjh+euWh_DSjhtRxquB8qA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Cc: David Daney <david.daney@cavium.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"davem@davemloft.net" <davem@davemloft.net>
To: Andy Fleming <afleming@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from va3ehsobe004.messaging.microsoft.com ([216.32.180.14]:47419
	"EHLO VA3EHSOBE004.bigfish.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751963Ab1KNRKr (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 14 Nov 2011 12:10:47 -0500
In-Reply-To: <CAKWjMd4WjDNHH8dOr9GPxQTC69SGgjh+euWh_DSjhtRxquB8qA@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Andy Fleming wrote:

> Yes, that is correct. I have a patch, I just have to resend it. Will do
> next time I come to a break in what I'm working on.

Can you point me to that patch, so that I can try it out now?

I fixed some lockdep-related code in my audio driver.  The driver was not initializing a sysfs attr structure, so I added a call to sysfs_attr_init().  But when I do that, I get the following bug report.  I don't understand the connection.

=============================================                                   
[ INFO: possible recursive locking detected ]                                   
3.2.0-10b-00093-gebea711-dirty #10                                              
---------------------------------------------                                   
kworker/1:1/271 is trying to acquire lock:                                      
 (&(&(priv->tx_queue[i]->txlock))->rlock){......}, at: [<c02b2e28>] lock_tx_qs+0
x34/0x54                                                                        
                                                                                
but task is already holding lock:                                               
 (&(&(priv->tx_queue[i]->txlock))->rlock){......}, at: [<c02b2e28>] lock_tx_qs+0
x34/0x54                                                                        
                                                                                
other info that might help us debug this:                                       
 Possible unsafe locking scenario:                                              
                                                                                
       CPU0                                                                     
       ----                                                                     
  lock(&(&(priv->tx_queue[i]->txlock))->rlock);                                 
  lock(&(&(priv->tx_queue[i]->txlock))->rlock);                                 
                                                                                
 *** DEADLOCK ***                                                               
                                                                                
 May be due to missing lock nesting notation                                    
                                                                                
4 locks held by kworker/1:1/271:                                                
 #0:  (events){.+.+.+}, at: [<c005b7c8>] process_one_work+0x138/0x490           
 #1:  ((&(&dev->state_queue)->work)){+.+...}, at: [<c005b7c8>] process_one_work+
0x138/0x490                                                                     
 #2:  (&dev->lock){+.+...}, at: [<c02ab3cc>] phy_state_machine+0x30/0x580       
 #3:  (&(&(priv->tx_queue[i]->txlock))->rlock){......}, at: [<c02b2e28>] lock_tx
_qs+0x34/0x54                                                                   
                                                                                
stack backtrace:                                                                
Call Trace:                                                                     
[e69d5d80] [c0008c7c] show_stack+0x44/0x154 (unreliable)                        
[e69d5dc0] [c007bafc] __lock_acquire+0xefc/0x1824                               
[e69d5e70] [c007c870] lock_acquire+0x4c/0x68                                    
[e69d5e90] [c04575d8] _raw_spin_lock+0x44/0x60                                  
[e69d5ea0] [c02b2e28] lock_tx_qs+0x34/0x54                                      
[e69d5ec0] [c02b2f24] adjust_link+0x34/0x1d8                                    
[e69d5ef0] [c02ab73c] phy_state_machine+0x3a0/0x580                             
[e69d5f10] [c005b83c] process_one_work+0x1ac/0x490                              
[e69d5f50] [c005e4c0] worker_thread+0x18c/0x35c                                 
[e69d5f90] [c00631d4] kthread+0x7c/0x80                                         
[e69d5ff0] [c000e588] kernel_thread+0x4c/0x68                                   

-- 
Timur Tabi
Linux kernel developer at Freescale
