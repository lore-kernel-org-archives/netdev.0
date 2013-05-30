From: Eliezer Tamir <eliezer.tamir@linux.intel.com>
Subject: Re: [PATCH v7 net-next 2/5] net: implement support
 for low latency socket polling
Date: Thu, 30 May 2013 23:01:13 +0300
Message-ID: <51A7B009.3030709@linux.intel.com>
References: <20130530114045.12653.79183.stgit@ladj378.jer.intel.com>
	<20130530114111.12653.25023.stgit@ladj378.jer.intel.com>
	<51A76B2F.8010904@mellanox.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: Willem de Bruijn <willemb@google.com>, Or Gerlitz <or.gerlitz@gmail.com>,
	e1000-devel@lists.sourceforge.net, netdev@vger.kernel.org,
	HPA <hpa@zytor.com>, Jesse Brandeburg <jesse.brandeburg@intel.com>,
	Alex Rosenbaum <alexr@mellanox.com>, linux-kernel@vger.kernel.org,
	Eliezer Tamir <eliezer@tamir.org.il>, Andi Kleen <andi@firstfloor.org>,
	Ben Hutchings <bhutchings@solarflare.com>,
	Eric Dumazet <erdnetdev@gmail.com>, Eilon Greenstien <eilong@broadcom.com>,
	David Miller <davem@davemloft.net>
To: Amir Vadai <amirv@mellanox.com>
Return-path: <e1000-devel-bounces@lists.sourceforge.net>
In-Reply-To: <51A76B2F.8010904@mellanox.com>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/e1000-devel>,
	<mailto:e1000-devel-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum_name=e1000-devel>
List-Post: <mailto:e1000-devel@lists.sourceforge.net>
List-Help: <mailto:e1000-devel-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/e1000-devel>,
	<mailto:e1000-devel-request@lists.sourceforge.net?subject=subscribe>
Errors-To: e1000-devel-bounces@lists.sourceforge.net
List-Id: netdev.vger.kernel.org

On 30/05/2013 18:07, Amir Vadai wrote:
> On 30/05/2013 14:41, Eliezer Tamir wrote:
>> diff --git a/fs/select.c b/fs/select.c
>> @@ -486,6 +488,8 @@ int do_select(int n, fd_set_bits *fds, struct timespec *end_time)
>>   			break;
>>   		}
>>
>> +		if (can_poll_ll(ll_time))
>> +			continue;
> I don't see here discrimination between sockets that you want to poll
> and other sockets.
> So it means that select will busy poll every type of file descriptor
> instead of going to sleep.
> Should have a condition with something like sk_valid_ll()

As I said earlier, select and poll are far from complete.
We are working on this.
Right now when you turn this on, all sockets get the same treatment.
sk_valid_ll() can't work here, because we don't have a single socket to 
work with.

At the moment, I think the right way to solve this might be to add
new flags to poll.h So that select/poll can signal to sock_poll
that it wants to busy-wait and sock_poll can tell select/poll that
it has found a socket that can support it.

Remember that the information is dynamic so we can't know in advance
which sockets can busy-poll.

If anyone else has a suggestion I would really like to hear it.

>
>> +static inline void sk_mark_ll(struct sock *sk, struct sk_buff *skb)
>> +{
>> +}
>> +
>> +static inline bool can_poll_ll(unsigned long end_time)
> should use here cycles_t too.

yes

>
>> +{
>> +	return false;
>> +}
>> +
>> +#endif /* CONFIG_NET_LL_RX_POLL */
>> +#endif /* _LINUX_NET_LL_POLL_H */
>
>
> Also, something general about this patch. I think you should split out
> to separate patches all the users of the feature, like you did for TCP.
> I would suggest small patches for UDP, select and poll.

Splitting out the users of the features as you call it will only move 
out about 30 lines of patch, I think it will make reviewing harder since 
you will not be able to see the whole picture in one patch.
But if anyone else thinks this is a good idea, I will do it.

-Eliezer

------------------------------------------------------------------------------
Introducing AppDynamics Lite, a free troubleshooting tool for Java/.NET
Get 100% visibility into your production application - at no cost.
Code-level diagnostics for performance bottlenecks with <2% overhead
Download for free and get started troubleshooting in minutes.
http://p.sf.net/sfu/appdyn_d2d_ap1
_______________________________________________
E1000-devel mailing list
E1000-devel@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/e1000-devel
To learn more about Intel&#174; Ethernet, visit http://communities.intel.com/community/wired
