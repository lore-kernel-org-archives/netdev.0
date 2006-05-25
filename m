From: "Daniel J Blueman" <daniel.blueman@gmail.com>
Subject: Re: sky2 hw csum failure [was Re: sky2 large MTU problems]
Date: Thu, 25 May 2006 11:55:11 +0100
Message-ID: <6278d2220605250355y316f974cl216f22d198475666@mail.gmail.com>
References: <6278d2220605240228v576dd66atdad4855b308e64bf@mail.gmail.com>
	 <20060524103820.2e213a0b@localhost.localdomain>
	 <44758881.1020106@trash.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII;
	format=flowed
Content-Transfer-Encoding: 7BIT
Cc: "Stephen Hemminger" <shemminger@osdl.org>, netdev@vger.kernel.org,
	"Netfilter Developer" <netfilter-devel@lists.netfilter.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from wr-out-0506.google.com ([64.233.184.234]:15414 "EHLO
	wr-out-0506.google.com") by vger.kernel.org with ESMTP
	id S965020AbWEYKzM convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 25 May 2006 06:55:12 -0400
Received: by wr-out-0506.google.com with SMTP id i7so113324wra
        for <netdev@vger.kernel.org>; Thu, 25 May 2006 03:55:11 -0700 (PDT)
To: "Patrick McHardy" <kaber@trash.net>
In-Reply-To: <44758881.1020106@trash.net>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 25/05/06, Patrick McHardy <kaber@trash.net> wrote:
> Stephen Hemminger wrote:
> > On Wed, 24 May 2006 10:28:52 +0100
> > "Daniel J Blueman" <daniel.blueman@gmail.com> wrote:
> >
> >>Having done some more stress testing with sky2 1.4 (in 2.6.17-rc4) and
> >>the latest patch, I have found problems when streaming lots of data
> >>out of the sky2 interface (eg via samba serving a large file to GigE
> >>client). Ultimately, the interface will stop sending.
> >>
> >>Before this happens, I see lots of:
> >>
> >>kernel: lan0: hw csum failure.
> >>kernel:  [__skb_checksum_complete+86/96] __skb_checksum_complete+0x56/0x60
> >>kernel:  [tcp_error+300/512] tcp_error+0x12c/0x200
> >>kernel:  [poison_obj+41/96] poison_obj+0x29/0x60
> >>kernel:  [tcp_error+0/512] tcp_error+0x0/0x200
> >>kernel:  [ip_conntrack_in+157/1072] ip_conntrack_in+0x9d/0x430
> >>kernel:  [kfree_skbmem+8/128] kfree_skbmem+0x8/0x80
> >>kernel:  [arp_process+102/1408] arp_process+0x66/0x580
> >>kernel:  [check_poison_obj+36/416] check_poison_obj+0x24/0x1a0
> >>kernel:  [arp_process+102/1408] arp_process+0x66/0x580
> >>kernel:  [nf_iterate+99/144] nf_iterate+0x63/0x90
> >>kernel:  [ip_rcv_finish+0/608] ip_rcv_finish+0x0/0x260
> >>kernel:  [nf_hook_slow+89/240] nf_hook_slow+0x59/0xf0
> >>kernel:  [ip_rcv_finish+0/608] ip_rcv_finish+0x0/0x260
> >>kernel:  [ip_rcv+386/1104] ip_rcv+0x182/0x450
> >>kernel:  [ip_rcv_finish+0/608] ip_rcv_finish+0x0/0x260
> >>kernel:  [packet_rcv_spkt+216/320] packet_rcv_spkt+0xd8/0x140
> >>kernel:  [netif_receive_skb+476/784] netif_receive_skb+0x1dc/0x310
> >>kernel:  [sky2_poll+879/2096] sky2_poll+0x36f/0x830
> >>kernel:  [_spin_lock_irqsave+9/16] _spin_lock_irqsave+0x9/0x10
> >>kernel:  [run_timer_softirq+290/416] run_timer_softirq+0x122/0x1a0
> >>kernel:  [net_rx_action+108/256] net_rx_action+0x6c/0x100
> >>kernel:  [__do_softirq+66/160] __do_softirq+0x42/0xa0
> >>kernel:  [do_softirq+78/96] do_softirq+0x4e/0x60
> >>kernel:  =======================
> >>kernel:  [do_IRQ+90/160] do_IRQ+0x5a/0xa0
> >>kernel:  [remove_vma+69/80] remove_vma+0x45/0x50
> >>kernel:  [common_interrupt+26/32] common_interrupt+0x1a/0x20
> >>kernel:  [get_offset_pmtmr+151/3584] get_offset_pmtmr+0x97/0xe00
> >>kernel:  [do_gettimeofday+26/208] do_gettimeofday+0x1a/0xd0
> >>kernel:  [sys_gettimeofday+26/144] sys_gettimeofday+0x1a/0x90
> >>kernel:  [syscall_call+7/11] syscall_call+0x7/0xb
> >
> > What ever the netfilter chain is, it is trimming or altering the packet
> > without clearing or altering the hardware checksum. It is not a driver
> > problem, we saw these in VLAN's and ebtables already.
>
> The call chain looks pretty messed up, but the point where an
> invalid HW checksum is detected is in TCP connection tracking,
> which is basically the first thing netfilter does, unless
> you use the raw table. There are no packet modifications done
> by conntrack, so I doubt that netfilter is the culprit here.
> Of course we had some big checksumming cleanups, so there is
> a possibilty of bugs there, but I did test them with sky2 and
> HW checksumming, so I don't think thats the case.
>
> Daniel, is there an easy way to reproduce the checksum failure?

In short, no. This was seen when packets may have been truncated by
large MTU (eg 9000) problems in the sky2 driver transmit path.

There is a small chance that this could relate to transmitting with an
MTU of 9000 (possibly with receiving with an MTU of 1500 too)

On that interface, the only rules that were being exercised were:

iptables -t filter -A INPUT -m state --state ESTABLISHED,RELATED -j ACCEPT
iptables -t filter -A INPUT -p tcp -m tcp --dport 445 --syn -j ACCEPT # SMB
iptables -t filter -A INPUT -j DROP

HTB and SFQ are active on other interfaces.
-- 
Daniel J Blueman
