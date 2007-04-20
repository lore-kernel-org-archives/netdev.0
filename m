From: David Howells <dhowells@redhat.com>
Subject: Re: [PATCH] CONFIG_PACKET_MMAP should depend on MMU
Date: Fri, 20 Apr 2007 08:58:13 +0100
Message-ID: <1016.1177055893@redhat.com>
References: <6d6a94c50704192146k5bbe2aefr31fa5726bf1c1e54@mail.gmail.com>  <200704091146.32346.rgetz@blackfin.uclinux.org> <1176112223.17975.8.camel@roc-desktop> <9561.1176209728@redhat.com> <200704101952.05380.rgetz@blackfin.uclinux.org> <6d6a94c50704170336l62fc9ael1e58197e6c3853ba@mail.gmail.com> <2817.1176910411@redhat.com>
Cc: "Robin Getz" <rgetz@blackfin.uclinux.org>, uaca@alumni.uv.es,
	bryan.wu@analog.com, "Alan Cox" <alan@lxorguk.ukuu.org.uk>,
	waltje@uwalt.nl.mugnet.org, netdev@vger.kernel.org,
	"Andrew Morton" <akpm@osdl.org>,
	"Linux Kernel" <linux-kernel@vger.kernel.org>
To: "Aubrey Li" <aubreylee@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([66.187.233.31]:53112 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S2992425AbXDTIAJ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 20 Apr 2007 04:00:09 -0400
In-Reply-To: <6d6a94c50704192146k5bbe2aefr31fa5726bf1c1e54@mail.gmail.com> 
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Aubrey Li <aubreylee@gmail.com> wrote:

> The patch works properly on my side. But
> 1) I'm not sure why you re-wrote alloc/free_pg_vec function, doesn't
> the current implement work for NOMMU? I know you want to allocate the
> entire data buffer as one contiguous lump, but is it really necessary?

Yes.  It's not possible to map the whole buffer otherwise.  Think about it!
mmap() returns _one_ reference address.  In MMU-mode, the non-contiguous
physical buffers can be made to appear virtually contiguous by fudging the
page tables and using the MMU.  This is not possible in NOMMU-mode.  The app
will expect the buffer to be one contiguous lump in its address space, and
will not be able to locate the other segments of the buffer.

Actually, what I said is not quite true.  It is possible to map the whole
buffer otherwise: I could lift the restriction that requires that you map the
whole buffer or not at all, and then userspace could stitch the whole lot
together itself.  This would then require userspace to be bimodal.

> 2) So the mapped pages doesn't count into NR_FILE_MAPPED, is it a problem?

Not really, no - there are no pagetables.

Furthermore, issuing the PACKET_RX_RING sockopt does the entire allocation.
Any subsequent mmaps on it have little effect.

We could do that accounting though if you think it'd be better.  I don't
suppose it hurts.

David
