From: Russell King - ARM Linux <linux@arm.linux.org.uk>
Subject: Re: [PATCH] af_packet: flush complete kernel cache in packet_sendmsg
Date: Tue, 6 Sep 2011 10:57:22 +0100
Message-ID: <20110906095722.GK6619@n2100.arm.linux.org.uk>
References: <20110505141107.GC30443@orbit.nwl.cc>
	<1314961686-30870-1-git-send-email-phil.sutter@viprinet.com>
	<1314971179.3092.159.camel@deadeye>
	<20110902172850.GB6619@n2100.arm.linux.org.uk>
	<20110905195714.GC29025@philter>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: Ben Hutchings <bhutchings@solarflare.com>, netdev@vger.kernel.org,
	"David S. Miller" <davem@davemloft.net>,
	linux-arm-kernel@lists.infradead.org
To: Phil Sutter <phil.sutter@viprinet.com>
Return-path: <linux-arm-kernel-bounces+linux-arm-kernel=m.gmane.org@lists.infradead.org>
Content-Disposition: inline
In-Reply-To: <20110905195714.GC29025@philter>
List-Unsubscribe: <http://lists.infradead.org/mailman/options/linux-arm-kernel>,
	<mailto:linux-arm-kernel-request@lists.infradead.org?subject=unsubscribe>
List-Archive: <http://lists.infradead.org/pipermail/linux-arm-kernel/>
List-Post: <mailto:linux-arm-kernel@lists.infradead.org>
List-Help: <mailto:linux-arm-kernel-request@lists.infradead.org?subject=help>
List-Subscribe: <http://lists.infradead.org/mailman/listinfo/linux-arm-kernel>,
	<mailto:linux-arm-kernel-request@lists.infradead.org?subject=subscribe>
Sender: linux-arm-kernel-bounces@lists.infradead.org
Errors-To: linux-arm-kernel-bounces+linux-arm-kernel=m.gmane.org@lists.infradead.org
List-Id: netdev.vger.kernel.org

On Mon, Sep 05, 2011 at 09:57:14PM +0200, Phil Sutter wrote:
> Hi,
> 
> On Fri, Sep 02, 2011 at 06:28:50PM +0100, Russell King - ARM Linux wrote:
> > On Fri, Sep 02, 2011 at 02:46:17PM +0100, Ben Hutchings wrote:
> > > On Fri, 2011-09-02 at 13:08 +0200, Phil Sutter wrote:
> > > > This flushes the cache before and after accessing the mmapped packet
> > > > buffer. It seems like the call to flush_dcache_page from inside
> > > > __packet_get_status is not enough on Kirkwood (or ARM in general).
> > > > ---
> > > > I know this is far from an optimal solution, but it's in fact the only working
> > > > one I found.
> > > [...]
> > > 
> > > This is ridiculous.  If flush_dcache_page() isn't doing everything it
> > > should, you need to fix that.
> > 
> > It does do everything it should - which is to perform maintanence on
> > page cache pages.  It flushes the kernel mapping of the page.  It
> > also flushes the userspace mappings of the page which it finds by
> > walking the mmap list via the associated struct page.  It does not
> > touch vmalloc mappings because it has no way to know whether they
> > exist or not.
> > 
> > It doesn't do so much for anonymous pages - to do so would only
> > duplicate what flush_anon_page() does at the very same callsites.
> > Plus the mmap list isn't available for such pages so there's no
> > way to find out what userspace addresses to flush.
> 
> Indeed very interesting information, thanks a lot!
> 
> The code in question uses __get_free_pages(), and if that fails uses
> vmalloc() (see alloc_one_pg_vec_page() for reference). Both code paths
> show result in the same faulty behaviour.

So, what you're wanting is cache coherency between vmalloc() and
userspace.  There is no API in the kernel to do that, and you'll see
the same failures of this interface not only on ARM but also other
architectures with virtual caches.

It sounds like we need an API to flush the cache using both the
userspace address, plus the kernel side address be that in the direct
map or the vmalloc map areas.

Or maybe the right solution is to simply disable AF_PACKET MMAP support
for virtual cached architectures - it may be that adding cache flushing
calls makes the thing too expensive and the benefits of mmap over normal
read/write are lost.
