From: Willem de Bruijn <willemb@google.com>
Subject: Re: [PATCH net-next RFC 00/10] socket sendmsg MSG_ZEROCOPY
Date: Thu, 20 Aug 2015 22:49:25 -0400
Message-ID: <CA+FuTSfA=_1VPFbUAh+5_+Xa_UxuTiFgGPGVRzfEtZLkvW6a9g@mail.gmail.com>
References: <1440081408-12302-1-git-send-email-willemb@google.com> <20150820.155647.106500427975157613.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Network Development <netdev@vger.kernel.org>,
	"Michael S. Tsirkin" <mst@redhat.com>,
	Jason Wang <jasowang@redhat.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-yk0-f180.google.com ([209.85.160.180]:34179 "EHLO
	mail-yk0-f180.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752416AbbHUCt4 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 20 Aug 2015 22:49:56 -0400
Received: by ykdt205 with SMTP id t205so58370780ykd.1
        for <netdev@vger.kernel.org>; Thu, 20 Aug 2015 19:49:55 -0700 (PDT)
In-Reply-To: <20150820.155647.106500427975157613.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Aug 20, 2015 at 6:56 PM, David Miller <davem@davemloft.net> wrote:
> From: Willem de Bruijn <willemb@google.com>
> Date: Thu, 20 Aug 2015 10:36:39 -0400
>
>> Datapath integrity does not otherwise depend on payload, with three
>> exceptions: checksums, optional sk_filter/tc u32/.. and device +
>> driver logic. The effect of wrong checksums is limited to the
>> misbehaving process. Filters may have to be addressed by inserting a
>> preventative skb_copy_ubufs(). Device drivers can be whitelisted,
>> similar to scatter-gather support (NETIF_F_SG).
>
> Consider a userland NFS implementation sending over loopback while
> constantly modifying the page.  The sunrpc code could be tricked into
> seeing one thing during validation of the RPC headers then doing
> another after the user makes changes.
>
> I really don't think this is completely safe as-is.

Sunrpc is a great counter example. Anything that calls
kernel_recvmsg may be problematic, I guess. Copying when
passing to kernel sockets would plug that class of issues.

But there may still be others. Most obvious use case for copy
avoidance is pure device transmit. Excluding loopback may be
a reasonable way to initially limit the attack surface. With a flag
NETIF_F_ZC not supported on lo.
