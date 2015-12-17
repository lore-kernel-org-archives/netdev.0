From: Alexander Aring <alex.aring@gmail.com>
Subject: Re: [RFCv4 bluetooth-next 1/2] 6lowpan: iphc: add support for
 stateful compression
Date: Thu, 17 Dec 2015 14:41:05 +0100
Message-ID: <20151217134100.GA6260@omega>
References: <1450101654-22633-1-git-send-email-alex.aring@gmail.com>
 <1450101654-22633-2-git-send-email-alex.aring@gmail.com>
 <AB80DA35A7B64E4E98291794926897D9011B97546F@MBX03.nvlsi.no>
 <20151215110835.GA3774@omega>
 <AB80DA35A7B64E4E98291794926897D9011B977941@MBX03.nvlsi.no>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Cc: "linux-wpan@vger.kernel.org" <linux-wpan@vger.kernel.org>,
	"linux-bluetooth@vger.kernel.org" <linux-bluetooth@vger.kernel.org>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"kernel@pengutronix.de" <kernel@pengutronix.de>,
	"mcr@sandelman.ca" <mcr@sandelman.ca>,
	"martin.gergeleit@hs-rm.de" <martin.gergeleit@hs-rm.de>
To: "Duda, Lukasz" <Lukasz.Duda@nordicsemi.no>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f41.google.com ([74.125.82.41]:36996 "EHLO
	mail-wm0-f41.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756506AbbLQNlN (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 17 Dec 2015 08:41:13 -0500
Content-Disposition: inline
In-Reply-To: <AB80DA35A7B64E4E98291794926897D9011B977941@MBX03.nvlsi.no>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Dec 17, 2015 at 12:26:37PM +0000, Duda, Lukasz wrote:
> Hi Alex!
> 
> > -----Original Message-----
> > From: Alexander Aring [mailto:alex.aring@gmail.com]
> > Sent: Tuesday, December 15, 2015 12:09
> > To: Duda, Lukasz
> > Cc: linux-wpan@vger.kernel.org; linux-bluetooth@vger.kernel.org;
> > netdev@vger.kernel.org; kernel@pengutronix.de; mcr@sandelman.ca;
> > martin.gergeleit@hs-rm.de
> > Subject: Re: [RFCv4 bluetooth-next 1/2] 6lowpan: iphc: add support for
> > stateful compression
> > 
> > On Tue, Dec 15, 2015 at 10:29:51AM +0000, Duda, Lukasz wrote:
> > > First of all great work for your series of patches on 6lowpan improvements
> > and
> > > stateful compression!
> > >
> > > I have just done some testing of this patch (without RADVD modifications),
> > and
> > > I can share my experiments using 6LoWPAN over BT-LE by sending simple
> > ICMPv6
> > > messages. Contexts for BTLE device has been added manually.
> > >
> > 
> > did you test that with linux <-> linux? Or linux <->
> > $SOME_OTHER_6LOWPAN_BTLE_STACK.
> > 
> > I tested it on my side with RIOT, it has 802.15.4 6LoWPAN support and
> > also manipulate manually the context table.
> > 
> 
> I have tested it with nRF52 BTLE device from Nordic Semiconductor 
> with IoT SDK, and Linux Ubuntu with BTLE Dongle that acts as Router/Master.
> 
> > > Experiment 1:
> > >
> > > Router: 2001:db8::1/64 BTLE: 2001:db8::211:22FF:FE33:4455/64
> > > CID 1: 2001:db8::/64
> > >
> > > Works fine, I see that CID 1 is used for both addresses. Router has 64 bits of
> > > IID inline and BTLE node has 0.
> > >
> > > Experiment 2:
> > >
> > > Router: 2001:db8::1/64 BTLE: 2001:db8::211:22FF:FE33:4455/64
> > > CID 3: 2001:db8::/64 CID 5: 2001:db8::1/128
> > >
> > > Works also fine, I see that both CID 3 and 5 are used, as well as both sides
> > > compress its IID in the best possible way. So the patch appears to work fine
> > on
> > > 6LoWPAN over BT-LE.
> > >
> > 
> > ok.
> > 
> > >
> > > However, I notice that the folder created in the sys/kernel/debug/6lowpan/
> > for
> > > my bluetooth network interface is called "bt%d". And I would imagine this
> > > should be "bt0", "bt1", ... and not the template?
> > >
> > 
> > urgh, this should not happen. I use "dev->name" for that and dev is the
> > netdevice structure. This should be an _unique_ interface name,
> > otherwise you will getting trouble if you have two btle 6lowpan
> > interfaces.
> > 
> > I didn't realized it because I create my interface with:
> > 
> > ip link add link wpan0 name lowpan0 type lowpan
> > 
> > but should change it into:
> > 
> > ip link add link wpan0 name lowpan%d type lowpan
> > 
> > I realized that the dev->name will be changed from template into "real"
> > name after registering. This should do the job:
> > 
> > diff --git a/net/6lowpan/core.c b/net/6lowpan/core.c
> > index c7f06f5..faf65ba 100644
> > --- a/net/6lowpan/core.c
> > +++ b/net/6lowpan/core.c
> > @@ -29,13 +29,13 @@ int lowpan_register_netdevice(struct net_device
> > *dev,
> > 
> >         lowpan_priv(dev)->lltype = lltype;
> > 
> > -       ret = lowpan_dev_debugfs_init(dev);
> > +       ret = register_netdevice(dev);
> >         if (ret < 0)
> >                 return ret;
> > 
> > -       ret = register_netdevice(dev);
> > +       ret = lowpan_dev_debugfs_init(dev);
> >         if (ret < 0)
> > -               lowpan_dev_debugfs_exit(dev);
> > +               unregister_netdevice(dev);
> > 
> >         return ret;
> >  }
> > 
> > I think it should be safe to do that after registering because we held the
> > RTNL lock. And the interface isn't up after registering.
> > 
> 
> Thanks! Your patch helped, and I acked it in separate mail thread.
> 
> > > Also, I notice that the compression for Flow Control and Traffic Label in IPv6
> > > header has been modified, these fields are no longer compressed in any
> > packets
> > > (0b11 value) that comes from Linux Kernel (e.g. ICMP Echo Request,
> > > Router Advertisement), instead I get three extra bytes (0b01 value).
> > > I would like to understand reason for this modification a little better.
> > 
> > 0b11 means that traffic class and flow label are zero. Are you sure that
> > these fields are zero inside the IPv6 header when you transmit
> > "e.g. ICMP Echo Request, RA"?
> > 
> > Can you verify this by running tcpdump/wireshark? Or instruments some
> > printk's at [0] for hdr->flow_lbl array and hdr->priority?
> > 
> > - Alex
> > 
> > [0] http://lxr.free-electrons.com/source/net/6lowpan/iphc.c#L428
> 
> I did some more linux debugging, and indeed, its IPv6 stack that already gives ip6hdr
> with flow label set to some strange number. Do you know maybe the reason of this?
> On Kernel version < 4.2 that field was always set to 0, thus better compression can
> be applied.
> 

I think it depends on ping6 implementation. There exists some of them
outside, I using "iputils" [0].

Look inside the manpage of iputils:

-F flow label
ping6 only.  Allocate and set 20 bit flow label (in hex) on echo
request packets.  If value is zero, kernel allocates random flow label.

This is for "echo request" only and if set it to zero then a random
one will be used. Anyway you can also try to set some -F "0xdead" and
look in wireshark if it's (6LoWPAN adaptation/transmitting) was
correctly.

What I believe when I read "If value is zero, kernel allocates random
flow label.", then you can't set it to zero from userspace, but I am not
100% sure, may depends on socket type (which depends on ping6
implementation).

At least:

It could be that the compression never worked correctly before and
simple set always flow_lbl compression to zero? Depends on how you test
it at "Kernel version < 4.2".

Please verify the testing with "Kernel version < 4.2" and check if
flow_lbl is zero before running 6LoWPAN adaptation with same ping6
implementation (but may also differs if they do some runtime checks on
what kernel supports).

- Alex

[0] https://github.com/iputils/iputils
