From: Jack Stone <jwjstone@fastmail.fm>
Subject: Re: WARNING: at net/ipv4/tcp.c:1610 tcp_recvmsg+0xb1b/0xc70()
Date: Sun, 27 May 2012 20:13:43 +0100
Message-ID: <4FC27CE7.20604@fastmail.fm>
References: <4FBFEACC.8040601@fastmail.fm>  <1337978725.10135.0.camel@edumazet-glaptop>  <1337979331.10135.2.camel@edumazet-glaptop> <4FC0BCE1.6070601@fastmail.fm>  <1338127184.3670.50.camel@edumazet-glaptop> <4FC24987.4090708@fastmail.fm> <1338140156.3786.10.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, netdev@vger.kernel.org,
	Linux Kernel <linux-kernel@vger.kernel.org>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1338140156.3786.10.camel@edumazet-glaptop>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 05/27/2012 06:35 PM, Eric Dumazet wrote:
> So it seems we can queue in sk_receive_queue a packet with SYN flag set.
> 
> (A SYN or SYNACK packet contains DATA payload...)
> 
> The sequence number of such frames should be tweaked (seq++) instead of
> games we do in fast path :
> 
> if (tcp_hdr(skb)->syn)
>     offset--;
> 
> 
> Oh well this can wait linux-3.6, please test following patch in the
> meantime.
> 
> diff --git a/net/ipv4/tcp_input.c b/net/ipv4/tcp_input.c
> index b224eb8..34c8dcc 100644
> --- a/net/ipv4/tcp_input.c
> +++ b/net/ipv4/tcp_input.c
> @@ -4553,7 +4553,7 @@ static bool tcp_try_coalesce(struct sock *sk,
>  
>  	*fragstolen = false;
>  
> -	if (tcp_hdr(from)->fin)
> +	if (tcp_hdr(from)->fin || tcp_hdr(to)->syn)
>  		return false;
>  
>  	/* Its possible this segment overlaps with prior segment in queue */
> 
> 

Still seems to fire with the above applied, it also sets of the warn just above it...

Could it be something to do with my staging network driver?

[ 2605.769938] ------------[ cut here ]------------
[ 2605.769942] WARNING: at net/ipv4/tcp.c:1611 tcp_recvmsg+0xb36/0xc90()
[ 2605.769943] Hardware name: System Product Name
[ 2605.769944] recvmsg bug 2: copied 84322A4D seq 84322A4D end_seq 84322A86 rcvnxt 843233B3 fl 0 offset 4294967295 len 57 syn 1
[ 2605.769982] Modules linked in: fuse ebtable_nat ebtables ipt_MASQUERADE iptable_nat nf_nat xt_CHECKSUM iptable_mangle bridge lockd rfcomm 8021q garp stp llc bnep ip6t_REJECT nf_conntrack_netbios_ns nf_conntrack_broadcast nf_conntrack_ipv6 nf_defrag_ipv6 nf_conntrack_ipv4 nf_defrag_ipv4 xt_state nf_conntrack ip6table_filter ip6_tables snd_hda_codec_hdmi snd_hda_codec_realtek vhost_net macvtap macvlan tun coretemp virtio_net kvm_intel kvm btusb bluetooth snd_hda_intel snd_hda_codec snd_hwdep snd_seq sunrpc r8712u(C) snd_seq_device snd_pcm snd_timer eeepc_wmi asus_wmi sparse_keymap e1000e mxm_wmi snd soundcore joydev wmi rfkill i2c_i801 snd_page_alloc iTCO_wdt serio_raw hid_logitech_dj pcspkr iTCO_vendor_support binfmt_misc microcode uinput crc32c_intel ghash_clmulni_intel firewire_ohci fi
 rewire_core crc_itu_t [last unloaded: scsi_wait_scan]
[ 2605.769985] Pid: 3305, comm: firefox Tainted: G        WC   3.4.0-07822-g786f02b-dirty #2
[ 2605.769986] Call Trace:
[ 2605.769988]  [<ffffffff8106010f>] warn_slowpath_common+0x7f/0xc0
[ 2605.769990]  [<ffffffff81060206>] warn_slowpath_fmt+0x46/0x50
[ 2605.769993]  [<ffffffff8163f7f5>] ? tcp_recvmsg+0x35/0xc90
[ 2605.769996]  [<ffffffff816402f6>] tcp_recvmsg+0xb36/0xc90
[ 2605.769998]  [<ffffffff8166ac20>] ? inet_sendmsg+0x230/0x230
[ 2605.770001]  [<ffffffff8166ad57>] inet_recvmsg+0x137/0x250
[ 2605.770004]  [<ffffffff815d8288>] ? sock_update_classid+0x128/0x310
[ 2605.770006]  [<ffffffff815d04ed>] sock_recvmsg+0x11d/0x140
[ 2605.770009]  [<ffffffff811bdcb8>] ? fget_light+0x48/0x4f0
[ 2605.770012]  [<ffffffff811d1920>] ? __pollwait+0xf0/0xf0
[ 2605.770014]  [<ffffffff811bdd76>] ? fget_light+0x106/0x4f0
[ 2605.770017]  [<ffffffff811bdcb8>] ? fget_light+0x48/0x4f0
[ 2605.770020]  [<ffffffff815d3941>] sys_recvfrom+0xf1/0x170
[ 2605.770022]  [<ffffffff810f6ddc>] ? __audit_syscall_entry+0xcc/0x310
[ 2605.770025]  [<ffffffff8132dfce>] ? trace_hardirqs_on_thunk+0x3a/0x3f
[ 2605.770028]  [<ffffffff8174cc69>] system_call_fastpath+0x16/0x1b
[ 2605.770029] ---[ end trace f86533e3bdc5b326 ]---
------------[ cut here ]------------
[ 2605.770032] WARNING: at net/ipv4/tcp.c:1598 tcp_recvmsg+0x409/0xc90()
[ 2605.770034] Hardware name: System Product Name
[ 2605.770082] recvmsg bug: copied 84322A4D seq 84322A86 rcvnxt 843233B3 fl 0
[ 2605.770119] Modules linked in: fuse ebtable_nat ebtables ipt_MASQUERADE iptable_nat nf_nat xt_CHECKSUM iptable_mangle bridge lockd rfcomm 8021q garp stp llc bnep ip6t_REJECT nf_conntrack_netbios_ns nf_conntrack_broadcast nf_conntrack_ipv6 nf_defrag_ipv6 nf_conntrack_ipv4 nf_defrag_ipv4 xt_state nf_conntrack ip6table_filter ip6_tables snd_hda_codec_hdmi snd_hda_codec_realtek vhost_net macvtap macvlan tun coretemp virtio_net kvm_intel kvm btusb bluetooth snd_hda_intel snd_hda_codec snd_hwdep snd_seq sunrpc r8712u(C) snd_seq_device snd_pcm snd_timer eeepc_wmi asus_wmi sparse_keymap e1000e mxm_wmi snd soundcore joydev wmi rfkill i2c_i801 snd_page_alloc iTCO_wdt serio_raw hid_logitech_dj pcspkr iTCO_vendor_support binfmt_misc microcode uinput crc32c_intel ghash_clmulni_intel firewire_ohci fi
 rewire_core crc_itu_t [last unloaded: scsi_wait_scan]
[ 2605.770122] Pid: 3305, comm: firefox Tainted: G        WC   3.4.0-07822-g786f02b-dirty #2
[ 2605.770123] Call Trace:
[ 2605.770125]  [<ffffffff8106010f>] warn_slowpath_common+0x7f/0xc0
[ 2605.770128]  [<ffffffff81060206>] warn_slowpath_fmt+0x46/0x50
[ 2605.770130]  [<ffffffff8163f7f5>] ? tcp_recvmsg+0x35/0xc90
[ 2605.770132]  [<ffffffff8163fbc9>] tcp_recvmsg+0x409/0xc90
[ 2605.770135]  [<ffffffff8166ac20>] ? inet_sendmsg+0x230/0x230
[ 2605.770138]  [<ffffffff8166ad57>] inet_recvmsg+0x137/0x250
[ 2605.770140]  [<ffffffff815d8288>] ? sock_update_classid+0x128/0x310
[ 2605.770143]  [<ffffffff815d04ed>] sock_recvmsg+0x11d/0x140
[ 2605.770146]  [<ffffffff811bdcb8>] ? fget_light+0x48/0x4f0
[ 2605.770148]  [<ffffffff811d1920>] ? __pollwait+0xf0/0xf0
[ 2605.770150]  [<ffffffff811bdd76>] ? fget_light+0x106/0x4f0
[ 2605.770152]  [<ffffffff811bdcb8>] ? fget_light+0x48/0x4f0
[ 2605.770154]  [<ffffffff815d3941>] sys_recvfrom+0xf1/0x170
[ 2605.770157]  [<ffffffff810f6ddc>] ? __audit_syscall_entry+0xcc/0x310
[ 2605.770160]  [<ffffffff8132dfce>] ? trace_hardirqs_on_thunk+0x3a/0x3f
[ 2605.770163]  [<ffffffff8174cc69>] system_call_fastpath+0x16/0x1b
[ 2605.770164] ---[ end trace f86533e3bdc5b327 ]---

Thanks,

Jack
