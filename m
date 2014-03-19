From: Mike Rapoport <mike.rapoport@ravellosystems.com>
Subject: Re: [PATCH net] net: vxlan: fix crash when interface is created with
 no group
Date: Wed, 19 Mar 2014 16:32:17 +0200
Message-ID: <CAF1J0HPtQqpaqZ82yPoKFSYpP42HfOGu_X7uz3_61X2b+bYAjQ@mail.gmail.com>
References: <1395055050-20874-1-git-send-email-mike.rapoport@ravellosystems.com>
	<OFEB1030F8.C147FA77-ON87257C9F.005CF370-87257C9F.005CF375@us.ibm.com>
	<CAF1J0HOTLvyaWdmYLGLPn9AJLR6rQr4fk8EVFSzv5sckLuBwvw@mail.gmail.com>
	<OF55200AFE.3F917127-ON87257CA0.004DA877-87257CA0.004DA87C@us.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: netdev <netdev@vger.kernel.org>
To: David Stevens <dlstevens@us.ibm.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ob0-f171.google.com ([209.85.214.171]:37988 "EHLO
	mail-ob0-f171.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S933739AbaCSOcS (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 19 Mar 2014 10:32:18 -0400
Received: by mail-ob0-f171.google.com with SMTP id wn1so8241715obc.30
        for <netdev@vger.kernel.org>; Wed, 19 Mar 2014 07:32:17 -0700 (PDT)
In-Reply-To: <OF55200AFE.3F917127-ON87257CA0.004DA877-87257CA0.004DA87C@us.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Mar 19, 2014 at 4:08 PM, David Stevens <dlstevens@us.ibm.com> wrote:
>
>
> -----Mike Rapoport <mike.rapoport@ravellosystems.com> wrote: -----
>
>>To: David Stevens/Beaverton/IBM@IBMUS
>>From: Mike Rapoport <mike.rapoport@ravellosystems.com>
> ,,,
>>However, for the particular case in vxlan_rcv, checking the packet
>>version seems to me semantically more correct than comparing
>>default_dst
>>protocol family with AF_INET or AF_INET6.
>
> No, that's saying that the sender should determine whether
> you are using IPv4 or IPv6, but when the localhost is the
> sender, it'll only be using one of those.
>
> If the default_dst is an IPv4 group address, ordinary VXLAN
> wouldn't interoperate with IPv6 because the group is not an IPv6
> group, but with your patch, it'll still receive and accept IPv6-encapsulated
> packets. It just wouldn't send any, if all the fdb entries are also v4.

I'm not really familiar with v4 and v6 interoperability, but the
vxlan_socket_create will create v6 socket only if IPv6 is explicitly
requested.
Would it be possible to receive IPv6-encapsulated packets from IPv4 socket?

> I think neither the receive packets nor the default_dst, which may
> not be set, is the right way to determine this. vxlan_dev->saddr
> makes more sense, but it, too, doesn't have to be set.
>
> I'd suggest:
> 1) if vxlan_dev->saddr is set, use that. Any packets sent should use
>           this saddr, if set, so that determines the underlay address family
>           and so also what IP version you'll receive.
> 2) if vxlan_dev->saddr is not set, and default_dst is a multicast group,
>           use that address family. For ordinary VXLAN, the group is used
>           by all participants so it can't mix v4 and v6. Also, if saddr is set
>           and default_dst is a multicast group, the address family should
>           match.
> 3) if neither of those is set, then it isn't ordinary VXLAN, but rather a
>          custom configuration. In that case, we should allow both, by
>          default, at least. fdb entries can use both v4 and v6, so we
>          should receive both.
>
> We could also (or instead) add flags to explicitly allow or disallow v4 and/or v6,
> and then, of course, enforce those flag settings for saddr, default_dst
> and fdb entries, too.
>
>                                                                   +-DLS
>



-- 
Sincerely yours,
Mike.
