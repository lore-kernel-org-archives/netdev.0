From: "David S. Miller" <davem@davemloft.net>
Subject: Re: PATCH: kmalloc packet slab
Date: Mon, 27 Dec 2004 14:23:50 -0800
Message-ID: <20041227142350.1cf444fe.davem@davemloft.net>
References: <1104156983.20944.25.camel@localhost.localdomain>
	<41D043AC.2070203@trash.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: alan@lxorguk.ukuu.org.uk, torvalds@osdl.org,
	linux-kernel@vger.kernel.org, netdev@oss.sgi.com
Return-path: <linux-kernel-owner+glk-linux-kernel=40m.gmane.org-S261641AbUL0WZb@vger.kernel.org>
To: Patrick McHardy <kaber@trash.net>
In-Reply-To: <41D043AC.2070203@trash.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, 27 Dec 2004 18:17:32 +0100
Patrick McHardy <kaber@trash.net> wrote:

> Alan Cox wrote:
> > The networking world runs in 1514 byte packets pretty much all the time.
> > This adds a 1620 byte slab for such objects and is one of the internally
> > generated Red Hat patches we use on things like Fedora Core 3. Original:
> > Arjan van de Ven.
> > 
> > Signed-off-by: Alan Cox <alan@redhat.com>
> 
> Why 1620 bytes ? Most drivers allocate packet_size + 2 bytes.
> dev_alloc_skb adds another 16 bytes, finally alloc_skb adds
> sizeof(struct skb_shared_info). So we get:
> 
> (32bit): 1514b + 2b + 16b + 160b = 1692b
> (64bit): 1514b + 2b + 16b + 312b = 1844b
> 
> On paths using alloc_skb instead of dev_alloc_skb it's 16 bytes
> less, but 1620 bytes is still too small for full-sized packets.

Absolutely, there is no way this patch actually helps for
full sized frames.  Another thing in the above equations is
that on output you have to add in MAX_TCP_HEADER which is
128 + MAX_HEADER. MAX_HEADER is variable sized based upon
which link layer support is built into the kernel.

Even on input, many ethernet device drivers add in their
own amounts to the size for DMA and cache-line alignment.

So this special slab would never be used on output even
if it got the base equations correct.

If we are really going to do something like this, it should
be calculated properly and be determined per-interface
type as netdevs are registered.

Special casing ethernet is just rediculious.
