From: Ian Campbell <Ian.Campbell@citrix.com>
Subject: Re: kernel panic in skb_copy_bits
Date: Thu, 4 Jul 2013 10:52:45 +0100
Message-ID: <1372931565.7184.32.camel@kazak.uk.xensource.com>
References: <51CBAA48.3080802@oracle.com>
	 <1372311118.3301.214.camel@edumazet-glaptop> <51CD0E67.4000008@oracle.com>
	 <6BFD5AF235F72F13CE646A0D@nimrod.local> <51D0F514.3070309@oracle.com>
	 <1372666283.14691.8.camel@zakaz.uk.xensource.com>
	 <51D53896.1060405@oracle.com>
	 <1372928382.7184.16.camel@kazak.uk.xensource.com>
	 <1372930465.4979.82.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Joe Jin <joe.jin@oracle.com>, Alex Bligh <alex@alex.org.uk>,
	"Frank Blaschka" <frank.blaschka@de.ibm.com>,
	"David S. Miller" <davem@davemloft.net>,
	<linux-kernel@vger.kernel.org>, <netdev@vger.kernel.org>,
	<zheng.x.li@oracle.com>, Xen Devel <xen-devel@lists.xen.org>,
	Jan Beulich <JBeulich@suse.com>,
	"Stefano Stabellini" <stefano.stabellini@eu.citrix.com>,
	Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1372930465.4979.82.camel@edumazet-glaptop>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, 2013-07-04 at 02:34 -0700, Eric Dumazet wrote:
> On Thu, 2013-07-04 at 09:59 +0100, Ian Campbell wrote:
> > On Thu, 2013-07-04 at 16:55 +0800, Joe Jin wrote:
> > > 
> > > Another way is add new page flag like PG_send, when sendpage() be called,
> > > set the bit, when page be put, clear the bit. Then xen-blkback can wait
> > > on the pagequeue.
> > 
> > These schemes don't work when you have multiple simultaneous I/Os
> > referencing the same underlying page.
> 
> So this is a page property, still the patches I saw tried to address
> this problem adding networking stuff (destructors) in the skbs.
> 
> Given that a page refcount can be transfered between entities, say using
> splice() system call, I do not really understand why the fix would imply
> networking only.
> 
> Let's try to fix it properly, or else we must disable zero copies
> because they are not reliable.
> 
> Why sendfile() doesn't have the problem, but vmsplice()+splice() do have
> this issue ?

Might just be that no one has observed it with vmsplice()+splice()? Most
of the time this happens silently and you'll probably never notice, it's
just the behaviour of Xen which escalates the issue into one you can
see.

> As soon as a page fragment reference is taken somewhere, the only way to
> properly reuse the page is to rely on put_page() and page being freed.

Xen's out of tree netback used to fix this by a destructor call back on
page free, but that was a core mm patch in the hot memory free path
which wasn't popular, and it doesn't solve anything for the non-Xen
instances of this issue.

> Adding workarounds in TCP stack to always copy the page fragments in
> case of a retransmit is partial solution, as the remote peer could be
> malicious and send ACK _before_ page content is actually read by the
> NIC.
> 
> So if we rely on networking stacks to give the signal for page reuse, we
> can have major security issue.

If you ignore the Xen case and consider just the native case then the
issue isn't page reuse in the sense of getting mapped into another
process, it's the same page in the same process but the process has
written something new to the buffer, e.g.
	memset(buf, 0xaa, 4096);
	write(fd, buf, 4096)
	memset(buf, 0x55, 4096);
(where fd is O_DIRECT on NFS) Can result in 0x55 being seen on the wire
in the TCP retransmit.

If the retransmit is at the RPC layer then you get a resend of the NFS
write RPC, but the XDR sequence stuff catches that case (I think, memory
is fuzzy).

If the retransmit is at the TCP level then the TCP sequence/ack will
cause the receiver to ignore the corrupt version, but if you replace the
second memset with write_critical_secret_key(buf), then you have an
information leak.

Ian.
