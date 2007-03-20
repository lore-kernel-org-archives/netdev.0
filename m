From: Chris Madden <chris@reflexsecurity.com>
Subject: Re: Oops in filter add
Date: Tue, 20 Mar 2007 10:15:20 -0400
Message-ID: <45FFEC78.2090708@reflexsecurity.com>
References: <45FEEE35.6090606@reflexsecurity.com>	 <20070319.192206.21926062.davem@davemloft.net> <1174373645.4895.15.camel@localhost>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: hadi@cyberus.ca
Return-path: <netdev-owner@vger.kernel.org>
Received: from crown.reflexsecurity.com ([72.54.139.163]:55769 "EHLO
	crown.reflexsecurity.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S933122AbXCTOPT (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 20 Mar 2007 10:15:19 -0400
In-Reply-To: <1174373645.4895.15.camel@localhost>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

jamal wrote:
> On Mon, 2007-19-03 at 19:22 -0700, David Miller wrote:
>> Can you just replace the above with dev->queue_lock and see if
>> that makes your problem go away?  THanks.
>>     
>
> It should; 
> i will stare at the code later and see if i can send a better patch,
> maybe a read_lock(qdisc_tree_lock). Chris, if you can experiment by just
> locking against filters instead, that would be nicer for the reasons i
> described above.
>
>   
Ok, I replaced ingress_lock with queue_lock in ing_filter and it died in
the same place.  Trace below (looks to be substantively the same)...

If I am reading tc_ctl_tfilter correctly, we are adding our new
tcf_proto to the end of the list, and it is getting used before the
change function is getting executed on it.   Locking the ingress_lock in
qdisc_lock_tree ( in addition to the extant queue_lock )seems to have
the same effect; I can get  a traceback from that if its useful.

BUG: unable to handle kernel NULL pointer dereference at virtual address
0000004
 printing
eip:                                                                 
f8a5f093                                                                       

*pde =
00000000                                                                
Oops: 0000
[#1]                                                                
SMP                                                                            

Modules linked in: af_packet cls_basic sch_ingress button ac battery
ts_match bn
CPU:   
0                                                                      
EIP:    0060:[<f8a5f093>]    Not tainted
VLI                                   
EFLAGS: 00010246   (2.6.20.3-x86
#1)                                           
EIP is at basic_classify+0xb/0x69
[cls_basic]                                  
eax: f3d57080   ebx: f3dd6f00   ecx: c0329f1c   edx:
f3dd6f00                  
esi: c0329f1c   edi: 00000000   ebp: f3d57080   esp:
c0329ee4                  
ds: 007b   es: 007b   ss:
0068                                                 
Process python (pid: 2503, ti=c0329000 task=f431e570
task.ti=f42ac000)         
Stack: f3dd6f00 f3d57080 f3dd6f00 00000008 c02206a1 00000286 f8aaad60
f3d57080 
       c0329f1c f3e606c0 f3d57080 00000000 df993000 f8a5c10b 00000080
c02108cd 
       df993000 f3d57080 c021454e df993000 00000040 f3db8780 00000008
00000000 
Call Trace:
 [<c02206a1>] tc_classify+0x34/0xbc                                      
 [<f8a5c10b>] ingress_enqueue+0x16/0x55 [sch_ingress]                    
 [<c02108cd>] __alloc_skb+0x53/0xfd                                      
 [<c021454e>] netif_receive_skb+0x1cd/0x2a6                              
 [<f88aa162>] e1000_clean_rx_irq+0x35b/0x42c [e1000]                     
 [<f88a9e07>] e1000_clean_rx_irq+0x0/0x42c [e1000]                       
 [<f88a9194>] e1000_clean+0x6e/0x23d [e1000]                             
 [<c011007b>] handle_vm86_fault+0x16/0x6f7                               
 [<c0215ef6>] net_rx_action+0xcc/0x1bc                                   
 [<c011cafc>] __do_softirq+0x5d/0xba                                     
 [<c0104c7f>] do_softirq+0x59/0xa9                                       
 [<c01341e3>] handle_fasteoi_irq+0x0/0xa0                                
 [<c0104d70>] do_IRQ+0xa1/0xb9                                           
 [<c010367f>] common_interrupt+0x23/0x28                                 
 [<c014c39a>] kmem_cache_zalloc+0x33/0x5c                                
 [<f8a5f4ac>] basic_change+0x17c/0x370 [cls_basic]                       
 [<c02220ff>] tc_ctl_tfilter+0x3ec/0x469                                 
 [<c0221d13>] tc_ctl_tfilter+0x0/0x469                                   
 [<c021b270>] rtnetlink_rcv_msg+0x1b3/0x1d8                              
 [<c0221398>] tc_dump_qdisc+0x0/0xfe                                     
 [<c02259ed>] netlink_run_queue+0x50/0xbe                                
 [<c021b0bd>] rtnetlink_rcv_msg+0x0/0x1d8                                
 [<c021b07c>] rtnetlink_rcv+0x25/0x3d
 [<c0225e34>] netlink_data_ready+0x12/0x4c
 [<c0224e2e>] netlink_sendskb+0x19/0x30
 [<c0225e16>]
netlink_sendmsg+0x242/0x24e                                      
 [<c020ba5f>]
sock_sendmsg+0xbc/0xd4                                           
 [<c012832d>]
autoremove_wake_function+0x0/0x35                                
 [<c012832d>]
autoremove_wake_function+0x0/0x35                                
 [<c010367f>]
common_interrupt+0x23/0x28                                       
 [<c021184e>]
verify_iovec+0x3e/0x70                                           
 [<c020bc0b>]
sys_sendmsg+0x194/0x1f9                                          
 [<c0112bde>]
__wake_up+0x32/0x43                                              
 [<c022508a>]
netlink_insert+0x106/0x110                                       
 [<c022515b>]
netlink_autobind+0xc7/0xe3                                       
 [<c0226376>]
netlink_bind+0x8d/0x127                                          
 [<c013f623>]
do_wp_page+0x149/0x36c                                           
 [<c015d183>]
d_alloc+0x138/0x17a                                              
 [<c0140a2c>]
__handle_mm_fault+0x756/0x7a6                                    
 [<c020caa8>]
sys_socketcall+0x223/0x242                                       
 [<c0263dc3>]
do_page_fault+0x0/0x525                                          
 [<c0102ce4>]
syscall_call+0x7/0xb                                             
 =======================                                                       

Code: 1a ff 43 08 8b 76 18 83 ee 18 8b 46 18 0f 18 00 90 8d 56 18 8d 47
04 39 c
EIP: [<f8a5f093>] basic_classify+0xb/0x69 [cls_basic] SS:ESP
0068:c0329ee4     
 <0>Kernel panic - not syncing: Fatal exception in
interrupt                   

