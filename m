From: Vlad Yasevich <vyasevic@redhat.com>
Subject: Re: [PATCH v2 net 2/4] bridge: Apply the PVID to priority-tagged
 frames
Date: Wed, 16 Oct 2013 12:16:09 -0400
Message-ID: <525EBBC9.8050809@redhat.com>
References: <1381910836-718-1-git-send-email-makita.toshiaki@lab.ntt.co.jp>	<1381910836-718-3-git-send-email-makita.toshiaki@lab.ntt.co.jp> <20131016085537.1cbe9c37@nehalam.linuxnetplumber.net>
Reply-To: vyasevic@redhat.com
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: "David S . Miller" <davem@davemloft.net>, netdev@vger.kernel.org,
	Toshiaki Makita <toshiaki.makita1@gmail.com>
To: Stephen Hemminger <stephen@networkplumber.org>,
	Toshiaki Makita <makita.toshiaki@lab.ntt.co.jp>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:6135 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750926Ab3JPQQQ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 16 Oct 2013 12:16:16 -0400
In-Reply-To: <20131016085537.1cbe9c37@nehalam.linuxnetplumber.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 10/16/2013 11:55 AM, Stephen Hemminger wrote:
> On Wed, 16 Oct 2013 17:07:14 +0900
> Toshiaki Makita <makita.toshiaki@lab.ntt.co.jp> wrote:
>
>> IEEE 802.1Q says that when we receive priority-tagged (VID 0) frames
>> use the PVID for the port as its VID.
>> (See IEEE 802.1Q-2011 6.9.1 and Table 9-2)
>>
>> Apply the PVID to not only untagged frames but also priority-tagged frames.
>>
>> Signed-off-by: Toshiaki Makita <makita.toshiaki@lab.ntt.co.jp>
>> ---
>>   net/bridge/br_vlan.c | 27 ++++++++++++++++++++-------
>>   1 file changed, 20 insertions(+), 7 deletions(-)
>>
>> diff --git a/net/bridge/br_vlan.c b/net/bridge/br_vlan.c
>> index 21b6d21..5a9c44a 100644
>> --- a/net/bridge/br_vlan.c
>> +++ b/net/bridge/br_vlan.c
>> @@ -189,6 +189,8 @@ out:
>>   bool br_allowed_ingress(struct net_bridge *br, struct net_port_vlans *v,
>>   			struct sk_buff *skb, u16 *vid)
>>   {
>> +	int err;
>> +
>>   	/* If VLAN filtering is disabled on the bridge, all packets are
>>   	 * permitted.
>>   	 */
>> @@ -201,20 +203,31 @@ bool br_allowed_ingress(struct net_bridge *br, struct net_port_vlans *v,
>>   	if (!v)
>>   		return false;
>>
>> -	if (br_vlan_get_tag(skb, vid)) {
>> +	err = br_vlan_get_tag(skb, vid);
>> +	if (!*vid) {
>>   		u16 pvid = br_get_pvid(v);
>
> Ok, but it looks like br_vlan_get_tag() could be cleaner if it just returned
> the tag, and there was another br_vlan_tag_present() function.

I was just thinking about that as well.  If we make br_vlan_get_tag()
return either the actual tag (if the packet is tagged), or the pvid
if (untagged/prio_tagged), then we can skp most of this.

>
> Also, does this still work if CONFIG_BRIDGE_VLAN_FILTERING is disabled?

Yes.  br_allowed_ingress becomes an inline if the config option is disabled.

-vlad
