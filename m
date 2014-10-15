From: Jason Wang <jasowang@redhat.com>
Subject: Re: [PATCH net-next RFC 0/3] virtio-net: Conditionally enable tx
	interrupt
Date: Wed, 15 Oct 2014 15:28:43 +0800
Message-ID: <543E222B.40706@redhat.com>
References: <1413011806-3813-1-git-send-email-jasowang@redhat.com>
	<20141014.145327.365091739350390288.davem@davemloft.net>
	<20141014230627.GA23715@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: kvm@vger.kernel.org, netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	virtualization@lists.linux-foundation.org, linux-api@vger.kernel.org
To: "Michael S. Tsirkin" <mst@redhat.com>, David Miller <davem@davemloft.net>
Return-path: <virtualization-bounces@lists.linux-foundation.org>
In-Reply-To: <20141014230627.GA23715@redhat.com>
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

On 10/15/2014 07:06 AM, Michael S. Tsirkin wrote:
> On Tue, Oct 14, 2014 at 02:53:27PM -0400, David Miller wrote:
>> > From: Jason Wang <jasowang@redhat.com>
>> > Date: Sat, 11 Oct 2014 15:16:43 +0800
>> > 
>>> > > We free old transmitted packets in ndo_start_xmit() currently, so any
>>> > > packet must be orphaned also there. This was used to reduce the overhead of
>>> > > tx interrupt to achieve better performance. But this may not work for some
>>> > > protocols such as TCP stream. TCP depends on the value of sk_wmem_alloc to
>>> > > implement various optimization for small packets stream such as TCP small
>>> > > queue and auto corking. But orphaning packets early in ndo_start_xmit()
>>> > > disable such things more or less since sk_wmem_alloc was not accurate. This
>>> > > lead extra low throughput for TCP stream of small writes.
>>> > > 
>>> > > This series tries to solve this issue by enable tx interrupts for all TCP
>>> > > packets other than the ones with push bit or pure ACK. This is done through
>>> > > the support of urgent descriptor which can force an interrupt for a
>>> > > specified packet. If tx interrupt was enabled for a packet, there's no need
>>> > > to orphan it in ndo_start_xmit(), we can free it tx napi which is scheduled
>>> > > by tx interrupt. Then sk_wmem_alloc was more accurate than before and TCP
>>> > > can batch more for small write. More larger skb was produced by TCP in this
>>> > > case to improve both throughput and cpu utilization.
>>> > > 
>>> > > Test shows great improvements on small write tcp streams. For most of the
>>> > > other cases, the throughput and cpu utilization are the same in the
>>> > > past. Only few cases, more cpu utilization was noticed which needs more
>>> > > investigation.
>>> > > 
>>> > > Review and comments are welcomed.
>> > 
>> > I think proper accounting and queueing (at all levels, not just TCP
>> > sockets) is more important than trying to skim a bunch of cycles by
>> > avoiding TX interrupts.
>> > 
>> > Having an event to free the SKB is absolutely essential for the stack
>> > to operate correctly.
>> > 
>> > And with virtio-net you don't even have the excuse of "the HW
>> > unfortunately doesn't have an appropriate TX event."
>> > 
>> > So please don't play games, and instead use TX interrupts all the
>> > time.  You can mitigate them in various ways, but don't turn them on
>> > selectively based upon traffic type, that's terrible.
>> > 
>> > You can even use ->xmit_more to defer the TX interrupt indication to
>> > the final TX packet in the chain.
> I guess we can just defer the kick, interrupt will naturally be
> deferred as well.
> This should solve the problem for old hosts as well.

Interrupt were delayed but not reduced, to support this we need publish
avail idx as used event. This should reduce the tx interrupt in the case
of bulk dequeuing.

I will draft a new rfc series contain this.
>
> We'll also need to implement bql for this.
> Something like the below?
> Completely untested - posting here to see if I figured the
> API out correctly. Has to be applied on top of the previous patch.

Looks so. I believe better to have but not a must.
