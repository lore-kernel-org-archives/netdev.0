From: Dmitry Torokhov <dtor@vmware.com>
Subject: Re: [PATCH] vhost-scsi: Depend on NET for memcpy_fromiovec
Date: Mon, 20 May 2013 09:43:57 -0700
Message-ID: <4256914.YOKOpFu49M@dtor-d630.eng.vmware.com>
References: <20130515095558.918f2b29ba318a477eb5dde2@canb.auug.org.au> <87ppwq858q.fsf@rustcorp.com.au> <20130520020714.GA1386@hj.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7Bit
Cc: Rusty Russell <rusty@rustcorp.com.au>,
	Randy Dunlap <rdunlap@infradead.org>,
	Joe Perches <joe@perches.com>,
	"Michael S. Tsirkin" <mst@redhat.com>,
	Nicholas Bellinger <nab@linux-iscsi.org>,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	George Zhang <georgezhang@vmware.com>
To: Asias He <asias@redhat.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20130520020714.GA1386@hj.localdomain>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Monday, May 20, 2013 10:07:14 AM Asias He wrote:
> On Fri, May 17, 2013 at 04:25:49PM +0930, Rusty Russell wrote:
> > Randy Dunlap <rdunlap@infradead.org> writes:
> > > On 05/16/13 16:42, Rusty Russell wrote:
> > >> Joe Perches <joe@perches.com> writes:
> > >>> On Thu, 2013-05-16 at 13:04 +0930, Rusty Russell wrote:
> > >>>> Asias He <asias@redhat.com> writes:
> > >>>>> On Wed, May 15, 2013 at 02:47:53PM +0930, Rusty Russell wrote:
> > >>> []
> > >>> 
> > >>>>> Other users are using memcpy_fromiovec and friends outside net. It
> > >>>>> seems
> > >>>>> a good idea to put it in a util library. e.g. 
> > >>>>> crypto/algif_skcipher.c
> > >>>>> which also depends on NET for it.
> > >>> 
> > >>> []
> > >>> 
> > >>>> Subject: Hoist memcpy_fromiovec into lib/
> > >>> 
> > >>> You'll need the "friends" memcpy_toiovec too.
> > >>> 
> > >>> $ git grep -E \bmemcpy\w+iovec\w*"
> > >>> crypto/algif_hash.c:    err = memcpy_toiovec(msg->msg_iov,
> > >>> ctx->result, len); crypto/algif_skcipher.c:                       
> > >>> err = memcpy_fromiovec(page_address(sg_page(sg)) +
> > >>> crypto/algif_skcipher.c:                        err =
> > >>> memcpy_fromiovec(page_address(sg_page(sg + i)),
> > >>> drivers/dma/iovlock.c:#include <net/tcp.h> /* for memcpy_toiovec */
> > >>> drivers/dma/iovlock.c:          return memcpy_toiovec(iov, kdata,
> > >>> len); drivers/dma/iovlock.c:          err = memcpy_toiovec(iov, vaddr
> > >>> + offset, len); drivers/isdn/mISDN/socket.c:    if
> > >>> (memcpy_fromiovec(skb_put(skb, len), msg->msg_iov, len)) {
> > >>> drivers/misc/vmw_vmci/vmci_queue_pair.c:                        err =
> > >>> memcpy_fromiovec((u8 *)va + page_o
> > >>> drivers/misc/vmw_vmci/vmci_queue_pair.c:                        err =
> > >>> memcpy_toiovec(iov, (u8 *)va + pag> >> 
> > >> Fascinating.  These all indirectly depend on NET, so there's no problem
> > >> at the moment.  But it is a bit weird...
> > >> 
> > >> crypto/algif_hash.c: depends on CRYPTO_USER_API_HASH -> NET
> > >> crypto/algif_skcipher.c: depends on CRYPTO_USER_API_SKCIPHER -> NET
> > >> drivers/dma/iovlock.c: depends on NET_DMA -> NET
> > >> drivers/isdn/mISDN/socket.c: depends on MISDN -> ISDN -> NET
> > >> drivers/misc/vmw_vmci/vmci_queue_pair.c: depends on VMCI -> NET
> > >> 
> > >> Patch welcome.
> > >> 
> > >> Meanwhile, to avoid more bikeshedding I've put the patch I posted with
> > >> all acks in my fixes branch.  One cycle through linux-next, then
> > >> straight to Linus.
> > > 
> > > I agree with whoever suggested that more be moved into /lib.
> > > E.g., drivers/misc/vmw_vmci/Kconfig uses "depends on NET" because the
> > > code there uses both memcpy_toiovec() and memcpy_fromiovec().
> > > See commit ID 6d4f0139d642c45411a47879325891ce2a7c164a.
> > 
> > (CC's trimmed).
> > 
> > You Acked that commit :(
> > 
> > At a glance, the only way to drive the vmw_vmci device is through
> > net/vmw_vsock/vmci_transport.c, so without NET it's useless?  But let's
> > keep it neat anyway.  This was compiletested with CONFIG_VMCI,
> > CONFIG_DMA_ENGINE and !CONFIG_NET.
> > 
> > Thanks,
> > Rusty.
> > 
> > From: Rusty Russell <rusty@rustcorp.com.au>
> > Subject: [PATCH] Hoist memcpy_fromiovec/memcpy_toiovec into lib/
> > 
> > ERROR: "memcpy_fromiovec" [drivers/vhost/vhost_scsi.ko] undefined!
> > 
> > That function is only present with CONFIG_NET.  Turns out that
> > crypto/algif_skcipher.c also uses that outside net, but it actually
> > needs sockets anyway.
> > 
> > In addition, commit 6d4f0139d642c45411a47879325891ce2a7c164a added
> > CONFIG_NET dependency to CONFIG_VMCI for memcpy_toiovec, so hoist
> > that function and revert that commit too.
> > 
> > socket.h already include uio.h, so no callers *need* updating,
> > though I update the obvious ones.
> > 
> > Reported-by: Randy Dunlap <rdunlap@infradead.org>
> > Acked-by: David S. Miller <davem@davemloft.net>
> > Acked-by: Michael S. Tsirkin <mst@redhat.com>
> > Signed-off-by: Rusty Russell <rusty@rustcorp.com.au>
> 
> Acked-by: Asias He <asias@redhat.com>

Acked-by: Dmitry Torokhov <dtor@vmware.com>

Thanks,
Dmitry
