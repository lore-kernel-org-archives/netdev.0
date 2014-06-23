From: Joe Perches <joe@perches.com>
Subject: Re: [PATCH 00/22] Add and use pci_zalloc_consistent
Date: Mon, 23 Jun 2014 12:13:29 -0700
Message-ID: <1403550809.15811.13.camel@joe-AO725>
References: <cover.1403530604.git.joe@perches.com>
 <20140623172512.GA1390@garbanzo.do-not-panic.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: devel@driverdev.osuosl.org, linux-arch@vger.kernel.org,
 linux-scsi@vger.kernel.org, iss_storagedev@hp.com, linux-rdma@vger.kernel.org,
 netdev@vger.kernel.org, linux-atm-general@lists.sourceforge.net,
 linux-wireless@vger.kernel.org, linux-kernel@vger.kernel.org,
 dri-devel@lists.freedesktop.org, linux-crypto@vger.kernel.org,
 linux-media@vger.kernel.org, linux-eata@i-connect.net
To: "Luis R. Rodriguez" <mcgrof@do-not-panic.com>, Arnd Bergmann
 <arnd@arndb.de>
Return-path: <dri-devel-bounces@lists.freedesktop.org>
In-Reply-To: <20140623172512.GA1390@garbanzo.do-not-panic.com>
List-Unsubscribe: <http://lists.freedesktop.org/mailman/options/dri-devel>,
 <mailto:dri-devel-request@lists.freedesktop.org?subject=unsubscribe>
List-Archive: <http://lists.freedesktop.org/archives/dri-devel>
List-Post: <mailto:dri-devel@lists.freedesktop.org>
List-Help: <mailto:dri-devel-request@lists.freedesktop.org?subject=help>
List-Subscribe: <http://lists.freedesktop.org/mailman/listinfo/dri-devel>,
 <mailto:dri-devel-request@lists.freedesktop.org?subject=subscribe>
Errors-To: dri-devel-bounces@lists.freedesktop.org
Sender: "dri-devel" <dri-devel-bounces@lists.freedesktop.org>
List-Id: netdev.vger.kernel.org

On Mon, 2014-06-23 at 10:25 -0700, Luis R. Rodriguez wrote:
> On Mon, Jun 23, 2014 at 06:41:28AM -0700, Joe Perches wrote:
> > Adding the helper reduces object code size as well as overall
> > source size line count.
> > 
> > It's also consistent with all the various zalloc mechanisms
> > in the kernel.
> > 
> > Done with a simple cocci script and some typing.
> 
> Awesome, any chance you can paste in the SmPL? Also any chance
> we can get this added to a make coccicheck so that maintainers
> moving forward can use that to ensure that no new code is
> added that uses the old school API?

Not many of these are recent.

Arnd Bergmann reasonably suggested that the pci_alloc_consistent
api be converted the the more widely used dma_alloc_coherent.

https://lkml.org/lkml/2014/6/23/513

> Shouldn't these drivers just use the normal dma-mapping API now?

and I replied:

https://lkml.org/lkml/2014/6/23/525

> Maybe.  I wouldn't mind.
> They do seem to have a trivial bit of unnecessary overhead for 
> hwdev == NULL ? NULL : &hwdev->dev

Anyway, here's the little script.
I'm not sure it's worthwhile to add it though.

$ cat ./scripts/coccinelle/api/alloc/pci_zalloc_consistent.cocci
///
/// Use pci_zalloc_consistent rather than
///     pci_alloc_consistent followed by memset with 0
///
/// This considers some simple cases that are common and easy to validate
/// Note in particular that there are no ...s in the rule, so all of the
/// matched code has to be contiguous
///
/// Blatantly cribbed from: scripts/coccinelle/api/alloc/kzalloc-simple.cocci

@@
type T, T2;
expression x;
expression E1,E2,E3;
statement S;
@@

- x = (T)pci_alloc_consistent(E1,E2,E3);
+ x = pci_zalloc_consistent(E1,E2,E3);
  if ((x==NULL) || ...) S
- memset((T2)x,0,E2);
