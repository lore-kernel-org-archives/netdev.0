From: Abhijit Karmarkar <abhijitk@veritas.com>
Subject: Re: variation in thruput w/ change in mtu on gige
Date: Tue, 27 Apr 2004 10:16:57 +0530 (IST)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <Pine.GSO.4.50.0404270955050.20695-100000@revati>
References: <Pine.GSO.4.50.0404261700390.241-100000@revati>
    <408D246F.8090404@sgi.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Steve Modica <modica@sgi.com>
In-Reply-To: <408D246F.8090404@sgi.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Mon, 26 Apr 2004, Steve Modica wrote:

> Probably page size. 4k is one page so those are probably the most
> efficient IOs.  There must be some additional handling required to
> squeeze multiple pages into an MTU.

not sure. though i see copy_to_user() working harder on the rx side, in
case of MTU=9K.

> Have you profiled things at all to see what additional code has to run
> in order to handle multiple pages?

i did collect oprofile samples for my test runs (one-way flow, xmitting
38GB of data, using ttcp. same setup as earlier).

here is a summary (top 10 functions, for vmlinux and e1000):

for MTU=4096 (thruput = ~930Mbps) [At receiver]
----------------------------------------------------
	samples  %           symbol name
    vmlinux:
	28085    12.9316     default_idle
	24891    11.4609     __generic_copy_to_user
	12684    5.84026     tcp_v4_rcv
	11794    5.43047     __kmem_cache_alloc
	10966    5.04922     do_IRQ
	10834    4.98844     __wake_up
	8082     3.7213      try_to_wake_up
	7214     3.32164     __mod_timer
	6029     2.77601     net_rx_action
	5854     2.69544     ip_route_input
    e1000:
	52363    47.0657     e1000_intr
	36977    33.2363     e1000_irq_enable
	7435     6.68285     e1000_clean_tx_irq
	5024     4.51575     e1000_clean_rx_irq
	4764     4.28205     e1000_alloc_rx_buffers
	4037     3.6286      e1000_clean
	261      0.234596    e1000_tx_map
	258      0.2319      e1000_rx_checksum
	83       0.0746034   e1000_tx_queue
	48       0.0431441   e1000_xmit_frame


for MTU=9000 (thruput = ~806Mbps) [At receiver]
----------------------------------------------------
	samples  %           symbol name
    vmlinux:
	22533    20.7672     __generic_copy_to_user
	12178    11.2237     default_idle
	5893     5.43119     tcp_v4_rcv
	5151     4.74733     __wake_up
	5010     4.61738     __kmem_cache_alloc
	4585     4.22569     do_IRQ
	3592     3.31051     try_to_wake_up
	2966     2.73356     __mod_timer
	2683     2.47274     ip_route_input
	2491     2.29579     eth_type_trans
    e1000:
	20504    51.4349     e1000_intr
	10064    25.2458     e1000_irq_enable
	2860     7.17439     e1000_clean_tx_irq
	2292     5.74955     e1000_clean_rx_irq
	2261     5.67178     e1000_alloc_rx_buffers
	1583     3.971       e1000_clean
	132      0.331126    e1000_rx_checksum
	108      0.270921    e1000_tx_map
	35       0.0877985   e1000_tx_queue
	17       0.042645    e1000_xmit_frame


does that tell anything? also note that number of interrupts
(e1000_intr) is slightly higher for larger MTU.

[in case anybody needs the full profiles on both rx/tx side for
 differnet MTU's please let me know. i can mail them]

thanks
abhijit

>
> Steve
>
> Abhijit Karmarkar wrote:
> > Hi,
> >
> > i have observed that using jumbo frames (mtu=9000) decreases the thruput
> > (i am timing one-way ttcp). trying w/ different mtu's i see 4096 give
> > me the best numbers:
> >
> > mtu             thruput
> > -------------------------------
> > 1500 (default)  ~846Mbps
> > 4096            ~930Mbps <== highest
> > 8192            ~806Mbps
> > 9000            ~806Mbps
> > 15K             ~680Mbps
> >
> > my setup is:
> > - 2 nodes connected directly (cross-over cable)
> > - each node: 2-way, 2.4G Xeon. 4G RAM., running RHEL3 (2.4.21-4.ELsmp)
> > - intel gige (82543GC), e1000 ver. (5.1.11-k1)
> >   i think the cards are: 64bit/66Mhz PCI.
> > - ipv4.tcp_r/wmem and core.r/wmem_max set sufficiently high (512KB)
> > - using ttcp to xfer ~8GB one-way.
> >
> > why doesn't my thruput increase with increase in MTU? is it because of
> > small number of rx/txdescriptors on 82543GC (max=256?) or something
> > else?
> >
> > are there any driver parameters that i can tune to get better numbers
> > with larger MTUs?
> >
> > thanks,
> > abhijit
> >
>
>
> --
> Steve Modica
> work: 651-683-3224
> MTS-Technical Lead
> "Give a man a fish, and he will eat for a day, hit him with a fish and
> he leaves you alone" - me
>
