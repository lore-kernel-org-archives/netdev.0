From: Shawn Bohrer <sbohrer@rgmadvisors.com>
Subject: Re: Understanding lock contention in __udp4_lib_mcast_deliver
Date: Thu, 27 Jun 2013 17:44:44 -0500
Message-ID: <20130627224444.GE5936@sbohrermbp13-local.rgmadvisors.com>
References: <20130627192218.GA5936@sbohrermbp13-local.rgmadvisors.com>
 <51CC996F.3020507@hp.com>
 <20130627202008.GB5936@sbohrermbp13-local.rgmadvisors.com>
 <51CCA4C2.7050301@hp.com>
 <20130627215411.GC5936@sbohrermbp13-local.rgmadvisors.com>
 <51CCB6A3.9080806@hp.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Cc: netdev@vger.kernel.org
To: Rick Jones <rick.jones2@hp.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from na3sys009aog104.obsmtp.com ([74.125.149.73]:37043 "EHLO
	na3sys009aog104.obsmtp.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1754135Ab3F0Wos (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 27 Jun 2013 18:44:48 -0400
Received: by mail-ye0-f177.google.com with SMTP id q11so254419yen.22
        for <netdev@vger.kernel.org>; Thu, 27 Jun 2013 15:44:47 -0700 (PDT)
In-Reply-To: <51CCB6A3.9080806@hp.com>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Jun 27, 2013 at 03:03:15PM -0700, Rick Jones wrote:
> On 06/27/2013 02:54 PM, Shawn Bohrer wrote:
> >On Thu, Jun 27, 2013 at 01:46:58PM -0700, Rick Jones wrote:
> >>How do you know that time is actually contention and not simply
> >>acquire and release overhead?
> >
> >Excellent point, and that could be the problem with my thinking.  I
> >just now tried (unsuccessfully) to use lockstat to see if there was
> >any contention reported.  I read Documentation/lockstat.txt and
> >followed the instructions but the lock in question did not appear to
> >be in the output.  I think I'm going to have to go with the assumption
> >that this is just acquire and release overhead.
> 
> I think there is a way to get perf to "annotate" (iirc that is the
> term it uses) the report to show hits at the instruction level.
> Ostensibly one could then look and see how many of the hits were for
> the acquire/release part of the routine, and how much was for the
> actual contention.

Yep, so ~1% of my total time is in _raw_spin_lock and using perf
annotate it appears that maybe only 5-6% percent of that is actually
contention and the rest is acquire/release.  Looks like I need to look
elsewhere for my performance improvements.  Thanks Rick for your help!
Below is the output of perf annotate if your curious.

 Percent |      Source code & Disassembly of vmlinux
------------------------------------------------
         :
         :
         :
         :      Disassembly of section .text:
         :
         :      ffffffff814c72d0 <_raw_spin_lock>:
         :      EXPORT_SYMBOL(_raw_spin_trylock_bh);
         :      #endif
         :
         :      #ifndef CONFIG_INLINE_SPIN_LOCK
         :      void __lockfunc _raw_spin_lock(raw_spinlock_t *lock)
         :      {
    2.43 :      ffffffff814c72d0:       callq  ffffffff814cf440 <__fentry__>
    1.23 :      ffffffff814c72d5:       push   %rbp
    1.66 :      ffffffff814c72d6:       mov    %rsp,%rbp
         :       */
         :      static __always_inline void __ticket_spin_lock(arch_spinlock_t *lock)
         :      {
         :              register struct __raw_tickets inc = { .tail = 1 };
         :
         :              inc = xadd(&lock->tickets, inc);
    0.71 :      ffffffff814c72d9:       mov    $0x10000,%eax
    0.00 :      ffffffff814c72de:       lock xadd %eax,(%rdi)
   86.07 :      ffffffff814c72e2:       mov    %eax,%edx
    0.05 :      ffffffff814c72e4:       shr    $0x10,%edx
         :
         :              for (;;) {
         :                      if (inc.head == inc.tail)
    0.00 :      ffffffff814c72e7:       cmp    %ax,%dx
    0.00 :      ffffffff814c72ea:       je     ffffffff814c72fa <_raw_spin_lock+0x2a>
    0.04 :      ffffffff814c72ec:       nopl   0x0(%rax)
         :      }
         :
         :      /* REP NOP (PAUSE) is a good thing to insert into busy-wait loops. */
         :      static inline void rep_nop(void)
         :      {
         :              asm volatile("rep; nop" ::: "memory");
    0.47 :      ffffffff814c72f0:       pause  
         :                              break;
         :                      cpu_relax();
         :                      inc.head = ACCESS_ONCE(lock->tickets.head);
    2.85 :      ffffffff814c72f2:       movzwl (%rdi),%eax
         :              register struct __raw_tickets inc = { .tail = 1 };
         :
         :              inc = xadd(&lock->tickets, inc);
         :
         :              for (;;) {
         :                      if (inc.head == inc.tail)
    3.53 :      ffffffff814c72f5:       cmp    %ax,%dx
    0.00 :      ffffffff814c72f8:       jne    ffffffff814c72f0 <_raw_spin_lock+0x20>
         :              __raw_spin_lock(lock);
         :      }
    0.91 :      ffffffff814c72fa:       pop    %rbp
    0.00 :      ffffffff814c72fb:       retq   

--
Shawn

-- 

---------------------------------------------------------------
This email, along with any attachments, is confidential. If you 
believe you received this message in error, please contact the 
sender immediately and delete all copies of the message.  
Thank you.
