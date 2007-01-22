From: Michael Buesch <mb@bu3sch.de>
Subject: Re: Can someone please try...
Date: Mon, 22 Jan 2007 21:06:24 +0100
Message-ID: <200701222106.24329.mb@bu3sch.de>
References: <200701161806.02780.mb@bu3sch.de> <1169113274.10770.18.camel@dv> <1169193247.9908.34.camel@dv>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-15"
Content-Transfer-Encoding: 7bit
Cc: bcm43xx-dev@lists.berlios.de, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from static-ip-62-75-166-246.inaddr.intergenia.de ([62.75.166.246]:54398
	"EHLO vs166246.vserver.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751453AbXAVUHl (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 22 Jan 2007 15:07:41 -0500
To: Pavel Roskin <proski@gnu.org>
In-Reply-To: <1169193247.9908.34.camel@dv>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Friday 19 January 2007 08:54, Pavel Roskin wrote:
> Hello, Michael!
> 
> I did more testing, and the results are following.  It looks like the
> oopses and panics on i386 were triggered by 4k stacks.  x86_64 doesn't
> have this option.
> 
> Now that I enabled other debug options on both platforms. but not 4k
> stacks, I'm seeing exactly the same problem on each platform.  When run
> initially, wpa_supplicant connects with no problems (except very poor
> reception of the data packets, but it's another story).  If interrupted
> and restarted, wpa_supplicant reconnects, but I'm getting messages like
> this (i386):

That's a very interresting discover.
Partly, because I don't see this on my i386 machine. ;)

It's obviously some stack/memory corruption. But I'm not
sure if this is a stackoverflow. I'd rather say no, it isn't.

Could probably be triggered by something like kfree()ing
a dangling pointer or something...

> Slab corruption: start=cfdaece0, len=1024
> Redzone: 0x5a2cf071/0x5a2cf071.
> Last user: [<c02d70c2>](skb_release_data+0x7b/0x7f)
> 000: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
> 010: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
> 020: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
> 030: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
> 040: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
> 050: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
> Prev obj: start=cfdae8d4, len=1024
> Redzone: 0x170fc2a5/0x170fc2a5.
> Last user: [<c026ea5a>](device_create+0x2c/0x98)
> 000: 01 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
> 010: ad 4e ad de ff ff ff ff ff ff ff ff 10 3a 6d c0
> Next obj: start=cfdaf0ec, len=1024
> Redzone: 0x170fc2a5/0x170fc2a5.
> Last user: [<c0165730>](expand_files+0x95/0x2c2)
> 000: 78 55 39 c7 78 55 39 c7 78 55 39 c7 88 da 52 df
> 010: d8 18 3b c7 00 00 00 00 00 00 00 00 00 00 00 00
> 
> and this (x86_64):
> 
> Slab corruption: start=ffff81000ec8a198, len=1024
> Redzone: 0x5a2cf071/0x5a2cf071.
> Last user: [<ffffffff8042e916>](skb_release_data+0x94/0x99)
> 000: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
> 010: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
> 020: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
> 030: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
> 040: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
> 050: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
> Next obj: start=ffff81000ec8a5b0, len=1024
> Redzone: 0x170fc2a5/0x170fc2a5.
> Last user: [<ffffffff803be6e9>](device_create+0x5f/0x110)
> 000: 01 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
> 010: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
> 
> I can restart wpa_supplicant again, and it would show similar messages.
> The first "Last user" is inevitably skb_release_data.
> 
> I have no idea how to deal with it.  I think I need a stack trace at the
> time when skb_release_data is called.
> 
> This is a stack trace at the time when slab corruption is detected.
> It's actually incorrect closer to the top, perhaps from gcc
> optimizations for static functions.
> 
> Slab corruption: start=ffff8100066f81d8, len=1024
> 
> Call Trace:
>  [<ffffffff80218636>] vsnprintf+0x338/0x5a8
>  [<ffffffff8020713d>] check_poison_obj+0x69/0x1ae
>  [<ffffffff803c3ff2>] _request_firmware+0x8f/0x326
>  [<ffffffff803c3ff2>] _request_firmware+0x8f/0x326
> 
> 
>  [<ffffffff8020c09a>] cache_alloc_debugcheck_after+0x32/0x1a2
>  [<ffffffff803c3ff2>] _request_firmware+0x8f/0x326
>  [<ffffffff802aaae2>] kmem_cache_zalloc+0xaf/0xd8
>  [<ffffffff803c3ff2>] _request_firmware+0x8f/0x326
>  [<ffffffff880111ea>] :bcm43xx_d80211:bcm43xx_phy_init_tssi2dbm_table
> +0xf0/0x2ca
>  [<ffffffff803c432a>] request_firmware+0xe/0x10
>  [<ffffffff88007d75>] :bcm43xx_d80211:bcm43xx_chip_init+0x96/0xaba
>  [<ffffffff8020a03d>] kmem_cache_alloc+0xaf/0xbe
>  [<ffffffff88009c97>] :bcm43xx_d80211:bcm43xx_wireless_core_init
> +0x4de/0xa3d
>  [<ffffffff8800b4e8>] :bcm43xx_d80211:bcm43xx_add_interface+0x64/0xde
>  [<ffffffff8046eaa0>] ieee80211_open+0x1c7/0x2cc
>  [<ffffffff804330da>] dev_open+0x36/0x76
>  [<ffffffff8043185b>] dev_change_flags+0x5d/0x122
>  [<ffffffff8045a1a3>] devinet_ioctl+0x259/0x5e8
>  [<ffffffff8045a7f2>] inet_ioctl+0x71/0x8f
>  [<ffffffff8042a395>] sock_ioctl+0x1db/0x1fd
>  [<ffffffff8023bfa7>] do_ioctl+0x1b/0x50
>  [<ffffffff8022c9b2>] vfs_ioctl+0x22a/0x23c
>  [<ffffffff80289975>] trace_hardirqs_on+0x124/0x14e
>  [<ffffffff802459a2>] sys_ioctl+0x42/0x65
>  [<ffffffff8025531e>] system_call+0x7e/0x83
> 
> Anyway, I could narrow down this message to the first kzalloc() call in
> fw_register_device(), file drivers/base/firmware_class.c.  This only
> seems to confirm my suspicion that the actual corruption happened before
> this point.  We are just hitting it when trying to allocate more memory.
> 
> Help with debugging this problem will be appreciated.  I've never hunted
> down such problems, especially in kernel space.
> 

-- 
Greetings Michael.
