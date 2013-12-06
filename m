From: Jon Maloy <jon.maloy@ericsson.com>
Subject: Re: [PATCH net-next 1/6] tipc: add
	link_kfree_skbuff helper function
Date: Fri, 6 Dec 2013 09:13:44 -0500
Message-ID: <52A1DB98.60109@ericsson.com>
References: <1386311022-11176-1-git-send-email-wangweidong1@huawei.com>
	<1386311022-11176-2-git-send-email-wangweidong1@huawei.com>
	<52A16FF3.7040107@windriver.com> <52A171E4.4070806@huawei.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, tipc-discussion@lists.sourceforge.net,
	allan.stephens@windriver.com, davem@davemloft.net
To: Wang Weidong <wangweidong1@huawei.com>
Return-path: <tipc-discussion-bounces@lists.sourceforge.net>
In-Reply-To: <52A171E4.4070806@huawei.com>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/tipc-discussion>,
	<mailto:tipc-discussion-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum_name=tipc-discussion>
List-Post: <mailto:tipc-discussion@lists.sourceforge.net>
List-Help: <mailto:tipc-discussion-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/tipc-discussion>,
	<mailto:tipc-discussion-request@lists.sourceforge.net?subject=subscribe>
Errors-To: tipc-discussion-bounces@lists.sourceforge.net
List-Id: netdev.vger.kernel.org

Wang,
I am very happy to see you posting improvements to TIPC, but please synch up
with the TIPC development team (i.e., use tipc_discussion), before posting 
it to netdev. As Ying stated,we have a patch series in the pipe that deals 
with exactly this issue, and more.

Regards
///jon




