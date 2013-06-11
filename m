From: Jiri Pirko <jiri@resnulli.us>
Subject: Re: [patch net-next 1/3] team: remove synchronize_rcu() called
 during queue override change
Date: Tue, 11 Jun 2013 10:01:07 +0200
Message-ID: <20130611080107.GA1916@minipsycho.brq.redhat.com>
References: <1370878945-9718-1-git-send-email-jiri@resnulli.us>
 <1370878945-9718-2-git-send-email-jiri@resnulli.us>
 <20130611004845.GF11894@obelix.rh>
 <20130611054046.GA1533@minipsycho.orion>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, davem@davemloft.net, edumazet@google.com
To: fbl@redhat.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ee0-f44.google.com ([74.125.83.44]:48990 "EHLO
	mail-ee0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751877Ab3FKIBL (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 11 Jun 2013 04:01:11 -0400
Received: by mail-ee0-f44.google.com with SMTP id c13so3546831eek.31
        for <netdev@vger.kernel.org>; Tue, 11 Jun 2013 01:01:10 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <20130611054046.GA1533@minipsycho.orion>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Tue, Jun 11, 2013 at 07:40:46AM CEST, jiri@resnulli.us wrote:
>Tue, Jun 11, 2013 at 02:48:45AM CEST, fbl@redhat.com wrote:
>>On Mon, Jun 10, 2013 at 05:42:23PM +0200, Jiri Pirko wrote:
>>> This patch removes synchronize_rcu() from function
>>> __team_queue_override_port_del(). That can be done because it is ok to
>>> do list_del_rcu() and list_add_tail_rcu() on the same list_head member
>>> without calling synchronize_rcu() in between. A bit of refactoring
>>> needed to be done because INIT_LIST_HEAD needed to be removed (to not
>>> kill the forward pointer) as well.
>>> 
>>> Signed-off-by: Jiri Pirko <jiri@resnulli.us>
>>> ---
>>>  drivers/net/team/team.c | 63 ++++++++++++++++++++++++++++++++++++-------------
>>>  1 file changed, 47 insertions(+), 16 deletions(-)
>>> 
>>[...]
>>
>>> @@ -1278,17 +1310,16 @@ static int team_queue_id_option_set(struct team *team,
>>>  				    struct team_gsetter_ctx *ctx)
>>>  {
>>>  	struct team_port *port = ctx->info->port;
>>> +	u16 new_queue_id = ctx->data.u32_val;
>>>  
>>> -	if (port->queue_id == ctx->data.u32_val)
>>> +	if (port->queue_id == new_queue_id)
>>
>>Since you're passing new_queue_id to port->queue_id and
>>in the other parts you test against !port->queue_id to see
>>if it's enable or not, that means queue 0 can't be used.
>>
>>Maybe I am missing something, but wouldn't be better to
>>initialize with -1 and allow 0 to be used as well?
>
>0 means default queue. It's done the same was as in bonding code.

+ this patch does not change original behaviour...

>
>>
>>fbl
>>
>>>  		return 0;
>>> -	if (ctx->data.u32_val >= team->dev->real_num_tx_queues)
>>> +	if (new_queue_id >= team->dev->real_num_tx_queues)
>>>  		return -EINVAL;
>>> -	port->queue_id = ctx->data.u32_val;
>>> -	team_queue_override_port_refresh(team, port);
>>> +	team_queue_override_port_change_queue_id(team, port, new_queue_id);
>>>  	return 0;
>>>  }
>>>  
>>
