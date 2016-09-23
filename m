From: John Fastabend <john.fastabend@gmail.com>
Subject: Re: [RFC] net: store port/representative id in metadata_dst
Date: Fri, 23 Sep 2016 07:23:26 -0700
Message-ID: <57E53ADE.10806@gmail.com>
References: <1474572417-15907-1-git-send-email-jakub.kicinski@netronome.com>
 <20160923063429.GA1821@nanopsycho.orion> <20160923110609.2f221f99@griffin>
 <20160923135512.64e5d5e9@jkicinski-Precision-T1700>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, Thomas Graf <tgraf@suug.ch>,
        Roopa Prabhu <roopa@cumulusnetworks.com>,
        ogerlitz@mellanox.com, sridhar.samudrala@intel.com, ast@kernel.org,
        daniel@iogearbox.net, simon.horman@netronome.com,
        Paolo Abeni <pabeni@redhat.com>,
        Pravin B Shelar <pshelar@nicira.com>,
        hannes@stressinduktion.org, kubakici@wp.pl
To: Jakub Kicinski <jakub.kicinski@netronome.com>,
        Jiri Benc <jbenc@redhat.com>, Jiri Pirko <jiri@resnulli.us>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f196.google.com ([209.85.192.196]:34114 "EHLO
        mail-pf0-f196.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1759866AbcIWOXv (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 23 Sep 2016 10:23:51 -0400
Received: by mail-pf0-f196.google.com with SMTP id 21so5394727pfy.1
        for <netdev@vger.kernel.org>; Fri, 23 Sep 2016 07:23:50 -0700 (PDT)
In-Reply-To: <20160923135512.64e5d5e9@jkicinski-Precision-T1700>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 16-09-23 05:55 AM, Jakub Kicinski wrote:
> On Fri, 23 Sep 2016 11:06:09 +0200, Jiri Benc wrote:
>> On Fri, 23 Sep 2016 08:34:29 +0200, Jiri Pirko wrote:
>>> So if I understand that correctly, this would need some "shared netdev"
>>> which would effectively serve only as a sink for all port netdevices to
>>> tx packets to. On RX, this would be completely avoided. This lower
>>> device looks like half zombie to me.  
>>
>> Looks more like a quarter zombie. Even tx would not be allowed unless
>> going through one of the ports, as all skbs without
>> METADATA_HW_PORT_MUX metadata_dst would be dropped. But it would be
>> possible to attach qdisc to the "lower" netdevice and it would actually
>> have an effect. On rx this netdevice would be ignored completely. This
>> is very weird behavior.
>>
>>> I don't like it :( I wonder if the
>>> solution would not be possible without this lower netdev.  
>>
>> I agree. This approach doesn't sound correct. The skbs should not be
>> requeued.
> 
> Thanks for the responses!

Nice timing we were just thinking about this.

> 
> I think SR-IOV NICs are coming at this problem from a different angle,
> we already have a big, feature-full per-port netdevs and now we want to
> spawn representators for VFs to handle fallback traffic.  This patch
> would help us mux VFR traffic on all the queues of the physical port
> netdevs (the ones which were already present in legacy mode, that's the
> lower device).

Yep, I like the idea in general. I had a slightly different approach in
mind though. If you look at __dev_queue_xmit() there is a void
accel_priv pointer (gather you found this based on your commit note).
My take was we could extend this a bit so it can be used by the VFR
devices and they could do a dev_queue_xmit_accel(). In this way there is
no need to touch /net/core/{filter, dst, ip_tunnel}.c etc. Maybe the
accel logic needs to be extended to push the priv pointer all the way
through the xmit routine of the target netdev though. This should look
a lot like the macvlan accelerated xmit device path without the
switching logic.

Of course maybe the name would be extended to dev_queue_xmit_extended()
or something.

So the flow on ingress would be,

  1. pkt_received_by_PF_netdev
  2. PF_netdev reads some tag off packet/descriptor and sets correct
     skb->dev field. This is needed so stack "sees" packets from
     correct VF ports.
  3. packet passed up to stack.

I guess it is a bit "zombie" like on the receive path because the packet
is never actually handled by VF netdev code per se and on egress can
traverse both the VFR and PF netdevs qdiscs. But on the other hand the
VFR netdevs and PF netdevs are all in the same driver. Plus using a
queue per VFR is a bit of a waste as its not needed and also hardware
may not have any mechanism to push VF traffic onto a rx queue.

On egress,

  1. VFR xmit is called
  2. VFR xmit calls dev_queue_xmit_accel() with some meta-data if needed
     for the lower netdev
  3. lower netdev sends out the packet.

Again we don't need to waste any queues for each VFR and the VFR can be
a LLTX device. In this scheme I think you avoid much of the changes in
your patch and keep it all contained in the driver. Any thoughts?

To address 'I wonder if the solution can be done without this lower
netdev' I think it can be but it creates two issues which I'm not sure
have a good solution.

Without a lowerdev we either (a) give each VFR its own queue which I
don't like because it complicates mgmt and uses resources or (b) we
implicitly share queues. The later could be fine it just looks a bit
cleaner IMO to make it explicit.

With regard to VF-PF flow rules if we allow matching on ingress port
then can all your flow rules be pushed through the PF netdevices or
if you want any of the VFR netdevs? After all I expsect the flow rule
table is actually a shared resource between all attached ports.

Thanks,
.John





> 
> I read the mlxsw code when I was thinking about this and I wasn't
> 100% comfortable with returning NETDEV_TX_BUSY, I thought this
> behaviour should be generally avoided.  (BTW a very lame question - does
> mlxsw ever stop the queues?  AFAICS it only returns BUSY, isn't that
> confusing to the stack?)
> 
> FWIW the switchdev SR-IOV model we have now seems to be to treat the
> existing netdevs as "MAC ports" and spawn representatives for VFs but
> not represent PFs in any way.  This makes it impossible to install
> VF-PF flow rules.  I worry this can bite us later but that's slightly
> different discussion :)  For the purpose of this patch please assume
> the lower dev is the MAC/physical/external port.
> 
