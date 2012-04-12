From: Denys Fedoryshchenko <denys@visp.net.lb>
Subject: Re: [PATCH 1/1] netfilter: =?UTF-8?Q?xt=5Frecent=3A=20Add=20optio?=
 =?UTF-8?Q?nal=20mask=20option=20for=20xt=5Frecent?=
Date: Thu, 12 Apr 2012 12:00:03 +0300
Message-ID: <d8de90a8f08a092730109e72827264fe@visp.net.lb>
References: <1331033084-23803-1-git-send-email-denys@visp.net.lb>
 <20120411231421.GA7038@1984>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8;
 format=flowed
Content-Transfer-Encoding: 7bit
Cc: Patrick McHardy <kaber@trash.net>,
	"David S. Miller" <davem@davemloft.net>,
	<netfilter-devel@vger.kernel.org>, <netfilter@vger.kernel.org>,
	<coreteam@netfilter.org>, <linux-kernel@vger.kernel.org>,
	<netdev@vger.kernel.org>
To: Pablo Neira Ayuso <pablo@netfilter.org>
Return-path: <netfilter-owner@vger.kernel.org>
In-Reply-To: <20120411231421.GA7038@1984>
Sender: netfilter-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi Pablo

On 2012-04-12 02:14, Pablo Neira Ayuso wrote:
> Hi Denys,
>
> On Tue, Mar 06, 2012 at 01:24:44PM +0200, Denys Fedoryshchenko wrote:
>> Use case for this feature:
>> 1)In some occasions if you need to allow,block,match specific 
>> subnet.
>> 2)I can use recent as a trigger when netfilter rule matches, with 
>> mask 0.0.0.0
>>
>> Example:
>>
>> If you ping 8.8.8.8, after that you can't ping 2.2.2.10
>
> Could you provide an useful example for this new feature?
>
> I also think you can make this with hashlimit, that allows you to
> set the network mask.

Yes, technically hashlimit can do a lot, but not everything. Especially 
because xt_recent can be "fine-grained" in steps, depends on timeline of 
event, and can be updated accordingly to time of reoccurred event. It is 
generally not related to mask option, but mask gives power to block 
subnets.
Why for example /24? Well, it is minimal mask for BGP announce :) It is 
very often, that requesting ip has more ip's in same subnet 
(load-balancing, or multiple ip's on dedicated server), and mask will be 
highly useful for that, to reduce number of entries and to tighten weak 
points (usually after ip blocked, they try from neighbor ip to check, if 
destination just blocked single ip). Plus rttl and hitcount another 
sweet things that are available in xt_recent, but aren't in hashlimit.

iptables -t mangle -N SIP
# If someone abuse our SIP, block him completely at least for 10 
seconds, if he try again, update and block for new 120 seconds
iptables -t mangle -A SIP -m recent --name X --update --seconds 10 
--mask 255.255.255.0 -j MARK --set-mark 0x1
# 120 - 600 seconds handle him over special relay (that will log his 
query, but wont pass him to real SIP server)
iptables -t mangle -A SIP -m recent --name X --rcheck --seconds 600 
--mask 255.255.255.0 -j MARK --set-mark 0x2

In this case i will log only invalid queries, but for example some DDoS 
or scanners that flood servers by packets will be silently ignored. 
Maybe if hitcount really bad, i will add them to ipset, and block 
permanently, by -m set --add-set.

For me personally it is useful, because i have around 140 NAS servers, 
and i give each of them /24 "gray" subnets, and in some cases i need to 
handle bad users, that are changing dynamic ip and attacking from new ip 
each time. I just block non-critical service for whole subnet then, till 
technician on duty will solve issue completely. And sure if attack are 
stopped, subnet will be unblocked "automagically".

Sure this feature not critical, or "a must", and if code are not good, 
it is up to you, if it should be added or not.

