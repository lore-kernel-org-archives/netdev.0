From: Florian Fainelli <f.fainelli@gmail.com>
Subject: Re: [patch net-next RFC 0/4] introduce infrastructure for support of
 switch chip datapath
Date: Tue, 25 Mar 2014 11:33:22 -0700
Message-ID: <CAGVrzcacuU=RsnBOQh2-u+AjsMvznUYWFJru86w09+Vpdta2KQ@mail.gmail.com>
References: <1395243232-32630-1-git-send-email-jiri@resnulli.us>
 <532AD5B3.6020205@mojatatu.com> <20140320124021.GA2946@minipsycho.orion>
 <CAGVrzcbqQGGYb2Wkkekei7ivGd2XOnE+5GthLUv6_nD_oicrSQ@mail.gmail.com>
 <532C2AC4.7080303@mojatatu.com> <20140322094852.GB2844@minipsycho.orion>
 <5330BAB7.3040501@mojatatu.com> <20140325173927.GE8102@hmsreliant.think-freely.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Jamal Hadi Salim <jhs@mojatatu.com>, Jiri Pirko <jiri@resnulli.us>,
	netdev <netdev@vger.kernel.org>,
	David Miller <davem@davemloft.net>, andy <andy@greyhouse.net>,
	tgraf <tgraf@suug.ch>, dborkman <dborkman@redhat.com>,
	ogerlitz <ogerlitz@mellanox.com>, jesse <jesse@nicira.com>,
	pshelar <pshelar@nicira.com>, azhou <azhou@nicira.com>,
	Ben Hutchings <ben@decadent.org.uk>,
	Stephen Hemminger <stephen@networkplumber.org>,
	jeffrey.t.kirsher@intel.com, vyasevic <vyasevic@redhat.com>,
	Cong Wang <xiyou.wangcong@gmail.com>,
	John Fastabend <john.r.fastabend@intel.com>,
	Eric Dumazet <edumazet@google.com>,
	Scott Feldman <sfeldma@cumulusnetworks.com>,
	Lennert Buytenhek <buytenh@wantstofly.org>,
	Felix Fietkau <nbd@openwrt.org>
To: Neil Horman <nhorman@tuxdriver.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f182.google.com ([209.85.192.182]:33571 "EHLO
	mail-pd0-f182.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752206AbaCYSeD (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 25 Mar 2014 14:34:03 -0400
Received: by mail-pd0-f182.google.com with SMTP id y10so798314pdj.13
        for <netdev@vger.kernel.org>; Tue, 25 Mar 2014 11:34:02 -0700 (PDT)
In-Reply-To: <20140325173927.GE8102@hmsreliant.think-freely.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

2014-03-25 10:39 GMT-07:00 Neil Horman <nhorman@tuxdriver.com>:
> On Mon, Mar 24, 2014 at 07:07:35PM -0400, Jamal Hadi Salim wrote:
>> On 03/22/14 05:48, Jiri Pirko wrote:
>> >Fri, Mar 21, 2014 at 01:04:20PM CET, jhs@mojatatu.com wrote:
>>
>> >Hmm. This got me thinking about netdev and switches well and perhaps the
>> >switchdev api could be mostly implemented by couple of more ndos and
>> >feature flags. That way we could stick to your immortal netdev :)
>> >
>> >
>>
>> Perhaps ;->
>>
>> >>
>> >>In my view: that (immortal) device for L2/bridging is the bridge or
>> >>maybe a more barebone version of the bridge (since it has gained a
>> >>little more weight in recent times).
>> >
>> >Well, I do not think that bridge is ideal abstraction for modern switch
>> >chips. Bridge is very limited.
>> >
>>
>> True - but i was more thinking of being inclusive of the smaller
>> devices. They are mostly L2 only and in very limited scope. And thats
>> probably 95% of the population. The things you are talking about
>> are very high end and they can do more. Florian's taxanomy was useful.
>>
>> >But I don't necessary think it is needed to "mask" as a bride or mimic a
>> >bridge in any way. DSA does not do that either.
> No, but it would be really nice if these smaller devices could take advantage of
> this infrastructure.  Looking at it, I don't see why thats not possible.  The
> big trick (as we've discussed in the past), is using a net_device structure to
> take advantage of all the features that net_devices offer while not enabling the
> device specific features that some hardware doesn't allow.
>
> For instance the broadcom chips that live in many wireless routers would be well
> served by the model jiri has here as far as Media level interface control is
> concerned (i.e. ifup/down/speed/duplex/etc), but its a bit lacking in that
> net_devices are assumed to support L3 protocol configuration (i.e. they can have
> ip addresses assigned to them), which you can't IIRC do on these chips.

In fact, some switches could have valid L3 configurations, what you
usually do is have the switch be configured such that it selectively
inserts Broadcom tags for a given set of physical ports, such that
your CPU port (In-band Management port in Broadcom terminology), gets
flooded with such packets, and can dispatch those packets to the
per-port netdevices. Then you can take any decisions based on those
received packets, such as bridging this per-port netdevice with
another one for instance, or any switch topology change.

>
> Would it be worth considering a private interface model?  That is to say:
>
> 1) Ports on a switch chip are accessed using net_device structures, but
> registered to a private list contained within the switch device, rather than to
> the net namespaces device list.

I think this would be a good model for simple embedded switches that
only support 802.1q VLANs for instance, since we won't be able to get
any actual data to be sent/received to any per-port netdevice, those
per-port netdevices would only be effective for control at the L2
level.

For switches that do support tags, I think we do want per-port
netdevices to appear in the regular netdevices namespace as those
might be able to get actual data sent to/received from by using these
tags, at least momentarily until a higher-level entity decides
otherwise (e.g: by bridging, disabling interfaces...).

>
> 2) Access to the switch ports via user space is done through the master switch
> interface with additional netlink attributes specifying the port on the switch
> to access (or not to access the master switch device directly)

OpenWrt's swconfig model was to use the CPU Ethernet interface as the
master device for accessing the switch, although it did not use
RTNETLINK, but a separate Genl family, I think this is a good model.

One thing that was easy with OpenWrt's swconfig model was to promote
what started as a switch specific feature into something that could
become a generic operation that all switch drivers could implement. It
was also very easy to add custom switch driver features without
bloating the switch configuration API.

>
>
> Such a model I think might fit well with Jiri's code here and provide greater
> flexibility for a wider range of devices.  It would of course require
> augmentation for user space, but the changes would be additive, so I think they
> would be reasonable.  This would also allow the switch device to have a hook in
> the control path to block or allow features that the hardware may or may not
> support while still being able to use the existing net_device infrastructure to
> support these operations as they are normally carried out.

Sounds good. There might be a bunch of new NETIF_F_* flags to add to
help advertising switch-specific features such as: hardware/software
switch tag insertion, support for classification, support for
influencing switch queueing etc... but this does not have to be
available from day 1.
-- 
Florian
