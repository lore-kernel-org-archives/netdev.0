From: Ben Hutchings <bhutchings@solarflare.com>
Subject: Re: skb_warn_bad_offload with kernel 3.5 (maybe gso/bridge related
 ?)
Date: Fri, 3 Aug 2012 16:40:08 +0100
Message-ID: <1344008408.4642.160.camel@deadeye.wl.decadent.org.uk>
References: <501B8792.6040605@univ-nantes.fr>
	 <1343983887.9299.817.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Yann Dupont <Yann.Dupont@univ-nantes.fr>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	Herbert Xu <herbert@gondor.apana.org.au>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from webmail.solarflare.com ([12.187.104.25]:58659 "EHLO
	ocex02.SolarFlarecom.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1751802Ab2HCPkP (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 3 Aug 2012 11:40:15 -0400
In-Reply-To: <1343983887.9299.817.camel@edumazet-glaptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 2012-08-03 at 10:51 +0200, Eric Dumazet wrote:
> On Fri, 2012-08-03 at 10:10 +0200, Yann Dupont wrote:
> > Hello everybody,
> > 
> > I have a machine using ceph rbd volume, as a client (rbd module) to 
> > backup data.
> > 
> > I was running kernel 3.2.22 ok. Tried 3.5.0 because some rbd fixes went in.
> > 
> > Now, shortly after the start, my logs are filled by that :
> > 
> > Jul 31 18:15:01 singleton.u06.univ-nantes.prive kernel: [ 1175.780860] 
> > WARNING: at net/core/dev.c:1888 skb_warn_bad_offload+0xb6/0xc1()
> > Jul 31 18:15:01 singleton.u06.univ-nantes.prive kernel: [ 1175.780920] 
> > Hardware name: PowerEdge M605
> > Jul 31 18:15:01 singleton.u06.univ-nantes.prive kernel: [ 1175.780990] : 
> > caps=(0x0000000000005000, 0x0000000000000000) len=7292 data_len=5792 
> > gso_size=1448 gso_type=1 ip_summed=1
> > Jul 31 18:15:01 singleton.u06.univ-nantes.prive kernel: [ 1175.781071] 
> > Modules linked in: rbd libceph ipt_MASQUERADE iptable_nat nf_nat 
> > ipt_REJECT veth fuse xt_physdev xt_iprange xt_multiport ip6table_filter 
> > ip6_tables xt_LOG xt_limit xt_tcpudp xt_state iptable_filter ip_tables 
> > x_tables nf_conntrack_tftp nf_conntrack_ftp nf_conntrack_ipv4 
> > nf_defrag_ipv4 8021q bridge stp llc ext2 mbcache dm_round_robin 
> > dm_multipath scsi_dh nf_conntrack_ipv6 nf_conntrack nf_defrag_ipv6 ipv6 
> > powernow_k8 freq_table mperf kvm_amd snd_pcm kvm snd_timer snd soundcore 
> > snd_page_alloc tpm_tis tpm tpm_bios pcspkr evdev psmouse microcode 
> > joydev dcdbas shpchp i2c_nforce2 pci_hotplug serio_raw processor 
> > i2c_core hid_generic thermal_sys hed button xfs exportfs dm_mod ses 
> > enclosure usbhid hid sg sr_mod sd_mod cdrom usb_storage lpfc 
> > scsi_transport_fc scsi_tgt ohci_hcd bnx2x mptsas mptscsih bnx2 mptbase 
> > scsi_transport_sas crc32c scsi_mod libcrc32c mdio ehci_hcd [last 
> > unloaded: scsi_wait_scan]
> > Jul 31 18:15:01 singleton.u06.univ-nantes.prive kernel: [ 1175.785995] 
> > Pid: 0, comm: swapper/0 Not tainted 3.5.0-dsiun-120521 #5
> > Jul 31 18:15:01 singleton.u06.univ-nantes.prive kernel: [ 1175.786055] 
> > Call Trace:
> > Jul 31 18:15:01 singleton.u06.univ-nantes.prive kernel: [ 1175.786108]  
> > <IRQ>  [<ffffffff813bde00>] ? skb_warn_bad_offload+0x6f/0xc1
> > Jul 31 18:15:01 singleton.u06.univ-nantes.prive kernel: [ 1175.786209]  
> > [<ffffffff8103a109>] ? warn_slowpath_common+0x79/0xc0
> > Jul 31 18:15:01 singleton.u06.univ-nantes.prive kernel: [ 1175.786269]  
> > [<ffffffff8103a205>] ? warn_slowpath_fmt+0x45/0x50
> > Jul 31 18:15:01 singleton.u06.univ-nantes.prive kernel: [ 1175.786330]  
> > [<ffffffff81068647>] ? get_nohz_timer_target+0x57/0xd0
> > Jul 31 18:15:01 singleton.u06.univ-nantes.prive kernel: [ 1175.786390]  
> > [<ffffffff813bde47>] ? skb_warn_bad_offload+0xb6/0xc1
> > Jul 31 18:15:01 singleton.u06.univ-nantes.prive kernel: [ 1175.786452]  
> > [<ffffffff813110e7>] ? skb_gso_segment+0x207/0x280
[...]
> I dont know, maybe its more a GRO issue ?
>
> When a NIC delivers skbs with ip_summed set to CHECKSUM_UNNECESSARY,
> should resulting GRO packet have ip_summed set to CHECKSUM_PARTIAL ?

I think GRO is doing the right thing, and I can't think why we should
see ip_summed = CHECKSUM_PARTIAL if the skb is forwarded by a bridge.  I
think skb_gso_segment() now needs to handle CHECKSUM_UNNECESSARY
without warning, and it can be done somewhat more efficiently (as there
is no need to copy payload and generate checksums).

By the way, the warning in skb_gso_segment() is not new, even though I
changed it recently.  I don't know why it might have started being
triggered between 3.2 and 3.5.

Ben.

-- 
Ben Hutchings, Staff Engineer, Solarflare
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.
