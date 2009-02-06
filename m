From: Konstantin Khorenko <khorenko@parallels.com>
Subject: Re: [Bugme-new] [Bug 12570] New: Bonding does
 not	work over e1000e.
Date: Fri, 06 Feb 2009 13:18:52 +0300
Message-ID: <498C0E8C.9050309@parallels.com>
References: <8DD2590731AB5D4C9DBF71A877482A900DCA8695@orsmsx509.amr.corp.intel.com>
	<EA929A9653AAE14F841771FB1DE5A1365F60321240@rrsmsx501.amr.corp.intel.com>
	<F169D4F5E1F1974DBFAFABF47F60C10A1C2C9480@orsmsx507.amr.corp.intel.com>
	<EA929A9653AAE14F841771FB1DE5A1365F60321411@rrsmsx501.amr.corp.intel.com>
	<13830B75AD5A2F42848F92269B11996F3A0F5952@orsmsx509.amr.corp.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: "e1000-devel@lists.sourceforge.net" <e1000-devel@lists.sourceforge.net>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"devel@lists.sourceforge.net" <devel@lists.sourceforge.net>,
	"bonding-devel@lists.sourceforge.net"
	<bonding-devel@lists.sourceforge.net>,
	"bugme-daemon@bugzilla.kernel.org" <bugme-daemon@bugzilla.kernel.org>
To: "Graham, David" <david.graham@intel.com>
Return-path: <e1000-devel-bounces@lists.sourceforge.net>
In-Reply-To: <13830B75AD5A2F42848F92269B11996F3A0F5952@orsmsx509.amr.corp.intel.com>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/e1000-devel>,
	<mailto:e1000-devel-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum_name=e1000-devel>
List-Post: <mailto:e1000-devel@lists.sourceforge.net>
List-Help: <mailto:e1000-devel-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/e1000-devel>,
	<mailto:e1000-devel-request@lists.sourceforge.net?subject=subscribe>
Errors-To: e1000-devel-bounces@lists.sourceforge.net
List-Id: netdev.vger.kernel.org

Hello Dave,

thank you for investigating this, i'll try to answer your questions:

> 1) ... if I don't load with module load parameter miimon=100. ... would you please confirm for me by listing exactly which bonding module params you load with.

Yes, surely, /etc/modprobe.conf contains "miimon=100" parameter for all bonding devices on the node, and you are right, if i remove "miimon=100", /proc/net/bonding/bondX will report "MII Polling Interval (ms): 0".

# cat etc/modprobe.conf
alias eth0 bnx2
alias eth1 bnx2
alias eth2 e1000e
alias eth3 e1000e
alias scsi_hostadapter cciss
alias scsi_hostadapter1 lpfc
alias scsi_hostadapter2 usb-storage

alias bond0 bonding
options bond0 miimon=100 mode=1 max_bonds=2

alias bond1 bonding
options bond1 miimon=100 mode=1

# Disable IPV6
alias net-pf-10 off
alias ipv6 off

options ip_conntrack ip_conntrack_disable_ve0=1
######################################################################

> 2) At 11:56:01 in the report you "turn on eth2 uplink on the virtual connect bay5", and I see in /proc/net/bonding/bond1 , immediately after that, eth2 still shows MII status *down*, which would be incorrect. Can you confirm that this snippet of the file really is in the correct place in the reported sequence - that is, there is already a problem at this step, and that's where we should look for the problem.

Well, yes, the order is correct and you noticed right, but:
/var/log/messages were saved on other server so there might be a bit mistiming, but estimate it:

Here is the mix of messages from console and taken from /var/log/messages:
----------
## 11:53:05 shutdown eth2 uplink on the virtual connect bay5
Jan 27 11:53:29 sdencltst01blade12 kernel: 0000:15:00.0: eth2: Link is Down

## 11:56:01 turn on eth2 uplink on the virtual connect bay5
Jan 27 11:56:37 sdencltst01blade12 kernel: 0000:15:00.0: eth2: Link is Up 1000 Mbps Full
Duplex, Flow Control: RX/TX

## 11:57:22 turn off eth3 uplink on the virtual connect bay5
Jan 27 11:57:39 sdencltst01blade12 kernel: 0000:15:00.1: eth3: Link is Down
----------
Deltas are: 24 sec, 36 sec and 17 secs. (i mean the reaction that we can see in /var/log/messages on action from console).
The thus timing is different in no more than 17 secs, then we have: 7 secs, 19 secs and 0 secs deltas.

