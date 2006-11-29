From: Alexey Dobriyan <adobriyan@gmail.com>
Subject: Re: pktgen
Date: Wed, 29 Nov 2006 23:04:37 +0300
Message-ID: <20061129200437.GA5152@martell.zuzino.mipt.ru>
References: <20061121174737.GA5220@martell.zuzino.mipt.ru> <9fa31860611211236i104cb510mb5100ea056b657db@mail.gmail.com> <20061121212251.GA5084@martell.zuzino.mipt.ru> <20061128.153325.10304536.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: pavol.gono@gmail.com, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from nf-out-0910.google.com ([64.233.182.187]:9666 "EHLO
	nf-out-0910.google.com") by vger.kernel.org with ESMTP
	id S936008AbWK2UEl (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 29 Nov 2006 15:04:41 -0500
Received: by nf-out-0910.google.com with SMTP id o25so3011424nfa
        for <netdev@vger.kernel.org>; Wed, 29 Nov 2006 12:04:38 -0800 (PST)
To: David Miller <davem@davemloft.net>
Content-Disposition: inline
In-Reply-To: <20061128.153325.10304536.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, Nov 28, 2006 at 03:33:25PM -0800, David Miller wrote:
> From: Alexey Dobriyan <adobriyan@gmail.com>
> Date: Wed, 22 Nov 2006 00:22:51 +0300
> 
> > [CCing netdev, bug in pktgen]
> > 
> > 	[build modular pktgen]
> > 	while true; do modprobe pktgen && rmmod pktgen; done
> > 
> > 	BUG: warning at fs/proc/generic.c:732/remove_proc_entry()
> > 	 [<c016a7ad>] remove_proc_entry+0x161/0x1ca
> > 	 [<e19969ab>] pg_cleanup+0xd5/0xdc [pktgen]
> >          [<c011fa3e>] autoremove_wake_function+0x0/0x35
> > 	 [<c01280bd>] sys_delete_module+0x162/0x189
> > 	 [<c0136500>] remove_vma+0x31/0x36
> > 	 [<c0136df7>] do_munmap+0x193/0x1ac
> > 	 [<c0102829>] sysenter_past_esp+0x56/0x79
> > 	 [<c02d007b>] fn_hash_delete+0x4f/0x1c7
> > 
> > On Tue, Nov 21, 2006 at 09:36:46PM +0100, Pavol Gono wrote:
> > > I am going to add two more:
> > > for i in 1 2 3 4 5 ; do modprobe pktgen ; rmmod pktgen ; done
> > 
> > Looks like it creates /proc/net/pktgen/kpktgen_%i but forgets to remove
> > them.
>
> It's pretty careful to delete all of the entries under
> /proc/net/pktgen/.
>
> When the module is brought down, it walks the list of threads
> and brings them down by setting T_TERMINATE in t->control.

Looks like worker thread strategically clears it if scheduled at wrong
moment.

--- a/net/core/pktgen.c
+++ b/net/core/pktgen.c
@@ -3292,7 +3292,6 @@ static void pktgen_thread_worker(struct
 
 	init_waitqueue_head(&t->queue);
 
-	t->control &= ~(T_TERMINATE);
 	t->control &= ~(T_RUN);
 	t->control &= ~(T_STOP);
 	t->control &= ~(T_REMDEVALL);

> This makes the thread break out of it's loop and run:
>
> 	pktgen_stop(t);
> 	pktgen_rem_all_ifs(t);
> 	pktgen_rem_thread(t);

Kernel seeems to survive, but when I hit Ctrl+C after half
a minute backtrace is back being the very last dmesg lines.

