From: Stephen Hemminger <stephen@networkplumber.org>
Subject: Re: 8% performance improved by change tap interact with kernel
 stack
Date: Tue, 28 Jan 2014 08:58:34 -0800
Message-ID: <20140128085834.0325cd9f@nehalam.linuxnetplumber.net>
References: <52E766D4.4070901@huawei.com>
	<20140128083459.GB16833@redhat.com>
	<52E77506.1080604@huawei.com>
	<20140128094138.GA17332@redhat.com>
	<52E78416.50000@huawei.com>
	<20140128103325.GA17794@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Qin Chuanyu <qinchuanyu@huawei.com>, jasowang@redhat.com,
	Anthony Liguori <anthony@codemonkey.ws>,
	KVM list <kvm@vger.kernel.org>, netdev@vger.kernel.org
To: "Michael S. Tsirkin" <mst@redhat.com>
Return-path: <kvm-owner@vger.kernel.org>
In-Reply-To: <20140128103325.GA17794@redhat.com>
Sender: kvm-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, 28 Jan 2014 12:33:25 +0200
"Michael S. Tsirkin" <mst@redhat.com> wrote:

> On Tue, Jan 28, 2014 at 06:19:02PM +0800, Qin Chuanyu wrote:
> > On 2014/1/28 17:41, Michael S. Tsirkin wrote:
> > >>>I think it's okay - IIUC this way we are processing xmit directly
> > >>>instead of going through softirq.
> > >>>Was meaning to try this - I'm glad you are looking into this.
> > >>>
> > >>>Could you please check latency results?
> > >>>
> > >>netperf UDP_RR 512
> > >>test model: VM->host->host
> > >>
> > >>modified before : 11108
> > >>modified after  : 11480
> > >>
> > >>3% gained by this patch
> > >>
> > >>
> > >Nice.
> > >What about CPU utilization?
> > >It's trivially easy to speed up networking by
> > >burning up a lot of CPU so we must make sure it's
> > >not doing that.
> > >And I think we should see some tests with TCP as well, and
> > >try several message sizes.
> > >
> > >
> > Yes, by burning up more CPU we could get better performance easily.
> > So I have bond vhost thread and interrupt of nic on CPU1 while testing.
> > 
> > modified before, the idle of CPU1 is 0%-1% while testing.
> > and after modify, the idle of CPU1 is 2%-3% while testing
> > 
> > TCP also could gain from this, but pps is less than UDP, so I think
> > the improvement would be not so obviously.
> 
> Still need to test this doesn't regress but overall looks convincing to me.
> Could you send a patch, accompanied by testing results for
> throughput latency and cpu utilization for tcp and udp
> with various message sizes?
> 
> Thanks!
> 

There are a couple potential problems with this. The primary one is
that now you are violating the explicit assumptions about when netif_receive_skb()
can be called and because of that it may break things all over the place.

 *
 *	netif_receive_skb() is the main receive data processing function.
 *	It always succeeds. The buffer may be dropped during processing
 *	for congestion control or by the protocol layers.
 *
 *	This function may only be called from softirq context and interrupts
 *	should be enabled.

At a minimum, softirq (BH) and preempt must be disabled.

Another potential problem is that since a softirq is not used, the kernel stack
maybe much larger.

Maybe a better way would be implementing some form of NAPI in the TUN device?


