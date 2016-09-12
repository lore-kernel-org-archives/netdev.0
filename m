From: David Ahern <dsa@cumulusnetworks.com>
Subject: Re: [PATCH] net: VRF: Pass original iif to ip_route_input()
Date: Mon, 12 Sep 2016 08:48:09 -0600
Message-ID: <17a91dbc-e2d6-bb04-7f56-c95962748100@cumulusnetworks.com>
References: <20160912014553.20927-1-mark.tomlinson@alliedtelesis.co.nz>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
To: Mark Tomlinson <mark.tomlinson@alliedtelesis.co.nz>,
        netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f46.google.com ([209.85.220.46]:33368 "EHLO
        mail-pa0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1756086AbcILOsM (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 12 Sep 2016 10:48:12 -0400
Received: by mail-pa0-f46.google.com with SMTP id cm16so51571238pac.0
        for <netdev@vger.kernel.org>; Mon, 12 Sep 2016 07:48:12 -0700 (PDT)
In-Reply-To: <20160912014553.20927-1-mark.tomlinson@alliedtelesis.co.nz>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 9/11/16 7:45 PM, Mark Tomlinson wrote:
> The function ip_rcv_finish() calls l3mdev_ip_rcv(). On any VRF except
> the global VRF, this replaces skb->dev with the VRF master interface.
> When calling ip_route_input_noref() from here, the checks for forwarding
> look at this master device instead of the initial ingress interface.
> This will allow packets to be routed which normally would be dropped.
> For example, an interface that is not assigned an IP address should
> drop packets, but because the checking is against the master device, the
> packet will be forwarded.
> 
> The fix here is to still call l3mdev_ip_rcv(), but remember the initial
> net_device. This is passed to the other functions within ip_rcv_finish,
> so they still see the original interface.
> 
> Please note that while this patch fixes my issue, I am not entirely sure
> why the skb->dev is changed to the master device, so I am not sure this
> is the right fix.

It is done for socket lookups. VRF can handle global sockets with connected sockets bound to the VRF domain (VRF device index) or sockets bound to the VRF device which requires inet_iif / skb_iif to be the VRF device.

With the changes to l3mdev to look at enslaved devices as well as master devices this change might be fine, but need to confirm.

Please cc me on VRF related patches or questions. I only scan netdev as time allows.
