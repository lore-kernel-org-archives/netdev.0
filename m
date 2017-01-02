From: Jiri Benc <jbenc@redhat.com>
Subject: Re: [PATCH iproute2 net-next] tc: flower: support matching flags
Date: Mon, 2 Jan 2017 19:55:22 +0100
Message-ID: <20170102195522.7488179b@griffin>
References: <1482930409-55059-1-git-send-email-paulb@mellanox.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org,
        Stephen Hemminger <stephen@networkplumber.org>,
        "David S. Miller" <davem@davemloft.net>,
        Hadar Hen Zion <hadarh@mellanox.com>,
        Or Gerlitz <ogerlitz@mellanox.com>,
        Roi Dayan <roid@mellanox.com>
To: Paul Blakey <paulb@mellanox.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:57688 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1755683AbdABSz0 (ORCPT <rfc822;netdev@vger.kernel.org>);
        Mon, 2 Jan 2017 13:55:26 -0500
In-Reply-To: <1482930409-55059-1-git-send-email-paulb@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 28 Dec 2016 15:06:49 +0200, Paul Blakey wrote:
> Enhance flower to support matching on flags.
> 
> The 1st flag allows to match on whether the packet is
> an IP fragment.
> 
> Example:
> 
> 	# add a flower filter that will drop fragmented packets
> 	# (bit 0 of control flags)
> 	tc filter add dev ens4f0 protocol ip parent ffff: \
> 		flower \
> 		src_mac e4:1d:2d:fd:8b:01 \
> 		dst_mac e4:1d:2d:fd:8b:02 \
> 		indev ens4f0 \
> 		matching_flags 0x1/0x1 \
> 	action drop

This is very poor API. First, how is the user supposed to know what
those magic values in "matching_flags" mean? At the very least, it
should be documented in the man page.

Second, why "matching_flags"? That name suggests that those modify the
way the matching is done (to illustrate my point, I'd expect things
like "if the packet is too short, match this rule anyway" to be a
"matching flag"). But this is not the case. What's wrong with plain
"flags"? Or, if you want to be more specific, perhaps packet_flags?

Third, all of this looks very wrong anyway. There should be separate
keywords for individual flags. In this case, there should be an
"ip_fragment" flag. The tc tool should be responsible for putting the
flags together and creating the appropriate mask. The example would
then be:

	tc filter add dev ens4f0 protocol ip parent ffff: \
		flower \
		src_mac e4:1d:2d:fd:8b:01 \
		dst_mac e4:1d:2d:fd:8b:02 \
		indev ens4f0 \
		ip_fragment yes\
	action drop

I don't care whether it's "ip_fragment yes/no", "ip_fragment 1/0",
"ip_fragment/noip_fragment" or similar. The important thing is it's a
boolean flag; if specified, it's set to 0/1 and unmasked, if not
specified, it's wildcarded.

Stephen, I understand that you already applied this patch but given how
horrible the proposed API is and that's even undocumented in this
patch, please reconsider this. If this is released, the API is set in
stone and, frankly, it's very user unfriendly this way.

Paul, could you please prepare a patch that would introduce a more sane
API? I'd strongly prefer what I described under "third" but should you
strongly disagree, at least implement "second" and document the
currently known flag values.

Thanks,

 Jiri
