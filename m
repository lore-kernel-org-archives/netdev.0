From: Alan Jenkins <alan-jenkins@tuffmail.co.uk>
Subject: Re: rfkill rewrite bug
Date: Sat, 18 Apr 2009 09:17:10 +0100
Message-ID: <49E98C86.2040308@tuffmail.co.uk>
References: <49DCA88E.6060400@tuffmail.co.uk>	 (sfid-20090408_153722_059382_FB44D658) <1239204090.16477.1.camel@johannes.local>	 <49DCDD2E.80705@tuffmail.co.uk>  <49E38BBC.5010708@tuffmail.co.uk>	 (sfid-20090413_205524_915082_56358705) <1239741968.4205.1.camel@johannes.local>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Johannes Berg <johannes@sipsolutions.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ew0-f176.google.com ([209.85.219.176]:42444 "EHLO
	mail-ew0-f176.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757624AbZDRIMJ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 18 Apr 2009 04:12:09 -0400
Received: by ewy24 with SMTP id 24so499880ewy.37
        for <netdev@vger.kernel.org>; Sat, 18 Apr 2009 01:12:07 -0700 (PDT)
In-Reply-To: <1239741968.4205.1.camel@johannes.local>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Johannes Berg wrote:
> I think I fixed that now, I allowed using set_sw_state before register
> and that didn't go too well with the LED system w/o any checks.
>
> johannes
>   

Ok, I retried with v6.  It seemed to work well enough; my wireless 
toggle key worked and either state was preserved over suspend and 
hibernation.

When I looked at the code earlier, I saw no obvious replacement for 
rfkill_set_default().  So I tried disabling the wireless and rebooting 
to see what happened.  It didn't like that :-).

[    3.258061] ------------[ cut here ]------------
[    3.258160] kernel BUG at kernel/workqueue.c:192!
[    3.258256] invalid opcode: 0000 [#1]
[    3.258391] last sysfs file: /sys/module/backlight/initstate
[    3.258489] Modules linked in: video(+) output eeepc_laptop(+) 
backlight ac battery rfkill but
ton processor evdev thermal fan ata_generic
[    3.259261]
[    3.259346] Pid: 1571, comm: modprobe Not tainted (2.6.30-rc2-wleeepc 
#13) 701
[    3.259482] EIP: 0060:[<c0129e0a>] EFLAGS: 00010203 CPU: 0
[    3.259590] EIP is at queue_work_on+0x1a/0x31
[    3.259687] EAX: df089730 EBX: df00a060 ECX: df08972c EDX: 00000000
[    3.259790] ESI: e0045f54 EDI: df284800 EBP: df361e3c ESP: df361e38
[    3.259893]  DS: 007b ES: 007b FS: 0000 GS: 0033 SS: 0068
[    3.259996] Process modprobe (pid: 1571, ti=df360000 task=de853c00 
task.ti=df360000)
[    3.260131] Stack:
[    3.260160]  df089600 df361e44 c0129e41 df361e4c c0129e52 df361e5c 
e00125f7 00010000
[    3.260160]  df09c400 df361e80 e00458b9 00000000 00000200 00000010 
de59ae90 df284800
[    3.260160]  ffffffed e0047474 df361e9c c02116c3 df2849fc ffffffda 
df2849fc f
fffffed
[    3.260160] Call Trace:
[    3.260160]  [<c0129e41>] ? queue_work+0xe/0x10
[    3.260160]  [<c0129e52>] ? schedule_work+0xf/0x11
[    3.260160]  [<e00125f7>] ? rfkill_set_sw_state+0x4c/0x69 [rfkill]
[    3.260160]  [<e00458b9>] ? eeepc_hotk_add+0x2c7/0x3ec [eeepc_laptop]
[    3.260160]  [<c02116c3>] ? acpi_device_probe+0x44/0x127
[    3.260160]  [<c0249719>] ? driver_probe_device+0x7f/0xf2
[    3.260160]  [<c02497cf>] ? __driver_attach+0x43/0x5f
[    3.260160]  [<c0248dcb>] ? bus_for_each_dev+0x39/0x5a
[    3.260160]  [<c02495ec>] ? driver_attach+0x14/0x16
[    3.260160]  [<c024978c>] ? __driver_attach+0x0/0x5f
[    3.260160]  [<c02492cf>] ? bus_add_driver+0xd7/0x1e7
[    3.260160]  [<c02499d5>] ? driver_register+0x7b/0xd7
[    3.260160]  [<c0212d44>] ? acpi_bus_register_driver+0x3a/0x3c
[    3.260160]  [<e004a022>] ? eeepc_laptop_init+0x22/0x1b9 [eeepc_laptop]
[    3.260160]  [<c0101131>] ? _stext+0x49/0x10b
[    3.260160]  [<e004a000>] ? eeepc_laptop_init+0x0/0x1b9 [eeepc_laptop]
[    3.260160]  [<c012f476>] ? __blocking_notifier_call_chain+0x40/0x4c
[    3.260160]  [<c013a738>] ? sys_init_module+0x87/0x18f
[    3.260160]  [<c0102804>] ? sysenter_do_call+0x12/0x22
[    3.260160] Code: 83 e2 fc 8b 4a 14 89 c2 8b 01 e8 d9 ff ff ff 5d c3 
55 89 e5 53 89 d3 0f ba 29 00 19 c0 31 d2 85 c0 75 1a 8d 41 04 39 41 04 
74 04 <0f> 0b eb fe 8b 03 89 ca e8 b0 ff ff ff ba 01 00 00 00 5b 89 d0
[    3.260160] EIP: [<c0129e0a>] queue_work_on+0x1a/0x31 SS:ESP 
0068:df361e38
[    3.269670] ---[ end trace f8b6941350b5e97c ]---

Thanks
Alan
