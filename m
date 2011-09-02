From: Ang Way Chuang <wcang@sfc.wide.ad.jp>
Subject: Re: commit 1faa4356 breaks IPv6 assignment on libvirtd
Date: Fri, 02 Sep 2011 14:57:36 +0900
Message-ID: <4E607050.5030401@sfc.wide.ad.jp>
References: <4E5F99E2.50301@sfc.wide.ad.jp> <20110901085126.76cdda54@nehalam.ftrdhcpuser.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, Achmad Basuki <abazh@sfc.wide.ad.jp>
To: Stephen Hemminger <shemminger@vyatta.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from shonan.sfc.wide.ad.jp ([203.178.142.130]:43630 "EHLO
	mail.sfc.wide.ad.jp" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1753327Ab1IBF5j (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 2 Sep 2011 01:57:39 -0400
In-Reply-To: <20110901085126.76cdda54@nehalam.ftrdhcpuser.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 02/09/11 00:51, Stephen Hemminger wrote:
> On Thu, 01 Sep 2011 23:42:42 +0900
> Ang Way Chuang <wcang@sfc.wide.ad.jp> wrote:
>
>> Hi all,
>>
>>    Commit 1faa4356 break IPv6 assignment on libvirtd. The configuration for my VM bridge network is as such:
>>
>> <network>
>>   <name>default</name>
>>   <forward mode='nat'/>
>>   <bridge name='virbr0' stp='on' delay='0' />
>>   <ip address='192.168.122.1' netmask='255.255.255.0'>
>>     <dhcp>
>>       <range start='192.168.122.2' end='192.168.122.254' />
>>     </dhcp>
>>   </ip>
>>   <ip family='ipv6' address='2001:d30:113:504::1' prefix='64'>
>>   </ip>
>> </network>
>>
>>     This configuration worked fine on kernel 2.6.38. Updating my distro kernel broke the setup. My colleague 
>> and I traced the problem and found that libvirtd failed because there wasn't any carrier on virbr0 interface 
>> due to the change introduced by that commit. How can this be fixed? Thanks in advance.
>>
>> Regards,
>> Ang Way Chuang
> The issue is that address is assigned to a bridge device with no ports.
> IPv6 needs carrier to do duplicate address detection. Without any ports
> the DAD will always succeed, and there is a possibility that when ports
> are later added to the bridge the address actually is a duplicate.
>
> A couple of possible options are:
> 1. Default to carrier on in bridge when there are no ports.
>    The downside with this is that IPv6 DAD is being fooled.
I understand the point you raised. I think the same address duplication issue
is possible with IPv4. But any fix shouldn't break user space application.
>
> 2. Change libvirt to allow turning off DAD. This is controlled
>    in kernel by writing 0 to /proc/sys/net/ipv6/conf/virbr0/accept_dad
This won't fix the problem.

Here is the full analysis of the event from my observation, but please take it with
a grain of salt because I don't understand the internal of libvirtd.

# virsh net-start default
would create virbr0 with IPv6 address assigned, but with no carrier. dnsmasq would be called
with the following arguments.

/usr/sbin/dnsmasq --strict-order --bind-interfaces --pid-file=/var/run/libvirt/network/default.pid --conf-file=  --except-interface lo --listen-address 192.168.122.1 --listen-address 2001:d30:113:504::1 --dhcp-range 192.168.122.2,192.168.122.254 --dhcp-lease-max=253 --dhcp-no-override

Attempts from dnsmasq to bind to IPv6 failed. Here is the abridged version of strace output
from dnsmasq:

socket(PF_INET6, SOCK_DGRAM, IPPROTO_IP) = 7
setsockopt(7, SOL_SOCKET, SO_REUSEADDR, [1], 4) = 0
fcntl(7, F_GETFL)                       = 0x2 (flags O_RDWR)
fcntl(7, F_SETFL, O_RDWR|O_NONBLOCK)    = 0
setsockopt(7, SOL_IPV6, IPV6_V6ONLY, [1], 4) = 0
bind(7, {sa_family=AF_INET6, sin6_port=htons(53), inet_pton(AF_INET6, "2001:d30:113:555::1", &sin6_addr), sin6_flowinfo=0, sin6_scope_id=11}, 28) = -1 EADDRNOTAVAIL (Cannot assign requested address)

I am not sure why bind failed in this case. When dnsmasq failed to bind, virsh took down virbr0 and exit.

1. Is that the correct behaviour? Maybe modifying the code that deals with bind can resolve this problem, but
     will it cause any other problem?
2. If option 1 is too troublesome, maybe carrier should be turn on for bridge vif by default.


Regards,
Ang Way Chuang
