From: Or Gerlitz <gerlitz.or@gmail.com>
Subject: Re: [PATCH net-next 0/7] nfp: flower vxlan tunnel offload
Date: Mon, 25 Sep 2017 18:25:03 +0300
Message-ID: <CAJ3xEMgfRuD2Y-P2eTKmXpciiopA8js4zbO_nNOA6J62sn--mw@mail.gmail.com>
References: <1506335021-32024-1-git-send-email-simon.horman@netronome.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Cc: David Miller <davem@davemloft.net>,
        Jakub Kicinski <jakub.kicinski@netronome.com>,
        Linux Netdev List <netdev@vger.kernel.org>,
        oss-drivers@netronome.com
To: Simon Horman <simon.horman@netronome.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-oi0-f67.google.com ([209.85.218.67]:38719 "EHLO
        mail-oi0-f67.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S964909AbdIYPZE (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 25 Sep 2017 11:25:04 -0400
Received: by mail-oi0-f67.google.com with SMTP id s145so4067653oie.5
        for <netdev@vger.kernel.org>; Mon, 25 Sep 2017 08:25:04 -0700 (PDT)
In-Reply-To: <1506335021-32024-1-git-send-email-simon.horman@netronome.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Sep 25, 2017 at 1:23 PM, Simon Horman
<simon.horman@netronome.com> wrote:
> From: Simon Horman <simon.horman@netronome.com>
>
> John says:
>
> This patch set allows offloading of TC flower match and set tunnel fields
> to the NFP. The initial focus is on VXLAN traffic. Due to the current
> state of the NFP firmware, only VXLAN traffic on well known port 4789 is
> handled. The match and action fields must explicity set this value to be
> supported. Tunnel end point information is also offloaded to the NFP for
> both encapsulation and decapsulation. The NFP expects 3 separate data sets
> to be supplied.

> For decapsulation, 2 separate lists exist; a list of MAC addresses
> referenced by an index comprised of the port number, and a list of IP
> addresses. These IP addresses are not connected to a MAC or port.

Do these IP addresses exist on the host kernel SW stack? can the same
set of TC rules be fully functional and generate the same traffic
pattern when set to run in SW (skip_hw)?


> The MAC
> addresses can be written as a block or one at a time (because they have an
> index, previous values can be overwritten) while the IP addresses are
> always written as a list of all the available IPs. Because the MAC address
> used as a tunnel end point may be associated with a physical port or may
> be a virtual netdev like an OVS bridge, we do not know which addresses
> should be offloaded. For this reason, all MAC addresses of active netdevs
> are offloaded to the NFP. A notifier checks for changes to any currently
> offloaded MACs or any new netdevs that may occur. For IP addresses, the
> tunnel end point used in the rules is known as the destination IP address
> must be specified in the flower classifier rule. When a new IP address
> appears in a rule, the IP address is offloaded. The IP is removed from the
> offloaded list when all rules matching on that IP are deleted.
>
> For encapsulation, a next hop table is updated on the NFP that contains
> the source/dest IPs, MACs and egress port. These are written individually
> when requested. If the NFP tries to encapsulate a packet but does not know
> the next hop, then is sends a request to the host. The host carries out a
> route lookup and populates the given entry on the NFP table. A notifier
> also exists to check for any links changing or going down in the kernel
> next hop table. If an offloaded next hop entry is removed from the kernel
> then it is also removed on the NFP.
>
> The NFP periodically sends a message to the host telling it which tunnel
> ports have packets egressing the system. The host uses this information to
> update the used value in the neighbour entry. This means that, rather than
> expire when it times out, the kernel will send an ARP to check if the link
> is still live. From an NFP perspective, this means that valid entries will
> not be removed from its next hop table.
>
> John Hurley (7):
>   nfp: add helper to get flower cmsg length
>   nfp: compile flower vxlan tunnel metadata match fields
>   nfp: compile flower vxlan tunnel set actions
>   nfp: offload flower vxlan endpoint MAC addresses
>   nfp: offload vxlan IPv4 endpoints of flower rules
>   nfp: flower vxlan neighbour offload
>   nfp: flower vxlan neighbour keep-alive
>
>  drivers/net/ethernet/netronome/nfp/Makefile        |   3 +-
>  drivers/net/ethernet/netronome/nfp/flower/action.c | 169 ++++-
>  drivers/net/ethernet/netronome/nfp/flower/cmsg.c   |  16 +-
>  drivers/net/ethernet/netronome/nfp/flower/cmsg.h   |  87 ++-
>  drivers/net/ethernet/netronome/nfp/flower/main.c   |  13 +
>  drivers/net/ethernet/netronome/nfp/flower/main.h   |  35 +
>  drivers/net/ethernet/netronome/nfp/flower/match.c  |  75 +-
>  .../net/ethernet/netronome/nfp/flower/metadata.c   |   2 +-
>  .../net/ethernet/netronome/nfp/flower/offload.c    |  74 +-
>  .../ethernet/netronome/nfp/flower/tunnel_conf.c    | 811 +++++++++++++++++++++
>  10 files changed, 1243 insertions(+), 42 deletions(-)
>  create mode 100644 drivers/net/ethernet/netronome/nfp/flower/tunnel_conf.c
>
> --
> 2.1.4
>
