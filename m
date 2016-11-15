From: "Jason A. Donenfeld" <Jason@zx2c4.com>
Subject: Re: [PATCH v3] ip6_output: ensure flow saddr actually
	belongs to device
Date: Tue, 15 Nov 2016 01:45:14 +0100
Message-ID: <CAHmME9ppx01YR9Db1oPpm6FJ+BmpqSxvjQ2S+GT0DXO09_M4oQ@mail.gmail.com>
References: <27cccef1-06d9-74b3-5b8a-912850119a76@cumulusnetworks.com>
 <20161113232813.28926-1-Jason@zx2c4.com>
 <1479141867.3723362.787321689.4A3DCFD6@webmail.messagingengine.com>
 <fd1c804d-3e44-0321-8a3e-67d6ff7357fa@cumulusnetworks.com>
 <7d8c0210-9132-c755-9053-6ec19409e343@stressinduktion.org>
 <c75290bd-7ea2-0bf8-7ac0-fc5a3c81e312@cumulusnetworks.com>
 <7779da88-08dc-0adb-42dd-8e00502693df@stressinduktion.org>
 <0214eaf8-70c6-5a37-cddd-faa1c4268871@cumulusnetworks.com>
 <1479148385.3747043.787432273.5FCC2F4F@webmail.messagingengine.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: David Ahern <dsa@cumulusnetworks.com>,
 YOSHIFUJI Hideaki <hideaki.yoshifuji@miraclelinux.com>,
 LKML <linux-kernel@vger.kernel.org>,
 WireGuard mailing list <wireguard@lists.zx2c4.com>,
 Netdev <netdev@vger.kernel.org>
To: Hannes Frederic Sowa <hannes@stressinduktion.org>
Return-path: <wireguard-bounces@lists.zx2c4.com>
In-Reply-To: <1479148385.3747043.787432273.5FCC2F4F@webmail.messagingengine.com>
List-Unsubscribe: <http://lists.zx2c4.com/mailman/options/wireguard>,
 <mailto:wireguard-request@lists.zx2c4.com?subject=unsubscribe>
List-Archive: <http://lists.zx2c4.com/pipermail/wireguard/>
List-Post: <mailto:wireguard@lists.zx2c4.com>
List-Help: <mailto:wireguard-request@lists.zx2c4.com?subject=help>
List-Subscribe: <http://lists.zx2c4.com/mailman/listinfo/wireguard>,
 <mailto:wireguard-request@lists.zx2c4.com?subject=subscribe>
Errors-To: wireguard-bounces@lists.zx2c4.com
Sender: "WireGuard" <wireguard-bounces@lists.zx2c4.com>
List-Id: netdev.vger.kernel.org

Hey Hannes, David,

On Mon, Nov 14, 2016 at 7:33 PM, Hannes Frederic Sowa
<hannes@stressinduktion.org> wrote:
> I meant to say, we don't require the IPv6 "API" to behave in a similar
> way like the IPv4 one. We do this function pointer trick to allow
> _in-kernel_ tree modules to use the function dynamically, even the
> kernel ipv6 module would be available but is not loaded but don't
> guarante any "API like IPv4" to outside tree modules.

Ultimately I intend to submit my own use case for mainline inclusion.
I have no intention of maintaining my work as exclusively out of tree
and would be very pleased to see this well integrated. Hopefully I'll
meet some of you in person at upcoming conferences and events for
discussion about this.

Were I only concerned about out of tree status, I'd have no hesitation
about just including these particular checks in my own code and
leaving the current in tree code to rot. However, with my final
intentions in mind, it's certainly in my interest to "do things
right", hence this thread. When I noticed that the ipv6_stub routing
function was insufficient for my own project, I examined its usage in
a few other places. And indeed vxlan and geneve seem to also benefit
from this patch. I'd be happy to audit the small handful of other
cases in the kernel that use this API; I suspect they'll also be
improved in a positive way.

> I tried to make the point, that it is still something internal to the
> kernel if compared to out-of-tree function users. And that different
> behavior by itself doesn't count as a bug.

To the extent that other in-tree code uses this function and doesn't
get the saddr check, it seems like a bug. To the extent that this
function becomes more correct, it seems like an improvement. But
whether a bug or a mere improvement, it seems like a net positive.

> We could as well require the users of this function to check for the
> source address before or require to check the source address after the
> ipv6_dst_lookup call.

As said above, I have no qualms about doing this check in my own code.
I was thinking, though, that a handful of other places in the kernel
that use this function would benefit from adding that check too. In
this case, it's usually common practice to move the check into the
shared function, rather than require a flurry of copy-and-paste.

> vxlan currently seems wrong and would impacted by this patch in a better
> way, so I am all in for such a change, but I think we need to check if
> we are also correct scope-wise and not just match for the address on its
> own.

I'll have a better look at this. Perhaps this should be modeled on
what we currently do for userspace, which might amount to something
more or less like:


diff --git a/net/ipv6/ip6_output.c b/net/ipv6/ip6_output.c
index 6001e78..0721915 100644
--- a/net/ipv6/ip6_output.c
+++ b/net/ipv6/ip6_output.c
@@ -925,6 +925,7 @@ static int ip6_dst_lookup_tail(struct net *net,
const struct sock *sk,
 #endif
         int err;
         int flags = 0;
+        int addr_type, bind_to_dev;

         /* The correct way to handle this would be to do
          * ip6_route_get_saddr, and then ip6_route_output; however,
@@ -1012,6 +1013,16 @@ static int ip6_dst_lookup_tail(struct net *net,
const struct sock *sk,
         }
 #endif

+        addr_type = ipv6_addr_type(&fl6->saddr);
+        if (addr_type == IPv6_ADDR_ANY)
+                return 0;
+
+        err = -EINVAL;
+        bind_to_dev = __ipv6_addr_src_scope(addr_type) <=
IPV6_ADDR_SCOPE_LINKLOCAL;
+        if (!ipv6_chk_addr(net, &fl6->saddr, bind_to_dev ?
(*dst)->dev : NULL, 0) &&
+            !ipv6_chk_acast_addr_src(net, (*dst)->dev, &fl6->saddr))
+                goto out_err_release;
+
         return 0;

 out_err_release:
