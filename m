From: Wang Jian <lark@linux.net.cn>
Subject: Re: [PATCH] [PKT_SCHED]: improve hashing performance of cls_fw
Date: Thu, 07 Apr 2005 21:31:38 +0800
Message-ID: <20050407212340.02D2.LARK@linux.net.cn>
References: <1112872055.1117.123.camel@jzny.localdomain> <20050407130925.GU26731@postel.suug.ch>
Mime-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@davemloft.net>,
        Jamal Hadi Salim <hadi@cyberus.ca>, netdev <netdev@oss.sgi.com>
Return-path: <netdev-bounce@oss.sgi.com>
To: Thomas Graf <tgraf@suug.ch>
In-Reply-To: <20050407130925.GU26731@postel.suug.ch>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Hi Thomas Graf,

Would you please test this case?

(0..1024) << 16

The old hash gives a 1024 depth bucket for this case.

And I am not sure if there is a bad range (0..n) << s which is mapped
into one bucket.


On Thu, 7 Apr 2005 15:09:25 +0200, Thomas Graf <tgraf@suug.ch> wrote:

> Some test results for the new hashing
> 
> Test-1: hash 0..2147483648
> 
> old 256 buckets hash (enum):
> empty buckets: 0 average chain length: 8388607.996 min: 8388607 max: 8388608
> 
> new 1024 buckets hash (enum):
> empty buckets: 0 average chain length: 2097151.999 min: 2097151 max: 2097152
> 
> Test-2: hash 65536*rand()
> 
> old 256 buckets hash (rand):
> empty buckets: 0 average chain length: 256.000 min: 222 max: 296
> 
> new 1024 buckets hash (rand):
> empty buckets: 0 average chain length: 64.000 min: 40 max: 93
> 
> Test-3: hash 1024*rand()
> 
> old 256 buckets hash (rand):
> empty buckets: 3 average chain length: 4.047 min: 0 max: 9
> 
> new 1024 buckets hash (rand):
> empty buckets: 380 average chain length: 1.590 min: 0 max: 5
> 
> Test-4: total time for 2147483648 hashes, 10 runs
> 
>       old hashing algorithm    new hashing algorithm
>              1.619s                     1.610s
>              1.623s                     1.611s
>              1.625s                     1.612s
>              1.629s                     1.614s
>              1.633s                     1.616s
>              1.637s                     1.621s
>              1.638s                     1.625s
>              1.639s                     1.630s
>              1.644s                     1.632s
>              1.737s                     1.658s
> 
> 
> Please do a
> 
> 	bk pull bk://kernel.bkbits.net/tgraf/net-2.6-cls_fw
> 
> This will update the following files:
> 
>  net/sched/cls_fw.c |   31 +++++++++++++++++++++++++++----
>  1 files changed, 27 insertions(+), 4 deletions(-)
> 
> through these ChangeSets:
> 
> # This is a BitKeeper generated diff -Nru style patch.
> #
> # ChangeSet
> #   2005/04/07 14:23:09+02:00 tgraf@suug.ch 
> #   [PKT_SCHED]: improve hashing performance of cls_fw
> #   
> #   Calculate hashtable size to fit into a page instead of a hardcoded
> #   256 buckets hash table. Results in a 1024 buckets hashtable on
> #   most systems.
> #   
> #   Replace old naive extract-8-lsb-bits algorithm with a better
> #   algorithm xor'ing 3 or 4 bit fields at the size of the hashtable
> #   array index in order to improve distribution if the majority of
> #   the lower bits are unused while keeping zero collision behaviour
> #   for the most common use case.
> #   
> #   Thanks to Wang Jian <lark@linux.net.cn> for bringing this issue
> #   to attention and to Eran Mann <emann@mrv.com> for the initial
> #   idea for this new algorithm.
> #   
> #   Signed-off-by: Thomas Graf <tgraf@suug.ch>
> #   Signed-off-by: David S. Miller <davem@davemloft.net>
> # 
> # net/sched/cls_fw.c
> #   2005/04/07 14:22:58+02:00 tgraf@suug.ch +27 -4
> #   [PKT_SCHED]: improve hashing performance of cls_fw
> # 
> diff -Nru a/net/sched/cls_fw.c b/net/sched/cls_fw.c
> --- a/net/sched/cls_fw.c	2005-04-07 14:55:55 +02:00
> +++ b/net/sched/cls_fw.c	2005-04-07 14:55:55 +02:00
> @@ -46,9 +46,11 @@
>  #include <net/act_api.h>
>  #include <net/pkt_cls.h>
>  
> +#define HTSIZE (PAGE_SIZE/sizeof(struct fw_filter *))
> +
>  struct fw_head
>  {
> -	struct fw_filter *ht[256];
> +	struct fw_filter *ht[HTSIZE];
>  };
>  
>  struct fw_filter
> @@ -69,7 +71,28 @@
>  
>  static __inline__ int fw_hash(u32 handle)
>  {
> -	return handle&0xFF;
> +	if (HTSIZE == 4096)
> +		return ((handle >> 24) & 0xFFF) ^
> +		       ((handle >> 12) & 0xFFF) ^
> +		       (handle & 0xFFF);
> +	else if (HTSIZE == 2048)
> +		return ((handle >> 22) & 0x7FF) ^
> +		       ((handle >> 11) & 0x7FF) ^
> +		       (handle & 0x7FF);
> +	else if (HTSIZE == 1024)
> +		return ((handle >> 20) & 0x3FF) ^
> +		       ((handle >> 10) & 0x3FF) ^
> +		       (handle & 0x3FF);
> +	else if (HTSIZE == 512)
> +		return (handle >> 27) ^
> +		       ((handle >> 18) & 0x1FF) ^
> +		       ((handle >> 9) & 0x1FF) ^
> +		       (handle & 0x1FF);
> +	else if (HTSIZE == 256) {
> +		u8 *t = (u8 *) &handle;
> +		return t[0] ^ t[1] ^ t[2] ^ t[3];
> +	} else 
> +		return handle & (HTSIZE - 1);
>  }
>  
>  static int fw_classify(struct sk_buff *skb, struct tcf_proto *tp,
> @@ -152,7 +175,7 @@
>  	if (head == NULL)
>  		return;
>  
> -	for (h=0; h<256; h++) {
> +	for (h=0; h<HTSIZE; h++) {
>  		while ((f=head->ht[h]) != NULL) {
>  			head->ht[h] = f->next;
>  			fw_delete_filter(tp, f);
> @@ -291,7 +314,7 @@
>  	if (arg->stop)
>  		return;
>  
> -	for (h = 0; h < 256; h++) {
> +	for (h = 0; h < HTSIZE; h++) {
>  		struct fw_filter *f;
>  
>  		for (f = head->ht[h]; f; f = f->next) {



-- 
  lark
