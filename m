From: "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>
Subject: Re: net: rcu warnings in ip6fl_get_first
Date: Fri, 8 Feb 2013 11:19:32 -0800
Message-ID: <20130208191932.GG2666@linux.vnet.ibm.com>
References: <51140154.9040901@oracle.com>
 <kf1kul$699$2@ger.gmane.org>
Reply-To: paulmck@linux.vnet.ibm.com
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org
To: Cong Wang <xiyou.wangcong@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <kf1kul$699$2@ger.gmane.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, Feb 08, 2013 at 01:38:29AM +0000, Cong Wang wrote:
> On Thu, 07 Feb 2013 at 19:32 GMT, Sasha Levin <sasha.levin@oracle.com> wrote:
> > Hi guys,
> >
> > I got the following while fuzzing with trinity inside a KVM tools guest:
> >
> > [   51.680236] ===============================
> > [   51.681914] [ INFO: suspicious RCU usage. ]
> > [   51.683610] 3.8.0-rc6-next-20130206-sasha-00028-g83214f7-dirty #276 Tainted: G        W
> > [   51.686703] -------------------------------
> > [   51.688281] net/ipv6/ip6_flowlabel.c:671 suspicious rcu_dereference_check() usage!
> > [   51.691345]
> 
> It should use rcu_dereference_bh()...
> 
> diff --git a/net/ipv6/ip6_flowlabel.c b/net/ipv6/ip6_flowlabel.c
> index ea42bf4..c50080f 100644
> --- a/net/ipv6/ip6_flowlabel.c
> +++ b/net/ipv6/ip6_flowlabel.c
> @@ -65,13 +65,13 @@ static DEFINE_SPINLOCK(ip6_fl_lock);
>  static DEFINE_SPINLOCK(ip6_sk_fl_lock);
> 
>  #define for_each_fl_rcu(hash, fl)				\
> -	for (fl = rcu_dereference(fl_ht[(hash)]);		\
> +	for (fl = rcu_dereference_bh(fl_ht[(hash)]);		\
>  	     fl != NULL;					\
> -	     fl = rcu_dereference(fl->next))
> +	     fl = rcu_dereference_hb(fl->next))

Small but important typo in the preceding line, should be:

 +	     fl = rcu_dereference_bh(fl->next))

 							Thanx, Paul

>  #define for_each_fl_continue_rcu(fl)				\
> -	for (fl = rcu_dereference(fl->next);			\
> +	for (fl = rcu_dereference_bh(fl->next);			\
>  	     fl != NULL;					\
> -	     fl = rcu_dereference(fl->next))
> +	     fl = rcu_dereference_bh(fl->next))
> 
>  #define for_each_sk_fl_rcu(np, sfl)				\
>  	for (sfl = rcu_dereference_bh(np->ipv6_fl_list);	\
> 
> --
> To unsubscribe from this list: send the line "unsubscribe linux-kernel" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
> Please read the FAQ at  http://www.tux.org/lkml/
> 
