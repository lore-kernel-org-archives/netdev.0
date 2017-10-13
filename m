From: Vinicius Costa Gomes <vinicius.gomes@intel.com>
Subject: Re: [next-queue PATCH v7 4/6] net/sched: Introduce Credit Based Shaper (CBS) qdisc
Date: Fri, 13 Oct 2017 15:54:19 -0700
Message-ID: <8760bimzfo.fsf@intel.com>
References: <20171013004005.17416-1-vinicius.gomes@intel.com> <20171013004005.17416-5-vinicius.gomes@intel.com> <20171013195924.GA19439@khorivan>
Mime-Version: 1.0
Content-Type: text/plain
Cc: netdev@vger.kernel.org, intel-wired-lan@lists.osuosl.org,
        jhs@mojatatu.com, xiyou.wangcong@gmail.com, jiri@resnulli.us,
        andre.guedes@intel.com, ivan.briano@intel.com,
        jesus.sanchez-palencia@intel.com, boon.leong.ong@intel.com,
        richardcochran@gmail.com, henrik@austad.us, levipearson@gmail.com,
        rodney.cummings@ni.com
To: Ivan Khoronzhuk <ivan.khoronzhuk@linaro.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga03.intel.com ([134.134.136.65]:60417 "EHLO mga03.intel.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1753192AbdJMWyV (ORCPT <rfc822;netdev@vger.kernel.org>);
        Fri, 13 Oct 2017 18:54:21 -0400
In-Reply-To: <20171013195924.GA19439@khorivan>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,

Ivan Khoronzhuk <ivan.khoronzhuk@linaro.org> writes:

[...]

>> +
>> +static int cbs_enqueue_soft(struct sk_buff *skb, struct Qdisc *sch)
>> +{
>> +	struct cbs_sched_data *q = qdisc_priv(sch);
>> +
>> +	if (sch->q.qlen == 0 && q->credits > 0) {
>> +		/* We need to stop accumulating credits when there's
>> +		 * no packet enqueued packets and q->credits is
> no packet -> no

Ugh. Fixed.

>
>> +		 * positive.
>> +		 */
>> +		q->credits = 0;
>> +		q->last = ktime_get_ns();
>> +	}
>> +
>> +	return qdisc_enqueue_tail(skb, sch);
>> +}
>> +

[...]

>> +static struct sk_buff *cbs_dequeue_soft(struct Qdisc *sch)
>> +{
>> +	struct cbs_sched_data *q = qdisc_priv(sch);
>> +	s64 now = ktime_get_ns();
>> +	struct sk_buff *skb;
>> +	s64 credits;
>> +	int len;
>> +
>> +	if (q->credits < 0) {
>> +		credits = timediff_to_credits(now - q->last, q->idleslope);
> Maybe be better to add small optimization by moving some calculations from data
> path, I mean, save idle_slope in bytes instead of kbit and converting it for
> every packet. Both delay_from_credits() and timediff_to_credits() is used only
> once and with idle_slope only...and both of them converting it.
>
> Same for credits_from_len() and send slope, save it in units of port_rate.
>

Done. Thanks.


Cheers,
