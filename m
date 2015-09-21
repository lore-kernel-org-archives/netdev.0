From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH] lib: fix data race in rhashtable_rehash_one
Date: Mon, 21 Sep 2015 08:15:31 -0700
Message-ID: <1442848531.29850.59.camel@edumazet-glaptop2.roam.corp.google.com>
References: <1442822930-35319-1-git-send-email-dvyukov@google.com>
	 <1442842315.29850.44.camel@edumazet-glaptop2.roam.corp.google.com>
	 <1442847108.29850.56.camel@edumazet-glaptop2.roam.corp.google.com>
	 <CACT4Y+ZSGBi00ZbCN6NE=NdJ7Lm76LVjkSFMsC5diLHHD66Cfw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: tgraf@suug.ch, netdev@vger.kernel.org,
	LKML <linux-kernel@vger.kernel.org>,
	Kostya Serebryany <kcc@google.com>,
	Andrey Konovalov <andreyknvl@google.com>,
	Alexander Potapenko <glider@google.com>,
	ktsan@googlegroups.com, Paul McKenney <paulmck@linux.vnet.ibm.com>
To: Dmitry Vyukov <dvyukov@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f53.google.com ([209.85.220.53]:33792 "EHLO
	mail-pa0-f53.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752699AbbIUPPd (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 21 Sep 2015 11:15:33 -0400
In-Reply-To: <CACT4Y+ZSGBi00ZbCN6NE=NdJ7Lm76LVjkSFMsC5diLHHD66Cfw@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 2015-09-21 at 17:10 +0200, Dmitry Vyukov wrote:
> On Mon, Sep 21, 2015 at 4:51 PM, Eric Dumazet <eric.dumazet@gmail.com> wrote:
> > On Mon, 2015-09-21 at 06:31 -0700, Eric Dumazet wrote:
> >> On Mon, 2015-09-21 at 10:08 +0200, Dmitry Vyukov wrote:
> >> > rhashtable_rehash_one() uses plain writes to update entry->next,
> >> > while it is being concurrently accessed by readers.
> >> > Unfortunately, the compiler is within its rights to (for example) use
> >> > byte-at-a-time writes to update the pointer, which would fatally confuse
> >> > concurrent readers.
> >> >
> >> This is bogus.
> >>
> >> 1) Linux is certainly not working if some arch or compiler is not doing
> >> single word writes. WRITE_ONCE() would not help at all to enforce this.
> >>
> >> 2) If  new node is not yet visible, we don't care if we write
> >> entry->next using any kind of operation.
> >>
> >> So the WRITE_ONCE() is not needed at all.
> >>
> >>
> >>
> >> > +   WRITE_ONCE(entry->next, head);
> >>
> >>
> >> The rcu_assign_pointer() immediately following is enough in this case.
> >>
> >> We have hundred of similar cases in the kernel.
> >>
> >>
> >
> > The changelog and comment are totally confusing.
> >
> > Please remove the bogus parts in them, and/or rephrase.
> >
> > The important part here is that we rehash an item, so we need to make
> > sure to maintain consistent ->next field, and need to prevent compiler
> > from using ->next as a temporary variable.
> >
> > ptr->next = 1UL | ((base + offset) << 1);
> >
> > Is dangerous because compiler could issue :
> >
> > ptr->next = (base + offset);
> >
> > ptr->next <<= 1;
> >
> > ptr->next += 1UL;
> >
> > Frankly, all this looks like an oversight in this code.
> >
> > Not sure why the NULLS value is even recomputed.
> 
> I have not looked in detail yet, but the NULLS recomputation uses
> new_hash, which obviously wasn't available when the value was
> previously computed. Don't know yet whether it is important or not.


Well, head already contains the right value, set in bucket_table_alloc()

for (i = 0; i < nbuckets; i++)
    INIT_RHT_NULLS_HEAD(tbl->buckets[i], ht, i);

Think of this nulls value as a special NULL pointer.

If hash table is properly allocated/initialized, all the chains are
correctly ending with a proper NULL pointer.
