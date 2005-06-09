From: Jesse Brandeburg <jesse.brandeburg@intel.com>
Subject: Re: RFC: NAPI packet weighting patch
Date: Thu, 9 Jun 2005 14:37:31 -0700 (PDT)
Message-ID: <Pine.LNX.4.62.0506091406590.10396@ladlxr>
References: <468F3FDA28AA87429AD807992E22D07E0450C01F@orsmsx408>
 <20050607.132159.35660612.davem@davemloft.net> <Pine.LNX.4.62.0506071852290.31708@ladlxr>
 <20050607.204339.21591152.davem@davemloft.net> <1118237775.6382.34.camel@localhost.localdomain>
Mime-Version: 1.0
Content-Type: MULTIPART/MIXED; BOUNDARY="8323328-264338517-1118353051=:10396"
Cc: "David S. Miller" <davem@davemloft.net>,
        "Brandeburg, Jesse" <jesse.brandeburg@intel.com>,
        "Ronciak, John" <john.ronciak@intel.com>, shemminger@osdl.org,
        "Williams, Mitch A" <mitch.a.williams@intel.com>, mchan@broadcom.com,
        buytenh@wantstofly.org, jdmason@us.ibm.com, netdev@oss.sgi.com,
        Robert.Olsson@data.slu.se,
        "Venkatesan, Ganesh" <ganesh.venkatesan@intel.com>
Return-path: <netdev-bounce@oss.sgi.com>
To: jamal <hadi@cyberus.ca>
In-Reply-To: <1118237775.6382.34.camel@localhost.localdomain>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

  This message is in MIME format.  The first part should be readable text,
  while the remaining parts are likely unreadable without MIME-aware tools.

--8323328-264338517-1118353051=:10396
Content-Type: TEXT/PLAIN; charset=iso-8859-1; format=flowed
Content-Transfer-Encoding: quoted-printable
X-MIME-Autoconverted: from 8bit to quoted-printable by oss.sgi.com id j59LfVXq017815

On Wed, 8 Jun 2005, jamal wrote:
> > Something is up, if a single gigabit TCP stream can fully CPU
> > load your machine.=A0 10 gigabit, yeah, definitely all current
> > generation machines are cpu limited over that link speed, but
> > 1 gigabit should be no problem.
> >
>=20
> Yes, sir.
> BTW, all along i thought the sender and receiver are hooked up directly
> (there was some mention of chariot a while back).

Okay let me clear this up once and for all, here is our test setup:

* 10 1u rack machines (dual P3 - 1250MHz), with both windows and linux=20
installed (running windows now)
* Extreme 1gig switch
* Dual 2.8 GHz P4 server, RHEL3 base, running 2.6.12-rc5 or supertso patc=
h

* the test entails transferring 1MB files of zeros from memory to memory,=
=20
using TCP, with each client doing primary either send or recv, not both.

> Even if they did have some smart ass thing in the middle that reorders,
> it is still suprising that such a fast CPU cant handle a mere one Gig o=
f
> what seems to be MTU=3D1500 bytes sized packets.

It can handle a single thread (or even 6) just fine, its after that we ge=
t=20
in trouble somewhere.

> I suppose a netstat -s would help for visualization in addition to thos=
e
> dumps.

Okay I have that data, do you want it for the old tso, supertso, or no ts=
o=20
at all?

> Heres what i am deducing from their data, correct me if i am wrong:
> ->The evidence is that something is expensive in their code path (duh).

Actually I've found that adding more threads (10 total) sending to the=20
server, while keeping the transmit thread count constant yields an=20
increase our throughput all the way to 1750+ Mb/s (with supertso)

> -> Whatever that expensive thing code is, it not helped by them
> replenishing the descriptors after all the budget is exhausted since th=
e
> descriptor departure rate is much slower than packet arrival.

I'm running all my tests with the replenish patch mentioned earlier in=20
this thread.

> ---> This is why they would be seeing that the reduction of weight
> improves performance since the replenishing happens sooner with a
> smaller weight.

seems like we're past the weight problem now, should i start a new thread=
?

> ------> Clearly the driver needs some fixing - if they could do what

I'm not convinced it is the driver that is having issues.  We might be=20
having some complex interaction with the stack, but I definitely think we=
=20
have a lot of onion layers to hack through here, all of which are probabl=
y=20
relevant.

> Even if they SACKed for every packet, this still would not make any
> sense. So i think a profile of where the cycles are spent would also
> help. I am suspecting the driver at this point but i could be wrong.

