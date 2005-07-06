From: Stuart Zilm <szilm@presinet.com>
Subject: policy routing inconsistency
Date: Wed, 6 Jul 2005 15:27:19 -0700
Message-ID: <B98BE941-7E4B-47D9-AAB5-355E340BD3F9@presinet.com>
Mime-Version: 1.0 (Apple Message framework v730)
Content-Type: text/plain; charset=US-ASCII; delsp=yes; format=flowed
Content-Transfer-Encoding: 7bit
Return-path: <netdev-bounce@oss.sgi.com>
To: netdev@oss.sgi.com
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

While trying to do some policy routing recently I discovered an  
inconsistency in the behavior that selects the source address by  
route for locally generated outgoing packets.
It seems that while routing occurs through the full policy database  
(rules and routes), the routes source address is always looked up in  
the main routing table.

For example:

DST=10.10.1.1
SRC=10.10.1.2

ip address add $SRC dev eth0 # this is a secondary address on the  
interface

# this works - the source selected is $SRC
ip route add $DST dev eth0 src $SRC # implicit table main

# this fails - the source selected is chosen from main
ip route del $DST dev eth0 src $SRC # implicit table main - NOTE: if  
this route remains, this source address will be chosen (from table  
main!)
ip route add $SRC dev eth0 src $SRC table 1
ip rule add fwmark 1 table 1
iptables -t mangle -A OUTPUT -d $DST -j MARK --set-mark 1

I expected my source to come from the route that matches and routes  
my packets.  Instead, it seems like there is a separate lookup done  
on table main directly to select the source.
The behavior is the same on linux 2.4.30 and 2.6.8 kernels.
Is this done intentionally?
What I hoped to achieve was the ability to have two routes to the  
same host, using different source addresses and select routes based  
on packet marks.  Is that possible?

Stuart Zilm
PresiNET Systems
