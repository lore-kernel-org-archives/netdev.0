From: =?iso-8859-1?Q?Hans_Schillstr=F6m?= <hans.schillstrom@ericsson.com>
Subject: RE: [net-next PATCH] net: allow vlan traffic to be received under
 bond
Date: Thu, 13 Oct 2011 15:09:38 +0200
Message-ID: <C8A6796DE7C66C4ABCBC18106CB6C1CC106D903176@ESESSCMS0356.eemea.ericsson.se>
References: <20111010191641.2496.84845.stgit@jf-dev1-dcblab>
 <4E93A4D2.10301@intel.com>
  <CAEP_g=83tCQMVPOTT82GBw6GamodpqU-SAeYyx9noWnzbGfUpg@mail.gmail.com>
 <201110111308.53152.hans.schillstrom@ericsson.com>,<4E944116.8020103@intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7BIT
Cc: Jesse Gross <jesse@nicira.com>, Jiri Pirko <jpirko@redhat.com>,
	"davem@davemloft.net" <davem@davemloft.net>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"fubar@us.ibm.com" <fubar@us.ibm.com>
To: John Fastabend <john.r.fastabend@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailgw9.se.ericsson.net ([193.180.251.57]:55654 "EHLO
	mailgw9.se.ericsson.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755154Ab1JMNJm convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 13 Oct 2011 09:09:42 -0400
In-Reply-To: <4E944116.8020103@intel.com>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

>On 10/11/2011 4:08 AM, Hans Schillstrom wrote:
>> Hello
>> On Tuesday 11 October 2011 04:43:03 Jesse Gross wrote:
>>> On Mon, Oct 10, 2011 at 7:07 PM, John Fastabend
>>> <john.r.fastabend@intel.com> wrote:
>>>> On 10/10/2011 3:37 PM, Jiri Pirko wrote:
>>>>> Mon, Oct 10, 2011 at 09:16:41PM CEST, john.r.fastabend@intel.com wrote:
>>>>>> The following configuration used to work as I expected. At least
>>>>>> we could use the fcoe interfaces to do MPIO and the bond0 iface
>>>>>> to do load balancing or failover.
>>>>>>
>>>>>>       ---eth2.228-fcoe
>>>>>>       |
>>>>>> eth2 -----|
>>>>>>          |
>>>>>>          |---- bond0
>>>>>>          |
>>>>>> eth3 -----|
>>>>>>       |
>>>>>>       ---eth3.228-fcoe
>>>>>>
>>>>>> This worked because of a change we added to allow inactive slaves
>>>>>> to rx 'exact' matches. This functionality was kept intact with the
>>>>>> rx_handler mechanism. However now the vlan interface attached to the
>>>>>> active slave never receives traffic because the bonding rx_handler
>>>>>> updates the skb->dev and goto's another_round. Previously, the
>>>>>> vlan_do_receive() logic was called before the bonding rx_handler.
>>>>>>
>>>>>> Now by the time vlan_do_receive calls vlan_find_dev() the
>>>>>> skb->dev is set to bond0 and it is clear no vlan is attached
>>>>>> to this iface. The vlan lookup fails.
>>>>>>
>>>>>> This patch moves the VLAN check above the rx_handler. A VLAN
>>>>>> tagged frame is now routed to the eth2.228-fcoe iface in the
>>>>>> above schematic. Untagged frames continue to the bond0 as
>>>>>> normal. This case also remains intact,
>>>>>>
>>>>>> eth2 --> bond0 --> vlan.228
>>>>>>
>>>>>> Here the skb is VLAN tagged but the vlan lookup fails on eth2
>>>>>> causing the bonding rx_handler to be called. On the second
>>>>>> pass the vlan lookup is on the bond0 iface and completes as
>>>>>> expected.
>>>>>>
>>>>>> Putting a VLAN.228 on both the bond0 and eth2 device will
>>>>>> result in eth2.228 receiving the skb. I don't think this is
>>>>>> completely unexpected and was the result prior to the rx_handler
>>>>>> result.
>>
>> I think this OK, but I do have a question
>> if bond0 is in Active/Backup mode, eth2 and eth3 got the same MAC.addr,
>> what about the VLAN:s ?
>> (or is just one of thme working ??)
>>
>
>The VLAN MAC address will not be managed by the bond. In the
>storage case a SAN mac may be used (NETDEV_HW_ADDR_T_SAN).
>Otherwise the MAC can be managed normally.
>
>Both VLANs will receive frames but in some modes only to packet
>handlers that have exact matches. See bond_should_deliver_exact_match().
>
>.John.

Have made some test now,  this patch solves a big issue that we had with VLANs 
i.e. as a work-a-round we put macvlans in between the phys. interface and the bond.
I have tested the scenario below, where tipc is running on VLAN below the bonding interface.
With the patch it works fine now.
If you want you can add a
Tested-by: Hans Schillstrom <hams.schillstrom@ericsson.com>

                      +---------+        +---------+
                    +---------+ |      +---------+ |
                  +---------+ |-+    +---------+ |-+
                  | macvlan |-+      | macvlan |-+
                  +---------+        +---------+
                     | | |              | | |
                     | | |           +---------+
                     | | |       ----|  vlan8  |
                     | | |      /    +---------+
                     | | |     /
                  +----+----+ /
        +---------|  bond0  |=------------+
        |         +---------+             |
        |                                 |
   +----+----+  +---------+          +----+----+  +---------+
   |   eth1  |--|  vlan20 |          |   eth2  |--|  vlan21 |
   +----+----+  +---------+          +----+----+  +---------+
        |                                 |
        |                                 |
  +-----+-----+                     +-----+-----+
  | Switch-0  |_____________________|   Sw1     |
  |           |    ISL TRUNK        |           |
  +-+---+---+-+                     +-+---+---+-+
    |   |   |                         |   |   |
  vlan1 | vlan20                    vlan1 | vlan21
      vlan8                             vlan8



Thanks 
Hans
