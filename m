From: Florian Fainelli <f.fainelli@gmail.com>
Subject: Re: [PATCH net-next v3 06/10] net: dsa: Migrate to device_find_class()
Date: Fri, 10 Feb 2017 10:30:58 -0800
Message-ID: <29f1c56a-45ab-53b8-e6c6-83746e6ae18b@gmail.com>
References: <20170114214713.28109-7-f.fainelli@gmail.com>
 <20170115110628.GF26374@kroah.com>
 <fc247aeb-a8d6-5ba9-c26d-cb057a5ac34d@gmail.com>
 <20170115173949.GA19268@kroah.com>
 <a9ea1f45-b9a5-d840-68e0-9bf9bc7a6598@gmail.com>
 <20170115191632.GD5643@lunn.ch>
 <912e6143-c67a-d909-2a6c-939de79efc5d@gmail.com>
 <20170119142820.GA494@kroah.com> <20170119145315.GD21805@lunn.ch>
 <20170119165155.GH27312@n2100.armlinux.org.uk>
 <20170210130217.GA4570@kroah.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: Andrew Lunn <andrew@lunn.ch>, Jason Cooper <jason@lakedaemon.net>,
 Vivien Didelot <vivien.didelot@savoirfairelinux.com>, netdev@vger.kernel.org,
 open list <linux-kernel@vger.kernel.org>,
 Gregory Clement <gregory.clement@free-electrons.com>,
 "David S. Miller" <davem@davemloft.net>,
 "moderated list:ARM SUB-ARCHITECTURES" <linux-arm-kernel@lists.infradead.org>,
 Sebastian Hesselbarth <sebastian.hesselbarth@gmail.com>
To: Greg KH <gregkh@linuxfoundation.org>,
 Russell King - ARM Linux <linux@armlinux.org.uk>
Return-path: <linux-arm-kernel-bounces+linux-arm-kernel=m.gmane.org@lists.infradead.org>
In-Reply-To: <20170210130217.GA4570@kroah.com>
List-Unsubscribe: <http://lists.infradead.org/mailman/options/linux-arm-kernel>,
 <mailto:linux-arm-kernel-request@lists.infradead.org?subject=unsubscribe>
List-Archive: <http://lists.infradead.org/pipermail/linux-arm-kernel/>
List-Post: <mailto:linux-arm-kernel@lists.infradead.org>
List-Help: <mailto:linux-arm-kernel-request@lists.infradead.org?subject=help>
List-Subscribe: <http://lists.infradead.org/mailman/listinfo/linux-arm-kernel>,
 <mailto:linux-arm-kernel-request@lists.infradead.org?subject=subscribe>
Sender: "linux-arm-kernel" <linux-arm-kernel-bounces@lists.infradead.org>
Errors-To: linux-arm-kernel-bounces+linux-arm-kernel=m.gmane.org@lists.infradead.org
List-Id: netdev.vger.kernel.org

On 02/10/2017 05:02 AM, Greg KH wrote:
> On Thu, Jan 19, 2017 at 04:51:55PM +0000, Russell King - ARM Linux wrote:
>> (This is mainly for Greg's benefit to help him understand the issue.)
>>
>> I think the diagram you gave initially made this confusing, as it
>> talks about a CPU(sic) producing the "RGMII" and "MII-MGMT".
>>
>> Let's instead show a better representation that hopefully helps Greg
>> understand networking. :)
>>
>>
>>   CPU
>> System <-B->  Ethernet controller <-P-> } PHY <---> network cable
>>                                         } - - - - - - - or - - - - - - -
>>                   MDIO bus -------M---> } Switch <-P-> PHYs <--> network
>>                                               `----M----^        cables
>>
>> 'B' can be an on-SoC bus or something like PCI.
>>
>> 'P' are the high-speed connectivity between the ethernet controller and
>> PHY which carries the packet data.  It has no addressing, it's a point
>> to point link.  RGMII is just one wiring example, there are many
>> different interfaces there (SGMII, AUI, XAUI, XGMII to name a few.)
>>
>> 'M' are the MDIO bus, which is the bus by which ethernet PHYs and
>> switches can be identified and controlled.
>>
>> The MDIO bus has a bus_type, has host drivers which are sometimes
>> part of the ethernet controller, but can also be stand-alone devices
>> shared between multiple ethernet controllers.
>>
>> PHYs are a kind of MDIO device which are members of the MDIO bus
>> type.  Each PHY (and switch) has a numerical address, and identifying
>> numbers within its register set which identifies the manufacturer
>> and device type.  We have device_driver objects for these.
>>
>> Expanding the above diagram to make it (hopefully) even clearer,
>> we can have this classic setup:
>>
>>   CPU
>> System <-B-> Ethernet controller <-P-> PHY <---> network cable
>>                  MDIO bus -------M------^
>>
>> Or, in the case of two DSA switches attached to an Ethernet controller:
>>
>>                                      |~~~~~~~~|
>> System <-B-> Ethernet controller <-P-> Switch <-P-> PHY1 <--> network cable
>>                  MDIO bus ----+--M--->   1    <-P-> PHY2 <--> network cable
>>                               |      |        ...    |
>>                               |      |        <-P-> PHYn <--> network cable
>>                               |      |....^...|      |
>>                               |           |  `---M---'
>>                               |           P
>>                               |           |
>>                               |      |~~~~v~~~|
>>                               `------> Switch <-P-> PHY1 <--> network cable
>>                                      |   2    ...    |
>>                                      |        <-P-> PHYn <--> network cable
>>                                      |........|      |
>>                                              `---M---'
>>
>> The problem that the DSA guys are trying to deal with is how to
>> represent the link between the DSA switches (which are devices
>> sitting off their controlling bus - the MDIO bus) and the ethernet
>> controller associated with that collection of devices, be it a
>> switch or PHY.
> 
> Why do they have to represent that link?  This is a driver that somehow
> binds the two togther in some sort of "control plane"?

