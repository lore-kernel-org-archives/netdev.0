From: Joe Stringer <joe@ovn.org>
Subject: Re: [PATCH v2 net-next 7/9] openvswitch: Add original direction
 conntrack tuple to sw_flow_key.
Date: Wed, 8 Feb 2017 15:42:44 -0800
Message-ID: <CAPWQB7GAJkPUjsTO0UW59m=fot-rg_EirrkmDkmOzBswb1xapQ@mail.gmail.com>
References: <1486582330-31152-1-git-send-email-jarno@ovn.org> <1486582330-31152-8-git-send-email-jarno@ovn.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: netdev <netdev@vger.kernel.org>
To: Jarno Rajahalme <jarno@ovn.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from slow1-d.mail.gandi.net ([217.70.178.86]:55512 "EHLO
        slow1-d.mail.gandi.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751484AbdBHXqw (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 8 Feb 2017 18:46:52 -0500
Received: from relay3-d.mail.gandi.net (relay3-d.mail.gandi.net [217.70.183.195])
        by slow1-d.mail.gandi.net (Postfix) with ESMTP id 584B447B7B7
        for <netdev@vger.kernel.org>; Thu,  9 Feb 2017 00:43:35 +0100 (CET)
Received: from mfilter19-d.gandi.net (mfilter19-d.gandi.net [217.70.178.147])
        by relay3-d.mail.gandi.net (Postfix) with ESMTP id 3362FA80CF
        for <netdev@vger.kernel.org>; Thu,  9 Feb 2017 00:43:08 +0100 (CET)
Received: from relay3-d.mail.gandi.net ([IPv6:::ffff:217.70.183.195])
        by mfilter19-d.gandi.net (mfilter19-d.gandi.net [::ffff:10.0.15.180]) (amavisd-new, port 10024)
        with ESMTP id RNtAJtGC_3Ks for <netdev@vger.kernel.org>;
        Thu,  9 Feb 2017 00:43:06 +0100 (CET)
Received: from mail-qt0-f170.google.com (mail-qt0-f170.google.com [209.85.216.170])
        (Authenticated sender: joe@ovn.org)
        by relay3-d.mail.gandi.net (Postfix) with ESMTPSA id 126F3A80CD
        for <netdev@vger.kernel.org>; Thu,  9 Feb 2017 00:43:05 +0100 (CET)
Received: by mail-qt0-f170.google.com with SMTP id x49so181174847qtc.2
        for <netdev@vger.kernel.org>; Wed, 08 Feb 2017 15:43:05 -0800 (PST)
In-Reply-To: <1486582330-31152-8-git-send-email-jarno@ovn.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 8 February 2017 at 11:32, Jarno Rajahalme <jarno@ovn.org> wrote:
> Add the fields of the conntrack original direction 5-tuple to struct
> sw_flow_key.  The new fields are initially marked as non-existent, and
> are populated whenever a conntrack action is executed and either finds
> or generates a conntrack entry.  This means that these fields exist
> for all packets that were not rejected by conntrack as untrackable.
>
> The original tuple fields in the sw_flow_key are filled from the
> original direction tuple of the conntrack entry relating to the
> current packet, or from the original direction tuple of the master
> conntrack entry, if the current conntrack entry has a master.
> Generally, expected connections of connections having an assigned
> helper (e.g., FTP), have a master conntrack entry.
>
> The main purpose of the new conntrack original tuple fields is to
> allow matching on them for policy decision purposes, with the premise
> that the admissibility of tracked connections reply packets (as well
> as original direction packets), and both direction packets of any
> related connections may be based on ACL rules applying to the master
> connection's original direction 5-tuple.  This also makes it easier to
> make policy decisions when the actual packet headers might have been
> transformed by NAT, as the original direction 5-tuple represents the
> packet headers before any such transformation.
>
> When using the original direction 5-tuple the admissibility of return
> and/or related packets need not be based on the mere existence of a
> conntrack entry, allowing separation of admission policy from the
> established conntrack state.  While existence of a conntrack entry is
> required for admission of the return or related packets, policy
> changes can render connections that were initially admitted to be
> rejected or dropped afterwards.  If the admission of the return and
> related packets was based on mere conntrack state (e.g., connection
> being in an established state), a policy change that would make the
> connection rejected or dropped would need to find and delete all
> conntrack entries affected by such a change.  When using the original
> direction 5-tuple matching the affected conntrack entries can be
> allowed to time out instead, as the established state of the
> connection would not need to be the basis for packet admission any
> more.
>
> It should be noted that the directionality of related connections may
> be the same or different than that of the master connection, and
> neither the original direction 5-tuple nor the conntrack state bits
> carry this information.  If needed, the directionality of the master
> connection can be stored in master's conntrack mark or labels, which
> are automatically inherited by the expected related connections.
>
> The fact that neither ARP not ND packets are trackable by conntrack

* ARP nor ND

> allows mutual exclusion between ARP/ND and the new conntrack original
> tuple fields.  Hence, the IP addresses are overlaid in union with ARP
> and ND fields.  This allows the sw_flow_key to not grow much due to
> this patch, but it also means that we must be careful to never use the
> new key fields with ARP or ND packets.  ARP is easy to distinguish and
> keep mutually exclusive based on the ethernet type, but ND being an
> ICMPv6 protocol requires a bit more attention.
>
> Signed-off-by: Jarno Rajahalme <jarno@ovn.org>

Acked-by: Joe Stringer <joe@ovn.org>
