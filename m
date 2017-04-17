From: Linus =?utf-8?Q?L=C3=BCssing?= <linus.luessing@c0d3.blue>
Subject: Re: [PATCH v2] bridge: ebtables: fix reception of frames
 DNAT-ed to bridge device
Date: Mon, 17 Apr 2017 17:21:33 +0200
Message-ID: <20170417152133.GA5175@otheros>
References: <20170321222845.8373-1-linus.luessing@c0d3.blue>
	<20170321163245.34159349@xeon-e3>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 8bit
Cc: netdev@vger.kernel.org, bridge@lists.linux-foundation.org,
	linux-kernel@vger.kernel.org, coreteam@netfilter.org,
	netfilter-devel@vger.kernel.org,
	Jozsef Kadlecsik <kadlec@blackhole.kfki.hu>,
	"David S . Miller" <davem@davemloft.net>,
	Pablo Neira Ayuso <pablo@netfilter.org>
To: Stephen Hemminger <stephen@networkplumber.org>
Return-path: <bridge-bounces@lists.linux-foundation.org>
Content-Disposition: inline
In-Reply-To: <20170321163245.34159349@xeon-e3>
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/bridge>,
	<mailto:bridge-request@lists.linux-foundation.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/bridge/>
List-Post: <mailto:bridge@lists.linux-foundation.org>
List-Help: <mailto:bridge-request@lists.linux-foundation.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/bridge>,
	<mailto:bridge-request@lists.linux-foundation.org?subject=subscribe>
Sender: bridge-bounces@lists.linux-foundation.org
Errors-To: bridge-bounces@lists.linux-foundation.org
List-Id: netdev.vger.kernel.org

On Tue, Mar 21, 2017 at 04:32:45PM -0700, Stephen Hemminger wrote:
> On Tue, 21 Mar 2017 23:28:45 +0100
> Linus Lüssing <linus.luessing@c0d3.blue> wrote:
> 
> > However, the IP code drops it in the beginning of ip_input.c/ip_rcv()
> > as the dnat target did not update the skb->pkt_type. If after
> > dnat'ing the packet is now destined to us then the skb->pkt_type
> > needs to be updated from PACKET_OTHERHOST to PACKET_HOST, too.
> 
> Why not fix DNAT netfilter module rather than hacking bridge code here.

Sorry for the late response. Wanted to do some more testing before
replying.

My assumptions regarding macvlan were wrong:

A) The code my patch adds is not touched in the case of a macvlan
device on top of a bridge - with macvlan there seems to be no FDB entry
for the MAC address of the macvlan device at all, actually, resulting
in the flooding of a frame intended for that device (is this, ehm,
known/intended?).

B) ip_rcv() does not drop for a macvlan device, because macvlan
unconditionally sets skb->pkt_type to PACKET_HOST in macvlan_handle_frame().

(And I guess, maybe I shouldn't actually care that much about
macvlans on top of a bridge, as a veth-pair is much cleaner for that?)


Regarding netdev::dev_addrs, if I understand the kernel code correctly, it
is only, potentially populated with more than netdev::dev_addr for two
drivers, via dev_addr_add(): bnx2x and ixgbe. So for a bridge device,
there should never be more than one item in netdev::dev_addrs
(= netdev::dev_addr), correct?


So, currently I'm happy with moving the fix into the ebtables dnat
code and just checking against the netdev::dev_addr of the bridge
device now. (if anyone has any suggestions regarding upper devices
I should test with that, then please let me know)

(Sorry, Pablo, for me pressing against your earlier suggestion to
put the fix in the ebtables dnat instead of bridge code. :( )

Regards, Linus
