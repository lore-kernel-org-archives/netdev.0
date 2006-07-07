From: Tim Post <tim.post@netkinetics.net>
Subject: Re: kernel BUG at net/core/dev.c:1133!
Date: Fri, 07 Jul 2006 23:05:43 +0800
Message-ID: <1152284743.8914.112.camel@rd3.netkinetics.net>
References: <E1FyrUg-0003FA-00@gondolin.me.apana.org.au>
Reply-To: tim.post@netkinetics.net
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: "Petersson, Mats" <Mats.Petersson@amd.com>, davem@davemloft.net,
	xen-devel@lists.xensource.com, kaber@trash.net, netdev@vger.kernel.org
Return-path: <xen-devel-bounces@lists.xensource.com>
To: Herbert Xu <herbert@gondor.apana.org.au>
In-Reply-To: <E1FyrUg-0003FA-00@gondolin.me.apana.org.au>
List-Unsubscribe: <http://lists.xensource.com/cgi-bin/mailman/listinfo/xen-devel>,
	<mailto:xen-devel-request@lists.xensource.com?subject=unsubscribe>
List-Post: <mailto:xen-devel@lists.xensource.com>
List-Help: <mailto:xen-devel-request@lists.xensource.com?subject=help>
List-Subscribe: <http://lists.xensource.com/cgi-bin/mailman/listinfo/xen-devel>,
	<mailto:xen-devel-request@lists.xensource.com?subject=subscribe>
Sender: xen-devel-bounces@lists.xensource.com
Errors-To: xen-devel-bounces@lists.xensource.com
List-Id: netdev.vger.kernel.org

I got the exact same thing when attempting to use BOINC on a single node
supporting a 5 node open SSI cluster, (5 guests) and yes the problem
went away when I flushed the rules. 

I attributed this to a quirk with the cluster CVIP, because I had also
assigned each node its own outbound IP in addition to the incoming CVIP.

Since I felt it was due to my tendency to over-tinker, I didn't mention
it on the lists, was a few months ago. 

Thought I would chime in as it sounds like the same experience, up to
and including BOINC.

HTH

--Tim

On Sat, 2006-07-08 at 00:39 +1000, Herbert Xu wrote:
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
> > Process rosetta_5.25_i6 (pid: 8826, threadinfo=c0de4000 task=cb019560)
> > Stack: <0>c8f69060 00000000 ffffffa3 00000003 cd9e32e0 00000002 c63a7900
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
> > Code: c2 2b 57 24 29 d0 8d 14 2a 89 87 94 00 00 00 89 57 60 8b 44 24 08
> > 83 c4 0c 5b 5e 5f 5d c3 0f 0
> > b 69 03 fe 8c 66 c0 e9 69 ff ff ff <0f> 0b 6d 04 e8 ab 6c c0 e9 3a ff ff
> > ff 0f 0b 6c 04 e8 ab 6c c0 
> > <0>Kernel panic - not syncing: Fatal exception in interrupt
> 
> Cheers,
