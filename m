From: Maxim Uvarov <maxim.uvarov@oracle.com>
Subject: boding and netpoll
Date: Fri, 30 Dec 2011 14:17:13 -0800
Message-ID: <4EFE3869.3020900@oracle.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from rcsinet15.oracle.com ([148.87.113.117]:30100 "EHLO
	rcsinet15.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752025Ab1L3WTL (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 30 Dec 2011 17:19:11 -0500
Received: from acsinet21.oracle.com (acsinet21.oracle.com [141.146.126.237])
	by rcsinet15.oracle.com (Switch-3.4.4/Switch-3.4.4) with ESMTP id pBUMJ9Um011488
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-SHA bits=256 verify=OK)
	for <netdev@vger.kernel.org>; Fri, 30 Dec 2011 22:19:10 GMT
Received: from acsmt357.oracle.com (acsmt357.oracle.com [141.146.40.157])
	by acsinet21.oracle.com (8.14.4+Sun/8.14.4) with ESMTP id pBUMJ92S024655
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-SHA bits=256 verify=NO)
	for <netdev@vger.kernel.org>; Fri, 30 Dec 2011 22:19:09 GMT
Received: from abhmt117.oracle.com (abhmt117.oracle.com [141.146.116.69])
	by acsmt357.oracle.com (8.12.11.20060308/8.12.11) with ESMTP id pBUMJ900023805
	for <netdev@vger.kernel.org>; Fri, 30 Dec 2011 16:19:09 -0600
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

netpoll_send_skb_on_dev() disables interrupts which cause warning
which does spin_unlock_bh() in case if netpoll is used on bonded 
interface (netconsole in my case).

Looking for some clear fix for that. Maybe spin lock instead of 
spin_lock_bh  in _lock_tx_hashtbl in case if interrupts are disabled?

WARNING: at kernel/softirq.c:159 local_bh_enable_ip+0x69/0x80()
   [<c0461b59>] ? local_bh_enable_ip+0x69/0x80
   [<c045aea1>] warn_slowpath_common+0x81/0xa0
   [<c0461b59>] ? local_bh_enable_ip+0x69/0x80
   [<c045aee2>] warn_slowpath_null+0x22/0x30
   [<c0461b59>] local_bh_enable_ip+0x69/0x80
   [<c086ab83>] _raw_spin_unlock_bh+0x13/0x20
   [<f82b2150>] tlb_choose_channel+0x50/0xb0 [bonding]
   [<f82b3387>] bond_alb_xmit+0x207/0x210 [bonding]
   [<f82ab647>] __bond_start_xmit+0x177/0x1a0 [bonding]
   [<f82abe66>] bond_start_xmit+0x46/0x80 [bonding]
   [<c07c9681>] netpoll_send_skb_on_dev+0x121/0x1a0
   [<c07a9afe>] ? __alloc_skb+0x7e/0x120
   [<c07c996c>] netpoll_send_udp+0x1dc/0x1f0
   [<f838e73f>] write_msg+0x8f/0xc0 [netconsole]
   [<f838e6b0>] ? store_remote_port+0x60/0x60 [netconsole]
   [<c045b2a7>] __call_console_drivers+0x77/0x90
   [<c045b311>] _call_console_drivers+0x51/0x90
   [<c045b60b>] call_console_drivers+0x8b/0xd0
   [<c045b867>] console_unlock+0x37/0xc0
   [<c045be59>] vprintk+0x159/0x300
   [<c0541215>] ? path_openat+0xc5/0x360
   [<c0541595>] ? do_filp_open+0x35/0x80
   [<c045c020>] printk+0x20/0x30
   [<c06acc9d>] __handle_sysrq+0x3d/0x110
   [<c05aaaee>] ? security_file_permission+0x1e/0x90
   [<c06acdba>] write_sysrq_trigger+0x4a/0x50
   [<c06acd70>] ? __handle_sysrq+0x110/0x110
   [<c057e28d>] proc_reg_write+0x5d/0x80
   [<c0534ffb>] vfs_write+0x9b/0x160
   [<c04aff91>] ? audit_syscall_exit+0x381/0x3f0
   [<c057e230>] ? proc_reg_poll+0x80/0x80
   [<c0535622>] sys_write+0x42/0x70
   [<c087231f>] sysenter_do_call+0x12/0x28

  void netpoll_send_skb_on_dev(struct netpoll *np, struct sk_buff *skb,
                               struct net_device *dev)
  {
  .
  local_irq_save(flags);
  status = ops->ndo_start_xmit(skb, dev);
  local_irq_restore(flags);
  .
  }
  .
  then bond_start_xmit()
  static struct slave *tlb_choose_channel(struct bonding *bond, u32 
ash_index,
  u32 skb_len)
  {
  .
   spin_lock_bh(&(BOND_ALB_INFO(bond).tx_hashtbl_lock));
  .....
   spin_unlock_bh(&(BOND_ALB_INFO(bond).tx_hashtbl_lock));
  }
  .
  static inline void __raw_spin_unlock_bh(raw_spinlock_t *lock)
  {
          spin_release(&lock->dep_map, 1, _RET_IP_);
          do_raw_spin_unlock(lock);
          preempt_enable_no_resched();
          local_bh_enable_ip((unsigned long)__builtin_return_address(0));
  }
  .
  static inline void _local_bh_enable_ip(unsigned long ip)
  {
          WARN_ON_ONCE(in_irq() || irqs_disabled());

Best regards,
Maxim Uvarov.
