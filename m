From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net-next 2/2] net sched act_vlan: VLAN action rewrite to
 use RCU lock/unlock and update
Date: Wed, 11 Oct 2017 06:10:29 -0700
Message-ID: <1507727429.31614.22.camel@edumazet-glaptop3.roam.corp.google.com>
References: <1507689219-22993-1-git-send-email-manish.kurup@verizon.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: jhs@mojatatu.com, xiyou.wangcong@gmail.com, jiri@resnulli.us,
        davem@davemloft.net, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org, aring@mojatatu.com, mrv@mojatatu.com,
        manish.kurup@verizon.com
To: Manish Kurup <kurup.manish@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1507689219-22993-1-git-send-email-manish.kurup@verizon.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, 2017-10-10 at 22:33 -0400, Manish Kurup wrote:
> Using a spinlock in the VLAN action causes performance issues when the VLAN
> action is used on multiple cores. Rewrote the VLAN action to use RCU read
> locking for reads and updates instead.
> 
> Signed-off-by: Manish Kurup <manish.kurup@verizon.com>
> ---
>  include/net/tc_act/tc_vlan.h | 21 ++++++++-----
>  net/sched/act_vlan.c         | 73 ++++++++++++++++++++++++++++++--------------
>  2 files changed, 63 insertions(+), 31 deletions(-)
> 
> diff --git a/include/net/tc_act/tc_vlan.h b/include/net/tc_act/tc_vlan.h
> index c2090df..67fd355 100644
> --- a/include/net/tc_act/tc_vlan.h
> +++ b/include/net/tc_act/tc_vlan.h
> @@ -13,12 +13,17 @@
>  #include <net/act_api.h>
>  #include <linux/tc_act/tc_vlan.h>
>  
> +struct tcf_vlan_params {
> +	struct rcu_head   rcu;
> +	int               tcfv_action;
> +	u16               tcfv_push_vid;
> +	__be16            tcfv_push_proto;
> +	u8                tcfv_push_prio;
> +};
> +
>  struct tcf_vlan {
>  	struct tc_action	common;
> -	int			tcfv_action;
> -	u16			tcfv_push_vid;
> -	__be16			tcfv_push_proto;
> -	u8			tcfv_push_prio;
> +	struct tcf_vlan_params __rcu *vlan_p;
>  };
>  #define to_vlan(a) ((struct tcf_vlan *)a)
>  
> @@ -33,22 +38,22 @@ static inline bool is_tcf_vlan(const struct tc_action *a)
>  
>  static inline u32 tcf_vlan_action(const struct tc_action *a)
>  {
> -	return to_vlan(a)->tcfv_action;
> +	return to_vlan(a)->vlan_p->tcfv_action;

This is not proper RCU : ->vlan_p should be read once, and using
rcu_dereference()

So the caller should provide to this helper the 'p' pointer instead of
'a'


CONFIG_SPARSE_RCU_POINTER=y

and make C=2 would probably give you warnings about that.