On 12/06/2013 01:42 AM, Wang Weidong wrote:
> On 2013/12/6 14:34, Ying Xue wrote:
>> On 12/06/2013 02:23 PM, Wang Weidong wrote:
>>> replaces some chunks of code that kfree the sk_buff.
>>> This is just code simplification, no functional changes.
>>>
>>> Signed-off-by: Wang Weidong <wangweidong1@huawei.com>
>>> ---
>>>  net/tipc/link.c | 58 +++++++++++++++++++--------------------------------------
>>>  1 file changed, 19 insertions(+), 39 deletions(-)
>>>
>>> diff --git a/net/tipc/link.c b/net/tipc/link.c
>>> index 69cd9bf..1c27d7b 100644
>>> --- a/net/tipc/link.c
>>> +++ b/net/tipc/link.c
>>> @@ -100,6 +100,17 @@ static unsigned int align(unsigned int i)
>>>  	return (i + 3) & ~3u;
>>>  }
>>>  
>>> +static void link_kfree_skbuff(struct sk_buff *buf)
>>> +{
>>> +	struct sk_buff *next;
>>> +
>>> +	while (buf) {
>>> +		next = buf->next;
>>> +		kfree_skb(buf);
>>> +		buf = next;
>>> +	}
>>> +}
>>> +
>>
>> Your new defined function is unnecessary, instead we already have
>> another patch doing the same thing with kfree_skb_list(), and the patch
>> will be to be sent out soon.
>>
>> Please see below link:
>>
>> http://article.gmane.org/gmane.network.tipc.general/5140/
>>
>> And the patch cleans up more things than your patch.
>>
> 
> Yes, You are right. 
> Thanks.
> 
>> Regards,
>> Ying
>>
>>>  static void link_init_max_pkt(struct tipc_link *l_ptr)
>>>  {
>>>  	u32 max_pkt;
>>> @@ -387,13 +398,8 @@ exit:
>>>  static void link_release_outqueue(struct tipc_link *l_ptr)
>>>  {
>>>  	struct sk_buff *buf = l_ptr->first_out;
>>> -	struct sk_buff *next;
>>>  
>>> -	while (buf) {
>>> -		next = buf->next;
>>> -		kfree_skb(buf);
>>> -		buf = next;
>>> -	}
>>> +	link_kfree_skbuff(buf);
>>>  	l_ptr->first_out = NULL;
>>>  	l_ptr->out_queue_size = 0;
>>>  }
>>> @@ -416,21 +422,12 @@ void tipc_link_reset_fragments(struct tipc_link *l_ptr)
>>>  void tipc_link_stop(struct tipc_link *l_ptr)
>>>  {
>>>  	struct sk_buff *buf;
>>> -	struct sk_buff *next;
>>>  
>>>  	buf = l_ptr->oldest_deferred_in;
>>> -	while (buf) {
>>> -		next = buf->next;
>>> -		kfree_skb(buf);
>>> -		buf = next;
>>> -	}
>>> +	link_kfree_skbuff(buf);
>>>  
>>>  	buf = l_ptr->first_out;
>>> -	while (buf) {
>>> -		next = buf->next;
>>> -		kfree_skb(buf);
>>> -		buf = next;
>>> -	}
>>> +	link_kfree_skbuff(buf);
>>>  
>>>  	tipc_link_reset_fragments(l_ptr);
>>>  
>>> @@ -472,11 +469,7 @@ void tipc_link_reset(struct tipc_link *l_ptr)
>>>  	kfree_skb(l_ptr->proto_msg_queue);
>>>  	l_ptr->proto_msg_queue = NULL;
>>>  	buf = l_ptr->oldest_deferred_in;
>>> -	while (buf) {
>>> -		struct sk_buff *next = buf->next;
>>> -		kfree_skb(buf);
>>> -		buf = next;
>>> -	}
>>> +	link_kfree_skbuff(buf);
>>>  	if (!list_empty(&l_ptr->waiting_ports))
>>>  		tipc_link_wakeup_ports(l_ptr, 1);
>>>  
>>> @@ -1127,10 +1120,7 @@ again:
>>>  		if (copy_from_user(buf->data + fragm_crs, sect_crs, sz)) {
>>>  			res = -EFAULT;
>>>  error:
>>> -			for (; buf_chain; buf_chain = buf) {
>>> -				buf = buf_chain->next;
>>> -				kfree_skb(buf_chain);
>>> -			}
>>> +			link_kfree_skbuff(buf_chain);
>>>  			return res;
>>>  		}
>>>  		sect_crs += sz;
>>> @@ -1180,18 +1170,12 @@ error:
>>>  		if (l_ptr->max_pkt < max_pkt) {
>>>  			sender->max_pkt = l_ptr->max_pkt;
>>>  			tipc_node_unlock(node);
>>> -			for (; buf_chain; buf_chain = buf) {
>>> -				buf = buf_chain->next;
>>> -				kfree_skb(buf_chain);
>>> -			}
>>> +			link_kfree_skbuff(buf_chain);
>>>  			goto again;
>>>  		}
>>>  	} else {
>>>  reject:
>>> -		for (; buf_chain; buf_chain = buf) {
>>> -			buf = buf_chain->next;
>>> -			kfree_skb(buf_chain);
>>> -		}
>>> +		link_kfree_skbuff(buf_chain);
>>>  		return tipc_port_reject_sections(sender, hdr, msg_sect,
>>>  						 len, TIPC_ERR_NO_NODE);
>>>  	}
>>> @@ -2306,11 +2290,7 @@ static int link_send_long_buf(struct tipc_link *l_ptr, struct sk_buff *buf)
>>>  		fragm = tipc_buf_acquire(fragm_sz + INT_H_SIZE);
>>>  		if (fragm == NULL) {
>>>  			kfree_skb(buf);
>>> -			while (buf_chain) {
>>> -				buf = buf_chain;
>>> -				buf_chain = buf_chain->next;
>>> -				kfree_skb(buf);
>>> -			}
>>> +			link_kfree_skbuff(buf_chain);
>>>  			return -ENOMEM;
>>>  		}
>>>  		msg_set_size(&fragm_hdr, fragm_sz + INT_H_SIZE);
>>>
>>
>>
>> .
>>
> 
> 


------------------------------------------------------------------------------
Sponsored by Intel(R) XDK 
Develop, test and display web and hybrid apps with a single code base.
Download it for free now!
http://pubads.g.doubleclick.net/gampad/clk?id=111408631&iu=/4140/ostg.clktrk
