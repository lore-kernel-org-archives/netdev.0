From: Vlad Yasevich <vyasevic-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
Subject: Re: [PATCH] openvswitch: Make IPv6 packet parsing
	dependent on IPv6 config
Date: Fri, 16 Nov 2012 14:41:21 -0500
Message-ID: <1353094881-28867-1-git-send-email-vyasevic@redhat.com>
References: <20121116.135341.453792886356015492.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: dev-yBygre7rU0TnMu66kgdUjQ@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, fengguang.wu-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org
To: davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org
Return-path: <dev-bounces-yBygre7rU0TnMu66kgdUjQ@public.gmane.org>
In-Reply-To: <20121116.135341.453792886356015492.davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
List-Unsubscribe: <http://openvswitch.org/mailman/options/dev>,
	<mailto:dev-request-yBygre7rU0TnMu66kgdUjQ@public.gmane.org?subject=unsubscribe>
List-Archive: <http://openvswitch.org/pipermail/dev>
List-Post: <mailto:dev-yBygre7rU0TnMu66kgdUjQ@public.gmane.org>
List-Help: <mailto:dev-request-yBygre7rU0TnMu66kgdUjQ@public.gmane.org?subject=help>
List-Subscribe: <http://openvswitch.org/mailman/listinfo/dev>,
	<mailto:dev-request-yBygre7rU0TnMu66kgdUjQ@public.gmane.org?subject=subscribe>
Sender: dev-bounces-yBygre7rU0TnMu66kgdUjQ@public.gmane.org
Errors-To: dev-bounces-yBygre7rU0TnMu66kgdUjQ@public.gmane.org
List-Id: netdev.vger.kernel.org

On 11/16/2012 01:53 PM, David Miller wrote:> From: Jesse Gross <jesse-l0M0P4e3n4LQT0dZR+AlfA@public.gmane.org>
> Date: Fri, 16 Nov 2012 10:46:17 -0800
> 
>> I guess the simplest thing to do seems to just make Open vSwitch
>> depend on CONFIG_INET seeing as it is practically useless without
>> upper layer protocol support anyways.
> 
> The reason we have the ipv6 extension header parsing in a seperate,
> always compiled statically into the kernel, module is exactly for
> situations like this.
> 
> We need to think seriously if we want to go down this road of only
> using INET as protection for every module that has some kind of ipv6
> component to it.

Ok.  How about this approach instead.  This keeps core functions we need
still dependent on CONFIG_NET and makes new GSO stuff depend on CONFIG_INET
since its quite useless without CONFIG_INET anyway...

-vlad

-- >8 --

Subject: [PATCH] ipv6: Preserve ipv6 functionality needed by NET

Some pieces of network use core pieces of IPv6 stack.  Keep
them available while letting new GSO offload pieces depend
on CONFIG_INET.

Signed-off-by: Vlad Yasevich <vyasevic-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
---
 net/Makefile      |    2 +-
 net/ipv6/Makefile |    4 ++--
 2 files changed, 3 insertions(+), 3 deletions(-)

diff --git a/net/Makefile b/net/Makefile
index e050d9d..4f4ee08 100644
--- a/net/Makefile
+++ b/net/Makefile
@@ -19,7 +19,7 @@ obj-$(CONFIG_NETFILTER)		+= netfilter/
 obj-$(CONFIG_INET)		+= ipv4/
 obj-$(CONFIG_XFRM)		+= xfrm/
 obj-$(CONFIG_UNIX)		+= unix/
-obj-$(CONFIG_INET)		+= ipv6/
+obj-$(CONFIG_NET)		+= ipv6/
 obj-$(CONFIG_PACKET)		+= packet/
 obj-$(CONFIG_NET_KEY)		+= key/
 obj-$(CONFIG_BRIDGE)		+= bridge/
diff --git a/net/ipv6/Makefile b/net/ipv6/Makefile
index 04a475d..2068ac4 100644
--- a/net/ipv6/Makefile
+++ b/net/ipv6/Makefile
@@ -40,7 +40,7 @@ obj-$(CONFIG_IPV6_SIT) += sit.o
 obj-$(CONFIG_IPV6_TUNNEL) += ip6_tunnel.o
 obj-$(CONFIG_IPV6_GRE) += ip6_gre.o
 
-obj-y += addrconf_core.o exthdrs_core.o output_core.o protocol.o
-obj-y += $(ipv6-offload)
+obj-y += addrconf_core.o exthdrs_core.o
+obj-$(CONFIG_INET) += output_core.o protocol.o $(ipv6_offload)
 
 obj-$(subst m,y,$(CONFIG_IPV6)) += inet6_hashtables.o
-- 
1.7.7.6
