From: Andi Kleen <ak@suse.de>
Subject: Re: Tigon3 5701 PCI-X recv performance problem
Date: Wed, 8 Oct 2003 22:46:18 +0200
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20031008204618.GC15611@oldwotan.suse.de>
References: <3F844578.40306@sgi.com> <20031008101046.376abc3b.davem@redhat.com> <3F8455BE.8080300@sgi.com> <20031008183742.GA24822@wotan.suse.de> <20031008122223.1ba5ac79.davem@redhat.com> <20031008202248.GA15611@oldwotan.suse.de> <20031008132402.64984528.davem@redhat.com> <20031008203306.GB15611@oldwotan.suse.de> <20031008133248.1583ddcf.davem@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Andi Kleen <ak@suse.de>, modica@sgi.com, johnip@sgi.com,
        netdev@oss.sgi.com, jgarzik@pobox.com, jes@sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: "David S. Miller" <davem@redhat.com>
Content-Disposition: inline
In-Reply-To: <20031008133248.1583ddcf.davem@redhat.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Wed, Oct 08, 2003 at 01:32:48PM -0700, David S. Miller wrote:
> On Wed, 8 Oct 2003 22:33:06 +0200
> Andi Kleen <ak@suse.de> wrote:
> 
> > Well, this thread was about the tigon3 and I don't see that as an el cheapo
> > card. If SGI uses it on the Altix I guess they want it to perform well 
> > with many CPUs.
> 
> It's one of the oldest variants of the tg3 chip and it's full
> of hardware bugs when used in PCI-X.

Ok. Why do we care about it then?  Copying should be fine for that.

> 
> > I personally think it's better to just use slab to implement it,
> > allocating pages doesn't seem to have any advantages to me.
> 
> The page chunk allocator is meant to make it easier to put the
> non-header parts in the frag list of the SKB, see?  It means we
> don't need to do anything special in the networking, all the
> receive paths handle frag'd RX packets properly.

Sure, but to handle the sub allocation you need a destructor per fragment.
(otherwise how do you want to share a page between different packets)

And when you have a destructor you can as well allocate from slab
and convert the virtual pointer to (struct page *, offset)

If you don't want to share pages between different packets: I don't
like this because it would increase memory use of networking with 1.5k
MTU by factor 2. I don't think that would be a good path to go
down, Linux networking is already too bloated.

BTW I think this all should be also ifdefed with CONFIG_SLOW_UNALIGNMENT.
I certainly don't want any of this on x86-64 where unalignment cost
one cycle only.

Another BTW Actually this technique would allow socket buffers in highmem, but
it's not really needed yet and all 32bit architecture which have high
mem usually have fast unalignment handling. 

-Andi
