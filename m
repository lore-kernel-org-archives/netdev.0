From: Mark Smith <random@72616e646f6d20323030342d30342d31360a.nosense.org>
Subject: Re: bridge between ppp and ethernet - 1 IP address and assign it to
 another host
Date: Tue, 8 Mar 2005 00:26:43 +1030
Message-ID: <20050308002643.7eac84e7.random@72616e646f6d20323030342d30342d31360a.nosense.org>
References: <20050306153108.20430b58.random@72616e646f6d20323030342d30342d31360a.nosense.org>
	<1110199198.1094.1282.camel@jzny.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: ahu@ds9a.nl, netdev@oss.sgi.com
To: hadi@cyberus.ca
In-Reply-To: <1110199198.1094.1282.camel@jzny.localdomain>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On 07 Mar 2005 07:39:59 -0500
jamal <hadi@cyberus.ca> wrote:

Hi Jamal, Bert,

(Bert, sorry for calling you Ben earlier, I must have got a bit
distracted between seeing your name on a web page, and typing it on my
email client)

I'm fairly confident that broadly I'm thinking about the same way as
Bert, although as I'm about to go into some detail, it might turn out we
have slightly different ideas.

> 
> I actually havent quiet figured what you guys are talking about.
> Did i misunderstand or is it as simple as having ethernet on one (LAN)
> side and ppp on other (wan) side?
>

Not quite that simple. It's sort of "half routing" / "half bridging".

The Linux box terminates the PPP connection, including performing
authentication and aquisition of a /32 IP address from the service
providers PPP server - a typical point-to-point scenario. However,
rather than considering that IP address to now be a local address on the
Linux host, it is then allocated to the Windows (for e.g.) box ie. on
the Window's box's ethernet interface, the IP address is assigned. One
possiblity would be for the Linux box to issue the IP address to the
Windows box via DHCP. The Windows box's default gateway would be remote
PPP endpoint IP address, which means that the Linux box would also have
to perform Proxy ARP for that remote IP address on it's windows facing
ethernet interface. 

(I'm not sure if there would be issues with the default gateway on the
Windows box not being part of the same IP subnet that the allocated IP
address is, maybe that would be solved by assigning a /32 mask to the IP
address on the windows box, or possibly have DHCP configure a host route
on the Windows box for the default gateway, pointing out the ethernet
interface, so that it ARPs for the default gateway address, which the
Proxy ARP on the Linux box would receive. It would be interesting to see
what the DSL modems that do this trick do on the devices sitting behind
them.).

Here is the path an incoming and outgoing IP packets would follow,
adding in my firewalling suggestion :

1) IP packet comes in encapsulated in PPP.

2) The Linux box decapsulates it from the PPP header / trailer.

3) The Linux box performs layer 3 firewalling processing against the IP
packet.

4) If the IP packet passes the firewall rules, it is then encapsulated
in an ethernet frame, and sent to the Windows box. This might be achived
by configuring a host route for the IP address on the Linux box,
pointing directly to the ethernet interface, indicating it is directly
attached.

5) The windows box does what ever it wants with the IP packet, as normal.

6) The windows box sends a IP packet back, encapsulated in the ethernet
frame, via it's default gateway, which would be the Linux box Proxy
ARP'ing for the IP address of the remote PPP endpoint IP address.

7) The Linux box receives the IP packet, decapsulates it, and then
passes it through the layer 3 outgoing firewalling rules again.

8) If it passes those, it is then encapsulated in PPP, and off it goes.

The role the Linux box would be performing would be PPP session
termination, layer 3 firewalling and layer 2 style forwarding between
its ethernet and PPP interfaces.

Actually, what I've just described is quite similar to translational
bridging eg 802.5 (Token Ring) <-> 802.3 (Ethernet), with a bit of layer
3 processing ie. the firewalling occuring during the translation between
the layer 2 frame formats. The reason why it isn't quite translational
bridging is that PPP doesn't really have layer 2 addresses at all, so
the ethernet device can't specify a destination address in its header of
the PPP remote endpoint layer 2 address, which is why the Linux box has
to act as a Proxy for ARPs for the IP address of the remote end. In a TR
<-> Eth translation scenario, TR and Eth use compatible IEEE MAC
addresses, so the ethernet device can be fooled into believing it is
talking to another ethernet device, and vice versa, with a device in
between performing frame translation.

pppd already supports the Proxy ARP facility, although it is commonly
used to make a PPP connected remote PC appear on the local LAN where the
PPPD server is located. In the above scenario, Proxy ARP would be making
the remote router (ie. default getway) appear on the local LAN that the
Windows PC is attached to.


Hopefully that all makes sense ! If it doesn't, please ask, I'll work
out another way to explain it, or go into more detail.

Regards,
Mark.



-- 

    The Internet's nature is peer to peer.
