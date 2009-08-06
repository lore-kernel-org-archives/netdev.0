From: "Ira W. Snyder" <iws@ovro.caltech.edu>
Subject: Re: [PATCH 1/7] shm-signal: shared-memory signals
Date: Thu, 6 Aug 2009 13:51:09 -0700
Message-ID: <20090806205109.GA1330@ovro.caltech.edu>
References: <20090803171030.17268.26962.stgit@dev.haskins.net> <20090803171735.17268.37490.stgit@dev.haskins.net> <200908061556.55390.arnd@arndb.de> <4A7ABA530200005A00051C18@sinclair.provo.novell.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Arnd Bergmann <arnd@arndb.de>, paulmck@linux.vnet.ibm.com,
	alacrityvm-devel@lists.sourceforge.net,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org
To: Gregory Haskins <ghaskins@novell.com>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1756720AbZHFUvN@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <4A7ABA530200005A00051C18@sinclair.provo.novell.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, Aug 06, 2009 at 09:11:15AM -0600, Gregory Haskins wrote:
> Hi Arnd,
> 
> >>> On 8/6/2009 at  9:56 AM, in message <200908061556.55390.arnd@arndb.de>, Arnd
> Bergmann <arnd@arndb.de> wrote: 
> > On Monday 03 August 2009, Gregory Haskins wrote:
> >> shm-signal provides a generic shared-memory based bidirectional
> >> signaling mechanism.  It is used in conjunction with an existing
> >> signal transport (such as posix-signals, interrupts, pipes, etc) to
> >> increase the efficiency of the transport since the state information
> >> is directly accessible to both sides of the link.  The shared-memory
> >> design provides very cheap access to features such as event-masking
> >> and spurious delivery mititgation, and is useful implementing higher
> >> level shared-memory constructs such as rings.
> > 
> > Looks like a very useful feature in general.
> 
> Thanks, I was hoping that would be the case.
> 
> > 
> >> +struct shm_signal_irq {
> >> +       __u8                  enabled;
> >> +       __u8                  pending;
> >> +       __u8                  dirty;
> >> +};
> > 
> > Won't this layout cause cache line ping pong? Other schemes I have
> > seen try to separate the bits so that each cache line is written to
> > by only one side.
> 
> It could possibly use some optimization in that regard.  I generally consider myself an expert at concurrent programming, but this lockless stuff is, um, hard ;)  I was going for correctness first.
> 
> Long story short, any suggestions on ways to split this up are welcome (particularly now, before the ABI is sealed ;)
> 
> > This gets much more interesting if the two sides
> > are on remote ends of an I/O link, e.g. using a nontransparent
> > PCI bridge, where you only want to send stores over the wire, but
> > never fetches or even read-modify-write cycles.
> 
> /me head explodes ;)
> 

I've actually implemented this idea for virtio. Read the virtio-over-PCI
patches I posted, and you'll see that the entire virtqueue
implementation NEVER uses reads across the PCI bus, only writes. The
slowpath configuration space uses reads, but the virtqueues themselves
are write-only.

Some trivial benchmarking against an earlier driver that did
writes+reads across the PCI bus showed that the write-only driver was
about 2x as fast. (Throughput increased from ~30MB/sec to ~65MB/sec).

I'm sure the write-only design was not the only change responsible for
the speedup, but it was definitely a contributing factor.

Ira
