From: Paul McKenney <Paul.McKenney@us.ibm.com>
Subject: Re: [RFC] Use RCU for fib_rules
Date: Wed, 31 Mar 2004 15:40:11 -0800
Sender: netdev-bounce@oss.sgi.com
Message-ID: <OFD202E31E.B19A62BE-ON88256E68.0081FE2A-88256E68.008205DE@us.ibm.com>
References: <20040331112839.02e8d4c2@dell_ss3.pdx.osdl.net>
Mime-Version: 1.0
Content-Type: multipart/alternative;
	Boundary="0__=07BBE4FBDF1278BA8f9e8a93df938690918c07BBE4FBDF1278BA"
Cc: "David S. Miller" <davem@redhat.com>, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
In-Reply-To: <20040331112839.02e8d4c2@dell_ss3.pdx.osdl.net>
To: Stephen Hemminger <shemminger@osdl.org>
Content-Disposition: inline
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

--0__=07BBE4FBDF1278BA8f9e8a93df938690918c07BBE4FBDF1278BA
Content-type: text/plain; charset=US-ASCII





Hello, Steve!

> The IP forwarding rules, uses rwlock when it could use RCU.
> Don't know if this would help or hurt the recent discussions about
> large rulesets and DOS attacks.

;-)

The good news is that there is more than one promising approach, so
there should be no problem finding a workable solution.
The bad news is that there is more than one promising approach, so much
testing and discussion will likely be needed to arrive at that solution.

> Also, it increases the size of fib_rule slightly.

Looks sane, particularly focusing locally on the FIB subsystem.
A few comments, as always:

o     The original locking for inet_rtm_delrule() is rather
      "interesting".  At first, I could not understand how the code
      survived concurrent attempts to delete the same element, but
      I eventually realized that rtnl_sem is acquired several
      function call levels above inet_rtm_delrule().

      Although one might argue that this semaphore makes fib_rules_lock
      unnecessary, it is far from clear to me that the rtnl_sem
      protection was intentional.  So I agree with moving the
      fib_rules_lock to cover the full search.

o     In fib_rules_detach(), you do an RCU search of the list,
      but then acquire a global lock to update the element.
      Given that you are protecting a single assignment to a
      field within the fib_rule element, why not have a per-element
      lock?

      As written, you will need a seriously large number of
      FIB rules to see any performance increase from RCU if
      you stick with the global lock.  Note that use of RCU
      protects against the race between fib_rules_detach()
      and inet_rtm_delrule(), so you would not need to acquire
      the per-element lock in inet_rtm_delrule().

o     Ditto for fib_rules_attach().

      Of course, if both fib_rules_attach() and fib_rules_detach()
      are low-probability code paths...

o     It is not clear to me that fib_lookup() will see huge speedups
      due to inetdev_lock being read-held a ways up the stack.
      This may be a case of needing to make a number of changes
      to get the full performance benefit, but I in no way claim
      to understand all that inetdev_lock protects against.
      That said, getting rid of a cache miss from the old
      read-acquisition of fib_rules_lock might still give
      worthwhile (though perhaps not huge) benefits.  And getting
      rid of such locks one at a time instead of in one big "bang"
      would be quite wise.  ;-)

                                    Thanx, Paul

