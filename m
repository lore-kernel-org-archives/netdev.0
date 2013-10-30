From: Jason Wang <jasowang@redhat.com>
Subject: Re: [PATCH net-next] virtio_net: migrate mergeable rx buffers to
	page frag allocators
Date: Wed, 30 Oct 2013 12:41:46 +0800
Message-ID: <52708E0A.80904@redhat.com>
References: <1383000258-1458-1-git-send-email-mwdalton@google.com>
	<CAG7+5M1VFSZciaZf+Y_yzm=aq1Z4fZ-QgACN2srnC9twOWhVWw@mail.gmail.com>
	<CANJ5vP+=wCrzJ3Fdg0_5ZTTT-V-fw2AXUG=EgwsUcxXO=UpMgw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: "Michael S. Tsirkin" <mst@redhat.com>, netdev@vger.kernel.org,
	Eric Dumazet <edumazet@google.com>,
	lf-virt <virtualization@lists.linux-foundation.org>,
	Daniel Borkmann <dborkman@redhat.com>,
	"David S. Miller" <davem@davemloft.net>
To: Michael Dalton <mwdalton@google.com>, Eric Northup <digitaleric@google.com>
Return-path: <virtualization-bounces@lists.linux-foundation.org>
In-Reply-To: <CANJ5vP+=wCrzJ3Fdg0_5ZTTT-V-fw2AXUG=EgwsUcxXO=UpMgw@mail.gmail.com>
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

On 10/30/2013 03:05 AM, Michael Dalton wrote:
> Agreed Eric, the buffer size should be increased so that we can accommodate a
> MTU-sized packet + mergeable virtio net header in a single buffer. I will send
> a patch to fix shortly cleaning up the #define headers as Rusty indicated and
> increasing the buffer size slightly by VirtioNet header size bytes per Eric.
>
> Jason, I'll followup with you directly - I'd like to know your exact workload
> (single steam or multi-stream netperf?), VM configuration, etc, and also see if
> the nit that Erichas pointed out affects your results.

It's just a single TCP_STREAM from local host to guest with vhost_net
enabled. The host and guest were connected with bridge.
>   It is also
> worth noting that
> we may want to tune the queue sizes for your benchmarks, e.g, by reducing
> buffer size from 4KB to MTU-sized but keeping queue length constant, we're
> implicitly decreasing the number of bytes stored in the VirtioQueue for the
> VirtioNet device, so increasing the queue size may help.

The problem is the overhead of introduced by the frag refill and frag
list. Looking at tg3 and bnx2x, the frag were only used for small
packets not for jumbo frame which does not need a frag list. But your
patch tires to use it for GSO packets. So we'd better to solve it in
device level (e.g multiple rings with different size of buffers).

I try to change the queue size from 256 to 1024. Unfortunately, I didn't
see improvement. As a workaround, If you care only the MTU size packet
and do not want GSO packet to be received, you can just disable it by
specifying gso_tso{4|6}=off in qemu command line or let's make it
configurable through ethtool.
>
> Best,
>
> Mike
> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
