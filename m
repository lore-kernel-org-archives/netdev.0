From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: Re: [PATCH net-next 2/4] gtp: add genl cmd to enable GTP
 encapsulation on UDP socket
Date: Tue, 14 Mar 2017 14:39:57 +0100
Message-ID: <20170314133957.GA3838@salvia>
References: <20170314112548.24027-1-aschultz@tpip.net>
 <20170314112548.24027-3-aschultz@tpip.net>
 <20170314114330.GB2992@salvia>
 <1491326012.385002.1489494505868.JavaMail.zimbra@tpip.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: laforge <laforge@gnumonks.org>,
        osmocom-net-gprs <osmocom-net-gprs@lists.osmocom.org>,
        netdev <netdev@vger.kernel.org>,
        Lionel Gauthier <Lionel.Gauthier@eurecom.fr>
To: Andreas Schultz <aschultz@tpip.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.us.es ([193.147.175.20]:38992 "EHLO mail.us.es"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751143AbdCNNkI (ORCPT <rfc822;netdev@vger.kernel.org>);
        Tue, 14 Mar 2017 09:40:08 -0400
Received: from antivirus1-rhel7.int (unknown [192.168.2.11])
        by mail.us.es (Postfix) with ESMTP id 36A14E5A51
        for <netdev@vger.kernel.org>; Tue, 14 Mar 2017 14:40:05 +0100 (CET)
Received: from antivirus1-rhel7.int (localhost [127.0.0.1])
        by antivirus1-rhel7.int (Postfix) with ESMTP id 25417DA874
        for <netdev@vger.kernel.org>; Tue, 14 Mar 2017 14:40:05 +0100 (CET)
Received: from antivirus1-rhel7.int (localhost [127.0.0.1])
        by antivirus1-rhel7.int (Postfix) with ESMTP id DFC6ADA80B
        for <netdev@vger.kernel.org>; Tue, 14 Mar 2017 14:40:01 +0100 (CET)
Content-Disposition: inline
In-Reply-To: <1491326012.385002.1489494505868.JavaMail.zimbra@tpip.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Mar 14, 2017 at 01:28:25PM +0100, Andreas Schultz wrote:
> ----- On Mar 14, 2017, at 12:43 PM, pablo pablo@netfilter.org wrote:
[...]
> A GTP entity serves multiple local IP endpoints, It manages outgoing tunnels
> by the local APN/VRF, source IP, destination IP and remote tunnel id, incoming
> tunnels are managed by the local destination IP, local tunnel id and VRF/APN.
> 
> Therefor a PDP context needs the following attributes:
> 
>  * local source/destination IP (and port - but that's for different series)
>  * remote destination IP
>  * local and remote TEID
>  * VRF/APN
[...]
> I'm not sure if this pseudo GTP entity root device fits well with
> other networking concepts. And more over, I can't really see the need
> for such an construct.

Some sort of top-level structure that wraps all these objects is
needed, and that can be a new VRF object itself.

You can add a netlink interface to add/dump/delete VRFs, this VRF
database would be *global* to the GSN. At VRF creation, you attach the
socket and the GTP device. You can share sockets between VRFs. PDP
context objects would be added to the corresponding VRF *not to the
socket*, but actually this will result in inserting this PDP context
into the socket hashtable and the GTP device hashtable.

We need to introduce a default VRF that is assumed to always exist,
and that userspace cannot remove, so things don't break backward. If
no VRF is specified, then we attach things to this default VRF.
Actually, look at this from a different angle: the existing driver is
just supporting *one single VRF* at this moment so we just have to
represent this explicitly. Breaking existing API is a no-go.

This explicit VRF concept would also allow us to dump PDP contexts
that belong to a given VRF, by simply indicating the VRF unique id.
Jamal already requested that we extend iproute2 to have command to
inspect the gtp driver we cannot escape this, we should allow
standalone tools to inspect the gtp datapath as we do with other
existing tunnel drivers, no matter what daemon in userspace implements
the control plane.

[...]
> I think that the user space control instance should own the tunnels and
> only use the kernel facility to manage them. When the user space instance
> goes away, so should the tunnels.

This doesn't allow daemon hot restart for whatever administrative
reason without affecting existing traffic. The kernel owns the
datapath indeed, that include tunnels.

> From that perspective, I want to keep the kernel facilities to the
> absolute needed minimum.

If some simple abstraction that we can insert makes this whole thing
more maintainable, then it makes sense to consider it.

This is all about not exposing the internal layout of the
representation you use for a very specific reason: The more you expose
internal details to userspace, the more problems we'll have to extend
things later on in the future. And don't try to be smart and say:
"Hey, I already know every usecase we will have in the future" because
that is not true.
