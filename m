From: Eric Dumazet <edumazet@google.com>
Subject: Re: c21b48 causes nfs client to hang and kernel BUG at
 ./include/linux/mm.h:432 (bisected)
Date: Mon, 24 Jul 2017 03:25:57 -0700
Message-ID: <CANn89iLQ6CiTCSQcvoPRvodzt4cSBkSfH+YGJuspoL0=vZG8kg@mail.gmail.com>
References: <20170723123504.GA4312@pog.tecnopolis.ca>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable
Cc: David Miller <davem@davemloft.net>,
        Andrey Konovalov <andreyknvl@google.com>,
        Willem de Bruijn <willemb@google.com>,
        netdev <netdev@vger.kernel.org>
To: Trevor Cordes <trevor@tecnopolis.ca>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-yw0-f173.google.com ([209.85.161.173]:35172 "EHLO
        mail-yw0-f173.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753161AbdGXKZ6 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 24 Jul 2017 06:25:58 -0400
Received: by mail-yw0-f173.google.com with SMTP id h189so20416256ywf.2
        for <netdev@vger.kernel.org>; Mon, 24 Jul 2017 03:25:58 -0700 (PDT)
In-Reply-To: <20170723123504.GA4312@pog.tecnopolis.ca>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, Jul 23, 2017 at 5:35 AM, Trevor Cordes <trevor@tecnopolis.ca> wrote=
:
> Hi!  I've bisected a bug I'm seeing to:
> c21b48cc1bbf2f5af3ef54ada559f7fadf8b508b
> net: adjust skb->truesize in ___pskb_trim()
>
> The bug manifests as my NFS4 (TCP) client mount hanging after 5-10s of
> heavy read data transfer, which also produces: kernel BUG at
> ./include/linux/mm.h:462 (see full trace at bottom)
>
> I must reboot to regain nfs access.  I can make this bug occur on demand
> by just playing some video from the nfs export and skipping around for
> 5-10s or so.
>
> Every 10 or so times this bug occurs the entire system hard freezes and
> even magic SysRq won't work.
>
> This bug started for me in Fedora 24 as soon as 4.11.x was put out.  F24
> 4.10.x does not have this bug, and that is what I am currently using. I a=
m
> currently taking the final step of rpmbuilding the F24 src rpm with a
> patch to undo c21b48, just to confirm it for sure.  But it will take all
> day to build, so I thought I'd report my bisect right now.
>
> I've had a RHBZ up for this:
> https://bugzilla.redhat.com/show_bug.cgi?id=3D1455086
>
> That BZ has some info as to my mount/export options.  My setup *must* be
> different from normal as I see no other person on the net reporting this
> bug.  My mount options might be a little tweaked, I guess; also FYI, this
> box uses a strict iptables setup, if that could matter.  I also use NFS4
> only, with TCP, and strictly-preset ports to be more iptables friendly.
>
> Thanks!
>
> Complete bug trace below (have dozens of these from tests if more are
> needed, but stack trace is the same *every* time):
>
> Jul 23 05:34:14 pog kernel: [  118.789187] page:fffff662c8761a00 count:0 =
mapcount:0 mapping:          (null) index:0x0
> Jul 23 05:34:14 pog kernel: [  118.789196] flags: 0x17ffffc0000000()
> Jul 23 05:34:14 pog kernel: [  118.789201] raw: 0017ffffc0000000 00000000=
00000000 0000000000000000 00000000ffffffff
> Jul 23 05:34:14 pog kernel: [  118.789204] raw: dead000000000100 dead0000=
00000200 0000000000000000 0000000000000000
> Jul 23 05:34:14 pog kernel: [  118.789206] page dumped because: VM_BUG_ON=
_PAGE(page_ref_count(page) =3D=3D 0)
> Jul 23 05:34:14 pog kernel: [  118.789218] ------------[ cut here ]------=
------
> Jul 23 05:34:14 pog kernel: [  118.789221] kernel BUG at ./include/linux/=
mm.h:462!
> Jul 23 05:34:14 pog kernel: [  118.789224] invalid opcode: 0000 [#1] SMP
> Jul 23 05:34:14 pog kernel: [  118.789226] Modules linked in: rpcsec_gss_=
krb5 nfsv4 xfrm4_tunnel tunnel4 ipcomp xfrm_ipcomp esp4 ah4 dns_resolver af=
_key nfs fscache 8021q garp mrp stp llc cfg80211 rfkill nf_nat_pptp nf_nat_=
proto_gre nf_conntrack_pptp nf_conntrack_proto_gre nf_conntrack_netbios_ns =
nf_conntrack_broadcast xt_mac nf_log_ipv4 nf_log_common xt_LOG xt_limit xt_=
conntrack xt_nat ipt_MASQUERADE nf_nat_masquerade_ipv4 xt_REDIRECT nf_nat_r=
edirect iptable_nat nf_conntrack_ipv4
> nf_defrag_ipv4 ip6t_REJECT nf_reject_ipv6 ip6table_filter ip6_tables asc7=
621 nf_nat_ipv4 nf_nat nf_conntrack libcrc32c xt_TCPMSS iptable_mangle ipta=
ble_raw iptable_security snd_hda_codec_hdmi snd_hda_codec_idt snd_hda_codec=
_generic snd_hda_intel snd_hda_codec coretemp ppdev iTCO_wdt gpio_ich iTCO_=
vendor_support snd_hda_core kvm_intel snd_hwdep kvm snd_seq
> Jul 23 05:34:14 pog kernel: [  118.789288]  snd_seq_device irqbypass joyd=
ev snd_pcm nfsd pcspkr snd_timer i2c_i801 snd parport_pc acpi_cpufreq tpm_t=
is parport shpchp tpm_tis_core soundcore lpc_ich tpm auth_rpcgss nfs_acl lo=
ckd grace sunrpc raid1 raid0 firewire_ohci serio_raw firewire_core ata_gene=
ric pata_acpi crc_itu_t aic7xxx e1000e e1000 scsi_transport_spi ptp pps_cor=
e pata_marvell floppy
> Jul 23 05:34:14 pog kernel: [  118.789327] CPU: 2 PID: 541 Comm: kworker/=
2:1H Not tainted 4.11.0-rc8+ #13
> Jul 23 05:34:14 pog kernel: [  118.789330] Hardware name:                =
  /D975XBX2, BIOS BX97520J.86A.2838.2008.0903.1859 09/03/2008
> Jul 23 05:34:14 pog kernel: [  118.789362] Workqueue: xprtiod xs_tcp_data=
_receive_workfn [sunrpc]
> Jul 23 05:34:14 pog kernel: [  118.789366] task: ffff8d2919184880 task.st=
ack: ffffb168813a8000
> Jul 23 05:34:14 pog kernel: [  118.789372] RIP: 0010:page_frag_free+0x6d/=
0x80
> Jul 23 05:34:14 pog kernel: [  118.789375] RSP: 0018:ffffb168813abd10 EFL=
AGS: 00010246
> Jul 23 05:34:14 pog kernel: [  118.789378] RAX: 000000000000003e RBX: fff=
ff662c88c6d80 RCX: 0000000000000006
> Jul 23 05:34:14 pog kernel: [  118.789380] RDX: 0000000000000000 RSI: 000=
0000000000000 RDI: ffff8d292fd0e0a0
> Jul 23 05:34:14 pog kernel: [  118.789383] RBP: ffffb168813abd10 R08: 000=
00000000c0ad6 R09: 00000000000003f4
> Jul 23 05:34:14 pog kernel: [  118.789385] R10: ffff8d291a556d00 R11: fff=
fffffb222ac2d R12: ffff8d291a556d00
> Jul 23 05:34:14 pog kernel: [  118.789388] R13: 0000000000000008 R14: fff=
f8d291d868340 R15: 0000000000002d40
> Jul 23 05:34:14 pog kernel: [  118.789391] FS:  0000000000000000(0000) GS=
:ffff8d292fd00000(0000) knlGS:0000000000000000
> Jul 23 05:34:14 pog kernel: [  118.789394] CS:  0010 DS: 0000 ES: 0000 CR=
0: 0000000080050033
> Jul 23 05:34:14 pog kernel: [  118.789396] CR2: 00007f7597990008 CR3: 000=
000021e710000 CR4: 00000000000006e0
> Jul 23 05:34:14 pog kernel: [  118.789399] Call Trace:
> Jul 23 05:34:14 pog kernel: [  118.789406]  skb_free_head+0x28/0x30
> Jul 23 05:34:14 pog kernel: [  118.789410]  skb_release_data+0xf5/0x130
> Jul 23 05:34:14 pog kernel: [  118.789413]  skb_release_all+0x24/0x30
> Jul 23 05:34:14 pog kernel: [  118.789415]  __kfree_skb+0x12/0x20
> Jul 23 05:34:14 pog kernel: [  118.789420]  tcp_read_sock+0x11a/0x1e0
> Jul 23 05:34:14 pog kernel: [  118.789437]  ? xs_tcp_setup_socket+0x400/0=
x400 [sunrpc]
> Jul 23 05:34:14 pog kernel: [  118.789453]  ? xs_tcp_setup_socket+0x400/0=
x400 [sunrpc]
> Jul 23 05:34:14 pog kernel: [  118.789470]  xs_tcp_data_receive_workfn+0x=
bb/0x160 [sunrpc]
> Jul 23 05:34:14 pog kernel: [  118.789474]  process_one_work+0x197/0x450
> Jul 23 05:34:14 pog kernel: [  118.789478]  worker_thread+0x4e/0x4a0
> Jul 23 05:34:14 pog kernel: [  118.789482]  kthread+0x109/0x140
> Jul 23 05:34:14 pog kernel: [  118.789485]  ? process_one_work+0x450/0x45=
0
> Jul 23 05:34:14 pog kernel: [  118.789488]  ? kthread_park+0x90/0x90
> Jul 23 05:34:14 pog kernel: [  118.789492]  ret_from_fork+0x2c/0x40
> Jul 23 05:34:14 pog kernel: [  118.789494] Code: 47 1c 85 c0 74 19 f0 ff =
4f 1c 74 02 5d c3 48 8b 07 31 f6 f6 c4 80 75 15 e8 41 fb ff ff 5d c3 48 c7 =
c6 40 0e c4 b1 e8 83 07 03 00 <0f> 0b 8b 77 6c eb e6 48 8b 05 15 e2 c3 00 e=
b a4 0f 1f 00 66 66
> Jul 23 05:34:14 pog kernel: [  118.789542] RIP: page_frag_free+0x6d/0x80 =
RSP: ffffb168813abd10
> Jul 23 05:34:14 pog kernel: [  118.789620] ---[ end trace 7be02f8b337d1e8=
0 ]---
> Jul 23 05:34:19 pog kernel: [  123.294692] nfs: server 192.168.100.2 not =
responding, still trying
>

Hi Trevor, thanks for the report and bisection !

This commit exposed at least one bug, have you tried the following fix :

e44699d2c28067f69698ccb68dd3ddeacfebc434 ("net: handle
NAPI_GRO_FREE_STOLEN_HEAD case also in napi_frags_finish()")

If this commit does not help, please provide what kind of NIC you are using=
.

Thanks.
