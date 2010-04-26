From: ebiederm@xmission.com (Eric W. Biederman)
Subject: Re: [PATCH net-2.6] netns: assign NULL after pernet memory is freed
Date: Mon, 26 Apr 2010 11:05:25 -0700
Message-ID: <m18w8af5sq.fsf@fess.ebiederm.org>
References: <20100426111806.GB2941@psychotron.lab.eng.brq.redhat.com>
	<20100426120716.GD2941@psychotron.lab.eng.brq.redhat.com>
	<20100426133020.GE2941@psychotron.lab.eng.brq.redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, davem@davemloft.net
To: Jiri Pirko <jpirko@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from out02.mta.xmission.com ([166.70.13.232]:36848 "EHLO
	out02.mta.xmission.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751918Ab0DZSFa (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 26 Apr 2010 14:05:30 -0400
In-Reply-To: <20100426133020.GE2941@psychotron.lab.eng.brq.redhat.com> (Jiri Pirko's message of "Mon\, 26 Apr 2010 15\:30\:20 +0200")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Jiri Pirko <jpirko@redhat.com> writes:

> Mon, Apr 26, 2010 at 02:07:17PM CEST, jpirko@redhat.com wrote:
>>Mon, Apr 26, 2010 at 01:18:07PM CEST, jpirko@redhat.com wrote:
>>>This is needed to let know appropriate code (driver) know that pernet memory
>>>chunk  was freed already. For example when driver has also registered netdev
>>>notifier, it can be called after memory is freed which could eventually lead
>>>to panic. Also a null check should be present in these notifiers.
>>>
>>>For example, previously, when drivers were responsible for pernet memory
>>>allocation/freeing, in pppoe this assign was done in pppoe_exit_net() right
>>>after pernet memory was freed. The check in notifier stayed (in pppoe_flush_dev
>>>called from pppoe_device_event) but makes no sense now without this patch.
>>
>>Hmm, thinking about this, since the life of pernet memories is directly connected
>>with the life of net, as described by Eric, this should not be needed. So please
>>scrach this one too. Sorry.
>>
>>Anyway, I'm still wondering how to prevent netdev_notifiers from using this when
>>net is gone. Going to do more research, I'm probably missing something.
>
> Right, it becomes part of init_ns then. So this looks good then. One thing I can
> still imagine what may cause problem, since netdev_notifier is registered before
> register_pernet_device, the notifier can be called in between. So I think this
> should be reordered, am I right?

No.  We guarantee that all network devices are either destroyed or moved
to init_net with the appropriate notifications sent.  Before we tear down
the network namespace.  This guarantees we won't have packets in flight when
destroying the network subsystems.

The moving and destroying of network devices should simply look like normal
events, that don't need special handling.

Eric
