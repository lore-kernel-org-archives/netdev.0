From: Jason Wang <jasowang@redhat.com>
Subject: Re: [net-next RFC PATCH 5/5] virtio-net: flow director support
Date: Wed, 07 Dec 2011 20:10:47 +0800
Message-ID: <4EDF57C7.90406@redhat.com>
References: <20111205085603.6116.65101.stgit@dhcp-8-146.nay.redhat.com>
	<20111205085925.6116.94352.stgit@dhcp-8-146.nay.redhat.com>
	<CAJSP0QXfHC8j2Kk9x6wyBMubo2=YvpaLAShJtwMWA2mtro6UhA@mail.gmail.com>
	<4EDDB71F.9080908@redhat.com>
	<CAJSP0QX5dDkpX+cRcQut2mb6K91zeqGLRrZBGAWT_r2p685gaQ@mail.gmail.com>
	<4EDDECA9.8060808@redhat.com>
	<CAJSP0QXsLwvH5xYj6h0E_V4VLg6DuUc-GKXu9esEYzL2MFcFGw@mail.gmail.com>
	<4EDED785.80804@redhat.com>
	<CAJSP0QUGWCf5WHEeCXzqZeF2CvpycxrGo-uPSfpWD1rWD3zeSg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"; Format="flowed"
Content-Transfer-Encoding: 7bit
Cc: krkumar2@in.ibm.com, kvm@vger.kernel.org, mst@redhat.com,
	netdev@vger.kernel.org, virtualization@lists.linux-foundation.org,
	levinsasha928@gmail.com, bhutchings@solarflare.com
To: Stefan Hajnoczi <stefanha@gmail.com>
Return-path: <virtualization-bounces@lists.linux-foundation.org>
In-Reply-To: <CAJSP0QUGWCf5WHEeCXzqZeF2CvpycxrGo-uPSfpWD1rWD3zeSg@mail.gmail.com>
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

On 12/07/2011 05:08 PM, Stefan Hajnoczi wrote:
[...]
>> >  Consider the complexity of the host nic each with their own steering
>> >  features,  this series make the first step with minimal effort to try to let
>> >  guest driver and host tap/macvtap co-operate like what physical nic does.
>> >  There may be other method, but performance numbers is also needed to give
>> >  the answer.
> I agree that performance results for this need to be shown.
>
> My original point is really that it's not a good idea to take
> individual steps without a good big picture because this will change
> the virtio-net device specification.  If this turns out to be a dead
> end then hosts will need to continue to support the interface forever
> (legacy guests could still try to use it).  So please first explain
> what the full stack picture is going to look like and how you think it
> will lead to better performance.  You don't need to have all the code
> or evidence, but just enough explanation so we see where this is all
> going.
I think I mention too little in the cover message.

There's no much changes with Krishna's series except the method that 
choosing a rx virtqueue. Since original series use different hash 
methods in host (rxhash) and guest (txhash), a different virtqueue were 
chose for a flow which could lead packets of a flow to be handled by 
different vhost thread and vcpu. This may damage the performance.

This series tries to let one vhost thread to process the packets of a 
flow and also let the packets to be sent directly to a vcpu local to the 
thread process the data. This is done by letting guest tell the desired 
queue form which it want to receive the pakcet of a dedicated flow.

So passing the hash from host to guest is needed to get the same hash in 
the two sides. Then a guest programmable hash to queue table were 
introduced and guest co-operate with the host through accelerate RFS in 
guest.
