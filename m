From: Julian Anastasov <ja@ssi.bg>
Subject: Re: routing bug report for 2.4
Date: Sat, 28 Jun 2003 23:12:47 +0300 (EEST)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <Pine.LNX.4.44.0306282159250.1804-100000@u.domain.uli>
References: <3EFDE0BC.8040803@candelatech.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Ben Greear <greearb@candelatech.com>
In-Reply-To: <3EFDE0BC.8040803@candelatech.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


	Hello,

On Sat, 28 Jun 2003, Ben Greear wrote:

> My test works if I ping the 192.1.2.1 router from the eth1 interface, the issue
> is that the localness of eth2 over-rides the policy based routing.

	ok but be ready for problems if rp_filter is used

> Also, note that it does work when I BINDTODEVICE on eth1.  I had assumed that
> because I was setting the source IP, and had a specific routing table for
> that case, then it would use that routing table.  In the error case, it is
> at least partially ignoring that routing table, though not entirely:  It is
> trying to communicate on eth1, but it is arping instead of routing.

	It is arping because '-I device' does not hit your
'from local_IP => 0/0 via remote_GW' route, the kernel can not find
route "from 0 to remote_IP oif dev". If you specify '-I local_IP' then
it will hit the 'from local_IP' rule that points to your table.
See, "Assume, that the destination is on link", it is not gatewayed
as you expect. Thus, the ARP probe is resolving target, not the GW.

	BINDTODEVICE translated to routing request is "oif XXX".
As ping can do -I device (and can not specify saddr at the same time)
the result is that the device is used (unless target is local),
saddr is autoselected (there is no provided saddr) starting from
the -I device, there is no GW (the target becomes gw, route is forced
onlink), the packet reaches the neighbouring code where ARP sends
probe to target (not to GW).

> >>Now, use ping to try to send pkts from one interface to the other:
> >>
> >>ping -I 192.1.1.2 192.1.2.2
> >
> >
> > 	Your report is damn wrong, why do you ping local IP?
> > Or may be that is your test? Trying ping from ip-utils... sorry,
> > not reproducible here (I hope it is the expected result).
>
> What results do you get?  And did you set up policy based routing?

	Yes, I have tried to simulate your rules and routes but
not exactly. In any case, I can not generate ARP traffic when
pinging local IP no matter what device I use. The kernel normally
overrides the -I option if you talk to local IP, lo is used.
It is expected with the plain kernel.

> I tried ping with RH8, RH9, and downloaded the latest ip-utils I could
> find.  Only when I hacked the ping source to bind to the local IP AND bind
> specifically to the device did it work.

	Yes, that will hit the ip rule and will avoid the "lo"
cancellation for your patched kernel.

> I am trying to ping a local IP but over the external network.  It is not something
> most people try to do now, I am aware.  As well as my twisted reasons, it would
> be good for determining path failures in an HA setup, so it's not completely
> useless :)

	I now see that you have patched kernel and this is the reason
I can not fully understand your previous postings. The normal kernel
can not generate such strange results (I mean the ARP requests when
resolving local IP). All your problems do not show kernel bug yet,
it seems the problem is hidden in your strategy to support remote
local IPs. Or may be you do not have problems with your tests
but the plain kernel is suspect for ping insanity?

> > 	Why? 192.1.2.2 is local IP and the local table is first
> > priority. We should not see any ARP packets for local targets, right?
>
> Local table is not used in my case because I specifically bind to the sending IP
> and have a table specifically for that case.

	Not true with the normal kernel, may be your patches
avoid selecting dev lo for traffic to local IPs if oif is specified?

> > 	I think, the root of your problems is that you specify
> > 'ping -I device' and the routing is forced to construct result from
> > unknown route by using source address autoselection.
>
> I am open to suggestions as to other ways to make this work:  I want to ping from eth1
> to eth2, and have at least the echo-request go out over eth1 and be routed back to eth2.

	I see, this is another problem because you do not mention
in your posts that you have patched kernel.

> > 	As for ping from iputils: you can specify device or saddr,
> > not the both, so the only valid test for source based routing can
> > be '-I IP'. Do you really need '-I eth1' ?
>
> Actually, from the code I looked at, you can use two -I flags, but what appears
> to be a bug actually keeps it from working completely (I could find no combo of arguments
> to make it make the BINDTODEVICE call.)

	I do not see such -I behaviour in ping. I understand that
the only way to really avoid the "lo" cancellation and to send
traffic with daddr=local_IP is to patch the routing to keep the
original device and always to BINDTODEVICE for this reason (-I dev).

> During some of my earlier testing, I had various things wrong.  For instance, I
> noticed that if I had policy-based routing on my router, it would not work correctly.

	missing preferred sources in routes?

> I have not debugged that issue in depth, as it does not really hinder the functionality
> that I require.  If it still doesn't work in 2.6 I'll open a bug ;)
>
> One final note, I am running a kernel with a patch that allows external comm over
> two interfaces on the same machine on the same subnet (with policy based routing).
> The normal ping works in this case, btw.  So, it may be that even if
> you change ping, it may still not work for you (my patch mostly deals with getting
> local ARPs to answer correctly, so I am not sure it comes into play in the routed case.)

	If you still suspect the kernel may be you can show me fresh link 
for this patch because I'm not sure it is valid or at least does not break 
the things. But adding 'I local_IP' together with "-I device" should avoid
the wrong ARP probe "where is TARGET", it should be changed to
"where is GW".

So, IMO, you need to make sure in your tests that:

- you have patched ping to support -I device and -I local_IP together
- you have preferred source in all your routes

Do you still suspect the kernel?

> Ben

Regards

--
Julian Anastasov <ja@ssi.bg>
