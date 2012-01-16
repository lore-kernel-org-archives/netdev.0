From: =?ISO-8859-2?Q?=A9tefan_Gula?= <steweg@gmail.com>
Subject: Re: [patch v1, kernel version 3.2.1] net/ipv4/ip_gre: Ethernet
 multipoint GRE over IP
Date: Mon, 16 Jan 2012 18:26:57 +0100
Message-ID: <CAGsizzK-La0iqt8sOXBVcn4W+8KgxMnvQgFFozEqZzQY+hGpzA@mail.gmail.com>
References: <CAGsizzJTbGGpwrn-P=SUtqBW=1AN6hCTVXKp_oKHPBAoGZ4ubA@mail.gmail.com>
 <20120116083634.7b327c34@nehalam.linuxnetplumber.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-2
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>,
	"David S. Miller" <davem@davemloft.net>,
	James Morris <jmorris@namei.org>,
	Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>,
	Patrick McHardy <kaber@trash.net>, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: Stephen Hemminger <shemminger@vyatta.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20120116083634.7b327c34@nehalam.linuxnetplumber.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

D=F2a 16. janu=E1ra 2012 17:36, Stephen Hemminger <shemminger@vyatta.co=
m> nap=EDsal/a:
> On Mon, 16 Jan 2012 13:13:19 +0100
> =A9tefan Gula <steweg@gmail.com> wrote:
>
>> From: Stefan Gula <steweg@gmail.com
>>
>> This patch is an extension for current Ethernet over GRE
>> implementation, which allows user to create virtual bridge (multipoi=
nt
>> VPN) and forward traffic based on Ethernet MAC address informations =
in
>> it. It simulates the Bridge bahaviour learing mechanism, but instead
>> of learning port ID from which given MAC address comes, it learns IP
>> address of peer which encapsulated given packet. Multicast, Broadcas=
t
>> and unknown-multicast traffic is send over network as multicast
>> enacapsulated GRE packet, so one Ethernet multipoint GRE tunnel can =
be
>> represented as one single virtual switch on logical level and be als=
o
>> represented as one multicast IPv4 address on network level.
>>
>> Signed-off-by: Stefan Gula <steweg@gmail.com>
>
> Thanks for the effort, but it is duplicating existing functionality.
> It possible to do this already with existing gretap device and the
> current bridge.
>
> The same thing is also supported by OpenVswitch.
>

gretap with bridge will not do the same as gretap allows you to only
encapsulate L2 frames inside the GRE - this one part is actually
utilized in my code. GRE multipoint implementation is also utilized in
my code as well. But what is missing is forwarding logic here, which
prevents the traffic going not optimal way. Scenario one - e.g. if you
connect through 3 sites with using 1 gretap multipoint VPN, it always
forwards frames between site 1 and site 2 even if they are unicast.
That represents waste of bandwidth for site 3. Now assume that there
will be more than 40 sites and I hope you see that single current
multipoint gretap is not also good solution here

The second scenario - e.g. using 3 sites using point-to-point gretap
interfaces between each 2 sites (2 gretap VPN interfaces per site) and
bridging those interfaces with real ones results in looped topology
which needs to utilized STP inside to prevent loops. Once STP
converges the topology will looks like this, traffic from site 1 to
site 2 will go always directly by the way of unicast (on GRE level),
from site 2 to site 3 always directly by the way of unicast (on GRE
level) and from site 1 to site 3 will go indirectly through site 2 due
STP limitations, which results in another not optimalized traffic
flows. Now assume that the number of sites rises, so gretap+standard
bridge code is also not a good solution here.

My code utilizes it that way that I have extended the gretap
multipoint interface with the forwarding logic e.g. using 3 sites,
each site uses only one gretap VPN interface and if destination MAC
address is known to bridge code inside the gretap interface forwarding
logic, it forwards it towards only VPN endpoint that actually need
that by the way of unicasting on GRE level. On the other hand if the
destination MAC address is unknown or destination MAC address is L2
multicast or L2 broadcast than the frame is spread out through
multicasting on GRE level, providing delivery mechanism analogous to
standard switches on top of the multipoint GRE tunnels.

I also get through briefly over OpenVswitch documentation and found
that it is more related to virtualization inside the box like VMware
switches or so and not to such technologies interconnecting two or
more separate segments over routed L3 infrastructure - there is a
mention about the CAPWAP UDP transport but this is more related to
WiFi implementations than generic ones. My patch also doesn't need any
special userspace api to be configured. It utilizes the existing one.
