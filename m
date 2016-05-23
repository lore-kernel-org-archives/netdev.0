From: "Wei Hu (Xavier)" <xavier.huwei-hv44wF8Li93QT0dZR+AlfA@public.gmane.org>
Subject: Re: [RESEND PATCH v7 17/21] IB/hns: Add QP operations support
Date: Mon, 23 May 2016 11:30:57 +0800
Message-ID: <57427971.6090300@huawei.com>
References: <1462849483-67927-1-git-send-email-oulijun@huawei.com>
 <1462849483-67927-18-git-send-email-oulijun@huawei.com>
 <bf001e31-982a-c51d-782e-81ee19f9de09@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="windows-1252"; format=flowed
Content-Transfer-Encoding: 7bit
Cc: <linux-rdma-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	<netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, <gongyangming-hv44wF8Li93QT0dZR+AlfA@public.gmane.org>,
	<xiaokun-hv44wF8Li93QT0dZR+AlfA@public.gmane.org>, <tangchaofei-hv44wF8Li93QT0dZR+AlfA@public.gmane.org>,
	<haifeng.wei-hv44wF8Li93QT0dZR+AlfA@public.gmane.org>, <yisen.zhuang-hv44wF8Li93QT0dZR+AlfA@public.gmane.org>,
	<yankejian-hv44wF8Li93QT0dZR+AlfA@public.gmane.org>, <charles.chenxin-hv44wF8Li93QT0dZR+AlfA@public.gmane.org>,
	<linuxarm-hv44wF8Li93QT0dZR+AlfA@public.gmane.org>
To: Doug Ledford <dledford-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>, Lijun Ou <oulijun-hv44wF8Li93QT0dZR+AlfA@public.gmane.org>,
	<sean.hefty-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>, <hal.rosenstock-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>,
	<davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>, <jeffrey.t.kirsher-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>,
	<jiri-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>, <ogerlitz-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>
Return-path: <linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <bf001e31-982a-c51d-782e-81ee19f9de09-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
Sender: linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

Hi, Doug Ledford
    In hns_roce_cmd_wait and hns_roce_cmd_poll, there are down&up 
seminal operations,
    So, there are not deadlock and conflict, right?

static int hns_roce_cmd_poll(struct hns_roce_dev *hr_dev, u64 in_param,
			     u64 *out_param, unsigned long in_modifier,
			     u8 op_modifier, u16 op, unsigned long timeout)
{
	struct device *dev = &hr_dev->pdev->dev;
	u8 __iomem *hcr = hr_dev->cmd.hcr;
	unsigned long end = 0;
	u32 status = 0;
	int ret;

	down(&hr_dev->cmd.poll_sem);

	..// <snip>

	up (&hr_dev->cmd.poll_sem);
	return ret;
}

static int hns_roce_cmd_wait(struct hns_roce_dev *hr_dev, u64 in_param,
			     u64 *out_param, unsigned long in_modifier,
			     u8 op_modifier, u16 op, unsigned long timeout)
{
	struct hns_roce_cmdq *cmd = &hr_dev->cmd;
	struct device *dev = &hr_dev->pdev->dev;
	struct hns_roce_cmd_context *context;
	int ret = 0;

	down(&cmd->event_sem);

	..// <snip>

	up (&cmd->event_sem);
	return ret;
}

int __hns_roce_cmd(struct hns_roce_dev *hr_dev, u64 in_param, u64 *out_param,
		   unsigned long in_modifier, u8 op_modifier, u16 op,
		   unsigned long timeout)
{
	if (hr_dev->cmd.use_events)
		return hns_roce_cmd_wait(hr_dev, in_param, out_param,
					 in_modifier, op_modifier, op, timeout);
	else
		return hns_roce_cmd_poll(hr_dev, in_param, out_param,
					 in_modifier, op_modifier, op, timeout);
}



     Thanks.

Regards
Wei Hu

On 2016/5/14 5:52, Doug Ledford wrote:
> On 05/09/2016 11:04 PM, Lijun Ou wrote:
>> +int __hns_roce_cmd(struct hns_roce_dev *hr_dev, u64 in_param, u64 *out_param,
>> +		   unsigned long in_modifier, u8 op_modifier, u16 op,
>> +		   unsigned long timeout);
>> +
>> +/* Invoke a command with no output parameter */
>> +static inline int hns_roce_cmd(struct hns_roce_dev *hr_dev, u64 in_param,
>> +			       unsigned long in_modifier, u8 op_modifier,
>> +			       u16 op, unsigned long timeout)
>> +{
>> +	return __hns_roce_cmd(hr_dev, in_param, NULL, in_modifier,
>> +			      op_modifier, op, timeout);
>> +}
>> +
>> +/* Invoke a command with an output mailbox */
>> +static inline int hns_roce_cmd_box(struct hns_roce_dev *hr_dev, u64 in_param,
>> +				   u64 out_param, unsigned long in_modifier,
>> +				   u8 op_modifier, u16 op,
>> +				   unsigned long timeout)
>> +{
>> +	return __hns_roce_cmd(hr_dev, in_param, &out_param, in_modifier,
>> +			      op_modifier, op, timeout);
>> +}
> This will make people scratch their head in the future.  You are using
> two commands to map to one command without there being any locking
> involved.  The typical convention for routine_1() -> __routine_1() is
> that the __ version requires that it be called while locked, and the
> version without a __ does the locking before calling it.  That way a
> used can always know if they aren't currently holding the appropriate
> lock, then they6 call routine_1() and if they are, they call
> __routine_1() to avoid a deadlock.  I would suggest changing the name of
> __hns_roce_cmd to hns_roce_cmd_box and completely remove the existing
> hns_roce_cmd_box inline, and then change the hns_roce_cmd() inline to
> directly call hns_roce_cmd_box() which will then select between
> event/poll command sends.
>


--
To unsubscribe from this list: send the line "unsubscribe linux-rdma" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
