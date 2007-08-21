From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] IPv6: Fix kernel panic while send SCTP data with IP
 fragments
Date: Tue, 21 Aug 2007 00:09:58 -0700 (PDT)
Message-ID: <20070821.000958.18578815.davem@davemloft.net>
References: <46C8EE3B.40105@cn.fujitsu.com>
	<20070820021238.GU24792@ghostprotocols.net>
	<46C8FC18.6030006@cn.fujitsu.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: acme@ghostprotocols.net, netdev@vger.kernel.org
To: yjwei@cn.fujitsu.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:52023
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1761834AbXHUHJ7 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 21 Aug 2007 03:09:59 -0400
In-Reply-To: <46C8FC18.6030006@cn.fujitsu.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Wei Yongjun <yjwei@cn.fujitsu.com>
Date: Mon, 20 Aug 2007 10:27:36 +0800

> Hi Arnaldo Carvalho de Melo:
> > Em Mon, Aug 20, 2007 at 09:28:27AM +0800, Wei Yongjun escreveu:
> >   
> >> If ICMP6 message with "Packet Too Big" is received after send SCTP DATA,
> >> kernel panic will occur when SCTP DATA is send again.
> >>
> >> This is because of a bad dest address when call to skb_copy_bits().
> >>
> >> The messages sequence is like this:
> >>
> >> Endpoint A                             Endpoint B
> >>                                <-------  SCTP DATA (size=1432) 
> >> ICMP6 message ------->
> >> (Packet Too Big pmtu=1280)
> >>                                <-------  Resend SCTP DATA (size=1432) 
> >> ------------kernel panic---------------
> >>     
> >
> > Thanks! I'm to blame for this one, problem was introduced in:
> >
> > b0e380b1d8a8e0aca215df97702f99815f05c094
> >
> > @@ -761,7 +762,7 @@ slow_path:
> >                 /*
> >                  *      Copy a block of the IP datagram.
> >                  */
> > -               if (skb_copy_bits(skb, ptr, frag->h.raw, len))
> > +               if (skb_copy_bits(skb, ptr, skb_transport_header(skb),
> > len))
> >                         BUG();
> >                 left -= len;
> >
> > So please add:
> >
> > Signed-off-by: Arnaldo Carvalho de Melo <acme@ghostprotocols.net>
> >
> > To this patch.
> >
> > - Arnaldo
> >
> >  
> >   
> >>  printing eip:
> >> c05be62a
> >> *pde = 00000000
> >> Oops: 0002 [#1]
> >> SMP
> >> Modules linked in: scomm l2cap bluetooth ipv6 dm_mirror dm_mod video output sbs battery lp floppy sg i2c_piix4 i2c_core pcnet32 mii button ac parport_pc parport ide_cd cdrom serio_raw mptspi mptscsih mptbase scsi_transport_spi sd_mod scsi_mod ext3 jbd ehci_hcd ohci_hcd uhci_hcd
> >> CPU:    0
> >> EIP:    0060:[<c05be62a>]    Not tainted VLI
> >> EFLAGS: 00010282   (2.6.23-rc2 #1)
> >> EIP is at skb_copy_bits+0x4f/0x1ef
> >> eax: 000004d0   ebx: ce12a980   ecx: 00000134   edx: cfd5a880
> >> esi: c8246858   edi: 00000000   ebp: c0759b14   esp: c0759adc
> >> ds: 007b   es: 007b   fs: 00d8  gs: 0000  ss: 0068
> >> Process swapper (pid: 0, ti=c0759000 task=c06d0340 task.ti=c0713000)
> >> Stack: c0759b88 c0405867 ce12a980 c8bff838 c789c084 00000000 00000028 cfd5a880
> >>        d09f1890 000005dc 0000007b ce12a980 cfd5a880 c8bff838 c0759b88 d09bc521
> >>        000004d0 fffff96c 00000200 00000100 c0759b50 cfd5a880 00000246 c0759bd4
> >> Call Trace:
> >>  [<c0405e1d>] show_trace_log_lvl+0x1a/0x2f
> >>  [<c0405ecd>] show_stack_log_lvl+0x9b/0xa3
> >>  [<c040608d>] show_registers+0x1b8/0x289
> >>  [<c0406271>] die+0x113/0x246
> >>  [<c0625dbc>] do_page_fault+0x4ad/0x57e
> >>  [<c0624642>] error_code+0x72/0x78
> >>  [<d09bc521>] ip6_output+0x8e5/0xab2 [ipv6]
> >>  [<d09bcec1>] ip6_xmit+0x2ea/0x3a3 [ipv6]
> >>  [<d0a3f2ca>] sctp_v6_xmit+0x248/0x253 [sctp]
> >>  [<d0a3c934>] sctp_packet_transmit+0x53f/0x5ae [sctp]
> >>  [<d0a34bf8>] sctp_outq_flush+0x555/0x587 [sctp]
> >>  [<d0a34d3c>] sctp_retransmit+0xf8/0x10f [sctp]
> >>  [<d0a3d183>] sctp_icmp_frag_needed+0x57/0x5b [sctp]
> >>  [<d0a3ece2>] sctp_v6_err+0xcd/0x148 [sctp]
> >>  [<d09cf1ce>] icmpv6_notify+0xe6/0x167 [ipv6]
> >>  [<d09d009a>] icmpv6_rcv+0x7d7/0x849 [ipv6]
> >>  [<d09be240>] ip6_input+0x1dc/0x310 [ipv6]
> >>  [<d09be965>] ipv6_rcv+0x294/0x2df [ipv6]
> >>  [<c05c3789>] netif_receive_skb+0x2d2/0x335
> >>  [<c05c5733>] process_backlog+0x7f/0xd0
> >>  [<c05c58f6>] net_rx_action+0x96/0x17e
> >>  [<c042e722>] __do_softirq+0x64/0xcd
> >>  [<c0406f37>] do_softirq+0x5c/0xac
> >>  =======================
> >> Code: 00 00 29 ca 89 d0 2b 45 e0 89 55 ec 85 c0 7e 35 39 45 08 8b 55 e4 0f 4e 45 08 8b 75 e0 8b 7d dc 89 c1 c1 e9 02 03 b2 a0 00 00 00 <f3> a5 89 c1 83 e1 03 74 02 f3 a4 29 45 08 0f 84 7b 01 00 00 01
> >> EIP: [<c05be62a>] skb_copy_bits+0x4f/0x1ef SS:ESP 0068:c0759adc
> >> Kernel panic - not syncing: Fatal exception in interrupt
> >>
> >> Following is the patch.
> >>     
> Have changed. Thanks
> 
> Regards
> 
> 
> Signed-off-by: Wei Yongjun <yjwei@cn.fujitsu.com>
> Signed-off-by: Arnaldo Carvalho de Melo <acme@ghostprotocols.net>

Applied, thanks everyone.
