From: David Miller <davem@davemloft.net>
Subject: Re: pktgen
Date: Tue, 28 Nov 2006 15:33:25 -0800 (PST)
Message-ID: <20061128.153325.10304536.davem@davemloft.net>
References: <20061121174737.GA5220@martell.zuzino.mipt.ru>
	<9fa31860611211236i104cb510mb5100ea056b657db@mail.gmail.com>
	<20061121212251.GA5084@martell.zuzino.mipt.ru>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: pavol.gono@gmail.com, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:52203
	"EHLO sunset.davemloft.net") by vger.kernel.org with ESMTP
	id S1757960AbWK1XdS (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 28 Nov 2006 18:33:18 -0500
To: adobriyan@gmail.com
In-Reply-To: <20061121212251.GA5084@martell.zuzino.mipt.ru>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Alexey Dobriyan <adobriyan@gmail.com>
Date: Wed, 22 Nov 2006 00:22:51 +0300

> [CCing netdev, bug in pktgen]
> 
> 	[build modular pktgen]
> 	while true; do modprobe pktgen && rmmod pktgen; done
> 
> 	BUG: warning at fs/proc/generic.c:732/remove_proc_entry()
> 	 [<c016a7ad>] remove_proc_entry+0x161/0x1ca
> 	 [<e19969ab>] pg_cleanup+0xd5/0xdc [pktgen]
>          [<c011fa3e>] autoremove_wake_function+0x0/0x35
> 	 [<c01280bd>] sys_delete_module+0x162/0x189
> 	 [<c0136500>] remove_vma+0x31/0x36
> 	 [<c0136df7>] do_munmap+0x193/0x1ac
> 	 [<c0102829>] sysenter_past_esp+0x56/0x79
> 	 [<c02d007b>] fn_hash_delete+0x4f/0x1c7
> 
> On Tue, Nov 21, 2006 at 09:36:46PM +0100, Pavol Gono wrote:
> > I am going to add two more:
> > for i in 1 2 3 4 5 ; do modprobe pktgen ; rmmod pktgen ; done
> 
> Looks like it creates /proc/net/pktgen/kpktgen_%i but forgets to remove
> them.

It's pretty careful to delete all of the entries under
/proc/net/pktgen/.

When the module is brought down, it walks the list of threads
and brings them down by setting T_TERMINATE in t->control.
This makes the thread break out of it's loop and run:

	pktgen_stop(t);
	pktgen_rem_all_ifs(t);
	pktgen_rem_thread(t);

pktgen_rem_all_ifs() will delete all device entries in
/proc/net/pktgen/

Next, pktgen_rem_thread() will kill off the entry for
/proc/net/pktgen/kpkgen_%i

Finally, the top-level module remove code will delete the
control file right before it tries to kill off the directory
via:

	/* Clean up proc file system */
	remove_proc_entry(PGCTRL, pg_proc_dir);
	proc_net_remove(PG_PROC_DIR);

So I don't see any bugs that could cause this.

One possibility is that the thread's t->name is being
corrupted somehow, that would make the remove_proc_entry()
fail and cause the behavior you see.  But I can't see anything
obvious that might do that either.
