From: KOSAKI Motohiro <kosaki.motohiro-+CUm20s59erQFUHtdCDX3A@public.gmane.org>
Subject: Re: sk_lock: inconsistent {RECLAIM_FS-ON-W} -> {IN-RECLAIM_FS-W} usage
Date: Mon,  8 Jun 2009 13:55:18 +0900 (JST)
Message-ID: <20090608134428.4373.A69D9226@jp.fujitsu.com>
References: <20090608023757.GA6244@localhost>
Mime-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Content-Transfer-Encoding: 7bit
Cc: kosaki.motohiro-+CUm20s59erQFUHtdCDX3A@public.gmane.org,
	LKML <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, linux-nfs-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: Wu Fengguang <fengguang.wu-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>
Return-path: <linux-nfs-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <20090608023757.GA6244@localhost>
Sender: linux-nfs-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

Hi

> Hi,
> 
> This lockdep warning appears when doing stress memory tests over NFS.
> 
> page reclaim => nfs_writepage => tcp_sendmsg => lock sk_lock
> 
> tcp_close => lock sk_lock => tcp_send_fin => alloc_skb_fclone => page reclaim
> 
> Any ideas?

AFAIK, btrfs has re-dirty hack. 

------------------------------------------------------------------
static int btrfs_writepage(struct page *page, struct writeback_control *wbc)
{
        struct extent_io_tree *tree;


        if (current->flags & PF_MEMALLOC) {
                redirty_page_for_writepage(wbc, page);
                unlock_page(page);
                return 0;
        }
        tree = &BTRFS_I(page->mapping->host)->io_tree;
        return extent_write_full_page(tree, page, btrfs_get_extent, wbc);
}
---------------------------------------------------------------

PF_MEMALLOC mean caller is try_to_free_pages(). (not normal write nor kswapd)
Can't nfs does similar hack? 


I'm not net nor nfs expert. perhaps I'm wrong :-)


Thanks.



--
To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
