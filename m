From: "Petersson, Mats" <Mats.Petersson@amd.com>
Subject: RE: [Xen-devel] kernel BUG at net/core/dev.c:1133!
Date: Fri, 7 Jul 2006 17:03:36 +0200
Message-ID: <907625E08839C4409CE5768403633E0BA7FD7F@sefsexmb1.amd.com>
References: <E1FyrUg-0003FA-00@gondolin.me.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain;
 charset=us-ascii
Content-Transfer-Encoding: 8BIT
Cc: xen-devel@lists.xensource.com, netdev@vger.kernel.org,
	kaber@trash.net, davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from outbound-kan.frontbridge.com ([63.161.60.23]:18891 "EHLO
	outbound1-kan-R.bigfish.com") by vger.kernel.org with ESMTP
	id S932167AbWGGQ6C convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 7 Jul 2006 12:58:02 -0400
Content-class: urn:content-classes:message
In-Reply-To: <E1FyrUg-0003FA-00@gondolin.me.apana.org.au>
To: "Herbert Xu" <herbert@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

> -----Original Message-----
> From: Herbert Xu [mailto:herbert@gondor.apana.org.au] 
> Sent: 07 July 2006 15:40
> To: Petersson, Mats
> Cc: xen-devel@lists.xensource.com; netdev@vger.kernel.org; 
> kaber@trash.net; davem@davemloft.net
> Subject: Re: [Xen-devel] kernel BUG at net/core/dev.c:1133!
> 
> Petersson, Mats <Mats.Petersson@amd.com> wrote:
> > Looks like the GSO is involved?
> 
> It's certainly what crashed your machine :) It's probably not the
> guilty party though.  Someone is passing through a TSO packet with
> checksum set to something other than CHECKSUM_HW.
> 
> I bet it's netfilter and we just never noticed before because real
> NICS would simply corrupt the checksum silently.
> 
> Could you confirm that you have netfilter rules (in particular NAT
> rules) and that this goes away if you flush all your netfilter tables?

If by netfilter, you mean "iptables", it says:
[root@cheetah ~]# iptables --list
Chain FORWARD (policy ACCEPT)
target     prot opt source               destination

Chain INPUT (policy ACCEPT)
target     prot opt source               destination

Chain OUTPUT (policy ACCEPT)
target     prot opt source               destination

So, nothing going on there... I certainly haven't got NAT on my machine,
as my machine is within the AMD network, and doesn't need NAT. AMD
probably uses NAT as part of it's external communications, but I doubt
it's used at all internally. 

I also have noticed the crash happens when I try to access another
machine within my local switch - if that makes any difference... But not
instantly. I can do some communication with the machine next to it [like
I did "ssh cheetah" from my machine "quad" to get the iptables above,
and it works just fine - but when I did "xm dmesg" from "cheetah"
through ssh on "quad", it didn't work - presumably because it's a bit
more data being pushed - but I can't say for sure, as I have made no
attempt to really debug it]. 

I hope this info is of help to analyze the situation, and please feel
free to ask for further info.

--
Mats
> 
> Patrick, do we really have to zap the checksum on outbound NAT? Could
> we update it instead?
> 
> > I got this while running Dom0 only (no guests), with a
> > BOINC/Rosetta@home application running on all 4 cores. 
> > 
> > changeset:   10649:8e55c5c11475
> > 
> > Build: x86_32p (pae). 
> > 
> > ------------[ cut here ]------------
> > kernel BUG at net/core/dev.c:1133!
> > invalid opcode: 0000 [#1]
> > SMP 
> > CPU:    0
> > EIP:    0061:[<c04dceb0>]    Not tainted VLI
> > EFLAGS: 00210297   (2.6.16.13-xen #12) 
> > EIP is at skb_gso_segment+0xf0/0x110
> > eax: 00000000   ebx: 00000003   ecx: 00000002   edx: c06e2e00
> > esi: 00000008   edi: cd9e32e0   ebp: c63a7900   esp: c0de5ad0
> > ds: 007b   es: 007b   ss: 0069
> > Process rosetta_5.25_i6 (pid: 8826, threadinfo=c0de4000 
> task=cb019560)
> > Stack: <0>c8f69060 00000000 ffffffa3 00000003 cd9e32e0 
> 00000002 c63a7900
> > c04dcfb0 
> >       cd9e32e0 00000003 00000000 cd9e32e0 cf8e3000 cf8e3140 c04dd07e
> > cd9e32e0 
> >       cf8e3000 00000000 cd9e32e0 cf8e3000 c04ec07e cd9e32e0 cf8e3000
> > c0895140 
> > Call Trace:
> > [<c04dcfb0>] dev_gso_segment+0x30/0xb0
> > [<c04dd07e>] dev_hard_start_xmit+0x4e/0x110
> > [<c04ec07e>] __qdisc_run+0xbe/0x280
> > [<c04dd4b9>] dev_queue_xmit+0x379/0x380
> > [<c05bbe44>] br_dev_queue_push_xmit+0xa4/0x140
> > [<c05c2402>] br_nf_post_routing+0x102/0x1d0
> > [<c05c22b0>] br_nf_dev_queue_xmit+0x0/0x50
> > [<c05bbda0>] br_dev_queue_push_xmit+0x0/0x140
> > [<c04f0eab>] nf_iterate+0x6b/0xa0
> > [<c05bbda0>] br_dev_queue_push_xmit+0x0/0x140
> > [<c05bbda0>] br_dev_queue_push_xmit+0x0/0x140
> > [<c04f0f4e>] nf_hook_slow+0x6e/0x120
> > [<c05bbda0>] br_dev_queue_push_xmit+0x0/0x140
> > [<c05bbf40>] br_forward_finish+0x60/0x70
> > [<c05bbda0>] br_dev_queue_push_xmit+0x0/0x140
> > [<c05c1b71>] br_nf_forward_finish+0x71/0x130
> > [<c05bbee0>] br_forward_finish+0x0/0x70
> > [<c05c1d20>] br_nf_forward_ip+0xf0/0x1a0
> > [<c05c1b00>] br_nf_forward_finish+0x0/0x130
> > [<c05bbee0>] br_forward_finish+0x0/0x70
> > [<c04f0eab>] nf_iterate+0x6b/0xa0
> > [<c05bbee0>] br_forward_finish+0x0/0x70
> > [<c05bbee0>] br_forward_finish+0x0/0x70
> > [<c04f0f4e>] nf_hook_slow+0x6e/0x120
> > [<c05bbee0>] br_forward_finish+0x0/0x70
> > [<c05bc044>] __br_forward+0x74/0x80
> > [<c05bbee0>] br_forward_finish+0x0/0x70
> > [<c05bceb1>] br_handle_frame_finish+0xd1/0x160
> > [<c05bcde0>] br_handle_frame_finish+0x0/0x160
> > [<c05c0e0b>] br_nf_pre_routing_finish+0xfb/0x480
> > [<c05bcde0>] br_handle_frame_finish+0x0/0x160
> > [<c05c0d10>] br_nf_pre_routing_finish+0x0/0x480
> > [<c054fe13>] ip_nat_in+0x43/0xc0
> > [<c05c0d10>] br_nf_pre_routing_finish+0x0/0x480
> > [<c04f0eab>] nf_iterate+0x6b/0xa0
> > [<c05c0d10>] br_nf_pre_routing_finish+0x0/0x480
> > [<c05c0d10>] br_nf_pre_routing_finish+0x0/0x480
> > [<c04f0f4e>] nf_hook_slow+0x6e/0x120
> > [<c05c0d10>] br_nf_pre_routing_finish+0x0/0x480
> > [<c05c1914>] br_nf_pre_routing+0x404/0x580
> > [<c05c0d10>] br_nf_pre_routing_finish+0x0/0x480
> > [<c04f0eab>] nf_iterate+0x6b/0xa0
> > [<c05bcde0>] br_handle_frame_finish+0x0/0x160
> > [<c05bcde0>] br_handle_frame_finish+0x0/0x160
> > [<c04f0f4e>] nf_hook_slow+0x6e/0x120
> > [<c05bcde0>] br_handle_frame_finish+0x0/0x160
> > [<c05bd124>] br_handle_frame+0x1e4/0x250
> > [<c05bcde0>] br_handle_frame_finish+0x0/0x160
> > [<c04ddae5>] netif_receive_skb+0x165/0x2a0
> > [<c04ddcdf>] process_backlog+0xbf/0x180
> > [<c04ddebf>] net_rx_action+0x11f/0x1d0
> > [<c01262e6>] __do_softirq+0x86/0x120
> > [<c01263f5>] do_softirq+0x75/0x90
> > [<c0106cef>] do_IRQ+0x1f/0x30
> > [<c04271d0>] evtchn_do_upcall+0x90/0x100
> > [<c0105315>] hypervisor_callback+0x3d/0x48
> > Code: c2 2b 57 24 29 d0 8d 14 2a 89 87 94 00 00 00 89 57 60 
> 8b 44 24 08
> > 83 c4 0c 5b 5e 5f 5d c3 0f 0
> > b 69 03 fe 8c 66 c0 e9 69 ff ff ff <0f> 0b 6d 04 e8 ab 6c 
> c0 e9 3a ff ff
> > ff 0f 0b 6c 04 e8 ab 6c c0 
> > <0>Kernel panic - not syncing: Fatal exception in interrupt
> 
> Cheers,
> -- 
> Visit Openswan at http://www.openswan.org/
> Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
> Home Page: http://gondor.apana.org.au/~herbert/
> PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
> 
> 


