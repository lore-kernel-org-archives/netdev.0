From: "Andrew Grover" <andy.grover@gmail.com>
Subject: Re: RFR: New e1000 driver (e1000new),
	was: Re: e1000: backport ich9 support from 7.5.5 ?
Date: Sat, 7 Jul 2007 11:59:44 -0700
Message-ID: <c0a09e5c0707071159y4de39ff3w2562c750d9b35af4@mail.gmail.com>
References: <1183138159.17243.16.camel@blaa>
	<20070629175006.GB3917@falooley.org> <468571C6.3090305@garzik.org>
	<46857C08.4030303@intel.com>
	<20070629150350.414553d4.akpm@linux-foundation.org>
	<4685838D.9080108@garzik.org> <468594B7.6070309@intel.com>
	<468E92F8.7010501@garzik.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: Mark McLoughlin <markmc@redhat.com>,
	"Kok, Auke" <auke-jan.h.kok@intel.com>,
	e1000-devel@lists.sourceforge.net, netdev@vger.kernel.org,
	"Ronciak, John" <john.ronciak@intel.com>,
	Andrew Morton <akpm@linux-foundation.org>,
	Arjan van de Ven <arjan@linux.intel.com>,
	Jason Lunz <lunz@reflexsecurity.com>
To: "Jeff Garzik" <jeff@garzik.org>
Return-path: <e1000-devel-bounces@lists.sourceforge.net>
In-Reply-To: <468E92F8.7010501@garzik.org>
Content-Disposition: inline
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/e1000-devel>,
	<mailto:e1000-devel-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum_name=e1000-devel>
List-Post: <mailto:e1000-devel@lists.sourceforge.net>
List-Help: <mailto:e1000-devel-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/e1000-devel>,
	<mailto:e1000-devel-request@lists.sourceforge.net?subject=subscribe>
Sender: e1000-devel-bounces@lists.sourceforge.net
Errors-To: e1000-devel-bounces@lists.sourceforge.net
List-Id: netdev.vger.kernel.org

On 7/6/07, Jeff Garzik <jeff@garzik.org> wrote:
> OK, just looked through the driver.  I think its structured inside-out
> from what it should be.

> * The multitude of tiny, fine-grained operations for MAC, NVM, PHY, etc.
> is a signal that organization is backwards.  You should be creating
> hardware-specific high level operations (PHY layer hooks, net_device
> hooks, interrupt handler) that call out to more-generic functions when
> necessary.  Doing so eliminates the need to create a new hook for every
> little twirl in the code path.

I think the nice thing about the driver's organization is that it
gives a clear overview of how the driver works, without delving into
generation-specific details. This fixes a problem that the old driver
had, where it was very easy to get lost in the woods of
family-specific workarounds.

> In the long run, a driver is easier to maintain if you can easily follow
> the code path for a particular hardware generation.  Creating
> e1001_8257x_do_this_thing(), which calls more generic code as needed, is
> easier to review and doesn't require all sorts of indirection through APIs.

Basically make a library of e1000-routines. The alternative is a
polymorphic approach (i.e. using function pointers so generic code can
call specific code). Both approaches are used extensively in the
kernel -- I happen to think the latter approach is better suited to
the e1000's current issue.

(For what is a driver but specific code called from generic code? This
just reuses this helpful design pattern at a lower level.)

> Doing so also means that many workarounds for older hardware "disappear"
> from the most-travelled code paths over time.  The 64k boundary check
> found in e1000new is an easy example of something that really shouldn't
> pollute newer code at all [yes, even though it reduces to 'return 1' for
> most].

Given that the new driver would only support PCIe devices (i.e.
relatively new/good HW) I would think this would cut down on the
"workaround" hooks, leaving the "HW is genuinely different" hooks.

> * The multitude of files makes it difficult to review.  Much easier in
> one file, or a small few.

Removing support for pre-PCIe in the new driver would help alleviate this.

Regards -- Andy

-------------------------------------------------------------------------
This SF.net email is sponsored by DB2 Express
Download DB2 Express C - the FREE version of DB2 express and take
control of your XML. No limits. Just data. Click to get it now.
http://sourceforge.net/powerbar/db2/
