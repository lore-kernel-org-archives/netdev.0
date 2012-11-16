From: Vlad Yasevich <vyasevic-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
Subject: Re: [PATCH] openvswitch: Make IPv6 packet parsing
 dependent on IPv6 config
Date: Fri, 16 Nov 2012 12:43:32 -0500
Message-ID: <50A67B44.9040508@redhat.com>
References: <50a5c2e5.lgIvZwesNLp78CVD%fengguang.wu@intel.com>
	<1353080434-14165-1-git-send-email-vyasevic@redhat.com>
	<CAEP_g=9ge1dq8ahinM075hjdfdmXaou4a9fqPyLPJQinths6pQ@mail.gmail.com>
Reply-To: vyasevic-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"; Format="flowed"
Content-Transfer-Encoding: 7bit
Cc: dev-yBygre7rU0TnMu66kgdUjQ@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, fengguang.wu-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org,
	davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org
To: Jesse Gross <jesse-l0M0P4e3n4LQT0dZR+AlfA@public.gmane.org>
Return-path: <dev-bounces-yBygre7rU0TnMu66kgdUjQ@public.gmane.org>
In-Reply-To: <CAEP_g=9ge1dq8ahinM075hjdfdmXaou4a9fqPyLPJQinths6pQ-JsoAwUIsXosN+BqQ9rBEUg@public.gmane.org>
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

On 11/16/2012 12:26 PM, Jesse Gross wrote:
> On Fri, Nov 16, 2012 at 7:40 AM, Vlad Yasevich <vyasevic-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org> wrote:
>
>> Openvswitch attempts to use IPv6 packet parsing functions without
>> any dependency on IPv6 (unlike every other place in kernel).  Pull
>> the IPv6 code in openvswitch togeter and put a conditional that's
>> dependent on CONFIG_IPV6.
>>
>> Resolves:
>> net/built-in.o: In function `ovs_flow_extract':
>> (.text+0xbf5d5): undefined reference to `ipv6_skip_exthdr'
>>
>> Signed-off-by: Vlad Yasevich <vyasevic-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
>
>
> Doesn't this move in the opposite direction of your patches to make IPv6
> GSO/GRO always available?  The packets being processed here
> are generally created by the guest but with Open vSwitch running on the
> host.  Also, ipv6_skip_exthdr() is in exthdrs_core.c, so it actually is
> always available.  I suspect that the real problem is that the dependency
> on the ipv6 directory changed to CONFIG_INET and Open vSwitch should now
> depend on this.
>

Yes and no... :)  IPv6 uses a bunch of IPv4 code all over.  IPv4 is 
enabled with CONFIG_INET and IPv6 with CONFIG_NET.  So creates a strange 
imbalance.  By shifting IPv6 to CONFIG_INET (which is where it
lives and what enables its selection during config process), we now have 
a dependency with openvswitch.

All other users of ipv6_skip_exthdr have it either under the IS_ENABLED 
conditional or through some other means that don't build it when INET is
completely turned off.  This patch does the same for openvswitch.

I see 2 alternatives to this:
  1) Make openvswitch depend on CONFIG_INET.
  2) Pull a ton of code out of CONFIG_INET (v4 and v6) and into 
CONFIG_NET.  This could start with IPv6 header parsing and maybe even
include GSO/TSO (but not sure how much sense that would be).

What's your take?

-vlad
