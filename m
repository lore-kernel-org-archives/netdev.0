From: Ben Hutchings <bhutchings@solarflare.com>
Subject: Re: Trying to implement secondary loopback
Date: Fri, 15 Mar 2013 18:36:02 +0000
Message-ID: <1363372562.2560.7.camel@bwh-desktop.uk.solarflarecom.com>
References: <513F1A17.1000809@hhi.fraunhofer.de>
	 <CAFLxGvxcyDVwC-iys6UdKMBB6u3UQx6s7-mwm5caoNu=N7rmeA@mail.gmail.com>
	 <3D7E565A361FB844A410A5EFCDD7BA4002ECF5@MXSRV3.fe.hhi.de>
	 <87r4jjav00.fsf@xmission.com>
	 <3D7E565A361FB844A410A5EFCDD7BA4002EF11@MXSRV3.fe.hhi.de>
	 <878v5r9es7.fsf@xmission.com> <5142CE23.9070804@hhi.fraunhofer.de>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: "Eric W. Biederman" <ebiederm@xmission.com>,
	richard -rw- weinberger <richard.weinberger@gmail.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"davem@davemloft.net" <davem@davemloft.net>,
	"edumazet@google.com" <edumazet@google.com>,
	"herbert@gondor.apana.org.au" <herbert@gondor.apana.org.au>
To: Thomas Martitz <thomas.martitz@hhi.fraunhofer.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from webmail.solarflare.com ([12.187.104.25]:14421 "EHLO
	webmail.solarflare.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754212Ab3COSgJ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 15 Mar 2013 14:36:09 -0400
In-Reply-To: <5142CE23.9070804@hhi.fraunhofer.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 2013-03-15 at 08:30 +0100, Thomas Martitz wrote:
> Am 13.03.2013 22:21, schrieb Eric W. Biederman:
> > "Martitz, Thomas" <thomas.martitz@hhi.fraunhofer.de> writes:
> >
> >>> Von: Eric W. Biederman [ebiederm@xmission.com]
> >>>
> >>> The easy solution is to setup two network namespaces and two nics.
> >>> And transmit data from one network namespace to another, through your
> >>> nics.
> >
> >>
> >> That sounds a lot more involed than using loopback to send data back
> >> to the same process. And I guess just calling netif_rx() in the xmit()
> >> function wouldn't be sufficient either? Also I wouldn't know how to do
> >> that as I'm not yet very familiar with network namespaces (but that
> >> can clearly get fixed).
> >
> > It may sound involved but it is just a few lines of code to set up.
> >
> > ip netns add ns1
> > ip netns add ns2
> > ip link set nic1 netns ns1
> > ip link set nic2 netns ns2
> >
> > int main(int argc, char **argv)
> > {
> >          int netfd1, netfd2;
> >          int sk1, sk2;
> > 	netfd1 = open(/var/run/netns/nic1);
> > 	netfd2 = open(/var/run/netns/nic2);
> >
> > 	setns(netfd1, 0);
> > 	sk1 = socket(...);
> >
> >          setns(netfd2, 0);
> >          sk2 = socket(...);
> >
> >          /* test test test */
> > }
> >
> > And what is partidcularly interesting is that all of this works with
> > your drivers normal code paths without any kernel hacks.
> >
> > Eric
> >
> 
> 
> I have trouble understanding this approach. Does it mean that I have to 
> expose two interfaces from my kernel module. I.e. call register_netdev() 
> twice?
[...]

Perhaps you can use macvlan for this.  Create one net device in your
driver, then use macvlan to stack two net devices on top of it using
different MAC addresses.  I think you'll need to configure them in VEPA
mode so that macvlan doesn't bridge them.

As an alternative to network namespaces, you might find it easier to
assign one or both net devices to virtual machines.  virt-manager and
virsh can set up KVM virtual machines using macvlan/macvtap interfaces.

Ben.

-- 
Ben Hutchings, Staff Engineer, Solarflare
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.
