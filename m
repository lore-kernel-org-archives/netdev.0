From: Stephan von Krawczynski <skraw@ithnet.com>
Subject: Re: 2.4 and ip fragmentation question (background info)
Date: Fri, 2 Jan 2004 13:39:13 +0100
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040102133913.488cd537.skraw@ithnet.com>
References: <20031231122325.77f19143.skraw@ithnet.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Return-path: <netdev-bounce@oss.sgi.com>
To: netdev@oss.sgi.com
In-Reply-To: <20031231122325.77f19143.skraw@ithnet.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Wed, 31 Dec 2003 12:23:25 +0100
Stephan von Krawczynski <skraw@ithnet.com> wrote:

> Hello,
> 
> is ip fragmentation thought to work with multiple fragmented packets all with
> same ID field, same source and destination address? Or can one consider this
> situation as generally unsolvable and broken by application?
> 
> Regards,
> Stephan

As this question obviously sounded significantly stupid enough not to be
answered I may point you to this code in 2.4 include/net/ip.h:

static inline void ip_select_ident(struct iphdr *iph, struct dst_entry *dst,
struct sock *sk)
{
        if (iph->frag_off&__constant_htons(IP_DF)) {
                /* This is only to work around buggy Windows95/2000
                 * VJ compression implementations.  If the ID field
                 * does not change, they drop every other packet in
                 * a TCP stream using header compression.
                 */
                iph->id = ((sk && sk->daddr) ? htons(sk->protinfo.af_inet.id++)
: 0);
        } else
                __ip_select_ident(iph, dst);
}


As you all know this sets the ID field inside the ip-header. Interestingly it
depends on frag_off and sk->daddr field.
I ran into an application (formerly for 2.2 kernel) where the author (!=me)
obviously was unaware of this dependency and initialised these fields after
calling ip_select_ident. The outcome was that everything runs normal during low
traffic, but when more packets were transferred it looked like a increasing
amount of packets got "0" as ID, because iph->frag_off was not initialised
correctly and the skbs were of course not zeroed. Still this would have been no
problem if these packets weren't fragmented.
What I saw was that packets got corrupted during high load (because
fragmentation obviously vomitted on the high rate of "ID=0" packets), but all
was perfectly well during low load.

Should the author have read some doc where it is clearly stated that
ip_select_ident needs a more or less completely initialised ip header to work
as expected? (other way round see my original question...)

Regards,
Stephan
