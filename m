From: jamal <hadi@cyberus.ca>
Subject: Re: dummy as IMQ replacement
Date: 31 Jan 2005 08:39:30 -0500
Message-ID: <1107178770.7840.151.camel@jzny.localdomain>
References: <1107123123.8021.80.camel@jzny.localdomain>
	 <200501311438.01118.hasso@estpak.ee>
	 <1107175673.7847.130.camel@jzny.localdomain>
	 <200501311502.56796.hasso@estpak.ee>
Reply-To: hadi@cyberus.ca
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com, Nguyen Dinh Nam <nguyendinhnam@gmail.com>,
        Remus <rmocius@auste.elnet.lt>, Andre Tomt <andre@tomt.net>,
        syrius.ml@no-log.org, Andy Furniss <andy.furniss@dsl.pipex.com>,
        Damion de Soto <damion@snapgear.com>
Return-path: <netdev-bounce@oss.sgi.com>
To: Hasso Tepper <hasso@estpak.ee>
In-Reply-To: <200501311502.56796.hasso@estpak.ee>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Mon, 2005-01-31 at 08:02, Hasso Tepper wrote:
> jamal wrote:
[..]
> > What are you trying to do? Are you also trying to rate limit ARPs etc
> > in one shot?
> 
> All traffic coming from eth1.101 interface.
> 

eth1.101 is an alias? You may have issues there. Maybe not if the
attach to that interface worked.

>
> > tc filter add dev eth1.101 parent ffff: protocol all prio 50 handle \
> > 0x101 fw police rate 1024kbit burst 60k drop flowid :101
> >
> > Does this even get hit at all? tc -s would show you stats. I suspect
> > for one it is not being hit.
> 
> As far as I remember situation was exactly as I described. This worked for 
> IPv4 traffic, but not for IPv6 traffic.
>

Off hand i cant see why .. Unless the ipv6 packets didnt get marked
properly but the v4 ones did?

> > Maybe you are trying to use iptables marks that happen
> > a long time after the ingress has seen the packets (which would
> > explain why it is not being hit)? This would be true kernels > 2.6.8
> > but not before ..
> 
> This test was done with 2.6.6.

Ok, in that case iptables prerouting would have come before ingress; so 
as long as you marked the packets with iptables it should work fine.

> > In other words, it may be a config issue.
> 
> Would be nice ;).

I am still thinking it is. What are your iptables v6 markers?

> > If you tell me what it is you are trying to do i could try and set it
> > up when i come back from work today.
> 
> I'd like to limit _all_ traffic coming in from one particular interface to 
> the one common limit. No matter what traffic it is - IPv4 or IPv6. Sum of 
> traffic should be the one I specify.

Theres other ways to do it[1] but if theres a bug in this it needs
fixing.

cheers,
jamal

[1]
Example, you could do this:

tc filter add dev eth1 parent ffff: protocol ip prio 1 \
u32 match u32 0 0 flowid 1:15 \
action police index 1 rate 1024kbit burst 60k drop index 1

Note the use of "index 1" to select a policer.

Then repeat replacing ip with ip6; make sure that "index 1" for policer
stays. You could do this to share also across devices.

Example, on egress of eth0 also use the same 1Mbps

tc filter add dev eth0 parent 1:0 protocol ip prio 6 u32 \
match ip src 10.0.0.21/32 flowid 1:16 \
action police index 1 rate 1024kbit burst 60k drop index 1

Now with new action stuff you could instead just have said:
tc actions add \
action police index 1 rate 1024kbit burst 60k drop index 1

And then later just referenced it without having to repeat the rate
like so:
filter add dev eth0 parent ffff: protocol ip prio 6 u32 match ip src \
10.0.0.21/32 flowid 1:16 \
action police index 1

Again, this does not excuse a bug if it exists ...
