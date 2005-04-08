From: Stephen Hemminger <shemminger@osdl.org>
Subject: Re: [PATCH 2.6.12-rc2 0/17] bonding: sysfs interface...
Date: Thu, 7 Apr 2005 17:09:34 -0700
Message-ID: <20050407170934.5ca77ab5@dxpl.pdx.osdl.net>
References: <Pine.LNX.4.61.0504081530560.10355@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: fubar@us.ibm.com, bonding-devel@lists.sourceforge.net, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Radheka Godse <radheka.godse@intel.com>
In-Reply-To: <Pine.LNX.4.61.0504081530560.10355@localhost.localdomain>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Fri, 8 Apr 2005 16:15:24 -0700 (PDT)
Radheka Godse <radheka.godse@intel.com> wrote:

> 
> This patch set implements the sysfs interface for bonding and has a couple 
> bug fixes. We have done a full test pass and consider these patches ready for 
> inclusion upstream. We have submitted them to bonding-devel several 
> times and have incorporated feedback and fixes all known issues.
> 
> The interface is pretty simple. Here are some notes on how it could be 
> used:
> 
>   The file /sys/class/net/bonding_masters contains the names of all the
> active bonds. To add or remove bonds, write a whitespace-delimited list of
> interface names to this file.  For example:
>  	echo "bond1 bond2 bond3" > /sys/class/net/bonding_masters
>  		will create three bonds with the given names.  If any other
>   		bonds exist, they will be deleted.
>   	echo "bond0 bond2 bond3" > /sys/class/net/bonding_masters
>   		would then create bond0 and remove bond1.
> 
>   For each bond, there is a directory /sys/class/net/<bondname>/bonding.
> In this directory are a number of files which control the bond.  The names 
> of these files match the existing module parameters and do the same things.
> 
>   The slaves file contains a whitespace-delimited list of interface names,
>   which are slaves to the bond.  This file behaves much the same as the
>   "bonding_masters" file; just write a list of your desired interfaces to 
> this file.
> 
>   Likewise, the arp_targets file contains a whitespace-delimited list of IP
>   addresses and should be written to in a similar fashion.
> 
>   The other files contain single values(numeric and/or mnemonic), except 
> for stat, which duplicates the slave information in the proc file.
> 
>   Some caveats:
>    - slaves can only be assigned when the interface is up
>    - mode can only be changed when the interface is down
> 
>   Warnings and status messages will be logged and can be viewed with dmesg.
> 
>   Example:
>   modprobe bonding
>   echo "bond0 bond1" > /sys/class/net/bonding_masters
>   echo "6" > /sys/class/net/bond0/bonding/mode
>   echo "1000" > /sys/class/net/bond0/bonding/miimon
>   ifconfig bond0 192.168.0.1
>   echo "eth0 eth1" > /sys/class/net/bond0/bonding/slaves
>   # bond0 is now ready to use
>   echo "1" > /sys/class/net/bond1/bonding/mode
>   # ... and so on for bond1
> 
> 
>   These patches apply cleanly to kernel 2.6.12-rc2.
> 
> - Mitch Williams
> - Radheka Godse

I'm not adverse to sysfs per say, but you are using like /proc with multiple values
per file.  This is not what the original design was.

Examples:

+static ssize_t bonding_show_stat(struct class_device *cd, char *buf)
+{
+	struct slave *curr;
+	int i, len = 0;
+	struct bonding *bond = to_bond(cd);
+
+	down_read(&(bonding_rwsem));
+	read_lock_bh(&bond->lock);
+	bond_for_each_slave(bond, curr, i) {
+		len += sprintf(buf + len, "\nSlave Interface: %s\n",
+			       curr->dev->name);
+		len += sprintf(buf + len, "MII Status: %s\n",
+			       (curr->link == BOND_LINK_UP) ? "up" : "down");
+		len += sprintf(buf + len, "Link Failure Count: %d\n",
+			       curr->link_failure_count);
+
+		len += sprintf(buf + len,
+			       "Permanent HW addr: %02x:%02x:%02x:%02x:%02x:%02x\n",
+			       curr->perm_hwaddr[0], curr->perm_hwaddr[1],
+			       curr->perm_hwaddr[2], curr->perm_hwaddr[3],
+			       curr->perm_hwaddr[4], curr->perm_hwaddr[5]);
+
+		if (bond->params.mode == BOND_MODE_8023AD) {
+			const struct aggregator *agg =
+				SLAVE_AD_INFO(curr).port.aggregator;
+
+			if (agg) {
+				len += sprintf(buf + len, "Aggregator ID: %d\n",
+					       agg->aggregator_identifier);
+			} else {
+				len += sprintf(buf + len,
+					       "Aggregator ID: N/A\n");
+			}
+		}

You need to break this up into symlinks and individual files with single value.
Look at bridging as an example.


Also: how do you intend to use the ABI version exported? Unless you have  a clear
plan, it is frowned upon to drop random version numbers around hoping to be able
to have compatibility.
