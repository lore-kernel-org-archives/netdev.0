From: Tom Herbert <therbert@google.com>
Subject: Re: [PATCHv4] virtio-spec: virtio network device multiqueue support
Date: Wed, 12 Sep 2012 07:40:50 -0700
Message-ID: <CA+mtBx9NB=t=3YAB=MdRY_6hMe9J=z4U9o-pPe3iYfmxkeKJRw@mail.gmail.com>
References: <20120909130308.GA3471@redhat.com>
	<878vcifwxi.fsf@rustcorp.com.au>
	<20120910061629.GC16819@redhat.com>
	<20120910062738.GA17331@redhat.com>
	<20120910063346.GA17338@redhat.com>
	<504DC831.1000709@redhat.com>
	<87har3dc4o.fsf@rustcorp.com.au>
	<20120912075737.GA30455@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: Rusty Russell <rusty@rustcorp.com.au>,
	Jason Wang <jasowang@redhat.com>, kvm@vger.kernel.org,
	virtualization@lists.linux-foundation.org, netdev@vger.kernel.org,
	pbonzini@redhat.com, levinsasha928@gmail.com, rick.jones2@hp.com
To: "Michael S. Tsirkin" <mst@redhat.com>
Return-path: <kvm-owner@vger.kernel.org>
In-Reply-To: <20120912075737.GA30455@redhat.com>
Sender: kvm-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, Sep 12, 2012 at 12:57 AM, Michael S. Tsirkin <mst@redhat.com> wrote:
> On Wed, Sep 12, 2012 at 03:19:11PM +0930, Rusty Russell wrote:
>> Jason Wang <jasowang@redhat.com> writes:
>> > On 09/10/2012 02:33 PM, Michael S. Tsirkin wrote:
>> >> A final addition: what you suggest above would be
>> >> "TX follows RX", right?
>>
>> BTW, yes.  But it's a weird way to express what the nic is doing.
>
> It explains what the system is doing.
> TX is done by driver, RX by nic.
> We document both driver and device in the spec
> so I thought it's fine. any suggestions wellcome.
>
>> >> It is in anticipation of something like that, that I made
>> >> steering programming so generic.
>>
>> >> I think TX follows RX is more immediately useful for reasons above
>> >> but we can add both to spec and let drivers and devices
>> >> decide what they want to support.
>>
>> You mean "RX follows TX"?  ie. accelerated RFS.  I agree.
>
RX following TX is logic of flow director I believe.  {a}RFS has RX
follow CPU where application receive is done on the socket.  So in RFS
there is no requirement to have a 1-1 correspondence between TX and RX
queues, and in fact this allows different number of queues between TX
and RX.  We found this necessary when using priority HW queues, so
that there are more TX queues than RX.

>
> Yes that's what I meant. Thanks for the correction.
>
>> Perhaps Tom can explain how we avoid out-of-order receive for the
>> accelerated RFS case?  It's not clear to me, but we need to be able to
>> do that for virtio-net if it implements accelerated RFS.
>
AFAIK ooo RX is still possible with accelerated RFS.  We have an
algorithm that prevents this for RFS by deferring a migration to a new
queue as long as it's possible that a flow might have outstanding
packets on the old queue.  I suppose this could be implemented in the
device for the HW queues, but I don't think it would be easy to cover
all cases where packets were already in transit to the host or other
cases where host and device queues are out of sync.

> Basically this has tx vq per cpu and relies on scheduler not bouncing threads
> between cpus too aggressively. Appears to be what ixgbe does.
>
>> > AFAIK, ixgbe does "rx follows tx". The only differences between ixgbe
>> > and virtio-net is that ixgbe driver programs the flow director during
>> > packet transmission but we suggest to do it silently in the device for
>> > simplicity.
>>
>> Implying the receive queue by xmit will be slightly laggy.  Don't know
>> if that's a problem.
>>
>> Cheers,
>> Rusty.
>
> Doesn't seem to be a problem in Jason's testing so far.