I have profile data, here is an example of 5tx/5rx threads, where the=20
throughput was 1236Mb/s total, 936tx, 300rx, on 2.6.12-rc5 with old TSO=20
(the original problem case) we are at 100% cpu and generating 3289 ints/s=
,=20
with no hardware drops reported prolly due to my replenish patch
CPU: P4 / Xeon with 2 hyper-threads, speed 2791.36 MHz (estimated)
Counted GLOBAL_POWER_EVENTS events (time during which processor is not st=
opped) with a unit mask of 0x01 (mandatory) count 100000
samples  %        image name       symbol name
533687    8.1472  vmlinux          pskb_expand_head
428726    6.5449  vmlinux          __copy_user_zeroing_intel
349934    5.3421  vmlinux          _read_lock_irqsave
313667    4.7884  vmlinux          csum_partial
218870    3.3413  vmlinux          _spin_lock
214302    3.2715  vmlinux          __copy_user_intel
193662    2.9564  vmlinux          skb_release_data
177755    2.7136  vmlinux          ipt_do_table
148445    2.2662  vmlinux          _write_lock_irqsave
148080    2.2606  vmlinux          _read_unlock_bh
143308    2.1877  vmlinux          tcp_sendmsg
115745    1.7670  vmlinux          ip_queue_xmit
111487    1.7020  vmlinux          __kfree_skb
108383    1.6546  vmlinux          _spin_lock_irqsave
108071    1.6498  e1000.ko         e1000_xmit_frame
107850    1.6464  vmlinux          tcp_clean_rtx_queue
104552    1.5961  e1000.ko         e1000_clean_tx_irq
101308    1.5466  e1000.ko         e1000_clean_rx_irq
94297     1.4395  vmlinux          __copy_from_user_ll
85170     1.3002  vmlinux          kfree
76730     1.1714  vmlinux          tcp_transmit_skb
70976     1.0835  vmlinux          eth_type_trans
67381     1.0286  vmlinux          tcp_rcv_established
64670     0.9872  vmlinux          sub_preempt_count
64451     0.9839  vmlinux          dev_queue_xmit
64010     0.9772  vmlinux          skb_clone
62314     0.9513  vmlinux          tcp_v4_rcv
61980     0.9462  vmlinux          nf_iterate
60374     0.9217  vmlinux          ip_finish_output
57407     0.8764  vmlinux          _write_unlock_bh
56165     0.8574  vmlinux          mark_offset_tsc
54673     0.8346  endpoint         (no symbols)
52662     0.8039  vmlinux          __kmalloc
50112     0.7650  vmlinux          sock_wfree
50001     0.7633  vmlinux          _spin_trylock
47053     0.7183  vmlinux          _read_lock_bh
45988     0.7021  vmlinux          tcp_write_xmit
44229     0.6752  vmlinux          kmem_cache_alloc
43506     0.6642  vmlinux          smp_processor_id
42401     0.6473  vmlinux          ip_conntrack_find_get
42095     0.6426  vmlinux          alloc_skb
40619     0.6201  vmlinux          tcp_in_window
38098     0.5816  vmlinux          add_preempt_count
37701     0.5755  vmlinux          __copy_to_user_ll
31529     0.4813  vmlinux          ip_conntrack_in
31314     0.4780  vmlinux          kmem_cache_free
30954     0.4725  vmlinux          __ip_conntrack_find
30863     0.4712  vmlinux          local_bh_enable
30774     0.4698  vmlinux          tcp_packet
29426     0.4492  vmlinux          _spin_unlock_irqrestore
28716     0.4384  vmlinux          hash_conntrack
27073     0.4133  vmlinux          ip_route_input
26540     0.4052  e1000.ko         e1000_clean
25817     0.3941  vmlinux          nf_hook_slow
23395     0.3571  vmlinux          schedule
22981     0.3508  vmlinux          tcp_v4_send_check
22139     0.3380  vmlinux          __mod_timer
22126     0.3378  vmlinux          timer_interrupt
21511     0.3284  vmlinux          cache_alloc_refill
21161     0.3230  vmlinux          netif_receive_skb
20418     0.3117  vmlinux          _write_lock_bh
19443     0.2968  vmlinux          skb_copy_datagram_iovec
19100     0.2916  vmlinux          ip_nat_fn
18784     0.2868  vmlinux          ip_local_deliver
18251     0.2786  vmlinux          _read_lock
17513     0.2674  vmlinux          nat_packet
17124     0.2614  e1000.ko         e1000_intr
16357     0.2497  vmlinux          default_idle
15358     0.2345  vmlinux          qdisc_restart
14564     0.2223  vmlinux          _read_unlock
14360     0.2192  vmlinux          tcp_recvmsg
13853     0.2115  oprofiled        odb_insert
13374     0.2042  e1000.ko         e1000_alloc_rx_buffers
13321     0.2034  vmlinux          apic_timer_interrupt
12668     0.1934  vmlinux          pfifo_fast_enqueue
12618     0.1926  vmlinux          tcp_sack
12180     0.1859  vmlinux          ip_nat_local_fn
11434     0.1746  vmlinux          system_call
11426     0.1744  vmlinux          free_block
11377     0.1737  vmlinux          try_to_wake_up
11138     0.1700  vmlinux          irq_entries_start
11017     0.1682  vmlinux          ipt_route_hook
10987     0.1677  vmlinux          dev_queue_xmit_nit
10970     0.1675  vmlinux          tcp_push_one
10508     0.1604  vmlinux          tcp_error
10365     0.1582  vmlinux          pfifo_fast_dequeue
10323     0.1576  vmlinux          ip_rcv
10022     0.1530  vmlinux          ip_output

--8323328-264338517-1118353051=:10396--
