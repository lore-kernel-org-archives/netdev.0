From: KOSAKI Motohiro <kosaki.motohiro-+CUm20s59erQFUHtdCDX3A@public.gmane.org>
Subject: Re: sk_lock: inconsistent {RECLAIM_FS-ON-W} -> {IN-RECLAIM_FS-W} usage
Date: Mon,  8 Jun 2009 14:07:26 +0900 (JST)
Message-ID: <20090608140529.4376.A69D9226@jp.fujitsu.com>
References: <20090608134428.4373.A69D9226@jp.fujitsu.com> <20090608050049.GA10652@localhost>
Mime-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Content-Transfer-Encoding: 7bit
Cc: kosaki.motohiro-+CUm20s59erQFUHtdCDX3A@public.gmane.org,
	LKML <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	"linux-nfs-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <linux-nfs-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	"netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
To: Wu Fengguang <fengguang.wu-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>
Return-path: <linux-nfs-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <20090608050049.GA10652@localhost>
Sender: linux-nfs-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

> On Mon, Jun 08, 2009 at 12:55:18PM +0800, KOSAKI Motohiro wrote:
> > Hi
> > 
> > > Hi,
> > > 
> > > This lockdep warning appears when doing stress memory tests over NFS.
> > > 
> > > page reclaim => nfs_writepage => tcp_sendmsg => lock sk_lock
> > > 
> > > tcp_close => lock sk_lock => tcp_send_fin => alloc_skb_fclone => page reclaim
> > > 
> > > Any ideas?
> > 
> > AFAIK, btrfs has re-dirty hack. 
> > 
> > ------------------------------------------------------------------
> > static int btrfs_writepage(struct page *page, struct writeback_control *wbc)
> > {
> >         struct extent_io_tree *tree;
> > 
> > 
> >         if (current->flags & PF_MEMALLOC) {
> >                 redirty_page_for_writepage(wbc, page);
> >                 unlock_page(page);
> >                 return 0;
> >         }
> >         tree = &BTRFS_I(page->mapping->host)->io_tree;
> >         return extent_write_full_page(tree, page, btrfs_get_extent, wbc);
> > }
> > ---------------------------------------------------------------
> > 
> > PF_MEMALLOC mean caller is try_to_free_pages(). (not normal write nor kswapd)
> > Can't nfs does similar hack? 
> 
> But the trace shows that current is kswapd:
> 
> [ 1638.403414]  [<ffffffff811c9b69>] nfs_flush_one+0xb9/0x100
> [ 1638.419417]  [<ffffffff811c3f82>] nfs_pageio_doio+0x32/0x70
> [ 1638.419417]  [<ffffffff811c3fc9>] nfs_pageio_complete+0x9/0x10
> [ 1638.427413]  [<ffffffff811c7ee5>] nfs_writepage_locked+0x85/0xc0
> [ 1638.435414]  [<ffffffff811c8509>] nfs_writepage+0x19/0x40
> [ 1638.435414]  [<ffffffff810ce005>] shrink_page_list+0x675/0x810
> [ 1638.435414]  [<ffffffff810ce761>] shrink_list+0x301/0x650
> [ 1638.435414]  [<ffffffff810ced23>] shrink_zone+0x273/0x370
> [ 1638.435414]  [<ffffffff810cf9f9>] kswapd+0x729/0x7a0
> [ 1638.435414]  [<ffffffff810666de>] kthread+0x9e/0xb0
> [ 1638.435414]  [<ffffffff8100d0ca>] child_rip+0xa/0x20

kswapd can't hold sk-lock before calling reclaim. Thus, we don't need
care its bogus warning, I think.




--
To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
