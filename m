From: Shmulik Ladkani <shmulik.ladkani@gmail.com>
Subject: Re: [PATCH net v3] ipv4: allow local fragmentation in
 ip_finish_output_gso()
Date: Fri, 4 Nov 2016 10:02:06 +0200
Message-ID: <20161104100206.12f430c9@halley>
References: <1478118977-19608-1-git-send-email-lrichard@redhat.com>
        <20161103222751.5ae120ed@halley>
        <1769078966.96766888.1478207154311.JavaMail.zimbra@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: fw@strlen.de, netdev@vger.kernel.org, jtluka@redhat.com
To: Lance Richardson <lrichard@redhat.com>, hannes@stressinduktion.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f46.google.com ([74.125.82.46]:37943 "EHLO
        mail-wm0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1760226AbcKDICK (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 4 Nov 2016 04:02:10 -0400
Received: by mail-wm0-f46.google.com with SMTP id n67so33016915wme.1
        for <netdev@vger.kernel.org>; Fri, 04 Nov 2016 01:02:10 -0700 (PDT)
In-Reply-To: <1769078966.96766888.1478207154311.JavaMail.zimbra@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,

On Thu, 3 Nov 2016 17:05:54 -0400 (EDT) Lance Richardson <lrichard@redhat.com> wrote:
> 
> I'm still digesting the patchwork history, but it seems to me:
> 
>    1) If we call skb_gso_validate_mtu() and it returns true, ip_finish_output2() will
>       be called, just as before, so nothing changes.
> 
>    2) If we were to avoid calling skb_gso_validate_mtu() when it would have returned
>       false and call ip_finish_output2() without performing fragmentation, we
>       would transmit (or attempt to transmit) a packet that exceeds the configured
>       MTU.

Yes, this seemed strange to me as well.

I proposed your exact same patch, but Hannes wanted to limit its
behavior, expressing the following concerns (see [1]), quote:

    "The reason why I rather don't want to see a general solution is that
    currently gre and ipip are pmtu-safe and I rather would like to keep the
    old behavior that gre and ipip packets don't get treated alike. I
    couldn't check the current throughly but it seems they would also be
    affected by this change.

    My idea was to put those IPSKB_FORWARD just into the vxlan and geneve
    endpoints which could be seen as UDP endpoints and don't forward and
    care about pmtu events."

and

    "My argumentation is that vxlan and geneve can be seen as endpoints and
    don't have proper pmtu handling. Thus I would be fine with adding hacks
    to just make it working. For GRE I would like to keep strict internet
    pmtu handling and also keep the normal ethernet semantics in place, that
    we should drop packets if another interface did transmit on an ethernet
    bridge with a too big frame size."

Point is, I have no objection to the suggested patch as a whole.
I think (and thought) it is generally correct, as it fixes the anomalies
happending with GSO skbs not getting same treatment as non-gso skbs.

Just want to check whether Hannes' concerns are still valid, and if so,
refine the patch as needed.

Best,
Shmulik

[1] https://patchwork.ozlabs.org/patch/646683/
