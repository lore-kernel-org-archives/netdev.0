From: "Julius Volz" <juliusv@google.com>
Subject: Re: [PATCH 2/2] IPVS: Add genetlink interface implementation
Date: Thu, 10 Jul 2008 14:33:45 +0200
Message-ID: <f4845fc0807100533h6867ed00x8975d156b15a866f@mail.gmail.com>
References: <1215616317-11386-1-git-send-email-juliusv@google.com>
	 <1215616317-11386-3-git-send-email-juliusv@google.com>
	 <4874EABC.4000301@trash.net> <20080710112017.GA26952@google.com>
	 <20080710113649.GS20815@postel.suug.ch>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: "Patrick McHardy" <kaber@trash.net>, netdev@vger.kernel.org,
	lvs-devel@vger.kernel.org, vbusam@google.com, horms@verge.net.au,
	davem@davemloft.net
To: "Thomas Graf" <tgraf@suug.ch>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp-out.google.com ([216.239.33.17]:54508 "EHLO
	smtp-out.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754047AbYGJMdw (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 10 Jul 2008 08:33:52 -0400
Received: from spaceape7.eur.corp.google.com (spaceape7.eur.corp.google.com [172.28.16.141])
	by smtp-out.google.com with ESMTP id m6ACXlBu019736
	for <netdev@vger.kernel.org>; Thu, 10 Jul 2008 13:33:47 +0100
Received: from wf-out-1314.google.com (wfd27.prod.google.com [10.142.4.27])
	by spaceape7.eur.corp.google.com with ESMTP id m6ACXjst025812
	for <netdev@vger.kernel.org>; Thu, 10 Jul 2008 13:33:46 +0100
Received: by wf-out-1314.google.com with SMTP id 27so3133218wfd.17
        for <netdev@vger.kernel.org>; Thu, 10 Jul 2008 05:33:45 -0700 (PDT)
In-Reply-To: <20080710113649.GS20815@postel.suug.ch>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Jul 10, 2008 at 1:36 PM, Thomas Graf <tgraf@suug.ch> wrote:
> * Julius Volz <juliusv@google.com> 2008-07-10 13:20
>> +/* IPVS genetlink family */
>> +static struct genl_family ip_vs_genl_family = {
>> +     .id             = GENL_ID_GENERATE,
>> +     .hdrsize        = 0,
>> +     .name           = IPVS_GENL_NAME,
>> +     .version        = IPVS_GENL_VERSION,
>> +     .maxattr        = IPVS_CMD_MAX
>
> It's not a bug but looks like a typo, maxattr should
> specify the number of first level attributes.

Ah, this is how the family's attrbuf size is set. Looks like a bug
actually, but it hasn't affected anything because the command enum is
bigger than any of the first-level attribute enums. I might have
gotten this from net/irda/irnetlink.c, where it's also set to the
maximum command attribute value.

Note that I use different first level attributes depending on the
command. Rather than calculating the largest needed size, it's
probably best to join all attributes that may ever occur in the first
level into one big enum, right?

>> +static int ip_vs_genl_dump_service(struct sk_buff *skb, struct ip_vs_service *svc,
>> +                                struct netlink_callback *cb)
>> +{
>> +     void *hdr;
>> +
>> +     hdr = genlmsg_put(skb, NETLINK_CB(cb->skb).pid, cb->nlh->nlmsg_seq,
>> +                       &ip_vs_genl_family, NLM_F_MULTI,
>> +                       IPVS_CMD_GET_SERVICES);
>
> Typically, netlink code follows the following semantics WRT to
> commands/message types:
> -> GET_SERVICE (NLM_F_DUMP)
> <- NEW_SERVICE
> <- NEW_SERVICE
> <- NEW_SERVICE

Ok, so I will set the answer message type to IPVS_CMD_NEW_SERVICE (and
accordingly in the other dump cases). For non-dump GET commands, is it
usual to have the response ID be the same as the request?

>> +static int ip_vs_genl_get_cmd(struct sk_buff *skb, struct genl_info *info)
>> +{
>> +     struct sk_buff *msg;
>> +     void *reply;
>> +     int ret, cmd;
>> +
>> +     mutex_lock(&__ip_vs_mutex);
>> +
>> +     cmd = info->genlhdr->cmd;
>> +
>> +     msg = nlmsg_new(NLMSG_GOODSIZE, GFP_KERNEL);
>
> This should be nlmsg_new(NLMSG_DEFAULT_SIZE, ...) , NLMSG_GOODSIZE is for use
> with skb_alloc().

Ok, changed!

Thanks for the comments!

Julius

-- 
Google Switzerland GmbH
