From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [RFC] Support for UNARP (RFC 1868)
Date: Thu, 12 Oct 2017 07:57:16 -0700
Message-ID: <1507820236.31614.50.camel@edumazet-glaptop3.roam.corp.google.com>
References: <1507782977-2443-1-git-send-email-girish.moodalbail@oracle.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, davem@davemloft.net, kuznet@ms2.inr.ac.ru
To: Girish Moodalbail <girish.moodalbail@oracle.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f181.google.com ([209.85.192.181]:48186 "EHLO
        mail-pf0-f181.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751348AbdJLO5U (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 12 Oct 2017 10:57:20 -0400
Received: by mail-pf0-f181.google.com with SMTP id b79so5184616pfk.5
        for <netdev@vger.kernel.org>; Thu, 12 Oct 2017 07:57:20 -0700 (PDT)
In-Reply-To: <1507782977-2443-1-git-send-email-girish.moodalbail@oracle.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2017-10-11 at 21:36 -0700, Girish Moodalbail wrote:
> Add support for UNARP, as detailed in the IETF RFC 1868 (ARP Extension -
> UNARP). The central idea here is for a node to announce that it is
> leaving the network and that all the nodes on the L2 broadcast domain to
> update their ARP tables accordingly (i.e., mark the neighbor entry state
> to FAILED). Even though the ARP timers on nodes would eventually  mark
> such entries as FAILED it will be more robust if those entries gets
> marked FAILED sooner with the help from the host that is going away.
> 
> Besides providing a solution for an usecase, as captured in RFC, of an
> IP address moving across a proxy server, this feature is even more
> important for certain use cases in the Cloud. Imagine a tenant who is
> bringing up and down VM instances for some workload of theirs. If these
> instances are part of a small subnet, then the new VM instances may be
> assigned the same IP address (since the subnet pool is small) but with a
> different MAC address. So, if there is a client which has a stale
> mapping of the IP address to the old MAC address, then that client will
> fail to communicate with the new VM instance for some time.
> 
> Another usecase that comes to mind is that of the Live VM
> Migration. Imagine a client that is communicating with a VM. Now, let us
> migrate this VM to a destination machine. The IP address to MAC address
> mapping for a VM doesn't change after the Live Migration. However, there
> will be a small amount of time (till the VM sends gratuitous ARP from
> the destination machine) during which packets from a client will be
> forwarded to the source machine. This occurs because:
> 
>  - the ARP entry in the client is not invalidated yet and it continues
>    to use the same MAC address and
> 
>  - the MAC address table of all of the intermediate switches between the
>    client and the source machine are not updated yet for the MAC address
>    move.
> 
> This issue of forwarding the packets to wrong target could be avoided by
> sending UNARP packets from the source machine. This would invalidate the
> ARP entry on the client and forces it to resolve the IP address again by
> broadcasting an ARP request to the network. The VM on the destination
> machine would then respond back with an ARP response. The ARP response
> back from the VM should also clean up the MAC address table of the
> intermediate switches.
> 
> The following changes implements the UNARP receive processing in the
> kernel. Once the changes are in the kernel, arping(8) program can be
> updated to send UNARP packets.
> 
> Any Thoughts/Comments?
> 
> Signed-off-by: Girish Moodalbail <girish.moodalbail@oracle.com>
> ---

Hi Girish

Your description (or patch title) is misleading. You apparently
implement the receive side of the RFC.

And the RFC had Proxy ARP in mind.

What about security implications ? Will TCP flows be terminated, instead
of being smoothly migrated (TCP_REPAIR)

What about IPv6 ? Or maybe more abruptly, do we still need to add
features to IPv4 in 2017,  22 years after this RFC came ? ;)

Thanks.
