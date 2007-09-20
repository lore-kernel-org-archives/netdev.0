From: Varun Chandramohan <varunc@linux.vnet.ibm.com>
Subject: [PATCH 0/3 Rev-4] Age Entry For IPv4 & IPv6 Route Table
Date: Thu, 20 Sep 2007 20:56:35 +0530
Message-ID: <20070920205635.4c9879f7.varunc@linux.vnet.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, kaber@trash.net, socketcan@hartkopp.net,
	shemminger@linux-foundation.org, krkumar2@in.ibm.com,
	tgraf@suug.ch, varuncha@in.ibm.com
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from e32.co.us.ibm.com ([32.97.110.150]:45721 "EHLO
	e32.co.us.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754460AbXITPZ2 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 20 Sep 2007 11:25:28 -0400
Received: from d03relay04.boulder.ibm.com (d03relay04.boulder.ibm.com [9.17.195.106])
	by e32.co.us.ibm.com (8.12.11.20060308/8.13.8) with ESMTP id l8KEHU6Y012492
	for <netdev@vger.kernel.org>; Thu, 20 Sep 2007 10:17:30 -0400
Received: from d03av01.boulder.ibm.com (d03av01.boulder.ibm.com [9.17.195.167])
	by d03relay04.boulder.ibm.com (8.13.8/8.13.8/NCO v8.5) with ESMTP id l8KFPR9D346380
	for <netdev@vger.kernel.org>; Thu, 20 Sep 2007 09:25:27 -0600
Received: from d03av01.boulder.ibm.com (loopback [127.0.0.1])
	by d03av01.boulder.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id l8KFPPFl022014
	for <netdev@vger.kernel.org>; Thu, 20 Sep 2007 09:25:27 -0600
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi Dave,
	Thanks for the comment. I have created another patch set as you have suggested.
Your Comments:
In avoiding the age initialization at routing cache insertion time,
you make the value provided totally inaccurate and essentially
useless especially the very first time the value is asked for.

I really don't like these changes, they have had problems every step
of the way, and the above proves that we could essentially always
return an age value of zero and still be compliant with the standards.

+	if (!*age) {
> +		*age = timeval_to_sec(&tv);
> +		NLA_PUT_U32(skb, RTA_AGE, *age);
I have made a mistake. Sorry i didnt catch it earlier :-)
So, NLA_PUT_U32(skb, RTA_AGE, 0) would have made more sense?
> +	} else {
> +		NLA_PUT_U32(skb, RTA_AGE, timeval_to_sec(&tv) - *age);
> +	}

Since you didnt like the hack, i have reimplemented the above by initilizing the age value at the time of insertion. I hope this is what you pointed out in your comments. Please let me know if its ok.

Stephen, as the age value is human readable we decided that it need not be accurate. I thought that rounding up will make it a bit more readable. But i think you are right. So, in this patchset i have taken care of this issue. Is this ok? 

Regards,
Varun

Original Comment:
According to the RFC 4292 (IP Forwarding Table MIB) there is a need for an age entry for all the routes in therouting table. The entry in the RFC is inetCidrRouteAge and oid is inetCidrRouteAge.1.10.
Many snmp application require this age entry. So iam adding the age field in the routing table for ipv4 and ipv6 and providing the interface for this value netlink.

I made a note of changes i made as per the suggestions given in the community. Here is the changelog.

Changelog since ver 1:
---------------------
        Changes							Suggestion	
 
1)Change in the interface from proc to netlink.
  It was not approved by David Miller and Yoshifuji.            David Miller & Yoshifuji

2)Change from jiffies to timeval.				Eric Dumazet

3)Rounding up timeval						Patrick McHardy, Oliver Hartkopp
								Eric Dumazet.

4)Relocate timeval_to_sec					Stephen Hemminger, Krishna Kumar

5)Using macro RT6_GET_ROUTE_INFO				Krishna Kumar

6)Add proper comment for timeval_to_sec				Eric Dumazet

7)Add proper comment for timeval insertion			Thomas Graf				  

8)Insert the age value at route insertion			David Miller

9)Remove round off.						Stephen Hemminger
Signed-off-by: Varun Chandramohan <varunc@linux.vnet.ibm.com>
---

