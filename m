From: Roopa Prabhu <roopa@cumulusnetworks.com>
Subject: Re: [RFC PATCH net-next 0/5] bridge: per vlan lwt and dst_metadata
 support
Date: Mon, 23 Jan 2017 16:00:32 -0800
Message-ID: <58869920.1080006@cumulusnetworks.com>
References: <1484977616-1541-1-git-send-email-roopa@cumulusnetworks.com> <20170123080805.GB1831@nanopsycho.orion> <20170123095130.59ddcf34@griffin> <58862BAA.4060001@cumulusnetworks.com> <20170123172458.5c849171@griffin>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: Jiri Pirko <jiri@resnulli.us>, netdev@vger.kernel.org,
        davem@davemloft.net, stephen@networkplumber.org,
        nikolay@cumulusnetworks.com, tgraf@suug.ch,
        hannes@stressinduktion.org, pshelar@ovn.org,
        dsa@cumulusnetworks.com, hadi@mojatatu.com
To: Jiri Benc <jbenc@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f174.google.com ([209.85.192.174]:32876 "EHLO
        mail-pf0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751891AbdAXAAg (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 23 Jan 2017 19:00:36 -0500
Received: by mail-pf0-f174.google.com with SMTP id y143so44919794pfb.0
        for <netdev@vger.kernel.org>; Mon, 23 Jan 2017 16:00:35 -0800 (PST)
In-Reply-To: <20170123172458.5c849171@griffin>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 1/23/17, 8:24 AM, Jiri Benc wrote:
> On Mon, 23 Jan 2017 08:13:30 -0800, Roopa Prabhu wrote:
>> And, a 'vlan-to-tunid' mapping is a very common configuration in L2 ethernet vpn configurations.
> You have one particular and narrow use case in mind and are proposing a
> rather large patchset to add support for that (and only that) single
> use case, while we already have a generic mechanism in place to address
> this and many similar (and dissimilar, too) use cases. That doesn't
> sound right.
Let me clarify:
the generic mechanism you are talking about is dst_metadata infra. Any subsystem can use it.
tc vlan and dst_metadata wrapper/filter provide a creative way to use it inside the tc subsystem and is very
useful for people using tc all-around.
What I am proposing here is hooks in bridge to use the dst_metadata for pure L2 networks who
use the bridge driver. This is similar to how we have lwt plugged into the L3 (routing) code.
If you are using the bridge driver for vlan config and filtering, I don't see why one
 has to duplicate vlan config using tc. Its painful trying to deploy l2 networks with vlan config spanning
multiple subsystems and apis.

Regarding the patch-set size, let me give you a breakdown:
If i used tc for passing dst_metadata (assume 4k vlans that are participating in l2 ethernet vpn):
(a) configure bridging/vlan filtering using bridge driver (4k vlans)
(b) configure tc rules to map vlans to tunnel-id (Additional patch to tc to only allow tunnel-id in dst_metadata: ingress + egress = 8k tc rules)
(c) vxlan driver patch to make it bridge friendly (my patch in this series is required regardless if i use tc or bridge driver for dst_metadata because vxlan driver learns and needs to carry the forwarding information database)
(d) ethernet vpn controller (quagga bgp) looks at 'bridge api + vxlan api + tc filtering rules'
           

My current series:
(a) configure bridging/vlan filtering using bridge driver (4k vlans with tunnel info)
(b) vxlan driver patch to make it bridge friendly (my patch in this series is required regardless if
i use tc or bridge driver for dst_metadata because vxlan driver learns and needs to carry the forwarding information database)
(c) ethernet vpn controller (quagga bgp) looks at 'bridge api + vxlan api'


And btw, most of the functions that i am adding in the bridge driver are related to vlan range handling.
vlan ranges code is tricky and i am trying to also support vlan-tunnelid mapping in ranges, and i have tried
to rewrite my own vlan range code (added long back) to include tunnel info. The rest is just use of the dst_metadata infra
to store and use  dst_metadata per vlan.


>
> If the current generic mechanisms have bottlenecks for your use case,
> let's work on removing those bottlenecks. That way, everybody benefits,
> not just a single use case.
For people using all tc, the tc wrapper for dst_metadata is a good fit.
I see my series as still using the generic 'dst_metadata' mechanism/infra for a newer use case.
like i say above, I see this similar to how we have plugged dst_metadata into the L3 (routing) code.
This does it in the bridging code (for L2 networks).

Thanks,
Roopa
