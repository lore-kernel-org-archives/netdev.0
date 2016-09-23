From: Jakub Kicinski <jakub.kicinski@netronome.com>
Subject: Re: [RFC] net: store port/representative id in metadata_dst
Date: Fri, 23 Sep 2016 13:55:12 +0100
Message-ID: <20160923135512.64e5d5e9@jkicinski-Precision-T1700>
References: <1474572417-15907-1-git-send-email-jakub.kicinski@netronome.com>
        <20160923063429.GA1821@nanopsycho.orion>
        <20160923110609.2f221f99@griffin>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, Thomas Graf <tgraf@suug.ch>,
        Roopa Prabhu <roopa@cumulusnetworks.com>,
        ogerlitz@mellanox.com, John Fastabend <john.fastabend@gmail.com>,
        sridhar.samudrala@intel.com, ast@kernel.org, daniel@iogearbox.net,
        simon.horman@netronome.com, Paolo Abeni <pabeni@redhat.com>,
        Pravin B Shelar <pshelar@nicira.com>,
        hannes@stressinduktion.org, kubakici@wp.pl
To: Jiri Benc <jbenc@redhat.com>, Jiri Pirko <jiri@resnulli.us>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f51.google.com ([74.125.82.51]:38703 "EHLO
        mail-wm0-f51.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1757746AbcIWMzT (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 23 Sep 2016 08:55:19 -0400
Received: by mail-wm0-f51.google.com with SMTP id l132so28595590wmf.1
        for <netdev@vger.kernel.org>; Fri, 23 Sep 2016 05:55:18 -0700 (PDT)
In-Reply-To: <20160923110609.2f221f99@griffin>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 23 Sep 2016 11:06:09 +0200, Jiri Benc wrote:
> On Fri, 23 Sep 2016 08:34:29 +0200, Jiri Pirko wrote:
> > So if I understand that correctly, this would need some "shared netdev"
> > which would effectively serve only as a sink for all port netdevices to
> > tx packets to. On RX, this would be completely avoided. This lower
> > device looks like half zombie to me.  
> 
> Looks more like a quarter zombie. Even tx would not be allowed unless
> going through one of the ports, as all skbs without
> METADATA_HW_PORT_MUX metadata_dst would be dropped. But it would be
> possible to attach qdisc to the "lower" netdevice and it would actually
> have an effect. On rx this netdevice would be ignored completely. This
> is very weird behavior.
> 
> > I don't like it :( I wonder if the
> > solution would not be possible without this lower netdev.  
> 
> I agree. This approach doesn't sound correct. The skbs should not be
> requeued.

Thanks for the responses!

I think SR-IOV NICs are coming at this problem from a different angle,
we already have a big, feature-full per-port netdevs and now we want to
spawn representators for VFs to handle fallback traffic.  This patch
would help us mux VFR traffic on all the queues of the physical port
netdevs (the ones which were already present in legacy mode, that's the
lower device).

I read the mlxsw code when I was thinking about this and I wasn't
100% comfortable with returning NETDEV_TX_BUSY, I thought this
behaviour should be generally avoided.  (BTW a very lame question - does
mlxsw ever stop the queues?  AFAICS it only returns BUSY, isn't that
confusing to the stack?)

FWIW the switchdev SR-IOV model we have now seems to be to treat the
existing netdevs as "MAC ports" and spawn representatives for VFs but
not represent PFs in any way.  This makes it impossible to install
VF-PF flow rules.  I worry this can bite us later but that's slightly
different discussion :)  For the purpose of this patch please assume
the lower dev is the MAC/physical/external port.
