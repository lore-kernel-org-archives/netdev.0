From: Rick Jones <rick.jones2@hp.com>
Subject: Re: [PATCHv4] virtio-spec: virtio network device multiqueue support
Date: Mon, 10 Sep 2012 11:39:25 -0700
Message-ID: <504E33DD.3040504@hp.com>
References: <20120909130308.GA3471@redhat.com> <878vcifwxi.fsf@rustcorp.com.au>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"; Format="flowed"
Content-Transfer-Encoding: 7bit
Cc: kvm@vger.kernel.org, "Michael S. Tsirkin" <mst@redhat.com>,
	netdev@vger.kernel.org, virtualization@lists.linux-foundation.org,
	levinsasha928@gmail.com, pbonzini@redhat.com,
	Tom Herbert <therbert@google.com>
To: Rusty Russell <rusty@rustcorp.com.au>
Return-path: <virtualization-bounces@lists.linux-foundation.org>
In-Reply-To: <878vcifwxi.fsf@rustcorp.com.au>
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

On 09/09/2012 07:12 PM, Rusty Russell wrote:
> OK, I read the spec (pasted below for easy of reading), but I'm still
> confused over how this will work.
>
> I thought normal net drivers have the hardware provide an rxhash for
> each packet, and we map that to CPU to queue the packet on[1].  We hope
> that the receiving process migrates to that CPU, so xmit queue
> matches.
>
> For virtio this would mean a new per-packet rxhash value, right?
>
> Why are we doing something different?  What am I missing?
>
> Thanks,
> Rusty.
> [1] Everything I Know About Networking I Learned From LWN:
>      https://lwn.net/Articles/362339/

In my taxonomy at least, "multi-queue" predates RPS and RFS and is 
simply where the NIC via some means, perhaps a headers hash, separates 
incoming frames to different queues.

RPS can be thought of as doing something similar inside the host.  That 
could be used to get a spread from an otherwise "dumb" NIC (certainly 
that is what one of its predecessors - Inbound Packet Scheduling - used 
it for in HP-UX 10.20), or it could be used to augment the multi-queue 
support of a not-so-dump NIC - say if said NIC had a limit of queues 
that was rather lower than the number of cores/threads in the host. 
Indeed some driver/NIC combinations provide a hash value to the host for 
the host to use as it sees fit.

However, there is still the matter of a single thread of an application 
servicing multiple connections, each of which would hash to different 
locations.

RFS  (Receive Flow Steering) then goes one step further, and looks-up 
where the flow endpoint was last accessed and steers the traffic there. 
  The idea being that a thread of execution servicing multiple flows 
will have the traffic of those flows sent to the same place.  It then 
allows the scheduler to decide where things should be run rather than 
the networking code.

rick jones
