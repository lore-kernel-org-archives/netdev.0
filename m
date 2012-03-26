From: "Rose, Gregory V" <gregory.v.rose@intel.com>
Subject: RE: iproute2 does not enumerate vf's properly (ixgbe)
Date: Mon, 26 Mar 2012 15:56:41 +0000
Message-ID: <C5551D9AAB213A418B7FD5E4A6F30A0702FD6FDC@ORSMSX106.amr.corp.intel.com>
References: <89EBE686-6625-428C-8CCB-6A8E8B8162A8@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
To: Scott <ph3lpz@gmail.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga01.intel.com ([192.55.52.88]:38465 "EHLO mga01.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932568Ab2CZP4s convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 26 Mar 2012 11:56:48 -0400
In-Reply-To: <89EBE686-6625-428C-8CCB-6A8E8B8162A8@gmail.com>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> -----Original Message-----
> From: netdev-owner@vger.kernel.org [mailto:netdev-owner@vger.kernel.org]
> On Behalf Of Scott
> Sent: Saturday, March 24, 2012 6:44 AM
> To: netdev@vger.kernel.org
> Subject: iproute2 does not enumerate vf's properly (ixgbe)
> 
> When loading the module ixgbe with sr-iov enabled (max_vfs), enumeration
> of the interfaces' VFs is inconsistent using the iproute2 utility.
> 
> Server Information:HP Product Name: ProLiant DL165 G7 Ethernet Card
> Information: Intel 82599EB 10-Gigabit SFI/SFP+
> uname: Linux 3.0.0-16-server x86_64 GNU/Linux OS Release: Ubuntu 11.10

This was a longstanding bug that has since been fixed.  About 40 VFs was the approximate cut off due to buffer allocation issues in the netlink interface.  You'll probably need to upgrade your kernel or else backport the patches into your current kernel.

- Greg

> 
> 
> Using a freshly compiled git pull:
> # ./ip -V
> ip utility, iproute2-ss120319
> 
> Steps to reproduce:
> 
> 1. Determine the ethernet interface IDs:
> # dmesg |grep ixgbe\ 0000:05:00.[0-9].*detected|head -n 2
> [    8.448031] ixgbe 0000:05:00.0: eth4: detected SFP+: 5
> [    8.816035] ixgbe 0000:05:00.1: eth5: detected SFP+: 6
> 
> 2. Load the module w/40 VFs:
> # modprobe ixgbe max_vfs=40
> 
> 3. Sanity checks:
> # lsmod |grep ixgbe
> ixgbe                 206156  0
> dca                    15179  2 ixgbe,igb
> 
> # modinfo ixgbe|grep version
> version:        3.6.7-NAPI
> srcversion:     119ADBD2B16B0E40668FB9A
> vermagic:       3.0.0-16-server SMP mod_unload modversions
> (this is the latest too)
> 
> # lspci |grep 05:1[0-9]|perl -lane 'delete @F[1,2,3,4,10,11];print "@F"'
> 05:10.0     82599 Ethernet Controller Virtual Function
> 05:10.2     82599 Ethernet Controller Virtual Function
> 05:10.4     82599 Ethernet Controller Virtual Function
> 05:10.6     82599 Ethernet Controller Virtual Function
> 05:11.0     82599 Ethernet Controller Virtual Function
> (suppressing output of all 40 VFs)
> 
> # lspci |grep 05:1[0-9]|wc -l
> 40
> (showing that there are actually 40)
> 
> # ls -l /sys/class/net/eth4/device/|grep virt|awk '{print $10"
> "$8}'|sort|head -5
> ../0000:05:10.0 virtfn0
> ../0000:05:10.2 virtfn1
> ../0000:05:10.4 virtfn2
> ../0000:05:10.6 virtfn3
> ../0000:05:11.0 virtfn4
> (suppressing output of all 40 VFs)
> 
> 5. Run ip link show:
> # ./ip link show|grep -e eth[45] -e vf
> (null output!)
> 
> 6. Load the module with fewer VFs
> # rmmod ixgbe
> # modprobe ixgbe max_vfs=5
> # lspci |grep 05:1[0-9]|perl -lane 'delete @F[1,2,3,4,10,11];print "@F"'
> 05:10.0     82599 Ethernet Controller Virtual Function
> 05:10.2     82599 Ethernet Controller Virtual Function
> 05:10.4     82599 Ethernet Controller Virtual Function
> 05:10.6     82599 Ethernet Controller Virtual Function
> 05:11.0     82599 Ethernet Controller Virtual Function
> 
> # ls -l /sys/class/net/eth4/device/|grep virt|awk '{print $10" "$8}'|sort
> ../0000:05:10.0 virtfn0
> ../0000:05:10.2 virtfn1
> ../0000:05:10.4 virtfn2
> ../0000:05:10.6 virtfn3
> ../0000:05:11.0 virtfn4
> 
> 7. Run ip link show
> # ./ip link show|grep -e eth[45] -e vf
> 57: eth4: <BROADCAST,MULTICAST> mtu 1500 qdisc noop state DOWN mode
> DEFAULT qlen 1000
>     vf 0 MAC 52:a0:59:03:20:a8
>     vf 1 MAC 82:5f:55:a5:1f:be
>     vf 2 MAC 0a:ab:86:0c:02:b3
>     vf 3 MAC 22:a7:28:ce:9c:23
>     vf 4 MAC 26:ea:6c:1b:ca:57
> 58: eth5: <BROADCAST,MULTICAST> mtu 1500 qdisc noop state DOWN mode
> DEFAULT qlen 1000 (no vfs displayed for eth5!)
> 
> Patrick Kutch over at Intel suggested that there may be a patch to fix
> this problem, but I was not able to locate it.
> http://communities.intel.com/thread/28411?tstart=0
> 
> There is also Launchpad bug #960497 for this issue.
> 
> Thanks in advance for any suggestions.
> 
> -SP--
> To unsubscribe from this list: send the line "unsubscribe netdev" in the
> body of a message to majordomo@vger.kernel.org More majordomo info at
> http://vger.kernel.org/majordomo-info.html
