From: KY Srinivasan <kys@microsoft.com>
Subject: RE: [PATCH 1/1] Drivers: net-next: hyperv: Increase the size of the
 sendbuf region
Date: Fri, 1 Aug 2014 17:51:44 +0000
Message-ID: <e19aea30a421423090ba63db9ff8e0af@BY2PR0301MB0711.namprd03.prod.outlook.com>
References: <1406770549-29982-1-git-send-email-kys@microsoft.com>
 <20140731.215907.860867918938148695.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: "olaf@aepfle.de" <olaf@aepfle.de>,
 "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
 "jasowang@redhat.com" <jasowang@redhat.com>,
 "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
 "apw@canonical.com" <apw@canonical.com>,
 "devel@linuxdriverproject.org" <devel@linuxdriverproject.org>
To: David Miller <davem@davemloft.net>
Return-path: <driverdev-devel-bounces@linuxdriverproject.org>
In-Reply-To: <20140731.215907.860867918938148695.davem@davemloft.net>
Content-Language: en-US
List-Unsubscribe: <http://driverdev.linuxdriverproject.org/mailman/options/driverdev-devel>,
 <mailto:driverdev-devel-request@linuxdriverproject.org?subject=unsubscribe>
List-Archive: <http://driverdev.linuxdriverproject.org/pipermail/driverdev-devel>
List-Post: <mailto:driverdev-devel@linuxdriverproject.org>
List-Help: <mailto:driverdev-devel-request@linuxdriverproject.org?subject=help>
List-Subscribe: <http://driverdev.linuxdriverproject.org/mailman/listinfo/driverdev-devel>,
 <mailto:driverdev-devel-request@linuxdriverproject.org?subject=subscribe>
Errors-To: driverdev-devel-bounces@linuxdriverproject.org
Sender: driverdev-devel-bounces@linuxdriverproject.org
List-Id: netdev.vger.kernel.org



> -----Original Message-----
> From: David Miller [mailto:davem@davemloft.net]
> Sent: Thursday, July 31, 2014 9:59 PM
> To: KY Srinivasan
> Cc: netdev@vger.kernel.org; linux-kernel@vger.kernel.org;
> devel@linuxdriverproject.org; olaf@aepfle.de; apw@canonical.com;
> jasowang@redhat.com
> Subject: Re: [PATCH 1/1] Drivers: net-next: hyperv: Increase the size of the
> sendbuf region
> 
> From: "K. Y. Srinivasan" <kys@microsoft.com>
> Date: Wed, 30 Jul 2014 18:35:49 -0700
> 
> > For forwarding scenarios, it will be useful to allocate larger
> > sendbuf. Make the necessary adjustments to permit this.
> >
> > Signed-off-by: K. Y. Srinivasan <kys@microsoft.com>
> 
> This needs more information.
> 
> You're increasing the size by 16 times, 1MB --> 16MB, thus less cache locality.
> 
> You're also now using vmalloc() memory, thus more TLB misses and
> thrashing.
> 
> This must have a negative impact on performance, and you have to test for
> that and quantify it when making a change as serious as this one.
> 
> You also haven't gone into detail as to why forwarding scenerios require
> more buffer space, than say thousands of local sockets sending bulk TCP
> data.

David,

Intel did some benchmarking on our network throughput when Linux on Hyper-V was used as a gateway.
This fix gave us almost a 1 Gbps additional throughput on about 5Gbps base throughput we had prior to
Increasing the sendbuf size. The sendbuf mechanism is a copy based transport that we have which is clearly
more optimal than the copy-free page flipping mechanism (for small packets). In the forwarding scenario, we deal
only with MTU sized packets, and increasing the size of the senbuf area gave us the additional performance.

For what it is worth, Windows guests on Hyper-V, I am told use similar sendbuf size as well.

The exact value of sendbuf I think is less important than the fact that it needs to be larger than what Linux can
allocate as physically contiguous memory. Thus the change over to allocating via vmalloc(). As you know we currently
allocate 16MB receive buffer and we use vmalloc there for allocation. Also the low level channel code has already been
modified to deal with physically dis-contiguous memory in the ringbuffer setup.

Again based on experimentation Intel did, they say there was some improvement in throughput as the sendbuf size was
Increased up to 16MB and there was no effect on throughput beyond 16MB. Thus I chose 16MB here.

Increasing the sendbuf value makes a material difference in small packet handling. Let me know what I should do to
make this patch acceptable.

Regards,

K. Y

 
> 
> I'm not applying this, it needs a lot more work.
