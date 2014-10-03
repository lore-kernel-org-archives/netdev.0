From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [net-next PATCH V6 0/2] qdisc: bulk dequeue support
Date: Fri, 03 Oct 2014 15:56:09 -0700
Message-ID: <1412376969.17245.21.camel@edumazet-glaptop2.roam.corp.google.com>
References: <20141001203345.3321.99675.stgit@dragon>
	 <20141003.123806.183331913071081861.davem@davemloft.net>
	 <1412369869.17245.4.camel@edumazet-glaptop2.roam.corp.google.com>
	 <20141003.145647.1980640682969765484.davem@davemloft.net>
	 <1412373477.17245.5.camel@edumazet-glaptop2.roam.corp.google.com>
	 <1412374535.17245.7.camel@edumazet-glaptop2.roam.corp.google.com>
	 <CA+mtBx_TQhbS3VPVKjosaQjyO8YkNi=zBQMVYEbLqR8Hyczd3Q@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>,
	Jesper Dangaard Brouer <brouer@redhat.com>,
	Linux Netdev List <netdev@vger.kernel.org>,
	Hannes Frederic Sowa <hannes@stressinduktion.org>,
	Florian Westphal <fw@strlen.de>,
	Daniel Borkmann <dborkman@redhat.com>,
	Jamal Hadi Salim <jhs@mojatatu.com>,
	Alexander Duyck <alexander.duyck@gmail.com>,
	John Fastabend <john.r.fastabend@intel.com>,
	Dave Taht <dave.taht@gmail.com>,
	Toke =?ISO-8859-1?Q?H=F8iland-J=F8rgensen?= <toke@toke.dk>
To: Tom Herbert <therbert@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f172.google.com ([209.85.192.172]:54217 "EHLO
	mail-pd0-f172.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1759191AbaJCWzi (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 3 Oct 2014 18:55:38 -0400
Received: by mail-pd0-f172.google.com with SMTP id ft15so318586pdb.3
        for <netdev@vger.kernel.org>; Fri, 03 Oct 2014 15:55:38 -0700 (PDT)
In-Reply-To: <CA+mtBx_TQhbS3VPVKjosaQjyO8YkNi=zBQMVYEbLqR8Hyczd3Q@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 2014-10-03 at 15:19 -0700, Tom Herbert wrote:
> On Fri, Oct 3, 2014 at 3:15 PM, Eric Dumazet <eric.dumazet@gmail.com> wrote:
> > On Fri, 2014-10-03 at 14:57 -0700, Eric Dumazet wrote:
> >> On Fri, 2014-10-03 at 14:56 -0700, David Miller wrote:
> >>
> >> > I completely agree, and I sort of intended this to happen when
> >> > I split all the code into that new function.
> >> >
> >> >   GSO segmentation of TX checksuming should not prevent other
> >> > > cpus from queueing other skbs in the qdisc.
> >> > >
> >> > > I will spend some time on this.
> >> >
> >> > Thanks!
> >>
> >> I just did my first reboot, will make sure everything is working well
> >> before sending the patch ;)
> >
> > This is awesome...
> >
> > 40Gb rate, with TSO=on or TSO=off, it does not matter anymore.
> >
> This is with or without GSO?

GSO=on

But with GSO off, I also get line rate, only spending more cpu.

    25.05%  [kernel]          [k] copy_user_enhanced_fast_string
     3.17%  [kernel]          [k] _raw_spin_lock                
     2.65%  [kernel]          [k] tcp_sendmsg                   
     2.43%  [kernel]          [k] tcp_ack                       
     2.08%  [kernel]          [k] __netif_receive_skb_core      
     1.88%  [kernel]          [k] menu_select                   
     1.69%  [kernel]          [k] put_compound_page             
     1.50%  [kernel]          [k] flush_smp_call_function_queue 
     1.48%  [kernel]          [k] int_sqrt                      
     1.43%  [kernel]          [k] call_function_single_interrupt
     1.42%  [kernel]          [k] cpuidle_enter_state           
     1.21%  perf              [.] 0x00000000000353f2            
     1.10%  [kernel]          [k] tcp_init_tso_segs             
     1.05%  [kernel]          [k] memcpy                        
     1.01%  [kernel]          [k] __skb_clone                   
     0.91%  [kernel]          [k] irq_entries_start             
     0.84%  [kernel]          [k] get_nohz_timer_target         
     0.84%  [kernel]          [k] put_page                      
     0.82%  [kernel]          [k] tcp_write_xmit                
     0.82%  [kernel]          [k] get_page_from_freelist        
     0.82%  [kernel]          [k] llist_reverse_order           
     0.80%  [kernel]          [k] native_sched_clock            
     0.79%  [kernel]          [k] cpu_startup_entry             
     0.78%  [kernel]          [k] kmem_cache_free               

The killer combination is GSO=off and TX=off, of course.

     9.90%  [kernel]          [k] csum_partial_copy_generic     
     7.64%  [kernel]          [k] _raw_spin_lock                
     6.10%  [kernel]          [k] tcp_ack                       
     5.11%  [kernel]          [k] __skb_clone                   
     3.90%  [kernel]          [k] __alloc_skb                   
     3.78%  [kernel]          [k] skb_release_data              
     3.45%  [kernel]          [k] csum_partial                  
     3.17%  [kernel]          [k] __kfree_skb                   
     3.07%  [kernel]          [k] skb_clone                     
     2.44%  [kernel]          [k] __kmalloc_node_track_caller   
     2.26%  [kernel]          [k] tcp_init_tso_segs             
     2.25%  [kernel]          [k] kfree                         
     1.98%  [kernel]          [k] pfifo_fast_dequeue            
     1.61%  [kernel]          [k] tcp_set_skb_tso_segs          
     1.45%  [kernel]          [k] kmem_cache_free               
