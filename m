From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net] net: sctp: fix sctp_sf_do_5_1D_ce to verify if
 we/peer is AUTH capable
Date: Mon, 03 Mar 2014 16:40:48 -0500 (EST)
Message-ID: <20140303.164048.1803306262753946511.davem@davemloft.net>
References: <1393863784-28860-1-git-send-email-dborkman@redhat.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-sctp@vger.kernel.org,
	yasevich@gmail.com, nhorman@tuxdriver.com
To: dborkman@redhat.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:55342 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754906AbaCCVku (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 3 Mar 2014 16:40:50 -0500
In-Reply-To: <1393863784-28860-1-git-send-email-dborkman@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Daniel Borkmann <dborkman@redhat.com>
Date: Mon,  3 Mar 2014 17:23:04 +0100

> RFC4895 introduced AUTH chunks for SCTP; during the SCTP
> handshake RANDOM; CHUNKS; HMAC-ALGO are negotiated (CHUNKS
> being optional though):
 ...
> Commit bbd0d59809f9 introduced the possibility to receive
> and verification of AUTH chunk, including the edge case for
> authenticated COOKIE-ECHO. On reception of COOKIE-ECHO,
> the function sctp_sf_do_5_1D_ce() handles processing,
> unpacks and creates a new association if it passed sanity
> checks and also tests for authentication chunks being
> present. After a new association has been processed, it
> invokes sctp_process_init() on the new association and
> walks through the parameter list it received from the INIT
> chunk. It checks SCTP_PARAM_RANDOM, SCTP_PARAM_HMAC_ALGO
> and SCTP_PARAM_CHUNKS, and copies them into asoc->peer
> meta data (peer_random, peer_hmacs, peer_chunks) in case
> sysctl -w net.sctp.auth_enable=1 is set. If in INIT's
> SCTP_PARAM_SUPPORTED_EXT parameter SCTP_CID_AUTH is set,
> peer_random != NULL and peer_hmacs != NULL the peer is to be
> assumed asoc->peer.auth_capable=1, in any other case
> asoc->peer.auth_capable=0.
> 
> Now, if in sctp_sf_do_5_1D_ce() chunk->auth_chunk is
> available, we set up a fake auth chunk and pass that on to
> sctp_sf_authenticate(), which at latest in
> sctp_auth_calculate_hmac() reliably dereferences a NULL pointer
> at position 0..0008 when setting up the crypto key in
> crypto_hash_setkey() by using asoc->asoc_shared_key that is
> NULL as condition key_id == asoc->active_key_id is true if
> the AUTH chunk was injected correctly from remote. This
> happens no matter what net.sctp.auth_enable sysctl says.
> 
> The fix is to check for net->sctp.auth_enable and for
> asoc->peer.auth_capable before doing any operations like
> sctp_sf_authenticate() as no key is activated in
> sctp_auth_asoc_init_active_key() for each case.
> 
> Now as RFC4895 section 6.3 states that if the used HMAC-ALGO
> passed from the INIT chunk was not used in the AUTH chunk, we
> SHOULD send an error; however in this case it would be better
> to just silently discard such a maliciously prepared handshake
> as we didn't even receive a parameter at all. Also, as our
> endpoint has no shared key configured, section 6.3 says that
> MUST silently discard, which we are doing from now onwards.
> 
> Before calling sctp_sf_pdiscard(), we need not only to free
> the association, but also the chunk->auth_chunk skb, as
> commit bbd0d59809f9 created a skb clone in that case.
> 
> I have tested this locally by using netfilter's nfqueue and
> re-injecting packets into the local stack after maliciously
> modifying the INIT chunk (removing RANDOM; HMAC-ALGO param)
> and the SCTP packet containing the COOKIE_ECHO (injecting
> AUTH chunk before COOKIE_ECHO). Fixed with this patch applied.
> 
> Fixes: bbd0d59809f9 ("[SCTP]: Implement the receive and verification of AUTH chunk")
> Signed-off-by: Daniel Borkmann <dborkman@redhat.com>

Applied and queued up for -stable, exemplary commit message I
must say, thanks!
