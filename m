From: Nikolay Aleksandrov <nikolay@cumulusnetworks.com>
Subject: Re: [PATCH net-next v5 2/2] bridge: vlan: signal if
 anything changed on vlan add
Date: Fri, 27 Oct 2017 10:49:10 +0300
Message-ID: <c37963e6-800e-adf2-0193-0a82c1ce3b37@cumulusnetworks.com>
References: <1509025309-10165-1-git-send-email-nikolay@cumulusnetworks.com>
	<1509025309-10165-3-git-send-email-nikolay@cumulusnetworks.com>
	<1057357f-c59e-a789-4315-838003590ea5@lab.ntt.co.jp>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: roopa@cumulusnetworks.com, bridge@lists.linux-foundation.org,
	mrv@mojatatu.com, dsa@cumulusnetworks.com, davem@davemloft.net
To: Toshiaki Makita <makita.toshiaki@lab.ntt.co.jp>, netdev@vger.kernel.org
Return-path: <bridge-bounces@lists.linux-foundation.org>
In-Reply-To: <1057357f-c59e-a789-4315-838003590ea5@lab.ntt.co.jp>
Content-Language: en-US
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

On 27/10/17 04:55, Toshiaki Makita wrote:
> On 2017/10/26 22:41, Nikolay Aleksandrov wrote:
>> Before this patch there was no way to tell if the vlan add operation
>> actually changed anything, thus we would always generate a notification
>> on adds. Let's make the notifications more precise and generate them
>> only if anything changed, so use the new bool parameter to signal that the
>> vlan was updated. We cannot return an error because there are valid use
>> cases that will be broken (e.g. overlapping range add) and also we can't
>> risk masking errors due to calls into drivers for vlan add which can
>> potentially return anything.
>>
>> Signed-off-by: Nikolay Aleksandrov <nikolay@cumulusnetworks.com>
>> ---
>> v5: fix br_vlan_add return (v1 leftover) spotted by Toshiaki Makita
>> v4: set changed always to false in the non-vlan config case
>> v3: fix non-vlan config functions reported by kbuild bot
>> v2: pass changed down to vlan add functions instead of using a specific
>> error that needs to be masked
>>
>>  net/bridge/br_netlink.c |  9 ++++--
>>  net/bridge/br_private.h | 14 ++++++---
>>  net/bridge/br_vlan.c    | 76 +++++++++++++++++++++++++++++++++++--------------
>>  3 files changed, 71 insertions(+), 28 deletions(-)
>>
>> diff --git a/net/bridge/br_netlink.c b/net/bridge/br_netlink.c
>> index d0290ede9342..e732403669c6 100644
>> --- a/net/bridge/br_netlink.c
>> +++ b/net/bridge/br_netlink.c
>> @@ -508,6 +508,7 @@ int br_getlink(struct sk_buff *skb, u32 pid, u32 seq,
>>  static int br_vlan_info(struct net_bridge *br, struct net_bridge_port *p,
>>  			int cmd, struct bridge_vlan_info *vinfo, bool *changed)
>>  {
>> +	bool curr_change;
>>  	int err = 0;
> 
> Just a question.
> Why are you defining another variable here?
> Is it impossible to pass "changed" down to [br|nbp]_vlan_add() like
> other functions you modified in patch 1/2?
> 

No, we cannot because we need to preserve the current "changed" value that
is coming from setlink/dellink. br|nbp_vlan_add will overwrite whatever
is passed to them with "false" first in order to be agnostic to the caller.
If I make them set only "true" then we can't use this for anything else
and all callers will have to initialize the passed down variable to false.
I wanted to avoid such dependency for the vlan functions.
The important part is to keep "changed" passed down from setlink/dellink to
true if set once so we know that there was some change and need to notify.