Well, may be 7 and 19 secs for link detection is too much, but i cannot blame for that, it works at least.
But surely if you think this is a problem, let's also focus on it. (BTW, RHEL5 kernel does not provide correct link status at all, e.g. /proc/net/bonding/bond1 still shows eth2's mii status is UP if we unplug eth2 link.)


> 3) .../etc/sysconfig/networking-scripts/ifcfg-*....
ifcfg-eth2:

DEVICE=eth2
BOOTPROTO=none
ONBOOT=yes
MASTER=bond1
SLAVE=yes
USERCTR=no
HWADDR=00:1E:0B:93:D2:E2

ifcfg-bond1:

DEVICE=bond1
BOOTPROTO=none
ONBOOT=yes
USERCTL=no
IPADDR=xxx
NETMASK=xxx
GATEWAY=xxx

4) physical links managing

HP C7000 blade system with the Virtual Connect switch modules for the server's uplink is used.
The Onboard Administrator for the C7000 is used to power off the switch to simulate the uplink failure for this test.
Yes, the powering off switches off all links connected to the switch, but network cards are connected to different switches - thus we can disconnect links one by one.

> 5) ... if you have *ever* seen bonding work properly on the system you are testing.

Yes, we've seen. The node has 2 Broadcom network cards (eth0 and eth1) which are in bond0 the same node - bonding works fine there.
Ethernet controller: Broadcom Corporation NetXtreme II BCM5708S Gigabit Ethernet (rev 12)
0200: 14e4:16ac (rev 12)
        Subsystem: 103c:703b

6) test kernel with additional patches.
Thank you for the patches, i'll let you know as soon as the kernel with them will be tested.

Thank you!

-- 
Best regards,

Konstantin Khorenko,
Virtuozzo/OpenVZ developer,
Parallels

On 02/03/2009 04:42 AM, Graham, David wrote:
> Hi Konstantin. 
> 
> I have been trying but so far been failed to reproduce the reported problem. 
> I have a few questions.
> 
> 1) While I can't repro your problem, I can see something very similar if I don't load with module load parameter miimon=100. From your /proc/net/bonding/bond1 dumps it looks like you do the right thing, but would you please confirm for me by listing exactly which bonding module params you load with. 
> 
> 2) At 11:56:01 in the report you "turn on eth2 uplink on the virtual connect bay5", and I see in /proc/net/bonding/bond1 , immediately after that, eth2 still shows MII status *down*, which would be incorrect. Can you confirm that this snippet of the file really is in the correct place in the reported sequence - that is, there is already a problem at this step, and that's where we should look for the problem. 
> 
> 3) Could you send me your network scripts for the two slaves and the bonding interface itself (on RH systems, I think that's /etc/sysconfig/networking-scripts/ifcfg-*. They should be modeled on the sample info in <kernel>Documentation/networking/bonding.txt, and I'd like to check them.
> 
> 4) I'm probably not controlling the slave link state in the same way that you are, because in the NEC bladeserver that I'm using, I am bringing the e1000e link-partern ports up & down by using an admins console, using SW I don't understand. I (so far) have not been able to physically disconnect one of the (serdes) links connecting the 82571 without also disconnecting the other, as I have to pull an entire switch module to make the disconnect. Can you give me mmore information on what your system is, and how you can physically disconnect  on link at a time. Then I might be able to get hold of a similar setup and see the problem.
> 
> 5) I have been testing on 2.6.29-rc3 and on 2.6.28 kernels, not 2.6.29-rc1 which is what you reported the problem on. I think its unlikely that the problem is only on the 2.6.29-rc1 build, but would like to know if you've had a chance to try any other build, and what the results were. Also please let me know if you have tested with any other non-INTEL 1GB interfaces, and if you have *ever* seen bonding work properly on the system you are testing. 
> 
> 6) While I can't repro your issue yet, I have made some changes very recently to the serdes link detect logic in the e1000e driver. They were written to address a separate issue, and are actually NOT in the kernel that you have been testing. I also can't see how fixing that problem might fix your problem. However, because the fixes do concern serdes link detection, and so does yours, it's probably worth a (long) shot. If you are comfortable trying them out, I have attached them to this email. They are also being queued for upstream, but only after some further local testing.
>  
> Thanks
> Dave

------------------------------------------------------------------------------
Create and Deploy Rich Internet Apps outside the browser with Adobe(R)AIR(TM)
software. With Adobe AIR, Ajax developers can use existing skills and code to
build responsive, highly engaging applications that combine the power of local
resources and data with the reach of the web. Download the Adobe AIR SDK and
Ajax docs to start building applications today-http://p.sf.net/sfu/adobe-com
