From: "David S. Miller" <davem@redhat.com>
Subject: Re: 6to4/SIT and IP DF
Date: Wed, 15 Oct 2003 21:38:40 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20031015213840.4f1f809e.davem@redhat.com>
References: <OFBD470C6E.206063CD-ON88256DC0.0025444B@us.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: pekkas@netcore.fi, r.venning@telstra.com, nate@thebog.net,
        netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: David Stevens <dlstevens@us.ibm.com>
In-Reply-To: <OFBD470C6E.206063CD-ON88256DC0.0025444B@us.ibm.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Wed, 15 Oct 2003 00:15:21 -0700
David Stevens <dlstevens@us.ibm.com> wrote:

> I'm concerned that with DF set, as it is now, every packet in that
> range would be dropped, if the IPv4 Frag-Needed-But-DF-Set (FNBDFS :-))
> does not include enough v6 header & payload  to identify the v6 sender.

Who cares?  The PMTU as seen by the SIT tunnel is apsect of the IPV4
path not the IPV6 one.  IPV6 is merely communicating over a device
having a particular MTU.

When the ipv4 ICMP arrives, the IPV4 route to the other end of the SIT
tunnel is updated as appropriate.  (this is what the comment in sit.c
saying "Soft state for pmtu is maintained by IP core."  is talking
about)

After this, the next time something is attempted to be sent over the
SIT tunnel, we'll see the updated PMTU for the ipv4 route to the
SIT tunnel destination and act accordingly.

If the IPV6 packet is too big for this new IPV4 PMTU, the SIT driver
will emit an ICMPV6_PKT_TOOBIG icmp6 message back to the ipv6 packet's
origin.  It's this piece of code in sit.c:ipip6_tunnel_xmit():

        if (skb->len > mtu) {
                icmpv6_send(skb, ICMPV6_PKT_TOOBIG, 0, mtu, dev);
                ip_rt_put(rt);
                goto tx_error;
        }

In short I think all of the cases you're mentioning are taken care
of just fine.
