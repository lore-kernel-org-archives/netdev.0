From: Alexey Dobriyan <adobriyan@gmail.com>
Subject: Re: [PATCH 33/33] Enable netfilter in netns
Date: Thu, 2 Oct 2008 13:51:12 +0400
Message-ID: <20081002095112.GA31919@x200.localdomain>
References: <48C01046.2070704@trash.net> <1220842990-30500-33-git-send-email-adobriyan@gmail.com> <48E49068.5070305@trash.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, netfilter-devel@vger.kernel.org,
	containers@lists.linux-foundation.org
To: Patrick McHardy <kaber@trash.net>
Return-path: <netfilter-devel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <48E49068.5070305@trash.net>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, Oct 02, 2008 at 11:12:08AM +0200, Patrick McHardy wrote:
> Alexey Dobriyan wrote:
>> >From kernel perspective, allow entrance in nf_hook_slow().
>>
>> Stuff which uses nf_register_hook/nf_register_hooks, but otherwise not netns-ready:
>>
>> 	DECnet netfilter
>> 	ipt_CLUSTERIP
>> 	nf_nat_standalone.c together with XFRM (?)
>> 	IPVS
>> 	several individual match modules (like hashlimit)
>> 	ctnetlink
>> 	NOTRACK
>> 	all sorts of queueing and reporting to userspace
>> 	L3 and L4 protocol sysctls, bridge sysctls
>> 	probably something else
>>
>> Anyway critical mass has been achieved, there is no reason to hide netfilter any longer.
>>
>> >From userspace perspective, allow to manipulate all sorts of           
>>                                                                         
>>                                                                         
>>                         iptables/ip6tables/arptables rules.
>>   
>
> Applied. thanks Alexey.
>
> Is there an easy way to test all this stuff?

I used the following:

0) netns is currently mutually exclusive with sysfs, so depending on
   sanity of distro initscripts booting sysfs-less kernel can be tricky.

   In Gentoo, for example a) rm -rf /sys (sic!), b) RC_USE_FSTAB="yes",
   c) RC_DEVICES="static" in /etc/conf.d/rc are needed.

1) netns creation tool (attached, some container guy posted it somewhere)

	# ns_exec -n /bin/sh

2) shutdown network in init_net

	sudo /etc/init.d/ntpd stop
	sudo /etc/init.d/sshd stop
	sudo /etc/init.d/iptables stop
	sudo /etc/init.d/ip6tables stop
	sudo /etc/init.d/net.eth1 stop
	sudo /etc/init.d/net.eth0 stop

3) move netdevices to netns

	ip l s dev eth0 netns "$1"
	ip l s dev eth1 netns "$1"

	where $1 is PID of shell from 1)

4) in netns start everything back

	sudo /etc/init.d/net.eth0 start
	sudo /etc/init.d/net.eth1 start
	sudo /etc/init.d/iptables start
	sudo /etc/init.d/ip6tables start
	sudo /etc/init.d/sshd start
	sudo /etc/init.d/ntpd start

5) at this point my usual NAT setup is back working for me and everything should
   be like in init_net (modulo aforementioned exceptions) and
   independent from init_net.

Leaked netns are in /proc/slabinfo under "net_namespace".

Some IPv6 printks can be annoying, so mute them.

Object poisoning with SLUB won't work for irrelevant reasons, so use SLAB.

Something like that.
