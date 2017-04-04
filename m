From: Alexander Duyck <alexander.duyck@gmail.com>
Subject: Re: [Intel-wired-lan] [next-queue v6 PATCH 2/7] i40e: Introduce Port
 Representor netdevs and switchdev mode.
Date: Tue, 4 Apr 2017 08:29:03 -0700
Message-ID: <CAKgT0UeMtc4ywGa7wV4bbT7O54dTqpqGGDADfho3tmKTQ7NQ6g@mail.gmail.com>
References: <1490833375-2788-1-git-send-email-sridhar.samudrala@intel.com>
 <1490833375-2788-3-git-send-email-sridhar.samudrala@intel.com>
 <CAJ3xEMgVeri17KceKhnFUCCFj00yWXKtjwP4r36Pb-CSZiOTng@mail.gmail.com>
 <58E2974B.30503@intel.com> <CAJ3xEMikpx3JX5frn0Hbne6tTR9Vgu6Pv22TkEuaJP0mM1Au=w@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: "Samudrala, Sridhar" <sridhar.samudrala@intel.com>,
        Anjali Singhai Jain <anjali.singhai@intel.com>,
        Alexander Duyck <alexander.h.duyck@intel.com>,
        Jiri Pirko <jiri@resnulli.us>,
        Linux Netdev List <netdev@vger.kernel.org>,
        Jakub Kicinski <jakub.kicinski@netronome.com>,
        intel-wired-lan <intel-wired-lan@lists.osuosl.org>
To: Or Gerlitz <gerlitz.or@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-io0-f174.google.com ([209.85.223.174]:34938 "EHLO
        mail-io0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751092AbdDDP3F (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 4 Apr 2017 11:29:05 -0400
Received: by mail-io0-f174.google.com with SMTP id z13so98057864iof.2
        for <netdev@vger.kernel.org>; Tue, 04 Apr 2017 08:29:05 -0700 (PDT)
In-Reply-To: <CAJ3xEMikpx3JX5frn0Hbne6tTR9Vgu6Pv22TkEuaJP0mM1Au=w@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Apr 4, 2017 at 4:58 AM, Or Gerlitz <gerlitz.or@gmail.com> wrote:
> On Mon, Apr 3, 2017 at 9:41 PM, Samudrala, Sridhar
> <sridhar.samudrala@intel.com> wrote:
>> On 3/30/2017 12:17 AM, Or Gerlitz wrote:
>>> On Thu, Mar 30, 2017, Sridhar Samudrala wrote:
>
>>>> Port Representator netdevs are created for each PF and VF if the switch
>>>> mode is set to 'switchdev'. These netdevs can be used to control and
>>>> configure VFs and PFs when they are moved to a different namespace.
>>>> They enable exposing statistics, configure and monitor link state, mtu,
>>>> filters,fdb/vlan entries etc.
>
>>>> In switchdev mode, broadcasts from VFs are received by the PF and passed
>>>> to corresponding port representor netdev.
>
>>> What netdev represents the uplink (wire port) in your impl?
>
> combining your replies from the two emails:
>
>> We don't have a port netdev representing the uplink in this implementation as we
>> cannot control the frames going out the uplink via sw rules with the current
>> generation of hw/fw.
>
>> fwd to CPU as default rule is not possible with the current generation of hw/fw.
>> So we would like to enable switchdev to expose the port representors and start
>> adding offloads in an incremental way.
>
> I lost you even deeper
>
> I was asking on frames getting in from the uplink and not getting out
> the uplink.

Frames coming from the uplink will by default be routed to the PF. So
are you saying you want a representor for the uplink to handle the
packets that don't have any rules set up for them, correct?

I think we could set something like this up as we do have the concept
of a "default" entity that everything falls back into. It is just a
bit muddled since that current exists as a part of the PF.

> This is about offloading to HW a switching model where the steering
> (matching and actions)
> comes into play on the port ingress. E.g
>
> VF NIC xmit ---> VF vport e-switch rep recv --> SW or HW steering

So this bit we can't really support very well with the i40e hardware.
The problem is that unless there is a rule that exists to route it to
another PF/VF there is a default rule in the hardware that would send
it out the uplink port. The only data we can really catch on the port
representors is broadcast/multicast because it does replication.

> other node xmit --> UPLINK vport e-switch rep recv --> SW or HW steering

This part I think we can do. The default behavior would be to send a
packet to the default entity which in this case is the PF.

> If your current HW can't let you have "send to CPU" as the default
> action on ingress
> for the VFs and uplink ports, I am not clear what use-cases you can do
> in slow path
> (only reps, no offloaded SW rules) and for past path (reps + offloaded
> SW rules)...
>
> Can you please elaborate on such use-cases, so the bigger picture is more clear?

So the main goal with all of this is to support TC offloads so that we
can program filters to route packets from the default entity to the
VF. I agree that I think we are missing the uplink port. We probably
just need to add it as the "default" handler for packets that
originate with a source MAC address that is not the PF or one of the
VFs.

We can discuss this further at netdev/netconf.

- Alex
