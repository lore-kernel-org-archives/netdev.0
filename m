From: Lennert Buytenhek <buytenh@wantstofly.org>
Subject: Re: [22/*] [NETFILTER] Use correct IPsec MTU in TCPMSS
Date: Sun, 20 Mar 2005 18:17:07 +0100
Message-ID: <20050320171707.GE4201@xi.wantstofly.org>
References: <20050314102614.GA9610@gondor.apana.org.au> <20050314105313.GA21001@gondor.apana.org.au> <20050314111002.GA29156@gondor.apana.org.au> <20050315091904.GA6256@gondor.apana.org.au> <20050315095837.GA7130@gondor.apana.org.au> <20050318090310.GA28443@gondor.apana.org.au> <20050318091129.GA28658@gondor.apana.org.au> <20050318104013.57d65e99.davem@davemloft.net> <423D9ADA.6050407@trash.net> <423DA58D.4050406@protactive.nl>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@oss.sgi.com
To: Ludo Stellingwerff <ludo@protactive.nl>,
        Herbert Xu <herbert@gondor.apana.org.au>
Content-Disposition: inline
In-Reply-To: <423DA58D.4050406@protactive.nl>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Sun, Mar 20, 2005 at 05:32:13PM +0100, Ludo Stellingwerff wrote:

> As an daily user of Patricks patches, I like to agree with Patricks
> analysis about the loosing of flexibility with the choice not to use
> virtual devices. In a real-life situation I had to revert to using
> plain, unsave GRE-tunnels because of the complexity of using 2.6-ipsec
> for the same purpose. I'm routing one of multiple defaultroutes over
> this tunnel:) It felt like a relieve having a device to work with.

I'll add my 2 cents to this.

In my situation, there are three different sites in the same city
(Amsterdam), interconnected using a shared L2 vlan, and six routers
(A1, A2, B1, B2, C1, C2) on that vlan, two per site for redundancy
reasons.  Each router runs ospf.

The vlan is provided to us by a telco that we do not necessarily trust.
So ideally, we'd like all traffic that goes over the vlan (modulo ARPs
and STP and stuff) to be encrypted.  ("-o eth3 -j ENCRYPT")

The problem I kept running into with tunnel mode is that tunnel
mode SPD rules appear to dictate routing policy in a way that's not
compatible with dynamic routing.

I.e., a line like:

	spdadd 10.10.1.0/24 10.0.1.0/24 any -P out ipsec esp/tunnel/1.2.3.4-5.6.7.8/require;

effectively says "All traffic from 10.10.1.0/24 to 10.0.1.0/24 will
be sent over a tunnel with local endpoint 1.2.3.4 and remote endpoint
5.6.7.8", but:
- I have no idea beforehand what address ranges are going to be routed
  over this vlan.  (Customers might send traffic with source addresses
  in address ranges that they don't announce to us (asymmetric routing),
  and I don't want those packets to remain unencrypted just because they
  don't match the SPD rule.)  A 0.0.0.0/0 0.0.0.0/0 rule would not be
  appropriate either since that'd suck _all_ traffic into this tunnel.
- I have no idea beforehand what the remote nexthop is going to be.  A1
  might ordinarily send its traffic for site B to B1, but if B1 fails
  it'll want to start using B2 instead, which would be prevented by the
  SPD rule hardcoding the remote tunnel endpoint to B1.

The workaround we tried at first was to create GRE tunnels between each
pair of routers on the vlan, and to run ospf over the tunnels instead of
directly over the vlan interface.  That gave MTU problems, though, which
made us just forget about ipsec altogether and use vtund instead, hardly
better than nothing.  (Now that Herbert has submitted a number of fixes
for ipsec MTU issues with tunnels, I guess I should go and give the
GRE-over-ipsec setup a go again.)

Then again, maybe I totally misunderstood the way this is supposed to
work.


--L
