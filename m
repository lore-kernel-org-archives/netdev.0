From: Arnaldo Carvalho de Melo <acme@conectiva.com.br>
Subject: Re: [PATCH 6/9] irda: use sock slab cache
Date: Thu, 20 Jan 2005 01:47:10 -0200
Message-ID: <41EF29BE.2020807@conectiva.com.br>
References: <41EF11AF.70203@conectiva.com.br> <20050120021607.GA11216@bougret.hpl.hp.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@davemloft.net>, irda-users@lists.sourceforge.net,
        netdev@oss.sgi.com, Stephen Hemminger <shemminger@osdl.org>
Return-path: <netdev-bounce@oss.sgi.com>
To: jt@hpl.hp.com
In-Reply-To: <20050120021607.GA11216@bougret.hpl.hp.com>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Jean Tourrilhes escreveu:
> 	I'm just curious about the overhead of adding a specific slab
> for IrDA sockets. Most users never create any (using IrCOMM), or
> maximum one (using Obex), so it's not like it will get a lot of use
> (except here, of course).

Well, lets start with something that may sound funny: when this series
of patches is finished the overhead will _decrease_ for most people.

Why? Today we have in most machines five slab caches of this nature:
udp_sock, raw_sock, tcp_sock, unix_sock (PF_LOCAL) and the generic,
sock, that only is used by the protocols that are using kmalloc(pritave_sock) +
sk_protinfo.

When all protos use private slab caches, the generic slab "sock" is no longer
needed.

So most users will have only the udp, raw, tcp and unix slabs, if they require
another family, say AF_IRDA, they are back to the previous situation, with
5 sock slabs, only when users need two or more extra slabs we get some
overhead wrt the previous situation, but this is compensated by likely
performance gains associated with less cacheline trashing, as noticed when
I first introduced sock slabs, with all the protos converted at that time, i.e.
the 4 most common mentioned above.

And not having two ways to allocate the private area for protos reduces
the networking infrastructure complexity and makes all the networking families
look more similar in its implementation, which facilitates indentifying common
code patterns that can be made generic.

All of this is part of an effort I've been working on for a long time, with the
ultimate goals of reducing the costs associated with maintaining the support
for legacy protocols, taking advantage of the work done on the mainstream
protocols and easing the implementation of new network protocols, such as
DCCP, which I'm working on.

Regards,

- Arnaldo
