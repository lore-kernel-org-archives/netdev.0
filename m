From: Brande <brande@novolab.de>
Subject: Prism / Hostap Bridge Problems...
Date: Fri, 10 Dec 2004 16:46:40 +0100
Message-ID: <41B9C4E0.40407@novolab.de>
References: <41B9B6E9.7010600@novolab.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com, linux-net@vger.kernel.org
Return-path: <linux-net-owner@vger.kernel.org>
To: Brande <brande@novolab.de>
In-Reply-To: <41B9B6E9.7010600@novolab.de>
Sender: linux-net-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi all,

maybe there is someone who can help...

Problem:

I have a meshcube (www.meshcube.org) with two prim 2.5 mini-pci WLAN 
cards...
wlan0 should connect as client (managed mode) to a normal access point 
which is connected to the internet.
wlan1 should work as accesspoint (master mode).
I would like to bridge between wlan0 and wlan1 so that I can connect 
with my Laptop Client2 to the AccessPoint on wlan1 and go, through the 
wlan0 client connection to the normal AccessPoint, to the internet...

So here is the hardware setup:

Internet ----- AccessPoint (192.168.0.1) -------- CLient/AP Bridge 
(192.168.0.100 (2 cards in one box))                                  
|                                                  |    
                     Laptop Client 1                            my 
Laptop CLient 2
                     (192.168.0.33)                               
(192.168.0.117)

The data of the WLAN devices:

hostap_diag wlan0
Host AP driver diagnostics information for 'wlan0'

NICID: id=0x8013 v1.0.0 (PRISM II (2.5) Mini-PCI (SST parallel flash))
PRIID: id=0x0015 v1.1.1
STAID: id=0x001f v1.7.4 (station firmware)agnostics information for 'wlan0'

hostap_diag wlan1
Host AP driver diagnostics information for 'wlan1'

NICID: id=0x8013 v1.0.0 (PRISM II (2.5) Mini-PCI (SST parallel flash))
PRIID: id=0x0015 v1.1.1
STAID: id=0x001f v1.7.4 (station firmware)agnostics information for 'wlan0'

I have written the following bridge script:

ETHER0=wlan0
ETHER1=wlan1
BRIDGE=br0
BRIDGEIP=192.168.0.100
BRIDGEGW=192.168.0.1
BRIDGENM=255.255.255.0
BRIDGESTP=off           ### must be "on" with more then one bridge

### stop configure ###


echo -n "stopping firewall: "

  iptables -F
  iptables -F -t nat
  iptables -P INPUT ACCEPT
  iptables -P FORWARD ACCEPT
  iptables -P OUTPUT ACCEPT

  echo "*** network is insecure now *** "

echo "done."


case "$1" in

   start)
       echo "Starting service bridge br0"
       echo "Bridge IP will be: $BRIDGEIP"
               ifconfig $ETHER0 promisc up
               ifconfig $ETHER1 promisc up
               sleep 2
       brctl addbr $BRIDGE
       brctl setbridgeprio $BRIDGE 0
               ifconfig $ETHER0 0.0.0.0
               ifconfig $ETHER1 0.0.0.0
       brctl addif $BRIDGE $ETHER0
       brctl addif $BRIDGE $ETHER1
       #brctl stp $BRIDGE $BRIDGESTP
       #brctl sethello $BRIDGE 1
       #brctl setmaxage $BRIDGE 4
       #brctl setfd $BRIDGE 4
               echo "1" > /proc/sys/net/ipv4/ip_forward               
           # I know it's not really neccessary
               ifconfig $BRIDGE $BRIDGEIP netmask $BRIDGENM up   # but 
it was a test
               route add default gw $BRIDGEGW $BRIDGE
       echo -e "Bridge needs 30 sec. to learn table!\n(depends on kernel 
version...)\n"
       ;;


If I start the script the bridge goes up and I can ping the bridge 
(192.168.0.100) from outside with the Laptop Client 1. I can also ping 
my Laptop Client2 from outside but from my Laptop Client2 I can not ping 
the gateway behind the bridge (192.168.0.1) or the Laptop Client1 but I 
can ping the bridge interface from my Laptop Client2 which is connected 
to the WLAN1 AccessPoint in the bridge...

With tcpdump I can see that the there is an arp request from my Laptop 
Client2 on the bridge interface to see who has 192.168.0.1 if I try to 
ping e.g. 192.168.0.1 but I get no reply from the bridge. On my Laptop I 
get the message "Host unreachable".
Looks like that the AccessPoint or the Client in the bridge, the MAC 
address within the arp request from my Laptop Client1 to the one of the 
correspondig interfaces inside the bridge replaced and that that is the 
reason while I can't receive the answer to my arp request. Might this be 
possible? And if - do you know a solution to solve that problem? Or do 
you have another solution with the same effect but without wds please;)


Thanks for your time,
   have fun,
      Brande
