From: Nikolay Aleksandrov <nikolay@cumulusnetworks.com>
Subject: Re: [BUG] kernel oops during bridge creation
Date: Thu, 6 Apr 2017 23:26:06 +0300
Message-ID: <adc7b0d6-68b9-6649-73fc-f5e82812f4a6@cumulusnetworks.com>
References: <4d4b58e0-06e5-de5a-3305-abc739cf2ba2@svinota.eu>
 <20170406185814.GA21480@splinter>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, Ivan Vecera <ivecera@redhat.com>
To: Ido Schimmel <idosch@idosch.org>,
        "Peter V. Saveliev" <peter@svinota.eu>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wr0-f177.google.com ([209.85.128.177]:35408 "EHLO
        mail-wr0-f177.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1755927AbdDFU0J (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 6 Apr 2017 16:26:09 -0400
Received: by mail-wr0-f177.google.com with SMTP id o21so51366283wrb.2
        for <netdev@vger.kernel.org>; Thu, 06 Apr 2017 13:26:09 -0700 (PDT)
In-Reply-To: <20170406185814.GA21480@splinter>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 06/04/17 21:58, Ido Schimmel wrote:
> +Nik
> 

Thanks!

> On Thu, Apr 06, 2017 at 08:19:35PM +0200, Peter V. Saveliev wrote:
>> Operation:
>>
>> # ip link add name test type bridge vlan_default_pvid 1
>>
>> Result:
>>
>> Kernel oops. Minimal required netlink packet structure:
>>
>> ifinfmsg:
>> 	- IFLA_IFNAME: "test"
>> 	- IFLA_LINKINFO:
>> 		= IFLA_INFO_KIND: "bridge"
>> 		= IFLA_INFO_DATA:
>> 			- IFLA_BR_VLAN_DEFAULT_PVID: 1
>>
>> Reproducible: always
>>
>> Versions affected: all the latest kernels, including net-next
>>
>> Possibly related to https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/commit/?id=b6677449dff674cf5b81429b11d5c7f358852ef9
> 
> I believe this is correct.
> 

Yep.
+CC Ivan

>>
>> Trace:
>>
>> [13634.939408] BUG: unable to handle kernel NULL pointer dereference at
>> 0000000000000190
>> [13634.939436] IP: __vlan_add+0x73/0x5f0
>> [13634.939445] PGD 3dfe0067
>> [13634.939445] PUD 35807067
>> [13634.939451] PMD 0
>>
>> [13634.939467] Oops: 0002 [#1] SMP
>> [13634.939474] Modules linked in: crct10dif_pclmul crc32_pclmul
>> ghash_clmulni_intel pcbc qxl ttm drm_kms_helper drm aesni_intel aes_x86_64
>> crypto_simd glue_helper cryptd virtio_balloon evdev input_leds pcspkr
>> led_class serio_raw virtio_console i2c_piix4 acpi_cpufreq tpm_tis
>> tpm_tis_core tpm button ext4 crc16 jbd2 mbcache virtio_net virtio_blk
>> crc32c_intel psmouse 8139cp mii virtio_pci virtio_ring virtio
>> [13634.939561] CPU: 0 PID: 1535 Comm: ip Not tainted 4.11.0-rc3+ #6
>> [13634.939574] Hardware name: QEMU Standard PC (i440FX + PIIX, 1996), BIOS
>> 1.9.3-1.fc25 04/01/2014
>> [13634.939593] task: ffff9b4838f5a000 task.stack: ffffc1b74046c000
>> [13634.939607] RIP: 0010:__vlan_add+0x73/0x5f0
>> [13634.939617] RSP: 0018:ffffc1b74046f668 EFLAGS: 00010246
>> [13634.939629] RAX: 0000000000000000 RBX: ffff9b483522d680 RCX:
>> 0000000000000000
>> [13634.939644] RDX: ffffffffbe8f2978 RSI: 0000000000000200 RDI:
>> ffffffffbe2c120f
>> [13634.939659] RBP: 0000000000000000 R08: 0000000000000000 R09:
>> 0000000000000000
>> [13634.939674] R10: 0000000000000000 R11: 000000000000c609 R12:
>> 0000000000000000
>> [13634.939689] R13: ffff9b48350ae8c0 R14: ffff9b48350ae000 R15:
>> 0000000000000000
>> [13634.939705] FS:  00007fe5e4f13700(0000) GS:ffff9b483fc00000(0000)
>> knlGS:0000000000000000
>> [13634.939722] CS:  0010 DS: 0000 ES: 0000 CR0: 0000000080050033
>> [13634.939734] CR2: 0000000000000190 CR3: 0000000035805000 CR4:
>> 00000000000406f0
>> [13634.939752] DR0: 0000000000000000 DR1: 0000000000000000 DR2:
>> 0000000000000000
>> [13634.939767] DR3: 0000000000000000 DR6: 00000000fffe0ff0 DR7:
>> 0000000000000400
>> [13634.939783] Call Trace:
>> [13634.939791]  ? pcpu_next_unpop+0x3b/0x50
>> [13634.939801]  ? pcpu_alloc+0x3d2/0x680
>> [13634.939810]  ? br_vlan_add+0x135/0x1b0
> 
> Nik, I looked at this earlier today since Peter mentioned this over IRC.
> I think the problem is that the bridge's vlan group is accessed before
> it's allocated in br_vlan_init().
> 

Yes, that's the problem.

> Not sure what's the correct way to solve this though, maybe moving
> br_vlan_init() to the bridge's newlink()? Do you see any problem with
> that?
> 

I think we also have to support the old way of adding bridges via the ioctl, and moving
the init to newlink() would break that, making br_vlan_init() idempotent wouldn't help
either as we need to destroy the vg if it's allocated upon failure. So we'll have to
consider all error paths in both newlink() and the old ioctl and handle the vlan if it
was created before, ugh..

Right now I don't see a better option that would keep the current state though, so if you'd
like go ahead and cook a patch, I won't be able to do it until tomorrow my time.

Actually making br_vlan_init() idempotent might work, keep the code as-is just init the
the vlans before the changelink() in newlink(), then the second vlan_init() inside would
be a no-op, but it will work for the old ioctl and wouldn't require too much change.
On the downside it will be ugly.

Cheers,
 Nik
