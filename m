From: jamal <hadi@cyberus.ca>
Subject: Re: bridge between ppp and ethernet - 1 IP address and assign it
	to another host
Date: 07 Mar 2005 18:33:26 -0500
Message-ID: <1110238406.1043.57.camel@jzny.localdomain>
References: <20050306153108.20430b58.random@72616e646f6d20323030342d30342d31360a.nosense.org>
	 <1110199198.1094.1282.camel@jzny.localdomain>
	 <20050308002643.7eac84e7.random@72616e646f6d20323030342d30342d31360a.nosense.org>
	 <20050307213211.GA25323@outpost.ds9a.nl>
Reply-To: hadi@cyberus.ca
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: Mark Smith <random@72616e646f6d20323030342d30342d31360a.nosense.org>,
        netdev@oss.sgi.com
To: bert hubert <ahu@ds9a.nl>
In-Reply-To: <20050307213211.GA25323@outpost.ds9a.nl>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Mon, 2005-03-07 at 16:32, bert hubert wrote:
> On Tue, Mar 08, 2005 at 12:26:43AM +1030, Mark Smith wrote:

I think i got it finally ..

> Indeed, we are in full agreement. The idea is to have the ability to fully
> firewall and monitor a machine that absolutely needs to have a real
> routable IP address, without wasting an IP address for the router (or trying
> to get an ISP to assign you multiple addresses, which can be a major chore
> these days).
> 
> I'd settle for a 'dirty' solution. Remco van Mook of Virtu.nl suggested
> abusing iptables -j QUEUE combind with tun/tap to inject the packets on the
> ethernet side, where userspace does the PPP -> ethernet conversion by making
> up the required headers.
>
> Ideas?

Seems you will get much speedup doing it in the kernel instead.
So lets take the steps Mark posted. Actually before that, is the proxy
ARP really necessary if the windoz machines have a default gateway of
this proxy machine.

Lets looks t incoming from PPP:
 
> 1) IP packet comes in encapsulated in PPP.

> 2) The Linux box decapsulates it from the PPP header / trailer.

> 3) The Linux box performs layer 3 firewalling processing against the 
> IP packet.

Assuming 1 to 1 mapping i.e each pppx maps to one windows machine
(on one eth device?);
then when you issue the DHCP IP to the windoz machine you add the
following rules:

(assuming kernels 2.6.8 and up) with tc actions

eg 
tc ...ingress pppx...
tc ... dev pppx u32 match 0/0 i.e match all packets that came via pppx 
      action some firewall rules here .. (stateless for now)
      action some rate limit here ..
      action mirred redirect ethx  // eventually redirect to windoz

I think this should work fine; there may be need to rewrite MAC
addresses - but if you give this a shot and things are screwed up we
could redraw.
I am willing toi help you resolve the issue if you put the effort.

>4) If the IP packet passes the firewall rules, it is then encapsulated
>in an ethernet frame, and sent to the Windows box. This might be
>achived by configuring a host route for the IP address on the Linux 
> box, pointing directly to the ethernet interface, indicating it is
> directly attached.

If you do the above, do you really need to route to the windoz machines?
Let them worry about things...

On the return path it is much simpler; just have windows forward and let
routing take care of it. 
So summary:
 -->pppx -->"switch"---> windoz
 <--pppx <-- L3route <--- windoz

cheers,
jamal
