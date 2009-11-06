From: "Domsch, Matt" <Matt_Domsch@Dell.com>
Subject: Re: PATCH: Network Device Naming mechanism and policy
Date: Fri, 6 Nov 2009 16:05:09 -0600
Message-ID: <20091106220509.GA15533@mock.linuxdev.us.dell.com>
References: <EDA0A4495861324DA2618B4C45DCB3EE58954D@blrx3m08.blr.amer.dell.com> <20091013173638.GE1119@ldl.fc.hp.com> <20091016003245.GD29672@ldl.fc.hp.com> <EDA0A4495861324DA2618B4C45DCB3EE589579@blrx3m08.blr.amer.dell.com> <20091016152053.GA9862@ldl.fc.hp.com> <1255707193.2869.12.camel@achroite> <20091016214024.GA10091@ldl.fc.hp.com> <EDA0A4495861324DA2618B4C45DCB3EE5895AF@blrx3m08.blr.amer.dell.com> <4ADC906E.2050909@kadzban.is-a-geek.net> <EDA0A4495861324DA2618B4C45DCB3EE5896D2@blrx3m08.blr.amer.dell.com>
Reply-To: Matt Domsch <Matt_Domsch@Dell.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Bryan Kadzban <bryan@kadzban.is-a-geek.net>, dannf@hp.com,
	bhutchings@solarflare.com, netdev@vger.kernel.org,
	linux-hotplug@vger.kernel.org,
	"Hargrave, Jordan" <Jordan_Hargrave@Dell.com>,
	"Rose, Charles" <Charles_Rose@Dell.com>,
	"Shandilya, Sandeep K" <Sandeep_K_Shandilya@Dell.com>
To: "K, Narendra" <Narendra_K@Dell.com>
Return-path: <linux-hotplug-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <EDA0A4495861324DA2618B4C45DCB3EE5896D2@blrx3m08.blr.amer.dell.com>
Sender: linux-hotplug-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, Nov 04, 2009 at 08:23:38AM -0600, K, Narendra wrote:
> Similarly, export an attribute named "smbios_name" to sysfs, i.e
> "/sys/class/net/eth0/smbios_name". "Cat /sys/class/net/eth0/smbios_name"
> would show "Embedded_NIC_1[23..]" and this can be used by udev in
> 70-persistent-net.rules as 
> 
> SUBSYSTEM=="net", ACTION=="add", DRIVERS=="?*",
> ATTR{smbios_name}=="Embedded_NIC_1", ATTR{type}=="1", KERNEL=="eth*",
> NAME="eth0".
> 
> I suppose this would not need any changes to the udev code and existing
> udev infrastructure can be used as udev is capable handling
> ATTR{something}.
> 
> This would also ensure that whichever device is "Embedded_NIC_1" as per
> the BIOS, will also be "eth0" in the os.

We can grab the smbios_name value using biosdevname in a PROGRAM= part
of the udev rule.  But it doesn't actually solve the problem.  We
haven't changed the network device naming scheme from "eth%d" to
something else.  Therefore, by having rules which simply try to
re-order names within that scheme, when they're being enumerated in
parallel and racing, we get collisions.  Take for example, this which
tries to rename the 4 onboard NICs in a particular order, in the
absence of any other rules:

PROGRAM="/sbin/biosdevname --policy=smbios_names -i %k", RESULT=="Embedded NIC 1", NAME="eth0"
PROGRAM="/sbin/biosdevname --policy=smbios_names -i %k", RESULT=="Embedded NIC 2", NAME="eth1"
PROGRAM="/sbin/biosdevname --policy=smbios_names -i %k", RESULT=="Embedded NIC 3", NAME="eth2"
PROGRAM="/sbin/biosdevname --policy=smbios_names -i %k", RESULT=="Embedded NIC 4", NAME="eth3"

I wind up with instead this in ifconfig -a:

eth0        00:1B:21:42:66:30  
eth1        00:1B:21:42:66:31  
eth2        00:22:19:59:8E:5A  
eth2_rename 00:22:19:59:8E:56  
eth3        00:22:19:59:8E:5C  
eth3_rename 00:22:19:59:8E:58  

When what I would have expected would have been:

eth0 00:22:19:59:8E:56
eth1 00:22:19:59:8E:58
eth2 00:22:19:59:8E:5A
eth3 00:22:19:59:8E:5C
eth4 00:1B:21:42:66:30  
eth5 00:1B:21:42:66:31  


I can't use eth%d as the scheme - that's the kernel's scheme.  I have
to switch the scheme to something else.


-- 
Matt Domsch
Technology Strategist, Dell Office of the CTO
linux.dell.com & www.dell.com/linux
