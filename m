From: Mike Waychison <mikew@google.com>
Subject: Re: [RFC PATCH v1 2/2] virtio_net: Don't disable napi on low memory.
Date: Fri, 6 Jan 2012 09:54:46 -0800
Message-ID: <CAGTjWtBbLtm47kozBC2fdwGYKsOooQec0W9PwUEAF58mYDioaQ@mail.gmail.com>
References: <20120104225223.18184.1537.stgit@mike2.sea.corp.google.com>
	<20120104225237.18184.71853.stgit@mike2.sea.corp.google.com>
	<87y5tnat2g.fsf@rustcorp.com.au>
	<CAGTjWtB3PjWDfaunXjF-KQwKYg-bPgrn-8N=8iwL0EPvviXMuw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
Cc: netdev@vger.kernel.org, virtualization@lists.linux-foundation.org,
	linux-kernel@vger.kernel.org, "Michael S. Tsirkin" <mst@redhat.com>
To: Rusty Russell <rusty@rustcorp.com.au>
Return-path: <virtualization-bounces@lists.linux-foundation.org>
In-Reply-To: <CAGTjWtB3PjWDfaunXjF-KQwKYg-bPgrn-8N=8iwL0EPvviXMuw@mail.gmail.com>
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/virtualization>,
	<mailto:virtualization-request@lists.linux-foundation.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/virtualization/>
List-Post: <mailto:virtualization@lists.linux-foundation.org>
List-Help: <mailto:virtualization-request@lists.linux-foundation.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/virtualization>,
	<mailto:virtualization-request@lists.linux-foundation.org?subject=subscribe>
Sender: virtualization-bounces@lists.linux-foundation.org
Errors-To: virtualization-bounces@lists.linux-foundation.org
List-Id: netdev.vger.kernel.org

On Wed, Jan 4, 2012 at 6:46 PM, Mike Waychison <mikew@google.com> wrote:
> On Wed, Jan 4, 2012 at 4:31 PM, Rusty Russell <rusty@rustcorp.com.au> wro=
te:
>> 4) You use the skb data for the linked list; use the skb head's list.

What did you mean by this?  I was under the impression that the ->next
and ->prev fields in sk_buff were the first two elements specifically
so that the pointer could be treated as a list_head.  If it's the cast
in particular that you have an objection with, I can easily change
this to a singly linked list threaded through ->next if that's
cleaner.

>>
>> Instead, here's how I think it should be done:
...
>
> This sounds reasonable to me. =A0I'll see what I can muster together this=
 week.
>

So I started implementing it the way you were mentioning, and ran into
a problem with the original patchset.

Currently the "mergeable" and "big" receive buffers use a private page
free list (virtnet_info->pages) which has no synchronization itself.
This means that the batched version can't use get_a_page() and
give_pages() as is, which reduces the need to re-use the same alloc
halves that I've split.   Alternatives I can think of at this point:

- pass in a flag to the allocators like "bool is_serial" that is true
if we are serializing with napi, (which determines if we can much with
vi->pages)
or
- not use the same allocators for the "mergeable" and "big" paths.
The mergeable allocator in the non-serialized case reduces to
alloc_page(), while the big allocator looks like a copy and paste that
uses alloc_page instead of get_a_page().

Preferences?  I'll code one of the two up and see what it looks like.
