From: "James R. Leu" <jleu@mindspring.com>
Subject: Re: send-to-self (was Re: routing bug report for 2.4)
Date: Mon, 30 Jun 2003 15:22:46 -0500
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20030630152246.B22997@mindspring.com>
References: <3EFE131E.1080807@candelatech.com> <Pine.LNX.4.44.0306291110070.8466-100000@u.domain.uli>
Reply-To: jleu@mindspring.com
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Ben Greear <greearb@candelatech.com>, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Julian Anastasov <ja@ssi.bg>
In-Reply-To: <Pine.LNX.4.44.0306291110070.8466-100000@u.domain.uli>; from ja@ssi.bg on Sun, Jun 29, 2003 at 12:43:26PM +0300
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

I have some done some work on a related subject, 'virtual routing and
forwarding' for linux.  One of the applications of this is 'self-to-self'
routing.

I have mentioned my work before on this list, and have been flamed (but no
one provided me with ideas on how to do it better).  If you would like to take
a look at what I have done, head over to:

    http://linux-vrf.sf.net/

I'm open for suggestions of how to implement this better.

On Sun, Jun 29, 2003 at 12:43:26PM +0300, Julian Anastasov wrote:
> 
> 	Hello,
> 
> On Sat, 28 Jun 2003, Ben Greear wrote:
> 
> > My send-to-self patch that I have been using is attached.  I also have some other
> > patches for mac-vlans and packet-gen applied, but I don't believe these will have any
> > impact on the behaviour we have been discussing.
> 
> 	Ben, lets define new behaviour for your feature:
> 
> 1. we mark ethX with /proc/sys/net/ipv4/conf/ethX/loop=1. That means
> this is a loop device (my site contains lot of device flags, you
> can see what costs creating a sysctl var):
> http://www.ssi.bg/~ja/
> just hit some of the links, recommended example:
> http://www.ssi.bg/~ja/forward_shared-2.4.19-2.diff
> 
> 	there are 2 variants:
> 
> 	- loop can be 0(no loop) / 1(loop inout) or
> 
> 	- 0(no loop), 1(loop in only), 2(loop out only), 3(loop inout)
> 
> 	where "loop in only" means "accept only" and "loop out only"
> 	is "send only" interface
> 
> 	but as all traffics are inout I think "loop inout" will
> be always used
> 
> 2. arp_filter accepts traffic on ethX (as in your patch)
> if "loop in" is allowed for indev and "loop out" for the
> out_dev in routing result
> 
> 3. rp_filter (source validation) accepts traffic on ethX (as in your
> patch) if "loop in" is allowed
> 
> 4. get unicast output route for local IPs ethY->ethX if "loop in" is
> allowed for ethX and "loop out" is allowed for "ethY. ARP
> will add cache entries for local IPs.
> 
> 
> Goal 1. Can we just skip the BINDTODEVICE thing and to replace it
> with bind to src IP. We can avoid binding to src IP for our
> tests if we replace the preferred source IP in the desired local
> routes but this is a hack. Using BINDTODEVICE will not add
> any benefits but will be supported (it is ignored).
> 
> Then to define it in this way:
> 
> If ethX has "/proc/sys/net/ipv4/conf/ethX/loop" set to !0 then
> all output routes "from local_ip_on_ethY to local_ip_on_ethX" will
> not receive "lo" result but "ethY" with RTN_UNICAST type
> if local_ip_on_ethY is configured on ethY (ethY has loop enabled too),
> no matter the key->oif value. Sort of:
> 
> fib_lookup for "from IP1 to IP2 oif XXX"
> if (RTN_LOCAL)
> {
> 	if dev_out is loop_in and key->src != 0
> 	{
> 		src = key->src? : FIB_RES_PREFSRC(res);
> 		dev_in = ip_dev_find(src);
> 		if (dev_in is loop_out)
> 		{
> 			use dev_in as dev_out
> 			goto make_route;
> 		}
> 	}
> 	// else
> 	use "lo"
> }
> 
> - this code is slow but it is guarded from loop check for out_dev
> so I do not see performance impact (the output routing to localhost
> is not used often). The result is cached (you can set long
> routing cache expiration value during the tests).
> 
> - we assume my patch from previous posting is applied
> and we match any local IP no matter the key oif.
> 
> Goal 2. Can we skip all TCP/UDP changes?
> 
> - we rely on the fact the routing results allow traffic in
> both directions (incoming is accepted with RTN_LOCAL, output
> gets RTN_UNICAST). As for IPv6 I can not comment, we define
> ipv4/conf/XXX/loop flag, though. But I prefer we to keep the
> changes only at routing level. For TCP and UDP these talks
> should look as if "lo" is used.
> 
> - what I'm not sure is whether any socket hash problems exists
> and this is the only thing that can prevent this patch to look
> nice and fast. But I'm wondering there are such issues as
> the talks on "lo" should work but we have to check that.
> 
> 	The usage:
> 
> - mark eth0 as loop_out and eth1 as loop_in device and start the test
> in eth0->eth1 direction or use loop inout for both directions.
> 
> 	If you think that we can change only the routing then
> I can prepare patch for testing, I'm not sure I have a test setup
> for this feature right now.
> 
> Regards
> 
> --
> Julian Anastasov <ja@ssi.bg>
> 

-- 
James R. Leu
