From: Ying Xue <ying.xue@windriver.com>
Subject: Re: [PATCH net-next RESEND 2/2] ipv6: fix sparse warning
Date: Thu, 11 Dec 2014 09:56:33 +0800
Message-ID: <5488F9D1.9060109@windriver.com>
References: <1418201167-9591-1-git-send-email-ying.xue@windriver.com> <1418201167-9591-3-git-send-email-ying.xue@windriver.com> <20141210160406.GS25340@linux.vnet.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="windows-1252"
Content-Transfer-Encoding: 7bit
Cc: <davem@davemloft.net>, <eric.dumazet@gmail.com>,
	<jon.maloy@ericsson.com>, <erik.hugne@ericsson.com>,
	<netdev@vger.kernel.org>, <kbuild-all@01.org>,
	<linux-kernel@vger.kernel.org>
To: <paulmck@linux.vnet.ibm.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20141210160406.GS25340@linux.vnet.ibm.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 12/11/2014 12:04 AM, Paul E. McKenney wrote:
> On Wed, Dec 10, 2014 at 04:46:07PM +0800, Ying Xue wrote:
>> This fixes the following spare warning when using
>>
>> make C=1 CF=-D__CHECK_ENDIAN__ net/ipv6/addrconf.o
>> net/ipv6/addrconf.c:3495:9: error: incompatible types in comparison expression (different address spaces)
>> net/ipv6/addrconf.c:3495:9: error: incompatible types in comparison expression (different address spaces)
>> net/ipv6/addrconf.c:3495:9: error: incompatible types in comparison expression (different address spaces)
>> net/ipv6/addrconf.c:3495:9: error: incompatible types in comparison expression (different address spaces)
>>
>> To silence above spare complaint, an RCU annotation should be added
>> to "next" pointer of hlist_node structure through hlist_next_rcu()
>> macro when iterating over a hlist with
>> hlist_for_each_entry_continue_rcu_bh().
>>
>> By the way, this commit also resolves the same error appearing in
>> hlist_for_each_entry_continue_rcu().
>>
>> Signed-off-by: Ying Xue <ying.xue@windriver.com>
> 
> If you pull the rculist.h changes from the first patch into this one,
> I will queue it up through -rcu.
> 

Please just queue this patch into your RCU tree. Some changes of the
first patch currently only exists in net-next tree, so it cannot be
merged into RCU tree now. Therefore, please temporarily ignore it. In
next 3.19 development cycle, I will resubmit it to you.

Thanks,
Ying

> 							Thanx, Paul
> 
>> ---
>>  include/linux/rculist.h |   16 ++++++++--------
>>  1 file changed, 8 insertions(+), 8 deletions(-)
>>
>> diff --git a/include/linux/rculist.h b/include/linux/rculist.h
>> index 866d9c9..32bd4ad 100644
>> --- a/include/linux/rculist.h
>> +++ b/include/linux/rculist.h
>> @@ -524,11 +524,11 @@ static inline void hlist_add_behind_rcu(struct hlist_node *n,
>>   * @member:	the name of the hlist_node within the struct.
>>   */
>>  #define hlist_for_each_entry_continue_rcu(pos, member)			\
>> -	for (pos = hlist_entry_safe(rcu_dereference((pos)->member.next),\
>> -			typeof(*(pos)), member);			\
>> +	for (pos = hlist_entry_safe(rcu_dereference_raw(hlist_next_rcu( \
>> +			&(pos)->member)), typeof(*(pos)), member);	\
>>  	     pos;							\
>> -	     pos = hlist_entry_safe(rcu_dereference((pos)->member.next),\
>> -			typeof(*(pos)), member))
>> +	     pos = hlist_entry_safe(rcu_dereference_raw(hlist_next_rcu(	\
>> +			&(pos)->member)), typeof(*(pos)), member))
>>
>>  /**
>>   * hlist_for_each_entry_continue_rcu_bh - iterate over a hlist continuing after current point
>> @@ -536,11 +536,11 @@ static inline void hlist_add_behind_rcu(struct hlist_node *n,
>>   * @member:	the name of the hlist_node within the struct.
>>   */
>>  #define hlist_for_each_entry_continue_rcu_bh(pos, member)		\
>> -	for (pos = hlist_entry_safe(rcu_dereference_bh((pos)->member.next),\
>> -			typeof(*(pos)), member);			\
>> +	for (pos = hlist_entry_safe(rcu_dereference_bh(hlist_next_rcu(  \
>> +			&(pos)->member)), typeof(*(pos)), member);	\
>>  	     pos;							\
>> -	     pos = hlist_entry_safe(rcu_dereference_bh((pos)->member.next),\
>> -			typeof(*(pos)), member))
>> +	     pos = hlist_entry_safe(rcu_dereference_bh(hlist_next_rcu(	\
>> +			&(pos)->member)), typeof(*(pos)), member))
>>
>>  /**
>>   * hlist_for_each_entry_from_rcu - iterate over a hlist continuing from current point
>> -- 
>> 1.7.9.5
>>
> 
> 
> 
