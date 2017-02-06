From: Harald Welte <laforge@gnumonks.org>
Subject: Re: [PATCH 1/1] gtp: support SGSN-side tunnels
Date: Mon, 6 Feb 2017 15:16:22 +0100
Message-ID: <20170206141622.4szfsu6h4qqlhdvk@nataraja>
References: <20170203091231.10142-1-jonas@southpole.se>
 <20170206110858.GA3896@salvia>
 <3efa90fe-3f66-1da0-6038-4fbf9ec2b7ce@southpole.se>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Pablo Neira Ayuso <pablo@netfilter.org>, netdev@vger.kernel.org
To: Jonas Bonn <jonas@southpole.se>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ganesha.gnumonks.org ([213.95.27.120]:58706 "EHLO
        ganesha.gnumonks.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751669AbdBFOQh (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 6 Feb 2017 09:16:37 -0500
Content-Disposition: inline
In-Reply-To: <3efa90fe-3f66-1da0-6038-4fbf9ec2b7ce@southpole.se>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Jonas,

On Mon, Feb 06, 2017 at 02:33:07PM +0100, Jonas Bonn wrote:
> Fair enough.  The use-case I am looking at involves PGW load-testing where
> the simulated load is generated locally on the SGSN so it _is_ seeing IP
> packets and the SNDCP is left out altogether.  

Ok, it would have been useful to document that test-only feature in the
changelog and/or code.  Like "support simulated RAN-side tunnels" or
"support SGSN/S-GW simulation".

> Perhaps this is too pathological to warrant messing with the upstream
> driver... I don't know: the symmetry does not cost much even if it's
> of limited use.

There are plenty of features in the mainline kernel related to testing,
see pktgen for example.  So I think if it doesn't impose complexity,
performance issues or stretches the existing architecture, I think
there's no reason to keep it out.

Looking at the code, I think the one conditional on the flags is not
going to kill significant performance of the "normal" use case.  But
that's of course just guessing, without any benchmark to back that up.

Semantically, I'm not sure if the FLAGS and the re-use of the
SGSN_ADDRESS TLV is the best choice.  If suddenly the meaning of the TLV
is "Peer GSN Address" then it should be called that way.  We could have
a #define SGSN_ADDRESS to GSN_PEER_ADDRESS to make old code compile.
I'll let Pablo respond to this as he came up with the netlink interface,
as far as I can remember :)

Also, like with any changes to the kernel and netlink interface code, I
think we should always mandate similar changes to be made to libgtpnl so
the feature can actually be used/tested with the standard
tools/utilities available to anyone.

> Couldn't the SNDCP theoretically be a separate node and push IP packets to
> the SGSN, thus making this useful?  Perhaps it's a stretch...

No, because you would introduce an hop (or even two!) at the IP level,
breaking
* the notion of who the remote IP address is (remote poin-to-point address)
  of the PDP context
* packets get modified (TTL decrement, ...) where they are not supposed to
* you suddenly might get TTL exceeded, dest unreachable, ...) out of
  nowhere into your user IP
* you introduce serious security issues by having the kernel IP routing
  code between the outer IP (the operator RAN/core network) and the
  inner user IP payload.

Regards,
	Harald
-- 
- Harald Welte <laforge@gnumonks.org>           http://laforge.gnumonks.org/
============================================================================
"Privacy in residential applications is a desirable marketing option."
                                                  (ETSI EN 300 175-7 Ch. A6)
