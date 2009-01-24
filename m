From: Willy Tarreau <w@1wt.eu>
Subject: Re: [PATCH] tcp: splice as many packets as possible at once
Date: Sat, 24 Jan 2009 22:23:15 +0100
Message-ID: <20090124212315.GA20177@1wt.eu>
References: <20090115234408.GA1693@1wt.eu> <20090115.155434.206643894.davem@davemloft.net> <20090119004206.GA10396@1wt.eu> <20090118.192815.41774176.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: herbert@gondor.apana.org.au, jarkao2@gmail.com, zbr@ioremap.net,
	dada1@cosmosbay.com, ben@zeus.com, mingo@elte.hu,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	jens.axboe@oracle.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from 1wt.eu ([62.212.114.60]:1745 "EHLO 1wt.eu"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754420AbZAXVXt (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 24 Jan 2009 16:23:49 -0500
Content-Disposition: inline
In-Reply-To: <20090118.192815.41774176.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi David,

On Sun, Jan 18, 2009 at 07:28:15PM -0800, David Miller wrote:
> From: Willy Tarreau <w@1wt.eu>
> Date: Mon, 19 Jan 2009 01:42:06 +0100
> 
> > Hi guys,
> > 
> > On Thu, Jan 15, 2009 at 03:54:34PM -0800, David Miller wrote:
> > > From: Willy Tarreau <w@1wt.eu>
> > > Date: Fri, 16 Jan 2009 00:44:08 +0100
> > > 
> > > > And BTW feel free to add my Tested-by if you want in case you merge
> > > > this fix.
> > > 
> > > Done, thanks Willy.
> > 
> > Just for the record, I've now re-integrated those changes in a test kernel
> > that I booted on my 10gig machines. I have updated my user-space code in
> > haproxy to run a new series of tests. Eventhough there is a memcpy(), the
> > results are EXCELLENT (on a C2D 2.66 GHz using Myricom's Myri10GE NICs) :
> > 
> >   - 4.8 Gbps at 100% CPU using MTU=1500 without LRO
> >     (3.2 Gbps at 100% CPU without splice)
> > 
> >   - 9.2 Gbps at 50% CPU using MTU=1500 with LRO
> > 
> >   - 10 Gbps at 20% CPU using MTU=9000 without LRO (7 Gbps at 100% CPU without
> >     splice)
> > 
> >   - 10 Gbps at 15% CPU using MTU=9000 with LRO
> 
> Thanks for the numbers.
> 
> We can almost certainly do a lot better, so if you have the time and
> can get some oprofile dumps for these various cases that would be
> useful to us.

Well, I tried to get oprofile to work on those machines, but I'm surely
missing something, as "opreport" always complains :
  opreport error: No sample file found: try running opcontrol --dump
  or specify a session containing sample files

I've straced opcontrol --dump, opcontrol --stop, and I see nothing
creating any file in the samples directory. I thought it would be
opjitconv which would do it, but it's hard to debug, and I haven't
used oprofile for a 2/3 years now. I followed exactly the instructions
in the kernel doc, as well as a howto found on the net, but I remain
out of luck. I just see a "complete_dump" file created with only two
bytes. It's not easy to debug on those machines are they're diskless
and PXE-booted from squashfs root images.

However, upon Ingo's suggestion I tried his perfcounters while
running a test at 5 Gbps with haproxy running alone on one core,
and IRQs on the other one. No LRO was used and MTU was 1500.

For instance, kerneltop tells how many CPU cycles are spent in each
function :

# kerneltop -e 0 -d 1 -c 1000000 -C 1

             events         RIP          kernel function
  ______     ______   ________________   _______________

            1864.00 - 00000000f87be000 : init_module    [myri10ge]
            1078.00 - 00000000784a6580 : tcp_read_sock
             901.00 - 00000000784a7840 : tcp_sendpage
             857.00 - 0000000078470be0 : __skb_splice_bits
             617.00 - 00000000784b2260 : tcp_transmit_skb
             604.00 - 000000007849fdf0 : __ip_local_out
             581.00 - 0000000078470460 : __copy_skb_header
             569.00 - 000000007850cac0 : _spin_lock     [myri10ge]
             472.00 - 0000000078185150 : __slab_free
             443.00 - 000000007850cc10 : _spin_lock_bh  [sky2]
             434.00 - 00000000781852e0 : __slab_alloc
             408.00 - 0000000078488620 : __qdisc_run
             355.00 - 0000000078185b20 : kmem_cache_free
             352.00 - 0000000078472950 : __alloc_skb
             348.00 - 00000000784705f0 : __skb_clone
             337.00 - 0000000078185870 : kmem_cache_alloc       [myri10ge]
             302.00 - 0000000078472150 : skb_release_data
             297.00 - 000000007847bcf0 : dev_queue_xmit
             285.00 - 00000000784a08f0 : ip_queue_xmit

You should ignore the lines init_module, _spin_lock, etc, in fact all
lines indicating a module, as there's something wrong there, they
always report the name of the last module loaded, and the name changes
when the module is unloaded.

I also tried dumping the number of cache misses per function :

------------------------------------------------------------------------------
 KernelTop:    1146 irqs/sec  [NMI, 1000 cache-misses],  (all, cpu: 1)
------------------------------------------------------------------------------

             events         RIP          kernel function
  ______     ______   ________________   _______________

            7512.00 - 00000000784a6580 : tcp_read_sock
            2716.00 - 0000000078470be0 : __skb_splice_bits
            2516.00 - 00000000784a08f0 : ip_queue_xmit
             986.00 - 00000000784a7840 : tcp_sendpage
             587.00 - 00000000781a40c0 : sys_splice
             462.00 - 00000000781856b0 : kfree  [myri10ge]
             451.00 - 000000007849fdf0 : __ip_local_out
             242.00 - 0000000078185b20 : kmem_cache_free
             205.00 - 00000000784b1b90 : __tcp_select_window
             153.00 - 000000007850cac0 : _spin_lock     [myri10ge]
             142.00 - 000000007849f6a0 : ip_fragment
             119.00 - 0000000078188950 : rw_verify_area
             117.00 - 00000000784a99e0 : tcp_rcv_space_adjust
             107.00 - 000000007850cc10 : _spin_lock_bh  [sky2]
             104.00 - 00000000781852e0 : __slab_alloc

There are other options to combine events but I don't understand
the output when I enable it.

I think that when properly used, these tools can report useful
information.

Regards,
Willy

