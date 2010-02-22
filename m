From: Dan Smith <danms@us.ibm.com>
Subject: Re: [PATCH 3/5] Add checkpoint support for veth devices (v2)
Date: Mon, 22 Feb 2010 12:25:08 -0800
Message-ID: <87sk8t6msb.fsf@caffeine.danplanet.com>
References: <1266336187-19105-1-git-send-email-danms@us.ibm.com>
	<1266336187-19105-4-git-send-email-danms@us.ibm.com>
	<20100222195647.GB13135@us.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: containers@lists.osdl.org, netdev@vger.kernel.org
To: "Serge E. Hallyn" <serue@us.ibm.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from gw0.danplanet.com ([71.245.107.82]:43496 "EHLO
	mail.danplanet.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1753800Ab0BVUZN (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 22 Feb 2010 15:25:13 -0500
In-Reply-To: <20100222195647.GB13135@us.ibm.com> (Serge E. Hallyn's message of "Mon\, 22 Feb 2010 13\:56\:47 -0600")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

>> +	else if (!ckpt_obj_lookup(ctx, peer->nd_net, CKPT_OBJ_NET_NS)) {
>> +		ret = -EINVAL;
>> +		ckpt_err(ctx, ret,
>> +			 "Peer %s of %s not in checkpointed namespaces\n",
>> +			 peer->name, dev->name);

SH> I'm not sure this check does what you think it does: note that
SH> ckpt_netdev_base(), defined in the previous patch, and called
SH> higher up in this function, is going to checkpoint peer->nd_net.
SH> :)

Actually, no, ckpt_netdev_base() can't checkpoint peer->nd_net because
it's device-agnostic and has no knowledge of dev->peer.

The idea here was that we checkpoint a netns when we arrive at it via
nsproxy.  Doing that, we checkpoint the devices within.  We encounter
a veth device, which has a peer, so we decide if:

 1. We won't arrive at the peer later because it is in the init
    namespace, so we checkpoint it now.
 2. We will arrive at it later because the peer's netns is in the list
    we've already collected, so checkpoint the peer with its namespace
 3. Neither are true and we won't arrive at it later and therefore we
    can't allow checkpoint to continue

#2 depends on the collect process having put all the task's netns' in
 the hash ahead of time.

-- 
Dan Smith
IBM Linux Technology Center
email: danms@us.ibm.com
