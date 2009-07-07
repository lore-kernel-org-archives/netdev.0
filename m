From: =?ISO-8859-2?Q?Pawe=B3_Staszewski?= <pstaszewski@itcare.pl>
Subject: Re: [PATCH net-2.6] Re: rib_trie / Fix inflate_threshold_root.	Now=15
 size=11 bits
Date: Wed, 08 Jul 2009 01:23:01 +0200
Message-ID: <4A53D8D5.5030601@itcare.pl>
References: <20090702053216.GA4954@ff.dom.local> <4A4C48FD.7040002@itcare.pl> <20090702060011.GB4954@ff.dom.local> <4A4FF34E.7080001@itcare.pl> <4A4FF40B.5090003@itcare.pl> <20090705162003.GA19477@ami.dom.local> <20090705173208.GB19477@ami.dom.local> <20090705213232.GG8943@linux.vnet.ibm.com> <20090705222301.GA3203@ami.dom.local> <4A513D0D.5070204@itcare.pl> <20090706090207.GB3065@ami.dom.local>
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="------------070700030705060403010203"
Cc: "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>,
	Linux Network Development list <netdev@vger.kernel.org>,
	Robert Olsson <robert@robur.slu.se>
To: Jarek Poplawski <jarkao2@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.iq.pl ([86.111.241.19]:47873 "EHLO smtp.iq.pl"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756583AbZGGXX0 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 7 Jul 2009 19:23:26 -0400
In-Reply-To: <20090706090207.GB3065@ami.dom.local>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This is a multi-part message in MIME format.
--------------070700030705060403010203
Content-Type: text/plain; charset=ISO-8859-2; format=flowed
Content-Transfer-Encoding: 8bit

Jarek Poplawski pisze:
> On Mon, Jul 06, 2009 at 01:53:49AM +0200, Pawe³ Staszewski wrote:
> ...
>   
>> So i make tests with changing sync_pages
>> And
>>
>> ####################################
>> sync_pages: 64
>> total size reach maximum in 17sec
>>     
> ...
>   
>> ######################################
>> sync_pages: 128
>> Fib trie Total size reach max in 14sec
>>     
> ...
>   
>> #########################################
>> sync_pages: 256
>> hmm no difference also in 10sec
>>     
>
> 14 == 10!? ;-)
> ...
>   
:) i miss one test
>> And with sync_pages higher that 256 time of filling kernel routes is the  
>> same approx 10sec.
>>     
>
> Hmm... So, it's better than I expected; syncing after 128 or 256 pages
> could be quite reasonable. But then it would be interesting to find
> out if with such a safety we could go back to more aggressive values
> for possibly better performance. So here is 'the same' patch (so the
> previous, take 8, should be reverted), but with additional possibility
> to change:
> /sys/module/fib_trie/parameters/inflate_threshold_root
>
> I guess, you could try e.g. if: sync_pages 256, inflate_threshold_root 15
> can give faster lookups (or lower cpu loads); with this these inflate
> warnings could be back btw.; or maybe you'll find something in between
> like inflate_threshold_root 20 is optimal for you. (I think it should be
> enough to try this only for PREEMPT_NONE unless you have spare time ;-)
>
>   
And i can't make good tests with cpu load because of problem that i have 
from "weird problem" emails
It depend when i make mpstat to check cpu load and for what time because 
every 15 sec i have 1 do 3 % of cpu and after 15 sec i have almost 40% 
cpu load for next 15 sec.
I try to make mpstat -P ALL 1 60
but after 15 sec of 1 to 3 % cpu load this next higher cpu load if 
different everytime it balance from 30 to 50%

so i make test shorter when cpu load is 1 to 3 % - "mpstat -P ALL 1 10"
output in attached file

Regards
Pawe³ Staszewski


> Thanks,
> Jarek P.
> ---> (synchronize take 9; apply on top of the 2.6.29.x with the last
>   	all-in-one patch, or net-2.6)
>
>  net/ipv4/fib_trie.c |   18 ++++++++++++++++--
>  1 files changed, 16 insertions(+), 2 deletions(-)
>
> diff --git a/net/ipv4/fib_trie.c b/net/ipv4/fib_trie.c
> index 00a54b2..e8fca11 100644
> --- a/net/ipv4/fib_trie.c
> +++ b/net/ipv4/fib_trie.c
> @@ -71,6 +71,7 @@
>  #include <linux/netlink.h>
>  #include <linux/init.h>
>  #include <linux/list.h>
> +#include <linux/moduleparam.h>
>  #include <net/net_namespace.h>
>  #include <net/ip.h>
>  #include <net/protocol.h>
> @@ -164,6 +165,10 @@ static struct tnode *inflate(struct trie *t, struct tnode *tn);
>  static struct tnode *halve(struct trie *t, struct tnode *tn);
>  /* tnodes to free after resize(); protected by RTNL */
>  static struct tnode *tnode_free_head;
> +static size_t tnode_free_size;
> +
> +static int sync_pages __read_mostly = 1000;
> +module_param(sync_pages, int, 0640);
>  
>  static struct kmem_cache *fn_alias_kmem __read_mostly;
>  static struct kmem_cache *trie_leaf_kmem __read_mostly;
> @@ -316,9 +321,11 @@ static inline void check_tnode(const struct tnode *tn)
>  
>  static const int halve_threshold = 25;
>  static const int inflate_threshold = 50;
> -static const int halve_threshold_root = 15;
> -static const int inflate_threshold_root = 25;
>  
> +static int inflate_threshold_root __read_mostly = 25;
> +module_param(inflate_threshold_root, int, 0640);
> +
> +#define halve_threshold_root	(inflate_threshold_root / 2 + 1)
>  
>  static void __alias_free_mem(struct rcu_head *head)
>  {
> @@ -393,6 +400,8 @@ static void tnode_free_safe(struct tnode *tn)
>  	BUG_ON(IS_LEAF(tn));
>  	tn->tnode_free = tnode_free_head;
>  	tnode_free_head = tn;
> +	tnode_free_size += sizeof(struct tnode) +
> +			   (sizeof(struct node *) << tn->bits);
>  }
>  
>  static void tnode_free_flush(void)
> @@ -404,6 +413,11 @@ static void tnode_free_flush(void)
>  		tn->tnode_free = NULL;
>  		tnode_free(tn);
>  	}
> +
> +	if (tnode_free_size >= PAGE_SIZE * sync_pages) {
> +		tnode_free_size = 0;
> +		synchronize_rcu();
> +	}
>  }
>  
>  static struct leaf *leaf_new(void)
> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
>
>
>   


