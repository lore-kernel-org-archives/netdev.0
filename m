From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: net-next: NULL pointer dereference on adding a net namespace
 and a system freeze
Date: Sun, 09 Mar 2014 21:02:26 -0700
Message-ID: <1394424146.3607.2.camel@edumazet-glaptop2.roam.corp.google.com>
References: <20140310014452.144b0491@north>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, Fan Du <fan.du@windriver.com>,
	Steffen Klassert <steffen.klassert@secunet.com>
To: Jakub Kicinski <moorray3@wp.pl>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f43.google.com ([209.85.220.43]:61655 "EHLO
	mail-pa0-f43.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750722AbaCJEC2 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 10 Mar 2014 00:02:28 -0400
Received: by mail-pa0-f43.google.com with SMTP id bj1so6705473pad.2
        for <netdev@vger.kernel.org>; Sun, 09 Mar 2014 21:02:28 -0700 (PDT)
In-Reply-To: <20140310014452.144b0491@north>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 2014-03-10 at 01:44 +0100, Jakub Kicinski wrote:
> Hi!
> 
> Running Fedora 20 with net-next I get the following warning when
> libvirt or rtkit comes up:
> 
> [  272.143488] kmem_cache_sanity_check (flow_cache): Cache name already exists.
> [  272.143586] CPU: 0 PID: 975 Comm: libvirtd Not tainted 3.14.0-rc5+ #1
> [  272.143589] Hardware name: Bochs Bochs, BIOS Bochs 01/01/2011
> [  272.143591]  0000000000000000 ffff88003ceadba0 ffffffff8167baf0 ffff88003db3d300
> [  272.143595]  ffff88003ceadc18 ffffffff8117795b ffff88003ceadbc8 ffff88003b235158
> [  272.143599]  0000000000000000 0000000000040000 0000000000000068 0000000000000000
> [  272.143602] Call Trace:
> [  272.143610]  [<ffffffff8167baf0>] dump_stack+0x4d/0x66
> [  272.143615]  [<ffffffff8117795b>] kmem_cache_create_memcg+0x12b/0x420
> [  272.143618]  [<ffffffff81177c7b>] kmem_cache_create+0x2b/0x30
> [  272.143622]  [<ffffffff815c4a0e>] flow_cache_init+0x2e/0x2b0
> [  272.143626]  [<ffffffff8164b017>] xfrm_net_init+0x227/0x360
> [  272.143629]  [<ffffffff8164af41>] ? xfrm_net_init+0x151/0x360
> [  272.143632]  [<ffffffff815a5921>] ops_init+0x41/0x150
> [  272.143635]  [<ffffffff815a5aa3>] setup_net+0x73/0x110
> [  272.143638]  [<ffffffff815a5fe2>] copy_net_ns+0x72/0x100
> [  272.143642]  [<ffffffff810943f9>] create_new_namespaces+0xf9/0x190
> [  272.143645]  [<ffffffff81094560>] copy_namespaces+0xd0/0xf0
> [  272.143648]  [<ffffffff81094495>] ? copy_namespaces+0x5/0xf0
> [  272.143651]  [<ffffffff81069be0>] copy_process.part.31+0x950/0x1b30
> [  272.143655]  [<ffffffff8106af95>] do_fork+0xd5/0x370
> [  272.143658]  [<ffffffff811c1b2d>] ? __fput+0x17d/0x240
> [  272.143662]  [<ffffffff8110440c>] ? __audit_syscall_entry+0x9c/0xf0
> [  272.143665]  [<ffffffff8106b2b6>] SyS_clone+0x16/0x20
> [  272.143669]  [<ffffffff8168cf19>] stub_clone+0x69/0x90
> [  272.143673]  [<ffffffff8168cb69>] ? system_call_fastpath+0x16/0x1b
> 
> 
> When I try to add a netns with 
> # ip netns add abcd
> I it dies with:


Yep, commit ca925cf1534ebcec332c08719a7dee6ee1782ce4 is buggy.

    flowcache: Make flow cache name space aware
    
    Inserting a entry into flowcache, or flushing flowcache should be based
    on per net scope. The reason to do so is flushing operation from fat
    netns crammed with flow entries will also making the slim netns with only
    a few flow cache entries go away in original implementation.
    
    Since flowcache is tightly coupled with IPsec, so it would be easier to
    put flow cache global parameters into xfrm namespace part. And one last
    thing needs to do is bumping flow cache genid, and flush flow cache should
    also be made in per net style.
    
    Signed-off-by: Fan Du <fan.du@windriver.com>
    Signed-off-by: Steffen Klassert <steffen.klassert@secunet.com>

I fail to understand why the kmem_cache must be private to a netns.
