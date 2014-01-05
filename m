From: Or Gerlitz <or.gerlitz@gmail.com>
Subject: Re: [PATCH V1 net-next 2/2] net: Add UDP GRO support for vxlan traffic
Date: Sun, 5 Jan 2014 21:39:38 +0200
Message-ID: <CAJZOPZKJvpk9ZW6iRnXzm9OHppStAF+2=COw3zWNy5rMy3r0qg@mail.gmail.com>
References: <1388935422-7331-1-git-send-email-ogerlitz@mellanox.com>
	<1388935422-7331-3-git-send-email-ogerlitz@mellanox.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: Jerry Chu <hkchu@google.com>, Eric Dumazet <edumazet@google.com>,
	Herbert Xu <herbert@gondor.apana.org.au>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	David Miller <davem@davemloft.net>,
	Yan Burman <yanb@mellanox.com>,
	Shlomo Pongratz <shlomop@mellanox.com>
To: Or Gerlitz <ogerlitz@mellanox.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f169.google.com ([209.85.192.169]:45102 "EHLO
	mail-pd0-f169.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751119AbaAETji (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 5 Jan 2014 14:39:38 -0500
Received: by mail-pd0-f169.google.com with SMTP id v10so17353544pde.0
        for <netdev@vger.kernel.org>; Sun, 05 Jan 2014 11:39:38 -0800 (PST)
In-Reply-To: <1388935422-7331-3-git-send-email-ogerlitz@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, Jan 5, 2014 at 5:23 PM, Or Gerlitz <ogerlitz@mellanox.com> wrote:
> Add GRO handlers for UDP, with the intent of being able to coalesce vxlan
> packets which encapsulate packets belonging to the same TCP session.
>
> The UDP GRO handler will only attempt to coalesce packets whose
> destination port is used as vxlan listening port. There are two
> issues here for which I will be happy to get feedback
>
> 1. what is the most efficient way to determine if a udp port is
> owned by the vxlan driver, e.g maybe through a bit map exported by
> the vxlan driver?

To be accurate here, V1 (this patch) still has RFC aspects -- it
suggests a solution to the above matter -- the gro udp code exports
two callbacks which are invoked by the vxlan driver to add/delete udp
listening port. The callbacks maintain an O(1) accessed array which is
beeing looked from the fast path to determine if the destination udp
port of the packet under inspection is a vxlan listening port.

> 2. how to prevent the host GRO stack from coalescing guest UDP
> packets which went through vxlan encapsulation and happen to carry
> the same udp destination port as used by the host vxlan driver..

For this one, I was thinking to add some field to struct napi_gro_cb
which will be zeroed when the gro stacks starts to work on the skb and
set once we pass udp_gro_receive, such that if we arrive again to
udp_gro_recieve and this field is set, which means the encapsulated
packet is udp one, we flush.
