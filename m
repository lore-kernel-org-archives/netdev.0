From: Dan Smith <danms@us.ibm.com>
Subject: Re: [PATCH 5/5] c/r: Add AF_UNIX support (v6)
Date: Wed, 29 Jul 2009 11:37:39 -0700
Message-ID: <87vdlbmj2k.fsf@caffeine.danplanet.com>
References: <1248295301-30930-1-git-send-email-danms@us.ibm.com>
	<1248295301-30930-6-git-send-email-danms@us.ibm.com>
	<4A6F2D62.9040005@librato.com> <87ljm8czsf.fsf@caffeine.danplanet.com>
	<4A6F6B19.9010508@librato.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: containers@lists.osdl.org, Alexey Dobriyan <adobriyan@gmail.com>,
	netdev@vger.kernel.org
To: Oren Laadan <orenl@librato.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from gw0.danplanet.com ([71.245.107.82]:58175 "EHLO
	mail.danplanet.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1752671AbZG2Shn (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 29 Jul 2009 14:37:43 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

OL> Hmmm.. what about splice_direct_to_actor() ?

The comments (and code) for that function define that we can't splice
between non-regular files.  For now, this would work, but would fail
if you pass a socket as the checkpoint descriptor, as might be the
case in a migration.

OL> Still need to keep it in mind for inet when including those
OL> lingering sockets that don't belong to anyone.

Yep.

OL> This also means that a peer (of a dgram socket) that was closed
OL> will not be checkpointed, so restoring the rcvbuf of the remaining
OL> dgram socket wouldn't work.

Actually, the new algorithm creates the pair when finding the first
socket instead of the second, so I think it will still work.  However,
I'll test it and apply some thought to what will happen to the socket
we created to represent the dead one (I think it will die when the
objhash is freed).

OL> Hmm.. then what happens when you have a circular dependency ?
OL> For example, three dgram sockets, A, B and C where: A->B, B->C
OL> and C->A  ('->' means connected).

Hmm, hadn't thought of that.

OL> I suspect that sock_unix_restore_connect() will fail, because
OL> neither:

OL> +	if (!IS_ERR(this) && !IS_ERR(peer)) {

OL> nor

OL> +	} else if ((PTR_ERR(this) == -EINVAL) && (PTR_ERR(peer) == -EINVAL)) {

OL> will hold true, therefore:

OL> +	} else {
OL> +		ckpt_debug("Order Error\n");
OL> +		ret = PTR_ERR(this);
OL> +		goto out;
OL> +	}

Yeah, but I don't think it will be too hard to add another case to
that condition to handle this.  I'll check into it.

-- 
Dan Smith
IBM Linux Technology Center
email: danms@us.ibm.com
