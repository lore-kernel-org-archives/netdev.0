From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net V2] vhost: net: switch to use data copy if pending
	DMAs exceed the limit
Date: Fri, 07 Mar 2014 16:39:48 -0500 (EST)
Message-ID: <20140307.163948.633184079575086092.davem@davemloft.net>
References: <1394170107-12018-1-git-send-email-jasowang@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: virtio-dev@lists.oasis-open.org, kvm@vger.kernel.org, mst@redhat.com,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	virtualization@lists.linux-foundation.org, qinchuanyu@huawei.com
To: jasowang@redhat.com
Return-path: <virtualization-bounces@lists.linux-foundation.org>
In-Reply-To: <1394170107-12018-1-git-send-email-jasowang@redhat.com>
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

From: Jason Wang <jasowang@redhat.com>
Date: Fri,  7 Mar 2014 13:28:27 +0800

> This is because the delay added by htb may lead the delay the finish
> of DMAs and cause the pending DMAs for tap0 exceeds the limit
> (VHOST_MAX_PEND). In this case vhost stop handling tx request until
> htb send some packets. The problem here is all of the packets
> transmission were blocked even if it does not go to VM2.

Isn't this essentially head of line blocking?

> We can solve this issue by relaxing it a little bit: switching to use
> data copy instead of stopping tx when the number of pending DMAs
> exceed half of the vq size. This is safe because:
> 
> - The number of pending DMAs were still limited (half of the vq size)
> - The out of order completion during mode switch can make sure that
>   most of the tx buffers were freed in time in guest.
> 
> So even if about 50% packets were delayed in zero-copy case, vhost
> could continue to do the transmission through data copy in this case.
> 
> Test result:
> 
> Before this patch:
> VM1 to VM2 throughput is 9.3Mbit/s
> VM1 to External throughput is 40Mbit/s
> CPU utilization is 7%
> 
> After this patch:
> VM1 to VM2 throughput is 9.3Mbit/s
> Vm1 to External throughput is 93Mbit/s
> CPU utilization is 16%
> 
> Completed performance test on 40gbe shows no obvious changes in both
> throughput and cpu utilization with this patch.
> 
> The patch only solve this issue when unlimited sndbuf. We still need a
> solution for limited sndbuf.
> 
> Cc: Michael S. Tsirkin <mst@redhat.com>
> Cc: Qin Chuanyu <qinchuanyu@huawei.com>
> Signed-off-by: Jason Wang <jasowang@redhat.com>

I'd like some vhost experts reviewing this before I apply it.
