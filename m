From: Jack Stone <jwjstone@fastmail.fm>
Subject: WARNING: at net/ipv4/tcp.c:1610 tcp_recvmsg+0xb1b/0xc70()
Date: Fri, 25 May 2012 21:25:48 +0100
Message-ID: <4FBFEACC.8040601@fastmail.fm>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
To: davem@davemloft.net, netdev@vger.kernel.org,
	Linux Kernel <linux-kernel@vger.kernel.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi All,

The following warning keeps hitting me. I couldn't get the first one - it had already left dmesg hence the W taint.
The C taint is from r8712u from staging.

I've seen it with 3.4.0-076444-g07acfc2 (recent Linus tree) and 3.4.0-rc3-00089-gc6f5c93.

I am going to attempt to bisect it now.

[ 3896.037489] ------------[ cut here ]------------
[ 3896.037490] WARNING: at net/ipv4/tcp.c:1610 tcp_recvmsg+0xb1b/0xc70()
[ 3896.037491] Hardware name: System Product Name
[ 3896.037491] recvmsg bug 2: copied 3F1199D7 seq 3F1199D7 rcvnxt 3F119A71 fl 0
[ 3896.037511] Modules linked in: fuse ebtable_nat ebtables ipt_MASQUERADE iptable_nat nf_nat xt_CHECKSUM iptable_mangle bridge rfcomm lockd 8021q garp stp llc bnep nf_conntrack_netbios_ns nf_conntrack_broadcast ip6t_REJECT nf_conntrack_ipv4 nf_conntrack_ipv6 nf_defrag_ipv6 nf_defrag_ipv4 xt_state nf_conntrack ip6table_filter ip6_tables vhost_net snd_hda_codec_hdmi macvtap macvlan tun snd_hda_codec_realtek virtio_net btusb bluetooth coretemp kvm_intel kvm snd_hda_intel r8712u(C) snd_hda_codec snd_hwdep e1000e joydev snd_seq snd_seq_device snd_pcm snd_timer snd sunrpc eeepc_wmi asus_wmi hid_logitech_dj sparse_keymap mxm_wmi soundcore iTCO_wdt rfkill snd_page_alloc wmi i2c_i801 pcspkr iTCO_vendor_support serio_raw binfmt_misc uinput microcode crc32c_intel ghash_clmulni_intel firewire_ohci fi
 rewire_core crc_itu_t [last unloaded: scsi_wait_scan]
[ 3896.037512] Pid: 3926, comm: spotify Tainted: G        WC   3.4.0-07644-g07acfc2 #2
[ 3896.037513] Call Trace:
[ 3896.037514]  [<ffffffff8106010f>] warn_slowpath_common+0x7f/0xc0
[ 3896.037515]  [<ffffffff81060206>] warn_slowpath_fmt+0x46/0x50
[ 3896.037517]  [<ffffffff8163f4c5>] ? tcp_recvmsg+0x35/0xc70
[ 3896.037518]  [<ffffffff812c130f>] ? avc_has_perm_flags+0xef/0x230
[ 3896.037519]  [<ffffffff812c125c>] ? avc_has_perm_flags+0x3c/0x230
[ 3896.037520]  [<ffffffff8163ffab>] tcp_recvmsg+0xb1b/0xc70
[ 3896.037522]  [<ffffffff8166a8c0>] ? inet_sendmsg+0x230/0x230
[ 3896.037523]  [<ffffffff8166a9f7>] inet_recvmsg+0x137/0x250
[ 3896.037525]  [<ffffffff815d7f58>] ? sock_update_classid+0x128/0x310
[ 3896.037526]  [<ffffffff815cfe40>] do_sock_read+0xf0/0x110
[ 3896.037527]  [<ffffffff815d0b8c>] sock_aio_read.part.5+0x4c/0x70
[ 3896.037528]  [<ffffffff812c130f>] ? avc_has_perm_flags+0xef/0x230
[ 3896.037530]  [<ffffffff815d0bb0>] ? sock_aio_read.part.5+0x70/0x70
[ 3896.037531]  [<ffffffff815d0bdd>] sock_aio_read+0x2d/0x40
[ 3896.037532]  [<ffffffff811bc2b3>] do_sync_readv_writev+0xd3/0x110
[ 3896.037534]  [<ffffffff812beca6>] ? security_file_permission+0x96/0xb0
[ 3896.037535]  [<ffffffff811bb9a1>] ? rw_verify_area+0x61/0x100
[ 3896.037537]  [<ffffffff811bc584>] do_readv_writev+0xd4/0x1d0
[ 3896.037538]  [<ffffffff811bdad8>] ? fget_light+0x48/0x4f0
[ 3896.037540]  [<ffffffff811bdad8>] ? fget_light+0x48/0x4f0
[ 3896.037541]  [<ffffffff811bc71c>] vfs_readv+0x3c/0x50
[ 3896.037543]  [<ffffffff811bc77d>] sys_readv+0x4d/0xc0
[ 3896.037544]  [<ffffffff8174c829>] system_call_fastpath+0x16/0x1b
[ 3896.037545] ---[ end trace 762b4689c56af7ab ]---

The relevant code from tcp.c is:

		/* Next get a buffer. */

                skb_queue_walk(&sk->sk_receive_queue, skb) {
                        /* Now that we have two receive queues this
                         * shouldn't happen.
                         */
                        if (WARN(before(*seq, TCP_SKB_CB(skb)->seq),
                                 "recvmsg bug: copied %X seq %X rcvnxt %X fl %X\n",
                                 *seq, TCP_SKB_CB(skb)->seq, tp->rcv_nxt,
                                 flags))
                                break;

                        offset = *seq - TCP_SKB_CB(skb)->seq;
                        if (tcp_hdr(skb)->syn)
                                offset--;
                        if (offset < skb->len)
                                goto found_ok_skb;
                        if (tcp_hdr(skb)->fin)
                                goto found_fin_ok;
This warn here ----->        WARN(!(flags & MSG_PEEK),
                             "recvmsg bug 2: copied %X seq %X rcvnxt %X fl %X\n",
                             *seq, TCP_SKB_CB(skb)->seq, tp->rcv_nxt, flags);
                }

Thanks,

Jack
