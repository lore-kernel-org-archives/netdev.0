From: "Michael S. Tsirkin" <mst@redhat.com>
Subject: Re: 8% performance improved by change tap interact with kernel stack
Date: Tue, 28 Jan 2014 11:41:38 +0200
Message-ID: <20140128094138.GA17332@redhat.com>
References: <52E766D4.4070901@huawei.com>
 <20140128083459.GB16833@redhat.com>
 <52E77506.1080604@huawei.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: jasowang@redhat.com, Anthony Liguori <anthony@codemonkey.ws>,
	KVM list <kvm@vger.kernel.org>, netdev@vger.kernel.org
To: Qin Chuanyu <qinchuanyu@huawei.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:43041 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754771AbaA1Jgw (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 28 Jan 2014 04:36:52 -0500
Content-Disposition: inline
In-Reply-To: <52E77506.1080604@huawei.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Jan 28, 2014 at 05:14:46PM +0800, Qin Chuanyu wrote:
> On 2014/1/28 16:34, Michael S. Tsirkin wrote:
> >On Tue, Jan 28, 2014 at 04:14:12PM +0800, Qin Chuanyu wrote:
> >>according perf test result=EF=BC=8CI found that there are 5%-8% cpu=
 cost on
> >>softirq by use netif_rx_ni called in tun_get_user.
> >>
> >>so I changed the function which cause skb transmitted more quickly.
> >>from
> >>	tun_get_user	->
> >>		 netif_rx_ni(skb);
> >>to
> >>	tun_get_user	->
> >>		rcu_read_lock_bh();
> >>		netif_receive_skb(skb);
> >>		rcu_read_unlock_bh();
> >>
> >>The test result is as below:
> >>	CPU: Intel(R) Xeon(R) CPU E5620  @ 2.40GHz
> >>	NIC: intel 82599
> >>	Host OS/Guest OS:suse11sp3
> >>	Qemu-1.6
> >>	netperf udp 512(VM tx)
> >>	test model: VM->host->host
> >>
> >>	modified before : 2.00Gbps 461146pps
> >>	modified after  : 2.16Gbps 498782pps
> >>
> >>8% performance gained from this change,
> >>Is there any problem for this patch ?
> >
> >I think it's okay - IIUC this way we are processing xmit directly
> >instead of going through softirq.
> >Was meaning to try this - I'm glad you are looking into this.
> >
> >Could you please check latency results?
> >
> netperf UDP_RR 512
> test model: VM->host->host
>=20
> modified before : 11108
> modified after  : 11480
>=20
> 3% gained by this patch
>=20
>=20

Nice.
What about CPU utilization?
It's trivially easy to speed up networking by
burning up a lot of CPU so we must make sure it's
not doing that.
And I think we should see some tests with TCP as well, and
try several message sizes.
