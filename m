From: Daniel Borkmann <daniel@iogearbox.net>
Subject: Re: [patch net-next v3] tc: introduce OpenFlow classifier
Date: Fri, 10 Apr 2015 11:30:06 +0200
Message-ID: <5527981E.2040505@iogearbox.net>
References: <1428584287-8197-1-git-send-email-jiri@resnulli.us> <20150409.173423.2258417584616634411.davem@davemloft.net> <20150410091203.GA2021@nanopsycho.orion>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, jhs@mojatatu.com, tgraf@suug.ch,
	jesse@nicira.com
To: Jiri Pirko <jiri@resnulli.us>, David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from www62.your-server.de ([213.133.104.62]:45592 "EHLO
	www62.your-server.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754593AbbDJJaN (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 10 Apr 2015 05:30:13 -0400
In-Reply-To: <20150410091203.GA2021@nanopsycho.orion>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 04/10/2015 11:12 AM, Jiri Pirko wrote:
...
>> However I am sure that I majorly object to having yet another flow
>> parsing engine.  Therefore, at least adjust this code to use our flow
>> dissector and datastructures.  Adjust the flow dissector to fit your
>> needs, if necessary.
>
> Yep, Thomas already suggested the merge. The thing is, cls_flow uses
> linked list for doing lookups. That is not scalable. in cls_openflow I
> use rhashtable. Using rhashtable in cls_flow would break the existing
> assumption that first inrested filter would be first hit.
>
> So that would lead into major dual code in cls_flow. So I believe that
> it is better to do it in separate cls_openflow (do one thing and do it
> right).

Would it be possible to 1) reuse the majority of the existing internal
cls_flow code as much as possible, integrate the remaining openflow
parts into it, and then 2) just register a 2nd classifier kind, a la ...

static struct tcf_proto_ops cls_flow_ht_ops __read_mostly = {
	.kind		= "flow-ht",
	.classify	= flow_classify_ht,
	.init		= flow_init,
	.destroy	= flow_destroy,
	.change		= flow_change,
	.delete		= flow_delete,
	.get		= flow_get,
	.dump		= flow_dump,
	.walk		= flow_walk,
	.owner		= THIS_MODULE,
};

... so you could do the non-linear rhashtable matching from there, but
without much duplication?
