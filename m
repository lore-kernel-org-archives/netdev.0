From: "David S. Miller" <davem@redhat.com>
Subject: Re: [PATCH][IPV6] fixed authentication error with TCP
Date: Mon, 18 Aug 2003 02:48:37 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20030818024837.6815f0c2.davem@redhat.com>
References: <200308172329.DAA14889@dub.inr.ac.ru>
	<Pine.LNX.4.44.0308181029560.18400-200000@rhea.tcs.hut.fi>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: kuznet@ms2.inr.ac.ru, kazunori@miyazawa.org, netdev@oss.sgi.com,
   usagi@linux-ipv6.org, latten@austin.ibm.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Ville Nuorvala <vnuorval@tcs.hut.fi>
In-Reply-To: <Pine.LNX.4.44.0308181029560.18400-200000@rhea.tcs.hut.fi>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Mon, 18 Aug 2003 10:45:41 +0300 (EEST)
Ville Nuorvala <vnuorval@tcs.hut.fi> wrote:

> The attached patch reverts to the old ip6_dst_lookup() interface and and
> makes tcp_ipv6.c use that instead.
> 
> As an added bonus neither tcp_v6_connect() nor udpv6_connect() needs to do
> source address selection anymore, since ip6_dst_lookup() already does this
> for them.

While verifying this patch, I discovered some new dst leaks.

For example:

1) In icmpv6_send(), who releases the DST?
2) Similarly, for icmpv6_echo_reply()?

In these two cases, ip6_append_data() grabs one reference
each time it attaches 'rt' to the np->cort.rt, but we still
have the singular reference in those two icmpv6_*() routines
referenced above and they leak.

3) ip6_push_pending_frames(), it gets a new reference to
   np->cork.rt to attach the 'dst' to skb->dst on output.
   Then it sets np->cork.rt to NULL, 1 reference is lost
   as a result.
4) Similarly in ip6_flush_pending_frames().

I don't want to check any more places, because every place where I
look in ipv6 I find a new DST leak :(
