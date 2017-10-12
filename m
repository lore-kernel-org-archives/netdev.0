From: Jesus Sanchez-Palencia <jesus.sanchez-palencia@intel.com>
Subject: Re: [next-queue PATCH v6 3/5] net/sched: Introduce Credit Based
 Shaper (CBS) qdisc
Date: Thu, 12 Oct 2017 08:45:37 -0700
Message-ID: <7c1420f1-45a4-7a4b-7010-9049cc7bb352@intel.com>
References: <20171012005449.26533-1-vinicius.gomes@intel.com>
 <20171012005449.26533-4-vinicius.gomes@intel.com>
 <20171012075826.GA29396@sisyphus.home.austad.us>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, intel-wired-lan@lists.osuosl.org,
        jhs@mojatatu.com, xiyou.wangcong@gmail.com, jiri@resnulli.us,
        andre.guedes@intel.com, ivan.briano@intel.com,
        boon.leong.ong@intel.com, richardcochran@gmail.com,
        levipearson@gmail.com, rodney.cummings@ni.com
To: Henrik Austad <henrik@austad.us>,
        Vinicius Costa Gomes <vinicius.gomes@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga06.intel.com ([134.134.136.31]:27630 "EHLO mga06.intel.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1753086AbdJLPxJ (ORCPT <rfc822;netdev@vger.kernel.org>);
        Thu, 12 Oct 2017 11:53:09 -0400
In-Reply-To: <20171012075826.GA29396@sisyphus.home.austad.us>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Henrik,


On 10/12/2017 12:58 AM, Henrik Austad wrote:
> On Wed, Oct 11, 2017 at 05:54:47PM -0700, Vinicius Costa Gomes wrote:
>> This queueing discipline implements the shaper algorithm defined by
>> the 802.1Q-2014 Section 8.6.8.2 and detailed in Annex L.
>>
>> It's primary usage is to apply some bandwidth reservation to user
>> defined traffic classes, which are mapped to different queues via the
>> mqprio qdisc.
>>
>> Only a simple software implementation is added for now.
>>
>> Signed-off-by: Vinicius Costa Gomes <vinicius.gomes@intel.com>
>> Signed-off-by: Jesus Sanchez-Palencia <jesus.sanchez-palencia@intel.com>
>> ---
>>  include/uapi/linux/pkt_sched.h |  18 +++
>>  net/sched/Kconfig              |  11 ++
>>  net/sched/Makefile             |   1 +
>>  net/sched/sch_cbs.c            | 302 +++++++++++++++++++++++++++++++++++++++++
>>  4 files changed, 332 insertions(+)
>>  create mode 100644 net/sched/sch_cbs.c
>>
>> diff --git a/include/uapi/linux/pkt_sched.h b/include/uapi/linux/pkt_sched.h
>> index 099bf5528fed..41e349df4bf4 100644
>> --- a/include/uapi/linux/pkt_sched.h
>> +++ b/include/uapi/linux/pkt_sched.h
>> @@ -871,4 +871,22 @@ struct tc_pie_xstats {
>>  	__u32 maxq;             /* maximum queue size */
>>  	__u32 ecn_mark;         /* packets marked with ecn*/
>>  };
>> +
>> +/* CBS */
>> +struct tc_cbs_qopt {
>> +	__u8 offload;
>> +	__s32 hicredit;
>> +	__s32 locredit;
>> +	__s32 idleslope;
>> +	__s32 sendslope;
>> +};
>> +
>> +enum {
>> +	TCA_CBS_UNSPEC,
>> +	TCA_CBS_PARMS,
>> +	__TCA_CBS_MAX,
>> +};
>> +
>> +#define TCA_CBS_MAX (__TCA_CBS_MAX - 1)
>> +
>>  #endif
>> diff --git a/net/sched/Kconfig b/net/sched/Kconfig
>> index e70ed26485a2..c03d86a7775e 100644
>> --- a/net/sched/Kconfig
>> +++ b/net/sched/Kconfig
>> @@ -172,6 +172,17 @@ config NET_SCH_TBF
>>  	  To compile this code as a module, choose M here: the
>>  	  module will be called sch_tbf.
>>  
>> +config NET_SCH_CBS
>> +	tristate "Credit Based Shaper (CBS)"
> 
> Any particular reason why the dependency to MQPRIO was dropped? I'm only 
> asking because you added it in v1 of the series and then it disappeared in 
> v2 and onwards.


The main reason is that currently there are no qdiscs that depend on any other
specifically. The dependency CBS had on MQPRIO came from how we were calculating
the queue index from the qdisc id inside sch_cbc.c . During the previous review
rounds we agreed on a fix for that and the dependency could be finally removed.


(...)


>> +static int cbs_change(struct Qdisc *sch, struct nlattr *opt)
>> +{
>> +	struct cbs_sched_data *q = qdisc_priv(sch);
>> +	struct net_device *dev = qdisc_dev(sch);
>> +	struct nlattr *tb[TCA_CBS_MAX + 1];
>> +	struct ethtool_link_ksettings ecmd;
>> +	struct tc_cbs_qopt *qopt;
>> +	s64 link_speed;
>> +	int err;
>> +
>> +	err = nla_parse_nested(tb, TCA_CBS_MAX, opt, cbs_policy, NULL);
>> +	if (err < 0)
>> +		return err;
>> +
>> +	if (!tb[TCA_CBS_PARMS])
>> +		return -EINVAL;
>> +
>> +	qopt = nla_data(tb[TCA_CBS_PARMS]);
>> +
>> +	if (qopt->offload)
>> +		return -EOPNOTSUPP;
>> +
>> +	if (!__ethtool_get_link_ksettings(dev, &ecmd))
>> +		link_speed = ecmd.base.speed;
>> +	else
>> +		link_speed = SPEED_1000;
>> +
>> +	q->port_rate = link_speed * 1000 * BYTES_PER_KBIT;
>> +
>> +	q->enqueue = cbs_enqueue_soft;
>> +	q->dequeue = cbs_dequeue_soft;
> 
> How does one use the cbs_(en|de)queue instead of _soft()?


Judging from your comment on the other patch I believe you've got that
clarified. Please let us know if otherwise.

Thanks,
Jesus
