From: Toshiaki Makita <makita.toshiaki@lab.ntt.co.jp>
Subject: Re: [PATCH net-next 13/27] bridge: use __vlan_hwaccel
	helpers
Date: Wed, 14 Dec 2016 09:40:57 +0900
Message-ID: <ca5bb9f1-16ef-c442-b6d7-eb6ae39dae48@lab.ntt.co.jp>
References: <cover.1481586602.git.mirq-linux@rere.qmqm.pl>
	<e6e09a2f745a652382ac7859770ec16c75d8e149.1481586602.git.mirq-linux@rere.qmqm.pl>
	<f5078470-0fc0-cfcd-36df-3ebb380b547a@cogentembedded.com>
	<20161213151110.yapgecrospdd23oj@rere.qmqm.pl>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-2
Content-Transfer-Encoding: 8bit
Cc: netdev@vger.kernel.org,
	"moderated list:ETHERNET BRIDGE" <bridge@lists.linux-foundation.org>,
	"open list:NETFILTER \({IP, IP6, ARP, EB ,
	NF}TABLES\)" <netfilter-devel@vger.kernel.org>,
	"Jozsef Kadlecsik \(supporter:NETFILTER \({IP, IP6, ARP, EB,
	NF}TABLES\)\)" <kadlec@blackhole.kfki.hu>,
	"Patrick McHardy \(supporter:NETFILTER \({IP, IP6, ARP , EB,
	NF}TABLES\)\)" <kaber@trash.net>,
	"Pablo Neira Ayuso \(supporter:NETFILTER \({IP , IP6, ARP, EB,
	NF}TABLES\)\)" <pablo@netfilter.org>
To: =?UTF-8?B?TWljaGHFgiBNaXJvc8WCYXc=?= <mirq-linux@rere.qmqm.pl>,
	Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Return-path: <bridge-bounces@lists.linux-foundation.org>
In-Reply-To: <20161213151110.yapgecrospdd23oj@rere.qmqm.pl>
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

On 2016/12/14 0:11, Micha³ Miros³aw wrote:
> On Tue, Dec 13, 2016 at 03:59:46PM +0300, Sergei Shtylyov wrote:
>> Hello!
>>
>> On 12/13/2016 3:12 AM, Micha³ Miros³aw wrote:
>>
>>> This removes assumption than vlan_tci != 0 when tag is present.
>>>
>>> Signed-off-by: Micha³ Miros³aw <mirq-linux@rere.qmqm.pl>
>>> ---
>>>  net/bridge/br_netfilter_hooks.c | 14 ++++++++------
>>>  net/bridge/br_private.h         |  2 +-
>>>  net/bridge/br_vlan.c            |  6 +++---
>>>  3 files changed, 12 insertions(+), 10 deletions(-)
>>>
>>> diff --git a/net/bridge/br_netfilter_hooks.c b/net/bridge/br_netfilter_hooks.c
>>> index b12501a..2cc0747 100644
>>> --- a/net/bridge/br_netfilter_hooks.c
>>> +++ b/net/bridge/br_netfilter_hooks.c
>> [...]
>>> @@ -749,8 +747,12 @@ static int br_nf_dev_queue_xmit(struct net *net, struct sock *sk, struct sk_buff
>>>
>>>  		data = this_cpu_ptr(&brnf_frag_data_storage);
>>>
>>> -		data->vlan_tci = skb->vlan_tci;
>>> -		data->vlan_proto = skb->vlan_proto;
>>> +		if (skb_vlan_tag_present(skb)) {
>>> +			data->vlan_tci = skb->vlan_tci;
>>> +			data->vlan_proto = skb->vlan_proto;
>>> +		} else
>>> +			data->vlan_proto = 0;
>>
>>    CodingStyle: should use {} in all branches of *if* if at least one branch
>> has {}.
>>
>> [...]
>>> diff --git a/net/bridge/br_vlan.c b/net/bridge/br_vlan.c
>>> index b6de4f4..ef94664 100644
>>> --- a/net/bridge/br_vlan.c
>>> +++ b/net/bridge/br_vlan.c
>>
>>> @@ -444,8 +444,8 @@ static bool __allowed_ingress(const struct net_bridge *br,
>>>  			__vlan_hwaccel_put_tag(skb, br->vlan_proto, pvid);
>>>  		else
>>>  			/* Priority-tagged Frame.
>>> -			 * At this point, We know that skb->vlan_tci had
>>> -			 * VLAN_TAG_PRESENT bit and its VID field was 0x000.
>>> +			 * At this point, We know that skb->vlan_tci VID
>>
>>    s/We/we/.
>>
>>> +			 * field was 0x000.
>>
>>    Simply 0, maybe?

I originally wrote it like this because we are playing with bit field here.
I meant that all of 12 bits are 0 thus we can safely perform bitwise-OR
to update the VID field.

Thanks,
Toshiaki Makita
