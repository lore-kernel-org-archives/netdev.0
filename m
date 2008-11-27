From: Patrick McHardy <kaber@trash.net>
Subject: Re: [PATCH 07/39] wimax: generic WiMAX device management
 (registration, deregistration, etc)
Date: Thu, 27 Nov 2008 11:40:58 +0100
Message-ID: <492E793A.7020501@trash.net>
References: <cover.1227691434.git.inaky@linux.intel.com>
	<8b18de7322859679eefc5e9f1a86249d41762140.1227691434.git.inaky@linux.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, wimax@linuxwimax.org
To: Inaky Perez-Gonzalez <inaky@linux.intel.com>
Return-path: <wimax-bounces@linuxwimax.org>
In-Reply-To: <8b18de7322859679eefc5e9f1a86249d41762140.1227691434.git.inaky@linux.intel.com>
List-Unsubscribe: <http://www.linuxwimax.org/mailman/listinfo/wimax>,
	<mailto:wimax-request@linuxwimax.org?subject=unsubscribe>
List-Archive: <http://lists.moblin.org/pipermail/wimax>
List-Post: <mailto:wimax@linuxwimax.org>
List-Help: <mailto:wimax-request@linuxwimax.org?subject=help>
List-Subscribe: <http://www.linuxwimax.org/mailman/listinfo/wimax>,
	<mailto:wimax-request@linuxwimax.org?subject=subscribe>
Sender: wimax-bounces@linuxwimax.org
Errors-To: wimax-bounces@linuxwimax.org
List-Id: netdev.vger.kernel.org

Inaky Perez-Gonzalez wrote:
> +static
> +struct nla_policy wimax_gnl_result_policy[WIMAX_GNL_ATTR_MAX + 1] = {

const please for all policies.

> +	// This is really a signed-64 bit number that has to be
> +	// casted from a u64
> +	[WIMAX_GNL_RESULT_CODE] = { .type = NLA_U64 },
> +};
> +*/
> +

> +int wimax_gnl_send_rp_result(struct wimax_dev *wimax_dev,
> +			     struct genl_info *genl_info,
> +			     ssize_t code)
> +{
> +	int result;
> +	struct device *dev = wimax_dev_to_dev(wimax_dev);
> +	void *data;
> +	struct sk_buff *reply_skb;
> +	s64 code_s64 = code;
> +
> +	d_fnstart(3, dev, "(wimax_dev %p info %p code %zd)\n",
> +		  wimax_dev, genl_info, code);
> +	result = -ENOMEM;
> +	reply_skb = nlmsg_new(NLMSG_DEFAULT_SIZE, GFP_KERNEL);
> +	if (reply_skb == NULL)
> +		goto error_new;
> +	data = genlmsg_put_reply(reply_skb, genl_info,
> +				 &wimax_dev->gnl_family,
> +				 0, WIMAX_GNL_RP_RESULT);
> +	if (data == NULL)
> +		goto error_put_reply;
> +
> +	result = nla_put_u64(reply_skb, WIMAX_GNL_RESULT_CODE, (u64) code_s64);
> +	if (result < 0)
> +		dev_err(dev, "Error putting attribute: %d\n", result);

This is not how netlink protocols should treat errors.
It should return -ENOSPC (everywhere else also of course).

> +
> +	genlmsg_end(reply_skb, data);
> +
> +	result = genlmsg_reply(reply_skb, genl_info);
> +	if (result < 0)
> +		goto error_reply;
> +	d_fnend(3, dev, "(wimax_dev %p info %p code %zd) = 0\n",
> +		wimax_dev, genl_info, code);
> +	return 0;
> +
> +error_reply:
> +error_put_reply:
> +	nlmsg_free(reply_skb);
> +error_new:
> +	d_fnend(3, dev, "(wimax_dev %p info %p code %zd) = %d\n",
> +		wimax_dev, genl_info, code, result);
> +	return result;
> +}
