From: "Aubrey Li" <aubreylee@gmail.com>
Subject: Re: [PATCH] CONFIG_PACKET_MMAP should depend on MMU
Date: Fri, 20 Apr 2007 16:39:52 +0800
Message-ID: <6d6a94c50704200139vb9b24f6y77a6d23544c8f7b9@mail.gmail.com>
References: <200704091146.32346.rgetz@blackfin.uclinux.org>
	 <1176112223.17975.8.camel@roc-desktop> <9561.1176209728@redhat.com>
	 <200704101952.05380.rgetz@blackfin.uclinux.org>
	 <6d6a94c50704170336l62fc9ael1e58197e6c3853ba@mail.gmail.com>
	 <2817.1176910411@redhat.com>
	 <6d6a94c50704192146k5bbe2aefr31fa5726bf1c1e54@mail.gmail.com>
	 <1016.1177055893@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: "Robin Getz" <rgetz@blackfin.uclinux.org>, uaca@alumni.uv.es,
	bryan.wu@analog.com, "Alan Cox" <alan@lxorguk.ukuu.org.uk>,
	waltje@uwalt.nl.mugnet.org, netdev@vger.kernel.org,
	"Andrew Morton" <akpm@osdl.org>,
	"Linux Kernel" <linux-kernel@vger.kernel.org>
To: "David Howells" <dhowells@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from wr-out-0506.google.com ([64.233.184.234]:49829 "EHLO
	wr-out-0506.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S2992464AbXDTIjy (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 20 Apr 2007 04:39:54 -0400
Received: by wr-out-0506.google.com with SMTP id 76so855352wra
        for <netdev@vger.kernel.org>; Fri, 20 Apr 2007 01:39:53 -0700 (PDT)
In-Reply-To: <1016.1177055893@redhat.com>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 4/20/07, David Howells <dhowells@redhat.com> wrote:
> Aubrey Li <aubreylee@gmail.com> wrote:
>
> > The patch works properly on my side. But
> > 1) I'm not sure why you re-wrote alloc/free_pg_vec function, doesn't
> > the current implement work for NOMMU? I know you want to allocate the
> > entire data buffer as one contiguous lump, but is it really necessary?
>
> Yes.  It's not possible to map the whole buffer otherwise.  Think about it!
> mmap() returns _one_ reference address.  In MMU-mode, the non-contiguous
> physical buffers can be made to appear virtually contiguous by fudging the
> page tables and using the MMU.  This is not possible in NOMMU-mode.  The app
> will expect the buffer to be one contiguous lump in its address space, and
> will not be able to locate the other segments of the buffer.

Great explanation, thanks, :-)

>
> Actually, what I said is not quite true.  It is possible to map the whole
> buffer otherwise: I could lift the restriction that requires that you map the
> whole buffer or not at all, and then userspace could stitch the whole lot
> together itself.  This would then require userspace to be bimodal.
>
> > 2) So the mapped pages doesn't count into NR_FILE_MAPPED, is it a problem?
>
> Not really, no - there are no pagetables.
>
> Furthermore, issuing the PACKET_RX_RING sockopt does the entire allocation.
> Any subsequent mmaps on it have little effect.
>
> We could do that accounting though if you think it'd be better.  I don't
> suppose it hurts.
>
as checked in packet_set_ring, buffer size must be a multiple of PAGE_SIZE,
--------------------packet_set_ring------------------------
if (unlikely(req->tp_block_size & (PAGE_SIZE - 1)))

So why not use __get_free_pages rather than kmalloc, so that we have
pagetables to count?

-Aubrey
