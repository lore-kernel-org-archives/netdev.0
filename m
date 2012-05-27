From: Jack Stone <jwjstone@fastmail.fm>
Subject: Re: WARNING: at net/ipv4/tcp.c:1610 tcp_recvmsg+0xb1b/0xc70()
Date: Sun, 27 May 2012 16:34:31 +0100
Message-ID: <4FC24987.4090708@fastmail.fm>
References: <4FBFEACC.8040601@fastmail.fm>  <1337978725.10135.0.camel@edumazet-glaptop>  <1337979331.10135.2.camel@edumazet-glaptop>  <4FC0BCE1.6070601@fastmail.fm> <1338127184.3670.50.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, netdev@vger.kernel.org,
	Linux Kernel <linux-kernel@vger.kernel.org>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from out3-smtp.messagingengine.com ([66.111.4.27]:54351 "EHLO
	out3-smtp.messagingengine.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752672Ab2E0Peh (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 27 May 2012 11:34:37 -0400
In-Reply-To: <1338127184.3670.50.camel@edumazet-glaptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 05/27/2012 02:59 PM, Eric Dumazet wrote:
> On Sat, 2012-05-26 at 12:22 +0100, Jack Stone wrote:
> 
>> I'm still getting this with da89fb1 which includes the above
>>
>> Linux hover1 3.4.0-07797-gda89fb1 #4 SMP Fri May 25 22:23:14 BST 2012 x86_64 x86_64 x86_64 GNU/Linux
> 
> Thanks
> 
> Could you add following debugging patch ?
> 
> diff --git a/net/ipv4/tcp.c b/net/ipv4/tcp.c
> index 3ba605f..b56c63c 100644
> --- a/net/ipv4/tcp.c
> +++ b/net/ipv4/tcp.c
> @@ -1606,8 +1606,9 @@ int tcp_recvmsg(struct kiocb *iocb, struct sock *sk, struct msghdr *msg,
>  			if (tcp_hdr(skb)->fin)
>  				goto found_fin_ok;
>  			WARN(!(flags & MSG_PEEK),
> -			     "recvmsg bug 2: copied %X seq %X rcvnxt %X fl %X\n",
> -			     *seq, TCP_SKB_CB(skb)->seq, tp->rcv_nxt, flags);
> +			     "recvmsg bug 2: copied %X seq %X end_seq %X rcvnxt %X fl %X offset %u len %u syn %d\n",
> +			     *seq, TCP_SKB_CB(skb)->seq, TCP_SKB_CB(skb)->end_seq,
> +			     tp->rcv_nxt, flags, offset, skb->len, tcp_hdr(skb)->syn);
>  		}
>  
>  		/* Well, if we have backlog, try to process it now yet. */
> 
> 

uname: Linux hover1 3.4.0-07822-g786f02b-dirty #1 SMP Sun May 27 15:23:39 BST 2012 x86_64 x86_64 x86_64 GNU/Linux

Here's the new output:


May 27 16:32:30 hover1 kernel: [ 1907.804613] ------------[ cut here ]------------
May 27 16:32:30 hover1 kernel: [ 1907.804622] WARNING: at net/ipv4/tcp.c:1611 tcp_recvmsg+0xb36/0xc90()
May 27 16:32:30 hover1 kernel: [ 1907.804624] Hardware name: System Product Name
May 27 16:32:30 hover1 kernel: [ 1907.804626] recvmsg bug 2: copied 8F322DEB seq 8F322DEB end_seq 8F322F2A rcvnxt 8F322F2A fl 0 offset 4294967295 len 319 syn 1
May 27 16:32:30 hover1 kernel: [ 1907.804665] Modules linked in: fuse ebtable_nat ebtables ipt_MASQUERADE iptable_nat nf_nat xt_CHECKSUM iptable_mangle bridge rfcomm lockd 8021q garp stp llc bnep ip6t_REJECT nf_conntrack_ipv6 nf_defrag_ipv6 nf_conntrack_netbios_ns nf_conntrack_broadcast ip6table_filter ip6_tables nf_conntrack_ipv4 nf_defrag_ipv4 xt_state nf_conntrack snd_hda_codec_hdmi snd_hda_codec_realtek coretemp vhost_net macvtap macvlan tun virtio_net kvm_intel snd_hda_intel kvm snd_hda_codec btusb bluetooth snd_hwdep e1000e snd_seq eeepc_wmi asus_wmi sparse_keymap microcode r8712u(C) snd_seq_device rfkill snd_pcm joydev sunrpc snd_timer snd mxm_wmi hid_logitech_dj iTCO_wdt wmi iTCO_vendor_support i2c_i801 soundcore snd_page_alloc binfmt_misc serio_raw pcspkr uinput crc32c_intel ghash
 _clmulni_intel firewire_ohci firewire_core crc_itu_t [last unloaded: scsi_wait_scan]
May 27 16:32:30 hover1 kernel: [ 1907.804669] Pid: 2275, comm: thunderbird-bin Tainted: G         C   3.4.0-07822-g786f02b-dirty #1
May 27 16:32:30 hover1 kernel: [ 1907.804670] Call Trace:
May 27 16:32:30 hover1 kernel: [ 1907.804674]  [<ffffffff8106010f>] warn_slowpath_common+0x7f/0xc0
May 27 16:32:30 hover1 kernel: [ 1907.804676]  [<ffffffff81060206>] warn_slowpath_fmt+0x46/0x50
May 27 16:32:30 hover1 kernel: [ 1907.804679]  [<ffffffff8163f7f5>] ? tcp_recvmsg+0x35/0xc90
May 27 16:32:30 hover1 kernel: [ 1907.804681]  [<ffffffff816402f6>] tcp_recvmsg+0xb36/0xc90
May 27 16:32:30 hover1 kernel: [ 1907.804685]  [<ffffffff8166ac10>] ? inet_sendmsg+0x230/0x230
May 27 16:32:30 hover1 kernel: [ 1907.804687]  [<ffffffff8166ad47>] inet_recvmsg+0x137/0x250
May 27 16:32:30 hover1 kernel: [ 1907.804691]  [<ffffffff815d8288>] ? sock_update_classid+0x128/0x310
May 27 16:32:30 hover1 kernel: [ 1907.804693]  [<ffffffff815d04ed>] sock_recvmsg+0x11d/0x140
May 27 16:32:30 hover1 kernel: [ 1907.804697]  [<ffffffff811d85ff>] ? file_update_time+0xdf/0x140
May 27 16:32:30 hover1 kernel: [ 1907.804701]  [<ffffffff811bdcb8>] ? fget_light+0x48/0x4f0
May 27 16:32:30 hover1 kernel: [ 1907.804703]  [<ffffffff811bdd76>] ? fget_light+0x106/0x4f0
May 27 16:32:30 hover1 kernel: [ 1907.804705]  [<ffffffff811bdcb8>] ? fget_light+0x48/0x4f0
May 27 16:32:30 hover1 kernel: [ 1907.804708]  [<ffffffff815d3941>] sys_recvfrom+0xf1/0x170
May 27 16:32:30 hover1 kernel: [ 1907.804712]  [<ffffffff810f6ddc>] ? __audit_syscall_entry+0xcc/0x310
May 27 16:32:30 hover1 kernel: [ 1907.804715]  [<ffffffff8132dfce>] ? trace_hardirqs_on_thunk+0x3a/0x3f
May 27 16:32:30 hover1 kernel: [ 1907.804719]  [<ffffffff8174cc69>] system_call_fastpath+0x16/0x1b
May 27 16:32:30 hover1 kernel: [ 1907.804720] ---[ end trace 4797381fbdf33b5d ]---

Thanks,

Jack
