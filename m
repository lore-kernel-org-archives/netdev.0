From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: Re: [PATCH net-next] net/gtp: Add udp source port generation
 according to flow hash
Date: Thu, 23 Feb 2017 17:42:29 +0100
Message-ID: <20170223164229.GA4996@salvia>
References: <1487257141-11706-1-git-send-email-ogerlitz@mellanox.com>
 <576077949.135577.1487282291666.JavaMail.zimbra@tpip.net>
 <CAJ3xEMijwHpWfxUFcaCiAkP_0P8R2u6Cv4L=Vc3b_dPf+beOBg@mail.gmail.com>
 <CALx6S34ibBFpmZvxAtUn6oqgX9M8C1a3gg1iZrWWzwbswatUSQ@mail.gmail.com>
 <20170223134947.GA4373@salvia>
 <635223204.206529.1487859673545.JavaMail.zimbra@tpip.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Tom Herbert <tom@herbertland.com>,
        Or Gerlitz <gerlitz.or@gmail.com>,
        Or Gerlitz <ogerlitz@mellanox.com>,
        "David S. Miller" <davem@davemloft.net>,
        Jamal Hadi Salim <jhs@mojatatu.com>,
        laforge <laforge@gnumonks.org>, netdev <netdev@vger.kernel.org>
To: Andreas Schultz <aschultz@tpip.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.us.es ([193.147.175.20]:38026 "EHLO mail.us.es"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751222AbdBWQmu (ORCPT <rfc822;netdev@vger.kernel.org>);
        Thu, 23 Feb 2017 11:42:50 -0500
Received: from antivirus1-rhel7.int (unknown [192.168.2.11])
        by mail.us.es (Postfix) with ESMTP id 4C3CD170D24
        for <netdev@vger.kernel.org>; Thu, 23 Feb 2017 17:42:46 +0100 (CET)
Received: from antivirus1-rhel7.int (localhost [127.0.0.1])
        by antivirus1-rhel7.int (Postfix) with ESMTP id 3AC76DA81F
        for <netdev@vger.kernel.org>; Thu, 23 Feb 2017 17:42:46 +0100 (CET)
Received: from antivirus1-rhel7.int (localhost [127.0.0.1])
        by antivirus1-rhel7.int (Postfix) with ESMTP id 92E09DA7E0
        for <netdev@vger.kernel.org>; Thu, 23 Feb 2017 17:42:42 +0100 (CET)
Content-Disposition: inline
In-Reply-To: <635223204.206529.1487859673545.JavaMail.zimbra@tpip.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Feb 23, 2017 at 03:21:13PM +0100, Andreas Schultz wrote:
> ----- On Feb 23, 2017, at 2:49 PM, pablo pablo@netfilter.org wrote:
[...]
> > According to specs, section 4.4.2.3 Encapsulated T-PDU, TS 29.281.
> > 
> > "The UDP Source Port is a locally allocated port number at the sending
> > GTP-U entity."
> > 
> > Older specs that refer to GTP-U such as TS 09.60 and TS 29.060 also
> > state the same.
> 
> It is absolutely valid the choose any sending port you want. I only
> think you should know which port you did send on.
> 
> TS 29.281, Sect. 5.2.2.1 defines the UDP port extension to be used
> in error indications. It provides the UDP source port of a G-PDU
> that triggered an error.
> 
> If the send side does not know which port it uses to send, how
> can it use this indication to correlate an error? That's the reason
> I thought it would be better to add the UDP source port to the
> PDP context and allow the control path to assign the source port
> on context creation.
> 
> Of course, this header is optional and the receiving side is not
> required to use it.
> 
> About the RSS spreading in the receive side, I would think that
> a receiver would prefer to process all packets that belong to a
> give TEID with the same receive instance. So keeping the UDP
> source port for a given TEID stable would be beneficial. As far
> as I understand it, the hash used in the patch uses the source
> and destination values from the original flow. This would mean
> that GTP packets that belong to the same TEID would end up with
> different UDP source ports.

The receiver needs to scale up, and that happens if packets are
distributed between CPUs in a way that make sense. I don't think it
makes sense to pass packets that belong to the same tunnel to the same
CPU, this is exactly the scenario that makes DDOS easier to trigger.

> So what about this as a compromise, we dd a UDP source port field
> to the PDP context, it defaults to 0 (zero), the control instance
> can optionally initialize this field, when we hit the xmit code
> and the port is non zero, use that value, if it is zero use the hash?

You want to use this for your VRF concept? I would like that you take
the time to explain us your usecases. How are you going to use this
mapping between tunnels and UDP source ports? An explaination would be
better than searching at some optional (corner case) extension in the
specs whose usage is questionable.

In any case, I think we want a good default behaviour, and I think
Or's patch provides it.
