From: Vlad Yasevich <vyasevic@redhat.com>
Subject: Re: [PATCH net-next 3/4] bridge: Consider the Nearest
 Customer Bridge group addresses
Date: Mon, 09 Jun 2014 18:33:34 -0400
Message-ID: <5396363E.2020501@redhat.com>
References: <1402313687-28067-1-git-send-email-makita.toshiaki@lab.ntt.co.jp>	
	<1402313687-28067-4-git-send-email-makita.toshiaki@lab.ntt.co.jp>	
	<20140609085243.32f88582@nehalam.linuxnetplumber.net>
	<1402332351.1742.16.camel@localhost.localdomain>
Reply-To: vyasevic@redhat.com
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, bridge@lists.linux-foundation.org,
	"David S . Miller" <davem@davemloft.net>
To: Toshiaki Makita <toshiaki.makita1@gmail.com>,
	Stephen Hemminger <stephen@networkplumber.org>
Return-path: <bridge-bounces@lists.linux-foundation.org>
In-Reply-To: <1402332351.1742.16.camel@localhost.localdomain>
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/bridge>,
	<mailto:bridge-request@lists.linux-foundation.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/bridge/>
List-Post: <mailto:bridge@lists.linux-foundation.org>
List-Help: <mailto:bridge-request@lists.linux-foundation.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/bridge>,
	<mailto:bridge-request@lists.linux-foundation.org?subject=subscribe>
Sender: bridge-bounces@lists.linux-foundation.org
Errors-To: bridge-bounces@lists.linux-foundation.org
List-Id: netdev.vger.kernel.org

On 06/09/2014 12:45 PM, Toshiaki Makita wrote:
> On Mon, 2014-06-09 at 08:52 -0700, Stephen Hemminger wrote:
>> On Mon,  9 Jun 2014 20:34:46 +0900
>> Toshiaki Makita <makita.toshiaki@lab.ntt.co.jp> wrote:
>>
>>> An 802.1ad bridge must forward the Nearest Customer Bridge group addresses.
>>>  01-80-C2-00-00-00
>>>  01-80-C2-00-00-0B
>>>  01-80-C2-00-00-0C
>>>  01-80-C2-00-00-0D
>>>  01-80-C2-00-00-0F
>>> (For details, see IEEE 802.1Q-2011 8.6.3.)
>>>
>>> An exception is the br->group_addr, which needs to be passed to the higher
>>> layer entity so that STP works.
>>>
>>> Signed-off-by: Toshiaki Makita <makita.toshiaki@lab.ntt.co.jp>
>>> ---
>>>  net/bridge/br_input.c   | 15 ++++++++++++++-
>>>  net/bridge/br_private.h | 10 ++++++++++
>>>  2 files changed, 24 insertions(+), 1 deletion(-)
>>>
>>> diff --git a/net/bridge/br_input.c b/net/bridge/br_input.c
>>> index 04d6348..b05d419 100644
>>> --- a/net/bridge/br_input.c
>>> +++ b/net/bridge/br_input.c
>>> @@ -194,13 +194,26 @@ rx_handler_result_t br_handle_frame(struct sk_buff **pskb)
>>>  		case 0x00:	/* Bridge Group Address */
>>>  			/* If STP is turned off,
>>>  			   then must forward to keep loop detection */
>>> -			if (p->br->stp_enabled == BR_NO_STP)
>>> +			if (p->br->stp_enabled == BR_NO_STP ||
>>> +			    (br_vlan_enabled(p->br) &&
>>> +			     br_vlan_get_proto(p->br) == htons(ETH_P_8021AD) &&
>>> +			     p->br->group_addr[5] != dest[5]))
>>>  				goto forward;
>>>  			break;
>>>  
>>>  		case 0x01:	/* IEEE MAC (Pause) */
>>>  			goto drop;
>>>  
>>> +		case 0x0B:
>>> +		case 0x0C:
>>> +		case 0x0D:
>>> +		case 0x0F:
>>> +			/* The Nearest Customer Bridge group address */
>>> +			if (br_vlan_enabled(p->br) &&
>>> +			    br_vlan_get_proto(p->br) == htons(ETH_P_8021AD) &&
>>> +			    p->br->group_addr[5] != dest[5])
>>> +				goto forward;
>>> +			/* fall through */
>>>  		default:
>>>  			/* Allow selective forwarding for most other protocols */
>>>  			if (p->br->group_fwd_mask & (1u << dest[5]))
>>> diff --git a/net/bridge/br_private.h b/net/bridge/br_private.h
>>> index b65fee9..65204c2 100644
>>> --- a/net/bridge/br_private.h
>>> +++ b/net/bridge/br_private.h
>>> @@ -647,6 +647,11 @@ static inline int br_vlan_enabled(struct net_bridge *br)
>>>  {
>>>  	return br->vlan_enabled;
>>>  }
>>> +
>>> +static inline __be16 br_vlan_get_proto(struct net_bridge *br)
>>> +{
>>> +	return br->vlan_proto;
>>> +}
>>>  #else
>>>  static inline bool br_allowed_ingress(struct net_bridge *br,
>>>  				      struct net_port_vlans *v,
>>> @@ -742,6 +747,11 @@ static inline int br_vlan_enabled(struct net_bridge *br)
>>>  {
>>>  	return 0;
>>>  }
>>> +
>>> +static inline __be16 br_vlan_get_proto(struct net_bridge *br)
>>> +{
>>> +	return 0;
>>> +}
>>>  #endif
>>>  
>>>  /* br_netfilter.c */
>>
>> Rather than special casing this around vlan filtering, I would prefer
>> the code always forward these packets, or manipulate group_fwd_mask
>> to allow it that way.
> 
> These addresses must be forwarded only if the bridge is an S-VLAN
> bridge. When it is a C-VLAN bridge or a .1D bridge, they may not be
> forwarded. So, I don't think we can forward them always.
> 
> Using group_fwd_mask is a bit complicated. If we use it to forward them,
> user can optionally turn off forwarding ability of those addresses...
> but we maybe need another information (named like group_fwd_mask_set)
> that indicates which bit is set by user. (We have to set group_fwd_mask
> automatically when we set vlan_proto to 88a8.)
> Is this way acceptable?

May be separate it into required mask and user mask.  Set required
mask when this is an S-VLAN bridge.

-vlad

> 
> Thanks,
> Toshiaki Makita
> 
