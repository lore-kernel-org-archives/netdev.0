From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: Kernel panic when using bridge
Date: Tue, 12 Apr 2011 06:09:44 +0200
Message-ID: <1302581384.3603.14.camel@edumazet-laptop>
References: <4D9E62D9.5010400@scotdoyle.com>
	 <20110408121700.0aad53fe@nehalam>	<4D9FE5BE.6060600@scotdoyle.com>
	 <20110409161908.a2aca120.shimoda.hiroaki@gmail.com>
	 <4DA39330.2030102@scotdoyle.com> <20110411183105.46e86684@nehalam>
	 <4DA3CB4B.9090506@scotdoyle.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Stephen Hemminger <shemminger@vyatta.com>,
	Hiroaki SHIMODA <shimoda.hiroaki@gmail.com>,
	netdev@vger.kernel.org
To: Scot Doyle <lkml@scotdoyle.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wy0-f174.google.com ([74.125.82.174]:42576 "EHLO
	mail-wy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1749667Ab1DLEJt (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 12 Apr 2011 00:09:49 -0400
Received: by wya21 with SMTP id 21so5352635wya.19
        for <netdev@vger.kernel.org>; Mon, 11 Apr 2011 21:09:48 -0700 (PDT)
In-Reply-To: <4DA3CB4B.9090506@scotdoyle.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le lundi 11 avril 2011 =C3=A0 22:47 -0500, Scot Doyle a =C3=A9crit :
> On 04/11/2011 08:31 PM, Stephen Hemminger wrote:
> >
> > It would help if you gave a little more context (like diff -up)
> > next time.
> >
> > I think the correct fix is for the skb handed to ip_compile_options
> > to match the layout expected by ip_compile_options.
> >
> > This patch is compile tested only, please validate.
> >
> >
> > Subject: [PATCH] bridge: set pseudo-route table before calling ip_c=
omple_options
> >
> > For some ip options, ip_compile_options assumes it can find the ass=
ociated
> > route table. The bridge to iptables code doesn't supply the necessa=
ry
> > reference causing NULL dereference.
> >
> > Signed-off-by: Stephen Hemminger<shemminger@vyatta.com>
> >
> > ---
> > Patch against net-next-2.6, but if validated should go to net-2.6
> > and stable.
> >
> > --- a/net/bridge/br_netfilter.c	2011-04-11 18:18:22.534837859 -0700
> > +++ b/net/bridge/br_netfilter.c	2011-04-11 18:25:15.427244826 -0700
> > @@ -221,6 +221,7 @@ static int br_parse_ip_options(struct sk
> >   	struct ip_options *opt;
> >   	struct iphdr *iph;
> >   	struct net_device *dev =3D skb->dev;
> > +	struct rtable *rt;
> >   	u32 len;
> >
> >   	iph =3D ip_hdr(skb);
> > @@ -255,6 +256,14 @@ static int br_parse_ip_options(struct sk
> >   		return 0;
> >   	}
> >
> > +	/* Associate bogus bridge route table */
> > +	rt =3D bridge_parent_rtable(dev);
> > +	if (!rt) {
> > +		kfree_skb(skb);
> > +		return 0;
> > +	}
> > +	skb_dst_set(skb,&rt->dst);

Please try skb_dst_set_noref() here instead of skb_dst_set()

Or increment rt refcount.

> > +
> >   	opt->optlen =3D iph->ihl*4 - sizeof(struct iphdr);
> >   	if (ip_options_compile(dev_net(dev), opt, skb))
> >   		goto inhdr_error;
> >
> >
> Thanks for the advice on diff context, I appreciate it.  Here's the=20
> output from the patch:
>=20
> [  422.577325] ------------[ cut here ]------------
> [  422.581932] WARNING: at net/core/dst.c:278 dst_release+0x2e/0x5d()
> [  422.588086] Hardware name: PowerEdge R510
> [  422.592075] Modules linked in: kvm_intel kvm bridge stp loop snd_p=
cm=20
> snd_timer snd soundcore snd_page_alloc i7core_edac psmouse pcspkr=20
> edac_core evdev serio_raw power_meter processor ghes tpm_tis dcdbas t=
pm=20
> tpm_bios thermal_sys button hed ext2 mbcache dm_mod raid1 md_mod sd_m=
od=20
> crc_t10dif usb_storage uas uhci_hcd mpt2sas scsi_transport_sas igb=20
> ehci_hcd raid_class scsi_mod usbcore bnx2 dca [last unloaded:=20
> scsi_wait_scan]
> [  422.629510] Pid: 0, comm: swapper Not tainted 2.6.39-rc2+ #10
> [  422.635225] Call Trace:
> [  422.637655] <IRQ>  [<ffffffff81045635>] ? warn_slowpath_common+0x7=
8/0x8c
> [  422.644425]  [<ffffffffa01cbe89>] ? NF_HOOK.clone.4+0x56/0x56 [bri=
dge]
> [  422.650918]  [<ffffffff8127cd60>] ? dst_release+0x2e/0x5d
> [  422.656290]  [<ffffffff8126c25f>] ? skb_release_head_state+0x21/0x=
eb
> [  422.662613]  [<ffffffffa01cbe89>] ? NF_HOOK.clone.4+0x56/0x56 [bri=
dge]
> [  422.669108]  [<ffffffff8126c06f>] ? __kfree_skb+0x9/0x77
> [  422.674392]  [<ffffffff812985f7>] ? nf_hook_slow+0x93/0x114
> [  422.679936]  [<ffffffffa01cbe89>] ? NF_HOOK.clone.4+0x56/0x56 [bri=
dge]
> [  422.686431]  [<ffffffffa01cbe89>] ? NF_HOOK.clone.4+0x56/0x56 [bri=
dge]
> [  422.692927]  [<ffffffffa01cbe6f>] ? NF_HOOK.clone.4+0x3c/0x56 [bri=
dge]
> [  422.699421]  [<ffffffff812a7d8e>] ? tcp_gro_receive+0xa1/0x204
> [  422.705225]  [<ffffffffa01cc1e5>] ? br_handle_frame+0x195/0x1ac [b=
ridge]
> [  422.711892]  [<ffffffffa01cc050>] ?=20
> br_handle_frame_finish+0x1c7/0x1c7 [bridge]
> [  422.719166]  [<ffffffff812764ef>] ? __netif_receive_skb+0x2a7/0x45=
0
> [  422.725401]  [<ffffffff81276928>] ? netif_receive_skb+0x52/0x58
> [  422.731289]  [<ffffffff81276e2a>] ? napi_gro_receive+0x1f/0x2f
> [  422.737091]  [<ffffffff812769ff>] ? napi_skb_finish+0x1c/0x31
> [  422.742809]  [<ffffffffa0226fcd>] ? igb_poll+0x6d9/0x9ee [igb]
> [  422.748615]  [<ffffffffa003bde2>] ? scsi_run_queue+0x2ce/0x30a [sc=
si_mod]
> [  422.755371]  [<ffffffffa003cb31>] ? scsi_io_completion+0x44c/0x4cf=
=20
> [scsi_mod]
> [  422.762472]  [<ffffffff81276f55>] ? net_rx_action+0xa4/0x1b1
> [  422.768103]  [<ffffffff8104ad26>] ? __do_softirq+0xb8/0x176
> [  422.773647]  [<ffffffff81333c5c>] ? call_softirq+0x1c/0x30
> [  422.779104]  [<ffffffff8100aa57>] ? do_softirq+0x3f/0x84
> [  422.784388]  [<ffffffff8104af91>] ? irq_exit+0x3f/0x8f
> [  422.789499]  [<ffffffff8100a793>] ? do_IRQ+0x85/0x9e
> [  422.794439]  [<ffffffff8132cbd3>] ? common_interrupt+0x13/0x13
> [  422.800240] <EOI>  [<ffffffff81061348>] ? enqueue_hrtimer+0x3f/0x5=
3
> [  422.806575]  [<ffffffffa0310417>] ? arch_local_irq_enable+0x7/0x8=20
> [processor]
> [  422.813676]  [<ffffffffa0310dab>] ? acpi_idle_enter_c1+0x86/0xa2=20
> [processor]
> [  422.820690]  [<ffffffff8125d05d>] ? cpuidle_idle_call+0xf4/0x17e
> [  422.826664]  [<ffffffff81008298>] ? cpu_idle+0xa2/0xc4
> [  422.831776]  [<ffffffff8169db60>] ? start_kernel+0x3b9/0x3c4
> [  422.837406]  [<ffffffff8169d3c6>] ? x86_64_start_kernel+0x102/0x10=
f
> [  422.843640] ---[ end trace 5d4687f8472ee50c ]---
>=20


