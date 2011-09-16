From: Andy Gospodarek <andy@greyhouse.net>
Subject: Re: [PATCH net-next-2.6] e1000: don't enable dma
	receives until	after dma address has been setup
Date: Thu, 15 Sep 2011 21:50:14 -0400
Message-ID: <20110916015014.GW21309@gospo.rdu.redhat.com>
References: <20110915003138.4279.19020.email-sent-by-dnelson@localhost6.localdomain6>
	<20110915102112.0000146b@unknown>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: "Michael S. Tsirkin" <mst@redhat.com>, e1000-devel@lists.sourceforge.net,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	Dean Nelson <dnelson@redhat.com>, Andy Gospodarek <andy@greyhouse.net>
To: Jesse Brandeburg <jesse.brandeburg@intel.com>
Return-path: <e1000-devel-bounces@lists.sourceforge.net>
Content-Disposition: inline
In-Reply-To: <20110915102112.0000146b@unknown>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/e1000-devel>,
	<mailto:e1000-devel-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum_name=e1000-devel>
List-Post: <mailto:e1000-devel@lists.sourceforge.net>
List-Help: <mailto:e1000-devel-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/e1000-devel>,
	<mailto:e1000-devel-request@lists.sourceforge.net?subject=subscribe>
Errors-To: e1000-devel-bounces@lists.sourceforge.net
List-Id: netdev.vger.kernel.org

On Thu, Sep 15, 2011 at 10:21:12AM -0700, Jesse Brandeburg wrote:
> On Wed, 14 Sep 2011 17:31:38 -0700
> Dean Nelson <dnelson@redhat.com> wrote:
> 
> > Doing an 'ifconfig ethN down' followed by an 'ifconfig ethN up' on a
> > qemu-kvm guest system configured with two e1000 NICs can result in an
> > 'unable to handle kernel paging request at 0000000100000000' or 'bad
> > page map in process ...' or something similar.
> 
> <snip>
> 
> > The corruption appears to result from the following...
> > 
> >  . An 'ifconfig ethN down' gets us into e1000_close(), which through
> > a number of subfunctions results in:
> >      1. E1000_RCTL_EN being cleared in RCTL register.  [e1000_down()]
> >      2. dma_free_coherent() being called.  [e1000_free_rx_resources()]
> > 
> >  . An 'ifconfig ethN up' gets us into e1000_open(), which through a
> > number of subfunctions results in:
> >      1. dma_alloc_coherent() being called.
> > [e1000_setup_rx_resources()] 2. E1000_RCTL_EN being set in RCTL
> > register.  [e1000_setup_rctl()] 3. E1000_RCTL_EN being cleared in
> > RCTL register.  [e1000_configure_rx()] 4. RDLEN, RDBAH and RDBAL
> > registers being set to reflect the dma page allocated in step 1.
> > [e1000_configure_rx()] 5. E1000_RCTL_EN being set in RCTL register.
> > [e1000_configure_rx()]
> > 
> > During the 'ifconfig ethN up' there is a window opened, starting in
> > step 2 where the receives are enabled up until they are disabled in
> > step 3, in which the address of the receive descriptor dma page known
> > by the NIC is still the previous one which was freed during the
> > 'ifconfig ethN down'. If this memory has been reallocated for some
> > other use and the NIC feels so inclined, it will write to that former
> > dma page with predictably unpleasant results.
> > 
> > I realize that in the guest, we're dealing with an e1000 NIC that is
> > software emulated by qemu-kvm. The problem doesn't appear to occur on
> > bare-metal. Andy suspects that this is because in the emulator
> > link-up is essentially instant and traffic can start flowing
> > immediately. Whereas on bare-metal, link-up usually seems to take at
> > least a few milliseconds. And this might be enough to prevent traffic
> > from flowing into the device inside the window where E1000_RCTL_EN is
> > set.
> 
> nice analysis dean, yes, we shouldn't enable rx before we have the
> hardware all ready.
> 
> You didn't mention however that the hardware is reset in e1000_down,
> which will clear the RDBAL/RDBAH in real hardware.
> 
> > 
> > So perhaps a modification needs to be made to the qemu-kvm e1000 NIC
> > emulator to delay the link-up. But in defense of the emulator, it
> > seems like a bad idea to enable dma operations before the address of
> > the memory to be involved has been made known.
> 
> the hardware reset code in kvm should also reset to default many
> registers (almost all of them in fact) which may also end up solving
> the problem.
> 
> > 
> > The following patch no longer enables receives in e1000_setup_rctl()
> > but leaves them however they were. It only enables receives in
> > e1000_configure_rx(), and only after the dma address has been made
> > known to the hardware.
> 
> I still like your patch better as it is more correct.  We could also
> correct the kvm virtual hardware driver.
> 

I agree that the virtual hardware drivers should be fixed.  I took a
quick look at the emulation code and despite the fact that there is some
reset code that clears out registers and sets them back to default
values, I don't see it getting called when the E1000_CTRL_RST is set in
the CTRL register.

The patch below might do the trick.  This is totally untested, but it
seems appropriate based on my quick audit of that code and the driver's
expectations.

diff --git a/hw/e1000.c b/hw/e1000.c
index a6d12c5..e74dbf3 100644
--- a/hw/e1000.c
+++ b/hw/e1000.c
@@ -192,9 +192,14 @@ rxbufsize(uint32_t v)
     return 2048;
 }
 
+static void e1000_reset(void *opaque);
+
 static void
 set_ctrl(E1000State *s, int index, uint32_t val)
 {
+    /* reset the hardware registers */
+    if (val & E1000_CTRL_RST)
+       e1000_reset(s);
     /* RST is self clearing */
     s->mac_reg[CTRL] = val & ~E1000_CTRL_RST;
 }


------------------------------------------------------------------------------
BlackBerry&reg; DevCon Americas, Oct. 18-20, San Francisco, CA
http://p.sf.net/sfu/rim-devcon-copy2
_______________________________________________
E1000-devel mailing list
E1000-devel@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/e1000-devel
To learn more about Intel&#174; Ethernet, visit http://communities.intel.com/community/wired
