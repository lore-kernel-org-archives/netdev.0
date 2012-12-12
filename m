From: Peter Hurley <peter@hurleysoftware.com>
Subject: Re: netconsole fun
Date: Wed, 12 Dec 2012 15:59:17 -0500
Message-ID: <1355345957.2687.18.camel@thor>
References: <1355149033.3142.14.camel@thor> <ka6e4e$6k5$1@ger.gmane.org>
	 <1355235592.2694.5.camel@thor>
	 <20121211143004.GA7481@neilslaptop.think-freely.org>
	 <1355239011.2694.24.camel@thor>
	 <20121211164526.GB7481@neilslaptop.think-freely.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Cong Wang <xiyou.wangcong@gmail.com>, netdev@vger.kernel.org
To: Neil Horman <nhorman@tuxdriver.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailout39.mail01.mtsvc.net ([216.70.64.83]:57402 "EHLO
	n12.mail01.mtsvc.net" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1754914Ab2LLU7g (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 12 Dec 2012 15:59:36 -0500
In-Reply-To: <20121211164526.GB7481@neilslaptop.think-freely.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2012-12-11 at 11:45 -0500, Neil Horman wrote:
> On Tue, Dec 11, 2012 at 10:16:51AM -0500, Peter Hurley wrote:
> > On Tue, 2012-12-11 at 09:30 -0500, Neil Horman wrote:
> > > On Tue, Dec 11, 2012 at 09:19:52AM -0500, Peter Hurley wrote:
> > > > On Tue, 2012-12-11 at 04:51 +0000, Cong Wang wrote:
> > > > > On Mon, 10 Dec 2012 at 14:17 GMT, Peter Hurley <peter@hurleysoftware.com> wrote:
> > > > > > Now that netpoll has been disabled for slaved devices, is there a
> > > > > > recommended method of running netconsole on a machine that has a slaved
> > > > > > device?
> > > > > >
> > > > > 
> > > > > Yes, running it on the master device instead.
> > > > 
> > > > Thanks for the suggestion, but:
> > > > 
> > > > [ 0.000000] Kernel command line: BOOT_IMAGE=/boot/vmlinuz-3.7.0-rc8-xeon ...... netconsole=@192.168.10.99/br0,30000@192.168.10.100/xx:xx:xx:xx:xx:xx
> > > > ...
> > > > [ 5.289869] netpoll: netconsole: local port 6665
> > > > [ 5.289885] netpoll: netconsole: local IP 192.168.10.99
> > > > [ 5.289892] netpoll: netconsole: interface 'br0'
> > > > [ 5.289898] netpoll: netconsole: remote port 30000
> > > > [ 5.289907] netpoll: netconsole: remote IP 192.168.10.100
> > > > [ 5.289914] netpoll: netconsole: remote ethernet address xx:xx:xx:xx:xx:xx
> > > > [ 5.289922] netpoll: netconsole: br0 doesn't exist, aborting
> > > > [ 5.289929] netconsole: cleaning up
> > > > ...
> > > > [ 9.392291] Bridge firewalling registered
> > > > [ 9.396805] device eth1 entered promiscuous mode
> > > > [ 9.418350] eth1:  setting full-duplex.
> > > > [ 9.421268] br0: port 1(eth1) entered forwarding state
> > > > [ 9.423354] br0: port 1(eth1) entered forwarding state
> > > > 
> > > > 
> > > > Is there a way to control or associate network device names prior to
> > > > udev renaming?
> > > > 
> > > That looks like a systemd problem (or more specifically a boot dependency
> > > problem).  You need to modify your netconsole unit/service file to start after
> > > all your networking is up.  NetworkManager provides a dummy service file for
> > > this purpose, called networkmanager-wait-online.service
> > 
> > Ok. So with a single physical network interface that will be bridged,
> > netconsole cannot used for kernel boot messages.
> > 
> > With a machine with multiple nics, is there a way to control device
> > naming so that the interface name to be used by netconsole specified on
> > the boot command line will actually corresponding to the intended
> > device. For example,
> > 
> > [ 0.000000] Kernel command line: BOOT_IMAGE=/boot/vmlinuz-3.7.0-rc8-xeon ...... netconsole=@192.168.1.123/eth0,30000@192.168.1.139/xx:xx:xx:xx:xx:xx
> > ....
> > [ 4.092184] 3c59x: Donald Becker and others.
> > [ 4.092204] 0000:07:05.0: 3Com PCI 3c905C Tornado at ffffc9000186cf80.
> > [ 4.094035] tg3.c:v3.125 (September 26, 2012)
> > ....
> > [ 4.125038] tg3 0000:08:00.0 eth1: Tigon3 [partno(BCM95754) rev b002] (PCI Express) MAC address xx:xx:xx:xx:xx:xx
> > [ 4.125055] tg3 0000:08:00.0 eth1: attached PHY is 5787 (10/100/1000Base-T Ethernet) (WireSpeed[1], EEE[0])
> > [ 4.125062] tg3 0000:08:00.0 eth1: RXcsums[1] LinkChgREG[0] MIirq[0] ASF[0] TSOcap[1]
> > [ 4.125068] tg3 0000:08:00.0 eth1: dma_rwctrl[76180000] dma_mask[64-bit]
> > 
> > This is attaching netconsole to the wrong device because bus
> > enumeration, and therefore load order, is not consistent from boot to
> > boot.
> > 
> No, theres no way to do that.  As you note device ennumeration isn't consistent
> accross boots, thats why udev creates rules to rename devices based on immutable
> (or semi-immutable) data, like mac addresses, or pci bus locations).  Once that
> happens, you'll have consistent names for your interfaces, and that work will be
> guaranteed to be done after networkmanager has finished opening all the
> interfaces that it needs (hence my suggestion to make netconsole service
> dependent on networkmanager service startup completing).

