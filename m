From: Tom London <selinux@gmail.com>
Subject: Re: return of ip_rt_bug()
Date: Thu, 4 Aug 2011 06:14:22 -0700
Message-ID: <CAFiZG+X0oyTOXqm4b0g_UEGYK_0JCW3=WOR5d_7GfbJrTMhMzg@mail.gmail.com>
References: <20110802170942.GA17164@redhat.com>
	<alpine.LFD.2.00.1108041422510.1495@ja.ssi.bg>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Dave Jones <davej@redhat.com>, netdev@vger.kernel.org
To: Julian Anastasov <ja@ssi.bg>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qy0-f181.google.com ([209.85.216.181]:54229 "EHLO
	mail-qy0-f181.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753118Ab1HDNOY convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 4 Aug 2011 09:14:24 -0400
Received: by qyk15 with SMTP id 15so942710qyk.19
        for <netdev@vger.kernel.org>; Thu, 04 Aug 2011 06:14:23 -0700 (PDT)
In-Reply-To: <alpine.LFD.2.00.1108041422510.1495@ja.ssi.bg>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Aug 4, 2011 at 5:20 AM, Julian Anastasov <ja@ssi.bg> wrote:
>
> =A0 =A0 =A0 =A0Hello,
>
> On Tue, 2 Aug 2011, Dave Jones wrote:
>
>> Tom (CC'd) has been hitting that ip_rt_bug() WARN_ON() since 3.0rc
>>
>> Here's the latest report.
>>
>> ------------[ cut here]------------
>> WARNING: atnet/ipv4/route.c:1714 ip_rt_bug+0x5c/0x62()
>> Hardware name: 74585FU
>> Modules linked in: fuse
>> ip6table_filter ip6_tables ebtable_nat ebtables ppdev parport_pc lp =
parport
>> ipt_MASQUERADE iptable_nat nf_nat nf_conntrack_ipv4 nf_defrag_ipv4 x=
t_state
>> nf_conntrack xt_CHECKSUM iptable_mangle tun bridge stp llc sunrpc rf=
comm bnep
>> usblp arc4 uvcvideo videodev media snd_usb_audio snd_usbmidi_lib snd=
_rawmidi
>> v4l2_compat_ioctl32 iwlagn microcode i2c_i801 btusb iTCO_wdt
>> iTCO_vendor_support mac80211 bluetooth snd_hda_codec_conexant cfg802=
11
>> thinkpad_acpi snd_hda_intel snd_hda_codec rfkill snd_hwdep snd_seq
>> snd_seq_device snd_pcm snd_timer snd soundcore snd_page_alloc e1000e=
 virtio_net
>> kvm_intel kvm uinput wmi i915 drm_kms_helper drm i2c_algo_bit i2c_co=
re video[last unloaded: scsi_wait_scan]
>> Pid: 5492, comm: xsane Not tainted 3.1.0-0.rc0.git12.1.fc17.x86_64 #=
1
>> Call Trace:
>> =A0[<ffffffff8105c5ec>] warn_slowpath_common+0x83/0x9b
>> =A0[<ffffffff8105c61e>] warn_slowpath_null+0x1a/0x1c
>> =A0[<ffffffff8142f485>] ip_rt_bug+0x5c/0x62
>> =A0[<ffffffff81437091>] dst_output+0x19/0x1d
>> =A0[<ffffffff814387c0>] ip_local_out+0x20/0x25
>> =A0[<ffffffff81439695>] ip_send_skb+0x19/0x3e
>> =A0[<ffffffff81455ea2>] udp_send_skb+0x239/0x29b
>> =A0[<ffffffff8145763f>] udp_sendmsg+0x5a1/0x7d4
>> =A0[<ffffffff813f67d5>] ? release_sock+0x35/0x155
>> =A0[<ffffffff8143718c>] ? ip_select_ident+0x3d/0x3d
>> =A0[<ffffffff81062703>] ? local_bh_enable_ip+0xe/0x10
>> =A0[<ffffffff814f1231>] ? _raw_spin_unlock_bh+0x40/0x44
>> =A0[<ffffffff813f68ec>] ? release_sock+0x14c/0x155
>> =A0[<ffffffff8145eb58>] inet_sendmsg+0x66/0x6f
>> =A0[<ffffffff813f1d92>] sock_sendmsg+0xe6/0x109
>> =A0[<ffffffff8108f1c8>] ? lock_acquire+0x10f/0x13e
>> =A0[<ffffffff8110dd34>] ? might_fault+0x5c/0xac
>> =A0[<ffffffff8108f08c>] ? lock_release+0x1a4/0x1d1
>> =A0[<ffffffff8110dd7d>] ? might_fault+0xa5/0xac
>> =A0[<ffffffff813f2ad7>] ? copy_from_user+0x2f/0x31
>> =A0[<ffffffff813f496d>] sys_sendto+0x132/0x174
>> =A0[<ffffffff8124ef6e>] ? trace_hardirqs_on_thunk+0x3a/0x3f
>> =A0[<ffffffff814f80c2>] system_call_fastpath+0x16/0x1b
>> ---[ end trace 0e82aef47f8d8552 ]---
>> ------------[ cut here ]------------
>>
>> all the traces he's hit so far seem to be caused by udp, and they al=
l seem to be
>> going from 192.168.2.5 -> 255.255.255.255
>>
>> https://bugzilla.redhat.com/show_bug.cgi?id=3D712632 is his full rep=
ort with similar traces.
>
> =A0 =A0 =A0 =A0Tom, what kind of netfilter rules do you have in
> LOCAL_OUT/OUTPUT hooks? We eliminated one ip_route_input call
> from net/ipv4/netfilter.c (ip_route_me_harder) but it looks like
> in your kernel ip_route_input is called again from this hook.
> It is interesting why only broadcasts get such input route.
>
> =A0 =A0 =A0 =A0I assume 192.168.2.5 is an existing local address that
> is present during the test? Any additional modules that use
> ip_route_input ? Are nf_queue, IPVS, br_netfilter or tproxy used?
>
> Regards
>
> --
> Julian Anastasov <ja@ssi.bg>
>

Here is what 'route' says:

[root@tlondon ~]# route
Kernel IP routing table
Destination     Gateway         Genmask         Flags Metric Ref    Use=
 Iface
default         tlondon         0.0.0.0         UG    0      0        0=
 eth0
192.168.2.0     *               255.255.255.0   U     1      0        0=
 eth0
192.168.122.0   *               255.255.255.0   U     0      0        0=
 virbr0
[root@tlondon ~]#

and 'ifconfig':

eth0      Link encap:Ethernet  HWaddr 00:1F:16:0B:56:A8
          inet addr:192.168.2.6  Bcast:192.168.2.255  Mask:255.255.255.=
0
          inet6 addr: fe80::21f:16ff:fe0b:56a8/64 Scope:Link
          UP BROADCAST RUNNING MULTICAST  MTU:1500  Metric:1
          RX packets:4269 errors:0 dropped:0 overruns:0 frame:0
          TX packets:3503 errors:0 dropped:0 overruns:0 carrier:0
          collisions:0 txqueuelen:1000
          RX bytes:3948798 (3.7 MiB)  TX bytes:517347 (505.2 KiB)
          Interrupt:20 Memory:f2600000-f2620000

Here is what is in /etc/sysconfig/iptables:

[root@tlondon sysconfig]# cat iptables
# Generated by iptables-save v1.4.9 on Mon Jan 17 06:36:35 2011
*security
:INPUT ACCEPT [0:0]
:FORWARD ACCEPT [0:0]
:OUTPUT ACCEPT [0:0]
:DNS - [0:0]
:INTERNET - [0:0]
:INTRANET - [0:0]
-A INPUT -m state --state RELATED,ESTABLISHED -j CONNSECMARK --restore
-A INPUT -s 255.255.255.255/32 -j INTRANET
-A INPUT -s 127.0.0.0/8 -j INTRANET
-A INPUT -s 10.0.0.0/8 -j INTRANET
-A INPUT -s 172.16.0.0/16 -j INTRANET
-A INPUT -s 224.0.0.0/24 -j INTRANET
-A INPUT -s 192.168.0.0/16 -j INTRANET
-A INPUT -j INTERNET
-A OUTPUT -m state --state RELATED,ESTABLISHED -j CONNSECMARK --restore
-A OUTPUT -d 255.255.255.255/32 -j INTRANET
-A OUTPUT -d 127.0.0.0/8 -j INTRANET
-A OUTPUT -d 10.0.0.0/8 -j INTRANET
-A OUTPUT -d 172.16.0.0/16 -j INTRANET
-A OUTPUT -d 224.0.0.0/24 -j INTRANET
-A OUTPUT -d 192.168.0.0/16 -j INTRANET
-A OUTPUT -p udp -m udp --dport 53 -j DNS
-A OUTPUT -p tcp -m tcp --dport 53 -j DNS
-A OUTPUT -j INTERNET
-A DNS -j SECMARK --selctx system_u:object_r:dns_internet_packet_t:s0
-A DNS -j CONNSECMARK --save
-A DNS -j ACCEPT
-A INTERNET -j SECMARK --selctx system_u:object_r:internet_packet_t:s0
-A INTERNET -j CONNSECMARK --save
-A INTERNET -j ACCEPT
-A INTRANET -j SECMARK --selctx system_u:object_r:intranet_packet_t:s0
-A INTRANET -j CONNSECMARK --save
-A INTRANET -j ACCEPT
COMMIT
# Completed on Mon Jan 17 06:36:35 2011
# Generated by iptables-save v1.4.9 on Mon Jan 17 06:36:35 2011
*nat
:PREROUTING ACCEPT [35:3434]
:INPUT ACCEPT [0:0]
:OUTPUT ACCEPT [812:64159]
:POSTROUTING ACCEPT [810:63177]
-A POSTROUTING -s 192.168.122.0/24 ! -d 192.168.122.0/24 -p tcp -j
MASQUERADE --to-ports 1024-65535
-A POSTROUTING -s 192.168.122.0/24 ! -d 192.168.122.0/24 -p udp -j
MASQUERADE --to-ports 1024-65535
-A POSTROUTING -s 192.168.122.0/24 ! -d 192.168.122.0/24 -j MASQUERADE
COMMIT
# Completed on Mon Jan 17 06:36:35 2011
# Generated by iptables-save v1.4.9 on Mon Jan 17 06:36:35 2011
*mangle
:PREROUTING ACCEPT [83178:89234503]
:INPUT ACCEPT [83176:89234439]
:FORWARD ACCEPT [0:0]
:OUTPUT ACCEPT [52780:3860973]
:POSTROUTING ACCEPT [52919:3899453]
-A POSTROUTING -o virbr0 -p udp -m udp --dport 68 -j CHECKSUM --checksu=
m-fill
COMMIT
# Completed on Mon Jan 17 06:36:35 2011
# Generated by iptables-save v1.4.9 on Mon Jan 17 06:36:35 2011
*filter
:INPUT ACCEPT [0:0]
:FORWARD ACCEPT [0:0]
:OUTPUT ACCEPT [52780:3860973]
-A INPUT -i virbr0 -p udp -m udp --dport 53 -j ACCEPT
-A INPUT -i virbr0 -p tcp -m tcp --dport 53 -j ACCEPT
-A INPUT -i virbr0 -p udp -m udp --dport 67 -j ACCEPT
-A INPUT -i virbr0 -p tcp -m tcp --dport 67 -j ACCEPT
-A INPUT -m state --state RELATED,ESTABLISHED -j ACCEPT
-A INPUT -p icmp -j ACCEPT
-A INPUT -i lo -j ACCEPT
-A INPUT -p tcp -m state --state NEW -m tcp --dport 22 -j ACCEPT
-A INPUT -p tcp -m state --state NEW -m tcp --dport 631 -j ACCEPT
-A INPUT -p udp -m state --state NEW -m udp --dport 631 -j ACCEPT
-A INPUT -j REJECT --reject-with icmp-host-prohibited
-A FORWARD -d 192.168.122.0/24 -o virbr0 -m state --state
RELATED,ESTABLISHED -j ACCEPT
-A FORWARD -s 192.168.122.0/24 -i virbr0 -j ACCEPT
-A FORWARD -i virbr0 -o virbr0 -j ACCEPT
-A FORWARD -o virbr0 -j REJECT --reject-with icmp-port-unreachable
-A FORWARD -i virbr0 -j REJECT --reject-with icmp-port-unreachable
-A FORWARD -m physdev --physdev-is-bridged -j ACCEPT
-A FORWARD -j REJECT --reject-with icmp-host-prohibited
COMMIT
# Completed on Mon Jan 17 06:36:35 2011
[root@tlondon sysconfig]#

and here is what 'iptables -L' says:

[root@tlondon ~]# iptables -L
Chain INPUT (policy ACCEPT)
target     prot opt source               destination
ACCEPT     udp  --  anywhere             anywhere             udp dpt:d=
omain
ACCEPT     tcp  --  anywhere             anywhere             tcp dpt:d=
omain
ACCEPT     udp  --  anywhere             anywhere             udp dpt:b=
ootps
ACCEPT     tcp  --  anywhere             anywhere             tcp dpt:b=
ootps

Chain FORWARD (policy ACCEPT)
target     prot opt source               destination
ACCEPT     all  --  anywhere             192.168.122.0/24     state
RELATED,ESTABLISHED
ACCEPT     all  --  192.168.122.0/24     anywhere
ACCEPT     all  --  anywhere             anywhere
REJECT     all  --  anywhere             anywhere
reject-with icmp-port-unreachable
REJECT     all  --  anywhere             anywhere
reject-with icmp-port-unreachable

Chain OUTPUT (policy ACCEPT)
target     prot opt source               destination
[root@tlondon ~]#

Regarding additional modules, I believe I'm running a 'stock' Fedora
Rawhide system.  Here is what 'lsmod' says:

[root@tlondon ~]# lsmod
Module                  Size  Used by
fuse                   70196  3
ip6table_filter        12815  0
ip6_tables             23088  1 ip6table_filter
ebtable_nat            12807  0
ebtables               27075  1 ebtable_nat
ipt_MASQUERADE         12880  3
iptable_nat            13383  1
nf_nat                 25795  2 ipt_MASQUERADE,iptable_nat
nf_conntrack_ipv4      14700  4 iptable_nat,nf_nat
nf_defrag_ipv4         12673  1 nf_conntrack_ipv4
xt_state               12578  1
nf_conntrack           81778  5
ipt_MASQUERADE,iptable_nat,nf_nat,nf_conntrack_ipv4,xt_state
ppdev                  13616  0
parport_pc             24112  0
xt_CHECKSUM            12549  1
lp                     22009  0
iptable_mangle         12695  1
parport                40823  3 ppdev,parport_pc,lp
tun                    19023  1
bridge                 85889  0
stp                    12946  1 bridge
llc                    14197  2 bridge,stp
rfcomm                 65661  4
bnep                   19857  2
usblp                  18206  0
arc4                   12529  2
uvcvideo               63617  0
videodev               85806  1 uvcvideo
media                  20522  2 uvcvideo,videodev
snd_usb_audio         108696  1
v4l2_compat_ioctl32    16677  1 videodev
snd_usbmidi_lib        24835  1 snd_usb_audio
snd_rawmidi            25641  1 snd_usbmidi_lib
snd_hda_codec_conexant    62115  1
snd_hda_intel          28992  3
iwlagn                370621  0
snd_hda_codec          91636  2 snd_hda_codec_conexant,snd_hda_intel
snd_hwdep              13595  2 snd_usb_audio,snd_hda_codec
snd_seq                57219  0
snd_seq_device         14173  2 snd_rawmidi,snd_seq
mac80211              282558  1 iwlagn
btusb                  20161  2
microcode              31412  0
i2c_i801               17765  0
snd_pcm                85340  4 snd_usb_audio,snd_hda_intel,snd_hda_cod=
ec
iTCO_wdt               17808  0
iTCO_vendor_support    13474  1 iTCO_wdt
cfg80211              161253  2 iwlagn,mac80211
bluetooth             215033  23 rfcomm,bnep,btusb
snd_timer              29131  2 snd_seq,snd_pcm
snd_page_alloc         14039  2 snd_hda_intel,snd_pcm
thinkpad_acpi          71386  0
rfkill                 21648  4 cfg80211,bluetooth,thinkpad_acpi
snd                    70856  19
snd_usb_audio,snd_usbmidi_lib,snd_rawmidi,snd_hda_codec_conexant,snd_hd=
a_intel,snd_hda_codec,snd_hwdep,snd_seq,snd_seq_device,snd_pcm,snd_time=
r,thinkpad_acpi
soundcore              14562  1 snd
e1000e                182622  0
virtio_net             19157  0
kvm_intel             125225  0
kvm                   348016  1 kvm_intel
uinput                 17722  0
wmi                    18697  0
i915                  403560  3
drm_kms_helper         36330  1 i915
drm                   201826  4 i915,drm_kms_helper
i2c_algo_bit           13246  1 i915
i2c_core               34077  6
videodev,i2c_i801,i915,drm_kms_helper,drm,i2c_algo_bit
video                  19174  1 i915
[root@tlondon ~]#

How else can I help?

tom
--=20
Tom London
