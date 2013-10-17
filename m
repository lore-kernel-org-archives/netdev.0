From: Vlad Yasevich <vyasevic@redhat.com>
Subject: Re: [PATCH v2 net 2/4] bridge: Apply the PVID to priority-tagged
 frames
Date: Thu, 17 Oct 2013 13:39:00 -0400
Message-ID: <526020B4.80104@redhat.com>
References: <1381910836-718-1-git-send-email-makita.toshiaki@lab.ntt.co.jp>	 <1381910836-718-3-git-send-email-makita.toshiaki@lab.ntt.co.jp>	 <20131016085537.1cbe9c37@nehalam.linuxnetplumber.net>	 <525EBBC9.8050809@redhat.com> <1382012042.3746.67.camel@ubuntu-vm-makita>
Reply-To: vyasevic@redhat.com
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Stephen Hemminger <stephen@networkplumber.org>,
	"David S . Miller" <davem@davemloft.net>, netdev@vger.kernel.org,
	Toshiaki Makita <toshiaki.makita1@gmail.com>,
	Fernando Luis Vazquez Cao <fernando_b1@lab.ntt.co.jp>
To: Toshiaki Makita <makita.toshiaki@lab.ntt.co.jp>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:50890 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756076Ab3JQRjH (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 17 Oct 2013 13:39:07 -0400
In-Reply-To: <1382012042.3746.67.camel@ubuntu-vm-makita>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 10/17/2013 08:14 AM, Toshiaki Makita wrote:
> On Wed, 2013-10-16 at 12:16 -0400, Vlad Yasevich wrote:
>> On 10/16/2013 11:55 AM, Stephen Hemminger wrote:
>>> On Wed, 16 Oct 2013 17:07:14 +0900
>>> Toshiaki Makita <makita.toshiaki@lab.ntt.co.jp> wrote:
>>>
>>>> IEEE 802.1Q says that when we receive priority-tagged (VID 0) frames
>>>> use the PVID for the port as its VID.
>>>> (See IEEE 802.1Q-2011 6.9.1 and Table 9-2)
>>>>
>>>> Apply the PVID to not only untagged frames but also priority-tagged frames.
>>>>
>>>> Signed-off-by: Toshiaki Makita <makita.toshiaki@lab.ntt.co.jp>
>>>> ---
>>>>    net/bridge/br_vlan.c | 27 ++++++++++++++++++++-------
>>>>    1 file changed, 20 insertions(+), 7 deletions(-)
>>>>
>>>> diff --git a/net/bridge/br_vlan.c b/net/bridge/br_vlan.c
>>>> index 21b6d21..5a9c44a 100644
>>>> --- a/net/bridge/br_vlan.c
>>>> +++ b/net/bridge/br_vlan.c
>>>> @@ -189,6 +189,8 @@ out:
>>>>    bool br_allowed_ingress(struct net_bridge *br, struct net_port_vlans *v,
>>>>    			struct sk_buff *skb, u16 *vid)
>>>>    {
>>>> +	int err;
>>>> +
>>>>    	/* If VLAN filtering is disabled on the bridge, all packets are
>>>>    	 * permitted.
>>>>    	 */
>>>> @@ -201,20 +203,31 @@ bool br_allowed_ingress(struct net_bridge *br, struct net_port_vlans *v,
>>>>    	if (!v)
>>>>    		return false;
>>>>
>>>> -	if (br_vlan_get_tag(skb, vid)) {
>>>> +	err = br_vlan_get_tag(skb, vid);
>>>> +	if (!*vid) {
>>>>    		u16 pvid = br_get_pvid(v);
>>>
>>> Ok, but it looks like br_vlan_get_tag() could be cleaner if it just returned
>>> the tag, and there was another br_vlan_tag_present() function.
>
> Thank you for reviewing.
> I agree with you.
> I had been afraid that if it affects other codes because
> br_vlan_get_tag() is used in many places else, but now I have decided
> not to hesitate to change its signature and behavior.
>
>>
>> I was just thinking about that as well.  If we make br_vlan_get_tag()
>> return either the actual tag (if the packet is tagged), or the pvid
>> if (untagged/prio_tagged), then we can skp most of this.
>
> Hmm... maybe I don't fully understand you.
>
> Is what you intend something like
> 	br_allowed_ingress(...) {
> 		...
> 		vid = br_vlan_get_tag(skb, v);
> 		if (!tagged(skb)) put_tag(skb, vid); /* untagged */
> 		else if (!get_vid(skb)) update_vid(skb, vid); /* prio_tagged */
> 		...
> 	}
>
> 	br_vlan_get_tag(skb, v) {
> 		if (tagged(skb)) {
> 			vid = get_vid(skb);
> 			if (!vid) return get_pvid(v); /* prio_tagged */
> 			return vid;
> 		}
> 		return get_pvid(v); /* untagged */
> 	}
>
> This needs double check for prio_tagged at br_allowed_ingress() and
> br_vlan_get_tag().
>
> Or if we modify skb->vlan_tci at br_vlan_get_tag(), isn't it a little
> dangerous to other codes that use this function in order to just get
> vid?
>
> I am thinking it makes things simple that br_vlan_get_tag() returns 0 if
> (untagged/prio_tagged).
>
> 	br_allowed_ingress(...) {
> 		...
> 		vid = br_vlan_get_tag(skb);
> 		if (!vid) {
> 			vid = get_pvid(v);
> 			if (!tagged(skb)) put_tag(skb, vid);/* untagged */
> 			else update_vid(skb, vid); /* prio_tagged */
> 		}
> 		...
> 	}
>
> 	br_vlan_get_tag(skb) {
> 		if (tagged(skb)) return get_vid(skb);
> 		return 0;
> 	}

With this you end up checking if the patcket is tagged quite a lot of times.

What I am thinking is that once we perform a get_tag, we should get
the vlan tag that the current packet belongs to.  We can then safely
use that tag everywhere and not have to worry too much about it.

We can pass that tag to br_allowed_ingress to verify that it is
permitted to enter.

You made a valid point about multicast code using br_vlan_get_tag
incorrectly and I plan on addressing that.

As it is, the current series addresses bugs in the implementation
that should be fixed.

We can make the code better/nicer as a next step.

-vlad

>
> Thanks,
>
> Toshiaki Makita
>
>>
>>>
>>> Also, does this still work if CONFIG_BRIDGE_VLAN_FILTERING is disabled?
>>
>> Yes.  br_allowed_ingress becomes an inline if the config option is disabled.
>>
>> -vlad
>
>