--------------070700030705060403010203
Content-Type: text/plain;
 name="sync_pages.txt"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="sync_pages.txt"

sync_pages: 256
inflate_threshold_root: 10
Average:     CPU    %usr   %nice    %sys %iowait    %irq   %soft  %steal  %guest   %idle
Average:     all    0.00    0.00    0.00    0.00    0.00    0.60    0.00    0.00   99.40
Average:       0    0.00    0.00    0.00    0.00    0.00    0.60    0.00    0.00   99.40
Average:       1    0.00    0.00    0.00    0.00    0.00    0.40    0.00    0.00   99.60

sync_pages: 256
inflate_threshold_root: 15
Average:     CPU    %usr   %nice    %sys %iowait    %irq   %soft  %steal  %guest   %idle
Average:     all    0.00    0.00    0.10    0.00    0.00    0.70    0.00    0.00   99.20
Average:       0    0.00    0.00    0.00    0.00    0.20    0.80    0.00    0.00   99.00
Average:       1    0.00    0.00    0.20    0.00    0.00    0.61    0.00    0.00   99.19

sync_pages: 256
inflate_threshold_root: 20
Average:     CPU    %usr   %nice    %sys %iowait    %irq   %soft  %steal  %guest   %idle
Average:     all    0.00    0.00    0.00    0.00    0.10    0.80    0.00    0.00   99.10
Average:       0    0.00    0.00    0.00    0.00    0.00    1.00    0.00    0.00   99.00
Average:       1    0.00    0.00    0.00    0.00    0.00    0.61    0.00    0.00   99.39

sync_pages: 256
inflate_threshold_root: 25
Average:     CPU    %usr   %nice    %sys %iowait    %irq   %soft  %steal  %guest   %idle
Average:     all    0.00    0.00    0.00    0.00    0.00    0.70    0.00    0.00   99.30
Average:       0    0.00    0.00    0.00    0.00    0.20    1.00    0.00    0.00   98.80
Average:       1    0.00    0.00    0.00    0.00    0.00    0.40    0.00    0.00   99.60


sync_pages: 512
inflate_threshold_root: 10
Average:     CPU    %usr   %nice    %sys %iowait    %irq   %soft  %steal  %guest   %idle
Average:     all    0.00    0.00    0.10    0.00    0.10    0.60    0.00    0.00   99.20
Average:       0    0.00    0.00    0.20    0.00    0.00    1.00    0.00    0.00   98.80
Average:       1    0.00    0.00    0.00    0.00    0.00    0.40    0.00    0.00   99.60

sync_pages: 512
inflate_threshold_root: 15
Average:     CPU    %usr   %nice    %sys %iowait    %irq   %soft  %steal  %guest   %idle
Average:     all    0.00    0.00    0.20    0.00    0.00    1.10    0.00    0.00   98.70
Average:       0    0.00    0.00    0.40    0.00    0.00    1.00    0.00    0.00   98.60
Average:       1    0.00    0.00    0.00    0.00    0.00    1.01    0.00    0.00   98.99

sync_pages: 512
inflate_threshold_root: 20
Average:     CPU    %usr   %nice    %sys %iowait    %irq   %soft  %steal  %guest   %idle
Average:     all    0.00    0.00    0.10    0.00    0.10    1.01    0.00    0.00   98.79
Average:       0    0.00    0.00    0.20    0.00    0.20    1.40    0.00    0.00   98.20
Average:       1    0.00    0.00    0.00    0.00    0.00    0.61    0.00    0.00   99.39

sync_pages: 512
inflate_threshold_root: 25
Average:     CPU    %usr   %nice    %sys %iowait    %irq   %soft  %steal  %guest   %idle
Average:     all    0.00    0.00    0.00    0.00    0.10    0.90    0.00    0.00   99.00
Average:       0    0.00    0.00    0.00    0.00    0.00    1.00    0.00    0.00   99.00
Average:       1    0.00    0.00    0.00    0.00    0.20    0.80    0.00    0.00   99.00

--------------070700030705060403010203--
