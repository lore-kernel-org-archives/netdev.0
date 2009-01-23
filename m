From: Pekka Enberg <penberg@cs.helsinki.fi>
Subject: Re: Mainline kernel OLTP performance update
Date: Fri, 23 Jan 2009 10:40:09 +0200
Message-ID: <1232700009.6094.19.camel@penberg-laptop>
References: <BC02C49EEB98354DBA7F5DD76F2A9E800317003CB0@azsmsx501.amr.corp.intel.com>
	 <200901161503.13730.nickpiggin@yahoo.com.au>
	 <20090115201210.ca1a9542.akpm@linux-foundation.org>
	 <200901161746.25205.nickpiggin@yahoo.com.au>
	 <20090116065546.GJ31013@parisc-linux.org>
	 <1232092430.11429.52.camel@ymzhang>  <87sknjeemn.fsf@basil.nowhere.org>
	 <1232428583.11429.83.camel@ymzhang>
	 <alpine.DEB.1.10.0901211852060.18367@qirst.com>
	 <1232613395.11429.122.camel@ymzhang>
	 <1232615707.14549.6.camel@penberg-laptop>
	 <1232616517.11429.129.camel@ymzhang>
	 <1232617672.14549.25.camel@penberg-laptop>
	 <1232679773.11429.155.camel@ymzhang>  <4979692B.3050703@cs.helsinki.fi>
	 <1232697998.6094.17.camel@penberg-laptop>
	 <1232699401.11429.163.camel@ymzhang>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: 7bit
Cc: Christoph Lameter <cl@linux-foundation.org>,
	Andi Kleen <andi@firstfloor.org>,
	Matthew Wilcox <matthew@wil.cx>,
	Nick Piggin <nickpiggin@yahoo.com.au>,
	Andrew Morton <akpm@linux-foundation.org>,
	netdev@vger.kernel.org, sfr@canb.auug.org.au,
	matthew.r.wilcox@intel.com, chinang.ma@intel.com,
	linux-kernel@vger.kernel.org, sharad.c.tripathi@intel.com,
	arjan@linux.intel.com, suresh.b.siddha@intel.com,
	harita.chilukuri@intel.com, douglas.w.styner@intel.com,
	peter.xihong.wang@intel.com, hubert.nueckel@intel.com,
	chris.mason@oracle.com, srostedt@redhat.com,
	linux-scsi@vger.kernel.org, andrew.vasquez@qlogic.com,
	anirban.chakraborty@qlogic.com, mingo@elte.hu
To: "Zhang, Yanmin" <yanmin_zhang@linux.intel.com>
Return-path: <linux-scsi-owner@vger.kernel.org>
In-Reply-To: <1232699401.11429.163.camel@ymzhang>
Sender: linux-scsi-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, 2009-01-23 at 16:30 +0800, Zhang, Yanmin wrote:
> > I assume binding the client and the server to different physical CPUs
> > also  means that the SKB is always allocated on CPU 1 and freed on CPU
> > 2? If so, we will be taking the __slab_free() slow path all the time on
> > kfree() which will cause cache effects, no doubt.
> > 
> > But there's another potential performance hit we're taking because the
> > object size of the cache is so big. As allocations from CPU 1 keep
> > coming in, we need to allocate new pages and unfreeze the per-cpu page.
> > That in turn causes __slab_free() to be more eager to discard the slab
> > (see the PageSlubFrozen check there).
> > 
> > So before going for cache profiling, I'd really like to see an oprofile
> > report. I suspect we're still going to see much more page allocator
> > activity
> Theoretically, it should, but oprofile doesn't show that.
> 
> > there than with SLAB or SLQB which is why we're still behaving
> > so badly here.
> 
> oprofile output with 2.6.29-rc2-slubrevertlarge:
> CPU: Core 2, speed 2666.71 MHz (estimated)
> Counted CPU_CLK_UNHALTED events (Clock cycles when not halted) with a unit mask of 0x00 (Unhalted core cycles) count 100000
> samples  %        app name                 symbol name
> 132779   32.9951  vmlinux                  copy_user_generic_string
> 25334     6.2954  vmlinux                  schedule
> 21032     5.2264  vmlinux                  tg_shares_up
> 17175     4.2679  vmlinux                  __skb_recv_datagram
> 9091      2.2591  vmlinux                  sock_def_readable
> 8934      2.2201  vmlinux                  mwait_idle
> 8796      2.1858  vmlinux                  try_to_wake_up
> 6940      1.7246  vmlinux                  __slab_free
> 
> #slaninfo -AD
> Name                   Objects    Alloc     Free   %Fast
> :0000256                  1643  5215544  5214027  94   0 
> kmalloc-8192                28  5189576  5189560   0   0 
                                                    ^^^^^^

This looks bit funny. Hmm.

> :0000168                  2631   141466   138976  92  28 
> :0004096                  1452    88697    87269  99  96 
> :0000192                  3402    63050    59732  89  11 
> :0000064                  6265    46611    40721  98  82 
> :0000128                  1895    30429    28654  93  32 


