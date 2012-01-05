From: Mike Waychison <mikew@google.com>
Subject: Re: [RFC PATCH v1 2/2] virtio_net: Don't disable napi on low memory.
Date: Wed, 4 Jan 2012 18:46:55 -0800
Message-ID: <CAGTjWtB3PjWDfaunXjF-KQwKYg-bPgrn-8N=8iwL0EPvviXMuw@mail.gmail.com>
References: <20120104225223.18184.1537.stgit@mike2.sea.corp.google.com>
	<20120104225237.18184.71853.stgit@mike2.sea.corp.google.com>
	<87y5tnat2g.fsf@rustcorp.com.au>
Mime-Version: 1.0
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
Cc: netdev@vger.kernel.org, virtualization@lists.linux-foundation.org,
	linux-kernel@vger.kernel.org, "Michael S. Tsirkin" <mst@redhat.com>
To: Rusty Russell <rusty@rustcorp.com.au>
Return-path: <virtualization-bounces@lists.linux-foundation.org>
In-Reply-To: <87y5tnat2g.fsf@rustcorp.com.au>
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

On Wed, Jan 4, 2012 at 4:31 PM, Rusty Russell <rusty@rustcorp.com.au> wrote:
> On Wed, 04 Jan 2012 14:52:38 -0800, Mike Waychison <mikew@google.com> wro=
te:
>> Currently, the virtio_net driver deals with low memory memory by kicking
>> off delayed work in process context to try and refill the rx queues.
>> This process-context filling is synchronized against the receive
>> bottom-half by serially:
>>
>> =A0 - disabling NAPI polling on the device,
>> =A0 - allocating buffers,
>> =A0 - enqueueing the buffers,
>> =A0 - re-enabling napi.
>>
>> Disabling NAPI just to synchronize virtio_add_buf calls is a bit
>> overkill, and there isn't any reason we shouldn't be able to continue
>> processing received packets as they come in. =A0In the simple case, this
>> does not involve allocating any memory, and in fact allows memory to be
>> released as the guest system receives and processes packets.
>
> Adding a spinlock to the fastpath for a weird case in the slow path is
> bad too.
>
> I dislike several things about this patch:
> 1) You seem to leak memory if you allocate a batch then don't add it all.
> 2) You have a module parameter, which I guarantee noone else will ever us=
e.
> 3) You've made three changes at once: allocating outside the lock,
> =A0 batching, and replacing the napi lock with a spinlock.
> 4) You use the skb data for the linked list; use the skb head's list.
>
> Instead, here's how I think it should be done:
>
> 1) Split alloc and add, but make alloc return the skb.
> 2) Make try_fill_recv() only called in the receive path, keep it
> =A0 basically the same (no batching).
> 3) Add a new try_fill_recv_batch() for the workqueue and init paths.
> =A0 This should try to allocate max - num, though in practice the
> =A0 first alloc would probably kick off reclaim and take forever,
> =A0 then by the time it's done, the problem is solved. =A0Since it's
> =A0 reading max and num outside the lock, write this loop carefully!
> 4) try_fill_recv_batch() should then stop napi and add as many as it
> =A0 can, then restart it, then free any remainder.

This sounds reasonable to me.  I'll see what I can muster together this wee=
k.

Thanks for taking a look :)

>
> Cheers,
> Rusty.
