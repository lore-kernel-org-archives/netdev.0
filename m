From: Christian Darnell <Christian.Darnell@se.flextronics.com>
Subject: RE: [Bridge] RE: Re: [PATCH/RFC] Let {ip, arp}tables "see"
	 bridged VLAN tagged{I,AR}P packets
Date: Wed, 8 Oct 2003 15:09:21 +0200
Sender: vlan-bounces@wanfear.com
Message-ID: <5B537508CDBED3118403009027745A210B8C14A2@knant18.kna.flextronics.com>
Reply-To: "Linux 802.1Q VLAN" <vlan@wanfear.com>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="iso-8859-1"
Cc: netdev@oss.sgi.com
Return-path: <vlan-bounces@wanfear.com>
To: "'Linux 802.1Q VLAN'" <vlan@wanfear.com>,
        "'Tommy Christensen'"
	 <tommy.christensen@tpack.net>
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
>From: Christian Darnell [mailto:Christian.Darnell@se.flextronics.com]
>Sent: Wednesday, October 08, 2003 10:18 AM
>To: 'Tommy Christensen'
>Cc: netdev@oss.sgi.com; 'Linux 802.1Q VLAN'; bridge
>Subject: RE: [Bridge] RE: [VLAN] Re: [PATCH/RFC] Let {ip, arp}tables
>"see" bridged VLAN tagged{I,AR}P packets
>
>
>
>-----Original Message-----
>>From: Tommy Christensen [mailto:tommy.christensen@tpack.net]
>>Sent: Wednesday, October 08, 2003 10:09 AM
>>To: Christian Darnell
>>Cc: 'Linux 802.1Q VLAN'; Bart De Schuymer; netdev@oss.sgi.com; bridge
>>Subject: Re: [Bridge] RE: [VLAN] Re: [PATCH/RFC] Let {ip, arp}tables
>>"see" bridged VLAN tagged{I,AR}P packets
>>
>>
>>
>>This is because the VLAN code is mangling shared data.
>>You need to do something like this:
>>
>>
>>--- linux-2.4/net/8021q/vlan_dev.c.org	2003-02-25
15:23:09.000000000
>>+0100
>>+++ linux-2.4/net/8021q/vlan_dev.c	2003-10-07 16:01:29.000000000 +0200
>>@@ -75,7 +75,12 @@
>> static inline struct sk_buff *vlan_check_reorder_header(struct sk_buff
>>*skb)
>> {
>> 	if (VLAN_DEV_INFO(skb->dev)->flags & 1) {
>>-		skb = skb_share_check(skb, GFP_ATOMIC);
>>+		if (skb_shared(skb) || skb_cloned(skb)) {
>>+			struct sk_buff *nskb;
>>+			nskb = skb_copy(skb, GFP_ATOMIC);
>>+			kfree_skb(skb);
>>+			skb = nskb;
>>+		}
>> 		if (skb) {
>> 			/* Lifted from Gleb's VLAN code... */
>> 			memmove(skb->data - ETH_HLEN,
>>
>>
>>Christian, could you try this out?
>
>
>Thanks Tommy! I tried this (on kernel 2.4.22) and it works great!
>
>

Hi again, when the problem with VLAN and pcap was solved I found a bug in
pcap. The problem is that pcap_setfilter doesn't work correctly when using
vlan x. The problem is that pcap don't mask VID. This results in that for
packets with priority (802.1q) set to 0 the vlan x filter works fine, but
when the packet has a priority != 0 the vlan x fails. 

An example:
If one have a vlan with VID = 2 and sniffing using the filter "vlan 2"
packets with priority = 0 will be shown. Changing to priority = 1 the
packets wont appear, if one changes the filter to "vlan 8194" the packets
will appear.

Fixing so pcap will mask the TCI field with "& 0xfff " to get the VID should
probably fix this problem. I have try to locate where this check is
performed in the pcap code but with no success. I think
gencode.c::gen_vlan(vlan_num) has something to do with...

Is there someone who knows the pcap code and know where this check is done?
I have tried with tcpdump-workers@tcpdump.org before without any response,
is there anyone who knows how to contact the maintainers of the libpcap?


Best regards,

Christian Darnell

_______________________________________________
VLAN mailing list  -  VLAN@wanfear.com
http://www.WANfear.com/mailman/listinfo/vlan
VLAN Page:  http://scry.wanfear.com/~greear/vlan.html
