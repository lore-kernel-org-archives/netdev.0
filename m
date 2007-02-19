From: Ben Greear <greearb@candelatech.com>
Subject: Re: [PATCH 1/2] RTNL and flush_scheduled_work deadlocks
Date: Sun, 18 Feb 2007 22:27:19 -0800
Message-ID: <45D94347.8060405@candelatech.com>
References: <20070216072928.GA1599@ff.dom.local> <45D55FF0.8090309@candelatech.com> <20070216103115.517f1a4c@freekitty> <45D60022.9060701@candelatech.com> <20070219061300.GA1640@ff.dom.local>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Stephen Hemminger <shemminger@linux-foundation.org>,
	Francois Romieu <romieu@fr.zoreil.com>, netdev@vger.kernel.org,
	Kyle Lucke <klucke@us.ibm.com>,
	Raghavendra Koushik <raghavendra.koushik@neterion.com>,
	Al Viro <viro@ftp.linux.org.uk>
To: Jarek Poplawski <jarkao2@o2.pl>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ns2.lanforge.com ([66.165.47.211]:57936 "EHLO ns2.lanforge.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752970AbXBSGaW (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 19 Feb 2007 01:30:22 -0500
In-Reply-To: <20070219061300.GA1640@ff.dom.local>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Jarek Poplawski wrote:
> On Fri, Feb 16, 2007 at 11:04:02AM -0800, Ben Greear wrote:
>   
>> Stephen Hemminger wrote:
>>     
>>> On Thu, 15 Feb 2007 23:40:32 -0800
>>> Ben Greear <greearb@candelatech.com> wrote:
>>>       
>>>> Maybe there should be something like an ASSERT_NOT_RTNL() in the 
>>>> flush_scheduled_work()
>>>> method?  If it's performance criticial, #ifdef it out if we're not 
>>>> debugging locks?
>>>>
>>>>         
>>> You can't safely add a check like that. What if another cpu had acquired
>>> RTNL and was unrelated.
>>>       
>> I guess there isn't a way to see if *this* thread is the owner of the RTNL
>> currently?  I think lockdep knows the owner...maybe could query it somehow,
>> or just save the owner in the mutex object when debugging is enabled...
>>     
>
> Here is my patch proposal to enable such thing
> (and to make ASSERT_RTNL simpler btw.).
>   
For performance reasons, I'd leave the rtnl_owner inside the
#if debugging locking code....

You are also changing the semantics of ASSERT_RTNL (assert *this thread* 
has rtnl, from the
old behaviour:  assert *some thread* has rtnl).  It may be better this
way, but it could break code that assumes the old behaviour.

Ben


> Signed-off-by: Jarek Poplawski <jarkao2@o2.pl>
>
> ---
>
>  include/linux/rtnetlink.h |   13 +++++++++++--
>  net/core/rtnetlink.c      |   29 ++++++++++++++++++++++++++---
>  2 files changed, 37 insertions(+), 5 deletions(-)
>
>
> diff -Nurp linux-2.6.20-git13-/include/linux/rtnetlink.h linux-2.6.20-git13/include/linux/rtnetlink.h
> --- linux-2.6.20-git13-/include/linux/rtnetlink.h	2007-02-04 19:44:54.000000000 +0100
> +++ linux-2.6.20-git13/include/linux/rtnetlink.h	2007-02-18 22:56:36.000000000 +0100
> @@ -704,16 +704,25 @@ extern int rtnl_trylock(void);
>  
>  extern void rtnetlink_init(void);
>  extern void __rtnl_unlock(void);
> +extern int rtnl_assert(void);
>  
>  #define ASSERT_RTNL() do { \
> -	if (unlikely(rtnl_trylock())) { \
> -		rtnl_unlock(); \
> +	if (unlikely(!rtnl_assert())) { \
>  		printk(KERN_ERR "RTNL: assertion failed at %s (%d)\n", \
>  		       __FILE__,  __LINE__); \
>  		dump_stack(); \
>  	} \
>  } while(0)
>  
> +/* Current process shouldn't hold RTNL lock: */
> +#define ASSERT_NOT_RTNL() do { \
> +	if (unlikely(rtnl_assert())) { \
> +		printk(KERN_ERR "NOT_RTNL: assertion failed at %s (%d)\n", \
> +		       __FILE__,  __LINE__); \
> +		dump_stack(); \
> +	} \
> +} while(0)
> +
>  #define BUG_TRAP(x) do { \
>  	if (unlikely(!(x))) { \
>  		printk(KERN_ERR "KERNEL: assertion (%s) failed at %s (%d)\n", \
> diff -Nurp linux-2.6.20-git13-/net/core/rtnetlink.c linux-2.6.20-git13/net/core/rtnetlink.c
> --- linux-2.6.20-git13-/net/core/rtnetlink.c	2007-02-15 20:07:11.000000000 +0100
> +++ linux-2.6.20-git13/net/core/rtnetlink.c	2007-02-18 22:50:13.000000000 +0100
> @@ -57,20 +57,33 @@
>  #endif	/* CONFIG_NET_WIRELESS_RTNETLINK */
>  
>  static DEFINE_MUTEX(rtnl_mutex);
> +static struct thread_info *rtnl_owner;
>  static struct sock *rtnl;
>  
>  void rtnl_lock(void)
>  {
> +#if !defined(CONFIG_DEBUG_MUTEXES) && !defined(CONFIG_DEBUG_SPINLOCK)
> +	WARN_ON(rtnl_owner == current_thread_info());
> +#endif
>  	mutex_lock(&rtnl_mutex);
> +	rtnl_owner = current_thread_info();
>  }
>  
>  void __rtnl_unlock(void)
>  {
> +#if !defined(CONFIG_DEBUG_MUTEXES) && !defined(CONFIG_DEBUG_SPINLOCK)
> +	WARN_ON(rtnl_owner != current_thread_info());
> +#endif
> +	rtnl_owner = NULL;
>  	mutex_unlock(&rtnl_mutex);
>  }
>  
>  void rtnl_unlock(void)
>  {
> +#if !defined(CONFIG_DEBUG_MUTEXES) && !defined(CONFIG_DEBUG_SPINLOCK)
> +	WARN_ON(rtnl_owner != current_thread_info());
> +#endif
> +	rtnl_owner = NULL;
>  	mutex_unlock(&rtnl_mutex);
>  	if (rtnl && rtnl->sk_receive_queue.qlen)
>  		rtnl->sk_data_ready(rtnl, 0);
> @@ -79,7 +92,16 @@ void rtnl_unlock(void)
>  
>  int rtnl_trylock(void)
>  {
> -	return mutex_trylock(&rtnl_mutex);
> +	int ret;
> +	
> +	if ((ret = mutex_trylock(&rtnl_mutex)))
> +		rtnl_owner = current_thread_info();
> +	return ret;
> +}
> +
> +int rtnl_assert(void)
> +{
> +	return (rtnl_owner == current_thread_info());
>  }
>  
>  int rtattr_parse(struct rtattr *tb[], int maxattr, struct rtattr *rta, int len)
> @@ -805,9 +827,9 @@ static void rtnetlink_rcv(struct sock *s
>  	unsigned int qlen = 0;
>  
>  	do {
> -		mutex_lock(&rtnl_mutex);
> +		rtnl_lock();
>  		netlink_run_queue(sk, &qlen, &rtnetlink_rcv_msg);
> -		mutex_unlock(&rtnl_mutex);
> +		__rtnl_unlock();
>  
>  		netdev_run_todo();
>  	} while (qlen);
> @@ -893,3 +915,4 @@ EXPORT_SYMBOL(rtnl_unlock);
>  EXPORT_SYMBOL(rtnl_unicast);
>  EXPORT_SYMBOL(rtnl_notify);
>  EXPORT_SYMBOL(rtnl_set_sk_err);
> +EXPORT_SYMBOL(rtnl_assert);
> -
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
>   


-- 
Ben Greear <greearb@candelatech.com> 
Candela Technologies Inc  http://www.candelatech.com


