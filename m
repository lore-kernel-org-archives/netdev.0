From: Ben Greear <greearb@candelatech.com>
Subject: Re: ARP problem?
Date: Wed, 16 Oct 2002 16:56:35 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <3DADFCB3.6010206@candelatech.com>
References: <E156A23F1885D4119ED800B0D0498A9F02128B96@aimexc07.adaptec.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: "'netdev@oss.sgi.com'" <netdev@oss.sgi.com>
Return-path: <netdev-bounce@oss.sgi.com>
To: "Thompson, Ian" <Ian_Thompson@adaptec.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Thompson, Ian wrote:
>>You need arp-filtering:
>>
>>     # Set up arp-filter magic.  This, with source-based 
>>routing allows us
>>     # to have multiple NICs on the same subnet, on the same 
>>machine, connected
>>     # to the same switch...
>>     if [ -f  /proc/sys/net/ipv4/conf/all/arp_filter ];
>>     then
>>	echo 1 > /proc/sys/net/ipv4/conf/all/arp_filter
>>     else
>>	echo "ERROR: kernel does not support arp_filter.  Don't 
>>put more than"
>>	echo "       one interface on the same subnet on the 
>>same machine."
>>	echo ""
>>     fi
>>
> 
> 
> I tried this, and now I'm getting only one ARP response.  However, I get the
> same MAC address for ARP broadcasts for either IP address.  Does ARP
> filtering turn off all but the first interface when processing ARP packets?
> Can I get each interface to answer ARP packets only for its specific IP
> address?

Try setting up source-based routing.  Here is a snippet of perl code that
does that, but it will be difficult for you to decipher out of context:

e_if is a list of interfaces (ie eth2)
e_ip is the IP for this interface
sigb is the significant bits, ie the 24 in 192.168.2.0/24
e_tbl is the table name, you need a table for each interface.


       print "# Setup for device: $e_if[$i]  IP:  $e_ip[$i]  sig-bits: $e_sigb[$i]\n";
       printAndExec("ip link set $e_if[$i] down");
       printAndExec("ip link set $e_if[$i] up");
       printAndExec("ip addr flush dev $e_if[$i]");
       if ($e_ip[$i] ne "0.0.0.0") {
	printAndExec("ip address add $e_ip[$i]/$e_sigb[$i] broadcast $e_bcast[$i] dev $e_if[$i]");
       }
       printAndExec("ip link set dev $e_if[$i] up");
       if ($e_ip[$i] ne "0.0.0.0") {
	printAndExec("ip ru add from $e_ip[$i]/32 table $e_tbl[$i]");
	printAndExec("ip route add $e_sub[$i]/$e_sigb[$i] via $e_ip[$i] table $e_tbl[$i]");
       }
       if ($e_gw[$i] ne "0.0.0.0") {
	printAndExec("ip route add 0/0 via $e_gw[$i] dev $e_if[$i] table $e_tbl[$i]");
       }

You can use this to give you ideas of what to look for as you read one of the
advanced-routing HOWTOs.  With source-based routing and arp-filtering, I have
gotten many interfaces on the same subnet to work as you would expect, so it
can be done :)

Ben


> 
> Thanks,
> -ian
> 


-- 
Ben Greear <greearb@candelatech.com>       <Ben_Greear AT excite.com>
President of Candela Technologies Inc      http://www.candelatech.com
ScryMUD:  http://scry.wanfear.com     http://scry.wanfear.com/~greear
