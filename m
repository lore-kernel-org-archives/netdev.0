From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: kernel panic in skb_copy_bits
Date: Thu, 04 Jul 2013 03:12:10 -0700
Message-ID: <1372932730.4979.96.camel@edumazet-glaptop>
References: <51CBAA48.3080802@oracle.com>
	 <1372311118.3301.214.camel@edumazet-glaptop> <51CD0E67.4000008@oracle.com>
	 <6BFD5AF235F72F13CE646A0D@nimrod.local> <51D0F514.3070309@oracle.com>
	 <1372666283.14691.8.camel@zakaz.uk.xensource.com>
	 <51D53896.1060405@oracle.com>
	 <1372928382.7184.16.camel@kazak.uk.xensource.com>
	 <1372930465.4979.82.camel@edumazet-glaptop>
	 <1372931565.7184.32.camel@kazak.uk.xensource.com>
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
In-Reply-To: <1372931565.7184.32.camel@kazak.uk.xensource.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, 2013-07-04 at 10:52 +0100, Ian Campbell wrote:

> Might just be that no one has observed it with vmsplice()+splice()? Most
> of the time this happens silently and you'll probably never notice, it's
> just the behaviour of Xen which escalates the issue into one you can
> see.

The point I wanted to make is that nobody can seriously use vmsplice(),
unless the memory is never reused by the application, or the application
doesn't care of security implications.

Because an application has no way to know when it's safe to reuse the
area for another usage.

[ Unless it uses the obscure and complex pagemap stuff
(Documentation/vm/pagemap.txt), but its not asynchronous signaling and
not pluggable into epoll()/poll()/select()) ]

> Xen's out of tree netback used to fix this by a destructor call back on
> page free, but that was a core mm patch in the hot memory free path
> which wasn't popular, and it doesn't solve anything for the non-Xen
> instances of this issue.

It _is_ a mm core patch which is needed, if we ever want to fix this
problem.

It looks like a typical COW issue to me.

If the page content is written while there is still a reference on this
page, we should allocate a new page and copy the previous content.

And this has little to do with networking.
