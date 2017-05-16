From: Girish Moodalbail <girish.moodalbail@oracle.com>
Subject: Re: [PATCH net-next] geneve: add rtnl changelink support
Date: Tue, 16 May 2017 13:09:10 -0700
Message-ID: <b8ecc429-5710-cae8-0f43-9211abafb18d@oracle.com>
References: <1494870424-22699-1-git-send-email-girish.moodalbail@oracle.com>
 <20170516.153115.2084299272043901950.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, pshelar@ovn.org, joe@ovn.org,
        jbenc@redhat.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from userp1040.oracle.com ([156.151.31.81]:40910 "EHLO
        userp1040.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752362AbdEPUJi (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 16 May 2017 16:09:38 -0400
In-Reply-To: <20170516.153115.2084299272043901950.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 5/16/17 12:31 PM, David Miller wrote:
> From: Girish Moodalbail <girish.moodalbail@oracle.com>
> Date: Mon, 15 May 2017 10:47:04 -0700
>
>>  	if (data[IFLA_GENEVE_REMOTE]) {
>> -		info.key.u.ipv4.dst =
>> +		info->key.u.ipv4.dst =
>>  			nla_get_in_addr(data[IFLA_GENEVE_REMOTE]);
>>
>> -		if (IN_MULTICAST(ntohl(info.key.u.ipv4.dst))) {
>> +		if (IN_MULTICAST(ntohl(info->key.u.ipv4.dst))) {
>>  			netdev_dbg(dev, "multicast remote is unsupported\n");
>>  			return -EINVAL;
>>  		}
>> +		if (changelink &&
>> +		    ip_tunnel_info_af(&geneve->info) == AF_INET6) {
>> +			info->mode &= ~IP_TUNNEL_INFO_IPV6;
>> +			info->key.tun_flags &= ~TUNNEL_CSUM;
>> +			*use_udp6_rx_checksums = false;
>> +		}
>>  	}
>
> I don't understand this "changelink" guarded code, why do you need to
> clear all of this state out if the existing tunnel type if AF_INET6
> and only when doing a changelink?
>
> In any event, I think you need to add a comment explaining it.
>

If geneve link was overlayed over IPv6 network and now the user modifies the 
link to be over IPv4 network by doing

# ip link set gen0 type geneve id 100 remote 192.168.13.2

Then we will need to

  - reset info->mode to be not IPv6 type
  - the default for UDP checksum over IPv4 is 'no', so reset that and
  - set use_udp6_rx_checksums to its default value which is false.

I will capture the above information concisely in a comment around that 
'changelink' guard.

thanks,
~Girish
