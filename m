From: Wu Fengguang <fengguang.wu-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>
Subject: Re: sk_lock: inconsistent {RECLAIM_FS-ON-W} -> {IN-RECLAIM_FS-W}
	usage
Date: Tue, 9 Jun 2009 11:07:26 +0800
Message-ID: <20090609030726.GA8026@localhost>
References: <20090608023757.GA6244@localhost> <20090608134428.4373.A69D9226@jp.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: LKML <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	"linux-nfs-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <linux-nfs-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	"netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	"linux-btrfs-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <linux-btrfs-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	"chris.mason-QHcLZuEGTsvQT0dZR+AlfA@public.gmane.org" <chris.mason-QHcLZuEGTsvQT0dZR+AlfA@public.gmane.org>
To: KOSAKI Motohiro <kosaki.motohiro-+CUm20s59erQFUHtdCDX3A@public.gmane.org>
Return-path: <linux-nfs-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <20090608134428.4373.A69D9226-+CUm20s59erQFUHtdCDX3A@public.gmane.org>
Sender: linux-nfs-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Mon, Jun 08, 2009 at 12:55:18PM +0800, KOSAKI Motohiro wrote:
> Hi
> 
> > Hi,
> > 
> > This lockdep warning appears when doing stress memory tests over NFS.
> > 
> > page reclaim => nfs_writepage => tcp_sendmsg => lock sk_lock
> > 
> > tcp_close => lock sk_lock => tcp_send_fin => alloc_skb_fclone => page reclaim
> > 
> > Any ideas?
> 
> AFAIK, btrfs has re-dirty hack. 
> 
> ------------------------------------------------------------------
> static int btrfs_writepage(struct page *page, struct writeback_control *wbc)
> {
>         struct extent_io_tree *tree;
> 
> 
>         if (current->flags & PF_MEMALLOC) {
>                 redirty_page_for_writepage(wbc, page);
>                 unlock_page(page);
>                 return 0;
>         }
>         tree = &BTRFS_I(page->mapping->host)->io_tree;
>         return extent_write_full_page(tree, page, btrfs_get_extent, wbc);
> }
> ---------------------------------------------------------------
> 
> PF_MEMALLOC mean caller is try_to_free_pages(). (not normal write nor kswapd)

No, kswapd also sets the PF_MEMALLOC flag. It looks like btrfs_writepage()
is trying to avoid inefficient page outs at the cost of pinning dirty
pages in memory (even when we really want free pages).

Thanks,
Fengguang

> Can't nfs does similar hack? 
> 
> 
> I'm not net nor nfs expert. perhaps I'm wrong :-)
> 
> 
> Thanks.
> 
> 
--
To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
