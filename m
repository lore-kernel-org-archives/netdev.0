From: Andi Kleen <ak@suse.de>
Subject: Re: 3c59x (was Route cache performance under stress)
Date: Wed, 11 Jun 2003 12:05:20 +0200
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20030611100520.GB27119@oldwotan.suse.de>
References: <20030610.085600.71109220.davem@redhat.com> <Pine.LNX.4.44.0306101815550.26879-100000@kenzo.iwr.uni-heidelberg.de> <20030610164949.GB13246@wotan.suse.de> <16102.64602.19145.131439@robur.slu.se>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Andi Kleen <ak@suse.de>,
   Bogdan Costescu <bogdan.costescu@iwr.uni-heidelberg.de>,
   "David S. Miller" <davem@redhat.com>, sim@netnation.com, ralph+d@istop.com,
   hadi@shell.cyberus.ca, xerox@foonet.net, fw@deneb.enyo.de,
   netdev@oss.sgi.com, linux-net@vger.kernel.org
Return-path: <netdev-bounce@oss.sgi.com>
To: Robert Olsson <Robert.Olsson@data.slu.se>
Content-Disposition: inline
In-Reply-To: <16102.64602.19145.131439@robur.slu.se>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Wed, Jun 11, 2003 at 11:54:34AM +0200, Robert Olsson wrote:
> 
> 
> Andi Kleen writes:
> 
>  > You can play some tricks with the driver to make eth_type_trans disappear
>  > from the profiles. This usually helps a lot because it avoids one
>  > full "fetch from cache cold memory" roundtrip per packet, which is slow on
>  > any CPU.
> 
> 
>  Andi!
>  Interesting. Can we get into details?

eth_type_trans checks the ethernet protocol ID and sets the broadcast/multicast/
unicast L2 type.

Some NICs have bits in the RX descriptor for most of them. They have a 
"packet is TCP or UDP or IP" bit and also a bit for unicast or sometimes
even multicast/broadcast. So when you have the RX descriptor you 
can just derive these values from there and put them into the skb
without calling eth_type_trans or looking at the cache cold header.

Then you do a prefetch on the header. When the packet reaches the 
network stack later the header has already reached cache  and it can be
processed without a memory round trip latency.

Caveats: 
On some cards it doesn't work for all packets or can be only done 
if you don't have any multicast addresses hashed (that's the case
for the e1000 if I read the header bits correctly). The lxt1001 
(old EOLed card) can do it for all packet types.

Often prefetch size is limited so you should not prefetch more
than what you can store until the packet reaches the stack.

-Andi
