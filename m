From: Bruce Cole <bacole@gmail.com>
Subject: Re: r8169: slow samba performance
Date: Tue, 04 Sep 2007 14:51:59 -0700
Message-ID: <46DDD37F.8080905@gmail.com>
References: <46CC66D3.8030602@gmail.com> <20070822182116.GA5445@csy.ca> <46CC9290.3040501@gmail.com> <Pine.SOC.4.64.0708271631330.871@katana> <20070903210322.GB4444@electric-eye.fr.zoreil.com> <Pine.SOC.4.64.0709041402130.871@katana> <20070904203742.GB31783@electric-eye.fr.zoreil.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: john@BlueSkyTours.com, netdev@vger.kernel.org
To: Francois Romieu <romieu@fr.zoreil.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from wa-out-1112.google.com ([209.85.146.178]:64045 "EHLO
	wa-out-1112.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752202AbXIDV4p (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 4 Sep 2007 17:56:45 -0400
Received: by wa-out-1112.google.com with SMTP id v27so2364076wah
        for <netdev@vger.kernel.org>; Tue, 04 Sep 2007 14:56:44 -0700 (PDT)
In-Reply-To: <20070904203742.GB31783@electric-eye.fr.zoreil.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Francois Romieu wrote:
> Does "acceptable" mean that there is a noticeable difference when compared
> to the patch based on a busy-waiting loop ?
>
>   
>> Would you like me to *just* try patches 1 & 2, to help narrow down anything?
>>     
>
> I expect patch #2 alone to be enough to enhance the performance. If it gets
> proven, the patch would be a good candidate for a quick merge upstream.
>
>   
Patch #0002 looks functionally equivalent to the patch I already pointed 
folks
to and which I showed as being sufficient to address the TX queue problem.
The fix has also already been confirmed by shane, that fix being:

diff -c r/r8169.c r3/r8169-out.c
*** r/r8169.c   2007-08-18 11:54:58.000000000 -0700
--- r3/r8169-out.c      2007-09-04 14:23:49.000000000 -0700
***************
*** 2646,2651 ****
--- 2646,2655 ----
                if (netif_queue_stopped(dev) &&
                    (TX_BUFFS_AVAIL(tp) >= MAX_SKB_FRAGS)) {
                        netif_wake_queue(dev);
+               } else if (dirty_tx != tp->cur_tx) {
+                       netif_tx_lock(dev);
+                       RTL_W8(TxPoll, NPQ);
+                       netif_tx_unlock(dev);
                }
        }
  }


In any case, I've tried your latest version of the patch,
0002-r8169-workaround-against-ignored-TxPoll-writes-8168.patch, and it alone
works as well.


I'm not sure why you describe this as being an "8168 hack", given that the
problem has been seen with the 8111b chip (I have an 8111b chip on my 
gigabyte
motherboard).


Now since this change heals the TX queue stall, it would seem that the real
underlying problem involves a race condition with enqueueing to the TX queue
while the controller is processing the queue.  The ultimate fix for that 
I bet
is either to address locking at TX enqueue time, or there is a 
controller bug.
Any clarification from realtek on the necessary processing for the NPQ 
bit, or
a known controller problem?
 
PS: I've also received private email that this problem pertains to video
streaming (to a Kiss DVD player) not just samba or X11 traffic.  Basically
most all high-level TCP based protocols are affected it seems.  This serious
performance problem should be considered to impact a lot more than just 
samba
users.



