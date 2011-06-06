From: Alexander Holler <holler@ahsoftware.de>
Subject: Re: bridge/netfilter: regression in 2.6.39.1
Date: Mon, 06 Jun 2011 14:49:04 +0200
Message-ID: <4DECCCC0.70905@ahsoftware.de>
References: <4DE93422.3070000@ahsoftware.de>	 <20110606111507.GA1000@hmsreliant.think-freely.org>	 <4DECBEA3.6070408@ahsoftware.de> <1307362358.3098.6.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Neil Horman <nhorman@tuxdriver.com>, linux-kernel@vger.kernel.org,
	David Miller <davem@davemloft.net>,
	Herbert Xu <herbert@gondor.apana.org.au>,
	netdev@vger.kernel.org
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1307362358.3098.6.camel@edumazet-laptop>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Am 06.06.2011 14:12, schrieb Eric Dumazet:
> Le lundi 06 juin 2011 =C3=A0 13:48 +0200, Alexander Holler a =C3=A9cr=
it :
>> Am 06.06.2011 13:15, schrieb Neil Horman:
>>> On Fri, Jun 03, 2011 at 09:21:06PM +0200, Alexander Holler wrote:
>>>> Hello,
>>>>
>>>> I'm getting a oops in the bridge code in br_change_mtu() with
>>>> 2.6.39.1. The patch below seems to fix that.
>>>>
>>>> I'm not sure about the usage of dst_cow_metrics_generic() in
>>>> fake_dst_ops, but after having a quick look at it seems to be ok t=
o
>>>> use that here.
>>>>
>>>> Regards,
>>>>
>>>> Alexander
>>>>
>>> How did the flags of the dst entry on which we're callnig dst_entry=
_write_ptr
>>> wind up getting the  READ_ONLY flag set on it?  I don't see how we'=
er falling
>>> into that clause in which we call cow_metrics when we call dst_metr=
ic_set.  It
>>> seems like that flag is set erroneously.  perhaps we should just up=
date
>>> fake_rtable.dst to have the correct flags?
>>> Neil
>>
>> It is set by that change:
>>
>> --------
>> @@ -124,7 +128,7 @@ void br_netfilter_rtable_init(struct net_bridge =
*br)
>>    	atomic_set(&rt->dst.__refcnt, 1);
>>    	rt->dst.dev =3D br->dev;
>>    	rt->dst.path =3D&rt->dst;
>> -	dst_metric_set(&rt->dst, RTAX_MTU, 1500);
>> +	dst_init_metrics(&rt->dst, br_dst_default_metrics, true);
>>    	rt->dst.flags	=3D DST_NOXFRM;
>>    	rt->dst.ops =3D&fake_dst_ops;
>>    }
>> --------
>>
>> The true in dst_init_metrics() is responsible for that flag.
>>
>
> You are aware this change fixed an oops ?

No, I'm not aware of this. I know almost nothing about what all that=20
stuff is doing. For me that change above just introduced an oops throug=
h=20
an immediate NULL pointer dereference in br_change_mtu().

> read_only in this context means : In case this must be written, we ma=
ke
> a COW first
> (allocate a piece of memory, copy the source in it before applying an=
y
> change)
>
> It would be nice you send us the stack trace, so that we can have a c=
lue
> of whats going on.

Here is the text as found in my first mail:
----
Commit 42923465fb8d025a2b5153f2e7ab1e6e1058bf00 does here what it
should prevent, it introduces NULL a dereference.

The above commit uses dst_init_metrics() which sets the metrics as
read only. As result br_change_mtu() dies in dst_metric_set()
which calls dst_metrics_write_ptr() which calls
dst->ops->cow_metrics() if the metrics are read only.

I don't have a system with 2.6.39.1 or 3.0-rcN ready which writes an=20
oops to somewhere else than the screen. Just set up a bridge and change=
=20
the MTU for the IF, that will trigger the oops.
----

Here is the oops:

----
[  136.546023] BUG: unable to handle kernel NULL pointer dereference at=
=20
   (null)
