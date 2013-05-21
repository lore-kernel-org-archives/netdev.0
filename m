From: Pravin Shelar <pshelar@nicira.com>
Subject: Re: GRE+XFRM+GSO crashes
Date: Tue, 21 May 2013 15:32:35 -0700
Message-ID: <CALnjE+qOf2pxzP0-7s4AsSNDbG5M5s8bXFDqYoD-5NgmtKYixA@mail.gmail.com>
References: <20130520094127.546a2f3e@vostro>
	<CALnjE+qgOQUDm_gAuygpDE5VH23YS0i3QyQuCVPhgu15=jwXWw@mail.gmail.com>
	<20130521110132.37dc2665@vostro>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary=047d7b6783aca094fe04dd420656
Cc: netdev@vger.kernel.org
To: Timo Teras <timo.teras@iki.fi>
Return-path: <netdev-owner@vger.kernel.org>
Received: from na3sys009aog117.obsmtp.com ([74.125.149.242]:51322 "HELO
	na3sys009aog117.obsmtp.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with SMTP id S1751604Ab3EUWck (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 21 May 2013 18:32:40 -0400
Received: by mail-qe0-f51.google.com with SMTP id nd7so770473qeb.10
        for <netdev@vger.kernel.org>; Tue, 21 May 2013 15:32:35 -0700 (PDT)
In-Reply-To: <20130521110132.37dc2665@vostro>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

--047d7b6783aca094fe04dd420656
Content-Type: text/plain; charset=ISO-8859-1

On Tue, May 21, 2013 at 1:01 AM, Timo Teras <timo.teras@iki.fi> wrote:
> On Mon, 20 May 2013 10:58:03 -0700
> Pravin Shelar <pshelar@nicira.com> wrote:
>
>> On Sun, May 19, 2013 at 11:41 PM, Timo Teras <timo.teras@iki.fi>
>> wrote:
>> > Since upgrade from 3.8 to 3.9 I've started getting the below
>> > mentioned BUG crashes. One of the few relevant changes seems to be
>> > GSO support in GRE driver.
>> >
>> > Turning off SG (and GSO) seems to make these crashes disappear.
>> >
>> > The basic setup is:
>> > - gre1 is an NBMA tunnel (no explicit destination, nor bound
>> >   target interface; opennhrp daemon creates neigh mappings)
>> > - IPsec policy to encrypt all GRE traffic in transport mode
>> > - VIA Padlock hardware for AES acceleration
>> > - GRE traffic goes to r8169 NIC; rx on, gro on, tx off, sg off, gso
>> > off
>> >
>> > Incidentally, when I tried exact same setup ran as virtualized, I
>> > was unable to reproduce this crash. I suspect it depends on the
>> > target NIC acceleration capabilities.
>> >
>> I do not have access to this hardware, can you tell me what are target
>> device capabilities?
>
> The physical hardware from which the OOPS is from:
>
> r8169 0000:00:09.0 eth0: RTL8169sc/8110sc at 0xf801c000, 00:30:18:a8:14:ac, XID 18000000 IRQ 18
> r8169 0000:00:09.0 eth0: jumbo features [frames: 7152 bytes, tx checksumming: ok]
>
> (defaults after boot)
> Offload parameters for eth0:
> rx-checksumming: on
> tx-checksumming: off
> scatter-gather: off
> tcp-segmentation-offload: off
> udp-fragmentation-offload: off
> generic-segmentation-offload: off
> generic-receive-offload: on
> large-receive-offload: off
> rx-vlan-offload: on
> tx-vlan-offload: on
> ntuple-filters: off
> receive-hashing: off
>
> When running virtualized in which I was unable to reproduce this OOPS:
>
> e1000 0000:00:03.0 eth0: (PCI:33MHz:32-bit) 52:54:00:12:34:56
> e1000 0000:00:03.0 eth0: Intel(R) PRO/1000 Network Connection
>
> Offload parameters for eth0:
> rx-checksumming: off
> tx-checksumming: on
> scatter-gather: on
> tcp-segmentation-offload: on
> udp-fragmentation-offload: off
> generic-segmentation-offload: on
> generic-receive-offload: on
> large-receive-offload: off
> rx-vlan-offload: on
> tx-vlan-offload: on
> ntuple-filters: off
> receive-hashing: off
>

OK. I am still not able to reproduce it, Can you try attached patch?
if that works, I will send out proper patch.

>>
>> Thanks,
>> Pravin.
>> > This is from vanilla 3.9.2 kernel:
>> >  BUG: unable to handle kernel NULL pointer dereference at 00000010
>> >  IP: [<c123e5b8>] xfrm_output_resume+0x63/0x2a4
>> >  *pde = 00000000
>> >  Oops: 0000 [#1] SMP
>> >  Modules linked in: sha1_generic authenc esp4 xfrm4_mode_transport
>> >  deflate zlib_deflate ctr twofish_i586 twofish_generic
>> > twofish_common camellia_generic serpent_sse2_i586 xts lrw gf128mul
>> > glue_helper ablk_helper cryptd serpent_generic blowfish_generic
>> > blowfish_common cast5_generic cast_common des_generic cbc xcbc
>> > rmd160 sha512_generic hmac crypto_null af_key xfrm_algo ip_gre
>> > ipt_REJECT iptable_filter ipt_MASQUERADE xt_nat iptable_nat
>> > nf_conntrack_ipv4 nf_defrag_ipv4 nf_nat_ipv4 nf_nat ip_tables
>> > ip6t_REJECT xt_LOG xt_limit xt_recent xt_policy xt_tcpudp
>> > nf_conntrack_ipv6 nf_defrag_ipv6 xt_state nf_conntrack xt_multiport
>> > ip6table_filter ip6_tables x_tables ipv6 af_packet padlock_sha
>> > padlock_aes via_cputemp hwmon hwmon_vid serio_raw psmouse pcspkr
>> > shpchp pci_hotplug i2c_viapro i2c_core via_rhine snd_via82xx
>> > snd_ac97_codec snd_pcm snd_timer ac97_bus snd_page_alloc
>> > snd_mpu401_uart snd_rawmidi snd_seq_device snd soundcore
>> > firewire_ohci firewire_core crc_itu_t via_agp agpgart r8169
>> > firmware_class mii evdev fan parport_pc parport thermal button
>> > acpi_cpufreq freq_table mperf processor nls_utf8 nls_cp437 vfat fat
>> > sata_via ehci_pci ehci_hcd uhci_hcd ata_generic pata_via pata_acpi
>> > libata usb_storage usbcore usb_common sd_mod scsi_mod squashfs loop
>> > Pid: 1794, comm: opennhrp Not tainted 3.9.2
>> > #2-Alpine    /CN700-8237 EIP: 0060:[<c123e5b8>] EFLAGS: 00010246
>> > CPU: 0 EIP is at xfrm_output_resume+0x63/0x2a4 EAX: 00000000 EBX:
>> > f0572500 ECX: f5ffc8b8 EDX: 00000064 ESI: f0496400 EDI: 00000000
>> > EBP: f0499bf8 ESP: f0499be8 DS: 007b ES: 007b FS: 00d8 GS: 0033 SS:
>> > 0068 CR0: 80050033 CR2: 00000010 CR3: 3104c000 CR4: 00000690
>> >  DR0: 00000000 DR1: 00000000 DR2: 00000000 DR3: 00000000
>> >  DR6: ffff0ff0 DR7: 00000400
>> >  Process opennhrp (pid: 1794, ti=f0498000 task=f670eff0
>> > task.ti=f0498000) Stack:
>> >   f0496420 f0572500 c1236810 f0572528 f0499c00 c123e806 f0499c14
>> > c123e89b f0572500 c1236810 f0572528 f0499c1c c1236837 f0499c2c
>> > c1236865 f0572500 0000003c f0499c38 c12016e7 f0572500 f0499cb0
>> > f84175fb f0572a00 f04bb400 Call Trace:
>> >   [<c1236810>] ? xfrm4_extract_output+0x8c/0x8c
>> >   [<c123e806>] xfrm_output2+0xd/0xf
>> >   [<c123e89b>] xfrm_output+0x93/0xa0
>> >   [<c1236810>] ? xfrm4_extract_output+0x8c/0x8c
>> >   [<c1236837>] xfrm4_output_finish+0x27/0x29
>> >   [<c1236865>] xfrm4_output+0x2c/0x63
>> >   [<c12016e7>] ip_local_out+0x1b/0x1e
>> >   [<f84175fb>] ipgre_tunnel_xmit+0x80a/0x892 [ip_gre]
>> >   [<c11ddff1>] dev_hard_start_xmit+0x27d/0x37c
>> >   [<c11de379>] dev_queue_xmit+0x289/0x31a
>> >   [<f8332308>] packet_sendmsg+0x933/0x9d0 [af_packet]
>> >   [<c1040200>] ? ttwu_do_wakeup+0xe/0xa8
>> >   [<f8416874>] ? ipgre_header_parse+0x15/0x15 [ip_gre]
>> >   [<c11cd5a9>] sock_sendmsg+0x79/0x94
>> >   [<c10b33d4>] ? __pollwait+0xa4/0xa4
>> >   [<c11cd7e3>] __sys_sendmsg+0x16e/0x1f3
>> >   [<c10367c5>] ? free_pid+0x99/0x9f
>> >   [<c106b92a>] ? call_rcu_sched+0xf/0x12
>> >   [<c1026e15>] ? release_task+0x36d/0x37d
>> >   [<c10390e8>] ? remove_wait_queue+0x31/0x36
>> >   [<c1027a1d>] ? do_wait+0x1a8/0x1b5
>> >   [<c11cef10>] sys_sendmsg+0x2b/0x46
>> >   [<c11cf394>] sys_socketcall+0x145/0x19f
>> >   [<c1257888>] syscall_call+0x7/0xb
>> >  Code: ff 8b 43 74 c7 43 70 00 00 00 00 85 c0 74 0f 3e ff 08 0f 94
>> > c2 84 d2 74 05 e8 35 17 e6 ff 8b 43 48 c7 43 74 00 00 00 00 83 e0
>> > fe <8b> 50 10 89 d8 ff 52 34 83 f8 01 89 c7 0f 85 24 02 00 00 8b 53
>> > EIP: [<c123e5b8>] xfrm_output_resume+0x63/0x2a4 SS:ESP
>> > 0068:f0499be8 CR2: 0000000000000010 ---[ end trace ac96c6b6b1a4992f
>> > ]--- Kernel panic - not syncing: Fatal exception in interrupt
>> >
>> >
>> > Based on the disassembly, it seems the crash happens in
>> > net/xfrm/xfrm_output.c:
>> >
>> > int xfrm_output_resume(struct sk_buff *skb, int err)
>> > {
>> >         while (likely((err = xfrm_output_one(skb, err)) == 0)) {
>> >                 nf_reset(skb);
>> >
>> >                 err = skb_dst(skb)->ops->local_out(skb);
>> >                       ^^^^^^^^^^^^ is NULL
>> >                 if (unlikely(err != 1))
>> >                         goto out;
>> >
>> >                 if (!skb_dst(skb)->xfrm)
>> >                         return dst_output(skb);
>

--047d7b6783aca094fe04dd420656
Content-Type: application/octet-stream;
	name="0001-xfrm-Restore-skb-cb-after-segmenting-it.patch"
Content-Disposition: attachment;
	filename="0001-xfrm-Restore-skb-cb-after-segmenting-it.patch"
Content-Transfer-Encoding: base64
X-Attachment-Id: f_hgznsp1j0

RnJvbSBlNDM3YjIwMTkyNWM5Y2Y3ZDMyNjQ5ODc4NWJlNDg0N2VjMDdmMWNmIE1vbiBTZXAgMTcg
MDA6MDA6MDAgMjAwMQpGcm9tOiBQcmF2aW4gQiBTaGVsYXIgPHBzaGVsYXJAbmljaXJhLmNvbT4K
RGF0ZTogVHVlLCAyMSBNYXkgMjAxMyAxNToyMzowNCAtMDcwMApTdWJqZWN0OiBbUEFUQ0hdIHhm
cm06IFJlc3RvcmUgc2tiLWNiIGFmdGVyIHNlZ21lbnRpbmcgaXQuCgpTaWduZWQtb2ZmLWJ5OiBQ
cmF2aW4gQiBTaGVsYXIgPHBzaGVsYXJAbmljaXJhLmNvbT4KLS0tCiBuZXQveGZybS94ZnJtX291
dHB1dC5jIHwgICAgNyArKysrKysrCiAxIGZpbGVzIGNoYW5nZWQsIDcgaW5zZXJ0aW9ucygrKSwg
MCBkZWxldGlvbnMoLSkKCmRpZmYgLS1naXQgYS9uZXQveGZybS94ZnJtX291dHB1dC5jIGIvbmV0
L3hmcm0veGZybV9vdXRwdXQuYwppbmRleCBiY2ZkYTg5Li44YzM5OTUxIDEwMDY0NAotLS0gYS9u
ZXQveGZybS94ZnJtX291dHB1dC5jCisrKyBiL25ldC94ZnJtL3hmcm1fb3V0cHV0LmMKQEAgLTE1
Miw3ICsxNTIsMTIgQEAgc3RhdGljIGludCB4ZnJtX291dHB1dDIoc3RydWN0IHNrX2J1ZmYgKnNr
YikKIHN0YXRpYyBpbnQgeGZybV9vdXRwdXRfZ3NvKHN0cnVjdCBza19idWZmICpza2IpCiB7CiAJ
c3RydWN0IHNrX2J1ZmYgKnNlZ3M7CisJc3RydWN0IGluZXRfc2tiX3Bhcm0gY2I7CiAKKwkvKiBH
U08gY29kZSBtYWtlIHVzZSBvZiBza2IgY29udHJvbCBibG9jaywgc2F2ZSBpdCBsb2NhbGx5LAor
CSAqIHNvIHRoYXQgd2UgY2FuIHJlc3RvcmUgaXQgYmFjayB0byBpbmRpdmlkdWFsIHNlZ21lbnRz
LgorCSAqKi8KKwljYiA9ICpJUENCKHNrYik7CiAJc2VncyA9IHNrYl9nc29fc2VnbWVudChza2Is
IDApOwogCWtmcmVlX3NrYihza2IpOwogCWlmIChJU19FUlIoc2VncykpCkBAIC0xNjMsNiArMTY4
LDggQEAgc3RhdGljIGludCB4ZnJtX291dHB1dF9nc28oc3RydWN0IHNrX2J1ZmYgKnNrYikKIAkJ
aW50IGVycjsKIAogCQlzZWdzLT5uZXh0ID0gTlVMTDsKKwkJKklQQ0Ioc2VncykgPSBjYjsKKwog
CQllcnIgPSB4ZnJtX291dHB1dDIoc2Vncyk7CiAKIAkJaWYgKHVubGlrZWx5KGVycikpIHsKLS0g
CjEuNy4xCgo=
--047d7b6783aca094fe04dd420656--
