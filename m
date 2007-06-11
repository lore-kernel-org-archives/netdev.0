From: Philip Romanov <philip_romanov@yahoo.com>
Subject: Re: SKY2 vs SK98LIN performance on 88E8053 MAC
Date: Mon, 11 Jun 2007 12:05:02 -0700 (PDT)
Message-ID: <709767.60054.qm@web52311.mail.re2.yahoo.com>
References: <20070610092628.4287a935@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7BIT
Cc: netdev@vger.kernel.org
To: Stephen Hemminger <shemminger@linux-foundation.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from web52311.mail.re2.yahoo.com ([206.190.48.154]:26613 "HELO
	web52311.mail.re2.yahoo.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with SMTP id S1751808AbXFKULM (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 11 Jun 2007 16:11:12 -0400
In-Reply-To: <20070610092628.4287a935@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org



> > We are doing pure IPv4 forwarding between two
> Ethernet
> > interfaces:
> > 
> >  IXIA port A<--->System Under Test<--->IXIA Port B
> > 
> > Traffic has two IP destinations for each direction
> and
> > L4 protocol is UDP. There are two static ARP
> entries
> > and only interface routes. Two tests are identical
> > except that we switch from one driver to another. 
> > 
> > Ethernet ports on the SUT are oversubscribed --
> I'm
> > sending 60% of line rate (of 256-byte packets) and
> > measuring percentage of pass-through traffic which
> > makes to the IXIA port on the other side. Traffic
> is
> > bidirectional and system load is close to 100%.
> > 

> 
> Could you post the profiles. Hopefully, others have
> good ideas
> as well.
> 
> 256 bytes is the size where the copybreak
> optimization kicks in
> so you might want to experiment with the copybreak
> module option
> to the sky2 driver. copybreak=0 would no packets to
> be copied,
> copybreak=1514 would cause all packets to be copied.
>  Copying is
> an optimization that helps when receiving small
> packets locally,
> but may slow down forwarding path.
> 
 

Profiles were attached to previous posting in the
thread. I'm pasting them in plain text now at the end.
There are four profiles: two for the vmlinux and two
for sky2 and sk98lin drivers.

Regarding copybreak parameter: it appears that it
kicks in starting from 128 bytes by default??? 

...
static int copybreak __read_mostly = 128;
module_param(copybreak, int, 0);
MODULE_PARM_DESC(copybreak, "Receive copy threshold");
...

Anyway, I tried both copybreak settings of 0 and 1500:
there is significant slowdown when copybreak is set to
1500 with 256-byte traffic. Another clarification:
256-byte packets refer to entire Ethernet frame
including FCS, so when packets make into the driver
they become 252-byte long. I also tried to switch
driver to IRQ mode from MSI (SK98LIN is running is IRQ
mode) -- that did not have any significant effect on
forwarding performance.


Oprofile results:
================================================
profile for vmlinux 2.6.21.3 running with sk98lin
driver:

CPU: PIII, speed 2000.1 MHz (estimated)
Counted CPU_CLK_UNHALTED events (clocks processor is
not halted) with a unit mask of 0x00 (No unit mask)
count 100000
samples  %        symbol name
1626     14.3222  _raw_spin_trylock
935       8.2357  dev_hard_start_xmit
756       6.6590  sub_preempt_count
574       5.0559  __alloc_skb
507       4.4658  _raw_spin_unlock
462       4.0694  add_preempt_count
452       3.9813  dev_queue_xmit
432       3.8052  ip_output
416       3.6642  ip_rcv
406       3.5761  preempt_schedule
380       3.3471  netif_receive_skb
364       3.2062  __qdisc_run
283       2.4927  skb_release_data
274       2.4135  debug_smp_processor_id
265       2.3342  kfree
219       1.9290  kmem_cache_free
211       1.8585  __kmalloc
181       1.5943  ip_route_input
177       1.5591  pfifo_fast_dequeue
164       1.4446  ip_forward
150       1.3212  kmem_cache_alloc
141       1.2420  __kfree_skb
128       1.1275  ide_insw
121       1.0658  rt_hash_code
100       0.8808  pfifo_fast_requeue
96        0.8456  nf_iterate
94        0.8280  pfifo_fast_enqueue
91        0.8016  eth_type_trans
80        0.7047  nf_hook_slow
78        0.6870  cache_alloc_refill
72        0.6342  dev_kfree_skb_any
68        0.5990  local_bh_enable
58        0.5109  kfree_skb
58        0.5109  kfree_skbmem
52        0.4580  free_block
49        0.4316  selinux_ipv4_postroute_last
48        0.4228  delay_tsc
38        0.3347  page_fault
36        0.3171  kunmap_atomic
33        0.2907  memcpy
27        0.2378  __handle_mm_fault
27        0.2378  __netif_schedule
27        0.2378  cache_flusharray
26        0.2290  do_wp_page
25        0.2202  net_rx_action
21        0.1850  __d_lookup
16        0.1409  __copy_to_user_ll
16        0.1409  unmap_vmas
15        0.1321  default_idle
15        0.1321  kmap_atomic
14        0.1233  get_page_from_freelist
12        0.1057  __link_path_walk
12        0.1057  flush_tlb_mm
12        0.1057  strnlen_user
11        0.0969  avc_has_perm_noaudit
11        0.0969  do_page_fault
11        0.0969  sysenter_past_esp
10        0.0881  inode_has_perm
10        0.0881  net_tx_action
10        0.0881  selinux_inode_permission
9         0.0793  __might_sleep
9         0.0793  filemap_nopage
8         0.0705  cache_reap
8         0.0705  find_get_page
8         0.0705  find_vma
8         0.0705  local_bh_disable
7         0.0617  _atomic_dec_and_lock
6         0.0528  __copy_from_user_ll
6         0.0528  do_lookup
6         0.0528  do_timer
6         0.0528  free_hot_cold_page
6         0.0528  hrtimer_run_queues
6         0.0528  run_rebalance_domains
5         0.0440  apic_timer_interrupt
5         0.0440  error_code
5         0.0440  find_busiest_group
5         0.0440  task_rq_lock
4         0.0352  __do_softirq
4         0.0352  _spin_lock_irq
4         0.0352  copy_page_range
4         0.0352  do_mmap_pgoff
4         0.0352  do_softirq
4         0.0352  irq_entries_start
4         0.0352  put_page
4         0.0352  radix_tree_lookup
4         0.0352  raise_softirq
4         0.0352  restore_nocheck
4         0.0352  sched_clock
4         0.0352  schedule
3         0.0264  __pagevec_lru_add_active
3         0.0264  account_system_time
3         0.0264  apm_bios_call_simple
3         0.0264  avc_audit
3         0.0264  avc_has_perm
3         0.0264  do_IRQ
3         0.0264  drain_array
3         0.0264  getname
3         0.0264  handle_IRQ_event
3         0.0264  handle_fasteoi_irq
3         0.0264  mutex_lock
3         0.0264  page_remove_rmap
3         0.0264  prio_tree_insert
3         0.0264  run_timer_softirq
3         0.0264  serial_in
3         0.0264  set_cpus_allowed
3         0.0264  shrink_dcache_sb
3         0.0264  strncpy_from_user
2         0.0176  __wake_up_bit
2         0.0176  _raw_read_trylock
2         0.0176  _raw_read_unlock
2         0.0176  alloc_inode
2         0.0176  apm_cpu_idle
2         0.0176  clocksource_get_next
2         0.0176  common_interrupt
2         0.0176  copy_process
2         0.0176  do_sigaction
2         0.0176  dup_fd
2         0.0176  file_move
2         0.0176  flush_tlb_page
2         0.0176  free_pages_bulk
2         0.0176  mark_page_accessed
2         0.0176  mntput_no_expire
2         0.0176  raise_softirq_irqoff
2         0.0176  resume_userspace
2         0.0176  ret_from_intr
2         0.0176  serial_out
2         0.0176  softlockup_tick
2         0.0176  tick_handle_periodic
2         0.0176  unlink_file_vma
2         0.0176  up_read
2         0.0176  vfs_read
2         0.0176  vm_normal_page
1         0.0088  __add_entropy_words
1         0.0088  __alloc_pages
1         0.0088  __const_udelay
1         0.0088  __first_cpu
1         0.0088  __follow_mount
1         0.0088  __lookup_hash
1         0.0088  __mod_zone_page_state
1         0.0088  __next_cpu
1         0.0088  __pte_alloc
1         0.0088  __remove_shared_vm_struct
1         0.0088  __rmqueue
1         0.0088  __wake_up
1         0.0088  __wake_up_common
1         0.0088  ack_ioapic_quirk_irq
1         0.0088  anon_vma_link
1         0.0088  anon_vma_unlink
1         0.0088  arch_get_unmapped_area_topdown
1         0.0088  can_share_swap_page
1         0.0088  cfq_exit_cfqq
1         0.0088  cfq_queue_empty
1         0.0088  copy_mount_options
1         0.0088  copy_strings
1         0.0088  create_write_pipe
1         0.0088  current_kernel_time
1         0.0088  current_tick_length
1         0.0088  d_lookup
1         0.0088  do_filp_open
1         0.0088  do_munmap
1         0.0088  do_notify_parent
1         0.0088  do_notify_resume
1         0.0088  do_path_lookup
1         0.0088  down_read_trylock
1         0.0088  exec_keys
1         0.0088  find_vma_prev
1         0.0088  free_page_and_swap_cache
1         0.0088  free_pgd_range
1         0.0088  generic_file_aio_read
1         0.0088  get_task_mm
1         0.0088  get_unmapped_area
1         0.0088  get_write_access
1         0.0088  hrtimer_cancel
1         0.0088  ide_inb
1         0.0088  ide_outb
1         0.0088  inode_init_once
1         0.0088  internal_add_timer
1         0.0088  irq_enter
1         0.0088  kmem_cache_zalloc
1         0.0088  kprobe_flush_task
1         0.0088  lookup_mnt
1         0.0088  may_create
1         0.0088  memmove
1         0.0088  new_inode
1         0.0088  notifier_call_chain
1         0.0088  number
1         0.0088  open_namei
1         0.0088  pid_task
1         0.0088  pipe_write_fasync
1         0.0088  proc_delete_inode
1         0.0088  proc_flush_task
1         0.0088  proc_lookup
1         0.0088  profile_tick
1         0.0088  put_files_struct
1         0.0088  rb_insert_color
1         0.0088  rcu_process_callbacks
1         0.0088  recalc_task_prio
1         0.0088  resched_task
1         0.0088  resume_kernel
1         0.0088  selinux_bprm_alloc_security
1         0.0088  selinux_bprm_set_security
1         0.0088  selinux_file_permission
1         0.0088  selinux_inode_getattr
1         0.0088  shmem_get_inode
1         0.0088  shmem_mknod
1         0.0088  sigprocmask
1         0.0088  slab_destroy
1         0.0088  sock_attach_fd
1         0.0088  sync_dquots
1         0.0088  sys_mmap2
1         0.0088  sys_munmap
1         0.0088  sys_rt_sigprocmask
1         0.0088  tick_periodic
1         0.0088  vfs_create
1         0.0088  vma_merge
1         0.0088  write_chan
1         0.0088  zone_watermark_ok

==================================================
profile for vmlinux 2.6.21.3 running with sky2 driver:

CPU: PIII, speed 2000.22 MHz (estimated)
Counted CPU_CLK_UNHALTED events (clocks processor is
not halted) with a unit mask of 0x00 (No unit mask)
count 100000
samples  %        symbol name
7894      9.0213  __alloc_skb
6475      7.3997  skb_release_data
5706      6.5208  dev_hard_start_xmit
5656      6.4637  ip_output
5652      6.4591  eth_type_trans
5432      6.2077  ip_rcv
5278      6.0317  netif_receive_skb
3499      3.9987  kfree
3195      3.6513  _raw_spin_trylock
3003      3.4318  kmem_cache_free
2675      3.0570  debug_smp_processor_id
2669      3.0501  __kmalloc
2383      2.7233  sub_preempt_count
2348      2.6833  ip_route_input
2263      2.5862  ip_forward
2185      2.4970  add_preempt_count
2105      2.4056  dev_queue_xmit
1994      2.2788  kmem_cache_alloc
1587      1.8136  __kfree_skb
1479      1.6902  rt_hash_code
1409      1.6102  nf_iterate
1300      1.4856  pfifo_fast_enqueue
1262      1.4422  preempt_schedule
1084      1.2388  nf_hook_slow
986       1.1268  _raw_spin_unlock
939       1.0731  kfree_skb
935       1.0685  kfree_skbmem
926       1.0582  __qdisc_run
897       1.0251  local_bh_enable
792       0.9051  pfifo_fast_dequeue
503       0.5748  __netdev_alloc_skb
451       0.5154  selinux_ipv4_postroute_last
411       0.4697  dev_kfree_skb_any
298       0.3406  __copy_to_user_ll
269       0.3074  cache_alloc_refill
263       0.3006  free_block
174       0.1988  local_bh_disable
122       0.1394  cache_flusharray
82        0.0937  net_rx_action
75        0.0857  delay_tsc
65        0.0743  memcpy
48        0.0549  net_tx_action
41        0.0469  kunmap_atomic
39        0.0446  do_wp_page
28        0.0320  __link_path_walk
27        0.0309  __d_lookup
27        0.0309  page_fault
22        0.0251  __do_softirq
22        0.0251  get_page_from_freelist
20        0.0229  kmap_atomic
19        0.0217  __handle_mm_fault
15        0.0171  __netif_schedule
14        0.0160  avc_has_perm_noaudit
14        0.0160  find_vma
13        0.0149  hrtimer_run_queues
11        0.0126  flush_tlb_mm
10        0.0114  schedule
9         0.0103  inode_has_perm
8         0.0091  do_timer
8         0.0091  strnlen_user
7         0.0080  avc_has_perm
7         0.0080  do_page_fault
7         0.0080  run_timer_softirq
6         0.0069  __might_sleep
6         0.0069  apic_timer_interrupt
6         0.0069  default_idle
6         0.0069  filemap_nopage
6         0.0069  find_busiest_group
6         0.0069  find_get_page
6         0.0069  mod_zone_page_state
6         0.0069  profile_tick
6         0.0069  sched_clock
5         0.0057  __rmqueue
5         0.0057  _spin_lock_irq
5         0.0057  apm_bios_call_simple
5         0.0057  error_code
5         0.0057  raise_softirq_irqoff
5         0.0057  serial_out
5         0.0057  set_cpus_allowed
5         0.0057  softlockup_tick
5         0.0057  tick_periodic
5         0.0057  unmap_vmas
4         0.0046  __rcu_process_callbacks
4         0.0046  _atomic_dec_and_lock
4         0.0046  account_system_time
4         0.0046  cache_reap
4         0.0046  copy_process
4         0.0046  do_mmap_pgoff
4         0.0046  kmem_cache_zalloc
4         0.0046  memmove
4         0.0046  read_tsc
4         0.0046  scheduler_tick
4         0.0046  shrink_dcache_sb
4         0.0046  smp_apic_timer_interrupt
4         0.0046  strncpy_from_user
3         0.0034  _raw_read_unlock
3         0.0034  avc_audit
3         0.0034  clocksource_get_next
3         0.0034  dput
3         0.0034  file_has_perm
3         0.0034  inode_doinit_with_dentry
3         0.0034  inode_init_once
3         0.0034  put_page
3         0.0034  raise_softirq
3         0.0034  rb_insert_color
3         0.0034  restore_nocheck
3         0.0034  ret_from_intr
3         0.0034  run_posix_cpu_timers
3         0.0034  selinux_inode_permission
3         0.0034  serial_in
3         0.0034  vm_normal_page
2         0.0023  __follow_mount
2         0.0023  __mod_zone_page_state
2         0.0023  __switch_to
2         0.0023  __wake_up_bit
2         0.0023  anon_vma_prepare
2         0.0023  anon_vma_unlink
2         0.0023  atomic_notifier_call_chain
2         0.0023  copy_page_range
2         0.0023  drain_array
2         0.0023  dummy_file_mmap
2         0.0023  find_vma_prepare
2         0.0023  free_hot_cold_page
2         0.0023  irq_entries_start
2         0.0023  irq_exit
2         0.0023  msecs_to_jiffies
2         0.0023  neigh_lookup
2         0.0023  page_add_file_rmap
2         0.0023  radix_tree_lookup
2         0.0023  resume_userspace
2         0.0023  selinux_vm_enough_memory
2         0.0023  shmem_get_inode
1         0.0011  __alloc_pages
1         0.0011  __copy_from_user_ll
1         0.0011  __copy_user_intel
1         0.0011  __dec_zone_page_state
1         0.0011  __dentry_open
1         0.0011  __free_pages_ok
1         0.0011  __mutex_init
1         0.0011  __netif_rx_schedule
1         0.0011  __next_cpu
1         0.0011  __pagevec_lru_add_active
1         0.0011  __rcu_pending
1         0.0011  __wake_up_common
1         0.0011  _raw_read_trylock
1         0.0011  _read_lock_irq
1         0.0011  acpi_pm_read
1         0.0011  add_to_page_cache
1         0.0011  add_wait_queue
1         0.0011  alloc_pid
1         0.0011  anon_vma_link
1         0.0011  apm_bios_call
1         0.0011  apm_cpu_idle
1         0.0011  arch_get_unmapped_area_topdown
1         0.0011  blockable_page_cache_readahead
1         0.0011  cap_bprm_set_security
1         0.0011  cap_capable
1         0.0011  cdev_get
1         0.0011  clear_user
1         0.0011  copy_from_user
1         0.0011  copy_strings
1         0.0011  copy_to_user
1         0.0011  cp_new_stat64
1         0.0011  cpuset_exit
1         0.0011  current_tick_length
1         0.0011  d_alloc
1         0.0011  deny_write_access
1         0.0011  dequeue_task
1         0.0011  do_exit
1         0.0011  do_lookup
1         0.0011  do_path_lookup
1         0.0011  do_sigaction
1         0.0011  do_softirq
1         0.0011  do_wait
1         0.0011  dummy_inode_setattr
1         0.0011  dup_fd
1         0.0011  exit_itimers
1         0.0011  exit_mm
1         0.0011  ext3_follow_link
1         0.0011  ext3_release_file
1         0.0011  fib_semantic_match
1         0.0011  file_read_actor
1         0.0011  filp_close
1         0.0011  find_inode_fast
1         0.0011  find_next_bit
1         0.0011  find_pid
1         0.0011  find_vma_prev
1         0.0011  flush_thread
1         0.0011  flush_tlb_page
1         0.0011  fn_hash_lookup
1         0.0011  free_page_and_swap_cache
1         0.0011  free_pages
1         0.0011  half_md4_transform
1         0.0011  handle_edge_irq
1         0.0011  hrtimer_init
1         0.0011  hweight32
1         0.0011  idle_cpu
1         0.0011  insert_vm_struct
1         0.0011  iput
1         0.0011  irq_enter
1         0.0011  ksoftirqd
1         0.0011  lookup_create
1         0.0011  lookup_mnt
1         0.0011  lru_cache_add_active
1         0.0011  move_native_irq
1         0.0011  mutex_unlock
1         0.0011  open_exec
1         0.0011  page_remove_rmap
1         0.0011  permission
1         0.0011  pipe_poll
1         0.0011  pipe_read
1         0.0011  prepare_to_wait
1         0.0011  proc_lookup
1         0.0011  radix_tree_preload
1         0.0011  rb_erase
1         0.0011  read_chan
1         0.0011  release_pages
1         0.0011  remove_vma
1         0.0011  restore_sigcontext
1         0.0011  run_rebalance_domains
1         0.0011  rw_verify_area
1         0.0011  save_i387
1         0.0011  second_overflow
1         0.0011  security_compute_sid
1         0.0011  selinux_file_mmap
1         0.0011  selinux_sysctl
1         0.0011  send_signal
1         0.0011  seq_escape
1         0.0011  shmem_swp_alloc
1         0.0011  shmem_truncate
1         0.0011  show_vfsmnt
1         0.0011  sig_ignored
1         0.0011  slab_destroy
1         0.0011  snprintf
1         0.0011  sys_access
1         0.0011  sys_clone
1         0.0011  sys_close
1         0.0011  sys_faccessat
1         0.0011  sys_fcntl64
1         0.0011  sys_mkdirat
1         0.0011  sys_mprotect
1         0.0011  sys_rt_sigaction
1         0.0011  sysenter_past_esp
1         0.0011  task_rq_lock
1         0.0011  task_running_tick
1         0.0011  unix_stream_connect
1         0.0011  unlink_file_vma
1         0.0011  up_read
1         0.0011  vma_adjust
1         0.0011  vma_link
1         0.0011  vma_prio_tree_add
1         0.0011  worker_thread
1         0.0011  zone_watermark_ok

====================================================
profile for SK98LIN driver:

CPU: PIII, speed 2000.1 MHz (estimated)
Counted CPU_CLK_UNHALTED events (clocks processor is
not halted) with a unit mask of 0x00 (No unit mask)
count 100000
samples  %        image name               symbol name
2357     43.3910  sk98lin.ko               SkY2Poll
870      16.0162  sk98lin.ko              
GiveTxBufferToHw
811      14.9300  sk98lin.ko               SkY2Xmit
677      12.4632  sk98lin.ko              
FillReceiveTableYukon2
206       3.7923  sk98lin.ko               SkGmPhyRead
113       2.0803  sk98lin.ko               SkY2Isr
103       1.8962  sk98lin.ko              
SkCsGetReceiveInfo
80        1.4728  sk98lin.ko               SkMacIrq
70        1.2887  sk98lin.ko              
SkGmPhyWrite
53        0.9757  sk98lin.ko              
SkGmMacStatistic
30        0.5523  sk98lin.ko              
SkGmResetCounter
25        0.4602  sk98lin.ko              
CheckRXCounters
8         0.1473  sk98lin.ko              
SkY2FreeRxBuffers
5         0.0920  sk98lin.ko               SkHwtRead
4         0.0736  sk98lin.ko               SkGmInitMac
2         0.0368  sk98lin.ko              
SkEventDispatcher
2         0.0368  sk98lin.ko              
SkMacHashing
2         0.0368  sk98lin.ko              
SkMacRxTxDisable
2         0.0368  sk98lin.ko              
SkMacSoftRst
2         0.0368  sk98lin.ko              
SkYuk2SirqIsr
1         0.0184  sk98lin.ko              
DoInitRamQueue
1         0.0184  sk98lin.ko              
SkAddrGmacMcUpdate
1         0.0184  sk98lin.ko               SkDrvEvent
1         0.0184  sk98lin.ko              
SkGeCheckTimer
1         0.0184  sk98lin.ko              
SkGeInitMacFifo
1         0.0184  sk98lin.ko              
SkGeStopPort
1         0.0184  sk98lin.ko               SkTimerStop
1         0.0184  sk98lin.ko              
SkY2PortStop
1         0.0184  sk98lin.ko              
SkYuk2PortSirq
1         0.0184  sk98lin.ko               timer_done


=============================================
SKY2 profile:

CPU: PIII, speed 2000.22 MHz (estimated)
Counted CPU_CLK_UNHALTED events (clocks processor is
not halted) with a unit mask of 0x00 (No unit mask)
count 100000
samples  %        image name               symbol name
69576    64.4634  sky2.ko                 
sky2_xmit_frame
27759    25.7192  sky2.ko                  sky2_poll
5782      5.3571  sky2.ko                 
sky2_rx_unmap_skb
1310      1.2137  sky2.ko                 
sky2_tx_complete
1276      1.1822  sky2.ko                  sky2_rx_add
1018      0.9432  sky2.ko                 
sky2_rx_submit
687       0.6365  sky2.ko                 
sky2_rx_map_skb
521       0.4827  sky2.ko                  .text
2         0.0019  sky2.ko                  sky2_intr







       
____________________________________________________________________________________
Get the free Yahoo! toolbar and rest assured with the added security of spyware protection.
http://new.toolbar.yahoo.com/toolbar/features/norton/index.php
