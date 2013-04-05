From: Veaceslav Falico <vfalico@redhat.com>
Subject: Re: [PATCH] bonding: remove sysfs before removing devices
Date: Sat, 6 Apr 2013 01:21:33 +0200
Message-ID: <20130405232133.GA19437@redhat.com>
References: <1365003993-13181-1-git-send-email-vfalico@redhat.com>
 <515F4CEF.3030207@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Cc: netdev@vger.kernel.org, fubar@us.ibm.com, andy@greyhouse.net,
	davem@davemloft.net
To: Nikolay Aleksandrov <nikolay@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:57696 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1759881Ab3DEXXc (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 5 Apr 2013 19:23:32 -0400
Content-Disposition: inline
In-Reply-To: <515F4CEF.3030207@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, Apr 06, 2013 at 12:15:11AM +0200, Nikolay Aleksandrov wrote:
>Hi,
>Sorry for the late reply but I was travelling this week. In my opinion this
>fix is wrong because in bond_uninit() (called by rtnl_link_unregister)
>you have:
>list_del(&bond->bond_list);
>which is linked in the bond_net dev_list which is freed by
>unregister_pernet_subsys.

Yep, you're right, I've hit it recently with the patch applied, and now
working on it. However, I still think that the idea of the patch is correct
- i.e. to first disable sysfs (especially bonding_masters) and only
  afterwards to start removing everything else. Or, obviously, to finally
add normal locking to sysfs functions.

Anyway, this corruption is really rare, so I'll wait for your fix next
week.

>You'll get a corrupted list warning at best.
>
>Here's a sample from running insmod max_bonds=3/rmmod in a loop with the
>patch applied:
>Apr  5 23:54:54 dhcp-1-171 kernel: [   21.302186] ------------[ cut here
>]------------
>Apr  5 23:54:54 dhcp-1-171 kernel: [   21.302191] WARNING: at
>lib/list_debug.c:62 __list_del_entry+0x82/0xd0()
>Apr  5 23:54:54 dhcp-1-171 kernel: [   21.302192] Hardware name: VirtualBox
>Apr  5 23:54:54 dhcp-1-171 kernel: [   21.302194] list_del corruption.
>next->prev should be ffff880036bc6860, but was ffff88002ee23000
>Apr  5 23:54:54 dhcp-1-171 kernel: [   21.302194] Modules linked in:
>bonding(O-) ip6t_REJECT nf_conntrack_ipv6 nf_defrag_ipv6
>nf_conntrack_ipv4 nf_defrag_ipv4 ip6table_filter xt_conntrack
>nf_conntrack ip6_tables snd_hda_codec_idt snd_hda_intel snd_hda_codec
>snd_hwdep snd_seq snd_seq_device ppdev snd_pcm pcspkr snd_page_alloc
>i2c_piix4 joydev snd_timer snd soundcore i2c_core microcode parport_pc
>parport e1000 [last unloaded: bonding]
>Apr  5 23:54:54 dhcp-1-171 kernel: [   21.302214] Call Trace:
>Apr  5 23:54:54 dhcp-1-171 kernel: [   21.302219]  [<ffffffff8105e99f>]
>warn_slowpath_common+0x7f/0xc0
>Apr  5 23:54:54 dhcp-1-171 kernel: [   21.302221]  [<ffffffff8105ea96>]
>warn_slowpath_fmt+0x46/0x50
>Apr  5 23:54:54 dhcp-1-171 kernel: [   21.302225]  [<ffffffff8164efaf>]
>? printk+0x61/0x63
>Apr  5 23:54:54 dhcp-1-171 kernel: [   21.302227]  [<ffffffff8130c302>]
>__list_del_entry+0x82/0xd0
>Apr  5 23:54:54 dhcp-1-171 kernel: [   21.302229]  [<ffffffff8130c361>]
>list_del+0x11/0x40
>Apr  5 23:54:54 dhcp-1-171 kernel: [   21.302233]  [<ffffffffa0187f70>]
>bond_uninit+0x70/0xd0 [bonding]
>Apr  5 23:54:54 dhcp-1-171 kernel: [   21.302236]  [<ffffffff815486d8>]
>rollback_registered_many+0x158/0x220
>Apr  5 23:54:54 dhcp-1-171 kernel: [   21.302238]  [<ffffffff815487f9>]
>unregister_netdevice_many+0x19/0x60
>Apr  5 23:54:54 dhcp-1-171 kernel: [   21.302240]  [<ffffffff815575ae>]
>__rtnl_link_unregister+0x6e/0xb0
>Apr  5 23:54:54 dhcp-1-171 kernel: [   21.302243]  [<ffffffff81557b7e>]
>rtnl_link_unregister+0x1e/0x30
>Apr  5 23:54:54 dhcp-1-171 kernel: [   21.302246]  [<ffffffffa019359e>]
>bonding_exit+0x2d/0xa8f [bonding]
>Apr  5 23:54:54 dhcp-1-171 kernel: [   21.302249]  [<ffffffff810c1dd0>]
>sys_delete_module+0x170/0x2d0
>Apr  5 23:54:54 dhcp-1-171 kernel: [   21.302252]  [<ffffffff81014981>]
>? do_notify_resume+0x71/0xb0
>Apr  5 23:54:54 dhcp-1-171 kernel: [   21.302255]  [<ffffffff81661899>]
>system_call_fastpath+0x16/0x1b
>Apr  5 23:54:54 dhcp-1-171 kernel: [   21.302256] ---[ end trace
>31cca9f26623fa11 ]---
>Apr  5 23:54:54 dhcp-1-171 kernel: [   21.302417] bonding: bond1:
>released all slaves
>
>You can hit this also with a NULL pointer dereference.
>I have a correct fix for this bug which I intend to post next week when
>I get back and after some more testing.
>
>Please let me know if I've missed something about this patch.
>
>Best regards,
> Nik
