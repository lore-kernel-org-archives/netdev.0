From: Evgeniy Polyakov <johnpol@2ka.mipt.ru>
Subject: Re: Fwd: Packet mmap: TX RING and zero copy
Date: Fri, 5 Sep 2008 18:59:02 +0400
Message-ID: <20080905145902.GA12762@2ka.mipt.ru>
References: <7e0dd21a0809050216r65b8f08fm1ad0630790a13a54@mail.gmail.com> <7e0dd21a0809050217v33ecb8fvcadd5e65118d6afe@mail.gmail.com> <20080905113112.GA29926@2ka.mipt.ru> <7e0dd21a0809050544m47deaf0dsf1f31805890ac09@mail.gmail.com> <20080905131618.GB12246@2ka.mipt.ru> <7e0dd21a0809050629w7fa8a914i863faa9ac18c3be4@mail.gmail.com> <20080905133748.GA28656@2ka.mipt.ru> <7e0dd21a0809050655n176ec32bo2bf4febe4e0fc363@mail.gmail.com> <20080905141911.GA16586@2ka.mipt.ru> <7e0dd21a0809050745w692328b7v6dd4e0adf59e9535@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: Johann Baudy <johaahn@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from relay.2ka.mipt.ru ([194.85.80.65]:36057 "EHLO 2ka.mipt.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752725AbYIEO72 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 5 Sep 2008 10:59:28 -0400
Content-Disposition: inline
In-Reply-To: <7e0dd21a0809050745w692328b7v6dd4e0adf59e9535@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi.

On Fri, Sep 05, 2008 at 04:45:13PM +0200, Johann Baudy (johaahn@gmail.com) wrote:
> I've finally made the test:
> Packet is not going through device due to this test:
> 	if (inet->cork.length + size > 0xFFFF - fragheaderlen) {
> 		ip_local_error(sk, EMSGSIZE, rt->rt_dst, inet->dport, mtu);
> 		return -EMSGSIZE;
> 	}
> in ip_append_page()
> 
> inet->cork.length reach 61448 then this failure occurs
> size = 4096
> fragheaderlen = 20
 
Well, udp_sendpage() needs to be extended to only append page when there
is anough free space there, otherwise push given frame and create next
packet.

> > You can always provide a global offset where to put next packet.
> > You can ajust it to put header before each data frame, and then DMA
> > frame content according to that offset.
> >
> > Transmitting packet socket is needed for those, who wants to implement
> > own low-level protocol unsupported by the kernel, so to transfer data
> > over UDP or TCP over IP with the highests speeds, one should use
> > existing methods. This does not of course mean, that anyone _has_ to do
> > it, it is always very fun to find new ways like your patch.
> >
> 
> What do you mean with global offset ?

I meant you get a pointer by mapping some file in tmpfs (for example)
and then use some offset variable to store where you put your last data
(either packet header, or data itself), so that any subsequent write to
that area (either new packet header or dma data placement) would put
data just after the previous chunk. Thus after you have put number of
headers and appropriate data chunks, you could call sendfile() and reset
offset to the beginning of the mapped area.

-- 
	Evgeniy Polyakov
