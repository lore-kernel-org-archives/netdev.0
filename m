From: Randy Dunlap <randy.dunlap@oracle.com>
Subject: Re: atm: panic when loading clip 2nd time
Date: Fri, 19 Oct 2007 18:02:36 -0700
Message-ID: <20071019180236.cbc000a2.randy.dunlap@oracle.com>
References: <47152758.5000900@oracle.com>
	<29495f1d0710161433h6e4e90a6r32c89c2a89af2f90@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: linux-kernel <linux-kernel@vger.kernel.org>,
	NetDev <netdev@vger.kernel.org>, chas@cmf.nrl.navy.mil
To: "Nish Aravamudan" <nish.aravamudan@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from agminet01.oracle.com ([141.146.126.228]:49780 "EHLO
	agminet01.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751291AbXJTBEx (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 19 Oct 2007 21:04:53 -0400
In-Reply-To: <29495f1d0710161433h6e4e90a6r32c89c2a89af2f90@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, 16 Oct 2007 14:33:38 -0700 Nish Aravamudan wrote:

> On 10/16/07, Randy Dunlap <randy.dunlap@oracle.com> wrote:
> > 2.6.23-git7, using SLAB (not SLUB) [config attached]:
> >
> > # modprobe clip
> > # rmmod clip
> > # modprobe clip
> >
> > results in panic:
> >
> > kmem_cache_create: duplicate cache clip_arp_cache
> >
> > Call Trace:
> >  [<ffffffff8028c682>] kmem_cache_create+0x3bf/0x3fd
> >  [<ffffffff8046ba1d>] neigh_table_init_no_netlink+0x6c/0x242
> >  [<ffffffff8800a010>] :clip:atm_clip_init+0x10/0x8a
> >  [<ffffffff80258ba4>] sys_init_module+0x146c/0x15cd
> >  [<ffffffff8046be0a>] neigh_lookup+0x0/0xd5
> >  [<ffffffff8020ef44>] syscall_trace_enter+0x95/0x99
> >  [<ffffffff8020beec>] tracesys+0xdc/0xe1
> >
> > Kernel panic - not syncing: kmem_cache_create(): failed to create slab `clip_arp_cache'
> 
> >From a quick read through the code, looks like
> net/core/neighbour.c:neigh_table_clear() needs a kmem_cache_destroy()?
> 
> I only see three callers of neight_table_clear() and they all seem to
> be in exit routines, so that should be safe?

Hi Nish,

Maybe.  I can't tell without knowing the code better.

[make that patch, test it; test patch is below]

Well, it survives light testing (boot/init and a tarball download),
but I don't know how safe it is.

---

From: Randy Dunlap <randy.dunlap@oracle.com>

net/atm/clip.c crashes the kernel if it (module) is loaded, removed,
and then loaded again.  Its exit call to neigh_table_clear()
should destroy the cache after freeing it.

Signed-off-by: Randy Dunlap <randy.dunlap@oracle.com>
---
 net/core/neighbour.c |    3 +++
 1 file changed, 3 insertions(+)

--- linux-2.6.23-git7.orig/net/core/neighbour.c
+++ linux-2.6.23-git7/net/core/neighbour.c
@@ -1436,6 +1436,9 @@ int neigh_table_clear(struct neigh_table
 	free_percpu(tbl->stats);
 	tbl->stats = NULL;
 
+	kmem_cache_destroy(tbl->kmem_cachep);
+	tbl->kmem_cachep = NULL;
+
 	return 0;
 }
 
