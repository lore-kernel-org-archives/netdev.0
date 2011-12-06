From: Sridhar Samudrala <sri@us.ibm.com>
Subject: Re: [net-next RFC PATCH 5/5] virtio-net: flow director support
Date: Tue, 06 Dec 2011 15:10:25 -0800
Message-ID: <4EDEA0E1.6020501@us.ibm.com>
References: <20111205085603.6116.65101.stgit@dhcp-8-146.nay.redhat.com>
	<20111205085925.6116.94352.stgit@dhcp-8-146.nay.redhat.com>
	<CAJSP0QXfHC8j2Kk9x6wyBMubo2=YvpaLAShJtwMWA2mtro6UhA@mail.gmail.com>
	<4EDDB71F.9080908@redhat.com>
	<CAJSP0QX5dDkpX+cRcQut2mb6K91zeqGLRrZBGAWT_r2p685gaQ@mail.gmail.com>
	<4EDDECA9.8060808@redhat.com>
	<CAJSP0QXsLwvH5xYj6h0E_V4VLg6DuUc-GKXu9esEYzL2MFcFGw@mail.gmail.com>
	<4EDE37FE.5090409@us.ibm.com> <20111206161422.GA3245@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"; Format="flowed"
Content-Transfer-Encoding: 7bit
Cc: krkumar2@in.ibm.com, xma@us.ibm.com, kvm@vger.kernel.org,
	virtualization@lists.linux-foundation.org,
	levinsasha928@gmail.com, netdev@vger.kernel.org, bhutchings@solarflare.com
To: "Michael S. Tsirkin" <mst@redhat.com>
Return-path: <virtualization-bounces@lists.linux-foundation.org>
In-Reply-To: <20111206161422.GA3245@redhat.com>
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

On 12/6/2011 8:14 AM, Michael S. Tsirkin wrote:
> On Tue, Dec 06, 2011 at 07:42:54AM -0800, Sridhar Samudrala wrote:
>> On 12/6/2011 5:15 AM, Stefan Hajnoczi wrote:
>>> On Tue, Dec 6, 2011 at 10:21 AM, Jason Wang<jasowang@redhat.com>   wrote:
>>>> On 12/06/2011 05:18 PM, Stefan Hajnoczi wrote:
>>>>> On Tue, Dec 6, 2011 at 6:33 AM, Jason Wang<jasowang@redhat.com>     wrote:
>>>>>> On 12/05/2011 06:55 PM, Stefan Hajnoczi wrote:
>>>>>>> On Mon, Dec 5, 2011 at 8:59 AM, Jason Wang<jasowang@redhat.com>
>>>>>>>   wrote:
>>>>> The vcpus are just threads and may not be bound to physical CPUs, so
>>>>> what is the big picture here?  Is the guest even in the position to
>>>>> set the best queue mappings today?
>>>> Not sure it could publish the best mapping but the idea is to make sure the
>>>> packets of a flow were handled by the same guest vcpu and may be the same
>>>> vhost thread in order to eliminate the packet reordering and lock
>>>> contention. But this assumption does not take the bouncing of vhost or vcpu
>>>> threads which would also affect the result.
>>> Okay, this is why I'd like to know what the big picture here is.  What
>>> solution are you proposing?  How are we going to have everything from
>>> guest application, guest kernel, host threads, and host NIC driver
>>> play along so we get the right steering up the entire stack.  I think
>>> there needs to be an answer to that before changing virtio-net to add
>>> any steering mechanism.
>>>
>>>
>> Yes. Also the current model of  a vhost thread per VM's interface
>> doesn't help with packet steering
>> all the way from the guest to the host physical NIC.
>>
>> I think we need to have vhost thread(s) per-CPU that can handle
>> packets to/from physical NIC's
>> TX/RX queues.
>> Currently we have a single vhost thread for a VM's i/f
>> that handles all the packets from
>> various flows coming from a multi-queue physical NIC.
>>
>> Thanks
>> Sridhar
> It's not hard to try that:
> 1. revert c23f3445e68e1db0e74099f264bc5ff5d55ebdeb
>     this will convert our thread to a workqueue
> 2. convert the workqueue to a per-cpu one
>
> It didn't work that well in the past, but YMMV
Yes. I tried this before we went ahead with per-interface vhost 
threading model.
At that time, per-cpu vhost  showed a regression with a single-VM and
per-vq vhost showed good performance improvements upto 8 VMs.

So  just making it per-cpu would not be enough. I think we may need a way
to schedule vcpu threads on the same cpu-socket as vhost.

Another aspect we need to look into is the splitting of vhost thread 
into separate
threads for TX and RX. Shirley is doing some work in this area and she 
is seeing
perf. improvements as long as TX and RX threads are on the same cpu-socket.
>
> On the surface I'd say a single thread makes some sense
> as long as guest uses a single queue.
>
But this may not be scalable long term when we want to support a large 
number of VMs each
having multiple virtio-net interfaces with multiple queues.

Thanks
Sridhar
