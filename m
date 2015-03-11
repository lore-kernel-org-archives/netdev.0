From: Ying Xue <ying.xue@windriver.com>
Subject: Re: [PATCH net-next v2] tipc: fix undefined
 __ipv6_sock_mc_join compile error
Date: Wed, 11 Mar 2015 11:34:01 +0800
Message-ID: <54FFB7A9.5080602@windriver.com>
References: <1425976885-18258-1-git-send-email-ying.xue@windriver.com>
	<54FF3CE1.3080804@cogentembedded.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: jon.maloy@ericsson.com, netdev@vger.kernel.org,
	Paul.Gortmaker@windriver.com,
	tipc-discussion@lists.sourceforge.net, kbuild-all@01.org,
	fengguang.wu@intel.com
To: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>, <davem@davemloft.net>
Return-path: <tipc-discussion-bounces@lists.sourceforge.net>
In-Reply-To: <54FF3CE1.3080804@cogentembedded.com>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/tipc-discussion>,
	<mailto:tipc-discussion-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum_name=tipc-discussion>
List-Post: <mailto:tipc-discussion@lists.sourceforge.net>
List-Help: <mailto:tipc-discussion-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/tipc-discussion>,
	<mailto:tipc-discussion-request@lists.sourceforge.net?subject=subscribe>
Errors-To: tipc-discussion-bounces@lists.sourceforge.net
List-Id: netdev.vger.kernel.org

On 03/11/2015 02:50 AM, Sergei Shtylyov wrote:
> Hello.
> 
> On 03/10/2015 11:41 AM, Ying Xue wrote:
> 
>> When CONFIG_IPV6 option is disabled, below error will appear while
>> building TIPC module:
> 
>> ERROR: "__ipv6_sock_mc_join" [net/tipc/tipc.ko] undefined!
>> make[1]: *** [__modpost] Error 1
>> make: *** [net/tipc/tipc.ko] Error 1
> 
>> This is because we don't check whether or not the CONFIG_IPV6 is
>> enabled when calling __ipv6_sock_mc_join().
> 
>> In addition, especially when TIPC=y, TIPC_MEDIA_UDP=y, and IPV6=m, TIPC
>> module is also unable to be successfully built. Therefore, we add a
>> dependency condition like (IPV6 || IPV6=n) to avoid the error.
> 
>> Fixes: d0f91938bede ("tipc: add ip/udp media type")
>> Reported-by: Wu Fengguang <fengguang.wu@intel.com>
>> Cc: Kbuild test robot <kbuild-all@01.org>
>> Signed-off-by: Ying Xue <ying.xue@windriver.com>
>> ---
>> v2:
>>   Fix another compile error when TIPC=y, TIPC_MEDIA_UDP=y, and IPV6=m
> 
>>   net/tipc/Kconfig     |    1 +
>>   net/tipc/udp_media.c |    2 ++
>>   2 files changed, 3 insertions(+)
> 
>> diff --git a/net/tipc/Kconfig b/net/tipc/Kconfig
>> index c25a3a1..6f217ba 100644
>> --- a/net/tipc/Kconfig
>> +++ b/net/tipc/Kconfig
>> @@ -5,6 +5,7 @@
>>   menuconfig TIPC
>>       tristate "The TIPC Protocol"
>>       depends on INET
>> +    depends on (IPV6 || IPV6=n)
> 
>    Parens not needed.
> 
> [...]
>> diff --git a/net/tipc/udp_media.c b/net/tipc/udp_media.c
>> index fc2fb11..6763002 100644
>> --- a/net/tipc/udp_media.c
>> +++ b/net/tipc/udp_media.c
>> @@ -247,10 +247,12 @@ static int enable_mcast(struct udp_bearer *ub, struct
>> udp_media_addr *remote)
>>           mreqn.imr_multiaddr = remote->ipv4;
>>           mreqn.imr_ifindex = ub->ifindex;
>>           err = __ip_mc_join_group(sk, &mreqn);
>> +#if IS_ENABLED(CONFIG_IPV6)
>>       } else {
> 
>    How about:
> 
>     } else if (IS_ENABLED(CONFIG_IPV6)) {
> 

Sorry, I try to the suggestion, but it doesn't work.

Thanks,
Ying

>>           if (!ipv6_addr_is_multicast(&remote->ipv6))
>>               return 0;
>>           err = __ipv6_sock_mc_join(sk, ub->ifindex, &remote->ipv6);
>> +#endif
>>       }
>>       return err;
>>   }
> 
> WBR, Sergei
> 
> 
> 


------------------------------------------------------------------------------
Dive into the World of Parallel Programming The Go Parallel Website, sponsored
by Intel and developed in partnership with Slashdot Media, is your hub for all
things parallel software development, from weekly thought leadership blogs to
news, videos, case studies, tutorials and more. Take a look and join the 
conversation now. http://goparallel.sourceforge.net/
