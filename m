From: Krzysztof Oledzki <olel@ans.pl>
Subject: Re: skge driver oops
Date: Sun, 30 Jul 2006 15:33:43 +0200 (CEST)
Message-ID: <Pine.LNX.4.64.0607301515260.2638@bizon.gios.gov.pl>
References: <BB1F4EFD574E9F409035BDA71C9612500241A2@exchange.i-bn>
 <20060526081737.5c5b422f@localhost.localdomain>
 <Pine.LNX.4.64.0607230018150.22678@bizon.gios.gov.pl>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII; format=flowed
Cc: Beschorner Daniel <Daniel.Beschorner@facton.com>,
	netdev@vger.kernel.org, "'david@mantara.com'" <david@mantara.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from bizon.gios.gov.pl ([212.244.124.8]:10904 "EHLO
	bizon.gios.gov.pl") by vger.kernel.org with ESMTP id S932282AbWG3NeL
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 30 Jul 2006 09:34:11 -0400
To: Stephen Hemminger <shemminger@osdl.org>
In-Reply-To: <Pine.LNX.4.64.0607230018150.22678@bizon.gios.gov.pl>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org



On Sun, 23 Jul 2006, Krzysztof Oledzki wrote:

>
>
> On Fri, 26 May 2006, Stephen Hemminger wrote:
>
>> Please give this a try, it rearranges the transmit buffer management,
>> and may avoid issues with partial completions causing SKB reuse.
>
> <CUT>
>
> Plase excuse me, I overlooked this patch. Anyway, it seems that this fix went 
> into the 2.6.16 kernel, which is already on the server that caused problems 
> (http://bugzilla.kernel.org/show_bug.cgi?id=6142). I'll disable my workaround 
> (/usr/sbin/ethtool -K eth1 tx off) and let you known about the results.

Strange, I had reenabled tx csum and there were no problems for about one 
week. Yesterday I had upgraded my kernel to the 2.6.17.7 and after one 
day, about 3 hours ago, my system crashed with following log:

  <782b6fe4> skge_xmit_frame+0x121/0x2ea  <781249b6> raise_softirq_irqoff+0xe/0x59
  <7833b9b7> qdisc_restart+0xc4/0x16b  <78332352> net_tx_action+0x97/0xbd
  <7812484d> __do_softirq+0x59/0xc0  <781248e4> do_softirq+0x30/0x35
  <78124947> local_bh_enable+0x5e/0x7e  <78332194> dev_queue_xmit+0x1b6/0x1bd
  <7834ab2c> ip_output+0x1b5/0x1eb  <7834af00> ip_queue_xmit+0x39e/0x3e6
  <78191f3e> __ext3_get_inode_loc+0x53/0x201  <7819df94> journal_dirty_metadata+0x1d1/0x1eb
  <7811bafb> __wake_up+0x27/0x3b  <7819e3dc> journal_stop+0x1bd/0x1c9
  <781963d0> __ext3_journal_stop+0x19/0x37  <78192b58> ext3_dirty_inode+0x5d/0x63
  <78359652> tcp_transmit_skb+0x38e/0x3af  <7816d122> touch_atime+0x97/0x9d
  <7835a89c> tcp_write_xmit+0x1ad/0x212  <7835a924> __tcp_push_pending_frames+0x23/0x80
  <78352732> do_tcp_setsockopt+0x12e/0x2f3  <7832cd3c> sock_common_setsockopt+0x1e/0x22
  <7832ac7b> sys_setsockopt+0x61/0x81  <7832b242> sys_socketcall+0x164/0x1a4
  <7815765d> sys_sendfile+0x5d/0x84  <78102c93> sysenter_past_esp+0x54/0x75
Bad page state in process 'swapper'
page:7985eb20 flags:0x80010008 mapping:e25867a0 mapcount:0 count:0
Trying to fix it up, but a reboot is needed
Backtrace:
  <78140e43> bad_page+0x43/0x6c  <781415e5> free_hot_cold_page+0x5b/0x123
  <7832d700> skb_release_data+0x50/0x86  <7832d741> kfree_skbmem+0xb/0x70
  <78355b41> tcp_clean_rtx_queue+0x225/0x3e6  <783560b1> tcp_ack+0x151/0x27b
  <78358116> tcp_rcv_established+0x544/0x5ed  <7835e972> tcp_v4_do_rcv+0x1f/0xb4
  <7835ee8e> tcp_v4_rcv+0x487/0x6de  <7833f4ef> nf_hook_slow+0xb3/0xce
  <78347aac> ip_local_deliver+0x11b/0x1ab  <78348086> ip_rcv+0x40c/0x446
  <783324e7> netif_receive_skb+0x16f/0x1a7  <782b79a0> skge_poll+0x307/0x3e8
  <78332661> net_rx_action+0x5c/0xd3  <7812484d> __do_softirq+0x59/0xc0
  <781248e4> do_softirq+0x30/0x35  <7812499d> irq_exit+0x36/0x41
  <78104edc> do_IRQ+0x20/0x28  <7810101c> default_idle+0x0/0x55
  <7810373e> common_interrupt+0x1a/0x20  <7810101c> default_idle+0x0/0x55
  <78101048> default_idle+0x2c/0x55  <78101132> cpu_idle+0xad/0xda

I know it is incomplete (this is all what I am able to find in my logs) 
but it looks _very_ similar to the one from:
http://bugzilla.kernel.org/show_bug.cgi?id=6142

BTW: During normal work skge driver still logs (about 10 times per 1 hour) 
informations about hardware error. However, message changed slightly - in 
2.6.16 it was:
  skge hardware error detected (status 0x400)
but in 2.6.17 it is:
  skge 0000:00:0b.0: PCI error cmd=0x7 status=0x82b0
  skge 0000:00:0b.0: PCI error cmd=0x147 status=0xc2b0
  skge 0000:00:0b.0: PCI error cmd=0x147 status=0xc2b0
  skge 0000:00:0b.0: PCI error cmd=0x147 status=0xc2b0
  skge 0000:00:0b.0: PCI error cmd=0x147 status=0xc2b0
  skge 0000:00:0b.0: PCI error cmd=0x147 status=0xc2b0
(...)

Anyway, everything works fine. I don't know if it is somehow related to 
mentioned crashes.

Best regards,

 				Krzysztof Oledzki
