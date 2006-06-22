From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: [0/5] GSO: Generic Segmentation Offload
Date: Thu, 22 Jun 2006 18:12:11 +1000
Message-ID: <20060622081211.GA22505@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="r5Pyd7+fXNt84Ff3"
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhun.apana.org.au ([64.62.148.172]:10500 "EHLO
	arnor.apana.org.au") by vger.kernel.org with ESMTP id S932524AbWFVIMO
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 22 Jun 2006 04:12:14 -0400
To: "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


--r5Pyd7+fXNt84Ff3
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline

Hi:

This is a repost of the GSO patches.  The main change is the fix to a bug
in the way dev->gso_skb is freed.  This series requires the dev_deactivate
patch that I just posted.

Here is the original description:

This series adds Generic Segmentation Offload (GSO) support to the Linux
networking stack.

Many people have observed that a lot of the savings in TSO come from
traversing the networking stack once rather than many times for each
super-packet.  These savings can be obtained without hardware support.
In fact, the concept can be applied to other protocols such as TCPv6,
UDP, or even DCCP.

The key to minimising the cost in implementing this is to postpone the
segmentation as late as possible.  In the ideal world, the segmentation
would occur inside each NIC driver where they would rip the super-packet
apart and either produce SG lists which are directly fed to the hardware,
or linearise each segment into pre-allocated memory to be fed to the NIC.
This would elminate segmented skb's altogether.

Unfortunately this requires modifying each and every NIC driver so it
would take quite some time.  A much easier solution is to perform the
segmentation just before the entry into the driver's xmit routine.  This
series of patches does this.

I've attached some numbers to demonstrate the savings brought on by
doing this.  The best scenario is obviously the case where the underlying
NIC supports SG.  This means that we simply have to manipulate the SG
entries and place them into individual skb's before passing them to the
driver.  The attached file lo-res shows this.

The test was performed through the loopback device which is a fairly good
approxmiation of an SG-capable NIC.

GSO like TSO is only effective if the MTU is significantly less than the
maximum value of 64K.  So only the case where the MTU was set to 1500 is
of interest.  There we can see that the throughput improved by 17.5%
(3061.05Mb/s => 3598.17Mb/s).  The actual saving in transmission cost is
in fact a lot more than that as the majority of the time here is spent on
the RX side which still has to deal with 1500-byte packets.

The worst-case scenario is where the NIC does not support SG and the user
uses write(2) which means that we have to copy the data twice.  The files
gso-off/gso-on provide data for this case (the test was carried out on
e100).  As you can see, the cost of the extra copy is mostly offset by the
reduction in the cost of going through the networking stack.

For now GSO is off by default but can be enabled through ethtool.  It is
conceivable that with enough optimisation GSO could be a win in most cases
and we could enable it by default.

However, even without enabling GSO explicitly it can still function on
bridged and forwarded packets.  As it is, passing TSO packets through a
bridge only works if all constiuents support TSO.  With GSO, it provides
a fallback so that we may enable TSO for a bridge even if some of its
constituents do not support TSO.

This provides massive savings for Xen as it uses a bridge-based architecture
and TSO/GSO produces a much larger effective MTU for internal traffic between
domains.

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt

--r5Pyd7+fXNt84Ff3
Content-Type: text/plain; charset=us-ascii
Content-Disposition: attachment; filename=lo-res

$ sudo ./ethtool -K lo gso on
$ sudo ifconfig lo mtu 1500
$ netperf -t TCP_STREAM
TCP STREAM TEST to localhost
Recv   Send    Send
Socket Socket  Message  Elapsed
Size   Size    Size     Time     Throughput
bytes  bytes   bytes    secs.    10^6bits/sec

 87380  16384  16384    10.00    3598.17
$ sudo ./ethtool -K lo gso off
$ netperf -t TCP_STREAM
TCP STREAM TEST to localhost
Recv   Send    Send
Socket Socket  Message  Elapsed
Size   Size    Size     Time     Throughput
bytes  bytes   bytes    secs.    10^6bits/sec

 87380  16384  16384    10.00    3061.05
$ sudo ifconfig lo mtu 60000
$ netperf -t TCP_STREAM
TCP STREAM TEST to localhost
Recv   Send    Send
Socket Socket  Message  Elapsed
Size   Size    Size     Time     Throughput
bytes  bytes   bytes    secs.    10^6bits/sec

 87380  16384  16384    10.00    8245.05
$ sudo ./ethtool -K lo gso on
$ netperf -t TCP_STREAM
TCP STREAM TEST to localhost
Recv   Send    Send
Socket Socket  Message  Elapsed
Size   Size    Size     Time     Throughput
bytes  bytes   bytes    secs.    10^6bits/sec

 87380  16384  16384    10.00    8563.36
$ sudo ifconfig lo mtu 16436
$ netperf -t TCP_STREAM
TCP STREAM TEST to localhost
Recv   Send    Send
Socket Socket  Message  Elapsed
Size   Size    Size     Time     Throughput
bytes  bytes   bytes    secs.    10^6bits/sec

 87380  16384  16384    10.00    7359.95
$ sudo ./ethtool -K lo gso off
$ netperf -t TCP_STREAM
TCP STREAM TEST to localhost
Recv   Send    Send
Socket Socket  Message  Elapsed
Size   Size    Size     Time     Throughput
bytes  bytes   bytes    secs.    10^6bits/sec

 87380  16384  16384    10.00    7535.04
$

--r5Pyd7+fXNt84Ff3
Content-Type: text/plain; charset=us-ascii
Content-Disposition: attachment; filename=gso-off

CPU: PIII, speed 1200 MHz (estimated)
Counted CPU_CLK_UNHALTED events (clocks processor is not halted) with a unit mask of 0x00 (No unit mask) count 100000
samples  %        symbol name
1247     21.7551  csum_partial_copy_generic
294       5.1291  prep_new_page
240       4.1870  __alloc_skb
120       2.0935  tcp_sendmsg
113       1.9714  get_offset_pmtmr
113       1.9714  kfree
103       1.7969  skb_release_data
103       1.7969  timer_interrupt
101       1.7620  ip_queue_xmit
96        1.6748  skb_clone
94        1.6399  __kmalloc
94        1.6399  net_rx_action
86        1.5003  tcp_transmit_skb
80        1.3957  kmem_cache_free
76        1.3259  tcp_clean_rtx_queue
67        1.1689  ip_output
66        1.1514  mark_offset_pmtmr
65        1.1340  tcp_v4_rcv
64        1.1165  local_bh_enable
62        1.0816  kmem_cache_alloc
59        1.0293  irq_entries_start
59        1.0293  page_fault
57        0.9944  tcp_push_one
52        0.9072  kfree_skbmem
47        0.8200  __qdisc_run
47        0.8200  csum_partial
47        0.8200  netif_receive_skb
46        0.8025  __kfree_skb
46        0.8025  tcp_init_tso_segs
44        0.7676  __copy_to_user_ll
44        0.7676  dev_queue_xmit
39        0.6804  pfifo_fast_enqueue
39        0.6804  system_call
37        0.6455  __copy_from_user_ll
37        0.6455  ip_rcv
36        0.6281  __tcp_select_window
33        0.5757  sock_wfree
31        0.5408  __do_softirq
31        0.5408  tcp_v4_send_check
30        0.5234  eth_header
28        0.4885  tcp_rcv_established
27        0.4710  restore_nocheck
26        0.4536  pfifo_fast_dequeue
25        0.4361  __do_IRQ
25        0.4361  do_softirq
25        0.4361  tcp_build_and_update_options
25        0.4361  tcp_snd_test
23        0.4013  cache_alloc_refill
23        0.4013  handle_IRQ_event
23        0.4013  tcp_ack
22        0.3838  free_block
22        0.3838  ip_route_input
21        0.3664  __netif_rx_schedule
21        0.3664  schedule
20        0.3489  do_wp_page
20        0.3489  neigh_resolve_output
19        0.3315  do_IRQ
19        0.3315  do_page_fault
19        0.3315  do_select
19        0.3315  fget_light
19        0.3315  ip_local_deliver
18        0.3140  __tcp_push_pending_frames
18        0.3140  end_level_ioapic_irq
17        0.2966  cpu_idle
17        0.2966  delay_pmtmr
17        0.2966  tcp_select_window
16        0.2791  add_wait_queue
16        0.2791  rt_hash_code
16        0.2791  tcp_set_skb_tso_segs
15        0.2617  find_vma
15        0.2617  irq_exit
15        0.2617  update_send_head
14        0.2442  __switch_to
13        0.2268  __skb_checksum_complete
13        0.2268  common_interrupt
13        0.2268  dev_kfree_skb_any
13        0.2268  tcp_event_data_sent
13        0.2268  zap_pte_range
12        0.2094  __d_lookup
12        0.2094  __page_set_anon_rmap
12        0.2094  mod_timer
12        0.2094  ret_from_intr
12        0.2094  sock_poll
12        0.2094  tcp_current_mss
12        0.2094  tcp_write_xmit
11        0.1919  do_no_page
11        0.1919  error_code
11        0.1919  free_hot_cold_page
11        0.1919  i8042_interrupt
10        0.1745  __link_path_walk
10        0.1745  buffered_rmqueue
10        0.1745  sk_reset_timer
9         0.1570  __rmqueue
9         0.1570  dev_hard_start_xmit
9         0.1570  free_pages_bulk
9         0.1570  resume_kernel
9         0.1570  skb_checksum
9         0.1570  tcp_cong_avoid
9         0.1570  tcp_rtt_estimator
8         0.1396  do_anonymous_page
8         0.1396  eth_type_trans
8         0.1396  get_page_from_freelist
8         0.1396  tcp_ack_saw_tstamp
8         0.1396  tcp_v4_checksum_init
7         0.1221  __wake_up
7         0.1221  atomic_notifier_call_chain
7         0.1221  normal_poll
7         0.1221  sk_stream_write_space
7         0.1221  tcp_ack_packets_out
7         0.1221  tcp_check_space
7         0.1221  tcp_cwnd_validate
7         0.1221  tcp_reno_cong_avoid
6         0.1047  __pagevec_lru_add_active
6         0.1047  copy_from_user
6         0.1047  hrtimer_get_softirq_time
6         0.1047  lock_sock
6         0.1047  lookup_bh_lru
6         0.1047  net_tx_action
6         0.1047  remove_wait_queue
6         0.1047  tcp_new_space
6         0.1047  unmap_vmas
5         0.0872  __copy_user_intel
5         0.0872  __handle_mm_fault
5         0.0872  __page_cache_release
5         0.0872  core_sys_select
5         0.0872  del_timer
5         0.0872  dnotify_parent
5         0.0872  filemap_nopage
5         0.0872  find_get_page
5         0.0872  kfree_skb
5         0.0872  lru_cache_add_active
5         0.0872  max_select_fd
5         0.0872  mod_page_state_offset
5         0.0872  note_interrupt
5         0.0872  pipe_poll
5         0.0872  prepare_to_wait
5         0.0872  restore_all
5         0.0872  scheduler_tick
5         0.0872  slab_put_obj
5         0.0872  syscall_exit
5         0.0872  try_to_wake_up
5         0.0872  zone_watermark_ok
4         0.0698  __sk_dst_check
4         0.0698  copy_to_user
4         0.0698  do_poll
4         0.0698  do_pollfd
4         0.0698  fput
4         0.0698  inotify_dentry_parent_queue_event
4         0.0698  inotify_inode_queue_event
4         0.0698  memcpy
4         0.0698  sk_stream_wait_memory
4         0.0698  slab_get_obj
4         0.0698  sock_sendmsg
4         0.0698  strncpy_from_user
4         0.0698  strnlen_user
4         0.0698  tcp_should_expand_sndbuf
4         0.0698  tty_poll
3         0.0523  __alloc_pages
3         0.0523  __copy_user_zeroing_intel
3         0.0523  __d_path
3         0.0523  __find_get_block
3         0.0523  __follow_mount
3         0.0523  __netif_schedule
3         0.0523  __wake_up_bit
3         0.0523  __wake_up_common
3         0.0523  _atomic_dec_and_lock
3         0.0523  activate_task
3         0.0523  anon_vma_prepare
3         0.0523  bh_lru_install
3         0.0523  cond_resched
3         0.0523  do_lookup
3         0.0523  do_path_lookup
3         0.0523  do_readv_writev
3         0.0523  dup_fd
3         0.0523  effective_prio
3         0.0523  hrtimer_run_queues
3         0.0523  ing_filter
3         0.0523  link_path_walk
3         0.0523  notifier_call_chain
3         0.0523  preempt_schedule
3         0.0523  radix_tree_lookup
3         0.0523  release_pages
3         0.0523  run_timer_softirq
3         0.0523  run_workqueue
3         0.0523  sys_sendto
3         0.0523  sys_writev
3         0.0523  tty_ldisc_deref
3         0.0523  unmap_page_range
3         0.0523  vm_normal_page
2         0.0349  __brelse
2         0.0349  __find_get_block_slow
2         0.0349  __getblk
2         0.0349  __mod_page_state_offset
2         0.0349  __mod_timer
2         0.0349  acct_update_integrals
2         0.0349  adjtime_adjustment
2         0.0349  alloc_sock_iocb
2         0.0349  apic_timer_interrupt
2         0.0349  bit_waitqueue
2         0.0349  cache_flusharray
2         0.0349  cache_reap
2         0.0349  d_alloc
2         0.0349  dput
2         0.0349  fget
2         0.0349  finish_wait
2         0.0349  init_timer
2         0.0349  lock_timer_base
2         0.0349  opost_block
2         0.0349  page_remove_rmap
2         0.0349  permission
2         0.0349  poll_get_entry
2         0.0349  poll_initwait
2         0.0349  profile_munmap
2         0.0349  pty_chars_in_buffer
2         0.0349  put_page
2         0.0349  raise_softirq
2         0.0349  recalc_task_prio
2         0.0349  resume_userspace
2         0.0349  ret_from_exception
2         0.0349  rmqueue_bulk
2         0.0349  rw_verify_area
2         0.0349  sched_clock
2         0.0349  setup_frame
2         0.0349  skb_queue_head
2         0.0349  sock_aio_read
2         0.0349  sock_def_readable
2         0.0349  sys_ioctl
2         0.0349  sys_read
2         0.0349  task_curr
2         0.0349  task_timeslice
2         0.0349  tty_ldisc_try
2         0.0349  vfs_read
2         0.0349  vma_adjust
2         0.0349  vma_link
1         0.0174  __block_write_full_page
1         0.0174  __dentry_open
1         0.0174  __dequeue_signal
1         0.0174  __do_page_cache_readahead
1         0.0174  __fput
1         0.0174  __generic_file_aio_read
1         0.0174  __group_complete_signal
1         0.0174  __ip_route_output_key
1         0.0174  __lookup_mnt
1         0.0174  __mark_inode_dirty
1         0.0174  __pollwait
1         0.0174  __put_task_struct
1         0.0174  __put_user_4
1         0.0174  __queue_work
1         0.0174  __rcu_pending
1         0.0174  __sigqueue_alloc
1         0.0174  __vma_link_rb
1         0.0174  alloc_inode
1         0.0174  alloc_slabmgmt
1         0.0174  arch_unmap_area_topdown
1         0.0174  as_add_request
1         0.0174  as_fifo_expired
1         0.0174  as_find_next_arq
1         0.0174  autoremove_wake_function
1         0.0174  bio_init
1         0.0174  block_read_full_page
1         0.0174  cached_lookup
1         0.0174  can_vma_merge_before
1         0.0174  con_chars_in_buffer
1         0.0174  convert_fxsr_from_user
1         0.0174  copy_from_read_buf
1         0.0174  copy_pte_range
1         0.0174  cp_new_stat64
1         0.0174  d_splice_alias
1         0.0174  do_exit
1         0.0174  do_filp_open
1         0.0174  do_fork
1         0.0174  do_getname
1         0.0174  do_gettimeofday
1         0.0174  do_mpage_readpage
1         0.0174  do_sigaction
1         0.0174  do_sock_read
1         0.0174  do_sock_write
1         0.0174  do_sync_write
1         0.0174  do_timer
1         0.0174  drain_array
1         0.0174  dummy_inode_permission
1         0.0174  dup_mm
1         0.0174  dup_task_struct
1         0.0174  elv_queue_empty
1         0.0174  enqueue_hrtimer
1         0.0174  enqueue_task
1         0.0174  exit_mmap
1         0.0174  file_ra_state_init
1         0.0174  filesystems_read_proc
1         0.0174  find_vma_prev
1         0.0174  free_poll_entry
1         0.0174  generic_permission
1         0.0174  get_index
1         0.0174  get_signal_to_deliver
1         0.0174  get_vmalloc_info
1         0.0174  getname
1         0.0174  handle_signal
1         0.0174  hrtimer_try_to_cancel
1         0.0174  inet_csk_init_xmit_timers
1         0.0174  init_buffer_head
1         0.0174  inode_change_ok
1         0.0174  inode_init_once
1         0.0174  kbd_bh
1         0.0174  kmem_cache_zalloc
1         0.0174  kmem_getpages
1         0.0174  load_elf_binary
1         0.0174  locks_remove_posix
1         0.0174  memmove
1         0.0174  mempool_free
1         0.0174  mmput
1         0.0174  mutex_lock
1         0.0174  netlink_insert
1         0.0174  no_singlestep
1         0.0174  nr_blockdev_pages
1         0.0174  number
1         0.0174  open_namei
1         0.0174  page_add_new_anon_rmap
1         0.0174  path_release
1         0.0174  pipe_release
1         0.0174  poke_blanked_console
1         0.0174  proc_pid_readlink
1         0.0174  pty_unthrottle
1         0.0174  put_filp
1         0.0174  radix_tree_insert
1         0.0174  raise_softirq_irqoff
1         0.0174  rb_insert_color
1         0.0174  rcu_do_batch
1         0.0174  rcu_pending
1         0.0174  release_sock
1         0.0174  remove_vma
1         0.0174  restore_sigcontext
1         0.0174  search_binary_handler
1         0.0174  sk_wait_data
1         0.0174  skb_dequeue
1         0.0174  skb_queue_tail
1         0.0174  sock_aio_write
1         0.0174  sock_alloc_send_pskb
1         0.0174  sock_def_write_space
1         0.0174  sock_from_file
1         0.0174  sock_ioctl
1         0.0174  submit_bio
1         0.0174  sys_fcntl64
1         0.0174  sys_fstat64
1         0.0174  sys_rt_sigaction
1         0.0174  sys_rt_sigprocmask
1         0.0174  sys_send
1         0.0174  sys_sigreturn
1         0.0174  sys_socketcall
1         0.0174  sys_waitpid
1         0.0174  tcp_close
1         0.0174  tcp_data_queue
1         0.0174  tcp_fastretrans_alert
1         0.0174  tcp_grow_window
1         0.0174  tcp_mtu_probe
1         0.0174  tcp_v4_do_rcv
1         0.0174  tty_hung_up_p
1         0.0174  tty_insert_flip_string_flags
1         0.0174  tty_paranoia_check
1         0.0174  tty_wakeup
1         0.0174  tty_write
1         0.0174  unlock_buffer
1         0.0174  unmap_region
1         0.0174  update_process_times
1         0.0174  update_wall_time
1         0.0174  update_wall_time_one_tick
1         0.0174  vfs_ioctl
1         0.0174  vfs_permission
1         0.0174  vma_prio_tree_add
1         0.0174  wait_task_zombie

--r5Pyd7+fXNt84Ff3
Content-Type: text/plain; charset=us-ascii
Content-Disposition: attachment; filename=gso-on

CPU: PIII, speed 1200 MHz (estimated)
Counted CPU_CLK_UNHALTED events (clocks processor is not halted) with a unit mask of 0x00 (No unit mask) count 100000
samples  %        symbol name
1255     21.6865  csum_partial_copy_generic
398       6.8775  __copy_from_user_ll
343       5.9271  __alloc_skb
254       4.3891  prep_new_page
243       4.1991  skb_segment
110       1.9008  __kmalloc
106       1.8317  kfree
106       1.8317  timer_interrupt
105       1.8144  skb_copy_and_csum_bits
94        1.6243  net_rx_action
77        1.3306  kmem_cache_free
75        1.2960  tcp_v4_rcv
72        1.2442  kmem_cache_alloc
63        1.0886  page_fault
55        0.9504  mark_offset_pmtmr
54        0.9331  __kfree_skb
52        0.8986  skb_release_data
51        0.8813  csum_partial
50        0.8640  do_softirq
50        0.8640  inet_gso_segment
47        0.8122  get_offset_pmtmr
47        0.8122  irq_entries_start
45        0.7776  netif_receive_skb
43        0.7430  tcp_current_mss
41        0.7085  free_hot_cold_page
40        0.6912  tcp_clean_rtx_queue
36        0.6221  kfree_skbmem
35        0.6048  tcp_sendmsg
35        0.6048  tcp_write_xmit
34        0.5875  __do_softirq
31        0.5357  __do_IRQ
31        0.5357  ip_rcv
31        0.5357  tcp_rcv_established
30        0.5184  __pskb_trim_head
29        0.5011  system_call
28        0.4838  tcp_ack
28        0.4838  tcp_tso_segment
28        0.4838  tcp_tso_should_defer
27        0.4666  __copy_to_user_ll
26        0.4493  restore_nocheck
26        0.4493  rt_hash_code
25        0.4320  do_wp_page
24        0.4147  handle_IRQ_event
24        0.4147  schedule
23        0.3974  do_select
23        0.3974  tcp_tso_acked
22        0.3802  ip_local_deliver
22        0.3802  ip_route_input
21        0.3629  buffered_rmqueue
21        0.3629  free_block
20        0.3456  end_level_ioapic_irq
20        0.3456  tcp_init_tso_segs
19        0.3283  __netif_rx_schedule
19        0.3283  cache_alloc_refill
19        0.3283  dev_kfree_skb_any
18        0.3110  skb_split
17        0.2938  ret_from_intr
17        0.2938  tcp_mark_head_lost
16        0.2765  common_interrupt
16        0.2765  do_page_fault
16        0.2765  get_page_from_freelist
16        0.2765  slab_put_obj
15        0.2592  do_IRQ
15        0.2592  sock_poll
15        0.2592  zap_pte_range
14        0.2419  irq_exit
14        0.2419  tcp_trim_head
14        0.2419  tcp_v4_checksum_init
13        0.2246  __link_path_walk
13        0.2246  add_wait_queue
13        0.2246  delay_pmtmr
13        0.2246  tcp_rtt_estimator
12        0.2074  __skb_checksum_complete
12        0.2074  cpu_idle
12        0.2074  fget_light
12        0.2074  find_vma
12        0.2074  skb_checksum
12        0.2074  tcp_new_space
11        0.1901  copy_from_user
11        0.1901  put_page
11        0.1901  tcp_set_skb_tso_segs
10        0.1728  __d_lookup
10        0.1728  __switch_to
10        0.1728  error_code
10        0.1728  eth_type_trans
10        0.1728  i8042_interrupt
10        0.1728  skb_copy_bits
10        0.1728  tcp_transmit_skb
9         0.1555  dev_hard_start_xmit
9         0.1555  mod_page_state_offset
9         0.1555  strnlen_user
8         0.1382  __page_set_anon_rmap
8         0.1382  do_no_page
8         0.1382  ip_output
8         0.1382  resume_kernel
8         0.1382  skb_clone
8         0.1382  tcp_check_space
8         0.1382  tcp_xmit_retransmit_queue
7         0.1210  __mod_timer
7         0.1210  __tcp_push_pending_frames
7         0.1210  __tcp_select_window
7         0.1210  ip_queue_xmit
7         0.1210  mod_timer
7         0.1210  pipe_poll
7         0.1210  remove_wait_queue
7         0.1210  zone_watermark_ok
6         0.1037  __pagevec_lru_add_active
6         0.1037  core_sys_select
6         0.1037  do_pollfd
6         0.1037  find_get_page
6         0.1037  note_interrupt
6         0.1037  sk_stream_write_space
6         0.1037  skb_gso_segment
6         0.1037  sys_read
6         0.1037  tcp_ack_packets_out
6         0.1037  tcp_cong_avoid
6         0.1037  tcp_reno_cong_avoid
5         0.0864  __rmqueue
5         0.0864  __wake_up
5         0.0864  __wake_up_common
5         0.0864  dev_queue_xmit
5         0.0864  eth_header
5         0.0864  filemap_nopage
5         0.0864  fput
5         0.0864  free_pages_bulk
5         0.0864  internal_add_timer
5         0.0864  local_bh_enable
5         0.0864  lookup_bh_lru
5         0.0864  sys_socketcall
5         0.0864  syscall_exit
5         0.0864  tcp_mtu_probe
5         0.0864  tcp_v4_do_rcv
4         0.0691  __copy_user_intel
4         0.0691  __handle_mm_fault
4         0.0691  __mod_page_state_offset
4         0.0691  __page_cache_release
4         0.0691  __pollwait
4         0.0691  __qdisc_run
4         0.0691  adjtime_adjustment
4         0.0691  apic_timer_interrupt
4         0.0691  cond_resched
4         0.0691  hrtimer_run_queues
4         0.0691  kfree_skb
4         0.0691  lock_timer_base
4         0.0691  normal_poll
4         0.0691  opost_block
4         0.0691  pfifo_fast_enqueue
4         0.0691  preempt_schedule
4         0.0691  pskb_expand_head
4         0.0691  radix_tree_lookup
4         0.0691  resume_userspace
4         0.0691  sk_reset_timer
4         0.0691  skb_dequeue
4         0.0691  sys_send
4         0.0691  tcp_sacktag_write_queue
4         0.0691  tty_ldisc_try
4         0.0691  vfs_permission
3         0.0518  __alloc_pages
3         0.0518  __find_get_block
3         0.0518  __sk_dst_check
3         0.0518  anon_vma_prepare
3         0.0518  do_mmap_pgoff
3         0.0518  do_readv_writev
3         0.0518  do_sock_read
3         0.0518  dup_mm
3         0.0518  generic_permission
3         0.0518  hrtimer_get_softirq_time
3         0.0518  ing_filter
3         0.0518  lru_cache_add_active
3         0.0518  page_add_new_anon_rmap
3         0.0518  permission
3         0.0518  pfifo_fast_dequeue
3         0.0518  pty_chars_in_buffer
3         0.0518  raise_softirq
3         0.0518  rb_insert_color
3         0.0518  release_pages
3         0.0518  restore_all
3         0.0518  run_timer_softirq
3         0.0518  rw_verify_area
3         0.0518  slab_get_obj
3         0.0518  sock_wfree
3         0.0518  tcp_ack_saw_tstamp
3         0.0518  tcp_build_and_update_options
3         0.0518  tcp_event_data_sent
3         0.0518  tcp_should_expand_sndbuf
3         0.0518  tcp_v4_send_check
3         0.0518  tso_fragment
3         0.0518  unmap_vmas
3         0.0518  update_wall_time
3         0.0518  vsnprintf
2         0.0346  __rcu_pending
2         0.0346  _atomic_dec_and_lock
2         0.0346  account_system_time
2         0.0346  acct_update_integrals
2         0.0346  blk_recount_segments
2         0.0346  cache_flusharray
2         0.0346  cleanup_timers
2         0.0346  copy_pte_range
2         0.0346  cp_new_stat64
2         0.0346  current_fs_time
2         0.0346  d_instantiate
2         0.0346  default_wake_function
2         0.0346  dequeue_task
2         0.0346  dnotify_parent
2         0.0346  do_anonymous_page
2         0.0346  do_gettimeofday
2         0.0346  do_path_lookup
2         0.0346  do_setitimer
2         0.0346  do_sys_poll
2         0.0346  drain_array
2         0.0346  effective_prio
2         0.0346  find_next_zero_bit
2         0.0346  inode_init_once
2         0.0346  input_event
2         0.0346  max_select_fd
2         0.0346  memcpy
2         0.0346  memmove
2         0.0346  need_resched
2         0.0346  neigh_resolve_output
2         0.0346  no_singlestep
2         0.0346  notifier_call_chain
2         0.0346  page_remove_rmap
2         0.0346  poll_freewait
2         0.0346  prepare_to_wait
2         0.0346  recalc_task_prio
2         0.0346  rmqueue_bulk
2         0.0346  schedule_timeout
2         0.0346  scheduler_tick
2         0.0346  skb_queue_tail
2         0.0346  sock_aio_read
2         0.0346  sock_aio_write
2         0.0346  sock_from_file
2         0.0346  sock_sendmsg
2         0.0346  strncpy_from_user
2         0.0346  sys_gettimeofday
2         0.0346  sys_sendto
2         0.0346  tcp_cwnd_down
2         0.0346  tcp_data_queue
2         0.0346  tcp_fastretrans_alert
2         0.0346  tcp_parse_options
2         0.0346  tcp_push_one
2         0.0346  tcp_select_window
2         0.0346  tcp_snd_test
2         0.0346  transfer_objects
2         0.0346  try_to_wake_up
2         0.0346  tty_write
2         0.0346  unmap_page_range
2         0.0346  vfs_ioctl
2         0.0346  vma_adjust
1         0.0173  __bread
1         0.0173  __brelse
1         0.0173  __dentry_open
1         0.0173  __dequeue_signal
1         0.0173  __exit_signal
1         0.0173  __find_get_block_slow
1         0.0173  __group_complete_signal
1         0.0173  __insert_inode_hash
1         0.0173  __lookup_mnt
1         0.0173  __netif_schedule
1         0.0173  __pskb_pull_tail
1         0.0173  __pte_alloc
1         0.0173  __tasklet_schedule
1         0.0173  __wake_up_bit
1         0.0173  acct_process
1         0.0173  ack_edge_ioapic_irq
1         0.0173  acquire_console_sem
1         0.0173  activate_task
1         0.0173  alarm_setitimer
1         0.0173  alloc_new_pmd
1         0.0173  as_dispatch_request
1         0.0173  as_merged_request
1         0.0173  autoremove_wake_function
1         0.0173  bh_lru_install
1         0.0173  bit_waitqueue
1         0.0173  block_read_full_page
1         0.0173  cache_reap
1         0.0173  check_itimerval
1         0.0173  clear_user
1         0.0173  con_chars_in_buffer
1         0.0173  convert_fxsr_to_user
1         0.0173  copy_semundo
1         0.0173  copy_strings
1         0.0173  copy_to_user
1         0.0173  d_rehash
1         0.0173  deactivate_task
1         0.0173  dev_gso_segment
1         0.0173  do_fcntl
1         0.0173  do_generic_mapping_read
1         0.0173  do_lookup
1         0.0173  do_poll
1         0.0173  do_sigaction
1         0.0173  do_sync_read
1         0.0173  do_sys_open
1         0.0173  dummy_vm_enough_memory
1         0.0173  dup_fd
1         0.0173  enqueue_task
1         0.0173  exec_permission_lite
1         0.0173  file_ra_state_init
1         0.0173  file_update_time
1         0.0173  filp_close
1         0.0173  find_task_by_pid_type
1         0.0173  finish_wait
1         0.0173  flush_old_exec
1         0.0173  free_one_page
1         0.0173  free_page_and_swap_cache
1         0.0173  free_poll_entry
1         0.0173  free_uid
1         0.0173  get_empty_filp
1         0.0173  get_index
1         0.0173  get_signal_to_deliver
1         0.0173  get_task_mm
1         0.0173  get_vmalloc_info
1         0.0173  getname
1         0.0173  group_send_sig_info
1         0.0173  groups_search
1         0.0173  handle_signal
1         0.0173  hrtimer_try_to_cancel
1         0.0173  inode_setattr
1         0.0173  inode_sub_bytes
1         0.0173  inotify_dentry_parent_queue_event
1         0.0173  inotify_inode_queue_event
1         0.0173  kbd_keycode
1         0.0173  kmem_cache_zalloc
1         0.0173  kthread_should_stop
1         0.0173  locks_remove_flock
1         0.0173  lookup_create
1         0.0173  make_ahead_window
1         0.0173  mark_page_accessed
1         0.0173  math_state_restore
1         0.0173  may_expand_vm
1         0.0173  n_tty_receive_buf
1         0.0173  nameidata_to_filp
1         0.0173  opost
1         0.0173  page_waitqueue
1         0.0173  prio_tree_remove
1         0.0173  proc_file_read
1         0.0173  profile_munmap
1         0.0173  profile_tick
1         0.0173  put_io_context
1         0.0173  rb_next
1         0.0173  rcu_do_batch
1         0.0173  rcu_pending
1         0.0173  recalc_sigpending_tsk
1         0.0173  run_local_timers
1         0.0173  run_posix_cpu_timers
1         0.0173  save_i387
1         0.0173  sched_clock
1         0.0173  setup_frame
1         0.0173  signal_wake_up
1         0.0173  sk_stream_wait_memory
1         0.0173  skb_checksum_help
1         0.0173  slab_destroy
1         0.0173  smp_send_timer_broadcast_ipi
1         0.0173  sock_def_readable
1         0.0173  sock_ioctl
1         0.0173  sys_getpid
1         0.0173  sys_munmap
1         0.0173  syscall_call
1         0.0173  tcp_ack_update_window
1         0.0173  tcp_check_sack_reneging
1         0.0173  tcp_fast_parse_options
1         0.0173  tcp_fragment
1         0.0173  tcp_mtu_to_mss
1         0.0173  tcp_window_allows
1         0.0173  timespec_trunc
1         0.0173  tty_hung_up_p
1         0.0173  tty_ldisc_deref
1         0.0173  tty_poll
1         0.0173  unlink_file_vma
1         0.0173  vfs_getattr
1         0.0173  vfs_read
1         0.0173  vfs_write
1         0.0173  vm_normal_page
1         0.0173  vm_stat_account
1         0.0173  vma_prio_tree_add
1         0.0173  zone_statistics

--r5Pyd7+fXNt84Ff3--