Just wondering if you think something like the patch below is
suitable/acceptable for insulating netconsole from inconsistent device
name scenarios without changing the existing semantics. The basic idea
is to allow an ethernet MAC address in the <dev> field of the
netconsole= options, and if a MAC address was specified rather than a
device name, to do the dev lookup from the MAC address instead.

This doesn't extend to, but also doesn't interfere with, the dynamic
config of netconsole via configfs.

Would you mind reviewing it?

Regards,
Peter

-- >% --
Subject: [PATCH] netconsole: allow mac addr to specify local interface device

Allow the local interface device to be specified by ethernet
MAC address. For example,

  netconsole=@10.0.0.1/12:34:56:78:9a:bc,30000@10.0.0.3/cb:a9:87:65:43:21

This alternate form enables netconsole to start and log boot messages
even if the network device name varies (eg., a machine with multiple NICs).

Signed-off-by: Peter Hurley <peter@hurleysoftware.com>
---
 Documentation/networking/netconsole.txt |  9 +++++++--
 drivers/net/netconsole.c                |  2 ++
 include/linux/netpoll.h                 |  1 +
 net/core/netpoll.c                      | 19 +++++++++++++++++--
 4 files changed, 27 insertions(+), 4 deletions(-)

diff --git a/Documentation/networking/netconsole.txt b/Documentation/networking/netconsole.txt
index 2e9e0ae2..2dfd703 100644
--- a/Documentation/networking/netconsole.txt
+++ b/Documentation/networking/netconsole.txt
@@ -23,12 +23,13 @@ Sender and receiver configuration:
 It takes a string configuration parameter "netconsole" in the
 following format:
 
- netconsole=[src-port]@[src-ip]/[<dev>],[tgt-port]@<tgt-ip>/[tgt-macaddr]
+ netconsole=[src-port]@[src-ip]/[dev|macaddr],[tgt-port]@<tgt-ip>/[tgt-macaddr]
 
    where
         src-port      source for UDP packets (defaults to 6665)
         src-ip        source IP to use (interface address)
-        dev           network interface (eth0)
+        dev|macaddr   network interface (eth0)
+		      alternate: ethernet MAC address of network interface
         tgt-port      port for logging agent (6666)
         tgt-ip        IP address for logging agent
         tgt-macaddr   ethernet MAC address for logging agent (broadcast)
@@ -47,6 +48,10 @@ complete string enclosed in "quotes", thusly:
 
  modprobe netconsole netconsole="@/,@10.0.0.2/;@/eth1,6892@10.0.0.3/"
 