We have to represent that link because the CPU/host/management Ethernet
MAC is physically connected to the CPU/management port of the switch. It
does indeed participate in establishing the control plane.

The basic idea of DSA is that the switch inserts vendor tags to indicate
why the packet is sent towards the CPU in the first place: flooding,
management, copy etc along with information as to which
originating/destination port(s) this packet comes/goes from/to. On top
of that, we demultiplex that tag to deliver normal Ethernet frames to
per-port network devices (virtual network devices).

If we did leave the switch in an unmanaged mode and not logically
attached to an Ethernet MAC for management, we'd lose all that
information (we could use per-port VLANs to re-create it, but it would
be inferior to what a switch with proprietary tags can do)

Code in net/dsa/dsa2.c that binds the two (switch and Ethernet MAC)
together is not strictly a driver, it just is resident in memory and
waits for dsa_register_switch() to be called until it tries to do this
binding.

> 
>> Merely changing the parent/child relationships to try and solve
>> one issue just creates exactly the same problem elsewhere.
> 
> Fair enough.
> 
>> So, I hope with these diagrams, you can see that trying to make
>> the ethernet controller a child device of the DSA switches
>> means that (eg) it's no longer a PCI device, which is rather
>> absurd, especially when considering that what happens to the
>> right of the ethernet controller in the diagrams above is
>> normally external chips to the SoC or ethernet device.
> 
> Ok, thanks for the long explainations and diagrams.
> 
> _BUT_ my original point remains.  These new functions you all are trying
> to get into the driver core, do NOT do what they say they are doing.
> They are mucking around with a "known topology" and just happen to work
> because the device you are trying to find shares a common parent with
> yourself.
> 
> That is not what the function says it does, and as such, I do not want
> that function in the driver core at all.
> 
> If you wish to keep it in your own subsystem, that's fine, but call it
> what it really is:
> 	hack_to_find_peer_device_on_random_bus()
> and pass in a _real_ pointer to a bus type.  Not some random string
> please.

Yes, David has accepted that and we did make it prefixed with dsa_*.
That does not mean it should stay forever though if we can work on
something better designed.

> 
> Or better yet, have the DSA code accept pointers to the two devices in
> the first place, so it "knows" what to do here in a much better way.

Well, that is really what is being done here, the "inputs" to the code
in net/dsa/dsa2.c are opaque struct device references that we
verify/proof by making sure they belong in the class of device we expect
them to be.

NB: technically it's just one device reference: Ethernet MAC device,
because the other one is implied by the device driver registering the
switch with dsa_register_switch() (MDIO, SPI, I2C, PCI etc..).

> Right now it is a bad hack.  You all can not argue that is not true.

It's hard to argue on an qualifier for that design when we can't even
agree whether our understanding of these devices matches your
understanding after you read and digested our explanations :)

I entirely agree that the design has shortcomings, and in fact, it does
present some challenges that are not well solved right now, if you
unbind the Ethernet MAC driver, you leave a dangling DSA switch tree,
and good luck re-attaching it.

So maybe we should talk about it in person at $next conference, I will
be at ELC, how about you?

Thanks
-- 
Florian
