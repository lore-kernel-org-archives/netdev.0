From: <Narendra_K@Dell.com>
Subject: RE: PATCH: Network Device Naming mechanism and policy
Date: Wed, 4 Nov 2009 19:53:38 +0530
Message-ID: <EDA0A4495861324DA2618B4C45DCB3EE5896D2@blrx3m08.blr.amer.dell.com>
References: <EDA0A4495861324DA2618B4C45DCB3EE5894ED@blrx3m08.blr.amer.dell.com> <20091009140000.GA18765@mock.linuxdev.us.dell.com> <20091013150839.GD32107@ldl.fc.hp.com> <EDA0A4495861324DA2618B4C45DCB3EE58954D@blrx3m08.blr.amer.dell.com> <20091013173638.GE1119@ldl.fc.hp.com> <20091016003245.GD29672@ldl.fc.hp.com> <EDA0A4495861324DA2618B4C45DCB3EE589579@blrx3m08.blr.amer.dell.com> <20091016152053.GA9862@ldl.fc.hp.com> <1255707193.2869.12.camel@achroite> <20091016214024.GA10091@ldl.fc.hp.com> <EDA0A4495861324DA2618B4C45DCB3EE5895AF@blrx3m08.blr.amer.dell.com> <4ADC906E.2050909@kadzban.is-a-geek.net>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: <dannf@hp.com>, <bhutchings@solarflare.com>,
	<netdev@vger.kernel.org>, <linux-hotplug@vger.kernel.org>,
	<Matt_Domsch@Dell.com>, <Jordan_Hargrave@Dell.com>,
	<Charles_Rose@Dell.com>, <Sandeep_K_Shandilya@Dell.com>
To: <bryan@kadzban.is-a-geek.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ausc60pc101.us.dell.com ([143.166.85.206]:48905 "EHLO
	ausc60pc101.us.dell.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755918AbZKDOXh convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 4 Nov 2009 09:23:37 -0500
Content-class: urn:content-classes:message
In-Reply-To: <4ADC906E.2050909@kadzban.is-a-geek.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


>>> Matt, Ben and I talked about a few other possibilities on IRC. The 
>>> one I like the most at the moment is an idea Ben had to creat dummy 
>>> files named after the ifindex. Then, use symlinks for the 
>kernel name 
>>> and the various by-$property subdirectories. This means the KOBJ 
>>> events will need to expose the ifindex.
>>> 
>> 
>> I suppose the KOBJ events already expose the ifindex of a network 
>> interface. The file "/sys/class/net/ethN/uevent" contains 
>> INTERFACE=ethN and IFINDEX=n already. But it looks like udev doesn't 
>> use it in any way.
>
>Right; it could simply do the equivalent of:
>
>touch /dev/netdev/$env{IFINDEX}
>
>instead of its normal mknod(2), and then do normal SYMLINK processing.
>That last part is what would link 
>/dev/netdev/by-name/$env{INTERFACE} to that device, along with 
>/dev/netdev/by-mac/*, /dev/netdev/by-path/*, etc., etc., in as 
>many different ways as people want to add rules.
>
>(Or /dev/net/by-* instead of netdev; I'm mostly ambivalent 
>about the first-level directory under /dev.  Looks like 
>libnetdevname requires /dev/netdev though.)
>
>> For example, with the kernel patch the "/sys/class/net/ethN/uevent" 
>> contains in addition to the above details, MAJOR=M and MINOR=m which 
>> the udev knows how to make use of with a rule like
>> 
>> SUBSYSTEM=="net", KERNEL!="tun", NAME="netdev/%k", MODE="0600".
>
>And if the only point is to get the ifindex via stat(2) on the 
>resulting symlinks, but people don't like device files, then 
>why not get the ifindex via readlink(2) (and a bit of string 
>parsing, and a strtol(3) or
>strtoul(3) call) instead?  :-)


I suppose this issue can also be addressed in another way. Currently,
the sysfs contains various attributes of a network interface under the
directory "/sys/class/net/ethN", for example
"/sys/class/net/ethN/address". This will be used by udev as below -

SUBSYSTEM=="net", ACTION=="add", DRIVERS=="?*",
ATTR{address}=="00:1d:09:6a:78:ec", ATTR{type}=="1", KERNEL=="eth*",
NAME="eth1".

Similarly, export an attribute named "smbios_name" to sysfs, i.e
"/sys/class/net/eth0/smbios_name". "Cat /sys/class/net/eth0/smbios_name"
would show "Embedded_NIC_1[23..]" and this can be used by udev in
70-persistent-net.rules as 

SUBSYSTEM=="net", ACTION=="add", DRIVERS=="?*",
ATTR{smbios_name}=="Embedded_NIC_1", ATTR{type}=="1", KERNEL=="eth*",
NAME="eth0".

I suppose this would not need any changes to the udev code and existing
udev infrastructure can be used as udev is capable handling
ATTR{something}.

This would also ensure that whichever device is "Embedded_NIC_1" as per
the BIOS, will also be "eth0" in the os.

Netdev, What are your views on this idea ?

With regards,
Narendra K  
