From: Patrick McHardy <kaber@trash.net>
Subject: Re: [PATCH] netlink: allocate group bitmaps dynamically
Date: Tue, 03 Jul 2007 14:05:57 +0200
Message-ID: <468A3BA5.9050909@trash.net>
References: <1179827251.7707.29.camel@localhost.localdomain>	 <1182178882.4063.11.camel@localhost>	 <1182223964.5411.76.camel@localhost.localdomain>	 <1182811210.6644.22.camel@johannes.berg>	 <1182986681.5155.55.camel@localhost>	 <1183121869.4089.57.camel@johannes.berg>  <468504FE.9000502@trash.net>	 <1183122920.4089.63.camel@johannes.berg>  <468507C9.2000800@trash.net>	 <1183124085.4089.66.camel@johannes.berg>  <46850CB8.8000509@trash.net>	 <1183124981.4089.69.camel@johannes.berg>  <46850EDE.5020804@trash.net>	 <1183125924.4089.73.camel@johannes.berg>	 <1183126739.4089.76.camel@johannes.berg>	 <1183129006.4089.84.camel@johannes.berg>	 <1183217536.5165.25.camel@localhost>	 <1183365821.4089.94.camel@johannes.berg>  <4688F612.1060408@trash.net>	 <1183386883.4089.120.camel@johannes.ber g>  <46890DF8.2020706@trash.net>	 <1183387687.4089.124.camel@johannes.berg>	 <1183414370.4089.141.camel@jo
 hannes.berg> <1183457329.3841.0.camel@johannes.berg>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15
Content-Transfer-Encoding: 7bit
Cc: hadi@cyberus.ca, Zhang Rui <rui.zhang@intel.com>,
	netdev@vger.kernel.org,
	"linux-acpi@vger" <linux-acpi@vger.kernel.org>, lenb@kernel.org,
	Thomas Graf <tgraf@suug.ch>
To: Johannes Berg <johannes@sipsolutions.net>
Return-path: <linux-acpi-owner@vger.kernel.org>
In-Reply-To: <1183457329.3841.0.camel@johannes.berg>
Sender: linux-acpi-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Johannes Berg wrote:
> Allow changing the number of groups for a netlink family
> after it has been created.
> 
> Signed-off-by: Johannes Berg <johannes@sipsolutions.net>
> 
> ---
>  include/linux/netlink.h  |    1 
>  net/netlink/af_netlink.c |   61 +++++++++++++++++++++++++++++++++++------------
>  2 files changed, 47 insertions(+), 15 deletions(-)
> 
> --- wireless-dev.orig/net/netlink/af_netlink.c	2007-07-03 00:10:31.617889695 +0200
> +++ wireless-dev/net/netlink/af_netlink.c	2007-07-03 00:31:30.267889695 +0200
> @@ -316,8 +316,11 @@ netlink_update_listeners(struct sock *sk
>  
>  	for (i = 0; i < NLGRPSZ(tbl->groups)/sizeof(unsigned long); i++) {
>  		mask = 0;
> -		sk_for_each_bound(sk, node, &tbl->mc_list)
> -			mask |= nlk_sk(sk)->groups[i];
> +		sk_for_each_bound(sk, node, &tbl->mc_list) {
> +			if (nlk_sk(sk)->ngroups >=
> +			    (i + 1) * sizeof(unsigned long))


This condition implies that a socket can bind to a non-existant
group, which shouldn't be possible.

> +				mask |= nlk_sk(sk)->groups[i];
> +		}
>  		tbl->listeners[i] = mask;
>  	}
>  	/* this function is only called with the netlink table "grabbed", which
> @@ -555,10 +558,11 @@ netlink_update_subscriptions(struct sock
>  	nlk->subscriptions = subscriptions;
>  }
>  
> -static int netlink_alloc_groups(struct sock *sk)
> +static int netlink_realloc_groups(struct sock *sk)
>  {
>  	struct netlink_sock *nlk = nlk_sk(sk);
>  	unsigned int groups;
> +	unsigned long *new_groups;
>  	int err = 0;
>  
>  	netlink_lock_table();
> @@ -570,9 +574,15 @@ static int netlink_alloc_groups(struct s
>  	if (err)
>  		return err;
>  
> -	nlk->groups = kzalloc(NLGRPSZ(groups), GFP_KERNEL);
> -	if (nlk->groups == NULL)
> +	if (nlk->ngroups >= groups)
> +		return 0;
> +
> +	new_groups = krealloc(nlk->groups, NLGRPSZ(groups), GFP_KERNEL);
> +	if (new_groups == NULL)
>  		return -ENOMEM;
> +	memset((char*)new_groups + NLGRPSZ(nlk->ngroups), 0,
> +	       NLGRPSZ(groups) - NLGRPSZ(nlk->ngroups));
> +	nlk->groups = new_groups;


This should probably happen with the table grabbed to avoid races
with concurrent broadcasts.



> @@ -1332,6 +1338,31 @@ out_sock_release:
>  	return NULL;
>  }
>  
> +int netlink_change_ngroups(int unit, unsigned int groups)
> +{
> +	unsigned long *listeners;
> +	int err = 0;
> +
> +	netlink_table_grab();


Unfortunately that doesn't prevent races with netlink_has_listeners
since its lockless (and should really stay that way).


> +	if (NLGRPSZ(nl_table[unit].groups) < NLGRPSZ(groups)) {
> +		listeners = krealloc(nl_table[unit].listeners,
> +				     NLGRPSZ(groups), GFP_KERNEL);
> +		if (!listeners) {
> +			err = -ENOMEM;
> +			goto out_ungrab;
> +		}
> +		memset((char*) listeners + NLGRPSZ(nl_table[unit].groups),
> +		       0, NLGRPSZ(groups) - NLGRPSZ(nl_table[unit].groups));
> +		nl_table[unit].listeners = listeners;
> +	}
> +	nl_table[unit].groups = groups;
> +
> + out_ungrab:
> +	netlink_table_ungrab();
> +	return err;
> +}
> +EXPORT_SYMBOL(netlink_change_ngroups);
> +
>  void netlink_set_nonroot(int protocol, unsigned int flags)
>  {
>  	if ((unsigned int)protocol < MAX_LINKS)
> --- wireless-dev.orig/include/linux/netlink.h	2007-07-03 00:09:13.047889695 +0200
> +++ wireless-dev/include/linux/netlink.h	2007-07-03 00:31:30.267889695 +0200
> @@ -161,6 +161,7 @@ extern struct sock *netlink_kernel_creat
>  					  void (*input)(struct sock *sk, int len),
>  					  struct mutex *cb_mutex,
>  					  struct module *module);
> +extern int netlink_change_ngroups(int unit, unsigned int groups);
>  extern void netlink_ack(struct sk_buff *in_skb, struct nlmsghdr *nlh, int err);
>  extern int netlink_has_listeners(struct sock *sk, unsigned int group);
>  extern int netlink_unicast(struct sock *ssk, struct sk_buff *skb, __u32 pid, int nonblock);
> 
> 

