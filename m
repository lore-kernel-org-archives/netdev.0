From: Sedat Dilek <sedat.dilek@gmail.com>
Subject: Re: net.git: Call-trace after "Merge branch 'netlink_multicast'"
Date: Sun, 28 Dec 2014 06:39:35 +0100
Message-ID: <CA+icZUVkNHBqCn66onJP9i5vfVzHR9mdSFXyiBFyjhkrySrSzQ@mail.gmail.com>
Reply-To: sedat.dilek@gmail.com
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary=047d7bb03946dc3d00050b402eec
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"David S. Miller" <davem@davemloft.net>,
	Fengguang Wu <fengguang.wu@intel.com>
To: Johannes Berg <johannes.berg@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wg0-f52.google.com ([74.125.82.52]:58729 "EHLO
	mail-wg0-f52.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751045AbaL1Fjh (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 28 Dec 2014 00:39:37 -0500
Received: by mail-wg0-f52.google.com with SMTP id x12so16732379wgg.11
        for <netdev@vger.kernel.org>; Sat, 27 Dec 2014 21:39:35 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

--047d7bb03946dc3d00050b402eec
Content-Type: text/plain; charset=UTF-8

On Sat, Dec 27, 2014 at 11:46 AM, Sedat Dilek <sedat.dilek@gmail.com> wrote:
> On Sat, Dec 27, 2014 at 11:30 AM, Sedat Dilek <sedat.dilek@gmail.com> wrote:
>> Hi johill :-),
>>
>> I am seeing here a call-trace after pulling net.git#master on top of upstream.
>>
>> [   21.095849] ------------[ cut here ]------------
>> [   21.095862] WARNING: CPU: 1 PID: 1291 at
>> net/netlink/genetlink.c:1011 genl_bind+0xeb/0x100()
>> [   21.095864] Modules linked in: arc4 iwldvm snd_hda_codec_hdmi
>> uvcvideo snd_hda_codec_realtek mac80211 snd_hda_codec_generic
>> snd_hda_intel videobuf2_vmalloc snd_hda_controller videobuf2_memops
>> snd_hda_codec videobuf2_core bnep rfcomm v4l2_common joydev option
>> i915 usb_wwan videodev snd_hwdep cdc_ether usbserial snd_pcm usbnet
>> snd_seq_midi snd_seq_midi_event iwlwifi snd_rawmidi psmouse btusb
>> snd_seq i2c_algo_bit parport_pc snd_timer drm_kms_helper bluetooth
>> ppdev snd_seq_device serio_raw cfg80211 drm snd samsung_laptop lpc_ich
>> soundcore video wmi intel_rst mac_hid lp parport binfmt_misc
>> hid_generic usbhid hid usb_storage r8169 mii
>> [   21.095942] CPU: 1 PID: 1291 Comm: acpid Not tainted
>> 3.19.0-rc1-55.2-iniza-small #1
>> [   21.095945] Hardware name: SAMSUNG ELECTRONICS CO., LTD.
>> 530U3BI/530U4BI/530U4BH/530U3BI/530U4BI/530U4BH, BIOS 13XK 03/28/2013
>> [   21.095948]  ffffffff81ae3fda ffff8800b8877dc8 ffffffff8175b61c
>> 0000000000000000
>> [   21.095955]  0000000000000000 ffff8800b8877e08 ffffffff810753da
>> ffffffff82c82f40
>> [   21.095962]  0000000000000001 ffffffff82c82f40 0000000000000000
>> 0000000000000000
>> [   21.095967] Call Trace:
>> [   21.095976]  [<ffffffff8175b61c>] dump_stack+0x4c/0x65
>> [   21.095983]  [<ffffffff810753da>] warn_slowpath_common+0x8a/0xc0
>> [   21.095989]  [<ffffffff810754ca>] warn_slowpath_null+0x1a/0x20
>> [   21.095993]  [<ffffffff8169738b>] genl_bind+0xeb/0x100
>> [   21.095998]  [<ffffffff81695d97>] netlink_bind+0xb7/0x280
>> [   21.096004]  [<ffffffff811add89>] ? might_fault+0xb9/0xc0
>> [   21.096009]  [<ffffffff811add2e>] ? might_fault+0x5e/0xc0
>> [   21.096015]  [<ffffffff8164d038>] SYSC_bind+0xb8/0xf0
>> [   21.096021]  [<ffffffff810c2f0d>] ? trace_hardirqs_on+0xd/0x10
>> [   21.096027]  [<ffffffff81025ae5>] ? syscall_trace_enter_phase1+0x105/0x180
>> [   21.096033]  [<ffffffff813b4e1e>] ? trace_hardirqs_on_thunk+0x3a/0x3f
>> [   21.096038]  [<ffffffff8164e65e>] SyS_bind+0xe/0x10
>> [   21.096044]  [<ffffffff817654ed>] system_call_fastpath+0x16/0x1b
>> [   21.096047] ---[ end trace 7dceb0e985894682 ]---
>>
>> My kernel-config, full dmesg and my patchset on top of Linux
>> v.3.19-rc1 are attached.
>>
>> Please CC me if you need more informations.
>>
>
> It looks like the WARN_ON() in commit "genetlink: pass multicast
> bind/unbind to families" [1] causes this...
>
> [ dmesg ]
> ...
> [   21.095862] WARNING: CPU: 1 PID: 1291 at
> net/netlink/genetlink.c:1011 genl_bind+0xeb/0x100()
>
> [ patch ]
> ...
> +static int genl_bind(int group)
> +{
> + int i, err;
> + bool found = false;
> +
> + down_read(&cb_lock);
> + for (i = 0; i < GENL_FAM_TAB_SIZE; i++) {
> + struct genl_family *f;
> +
> + list_for_each_entry(f, genl_family_chain(i), family_list) {
> + if (group >= f->mcgrp_offset &&
> + group < f->mcgrp_offset + f->n_mcgrps) {
> + int fam_grp = group - f->mcgrp_offset;
> +
> + if (f->mcast_bind)
> + err = f->mcast_bind(fam_grp);
> + else
> + err = 0;
> + found = true;
> + break;
> + }
> + }
> + }
> + up_read(&cb_lock);
> +
> + if (WARN_ON(!found)) <--- *** Line #1011 ***
> + err = 0;
> +
> + return err;
> +}
>
> Hope this helps.
>
> Regards,
> - Sedat -
>
> [1] http://git.kernel.org/cgit/linux/kernel/git/davem/net.git/commit/net/netlink/genetlink.c?id=c380d9a7afff0e4c2e5f3c1c2dc7d2f4214dd962

[ CCing Fengguang Wu who reported the same issue on LKML (see [0]) ]

Was "netlink/genetlink: pass network namespace to bind/unbind" patch
[1] forgotten in this 'netlink_multicast' merge?
I also tested with that patch on top of net.git#master.
The warning still remains.

I have #if 0-ed the WARN_ON() for now (see attached patch), this makes
the warning go away for me.

BTW, I looked through the patches listed in [2] but this list seems to
be truncated.
Then I looked again at the linux-netdev ML where I found Johannes'
patch and Dave replied "Applied, thanks Johannes." (see thread in
[3]).
Forgot to push out?

- Sedat -

[0] http://marc.info/?l=linux-kernel&m=141972716410805&w=2
[1] http://patchwork.ozlabs.org/patch/423799/
[2] http://patchwork.ozlabs.org/project/netdev/list/
[3] http://marc.info/?t=141936487400002&r=1&w=2

--047d7bb03946dc3d00050b402eec
Content-Type: text/x-diff; charset=US-ASCII;
	name="0001-genetlink-Comment-out-WARN_ON-in-genl_bind.patch"
Content-Disposition: attachment;
	filename="0001-genetlink-Comment-out-WARN_ON-in-genl_bind.patch"
Content-Transfer-Encoding: base64
X-Attachment-Id: f_i47zac560

RnJvbSAwMjczMGUxZmI3ZmZkYTY4ZjE2YWJkZjMxMGQzNmZhYmM0ZTI1MTU0IE1vbiBTZXAgMTcg
MDA6MDA6MDAgMjAwMQpGcm9tOiBTZWRhdCBEaWxlayA8c2VkYXQuZGlsZWtAZ21haWwuY29tPgpE
YXRlOiBTYXQsIDI3IERlYyAyMDE0IDE3OjM2OjIzICswMTAwClN1YmplY3Q6IFtQQVRDSF0gZ2Vu
ZXRsaW5rOiBDb21tZW50IG91dCBXQVJOX09OKCkgaW4gZ2VubF9iaW5kKCkKClNpZ25lZC1vZmYt
Ynk6IFNlZGF0IERpbGVrIDxzZWRhdC5kaWxla0BnbWFpbC5jb20+Ci0tLQogbmV0L25ldGxpbmsv
Z2VuZXRsaW5rLmMgfCAyICsrCiAxIGZpbGUgY2hhbmdlZCwgMiBpbnNlcnRpb25zKCspCgpkaWZm
IC0tZ2l0IGEvbmV0L25ldGxpbmsvZ2VuZXRsaW5rLmMgYi9uZXQvbmV0bGluay9nZW5ldGxpbmsu
YwppbmRleCAwNWJmNDBiLi4zNjM3MzY5IDEwMDY0NAotLS0gYS9uZXQvbmV0bGluay9nZW5ldGxp
bmsuYworKysgYi9uZXQvbmV0bGluay9nZW5ldGxpbmsuYwpAQCAtMTAwOCw4ICsxMDA4LDEwIEBA
IHN0YXRpYyBpbnQgZ2VubF9iaW5kKGludCBncm91cCkKIAl9CiAJdXBfcmVhZCgmY2JfbG9jayk7
CiAKKyNpZiAwCiAJaWYgKFdBUk5fT04oIWZvdW5kKSkKIAkJZXJyID0gMDsKKyNlbmRpZgogCiAJ
cmV0dXJuIGVycjsKIH0KLS0gCjIuMi4xCgo=
--047d7bb03946dc3d00050b402eec--
