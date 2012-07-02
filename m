From: Oliver Hartkopp <socketcan@hartkopp.net>
Subject: Re: [PATCH net-next v3] em_canid: Ematch rule to match CAN frames
 according to their identifiers
Date: Mon, 02 Jul 2012 19:50:29 +0200
Message-ID: <4FF1DF65.5080306@hartkopp.net>
References: <1341241568-13438-1-git-send-email-lisovy@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-can@vger.kernel.org,
	lartc@vger.kernel.org, pisa@cmp.felk.cvut.cz, sojkam1@fel.cvut.cz
To: Rostislav Lisovy <lisovy@gmail.com>
Return-path: <linux-can-owner@vger.kernel.org>
In-Reply-To: <1341241568-13438-1-git-send-email-lisovy@gmail.com>
Sender: linux-can-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Ugh - sorry.

I still found some issues ...

On 02.07.2012 17:06, Rostislav Lisovy wrote:



> +
> +static int em_canid_change(struct tcf_proto *tp, void *data, int len,
> +			  struct tcf_ematch *m)
> +{
> +	struct can_filter *conf = data; /* Array with rules,
> +					 * fixed size EM_CAN_RULES_SIZE
> +					 */


Remove this comment.

It's only an "array with rules" - but EM_CAN_RULES_SIZE is absent in the code now.

> +	struct canid_match *cm;
> +	struct canid_match *cm_old = (struct canid_match *)m->data;
> +	int i;
> +	int rulescnt;
> +
> +	if (!len)
> +		return -EINVAL;
> +
> +	if (len % sizeof(struct can_filter))
> +		return -EINVAL;
> +
> +	if (len > sizeof(struct can_filter) * EM_CAN_RULES_MAX)
> +		return -EINVAL;
> +
> +	rulescnt = len / sizeof(struct can_filter);
> +
> +	cm = kzalloc(sizeof(struct canid_match) + sizeof(struct can_filter) *
> +		rulescnt, GFP_KERNEL);
> +	if (!cm)
> +		return -ENOMEM;
> +
> +	cm->sff_rules_count = 0;
> +	cm->eff_rules_count = 0;


These two lines are obsolete as you used kzalloc(), right?

> +	cm->rules_count = rulescnt;
> +
> +	/*
> +	 * We need two for() loops for copying rules into
> +	 * two contiguous areas in rules_raw
> +	 */
> +
> +	/* Process EFF frame rules*/
> +	for (i = 0; i < cm->rules_count; i++) {


use rulescnt instead of cm->rules_count (no need to derefence data)

> +		if (((conf[i].can_id & CAN_EFF_FLAG) &&
> +		    (conf[i].can_mask & CAN_EFF_FLAG)) ||
> +		    !(conf[i].can_mask & CAN_EFF_FLAG)) {
> +			memcpy(cm->rules_raw + cm->eff_rules_count,
> +				&conf[i],
> +				sizeof(struct can_filter));
> +
> +			cm->eff_rules_count++;
> +		} else {
> +			continue;
> +		}
> +	}
> +
> +	/* Process SFF frame rules */
> +	for (i = 0; i < cm->rules_count; i++) {


use rulescnt instead of cm->rules_count (no need to derefence data)

> +		if ((conf[i].can_id & CAN_EFF_FLAG) &&
> +		    (conf[i].can_mask & CAN_EFF_FLAG)) {



|| !(conf[i].can_mask & CAN_EFF_FLAG)) {

is missing here (must be the same as the condition above!)

> +			continue;
> +		} else {
> +			memcpy(cm->rules_raw
> +				+ cm->eff_rules_count
> +				+ cm->sff_rules_count,
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


*cm is no longer a fixed structure as it was in the first patches.

Must be:

m->datalen = sizeof(struct canid_match) + sizeof(struct can_filter) * rulescnt

> +	m->data = (unsigned long)cm;
> +


Sorry, that i didn't see that before :-(

Regards,
Oliver

