From: Rob Herring <robherring2@gmail.com>
Subject: Re: tg3: possible irq lock inversion dependency detected
Date: Fri, 19 Apr 2013 14:23:21 -0500
Message-ID: <517199A9.7060003@gmail.com>
References: <20130419190150.GA15355@linux.vnet.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, Matt Carlson <mcarlson@broadcom.com>,
	Michael Chan <mchan@broadcom.com>,
	Grant Likely <grant.likely@secretlab.ca>,
	linux-kernel@vger.kernel.org, Thomas Gleixner <tglx@linutronix.de>,
	Paul Gortmaker <paul.gortmaker@windriver.com>
To: Nishanth Aravamudan <nacc@linux.vnet.ibm.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20130419190150.GA15355@linux.vnet.ibm.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 04/19/2013 02:01 PM, Nishanth Aravamudan wrote:
> Running 3.9-rc7-ish, tripped the following (also being seen in FC19
> alpha) on ppc64:
> 
> [  117.026196] =========================================================
> [  117.026216] [ INFO: possible irq lock inversion dependency detected ]
> [  117.026238] 3.9.0-rc7+ #8 Not tainted
> [  117.026251] ---------------------------------------------------------
> [  117.026271] swapper/7/0 just changed the state of lock:
> [  117.026286]  (&(&tp->lock)->rlock){+.-...}, at: [<c00000000064effc>] .tg3_timer+0x9c/0x10f0
> [  117.026334] but this lock took another, SOFTIRQ-unsafe lock in the past:
> [  117.026353]  (devtree_lock){+.+...}
>  
> and interrupts could create inverse lock ordering between them.
>  
> [  117.026389]
> other info that might help us debug this:
> [  117.026409] Chain exists of:
>   &(&tp->lock)->rlock --> pci_lock --> devtree_lock
>  
> [  117.026452]  Possible interrupt unsafe locking scenario:
>  
> [  117.026472]        CPU0                    CPU1
> [  117.026488]        ----                    ----
> [  117.026503]   lock(devtree_lock);
> [  117.026521]                                local_irq_disable();
> [  117.026540]                                lock(&(&tp->lock)->rlock);
> [  117.026567]                                lock(pci_lock);
> [  117.026591]   <Interrupt>
> [  117.026600]     lock(&(&tp->lock)->rlock);
> [  117.026621]
>  *** DEADLOCK ***
>  
> [  117.026644] 1 lock held by swapper/7/0:
> [  117.026657]  #0:  ((&tp->timer)){+.-...}, at: [<c0000000000bbc50>] .call_timer_fn+0x0/0x3e0
> [  117.026698]
> the shortest dependencies between 2nd lock and 1st lock:
> [  117.026722]   -> (devtree_lock){+.+...} ops: 13864154431488 {
> [  117.026758]      HARDIRQ-ON-W at:
> [  117.026772]      SOFTIRQ-ON-W at:
> [  117.026786]      INITIAL USE at:
> [  117.026799]    }
> [  117.026809]    ... key      at: [<c00000000159b208>] devtree_lock+0x18/0x48
> [  117.026835]    ... acquired at:
>  
> [  117.026857]  -> (pci_lock){......} ops: 3955664879616 {
> [  117.026893]     INITIAL USE at:
> [  117.026906]   }
> [  117.026915]   ... key      at: [<c00000000157abe8>] pci_lock+0x18/0x48
> [  117.026942]   ... acquired at:
>  
> [  117.026963] -> (&(&tp->lock)->rlock){+.-...} ops: 154618822656 {
> [  117.027001]    HARDIRQ-ON-W at:
> [  117.027015]    IN-SOFTIRQ-W at:
> [  117.027029]    INITIAL USE at:
> [  117.027042]  }
> [  117.027051]  ... key      at: [<c0000000023a0311>] __key.48770+0x0/0x8
> [  117.027078]  ... acquired at:
>  
> [  117.027100]
> stack backtrace:
> [  117.027116] Call Trace:
> [  117.027129] [c0000003a7c7ad10] [c000000000016ee0] .show_stack+0xd0/0x1f0 (unreliable)
> [  117.027161] [c0000003a7c7ade0] [c000000000137d78] .print_irq_inversion_bug+0x298/0x2f0
> [  117.027189] [c0000003a7c7ae80] [c000000000137e70] .check_usage_forwards+0xa0/0x150
> [  117.027217] [c0000003a7c7af70] [c000000000138b68] .mark_lock+0x258/0x7b0
> [  117.027242] [c0000003a7c7b030] [c0000000001396f8] .__lock_acquire+0x638/0x1c20
> [  117.027270] [c0000003a7c7b1b0] [c00000000013b480] .lock_acquire+0xb0/0x250
> [  117.027296] [c0000003a7c7b290] [c00000000093a1cc] ._raw_spin_lock+0x5c/0xc0
> [  117.027321] [c0000003a7c7b320] [c00000000064effc] .tg3_timer+0x9c/0x10f0
> [  117.027345] [c0000003a7c7b3d0] [c0000000000bbd0c] .call_timer_fn+0xbc/0x3e0
> [  117.027369] [c0000003a7c7b4b0] [c0000000000bc328] .run_timer_softirq+0x2f8/0x440
> [  117.027398] [c0000003a7c7b5c0] [c0000000000afef8] .__do_softirq+0x1b8/0x540
> [  117.027423] [c0000003a7c7b6f0] [c0000000000b04e8] .irq_exit+0xe8/0x100
> [  117.027448] [c0000003a7c7b770] [c000000000020464] .timer_interrupt+0x174/0x510
> [  117.027477] [c0000003a7c7b830] [c0000000000024f4] decrementer_common+0x174/0x180
> [  117.027509] --- Exception: 901 at .plpar_hcall_norets+0x84/0xd4
>     LR = .check_and_cede_processor+0x48/0x80
> [  117.027544] [c0000003a7c7bb20] [c000000000085168] .check_and_cede_processor+0x18/0x80 (unreliable)
> [  117.027577] [c0000003a7c7bb90] [c000000000085258] .dedicated_cede_loop+0x88/0x150
> [  117.027606] [c0000003a7c7bc50] [c00000000075808c] .cpuidle_enter+0x2c/0x40
> [  117.027632] [c0000003a7c7bcc0] [c0000000007589bc] .cpuidle_idle_call+0xfc/0x4e0
> [  117.027660] [c0000003a7c7bd70] [c000000000074be8] .pSeries_idle+0x18/0x40
> [  117.027685] [c0000003a7c7bde0] [c000000000018ec0] .cpu_idle+0x180/0x360
> [  117.027711] [c0000003a7c7bea0] [c00000000095391c] .start_secondary+0x534/0x53c
> [  117.027739] [c0000003a7c7bf90] [c0000000000097fc] .start_secondary_prolog+0x10/0x14
> 

It might be related to this commit. Can you revert and try it.

commit d6d3c4e656513dcea61ce900f0ecb9ca820ee7cd
Author: Thomas Gleixner <tglx@linutronix.de>
Date:   Wed Feb 6 15:30:56 2013 -0500

    OF: convert devtree lock from rw_lock to raw spinlock

    With the locking cleanup in place (from "OF: Fixup resursive
    locking code paths"), we can now do the conversion from the
    rw_lock to a raw spinlock as required for preempt-rt.

    The previous cleanup and this conversion were originally
    separate since they predated when mainline got raw spinlock (in
    commit c2f21ce2e31286a "locking: Implement new raw_spinlock").

    So, at that point in time, the cleanup was considered plausible
    for mainline, but not this conversion.  In any case, we've kept
    them separate as it makes for easier review and better bisection.

    Signed-off-by: Thomas Gleixner <tglx@linutronix.de>
    [PG: taken from preempt-rt, update subject & add a commit log]
    Signed-off-by: Paul Gortmaker <paul.gortmaker@windriver.com>
    Signed-off-by: Rob Herring <rob.herring@calxeda.com>
