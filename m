From: Christian Darnell <Christian.Darnell@se.flextronics.com>
Subject: RE: Re: [PATCH/RFC] Let {ip,arp}tables "see" bridged VLAN
	tagged{I,AR}P packets
Date: Tue, 7 Oct 2003 11:06:13 +0200
Sender: vlan-bounces@wanfear.com
Message-ID: <5B537508CDBED3118403009027745A210B8C1499@knant18.kna.flextronics.com>
Reply-To: "Linux 802.1Q VLAN" <vlan@wanfear.com>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="iso-8859-1"
Cc: netdev@oss.sgi.com
Return-path: <vlan-bounces@wanfear.com>
To: "'Linux 802.1Q VLAN'" <vlan@wanfear.com>,
        Bart De Schuymer
	 <bdschuym@pandora.be>
cc: bridge <bridge@osdl.org>
List-Unsubscribe: <http://www.WANfear.com/mailman/listinfo/vlan>,
	<mailto:vlan-request@wanfear.com?subject=unsubscribe>
List-Archive: <http://ns1.wanfear.com/pipermail/vlan>
List-Post: <mailto:vlan@wanfear.com>
List-Help: <mailto:vlan-request@wanfear.com?subject=help>
List-Subscribe: <http://www.WANfear.com/mailman/listinfo/vlan>,
	<mailto:vlan-request@wanfear.com?subject=subscribe>
Errors-To: vlan-bounces@wanfear.com
List-Id: netdev.vger.kernel.org



>-----Original Message-----
>From: Ben Greear [mailto:greearb@candelatech.com]
>Sent: Monday, October 06, 2003 10:24 PM
>To: Bart De Schuymer
>Cc: netdev@oss.sgi.com; vlan@wanfear.com; bridge
>Subject: [VLAN] Re: [PATCH/RFC] Let {ip,arp}tables "see" bridged VLAN
>tagged{I,AR}P packets
>
>
>Bart De Schuymer wrote:
>> - add some code in vlan_dev.c::vlan_dev_hard_start_xmit():
>> skb->protocol = __constant_htons(ETH_P_8021Q);
>> skb->mac.raw -= VLAN_HLEN;
>> skb->nh.raw -= VLAN_HLEN;
>
>I wonder if this is what was messing up the tcpdump packet capture
>as well?

Hi Ben and all others, 

Just to clarify for other who hasn't been a part of this discussion before. 

---- 8< ----
When trying to grab a packet with pcap when using VLAN the beginning of the
packet is corrupt an the VLAN TCI bits are missing. This is only a problem
when sniffing on incoming traffic not outgoing.

00 60 08 50 00 60 08 50 26 2a 00 60 08 6a b4 53 xx xx xx xx 08 00 45 00
^^^^^^^^^^^                                     ^^^^^^^^^^^^
Where does these bytes come from?               Bytes missing (VLAN header)?

The correct MAC addresses here are:
00 60 08 50 26 2a and 00 60 08 6a b4 53
---- 8< ----


I added those lines (see above) to vlan_dev.c but it didn't solve the
problem with tcpdump (pcap) incoming packets. vlan_dev_hard_start_xmit()
tells me that this is only outgoing packets right? For outgoing packets
tcpdump works (and Ethereal for Windows sees the packet correctly on the
wire) so the problem doesn't occur when sending packets. I added following
line to vlan_dev.c:

vlan_dev.c:: int vlan_skb_recv(struct sk_buff *skb, struct net_device *dev,
struct packet_type* ptype):

vlan_TCI = ntohs(vhdr->h_vlan_TCI);

+ /* Print the 802.1p priority */
+printk("VLAN Prio: %hx\n", vlan_TCI >> 13);

vid = (vlan_TCI & VLAN_VID_MASK);

With the code above I get the 802.1p correctly. Does anyone know how and
when pcap grabs the packet (does pcap grab the packet before or after
vlan_skb_recv is called)?

When I'm sniffing with pcap I sniff the Ethernet interface, so the VLAN
stuff isn't really involved when pcap grab the packet or have I
misunderstand how it works?


Best Regards, 

Christian Darnell
_______________________________________________
VLAN mailing list  -  VLAN@wanfear.com
http://www.WANfear.com/mailman/listinfo/vlan
VLAN Page:  http://scry.wanfear.com/~greear/vlan.html
