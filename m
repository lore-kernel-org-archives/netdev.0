From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: kernel panic in skb_copy_bits
Date: Thu, 04 Jul 2013 02:34:25 -0700
Message-ID: <1372930465.4979.82.camel@edumazet-glaptop>
References: <51CBAA48.3080802@oracle.com>
	 <1372311118.3301.214.camel@edumazet-glaptop> <51CD0E67.4000008@oracle.com>
	 <6BFD5AF235F72F13CE646A0D@nimrod.local> <51D0F514.3070309@oracle.com>
	 <1372666283.14691.8.camel@zakaz.uk.xensource.com>
	 <51D53896.1060405@oracle.com>
	 <1372928382.7184.16.camel@kazak.uk.xensource.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Joe Jin <joe.jin@oracle.com>, Alex Bligh <alex@alex.org.uk>,
	Frank Blaschka <frank.blaschka@de.ibm.com>,
	"David S. Miller" <davem@davemloft.net>,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	zheng.x.li@oracle.com, Xen Devel <xen-devel@lists.xen.org>,
	Jan Beulich <JBeulich@suse.com>,
	Stefano Stabellini <stefano.stabellini@eu.citrix.com>,
	Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>
To: Ian Campbell <Ian.Campbell@citrix.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1372928382.7184.16.camel@kazak.uk.xensource.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, 2013-07-04 at 09:59 +0100, Ian Campbell wrote:
> On Thu, 2013-07-04 at 16:55 +0800, Joe Jin wrote:
> > 
> > Another way is add new page flag like PG_send, when sendpage() be called,
> > set the bit, when page be put, clear the bit. Then xen-blkback can wait
> > on the pagequeue.
> 
> These schemes don't work when you have multiple simultaneous I/Os
> referencing the same underlying page.

So this is a page property, still the patches I saw tried to address
this problem adding networking stuff (destructors) in the skbs.

Given that a page refcount can be transfered between entities, say using
splice() system call, I do not really understand why the fix would imply
networking only.

Let's try to fix it properly, or else we must disable zero copies
because they are not reliable.

Why sendfile() doesn't have the problem, but vmsplice()+splice() do have
this issue ?

As soon as a page fragment reference is taken somewhere, the only way to
properly reuse the page is to rely on put_page() and page being freed.

Adding workarounds in TCP stack to always copy the page fragments in
case of a retransmit is partial solution, as the remote peer could be
malicious and send ACK _before_ page content is actually read by the
NIC.

So if we rely on networking stacks to give the signal for page reuse, we
can have major security issue.
