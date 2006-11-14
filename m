From: "Arnaldo Carvalho de Melo" <arnaldo.melo@gmail.com>
Subject: Re: [PATCH] dccp: remove module exit functions
Date: Tue, 14 Nov 2006 12:11:04 -0200
Message-ID: <39e6f6c70611140611q4eebee4bv4a6f04e374d07f16@mail.gmail.com>
References: <XMMS.LNX.4.64.0611101122520.15046@d.namei>
	 <XMMS.LNX.4.64.0611101126150.15046@d.namei>
	 <39e6f6c70611101032v5f0be644ta65069cf533b3385@mail.gmail.com>
	 <20061113.164909.35016870.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: jmorris@namei.org, netdev@vger.kernel.org, dccp@vger.kernel.org,
	"Gerrit Renker" <gerrit@erg.abdn.ac.uk>
Return-path: <netdev-owner@vger.kernel.org>
Received: from wr-out-0506.google.com ([64.233.184.239]:10402 "EHLO
	wr-out-0506.google.com") by vger.kernel.org with ESMTP
	id S965838AbWKNOLI (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 14 Nov 2006 09:11:08 -0500
Received: by wr-out-0506.google.com with SMTP id i22so148911wra
        for <netdev@vger.kernel.org>; Tue, 14 Nov 2006 06:11:06 -0800 (PST)
To: "David Miller" <davem@davemloft.net>
In-Reply-To: <20061113.164909.35016870.davem@davemloft.net>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 11/13/06, David Miller <davem@davemloft.net> wrote:
> From: "Arnaldo Carvalho de Melo" <arnaldo.melo@gmail.com>
> Date: Fri, 10 Nov 2006 16:32:16 -0200
>
> > On 11/10/06, James Morris <jmorris@namei.org> wrote:
> > > On Fri, 10 Nov 2006, James Morris wrote:
> > >
> > > > I wonder if this facility can be integrated more generally into the kernel
> > > > protocol which people are developing.
> > >
> > > Ugh, editor screwup.  That was meant to be
> > >
> > > I wonder if this facility can be integrated more generally into the kernel
> > > as a kernel hacking option, as this is not the only protocol which people
> > > are developing.
> > >
> >
> > See:
> > http://www.erg.abdn.ac.uk/users/gerrit/dccp/patch-backlog/09a_release_ctl_socket_at_exit.diff
> >
> > This one requires a bit more thinking, so I'm postponing it for now to
> > get the simple bits in Gerrit's patch queue cherrypicked and sent for
> > Dave.
>
> One possible way to handle this is to flag certain sockets such that
> no refrence counting is done for them against the module.  It is
> an indication that the module will take care of such sockets on
> cleanup.
>
> It seems that this would limit the cost to a test at socket create
> and destroy time.

Yes, but this is not the case currently with Gerrit's proposed patch,
I'm postponing it for now, as one has to be very very careful to
monitor the TW sockets with iproute2's ss before rmmoding with
--force, have to revisit the old unload hack to combine its ideas with
SCTP/Gerrit's approach, the old one was ugly, but at least refused to
unload before all the TW sockets were gone.

- Arnaldo

[root@qemu ~]# rmmod dccp_ipv4
ERROR: Module dccp_ipv4 is in use by [unsafe]
[root@qemu ~]# rmmod --force dccp_ipv4
[  128.264180] slab error in kmem_cache_destroy(): cache
`tw_sock_DCCP': Can't free all objects
[  128.265284]  [<c0141ea7>] kmem_cache_destroy+0x77/0xd0
[  128.266133]  [<c0201dcf>] proto_unregister+0x8f/0xb0
[  128.267222]  [<d085005c>] dccp_v4_exit+0x3c/0x5b [dccp_ipv4]
[  128.268050]  [<c0128458>] sys_delete_module+0x158/0x1d0
[  128.268527]  [<c0269ada>] do_page_fault+0x4ea/0x640
[  128.269014]  [<c0102abf>] syscall_call+0x7/0xb
[  128.269472]  =======================

[root@qemu ~]# rmmod dccp
[  141.267175] slab error in kmem_cache_destroy(): cache
`dccp_bind_bucket': Can't free all objects
[  141.268392]  [<c0141ea7>] kmem_cache_destroy+0x77/0xd0
[  141.268950]  [<d0847e93>] dccp_fini+0x63/0x70 [dccp]
[  141.270046]  [<c0128458>] sys_delete_module+0x158/0x1d0
[  141.270530]  [<c013b6e4>] do_munmap+0x1c4/0x230
[  141.270964]  [<c0102abf>] syscall_call+0x7/0xb
[  141.271414]  =======================

Followed by:

<BIG SNIP>
[  147.347021]  =======================
[  147.359334] Code: c3 08 e9 69 ff ff ff eb 0d 90 90 90 90 90 90 90
90 90 90 90 90 90 55 89 cd 57 56 89 c6 53 8d 04 ca 83 ec 08 8b 10 89
e7 89 14 24 <89> 62 04 8b 50 04 89 22 89 54 24 04 89 00 8b 14 24 89 40
04 39
[  147.395025] EIP: [<c0115b05>] cascade+0x15/0x60 SS:ESP 0068:c0304fa4
[  147.403619]  <0>Kernel panic - not syncing: Fatal exception in interrupt
[  147.482149]
