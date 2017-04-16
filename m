From: Roopa Prabhu <roopa-qUQiAmfTcIp+XZJcv9eMoEEOCMrvLtNR@public.gmane.org>
Subject: Re: [PATCH net-next v2 4/6] vxlan: check valid
 combinations of address scopes
Date: Sun, 16 Apr 2017 10:15:05 -0700
Message-ID: <58F3A699.5070002@cumulusnetworks.com>
References: <cover.1492187126.git.mschiffer@universe-factory.net>
	<49cd788f13c2cd3f6a42f34c219c9511cc1f9cec.1492187126.git.mschiffer@universe-factory.net>
	<20170414103604.61ecffa9@xeon-e3>
	<d401b6c7-357a-1e1c-13bd-64e9af951971@universe-factory.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: dev-yBygre7rU0TnMu66kgdUjQ@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, jbenc-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org,
	Stephen Hemminger <stephen-OTpzqLSitTUnbdJkjeBofR2eb7JE58TQ@public.gmane.org>,
	aduyck-nYU0QVwCCFFWk0Htik3J/w@public.gmane.org, davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: Matthias Schiffer <mschiffer-Nyw9WiXk/RKXhJHkyCwd5uTW4wlIGRCZ@public.gmane.org>
Return-path: <ovs-dev-bounces-yBygre7rU0TnMu66kgdUjQ@public.gmane.org>
In-Reply-To: <d401b6c7-357a-1e1c-13bd-64e9af951971-Nyw9WiXk/RKXhJHkyCwd5uTW4wlIGRCZ@public.gmane.org>
List-Unsubscribe: <https://mail.openvswitch.org/mailman/options/ovs-dev>,
	<mailto:ovs-dev-request-yBygre7rU0TnMu66kgdUjQ@public.gmane.org?subject=unsubscribe>
List-Archive: <http://mail.openvswitch.org/pipermail/ovs-dev/>
List-Post: <mailto:ovs-dev-yBygre7rU0TnMu66kgdUjQ@public.gmane.org>
List-Help: <mailto:ovs-dev-request-yBygre7rU0TnMu66kgdUjQ@public.gmane.org?subject=help>
List-Subscribe: <https://mail.openvswitch.org/mailman/listinfo/ovs-dev>,
	<mailto:ovs-dev-request-yBygre7rU0TnMu66kgdUjQ@public.gmane.org?subject=subscribe>
Sender: ovs-dev-bounces-yBygre7rU0TnMu66kgdUjQ@public.gmane.org
Errors-To: ovs-dev-bounces-yBygre7rU0TnMu66kgdUjQ@public.gmane.org
List-Id: netdev.vger.kernel.org

On 4/16/17, 8:03 AM, Matthias Schiffer wrote:
> On 04/14/2017 07:36 PM, Stephen Hemminger wrote:
>> On Fri, 14 Apr 2017 18:44:44 +0200
>> Matthias Schiffer <mschiffer-Nyw9WiXk/RKXhJHkyCwd5uTW4wlIGRCZ@public.gmane.org> wrote:
>>
>>> diff --git a/drivers/net/vxlan.c b/drivers/net/vxlan.c
>>> index 07f89b037681..95a71546e8f2 100644
>>> --- a/drivers/net/vxlan.c
>>> +++ b/drivers/net/vxlan.c
>>> @@ -2881,11 +2881,39 @@ static int vxlan_config_validate(struct net *src_net, struct vxlan_config *conf,
>>>  	if (conf->saddr.sa.sa_family != conf->remote_ip.sa.sa_family)
>>>  		return -EINVAL;
>>>  
>>> +	if (vxlan_addr_multicast(&conf->saddr))
>>> +		return -EINVAL;
>>> +
>>>  	if (conf->saddr.sa.sa_family == AF_INET6) {
>>>  		if (!IS_ENABLED(CONFIG_IPV6))
>>>  			return -EPFNOSUPPORT;
>>>  		use_ipv6 = true;
>>>  		conf->flags |= VXLAN_F_IPV6;
>>> +
>>> +		if (!(conf->flags & VXLAN_F_COLLECT_METADATA)) {
>>> +			int local_type =
>>> +				ipv6_addr_type(&conf->saddr.sin6.sin6_addr);
>>> +			int remote_type =
>>> +				ipv6_addr_type(&conf->remote_ip.sin6.sin6_addr);
>>> +
>>> +			if (local_type & IPV6_ADDR_LINKLOCAL) {
>>> +				if (!(remote_type & IPV6_ADDR_LINKLOCAL) &&
>>> +				    (remote_type != IPV6_ADDR_ANY)) {
>>> +					pr_info("invalid combination of address scopes\n");
>> It is always helpful to include device if possible in error message.
>> 					netdev_notice(old->dev, " invalid combination of address scopes\n");
> That makes sense, I'll change it in v3.

I think it should just return -EINVAL here since this is in response to a netlink call from user-space.
I dont think we should print anything but like stephen says use the extended ack mechanism to propagate more information
about the error.


>
>> Also vxlan is good candidate for extended netlink error reporting.
> Can you point me to a piece of code that does this? Unless you insist, I
> wouldn't do it in this patchset, but I might implement the extended error
> reporting later.
>
For rtnetlink users (vxlan is one of them) this is still in the works... see patch "net: rtnetlink: plumb extended ack to doit function"