> Patch against 2.6.5-rc3
>
> diff -Nru a/net/ipv4/fib_rules.c b/net/ipv4/fib_rules.c
> --- a/net/ipv4/fib_rules.c         Wed Mar 31 11:24:52 2004
> +++ b/net/ipv4/fib_rules.c         Wed Mar 31 11:24:52 2004
> @@ -51,7 +51,7 @@
>
>  struct fib_rule
>  {
> -          struct fib_rule *r_next;
> +          struct list_head r_list;
>            atomic_t          r_clntref;
>            u32                     r_preference;
>            unsigned char           r_table;
> @@ -74,6 +74,7 @@
>  #endif
>            char                    r_ifname[IFNAMSIZ];
>            int                     r_dead;
> +          struct rcu_head         r_rcu;
>  };
>
>  static struct fib_rule default_rule = {
> @@ -84,7 +85,6 @@
>  };
>
>  static struct fib_rule main_rule = {
> -          .r_next =         &default_rule,
>            .r_clntref =            ATOMIC_INIT(2),
>            .r_preference =         0x7FFE,
>            .r_table =        RT_TABLE_MAIN,
> @@ -92,23 +92,23 @@
>  };
>
>  static struct fib_rule local_rule = {
> -          .r_next =         &main_rule,
>            .r_clntref =            ATOMIC_INIT(2),
>            .r_table =        RT_TABLE_LOCAL,
>            .r_action =             RTN_UNICAST,
>  };
>
> -static struct fib_rule *fib_rules = &local_rule;
> -static rwlock_t fib_rules_lock = RW_LOCK_UNLOCKED;
> +static LIST_HEAD(fib_rules);
> +static spinlock_t fib_rules_lock = SPIN_LOCK_UNLOCKED;
>
>  int inet_rtm_delrule(struct sk_buff *skb, struct nlmsghdr* nlh, void
*arg)
>  {
>            struct rtattr **rta = arg;
>            struct rtmsg *rtm = NLMSG_DATA(nlh);
> -          struct fib_rule *r, **rp;
> +          struct fib_rule *r;
>            int err = -ESRCH;
>
> -          for (rp=&fib_rules; (r=*rp) != NULL; rp=&r->r_next) {
> +          spin_lock_bh(&fib_rules_lock);
> +          list_for_each_entry(r, &fib_rules, r_list) {
>                        if ((!rta[RTA_SRC-1] ||
memcmp(RTA_DATA(rta[RTA_SRC-1]), &r->r_src, 4) == 0) &&
>                            rtm->rtm_src_len == r->r_src_len &&
>                            rtm->rtm_dst_len == r->r_dst_len &&
> @@ -125,15 +125,15 @@
>                                    if (r == &local_rule)
>                                                break;
>
> -                                  write_lock_bh(&fib_rules_lock);
> -                                  *rp = r->r_next;
> +                                  list_del_rcu(&r->r_list);
>                                    r->r_dead = 1;
> -                                  write_unlock_bh(&fib_rules_lock);
> -                                  fib_rule_put(r);
> +                                  call_rcu(&r->r_rcu,
> +                                               (void (*)(void
*))fib_rule_put, r);
>                                    err = 0;
>                                    break;
>                        }
>            }
> +          spin_unlock_bh(&fib_rules_lock);
>            return err;
>  }
>
> @@ -163,7 +163,7 @@
>  {
>            struct rtattr **rta = arg;
>            struct rtmsg *rtm = NLMSG_DATA(nlh);
> -          struct fib_rule *r, *new_r, **rp;
> +          struct fib_rule *r, *new_r;
>            unsigned char table_id;
>
>            if (rtm->rtm_src_len > 32 || rtm->rtm_dst_len > 32 ||
> @@ -221,27 +221,27 @@
>                        memcpy(&new_r->r_tclassid,
RTA_DATA(rta[RTA_FLOW-1]), 4);
>  #endif
>
> -          rp = &fib_rules;
> +
> +          spin_lock_bh(&fib_rules_lock);
> +          r = list_entry(&fib_rules, struct fib_rule, r_list);
>            if (!new_r->r_preference) {
> -                      r = fib_rules;
> -                      if (r && (r = r->r_next) != NULL) {
> -                                  rp = &fib_rules->r_next;
> +                      if (!list_empty(&fib_rules)) {
> +                                  r = list_entry(fib_rules.next, struct
fib_rule, r_list);
>                                    if (r->r_preference)
>                                                new_r->r_preference =
r->r_preference - 1;
>                        }
>            }
>
> -          while ( (r = *rp) != NULL ) {
> +          list_for_each_entry_continue(r, &fib_rules, r_list) {
>                        if (r->r_preference > new_r->r_preference)
>                                    break;
> -                      rp = &r->r_next;
>            }
>
> -          new_r->r_next = r;
>            atomic_inc(&new_r->r_clntref);
> -          write_lock_bh(&fib_rules_lock);
> -          *rp = new_r;
> -          write_unlock_bh(&fib_rules_lock);
> +
> +          list_add_rcu(&new_r->r_list, &r->r_list);
> +          spin_unlock_bh(&fib_rules_lock);
> +
>            return 0;
>  }
>
> @@ -285,26 +285,30 @@
>  {
>            struct fib_rule *r;
>
> -          for (r=fib_rules; r; r=r->r_next) {
> +          rcu_read_lock();
> +          list_for_each_entry_rcu(r, &fib_rules, r_list) {
>                        if (r->r_ifindex == dev->ifindex) {
> -                                  write_lock_bh(&fib_rules_lock);
> +                                  spin_lock_bh(&fib_rules_lock);
>                                    r->r_ifindex = -1;
> -                                  write_unlock_bh(&fib_rules_lock);
> +                                  spin_unlock_bh(&fib_rules_lock);
>                        }
>            }
> +          rcu_read_unlock();
>  }
>
>  static void fib_rules_attach(struct net_device *dev)
>  {
>            struct fib_rule *r;
>
> -          for (r=fib_rules; r; r=r->r_next) {
> +          rcu_read_lock();
> +          list_for_each_entry_rcu(r, &fib_rules, r_list) {
>                        if (r->r_ifindex == -1 && strcmp(dev->name,
r->r_ifname) == 0) {
> -                                  write_lock_bh(&fib_rules_lock);
> +                                  spin_lock_bh(&fib_rules_lock);
>                                    r->r_ifindex = dev->ifindex;
> -                                  write_unlock_bh(&fib_rules_lock);
> +                                  spin_unlock_bh(&fib_rules_lock);
>                        }
>            }
> +          rcu_read_unlock();
>  }
>
>  int fib_lookup(const struct flowi *flp, struct fib_result *res)
> @@ -318,8 +322,9 @@
>
>  FRprintk("Lookup: %u.%u.%u.%u <- %u.%u.%u.%u ",
>            NIPQUAD(flp->fl4_dst), NIPQUAD(flp->fl4_src));
> -          read_lock(&fib_rules_lock);
> -          for (r = fib_rules; r; r=r->r_next) {
> +
> +          rcu_read_lock();
> +          list_for_each_entry_rcu(r, &fib_rules, r_list) {
>                        if (((saddr^r->r_src) & r->r_srcmask) ||
>                            ((daddr^r->r_dst) & r->r_dstmask) ||
>  #ifdef CONFIG_IP_ROUTE_TOS
> @@ -342,10 +347,10 @@
>                                    return -ENETUNREACH;
>                        default:
>                        case RTN_BLACKHOLE:
> -                                  read_unlock(&fib_rules_lock);
> +                                  rcu_read_unlock();
>                                    return -EINVAL;
>                        case RTN_PROHIBIT:
> -                                  read_unlock(&fib_rules_lock);
> +                                  rcu_read_unlock();
>                                    return -EACCES;
>                        }
>
> @@ -356,16 +361,18 @@
>                                    res->r = policy;
>                                    if (policy)
>
atomic_inc(&policy->r_clntref);
> -                                  read_unlock(&fib_rules_lock);
> +
> +                                  rcu_read_unlock();
>                                    return 0;
>                        }
>                        if (err < 0 && err != -EAGAIN) {
> -                                  read_unlock(&fib_rules_lock);
> +                                  rcu_read_unlock();
>                                    return err;
>                        }
>            }
>  FRprintk("FAILURE\n");
> -          read_unlock(&fib_rules_lock);
> +
> +          rcu_read_unlock();
>            return -ENETUNREACH;
>  }
>
> @@ -391,8 +398,8 @@
>  }
>
>
> -struct notifier_block fib_rules_notifier = {
> -          .notifier_call =fib_rules_event,
> +static struct notifier_block fib_rules_notifier = {
> +          .notifier_call = fib_rules_event,
>  };
>
>  static __inline__ int inet_fill_rule(struct sk_buff *skb,
> @@ -444,18 +451,16 @@
>
>  int inet_dump_rules(struct sk_buff *skb, struct netlink_callback *cb)
>  {
> -          int idx;
> +          int idx = 0;
>            int s_idx = cb->args[0];
>            struct fib_rule *r;
>
> -          read_lock(&fib_rules_lock);
> -          for (r=fib_rules, idx=0; r; r = r->r_next, idx++) {
> -                      if (idx < s_idx)
> -                                  continue;
> -                      if (inet_fill_rule(skb, r, cb) < 0)
> +          rcu_read_lock();
> +          list_for_each_entry_rcu(r, &fib_rules, r_list) {
> +                      if (idx++ >= s_idx && inet_fill_rule(skb, r, cb) <
0)
>                                    break;
>            }
> -          read_unlock(&fib_rules_lock);
> +          rcu_read_unlock();
>            cb->args[0] = idx;
>
>            return skb->len;
> @@ -464,4 +469,10 @@
>  void __init fib_rules_init(void)
>  {
>            register_netdevice_notifier(&fib_rules_notifier);
> +
> +          spin_lock_bh(&fib_rules_lock);
> +          list_add_rcu(&local_rule.r_list, &fib_rules);
> +          list_add_rcu(&main_rule.r_list, &local_rule.r_list);
> +          list_add_rcu(&default_rule.r_list, &main_rule.r_list);
> +          spin_unlock_bh(&fib_rules_lock);
>  }
--0__=07BBE4FBDF1278BA8f9e8a93df938690918c07BBE4FBDF1278BA
Content-type: text/html; charset=US-ASCII
Content-Disposition: inline

<html><body>
<p>Hello, Steve!<br>
<br>
&gt; The IP forwarding rules, uses rwlock when it could use RCU.<br>
&gt; Don't know if this would help or hurt the recent discussions about<br>
&gt; large rulesets and DOS attacks.<br>
<br>
;-)<br>
<br>
The good news is that there is more than one promising approach, so<br>
there should be no problem finding a workable solution.<br>
The bad news is that there is more than one promising approach, so much<br>
testing and discussion will likely be needed to arrive at that solution.<br>
<br>
&gt; Also, it increases the size of fib_rule slightly.<br>
<br>
Looks sane, particularly focusing locally on the FIB subsystem.<br>
A few comments, as always:<br>
<br>
o	The original locking for inet_rtm_delrule() is rather<br>
	&quot;interesting&quot;.  At first, I could not understand how the code<br>
	survived concurrent attempts to delete the same element, but<br>
	I eventually realized that rtnl_sem is acquired several<br>
	function call levels above inet_rtm_delrule().<br>
<br>
	Although one might argue that this semaphore makes fib_rules_lock<br>
	unnecessary, it is far from clear to me that the rtnl_sem<br>
	protection was intentional.  So I agree with moving the<br>
	fib_rules_lock to cover the full search.<br>
<br>
o	In fib_rules_detach(), you do an RCU search of the list,<br>
	but then acquire a global lock to update the element.<br>
	Given that you are protecting a single assignment to a<br>
	field within the fib_rule element, why not have a per-element<br>
	lock?<br>
<br>
	As written, you will need a seriously large number of<br>
	FIB rules to see any performance increase from RCU if<br>
	you stick with the global lock.  Note that use of RCU<br>
	protects against the race between fib_rules_detach()<br>
	and inet_rtm_delrule(), so you would not need to acquire<br>
	the per-element lock in inet_rtm_delrule().<br>
<br>
o	Ditto for fib_rules_attach().<br>
<br>
	Of course, if both fib_rules_attach() and fib_rules_detach()<br>
	are low-probability code paths...<br>
<br>
o	It is not clear to me that fib_lookup() will see huge speedups<br>
	due to inetdev_lock being read-held a ways up the stack.<br>
	This may be a case of needing to make a number of changes<br>
	to get the full performance benefit, but I in no way claim<br>
	to understand all that inetdev_lock protects against.<br>
	That said, getting rid of a cache miss from the old<br>
	read-acquisition of fib_rules_lock might still give<br>
	worthwhile (though perhaps not huge) benefits.  And getting<br>
	rid of such locks one at a time instead of in one big &quot;bang&quot;<br>
	would be quite wise.  ;-)<br>
<br>
						Thanx, Paul<br>
<br>
&gt; Patch against 2.6.5-rc3<br>
&gt; <br>
&gt; diff -Nru a/net/ipv4/fib_rules.c b/net/ipv4/fib_rules.c<br>
&gt; --- a/net/ipv4/fib_rules.c		 Wed Mar 31 11:24:52 2004<br>
&gt; +++ b/net/ipv4/fib_rules.c		 Wed Mar 31 11:24:52 2004<br>
&gt; @@ -51,7 +51,7 @@<br>
&gt;  <br>
&gt;  struct fib_rule<br>
&gt;  {<br>
&gt; -		 struct fib_rule *r_next;<br>
&gt; +		 struct list_head r_list;<br>
&gt;  		 atomic_t		 r_clntref;<br>
&gt;  		 u32		 		 r_preference;<br>
&gt;  		 unsigned char		 r_table;<br>
&gt; @@ -74,6 +74,7 @@<br>
&gt;  #endif<br>
&gt;  		 char		 		 r_ifname[IFNAMSIZ];<br>
&gt;  		 int		 		 r_dead;<br>
&gt; +		 struct rcu_head		 r_rcu;<br>
&gt;  };<br>
&gt;  <br>
&gt;  static struct fib_rule default_rule = {<br>
&gt; @@ -84,7 +85,6 @@<br>
&gt;  };<br>
&gt;  <br>
&gt;  static struct fib_rule main_rule = {<br>
&gt; -		 .r_next =		 &amp;default_rule,<br>
&gt;  		 .r_clntref =		 ATOMIC_INIT(2),<br>
&gt;  		 .r_preference =		 0x7FFE,<br>
&gt;  		 .r_table =		 RT_TABLE_MAIN,<br>
&gt; @@ -92,23 +92,23 @@<br>
&gt;  };<br>
&gt;  <br>
&gt;  static struct fib_rule local_rule = {<br>
&gt; -		 .r_next =		 &amp;main_rule,<br>
&gt;  		 .r_clntref =		 ATOMIC_INIT(2),<br>
&gt;  		 .r_table =		 RT_TABLE_LOCAL,<br>
&gt;  		 .r_action =		 RTN_UNICAST,<br>
&gt;  };<br>
&gt;  <br>
&gt; -static struct fib_rule *fib_rules = &amp;local_rule;<br>
&gt; -static rwlock_t fib_rules_lock = RW_LOCK_UNLOCKED;<br>
&gt; +static LIST_HEAD(fib_rules);<br>
&gt; +static spinlock_t fib_rules_lock = SPIN_LOCK_UNLOCKED;<br>
&gt;  <br>
&gt;  int inet_rtm_delrule(struct sk_buff *skb, struct nlmsghdr* nlh, void *arg)<br>
&gt;  {<br>
&gt;  		 struct rtattr **rta = arg;<br>
&gt;  		 struct rtmsg *rtm = NLMSG_DATA(nlh);<br>
&gt; -		 struct fib_rule *r, **rp;<br>
&gt; +		 struct fib_rule *r;<br>
&gt;  		 int err = -ESRCH;<br>
&gt;  <br>
&gt; -		 for (rp=&amp;fib_rules; (r=*rp) != NULL; rp=&amp;r-&gt;r_next) {<br>
&gt; +		 spin_lock_bh(&amp;fib_rules_lock);<br>
&gt; +		 list_for_each_entry(r, &amp;fib_rules, r_list) {<br>
&gt;  		 		 if ((!rta[RTA_SRC-1] || memcmp(RTA_DATA(rta[RTA_SRC-1]), &amp;r-&gt;r_src, 4) == 0) &amp;&amp;<br>
&gt;  		 		     rtm-&gt;rtm_src_len == r-&gt;r_src_len &amp;&amp;<br>
&gt;  		 		     rtm-&gt;rtm_dst_len == r-&gt;r_dst_len &amp;&amp;<br>
&gt; @@ -125,15 +125,15 @@<br>
&gt;  		 		 		 if (r == &amp;local_rule)<br>
&gt;  		 		 		 		 break;<br>
&gt;  <br>
&gt; -		 		 		 write_lock_bh(&amp;fib_rules_lock);<br>
&gt; -		 		 		 *rp = r-&gt;r_next;<br>
&gt; +		 		 		 list_del_rcu(&amp;r-&gt;r_list);<br>
&gt;  		 		 		 r-&gt;r_dead = 1;<br>
&gt; -		 		 		 write_unlock_bh(&amp;fib_rules_lock);<br>
&gt; -		 		 		 fib_rule_put(r);<br>
&gt; +		 		 		 call_rcu(&amp;r-&gt;r_rcu, <br>
&gt; +		 		 		 		  (void (*)(void *))fib_rule_put, r);<br>
&gt;  		 		 		 err = 0;<br>
&gt;  		 		 		 break;<br>
&gt;  		 		 }<br>
&gt;  		 }<br>
&gt; +		 spin_unlock_bh(&amp;fib_rules_lock);<br>
&gt;  		 return err;<br>
&gt;  }<br>
&gt;  <br>
&gt; @@ -163,7 +163,7 @@<br>
&gt;  {<br>
&gt;  		 struct rtattr **rta = arg;<br>
&gt;  		 struct rtmsg *rtm = NLMSG_DATA(nlh);<br>
&gt; -		 struct fib_rule *r, *new_r, **rp;<br>
&gt; +		 struct fib_rule *r, *new_r;<br>
&gt;  		 unsigned char table_id;<br>
&gt;  <br>
&gt;  		 if (rtm-&gt;rtm_src_len &gt; 32 || rtm-&gt;rtm_dst_len &gt; 32 ||<br>
&gt; @@ -221,27 +221,27 @@<br>
&gt;  		 		 memcpy(&amp;new_r-&gt;r_tclassid, RTA_DATA(rta[RTA_FLOW-1]), 4);<br>
&gt;  #endif<br>
&gt;  <br>
&gt; -		 rp = &amp;fib_rules;<br>
&gt; +<br>
&gt; +		 spin_lock_bh(&amp;fib_rules_lock);<br>
&gt; +		 r = list_entry(&amp;fib_rules, struct fib_rule, r_list);<br>
&gt;  		 if (!new_r-&gt;r_preference) {<br>
&gt; -		 		 r = fib_rules;<br>
&gt; -		 		 if (r &amp;&amp; (r = r-&gt;r_next) != NULL) {<br>
&gt; -		 		 		 rp = &amp;fib_rules-&gt;r_next;<br>
&gt; +		 		 if (!list_empty(&amp;fib_rules)) {<br>
&gt; +		 		 		 r = list_entry(fib_rules.next, struct fib_rule, r_list);<br>
&gt;  		 		 		 if (r-&gt;r_preference)<br>
&gt;  		 		 		 		 new_r-&gt;r_preference = r-&gt;r_preference - 1;<br>
&gt;  		 		 }<br>
&gt;  		 }<br>
&gt;  <br>
&gt; -		 while ( (r = *rp) != NULL ) {<br>
&gt; +		 list_for_each_entry_continue(r, &amp;fib_rules, r_list) {<br>
&gt;  		 		 if (r-&gt;r_preference &gt; new_r-&gt;r_preference)<br>
&gt;  		 		 		 break;<br>
&gt; -		 		 rp = &amp;r-&gt;r_next;<br>
&gt;  		 }<br>
&gt;  <br>
&gt; -		 new_r-&gt;r_next = r;<br>
&gt;  		 atomic_inc(&amp;new_r-&gt;r_clntref);<br>
&gt; -		 write_lock_bh(&amp;fib_rules_lock);<br>
&gt; -		 *rp = new_r;<br>
&gt; -		 write_unlock_bh(&amp;fib_rules_lock);<br>
&gt; +<br>
&gt; +		 list_add_rcu(&amp;new_r-&gt;r_list, &amp;r-&gt;r_list);<br>
&gt; +		 spin_unlock_bh(&amp;fib_rules_lock);<br>
&gt; +<br>
&gt;  		 return 0;<br>
&gt;  }<br>
&gt;  <br>
&gt; @@ -285,26 +285,30 @@<br>
&gt;  {<br>
&gt;  		 struct fib_rule *r;<br>
&gt;  <br>
&gt; -		 for (r=fib_rules; r; r=r-&gt;r_next) {<br>
&gt; +		 rcu_read_lock();<br>
&gt; +		 list_for_each_entry_rcu(r, &amp;fib_rules, r_list) {<br>
&gt;  		 		 if (r-&gt;r_ifindex == dev-&gt;ifindex) {<br>
&gt; -		 		 		 write_lock_bh(&amp;fib_rules_lock);<br>
&gt; +		 		 		 spin_lock_bh(&amp;fib_rules_lock);<br>
&gt;  		 		 		 r-&gt;r_ifindex = -1;<br>
&gt; -		 		 		 write_unlock_bh(&amp;fib_rules_lock);<br>
&gt; +		 		 		 spin_unlock_bh(&amp;fib_rules_lock);<br>
&gt;  		 		 }<br>
&gt;  		 }<br>
&gt; +		 rcu_read_unlock();<br>
&gt;  }<br>
&gt;  <br>
&gt;  static void fib_rules_attach(struct net_device *dev)<br>
&gt;  {<br>
&gt;  		 struct fib_rule *r;<br>
&gt;  <br>
&gt; -		 for (r=fib_rules; r; r=r-&gt;r_next) {<br>
&gt; +		 rcu_read_lock();<br>
&gt; +		 list_for_each_entry_rcu(r, &amp;fib_rules, r_list) {<br>
&gt;  		 		 if (r-&gt;r_ifindex == -1 &amp;&amp; strcmp(dev-&gt;name, r-&gt;r_ifname) == 0) {<br>
&gt; -		 		 		 write_lock_bh(&amp;fib_rules_lock);<br>
&gt; +		 		 		 spin_lock_bh(&amp;fib_rules_lock);<br>
&gt;  		 		 		 r-&gt;r_ifindex = dev-&gt;ifindex;<br>
&gt; -		 		 		 write_unlock_bh(&amp;fib_rules_lock);<br>
&gt; +		 		 		 spin_unlock_bh(&amp;fib_rules_lock);<br>
&gt;  		 		 }<br>
&gt;  		 }<br>
&gt; +		 rcu_read_unlock();<br>
&gt;  }<br>
&gt;  <br>
&gt;  int fib_lookup(const struct flowi *flp, struct fib_result *res)<br>
&gt; @@ -318,8 +322,9 @@<br>
&gt;  <br>
&gt;  FRprintk(&quot;Lookup: %u.%u.%u.%u &lt;- %u.%u.%u.%u &quot;,<br>
&gt;  		 NIPQUAD(flp-&gt;fl4_dst), NIPQUAD(flp-&gt;fl4_src));<br>
&gt; -		 read_lock(&amp;fib_rules_lock);<br>
&gt; -		 for (r = fib_rules; r; r=r-&gt;r_next) {<br>
&gt; +<br>
&gt; +		 rcu_read_lock();<br>
&gt; +		 list_for_each_entry_rcu(r, &amp;fib_rules, r_list) {<br>
&gt;  		 		 if (((saddr^r-&gt;r_src) &amp; r-&gt;r_srcmask) ||<br>
&gt;  		 		     ((daddr^r-&gt;r_dst) &amp; r-&gt;r_dstmask) ||<br>
&gt;  #ifdef CONFIG_IP_ROUTE_TOS<br>
&gt; @@ -342,10 +347,10 @@<br>
&gt;  		 		 		 return -ENETUNREACH;<br>
&gt;  		 		 default:<br>
&gt;  		 		 case RTN_BLACKHOLE:<br>
&gt; -		 		 		 read_unlock(&amp;fib_rules_lock);<br>
&gt; +		 		 		 rcu_read_unlock(); <br>
&gt;  		 		 		 return -EINVAL;<br>
&gt;  		 		 case RTN_PROHIBIT:<br>
&gt; -		 		 		 read_unlock(&amp;fib_rules_lock);<br>
&gt; +		 		 		 rcu_read_unlock();<br>
&gt;  		 		 		 return -EACCES;<br>
&gt;  		 		 }<br>
&gt;  <br>
&gt; @@ -356,16 +361,18 @@<br>
&gt;  		 		 		 res-&gt;r = policy;<br>
&gt;  		 		 		 if (policy)<br>
&gt;  		 		 		 		 atomic_inc(&amp;policy-&gt;r_clntref);<br>
&gt; -		 		 		 read_unlock(&amp;fib_rules_lock);<br>
&gt; +<br>
&gt; +		 		 		 rcu_read_unlock(); <br>
&gt;  		 		 		 return 0;<br>
&gt;  		 		 }<br>
&gt;  		 		 if (err &lt; 0 &amp;&amp; err != -EAGAIN) {<br>
&gt; -		 		 		 read_unlock(&amp;fib_rules_lock);<br>
&gt; +		 		 		 rcu_read_unlock(); <br>
&gt;  		 		 		 return err;<br>
&gt;  		 		 }<br>
&gt;  		 }<br>
&gt;  FRprintk(&quot;FAILURE\n&quot;);<br>
&gt; -		 read_unlock(&amp;fib_rules_lock);<br>
&gt; +<br>
&gt; +		 rcu_read_unlock(); <br>
&gt;  		 return -ENETUNREACH;<br>
&gt;  }<br>
&gt;  <br>
&gt; @@ -391,8 +398,8 @@<br>
&gt;  }<br>
&gt;  <br>
&gt;  <br>
&gt; -struct notifier_block fib_rules_notifier = {<br>
&gt; -		 .notifier_call =fib_rules_event,<br>
&gt; +static struct notifier_block fib_rules_notifier = {<br>
&gt; +		 .notifier_call = fib_rules_event,<br>
&gt;  };<br>
&gt;  <br>
&gt;  static __inline__ int inet_fill_rule(struct sk_buff *skb,<br>
&gt; @@ -444,18 +451,16 @@<br>
&gt;  <br>
&gt;  int inet_dump_rules(struct sk_buff *skb, struct netlink_callback *cb)<br>
&gt;  {<br>
&gt; -		 int idx;<br>
&gt; +		 int idx = 0;<br>
&gt;  		 int s_idx = cb-&gt;args[0];<br>
&gt;  		 struct fib_rule *r;<br>
&gt;  <br>
&gt; -		 read_lock(&amp;fib_rules_lock);<br>
&gt; -		 for (r=fib_rules, idx=0; r; r = r-&gt;r_next, idx++) {<br>
&gt; -		 		 if (idx &lt; s_idx)<br>
&gt; -		 		 		 continue;<br>
&gt; -		 		 if (inet_fill_rule(skb, r, cb) &lt; 0)<br>
&gt; +		 rcu_read_lock();<br>
&gt; +		 list_for_each_entry_rcu(r, &amp;fib_rules, r_list) {<br>
&gt; +		 		 if (idx++ &gt;= s_idx &amp;&amp; inet_fill_rule(skb, r, cb) &lt; 0)<br>
&gt;  		 		 		 break;<br>
&gt;  		 }<br>
&gt; -		 read_unlock(&amp;fib_rules_lock);<br>
&gt; +		 rcu_read_unlock();<br>
&gt;  		 cb-&gt;args[0] = idx;<br>
&gt;  <br>
&gt;  		 return skb-&gt;len;<br>
&gt; @@ -464,4 +469,10 @@<br>
&gt;  void __init fib_rules_init(void)<br>
&gt;  {<br>
&gt;  		 register_netdevice_notifier(&amp;fib_rules_notifier);<br>
&gt; +<br>
&gt; +		 spin_lock_bh(&amp;fib_rules_lock);<br>
&gt; +		 list_add_rcu(&amp;local_rule.r_list, &amp;fib_rules);<br>
&gt; +		 list_add_rcu(&amp;main_rule.r_list, &amp;local_rule.r_list);<br>
&gt; +		 list_add_rcu(&amp;default_rule.r_list, &amp;main_rule.r_list);<br>
&gt; +		 spin_unlock_bh(&amp;fib_rules_lock);<br>
&gt;  }</body></html>
--0__=07BBE4FBDF1278BA8f9e8a93df938690918c07BBE4FBDF1278BA--
