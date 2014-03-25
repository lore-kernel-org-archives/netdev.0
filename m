From: Neil Horman <nhorman@tuxdriver.com>
Subject: Re: [patch net-next RFC 0/4] introduce infrastructure for support of
 switch chip datapath
Date: Tue, 25 Mar 2014 15:35:33 -0400
Message-ID: <20140325193533.GF8102@hmsreliant.think-freely.org>
References: <1395243232-32630-1-git-send-email-jiri@resnulli.us>
 <532AD5B3.6020205@mojatatu.com>
 <20140320124021.GA2946@minipsycho.orion>
 <CAGVrzcbqQGGYb2Wkkekei7ivGd2XOnE+5GthLUv6_nD_oicrSQ@mail.gmail.com>
 <532C2AC4.7080303@mojatatu.com>
 <20140322094852.GB2844@minipsycho.orion>
 <5330BAB7.3040501@mojatatu.com>
 <20140325173927.GE8102@hmsreliant.think-freely.org>
 <20140325180009.GB15723@casper.infradead.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Jamal Hadi Salim <jhs@mojatatu.com>, Jiri Pirko <jiri@resnulli.us>,
	Florian Fainelli <f.fainelli@gmail.com>,
	netdev <netdev@vger.kernel.org>,
	David Miller <davem@davemloft.net>, andy@greyhouse.net,
	dborkman@redhat.com, ogerlitz@mellanox.com, jesse@nicira.com,
	pshelar@nicira.com, azhou@nicira.com,
	Ben Hutchings <ben@decadent.org.uk>,
	Stephen Hemminger <stephen@networkplumber.org>,
	jeffrey.t.kirsher@intel.com, vyasevic <vyasevic@redhat.com>,
	Cong Wang <xiyou.wangcong@gmail.com>,
	John Fastabend <john.r.fastabend@intel.com>,
	Eric Dumazet <edumazet@google.com>,
	Scott Feldman <sfeldma@cumulusnetworks.com>,
	Lennert Buytenhek <buytenh@wantstofly.org>
To: Thomas Graf <tgraf@suug.ch>
Return-path: <netdev-owner@vger.kernel.org>
Received: from charlotte.tuxdriver.com ([70.61.120.58]:60170 "EHLO
	smtp.tuxdriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754405AbaCYTgD (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 25 Mar 2014 15:36:03 -0400
Content-Disposition: inline
In-Reply-To: <20140325180009.GB15723@casper.infradead.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Mar 25, 2014 at 06:00:09PM +0000, Thomas Graf wrote:
> On 03/25/14 at 01:39pm, Neil Horman wrote:
> > No, but it would be really nice if these smaller devices could take advantage of
> > this infrastructure.  Looking at it, I don't see why thats not possible.  The
> > big trick (as we've discussed in the past), is using a net_device structure to
> > take advantage of all the features that net_devices offer while not enabling the
> > device specific features that some hardware doesn't allow.
> > 
> > For instance the broadcom chips that live in many wireless routers would be well
> > served by the model jiri has here as far as Media level interface control is
> > concerned (i.e. ifup/down/speed/duplex/etc), but its a bit lacking in that
> > net_devices are assumed to support L3 protocol configuration (i.e. they can have
> > ip addresses assigned to them), which you can't IIRC do on these chips.
> 
> How about a new device flag indicating pure L2 mode? Any L3 address
> configuration would fail with EAFNOSUPP.
> 
Yeah, we've discussed that before, and it seems like a good idea, though I'm not
sure that its flexible enough.  It clearly prevents L3 operations on devices
that can only do L2, which is great, but that may not be sufficient for some
devices.  For example, what if you wanted to use ebtables on an L2 port where
the hardware can't mirror the actions of a given table rule?  Do we need to
expand out those capabilities?

> > Would it be worth considering a private interface model?  That is to say:
> > 
> > 1) Ports on a switch chip are accessed using net_device structures, but
> > registered to a private list contained within the switch device, rather than to
> > the net namespaces device list.
> 
> > 2) Access to the switch ports via user space is done through the master switch
> > interface with additional netlink attributes specifying the port on the switch
> > to access (or not to access the master switch device directly)
> 
> > Such a model I think might fit well with Jiri's code here and provide greater
> > flexibility for a wider range of devices.  It would of course require
> > augmentation for user space, but the changes would be additive, so I think they
> > would be reasonable.  This would also allow the switch device to have a hook in
> > the control path to block or allow features that the hardware may or may not
> > support while still being able to use the existing net_device infrastructure to
> > support these operations as they are normally carried out.
> 
> I believe this would defeat the main advantage of reusing net_device
> model which is compatibility with the well established standard toolset.
> 
> In an ideal world, we represent what is possible using the existing
> net_device model.
> 

Maybe I'm not being clear. I'm not suggesting that we abandon the use of a
net_device to do any of this work, only that we add a layer of indirection to
get to it.  By Augmenting the existing network device stack to allow
registration of net_devices to arbitrary lists, rather than to a fixes
per-net-namespace global device list, we can operate net_devices that are only
visible within the scope of a given switch fabric.  User space still works the
same way, it just requires the specification of additional information when
speaking to ports on a switch device that may not be directly accessible via the
cpu.  For example, if a systems has a directly connected nic (em1), and a switch
fabric with a master bridge port (sw1), and 10 external ports (sw1pX), we could
access them all from user space via ip link show.  for example:

1) ip link show:
em1
sw1

2) ip link show sw1
sw1

3) ip link show -p sw1
sw1p0
sw1p1
sw1p2...


The idea is to augment user space to allow the visibiliy of ports through the
switch device, not directly, but using the same existing mechanisms.  We can
reuse all the existing infrastruture, but with this model, control must pass
through the switch device driver, allowing it to taylor available features by
passing the netlink request on to the appropriate netdevice, or sending back an
error itself.

> On top of that, like for VFs, we provide extended nested attributes or
> alternate control paths such as via OVS that provide the additional
> flexibility and control required by the more advanced devices.
I'm sorry, I don't understand the relevance here.  Are you suggesting that to
make this modification, we would need to augment more than a single set of
netlink control paths?

Neil

> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
> 
