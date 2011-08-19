From: Ian Campbell <Ian.Campbell-Sxgqhf6Nn4DQT0dZR+AlfA@public.gmane.org>
Subject: [PATCH/RFC v3 0/75] enable SKB paged fragment lifetime visibility
Date: Fri, 19 Aug 2011 14:26:33 +0100
Message-ID: <1313760393.5010.356.camel@zakaz.uk.xensource.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
To: "netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	"linux-nfs-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <linux-nfs-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Return-path: <linux-nfs-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Sender: linux-nfs-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

Hi,

This is v3 of my series to enable visibility into SKB paged fragment's
lifecycles, v1 is at [0] and contains some more background and rational=
e
but basically the series allows entities which inject pages into the
networking stack to receive a notification when the stack has really
finished with those pages (i.e. including retransmissions, clones,
pull-ups etc) and not just when the original skb is finished with, whic=
h
is beneficial to many subsystems which wish to inject pages into the
network stack without giving up full ownership of those page's
lifecycle. It implements something broadly along the lines of what was
described in [1].

I have updated based on the feedback from v2. In particular:
      * Rebase to v3.2-rc2
      * Rework to move reliance on core struct page const'ness change t=
o
        end or series (David Miller).=20
      * Remove inadvertent semantic change to drivers/atm/eni.c (David)
      * Add skb_frag_set_destructor instead of adding a parameter to
        skb_fill_page_desc (Micha=C5=82 Miros=C5=82aw)
      * Resolved conflict with skb zero-copy buffers (nb: I revolved
        this with no functional change but I have a suspicion that this
        could be vastly simplified using the new destructor hook,
        although I've not looked all that closely)
      * Split drivers/* patches up from the huge monolithic patch.
      * Build tested defconfig on a bunch architectures (arm i386 m68k
        mips64 mips s390x sparc64 x86_64) and fixed a variety of issues
        arising from this.
      * Unfortunately I found an interesting breakage in
        kernel/signals.c arising from the additional #include of
        highmem.h in skbuff.h which. See:
        http://lkml.kernel.org/r/1313675198-7413-1-git-send-email-ian.c=
ampbell-Sxgqhf6Nn4DQT0dZR+AlfA@public.gmane.org I split the addition of skb_frag_kmap out and moved =
it to the end of the series to avoid this blocking the rest.
      * s/kmap_skb_frag/skb_frag_kmap_atomic/ (similar for kunmap) sinc=
e
        the names kmap_skb_frag and skb_frag_kmap were confusingly
        similar. At the same time I moved them to skbuff.h since they
        are used in a couple of places outside net/core (open coded in
        drivers/scsi/fcoe/fcoe.c and #include "../core/kmap_skb.h" in
        net/appletalk/ddp.c)

Changes between v1 and v2:
      * Added destructor directly to sendpage() protocol hooks instead
        of inventing sendpage_destructor() (David Miller)
      * Dropped skb_frag_pci_map in favour of skb_frag_dma_map on Micha=
=C5=82
        Miros=C5=82aw's advice
      * Pushed the NFS fix down into the RPC layer. (Trond)
      * I also split out the patches to make protocols use the new
        interface into per-protocol patches. I held back on splitting u=
p
        the patch to drivers/* (since that will cause an explosion in
        the series length) -- I'll do this split for v3.

I've a bit of an open dilemma regarding what to do about the small
number of drivers which use skb_frag_t as part of their internal
datastructures (it's a convenient page+offset+len container). It's a bi=
t
ugly sprinkling the ".p" in around those drivers. I've considered
leaving skb_frag_t alone and defining skb_shared_info->frag as an
anonymous struct with the new layout (i.e. repurposing the existing
skb_frag_t for the alternative use and making a new struct for the
traditional/proper use). This would need a new accessor to copy one to
the other. Alternatively perhaps a generic struct subpage would be
useful in its own right and I could transition those drivers to that?
Opinions?

=46or v4 I will investigate that issue, collect maintainers ACKs and
rebase over the big drivers/net re-org which is going on (lets see what
git rebase is made of ;-))

Cheers,
Ian.

[0] http://marc.info/?l=3Dlinux-netdev&m=3D131072801125521&w=3D2
[1] http://marc.info/?l=3Dlinux-netdev&m=3D130925719513084&w=3D2

--
To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
