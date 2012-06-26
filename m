From: Oliver Hartkopp <socketcan@hartkopp.net>
Subject: Re: [PATCH net-next] em_canid: Ematch rule to match CAN frames according
 to their CAN IDs
Date: Tue, 26 Jun 2012 22:07:56 +0200
Message-ID: <4FEA169C.1070709@hartkopp.net>
References: <1340022131-7827-1-git-send-email-lisovy@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-can@vger.kernel.org,
	lartc@vger.kernel.org, pisa@cmp.felk.cvut.cz, sojkam1@fel.cvut.cz
To: Rostislav Lisovy <lisovy@gmail.com>,
	Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <linux-can-owner@vger.kernel.org>
In-Reply-To: <1340022131-7827-1-git-send-email-lisovy@gmail.com>
Sender: linux-can-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hello Rostislav,

thanks for the new patch. It got indeed pretty short now :-)

I found some time for a review. See details inline ...

On 18.06.2012 14:22, Rostislav Lisovy wrote:


> 
> With no extra filter/qdisc configured, median of the time spent in can_send()
> was about 27 us -- with prio qdisc with 5 bands and 5 appropriate cls_can
> filters (previous patch), it was about 30 us -- with prio qdisc with 5 bands
> and 5 appropriate em_can filters (this patch), it was about 34 us.


Hm that's more than twice the time consumed for classification ...

cls_can: 3 us more
em_can:  7 us more

@Eric: Is this still the better approach then?


> diff --git a/net/sched/Kconfig b/net/sched/Kconfig
> index 75b58f8..bc0ceab 100644
> --- a/net/sched/Kconfig
> +++ b/net/sched/Kconfig
> @@ -485,6 +485,16 @@ config NET_EMATCH_TEXT
>  	  To compile this code as a module, choose M here: the
>  	  module will be called em_text.
>  
> +config NET_EMATCH_CANID
> +	tristate "CAN ID"


i would prefer

tristate "Controller Area Network Identifier"

or at least

tristate "CAN Identifier"

> +	depends on NET_EMATCH && CAN
> +	---help---
> +          Say Y here if you want to be able to classify CAN frames based
> +          on CAN ID.


"on the CAN Identifier."

(..)

> +#include <net/pkt_cls.h>
> +#include <linux/can.h>
> +
> +#define EM_CAN_RULES_SIZE				32


Reduce the gap before '32' to one single space.

(..)