+The alternate form for specifying the local network interface with the
+ethernet MAC address is useful when the device names are inconsistent from
+boot to boot (eg., if the machine has multiple NICs).
+
 Built-in netconsole starts immediately after the TCP stack is
 initialized and attempts to bring up the supplied dev at the supplied
 address.
diff --git a/drivers/net/netconsole.c b/drivers/net/netconsole.c
index 6989ebe..3808a31 100644
--- a/drivers/net/netconsole.c
+++ b/drivers/net/netconsole.c
@@ -180,6 +180,7 @@ static struct netconsole_target *alloc_param_target(char *target_config)
 	strlcpy(nt->np.dev_name, "eth0", IFNAMSIZ);
 	nt->np.local_port = 6665;
 	nt->np.remote_port = 6666;
+	memset(nt->np.local_mac, 0, ETH_ALEN);
 	memset(nt->np.remote_mac, 0xff, ETH_ALEN);
 
 	/* Parse parameters and setup netpoll */
@@ -560,6 +561,7 @@ static struct config_item *make_netconsole_target(struct config_group *group,
 	strlcpy(nt->np.dev_name, "eth0", IFNAMSIZ);
 	nt->np.local_port = 6665;
 	nt->np.remote_port = 6666;
+	memset(nt->np.local_mac, 0, ETH_ALEN);
 	memset(nt->np.remote_mac, 0xff, ETH_ALEN);
 
 	/* Initialize the config_item member */
diff --git a/include/linux/netpoll.h b/include/linux/netpoll.h
index 66d5379..d646b26 100644
--- a/include/linux/netpoll.h
+++ b/include/linux/netpoll.h
@@ -20,6 +20,7 @@ struct netpoll {
 
 	__be32 local_ip, remote_ip;
 	u16 local_port, remote_port;
+	u8 local_mac[ETH_ALEN];
 	u8 remote_mac[ETH_ALEN];
 
 	struct list_head rx; /* rx_np list element */
diff --git a/net/core/netpoll.c b/net/core/netpoll.c
index 77a0388..8910a95 100644
--- a/net/core/netpoll.c
+++ b/net/core/netpoll.c
@@ -660,6 +660,7 @@ void netpoll_print_options(struct netpoll *np)
 	np_info(np, "local port %d\n", np->local_port);
 	np_info(np, "local IP %pI4\n", &np->local_ip);
 	np_info(np, "interface '%s'\n", np->dev_name);
+	np_info(np, "local ethernet address %pM\n", np->local_mac);
 	np_info(np, "remote port %d\n", np->remote_port);
 	np_info(np, "remote IP %pI4\n", &np->remote_ip);
 	np_info(np, "remote ethernet address %pM\n", np->remote_mac);
@@ -693,7 +694,8 @@ int netpoll_parse_options(struct netpoll *np, char *opt)
 		if ((delim = strchr(cur, ',')) == NULL)
 			goto parse_failed;
 		*delim = 0;
-		strlcpy(np->dev_name, cur, sizeof(np->dev_name));
+		if (!mac_pton(cur, np->local_mac))
+			strlcpy(np->dev_name, cur, sizeof(np->dev_name));
 		cur = delim;
 	}
 	cur++;
@@ -806,8 +808,21 @@ int netpoll_setup(struct netpoll *np)
 	struct in_device *in_dev;
 	int err;
 
-	if (np->dev_name)
+	if (!is_zero_ether_addr(np->local_mac)) {
+		rcu_read_lock();
+		ndev = dev_getbyhwaddr_rcu(&init_net, ARPHRD_ETHER, np->local_mac);
+		if (!ndev) {
+			rcu_read_unlock();
+			np_err(np, "%pM doesn't exist, aborting\n", np->local_mac);
+			return -ENODEV;
+		}
+		dev_hold(ndev);
+		rcu_read_unlock();
+		strlcpy(np->dev_name, ndev->name, IFNAMSIZ);
+
+	} else if (np->dev_name)
 		ndev = dev_get_by_name(&init_net, np->dev_name);
+
 	if (!ndev) {
 		np_err(np, "%s doesn't exist, aborting\n", np->dev_name);
 		return -ENODEV;
-- 
1.8.0.1
