From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Subject: Re: [PATCH] ipv6: udp packets following an UFO enqueued packet need also be handled by UFO
Date: Wed, 2 Oct 2013 14:01:22 +0200
Message-ID: <20131002120122.GN10771@order.stressinduktion.org>
References: <20130921042700.GB8070@order.stressinduktion.org> <20130930114343.GA6356@minipsycho.brq.redhat.com> <20130930172312.GE10771@order.stressinduktion.org> <20131001105837.GA1424@minipsycho.brq.redhat.com> <20131001120907.GH10771@order.stressinduktion.org> <20131001123214.GI10771@order.stressinduktion.org> <20131001214721.GJ10771@order.stressinduktion.org> <20131001232534.GM10771@order.stressinduktion.org> <20131002103333.GB1528@minipsycho.brq.redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Cc: netdev@vger.kernel.org, yoshfuji@linux-ipv6.org,
	davem@davemloft.net, kuznet@ms2.inr.ac.ru, jmorris@namei.org,
	kaber@trash.net, herbert@gondor.apana.org.au,
	eric.dumazet@gmail.com
To: Jiri Pirko <jiri@resnulli.us>
Return-path: <netdev-owner@vger.kernel.org>
Received: from order.stressinduktion.org ([87.106.68.36]:35900 "EHLO
	order.stressinduktion.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753684Ab3JBMBY (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 2 Oct 2013 08:01:24 -0400
Content-Disposition: inline
In-Reply-To: <20131002103333.GB1528@minipsycho.brq.redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Oct 02, 2013 at 12:33:33PM +0200, Jiri Pirko wrote:
> Wed, Oct 02, 2013 at 01:25:34AM CEST, hannes@stressinduktion.org wrote:
> >On Tue, Oct 01, 2013 at 11:47:21PM +0200, Hannes Frederic Sowa wrote:
> >> The strange thing is that if I don't do the IPV6_MTU setsockopt I don't
> >> get an oops.
> >
> >This is incorrect, it just depends on the size of the writes and on the
> >interface mtu.
> >
> >> IPv4 seems to work without problems, too.
> >
> >I also get kernel oopses from IPv4 now, too.
> 
> I'm not able to trigger this with ipv4. Can you please send strace
> output for this as well?

I used this snippet on loopback with UFO enabled and lo mtu 1280.

#include <sys/types.h>
#include <sys/socket.h>
#include <netinet/in.h>
#include <arpa/inet.h>
#include <linux/udp.h>
#include <stdio.h>

int test(int mtu)
{
        int fd;
        const int one = 1;
        const int off = 0;
        struct sockaddr_in addr = {.sin_family = AF_INET, .sin_port = htons(53) };
        unsigned char buffer[3701];

        inet_pton(AF_INET, "127.0.0.1", &addr.sin_addr);

        fd = socket(AF_INET, SOCK_DGRAM, 0);
        connect(fd, (struct sockaddr *) &addr, sizeof(addr));

        setsockopt(fd, IPPROTO_UDP, UDP_CORK, &one, sizeof(one));

        write(fd, " ", 1);
        write(fd, buffer, sizeof(buffer));
        write(fd, " ", 1);

        setsockopt(fd, IPPROTO_UDP, UDP_CORK, &off, sizeof(off));

        close(fd);
}

int main() {
        test(1280);
}

Greetings,

  Hannes