> +static int em_canid_match(struct sk_buff *skb, struct tcf_ematch *m,
> +			 struct tcf_pkt_info *info)
> +{
> +	struct canid_match *cm = em_canid_priv(m);
> +	canid_t can_id;
> +	unsigned int match = false;


You use test_bit() below which returns an int.

Better use int instead of unsigned int ...

int match = 0;


> +	int i;
> +
> +	can_id = em_canid_get_id(skb);
> +
> +	if (can_id & CAN_EFF_FLAG) {
> +		can_id &= CAN_EFF_MASK;
> +
> +		for (i = 0; i < cm->eff_rules_count; i++) {
> +			if (!(((cm->rules_raw[i].can_id ^ can_id) &
> +			    cm->rules_raw[i].can_mask) & CAN_EFF_MASK)) {


Looks really tricky. I'm still pondering if it does what it should do ...

> +				match = true;


match = 1;

> +				break;
> +			}
> +		}
> +	} else { /* SFF */
> +		can_id &= CAN_SFF_MASK;
> +		match = test_bit(can_id, cm->match_sff);
> +	}
> +


return match;


> +	if (match)
> +		return 1;
> +
> +	return 0;
> +}
> +
> +static int em_canid_change(struct tcf_proto *tp, void *data, int len,
> +			  struct tcf_ematch *m)
> +{
> +	struct can_filter *conf = data; /* Array with rules,
> +					 * fixed size EM_CAN_RULES_SIZE
> +					 */
> +	struct canid_match *cm;
> +	int err;
> +	int i;
> +
> +	if (len < sizeof(struct can_filter))
> +		return -EINVAL;


if (len % sizeof(struct can_filter))
	return -EINVAL;

if (len > sizeof(struct can_filter) * EM_CAN_RULES_SIZE)
	return -EINVAL;

All checks done before kzalloc() => no need for error cleanups at the end of
the function.

> +
> +	err = -ENOBUFS;


remove

> +	cm = kzalloc(sizeof(*cm), GFP_KERNEL);
> +	if (cm == NULL)


if (!cm)
	return -ENOMEM;

> +		goto errout;


The only user of errout - to be removed.

> +
> +	cm->sff_rules_count = 0;
> +	cm->eff_rules_count = 0;
> +	cm->rules_count = len/sizeof(struct can_filter);


> +	err = -EINVAL;

remove

> +
> +	/* Be sure to fit into the array */
> +	if (cm->rules_count > EM_CAN_RULES_SIZE)
> +		goto errout_free;


already checked before => remove

> +
> +	/*
> +	 * We need two for() loops for copying rules into
> +	 * two contiguous areas in rules_raw
> +	 */
> +
> +	/* Process EFF frame rules*/
> +	for (i = 0; i < cm->rules_count; i++) {
> +		if ((conf[i].can_id & CAN_EFF_FLAG) &&
> +		    (conf[i].can_mask & CAN_EFF_FLAG)) {
> +			memcpy(cm->rules_raw + cm->eff_rules_count,


Oops. Shouldn't this be

cm->rules_raw + cm->eff_rules_count * sizeof(struct can_filter),

???

> +				&conf[i],
> +				sizeof(struct can_filter));
> +
> +			cm->eff_rules_count++;
> +		} else {
> +			continue;
> +		}


omit { } around continue

> +	}
> +
> +	/* Process SFF frame rules */
> +	for (i = 0; i < cm->rules_count; i++) {
> +		if ((conf[i].can_id & CAN_EFF_FLAG) &&
> +		    (conf[i].can_mask & CAN_EFF_FLAG)) {


What if CAN_EFF_FLAG is set in can_id but not in can_mask ?

> +			continue;
> +		} else {
> +			memcpy(cm->rules_raw
> +				+ cm->eff_rules_count
> +				+ cm->sff_rules_count,


dito

cm->rules_raw + (cm->eff_rules_count + cm->sff_rules_count) * sizeof(struct
can_filter),

???


> +				&conf[i], sizeof(struct can_filter));
> +
> +			cm->sff_rules_count++;
> +
> +			em_canid_sff_match_add(cm,
> +				conf[i].can_id, conf[i].can_mask);
> +		}
> +	}
> +
> +	m->datalen = sizeof(*cm);
> +	m->data = (unsigned long) cm;
> +
> +	return 0;
> +
> +errout_free:
> +	kfree(cm);
> +errout:
> +	return err;


error handling can be removed with the above changes.

> +}
> +
> +static void em_canid_destroy(struct tcf_proto *tp, struct tcf_ematch *m)
> +{
> +	struct canid_match *cm = em_canid_priv(m);
> +


Check for cm == NULL not needed ?

> +	kfree(cm);
> +}
> +
> +static int em_canid_dump(struct sk_buff *skb, struct tcf_ematch *m)
> +{
> +	struct canid_match *cm = em_canid_priv(m);
> +


Check for cm == NULL not needed ?

Can a dump happen before the matches are added??

> +	/*
> +	 * When configuring this ematch 'rules_count' is set not to exceed
> +	 * 'rules_raw' array size
> +	 */
> +	if (nla_put_nohdr(skb, sizeof(cm->rules_raw[0]) * cm->rules_count,


better sizeof(struct can_filter) instead of sizeof(cm->rules_raw[0]) ??

> +	    &cm->rules_raw) < 0)
> +		goto nla_put_failure;
> +
> +	return 0;
> +
> +nla_put_failure:
> +	return -1;
> +}
> +
> +static struct tcf_ematch_ops em_canid_ops = {
> +	.kind	  = TCF_EM_CANID,
> +	.change	  = em_canid_change,
> +	.match	  = em_canid_match,
> +	.destroy  = em_canid_destroy,
> +	.dump	  = em_canid_dump,
> +	.owner	  = THIS_MODULE,
> +	.link	  = LIST_HEAD_INIT(em_canid_ops.link)
> +};
> +
> +static int __init init_em_canid(void)
> +{
> +	return tcf_em_register(&em_canid_ops);
> +}
> +
> +static void __exit exit_em_canid(void)
> +{
> +	tcf_em_unregister(&em_canid_ops);
> +}
> +
> +MODULE_LICENSE("GPL");
> +
> +module_init(init_em_canid);
> +module_exit(exit_em_canid);
> +
> +MODULE_ALIAS_TCF_EMATCH(TCF_EM_CANID);


Regards,
Oliver
