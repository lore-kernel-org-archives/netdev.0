From: Florian Fainelli <f.fainelli@gmail.com>
Subject: Re: [PATCH RFC WIP 0/5] IGMP snooping for local traffic
Date: Sun, 27 Aug 2017 19:44:15 -0700
Message-ID: <b5bf300b-58c1-d7a7-8851-651683a234b0@gmail.com>
References: <1503780970-10312-1-git-send-email-andrew@lunn.ch>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 8bit
Cc: Vivien Didelot <vivien.didelot@savoirfairelinux.com>,
	nikolay@cumulusnetworks.com, roopa@cumulusnetworks.com,
	bridge@lists.linux-foundation.org, jiri@mellanox.com
To: Andrew Lunn <andrew@lunn.ch>, netdev <netdev@vger.kernel.org>
Return-path: <bridge-bounces@lists.linux-foundation.org>
In-Reply-To: <1503780970-10312-1-git-send-email-andrew@lunn.ch>
Content-Language: en-US
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

Hi Andrew,

On 08/26/2017 01:56 PM, Andrew Lunn wrote:
> This is a WIP patchset i would like comments on from bridge,
> switchdev and hardware offload people.
> 
> The linux bridge supports IGMP snooping. It will listen to IGMP 
> reports on bridge ports and keep track of which groups have been 
> joined on an interface. It will then forward multicast based on this 
> group membership.
> 
> When the bridge adds or removed groups from an interface, it uses 
> switchdev to request the hardware add an mdb to a port, so the 
> hardware can perform the selective forwarding between ports.
> 
> What is not covered by the current bridge code, is IGMP joins/leaves 
> from the host on the brX interface. No such monitoring is performed.
> With a pure software bridge, it is not required. All mulitcast frames
> are passed to the brX interface, and the network stack filters them,
> as it does for any interface. However, when hardware offload is
> involved, things change. We should program the hardware to only send
> multcast packets to the host when the host has in interest in them.

OK, so if I understand this right, without a bridge, we have the
following happen today: with a DSA-enabled setup using any kind of
switch tagging protocol, if a host is interested in receiving particular
multicast traffic, we would receive IGMP joins/leaves through sw0p0, and
the stack should call ndo_set_rx_mode for sw0p0, which would be
dsa_slave_set_rx_mode() and which would synchronize the DSA master
network device with the slave network device, everything works fine
provided that the CPU port is configured to accept multicast traffic.

Note here that we don't really add a MDB entry for sw0p0 when that
happens, but it seems like we should for switches that lack IGMP
snooping and/or multicast filtering.

With the current bridge and DSA code, are not we actually always going
to get the CPU port to be added with the multicast address and therefore
no filtering is occurring and snooping is pretty much useless?

> 
> Thus we need to perform IGMP snooping on the brX interface, just
> like any other interface of the bridge. However, currently the brX 
> interface is missing all the needed data structures to do this.
> There is no net_bridge_port structure for the brX interface. This
> strucuture is created when an interface is added to the bridge. But
> the brX interface is not a member of the bridge. So this patchset
> makes the brX interface a first class member of the bridge. When the
> brX interface is opened, the interface is added to the bridge. A 
> net_bridge_port is allocated for it, and IGMP snooping is performed
> as usual.

Would not making brX be part of the bridge have a huge negative
performance impact on locally generated traffic either? Even though we
do an early return in br_handle_frame() this may become noticeable.

> 
> There are some complexities here. Some assumptions are broken, like 
> the master interface of a port interface is the bridge interface.
> The brX interface cannot be its own master. The use of 
> netdev_master_upper_dev_get() within the bridge code has been
> changed to reflecit this. The bridge receive handler needs to not
> process frames for the brX interface, etc.
> 
> The interface downward to the hardware is also an issue. The code 
> presented here is a hack and needs to change. But that is secondary 
> and can be solved once it is agreed how the bridge needs to change
> to support this use case.
> 
> Comment welcome and wanted.

While I understand the reasons why you did it that way, I think this is
going to break a lot of code in bridge that does not expect brX to be a
bridge port member.

Maybe we can just generate switch MDB events targeting the bridge
network device and let switch drivers resolve that to whatever their
CPU/master port is?

It does sound like we are moving more and more to a model where brX
becomes one (if not the only one) net_device representor of what the
CPU/master port of a switch is (at least with DSA) which sort of makes
us go back to the multi-CPU port discussion we had a while ago.

Thanks!
-- 
Florian
