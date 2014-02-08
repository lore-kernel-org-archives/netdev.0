From: Linus Torvalds <torvalds@linux-foundation.org>
Subject: Re: [PATCH 1/2] mm/vmalloc: export is_vmalloc_or_module_addr
Date: Sat, 8 Feb 2014 11:45:53 -0800
Message-ID: <CA+55aFx8TzOnW9xPFA4Ox-yFiSUo=cEqeQUmgw_JWjDNEZep8Q@mail.gmail.com>
References: <1391886730-19667-1-git-send-email-ryao@gentoo.org>
	<1391886730-19667-2-git-send-email-ryao@gentoo.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Eric Van Hensbergen <ericvh@gmail.com>,
	Ron Minnich <rminnich@sandia.gov>,
	Latchesar Ionkov <lucho@ionkov.net>,
	"David S. Miller" <davem@davemloft.net>,
	V9FS Develooper Mailing List
	<v9fs-developer@lists.sourceforge.net>,
	Linux Netdev Mailing List <netdev@vger.kernel.org>,
	Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
	"Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>,
	Will Deacon <will.deacon@arm.com>,
	Christopher Covington <cov@codeaurora.org>,
	Matthew Thode <mthode@mthode.org>
To: Richard Yao <ryao@gentoo.org>, Mel Gorman <mgorman@suse.de>,
	Andrew Morton <akpm@linux-foundation.org>,
	Rik van Riel <riel@redhat.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1391886730-19667-2-git-send-email-ryao@gentoo.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Sat, Feb 8, 2014 at 11:12 AM, Richard Yao <ryao@gentoo.org> wrote:
> 9p-virtio needs is_vmalloc_or_module_addr exported before a patch can be
> merged to prevent the virtio zero-copy routines from triggering a
> hypervisor page fault when loading kernel modules:
>
> https://groups.google.com/forum/#!topic/linux.kernel/eRR7AyLE29Y
>
> Without this export, the kernel build breaks with that patch applied and
> CONFIG_NET_9P_VIRTIO=m. With this export in place, all is well.

I absolutely *detest* this patch.

Not so much because is_vmalloc_or_module_addr() should never be used,
but because the particular use in question is pure and utter garbage.

There are valid reasons to use "is_vmalloc_or_module_addr()", but
those are along the lines of drivers/char/mem.c, which says "return
-ENXIO for this crap".

And btw, that horrid crap called "kmap_to_page()" needs to die too.
When is it *ever* valid to use a kmap'ed page for IO? Here's a clue:
never.

I notice that we have a similar abortion in "get_kernel_page[s]()",
which probably has the same broken source.

We need to get *rid* of this crap, rather than add more of it. I
should have looked more closely, but it came in through Andrew, which
generally makes me go "ok, Andrew sends me a VM patch - apply". In
this case it was clearly a huge mistake.

So who the f*ck sends static module data as IO? Just stop doing that.
What's And that idiotic kmap_to_page() really needs to die too.

Those *disgusting* get_kernel_page[s]() functions came with a
commentary about "The initial user is expected to be NFS.." and that
is still the *only* user. The fact that *everybody* else has been able
to avoid that crap should tell us something.

Mel, Rik, this needs to die. I'm sorry I didn't notice how crap it was earlier.

And what's the backtrace that gets mentioned - but not quoted - for
the horrible 9p crap? So that we can see who the guilty party is that
thinks that it's somehow ok to pass module addresses off to other
kernel users..

Please let's just fix the real problem, don't add more horridness on
top of it because somebody messed up earlier.

                  Linus