[  136.546038] IP: [<  (null)>]   (null)
[  136.546046] *pde =3D 00000000
[  136.546052] Oops: 0000 [#1] SMP
[  136.546059] last sysfs file: /sys/devices/virtual/net/mybridge/ueven=
t
[  136.546066] Modules linked in: sit tunnel4 tun iwlagn sch_sfq bridge=
=20
stp llc nfs lockd auth_rpcgss nfs_acl sunrpc ipt_LOG xt_recent xt_state=
=20
iptable_filter iptable_nat nf_nat nf_conntrack_ipv4 nf_defrag_ipv4=20
xt_addrtype xt_dscp xt_iprange xt_DSCP xt_set ip_set nfnetlink ip6t_LOG=
=20
xt_limit ip6table_filter xt_string xt_owner xt_multiport xt_hashlimit=20
xt_conntrack xt_NFQUEUE xt_mark xt_connmark nf_conntrack ip6_tables=20
snd_seq_oss snd_seq_midi_event snd_seq snd_seq_device snd_pcm_oss=20
snd_mixer_oss uinput ipv6 dm_mod nvidiafb fb_ddc i2c_algo_bit vgastate=20
nvidia(P) arc4 uvcvideo videodev ecb snd_hda_codec_realtek iwl4965=20
snd_hda_intel iwl_legacy snd_hda_codec uhci_hcd firewire_ohci mac80211=20
sdhci_pci snd_hwdep snd_pcm sdhci ehci_hcd intel_agp firewire_core=20
cfg80211 snd_timer asus_laptop snd e1000e usbcore sparse_keymap rfkill=20
tpm_infineon crc_itu_t intel_gtt mmc_core iTCO_wdt tpm_tis ata_piix=20
agpgart tpm video soundcore sg tpm_bios joydev snd_page_alloc [last=20
unloaded: microcode]
[  136.546235]
[  136.546243] Pid: 8415, comm: ip Tainted: P=20
2.6.39.1-00006-g40545b7 #103 ASUSTeK Computer Inc.         V1Sn=20
        /V1Sn
[  136.546256] EIP: 0060:[<00000000>] EFLAGS: 00010202 CPU: 0
[  136.546268] EIP is at 0x0
[  136.546273] EAX: f14a389c EBX: 000005d4 ECX: f80d32c0 EDX: f80d1da1
[  136.546279] ESI: f14a3000 EDI: f255bf10 EBP: f15c3b54 ESP: f15c3b48
[  136.546285]  DS: 007b ES: 007b FS: 00d8 GS: 0033 SS: 0068
[  136.546293] Process ip (pid: 8415, ti=3Df15c2000 task=3Df4741f80=20
task.ti=3Df15c2000)
[  136.546297] Stack:
[  136.546301]  f80c658f f14a3000 ffffffed f15c3b64 c12cb9c8 f80d1b80=20
ffffffa1 f15c3bbc
[  136.546315]  c12da347 c12d9c7d 00000000 f7670b00 00000000 f80d1b80=20
ffffffa6 f15c3be4
[  136.546329]  00000004 f14a3000 f255bf20 00000008 f15c3bbc c11d6cae=20
00000000 00000000
[  136.546343] Call Trace:
[  136.546359]  [<f80c658f>] ? br_change_mtu+0x5f/0x80 [bridge]
[  136.546372]  [<c12cb9c8>] dev_set_mtu+0x38/0x80
[  136.546381]  [<c12da347>] do_setlink+0x1a7/0x860
[  136.546390]  [<c12d9c7d>] ? rtnl_fill_ifinfo+0x9bd/0xc70
[  136.546400]  [<c11d6cae>] ? nla_parse+0x6e/0xb0
[  136.546409]  [<c12db931>] rtnl_newlink+0x361/0x510
[  136.546420]  [<c1023240>] ? vmalloc_sync_all+0x100/0x100
[  136.546429]  [<c1362762>] ? error_code+0x5a/0x60
[  136.546438]  [<c12db5d0>] ? rtnl_configure_link+0x80/0x80
[  136.546446]  [<c12db27a>] rtnetlink_rcv_msg+0xfa/0x210
[  136.546454]  [<c12db180>] ? __rtnl_unlock+0x20/0x20
[  136.546463]  [<c12ee0fe>] netlink_rcv_skb+0x8e/0xb0
[  136.546471]  [<c12daf1c>] rtnetlink_rcv+0x1c/0x30
[  136.546479]  [<c12edafa>] netlink_unicast+0x23a/0x280
[  136.546487]  [<c12ede6b>] netlink_sendmsg+0x26b/0x2f0
[  136.546497]  [<c12bb828>] sock_sendmsg+0xc8/0x100
[  136.546508]  [<c10adf61>] ? __alloc_pages_nodemask+0xe1/0x750
[  136.546517]  [<c11d0602>] ? _copy_from_user+0x42/0x60
[  136.546525]  [<c12c5e4c>] ? verify_iovec+0x4c/0xc0
[  136.546534]  [<c12bd805>] sys_sendmsg+0x1c5/0x200
[  136.546542]  [<c10c2150>] ? __do_fault+0x310/0x410
[  136.546549]  [<c10c2c46>] ? do_wp_page+0x1d6/0x6b0
[  136.546557]  [<c10c47d1>] ? handle_pte_fault+0xe1/0x720
[  136.546565]  [<c12bd1af>] ? sys_getsockname+0x7f/0x90
[  136.546574]  [<c10c4ec1>] ? handle_mm_fault+0xb1/0x180
[  136.546582]  [<c1023240>] ? vmalloc_sync_all+0x100/0x100
[  136.546589]  [<c10233b3>] ? do_page_fault+0x173/0x3d0
[  136.546596]  [<c12bd87b>] ? sys_recvmsg+0x3b/0x60
[  136.546605]  [<c12bdd83>] sys_socketcall+0x293/0x2d0
[  136.546614]  [<c13629d0>] sysenter_do_call+0x12/0x26
[  136.546619] Code:  Bad EIP value.
[  136.546627] EIP: [<00000000>] 0x0 SS:ESP 0068:f15c3b48
[  136.546645] CR2: 0000000000000000
[  136.546652] ---[ end trace 6909b560e78934fa ]---
----

And if you want the oops on your machine (uisng 2.6.39.1 or 3.0-rcN):

----
brctl addbr mybridge
ip link set mybridge mtu 1234
oops
----

Regards,

Alexander
