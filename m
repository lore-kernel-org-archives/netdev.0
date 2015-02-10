From: Rusty Russell <rusty@rustcorp.com.au>
Subject: Re: [PATCH RFC v5 net-next 1/6] virtio_ring: fix
	virtqueue_enable_cb() when only 1 buffers were pending
Date: Wed, 11 Feb 2015 10:28:38 +1030
Message-ID: <87zj8lb9ox.fsf@rustcorp.com.au>
References: <1423471165-34243-1-git-send-email-jasowang@redhat.com>
	<1423471165-34243-2-git-send-email-jasowang@redhat.com>
	<878ug6y3uv.fsf@rustcorp.com.au> <20150210101839.GA9505@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: pagupta@redhat.com, netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	virtualization@lists.linux-foundation.org
To: "Michael S. Tsirkin" <mst@redhat.com>
Return-path: <virtualization-bounces@lists.linux-foundation.org>
In-Reply-To: <20150210101839.GA9505@redhat.com>
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

"Michael S. Tsirkin" <mst@redhat.com> writes:
> On Tue, Feb 10, 2015 at 11:33:52AM +1030, Rusty Russell wrote:
>> Jason Wang <jasowang@redhat.com> writes:
>> > We currently does:
>> >
>> > bufs = (avail->idx - last_used_idx) * 3 / 4;
>> >
>> > This is ok now since we only try to enable the delayed callbacks when
>> > the queue is about to be full. This may not work well when there is
>> > only one pending buffer in the virtqueue (this may be the case after
>> > tx interrupt was enabled). Since virtqueue_enable_cb() will return
>> > false which may cause unnecessary triggering of napis. This patch
>> > correct this by only calculate the four thirds when bufs is not one.
>> 
>> I mildly prefer to avoid the branch, by changing the calculation like
>> so:
>> 
>>         /* Set bufs >= 1, even if there's only one pending buffer */
>>         bufs = (bufs + 1) * 3 / 4;
>
> Or bus * 3/4 + 1
>
>> But it's not clear to me how much this happens.  I'm happy with the
>> patch though, as currently virtqueue_enable_cb_delayed() is the same
>> as virtqueue_enable_cb() if there's only been one buffer added.
>> 
>> Cheers,
>> Rusty.
>
> But isn't this by design?
> The documentation says:
>
>  * This re-enables callbacks but hints to the other side to delay
>  * interrupts until most of the available buffers have been processed;
>
> Clearly, this implies that when there's one buffer it must behave
> exactly the same.

Yes, my mistake.  We could hit the "never gets notified" case with this
change, and that's a much bigger problem.

So I don't think we can accept this patch...
Rusty.
