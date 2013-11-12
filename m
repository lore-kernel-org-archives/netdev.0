From: Kamala R <kamala@aristanetworks.com>
Subject: Re: IPv6: Blackhole route support partial ?
Date: Tue, 12 Nov 2013 16:39:10 +0530
Message-ID: <CAP8BHkG6=KuU9K7=sGsZftMDe58eTYByRu2DZ+j+KNqcfsOfAA@mail.gmail.com>
References: <CAP8BHkGZ5EFxW4BNervKrOiEaQTNdSh9s2YOrFoexzQCOR=AqQ@mail.gmail.com>
	<20131111203954.GB3043@order.stressinduktion.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
To: Kamala R <kamala@aristanetworks.com>, davem@davemloft.net,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20131111203954.GB3043@order.stressinduktion.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi,

Sure, here it is.

--- linux-3.12/net/ipv6/route.c.orig    2013-11-12 16:23:46.000000000 +0530
+++ linux-3.12/net/ipv6/route.c 2013-11-12 16:30:51.000000000 +0530
@@ -1570,9 +1570,13 @@ int ip6_route_add(struct fib6_config *cf
                switch (cfg->fc_type) {
                case RTN_BLACKHOLE:
                        rt->dst.error = -EINVAL;
+                       rt->dst.input = dst_discard;
+                       rt->dst.discard = dst_discard;
                        break;
                case RTN_PROHIBIT:
                        rt->dst.error = -EACCES;
+                       rt->dst.input = ip6_pkt_prohibit;
+                       rt->dst.output = ip6_pkt_prohibit_out;
                        break;
                case RTN_THROW:
                        rt->dst.error = -EAGAIN;

Is this ok ?

Regards,
Kamala


On Tue, Nov 12, 2013 at 2:09 AM, Hannes Frederic Sowa
<hannes@stressinduktion.org> wrote:
> Hello!
>
> On Mon, Nov 11, 2013 at 07:25:14PM +0530, Kamala R wrote:
>> On adding IPv6 blackhole routes, ICMP unreachable messages are being
>> sent back to source. According to the definition, packets destined to
>> a blackhole address must be dropped silently.
>
> Yes, this is a bug.
>
>> I applied the patch submitted to the 3.7 kernel that indicates that it
>> supports blackhole and prohibit routes correctly. However, the patch
>> only sets the error code and route type correctly, so the show command
>> displays the appropriate output.
>>
>>
>> It seems to me that the input and output function pointers of the dst
>> variable, which determine packet processing, need to be set to
>> dst_discard. This would enable correct behaviour for blackhole routes.
>> Am I on the right path here ?
>
> I think you are. ip6_pkt_discard is not the correct input/output
> function for blackhole routes. In ip6_route_add simply set up the
> function pointers in the switch instead to just initializing them to
> ip6_pkt_discard. dst_discard is fine. Looks like prohibit rules are not
> handled correctly either. They should go to ip6_pkt_prohibit. (Just look at
> how the templates are initialized.)
>
> Could you cook a patch?
>
> Thanks,
>
>   Hannes
>
