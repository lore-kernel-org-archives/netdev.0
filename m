From: David Ahern <dsa@cumulusnetworks.com>
Subject: Re: [PATCH iproute2 1/6] ip vrf: Add name_is_vrf
Date: Wed, 29 Jun 2016 10:57:58 -0600
Message-ID: <c39fca71-39be-6573-ae56-00d0e168c90b@cumulusnetworks.com>
References: <1467053461-16147-1-git-send-email-dsa@cumulusnetworks.com>
 <1467053461-16147-2-git-send-email-dsa@cumulusnetworks.com>
 <20160629080613.6d368b4f@xeon-e3>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Stephen Hemminger <stephen@networkplumber.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f178.google.com ([209.85.192.178]:32992 "EHLO
	mail-pf0-f178.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751674AbcF2Q56 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 29 Jun 2016 12:57:58 -0400
Received: by mail-pf0-f178.google.com with SMTP id i123so19912540pfg.0
        for <netdev@vger.kernel.org>; Wed, 29 Jun 2016 09:57:57 -0700 (PDT)
In-Reply-To: <20160629080613.6d368b4f@xeon-e3>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 6/29/16 9:06 AM, Stephen Hemminger wrote:
> On Mon, 27 Jun 2016 11:50:56 -0700
> David Ahern <dsa@cumulusnetworks.com> wrote:
>
>> diff --git a/ip/ip_common.h b/ip/ip_common.h
>> index e8da9e034b15..410eb135774a 100644
>> --- a/ip/ip_common.h
>> +++ b/ip/ip_common.h
>> @@ -90,6 +90,8 @@ struct link_util *get_link_slave_kind(const char *slave_kind);
>>
>>  void br_dump_bridge_id(const struct ifla_bridge_id *id, char *buf, size_t len);
>>
>> +bool name_is_vrf(char *name);
>> +
>>  #ifndef	INFINITY_LIFE_TIME
>>  #define     INFINITY_LIFE_TIME      0xFFFFFFFFU
>>  #endif
>> diff --git a/ip/iplink_vrf.c b/ip/iplink_vrf.c
>> index e3c7b4652da5..abd43c08423e 100644
>> --- a/ip/iplink_vrf.c
>> +++ b/ip/iplink_vrf.c
>> @@ -96,3 +96,56 @@ struct link_util vrf_slave_link_util = {
>>  	.print_opt	= vrf_slave_print_opt,
>>  	.slave          = true,
>>  };
>> +
>> +bool name_is_vrf(char *name)
>
> Why not?
> bool name_is_vrf(const char *name)

sure.

>
>> +{
>> +	struct {
>> +		struct nlmsghdr		n;
>> +		struct ifinfomsg	i;
>> +		char			buf[1024];
>> +	} req = {
>> +		.n = {
>> +			.nlmsg_len   = NLMSG_LENGTH(sizeof(struct ifinfomsg)),
>> +			.nlmsg_flags = NLM_F_REQUEST,
>> +			.nlmsg_type  = RTM_GETLINK,
>> +		},
>> +		.i = {
>> +			.ifi_family  = preferred_family,
>> +		},
>> +	};
>> +	struct {
>> +		struct nlmsghdr n;
>> +		char buf[8192];
>> +	} answer;
>> +	struct rtattr *tb[IFLA_MAX+1];
>> +	struct rtattr *li[IFLA_INFO_MAX+1];
>> +	struct ifinfomsg *ifi;
>> +	int len;
>> +
>> +	addattr_l(&req.n, sizeof(req), IFLA_IFNAME, name, strlen(name) + 1);
>> +
>> +	if (rtnl_talk(&rth, &req.n, &answer.n, sizeof(answer)) < 0)
>> +		goto err;
> Just return false instead of all these goto's?
> Also you might want to give some indication of error.

Any failure and the user gets the message "not a VRF". The reason can be 
the device is not a VRF or the device does not exist but that's the same 
thing in this case:

$ ./ip link show vrf foo
Error: argument "foo" is wrong: Not a valid VRF name

$ ./ip link show vrf eth1
Error: argument "eth1" is wrong: Not a valid VRF name
