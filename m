From: ebiederm@xmission.com (Eric W. Biederman)
Subject: Re: [PATCH net-2.6] netns: assign NULL after pernet memory is freed
Date: Mon, 26 Apr 2010 11:01:23 -0700
Message-ID: <m1vdbef5zg.fsf@fess.ebiederm.org>
References: <20100426111806.GB2941@psychotron.lab.eng.brq.redhat.com>
	<20100426120716.GD2941@psychotron.lab.eng.brq.redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, davem@davemloft.net
To: Jiri Pirko <jpirko@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from out01.mta.xmission.com ([166.70.13.231]:55036 "EHLO
	out01.mta.xmission.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754196Ab0DZSB3 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 26 Apr 2010 14:01:29 -0400
In-Reply-To: <20100426120716.GD2941@psychotron.lab.eng.brq.redhat.com> (Jiri Pirko's message of "Mon\, 26 Apr 2010 14\:07\:17 +0200")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Jiri Pirko <jpirko@redhat.com> writes:

> Mon, Apr 26, 2010 at 01:18:07PM CEST, jpirko@redhat.com wrote:
>>This is needed to let know appropriate code (driver) know that pernet memory
>>chunk  was freed already. For example when driver has also registered netdev
>>notifier, it can be called after memory is freed which could eventually lead
>>to panic. Also a null check should be present in these notifiers.
>>
>>For example, previously, when drivers were responsible for pernet memory
>>allocation/freeing, in pppoe this assign was done in pppoe_exit_net() right
>>after pernet memory was freed. The check in notifier stayed (in pppoe_flush_dev
>>called from pppoe_device_event) but makes no sense now without this patch.
>
> Hmm, thinking about this, since the life of pernet memories is directly connected
> with the life of net, as described by Eric, this should not be needed. So please
> scrach this one too. Sorry.
>
> Anyway, I'm still wondering how to prevent netdev_notifiers from using this when
> net is gone. Going to do more research, I'm probably missing something.

Also semenatically net_assign_generic is only guaranteed to work once, so assigning
NULL is at least semantically wrong.

Eric


>>I already know about several notifiers where the check should be present,
>>patches will follow up.
>>
>>Signed-off-by: Jiri Pirko <jpirko@redhat.com>
>>
>>diff --git a/net/core/net_namespace.c b/net/core/net_namespace.c
>>index bd8c471..29f622c 100644
>>--- a/net/core/net_namespace.c
>>+++ b/net/core/net_namespace.c
>>@@ -51,6 +51,7 @@ static void ops_free(const struct pernet_operations *ops, struct net *net)
>> 	if (ops->id && ops->size) {
>> 		int id = *ops->id;
>> 		kfree(net_generic(net, id));
>>+		net_assign_generic(net, id, NULL);
>> 	}
>> }
>> 
