From: Patrick McHardy <kaber@trash.net>
Subject: Re: DNAT sporadically doesn't replace destination IP address
Date: Thu, 22 May 2008 16:57:04 +0200
Message-ID: <483589C0.4080006@trash.net>
References: <4835A03D.B932.00FE.0@newtec.eu>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, Ulrik De Bie <ulrik.debie@newtec.eu>,
	Netfilter Development Mailinglist
	<netfilter-devel@vger.kernel.org>
To: Kris Op de Beeck <kris.op.de.beeck@newtec.eu>
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <4835A03D.B932.00FE.0@newtec.eu>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Kris Op de Beeck wrote:
> * Problem:
> The replacing of the destination IP address doesn't occur always.  I've got a PC on which I run a program which retrieves web pages of 30 modems which all have the same IP address.  In order to do this I created the configuration as listed below.  For the program the IP addresses will be 10.9.9.1 to 10.9.9.30.  Those will be send out on a specific VLAN and the IP address will be replaced by 192.168.1.1.  A number of times I get a 'no route to host' for those web pages, this happens sporadically.  If I start looking at the ARP messages, I see that when it goes wrong an ARP message is send out for an 10.9.9.x address which shouldn't be the case.
> On an older setup I didn't  had this problem, so I downgraded the kernel version from 2.6.22-14-generic to 2.6.17-12-generic on the setup where I had the problem.  
> With this downgraded kernel the problem didn't occur anymore. 
> The distro is Ubuntu. An upgrade to Ubuntu 8.04 which has kernel 2.6.24 didn't solve the problem.
> 
> * Setup:
> - On which I have the problem:
> PC -> Vlan enabled ethernet switch -> 30 modems with the same IP address.
> 
> - Simplified:
> PC -> PC
> for 1 port use the configuration as mentioned below. For the other port use 192.168.1.1 as IP address for each VLAN.
> Then you can just ping 10.9.9.x to test.
> I have not tried this.
> 
> * Perl script to generate configure script:
> !/usr/bin/perl -w
> 
> my $vlan  = 100;
> my $modem = 1;
> my $subip = 2;
> for (my $modem = 1;$modem <= 30;$modem++) {
>     print "echo \"------------$vlan--------------------\"\n";
>     print "vconfig add eth2 $vlan\n";
>     print "ifconfig eth2.$vlan 192.168.1.$subip\n";
>     print "route del -net 192.168.1.0/24\n";
>     print "route add -host 10.9.9.$modem eth2.$vlan\n";
>     print "iptables -t nat -A OUTPUT -o eth2.$vlan -j DNAT --to 192.168.1.1\n";
> 
>     print "iptables -t mangle -N VLAN$vlan\n";
>     print "iptables -t mangle -F VLAN$vlan\n";
>     print "iptables -t mangle -A VLAN$vlan -j MARK --set-mark $vlan\n";
>     print "iptables -t mangle -A OUTPUT -o eth2.$vlan -j VLAN$vlan\n";
>     print "ip ro add table $vlan default dev eth2.$vlan\n";
>     print "ip ru add fwmark $vlan table $vlan\n";
>     print "ip ro fl ca\n";
>     $vlan++;
>     $subip++;
> };
> 

Please try loading ipt_LOG and executing

"echo 255 >/proc/sys/net/netfilter/nf_conntrack_log_invalid"

and see if something shows up in the ringbuffer.
