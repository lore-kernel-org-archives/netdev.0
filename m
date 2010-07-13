From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: Re: [PATCH] netfilter: xtables: userspace notification target
Date: Tue, 13 Jul 2010 18:38:09 +0200
Message-ID: <4C3C9671.5090503@netfilter.org>
References: <20100713001115.GA3751@sortiz-mobl>	 <AANLkTil2EgQbzUqYNHAYpIWJvyyE6AWq1TpvxrqVsD7k@mail.gmail.com>	 <4C3C28EC.2000302@netfilter.org> <1279016596.12673.11.camel@chilepepper>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Changli Gao <xiaosuo@gmail.com>,
	Samuel Ortiz <sameo@linux.intel.com>,
	Patrick McHardy <kaber@trash.net>,
	"David S. Miller" <davem@davemloft.net>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"netfilter-devel@vger.kernel.org" <netfilter-devel@vger.kernel.org>
To: Luciano Coelho <luciano.coelho@nokia.com>
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <1279016596.12673.11.camel@chilepepper>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 13/07/10 12:23, Luciano Coelho wrote:
> On Tue, 2010-07-13 at 10:50 +0200, ext Pablo Neira Ayuso wrote:
>> On 13/07/10 08:18, Changli Gao wrote:
>>> On Tue, Jul 13, 2010 at 8:11 AM, Samuel Ortiz<sameo@linux.intel.com>  wrote:
>>>>
>>>> The userspace notification Xtables target sends a netlink notification
>>>> whenever a packet hits the target. Notifications have a label attribute
>>>> for userspace to match it against a previously set rule. The rules also
>>>> take a --all option to switch between sending a notification for all
>>>> packets or for the first one only.
>>>> Userspace can also send a netlink message to toggle this switch while the
>>>> target is in place. This target uses the nefilter netlink framework.
>>>>
>>>> This target combined with various matches (quota, rateest, etc..) allows
>>>> userspace to make decisions on interfaces handling. One could for example
>>>> decide to switch between power saving modes depending on estimated rate
>>>> thresholds.
>>>>
>>>
>>> It much like the following iptables rules.
>>>
>>> iptables -N log_and_drop
>>> iptables -A log_and_drop -j NFLOG --nflog-group 1 --nflog-prefix "log_and_drop"
>>> iptables -A log_and_drop -j DROP
>>>
>>> ...
>>> iptables ... -m quota --quota-bytes 20000 -j log_and_drop
>>> ...
>>
>> Indeed, this looks to me like something that you can do with NFLOG and
>> some combination of matches.
>
> Is it possible to have the NFLOG send only one notification to the
> userspace?

Not possible, but you could easily extend NFLOG to implement this 
feature if it's not possible to do what you need with the existing 
matches/targets. This NOTIF infrastructure is redundant and it looks 
like a subset of NFLOG.

There's a padding field in xt_NFLOG that is currently unused, it could 
be used for this.

Or we could add some 'count' match to store the number of packets that 
have matched a rule (although not sure if this is generic enough to be 
useful for others).

> In the example above, once the quota exceeds, the userspace
> will be notified of every packet arriving, won't it?  That would cause
> unnecessary processing in the userspace.
>
> The userspace could remove the rule when it gets the first notification
> and only add it again when it needs to get the information again (as a
> "toggle" functionality), but I think that would take too long and there
> would be several packets going through before the rule could be removed.

You can do that with libnetfilter_log to handle the log messages 
received and the minor change for xt_NFLOG that I proposed.
