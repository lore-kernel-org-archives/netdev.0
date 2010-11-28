From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH] kthread: NUMA aware kthread_create_on_cpu()
Date: Mon, 29 Nov 2010 00:37:04 +0100
Message-ID: <1290987424.29196.128.camel@edumazet-laptop>
References: <1290972833.29196.90.camel@edumazet-laptop>
	 <20101128224024.GA12300@basil.fritz.box>
	 <1290984712.29196.100.camel@edumazet-laptop>
	 <20101128230146.GB12300@basil.fritz.box>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Andrew Morton <akpm@linux-foundation.org>,
	linux-kernel <linux-kernel@vger.kernel.org>,
	netdev <netdev@vger.kernel.org>,
	David Miller <davem@davemloft.net>, Tejun Heo <tj@kernel.org>,
	Rusty Russell <rusty@rustcorp.com.au>
To: Andi Kleen <andi@firstfloor.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wy0-f174.google.com ([74.125.82.174]:44615 "EHLO
	mail-wy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752776Ab0K1XhL (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 28 Nov 2010 18:37:11 -0500
In-Reply-To: <20101128230146.GB12300@basil.fritz.box>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le lundi 29 novembre 2010 =C3=A0 00:01 +0100, Andi Kleen a =C3=A9crit :
> On Sun, Nov 28, 2010 at 11:51:51PM +0100, Eric Dumazet wrote:
> > > Also this messes up the policy of the caller process. You really
> > > need to save/restore it.
> >=20
> > Well, caller process duty is to create kthreads in a loop.
>=20
> In this case any other allocations it may do
>  are still on those
> nodes.

As I said, it does only create_kthread() calls, and no "other
allocations".

while (!list_empty(&kthread_create_list)) {
      struct kthread_create_info *create;

      create =3D list_entry(kthread_create_list.next,
                          struct kthread_create_info, list);
      list_del_init(&create->list);
      spin_unlock(&kthread_create_lock);

      create_kthread(create);

      spin_lock(&kthread_create_lock);
}





>=20
> > > Problem is that this ends up in architecture specific code
> > > for the stack, so may be a larger patch.
> >=20
> > I suggest arches that need slab to allocate kthread stacks do the
> > appropriate changes, because I am not able to make them myself.
> >=20
> > On x86, we use page allocator only, so NUMA mempolicy is used.
>=20
> task_struct is always allocated from slab.

Hmm, I meant stack (the thing that might be trashed a lot in ksoftirqd)=
,
so it is included in struct thread_info

And this one uses __get_free_pages(GFP_KERNEL, THREAD_SIZE_ORDER) from
alloc_thread_info()


By the way, I re-tested my original patch (MPOL_BIND) on x86_32

# cat /proc/buddyinfo=20
Node 0, zone      DMA      0      1      0      1      2      1      1 =
     0      1      1      3=20
Node 0, zone   Normal     22     14     10      3      2      3      4 =
     2      3      2    165=20
Node 0, zone  HighMem     41     35    346    223    124    140     40 =
    19      2      0    143=20
Node 1, zone  HighMem     21      7      8      4    217     97     33 =
    11      3      1    415=20

And got correct stacks. Are you sure we must use PREFERRED ?



