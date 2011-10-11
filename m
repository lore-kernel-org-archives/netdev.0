From: John Fastabend <john.r.fastabend@intel.com>
Subject: Re: [net-next PATCH] net: allow vlan traffic to be received under
 bond
Date: Tue, 11 Oct 2011 06:16:36 -0700
Message-ID: <4E9441B4.2090500@intel.com>
References: <20111010191641.2496.84845.stgit@jf-dev1-dcblab> <20111010223752.GB2373@minipsycho> <4E93A4D2.10301@intel.com> <CAEP_g=83tCQMVPOTT82GBw6GamodpqU-SAeYyx9noWnzbGfUpg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Cc: Jiri Pirko <jpirko@redhat.com>,
	"davem@davemloft.net" <davem@davemloft.net>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"fubar@us.ibm.com" <fubar@us.ibm.com>
To: Jesse Gross <jesse@nicira.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga11.intel.com ([192.55.52.93]:58160 "EHLO mga11.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752997Ab1JKNQh (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 11 Oct 2011 09:16:37 -0400
In-Reply-To: <CAEP_g=83tCQMVPOTT82GBw6GamodpqU-SAeYyx9noWnzbGfUpg@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 10/10/2011 7:43 PM, Jesse Gross wrote:
> On Mon, Oct 10, 2011 at 7:07 PM, John Fastabend
> <john.r.fastabend@intel.com> wrote:
>> On 10/10/2011 3:37 PM, Jiri Pirko wrote:
>>> Mon, Oct 10, 2011 at 09:16:41PM CEST, john.r.fastabend@intel.com wrote:
>>>> The following configuration used to work as I expected. At least
>>>> we could use the fcoe interfaces to do MPIO and the bond0 iface
>>>> to do load balancing or failover.
>>>>
>>>>       ---eth2.228-fcoe
>>>>       |
>>>> eth2 -----|
>>>>          |
>>>>          |---- bond0
>>>>          |
>>>> eth3 -----|
>>>>       |
>>>>       ---eth3.228-fcoe
>>>>
>>>> This worked because of a change we added to allow inactive slaves
>>>> to rx 'exact' matches. This functionality was kept intact with the
>>>> rx_handler mechanism. However now the vlan interface attached to the
>>>> active slave never receives traffic because the bonding rx_handler
>>>> updates the skb->dev and goto's another_round. Previously, the
>>>> vlan_do_receive() logic was called before the bonding rx_handler.
>>>>
>>>> Now by the time vlan_do_receive calls vlan_find_dev() the
>>>> skb->dev is set to bond0 and it is clear no vlan is attached
>>>> to this iface. The vlan lookup fails.
>>>>
>>>> This patch moves the VLAN check above the rx_handler. A VLAN
>>>> tagged frame is now routed to the eth2.228-fcoe iface in the
>>>> above schematic. Untagged frames continue to the bond0 as
>>>> normal. This case also remains intact,
>>>>
>>>> eth2 --> bond0 --> vlan.228
>>>>
>>>> Here the skb is VLAN tagged but the vlan lookup fails on eth2
>>>> causing the bonding rx_handler to be called. On the second
>>>> pass the vlan lookup is on the bond0 iface and completes as
>>>> expected.
>>>>
>>>> Putting a VLAN.228 on both the bond0 and eth2 device will
>>>> result in eth2.228 receiving the skb. I don't think this is
>>>> completely unexpected and was the result prior to the rx_handler
>>>> result.
>>>>
>>>> Note, the same setup is also used for other storage traffic that
>>>> MPIO is used with eg. iSCSI and similar setups can be contrived
>>>> without storage protocols.
>>>>
>>>> Signed-off-by: John Fastabend <john.r.fastabend@intel.com>
>>>> ---

[...]

>> Maybe Jesse, can comment though on why this commit that moved (and
>> cleaned up) the vlan tag handling put the vlan_do_receive below the
>> rx_handler rather than above it. Was this intended to fix something?
> 
> The original reason was to ensure packets received from NICs that do
> stripping behaved the same as those that don't.  At the time, the
> packets with inline vlan tags were handled by the same code that
> handled upper layer protocols so it was important that code for vlan
> stripped tags be immediately before that.  Otherwise, packets might be
> taken either by the bridge hook or vlan code depending the the type of
> device.
> 
> However, that's no longer an issue because we now emulate vlan
> acceleration by untagging packets at the beginning of
> __netif_receive_skb(), so the code path will always be the same.
> Furthermore, based on feedback received since that patch it seems
> pretty clear that people prefer the behavior where vlan devices take
> traffic first, so now that we can have both that and consistent
> behavior it seems to be the way to go.
> 
> This looks correct to me:
> Acked-by: Jesse Gross <jesse@nicira.com>

Thanks for the nice summary Jesse.
